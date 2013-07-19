REBOL [
	Title: "R3 GUI - Style: tag"
	Purpose: {
		These are the main functions for evaluating style related code.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

; set at stylize time
style-tags: [
	internal		; the style is intended for internal use
	layout			; the style is layout of other faces
	compound		; the style is a compound of part styles
	edit			; the style contains user editable text
	state			; the style is a user interactive state changing item
	action			; the style is a user interactive action item
	info			; the style is an indicator
	tab				; the style is part of tab navigtion
	detab			; the style handles TAB key event in a custom way
	eat-tab			; the style disables nested tab navigation
	auto-tab		; the style automatically tabs away on a specific event
	select			; the style contains user selectable text
	keep			; the style retains highlighting and caret after unfocusing
]

; set at layout and any other time
face-tags: [
	;validate		; the face will undergo validation
	;invalid		; the face did not pass validation
	;required		; the face is required to pass validation
	default			; the face is the window default
	focus			; the face is in focus
	disabled		; the face is disabled
	frozen			; the face is frozen
	dirty			; the face is dirty
	;pass			; the face has passed validation
]

; set at window creation time
window-tags: [
	form			; windows containing a validatable form or other field or state faces
	inform			; windows containing only text or images and no validatable faces
	popup			; windows containing a menu or selection, which when interacted with, results in immediate return of a value
]

; build tag map
guie/tags: make map! []
foreach tag style-tags [repend guie/tags [tag true]]
foreach tag face-tags [repend guie/tags [tag true]]
foreach tag window-tags [repend guie/tags [tag true]]

;guie/tags: tags

tag-error: funct [
	"Generate error on tag problem"
	words [word! block!]
	error [word!]
] [
	or-tag: func [w] [replace/all reform w " " " or "]
	fail-gui select [
		unknown ["Unknown tag:" words]
		coexist [words/1 "cannot coexist with " or-tag next words]
		requires [words/1 "requires" or-tag next words]
	] error
]

tag-face?: funct [
	"Queries whether a tag exists for a face"
	face
	tag
	/deep
] [
	any [not word? tag guie/tags/:tag tag-error tag 'unknown]
	either deep [
		if deep [traverse-face [tag-face? face tag]] ; not correct yet
	][
		either all [block? tag not empty? tag] [
			foreach t tag [if tag-face? face t [return true]]
		][
			all [face face/tags/:tag]
		]
	]
]

tag-face: funct [
	"Applies a tag to a face"
	face
	tag
	/deep
] [
	any [guie/tags/:tag tag-error tag 'unknown]
	unless apply :tag-face? [face tag deep] [face/tags/:tag: true]
	face
]

untag-face: funct [
	"Removes a tag from a face"
	face
	tag
	/deep
] [
	any [guie/tags/:tag tag-error tag 'unknown]
	face/tags/:tag: none
	if deep [traverse-face [face/tags/:tag: none]]
	face
]

make-tags: funct [
	; INTERNAL: make the style/tag map.
	tags ; name: [block]
][
	map: make map! 4
	foreach tag tags [repend map [tag true]]
	map
]

tagged-faces: funct [
	"Return all faces with a tag"
	face [object!]	"Face to search for faces"
	tag	[word!]			"Tag to search for"			; TODO: add support for block!
][
	faces: copy []
	traverse-face face [if tag-face? face tag [append faces face]]
	unique faces
]

;-- Standard Tags -----------------------------------------------------------
;
;   These are the default tags for all styles. May be overridden.

guie/style/tags: make-tags []
