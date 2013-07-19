REBOL [
	Title: "R3 GUI - Face: access"
	Purpose: {
		Provides access to a face's values and facets (attributes).
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Date: 15-Mar-2011/16:38:39+1:00
	Version: "$Id$"
]

get-face: funct [
	"Get a variable from the face state"
	face [object! block! path!] "Face or block of faces to get"
	/field
	word [word! block! none!]
	/state	"Get face state"
][
	if block? face [
		; TODO: /field and /state support?
		out: make block! 10
		foreach fac face [
			append out get-face fac
		]
		return out
	]

	;process the path notation
	if path? face [
		face: to block! face
		word: copy next face
		face: get first face
	]

	either state [
		state: make map! 10
		foreach field get-fields? face [
			state/:field: get-face/field face field
		]
		state
	][
		do-actor face 'on-get any [word 'value]
	]
]

set-face: func [
	"Set some facets in the given face, redraw the face."
	face [object!]
	value
	/no-show	"Do not redraw the face at this time."
	/field		"Set only the specific facet."
	word [word! none!]
	/state		"Set all key facets as in VALUE."
				"VALUE has to be a map having word keys in this case."
][
	either state [
		foreach word value [do-actor face 'on-set reduce [word value/:word no-show]]
	][
		do-actor face 'on-set reduce [any [word 'value] :value no-show]
	]
	unless no-show [
		draw-face face
	]
	if get-facet face 'relay [apply :do-face [face false none no-show]]
]

set-facet: func [
	"Set a named facet in face/facets. Creates it if needed."
	face [object!]
	word [word!]
	value
][
	append face/facets reduce [to-set-word word :value]
	:value
]

get-facet: funct [
	"Get a named facet(s) from the face or style."
	face [object!]
	field [word! block!] "A word or block of words (set-words allowed)."
][
	either word? f: field body: [
		any [
			all [
				val: in face/facets f
				any [
					val: get/any :val
					true
				]
			]
			all [
				style: select guie/styles face/style ; (result is a style)
				val: in style/facets f
				val: get/any :val
			]
		]
		val
	][
		; Special mode: set words in a block to their facet values.
		; A block of local variables will be set to those same values
		; from the facets of the face. The vars are allowed to be set-words
		; in order to support auto-locals (without requiring extra code).
		foreach word field [
			if any-word? :word [
				f: to word! word
				set :word do body ; can be set-word (word:) datatype
			]
		]
	]
]

get-panel: funct [
	"Get values for named faces"
	panel [object!]
][
	names: select panel 'names
	either names [
		out: copy []
		foreach face values-of panel/names [
			append/only out get-face face
		]
		out
	][
		none	
	]
]