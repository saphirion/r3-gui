REBOL [
	Title: "R3 GUI - Text: editing"
	Purpose: {
		Move the cursor based on key (or other) actions.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

insert-text-face: funct [
	"Insert text into field or area at cursor/mark position."
	face [object!]
	text [char! string!]
][
	state: face/state
	if mhead: state/mark-head [
		t: head state/cursor
		state/cursor: mhead
		remove/part mhead state/mark-tail
		if get-facet face 'hide-input [
			remove/part at face/facets/text-edit index? mhead index? state/mark-tail
		]
		select-none state
		clear-text-caret face
	]
	
	state/cursor: insert state/cursor either get-facet face 'hide-input [
		insert at face/facets/text-edit index? state/cursor text
		either string? text [
			append/dup clear "" "*" length? text
		][
			"*"
		]
	][
		text
	]
	
;	resize-text-face face
]

remove-text-face: funct [
	"Remove text from a field or area at cursor/mark position."
	face [object!]
	len
	/clip
][
	state: face/state

	either mhead: state/mark-head [
		mtail: state/mark-tail
		state/cursor: either positive? offset? mhead mtail [mhead][mtail]
		select-none state
	][
		mhead: state/cursor
		mtail: len
		case [
			len = 'end-line [mtail: any [find mhead newline tail mhead]]
			negative? len [state/cursor: skip mhead len]
		]
	]
	if get-facet face 'hide-input [
		take/part at face/facets/text-edit index? mhead either string? mtail [index? mtail][mtail]
	]
	text: take/part mhead mtail
	if clip [save-clip-text text]
;	resize-text-face face
]

copy-text-face: funct [
	"Copy text from a field or area at cursor/mark position."
	face
][
	state: face/state

	either mhead: state/mark-head [
		save-clip-text copy/part mhead state/mark-tail
	] [
		if get-facet face 'quick-copy [save-clip-text head face/cursor]
	]
]

select-all: funct [
	"Select and mark all text in face"
	face
][
	face/state/mark-head: head face/state/cursor
	face/state/cursor: face/state/mark-tail: tail face/state/cursor
;	update-selection face
	update-text-caret face
]

select-none: func [state] [
	state/mark-head: state/mark-tail: none
]

click-text-face: funct [
	"Make text face the focus and setup cursor."
	face
	cursor
	event
][
	if block? cursor [cursor: first cursor] ; no richtext (yet)
	clear-text-caret face

	face/state/cursor: cursor
	face/state/xpos: none

	if event [
		case [
			; Double click selection?
			find event/flags 'double [
				move-cursor face 'full-word 1 true
			]
			; Extended selection?
			all [
				find event/flags 'shift
				face/state/mark-head
			][
				face/state/mark-tail: cursor
			]
			; No selection:
			true [select-none face/state]
		]
	]
	;use 'forced focus' only when face is already focused
	apply :focus [face guie/focal-face = face]
]

save-clip-text: func [txt] [
	write clipboard:// to-binary enline txt
]

load-clip-text: does [
	to-string deline read clipboard://
]