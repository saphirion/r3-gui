REBOL [
	Title: "R3 GUI - Text: caret handling"
	Purpose: {
		Handles the text caret and its position mapping.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

;; I do not like the general method of this code and want to look into
;; changing it. -Carl

;-- Text Caret --------------------------------------------------------------
;
;   Terms:
;       cursor: the text string index for insert/remove (ibeam)
;       mark:   the text string indices for highlight head and tail
;       caret:  object used by graphics system for ibeam and highlight

init-text-caret: func [face][
	face/state/caret: context [
		caret: copy/deep [[""] ""] ; placeholders
		highlight-start: copy/deep [[""] ""]
		highlight-end: copy/deep [[""] ""]
	]
]

clear-text-caret: funct [face][
	car: face/state/caret
	car/caret/1: car/highlight-start/1: car/highlight-end/1: copy [""]
	car/caret/2: car/highlight-start/2: car/highlight-end/2: copy ""
]

update-text-caret: funct [face][
	car: face/state/caret
	car/caret/1: car/highlight-start/1: car/highlight-end/1: back tail get-gob-text face/gob/1
	car/caret/2: face/state/cursor
	car/highlight-start/2: face/state/mark-head
	car/highlight-end/2: face/state/mark-tail
]

goto-caret: funct [
	"Set text caret to a specific position."
	face
	pos [string! integer! none!]
][
	unless pos [exit]
	if string? pos [pos: index? pos]

	; GOB/text holds richtext block: [font f caret s ... [bold "string"]]
	gob: first face/gob
	car: select get-gob-text gob 'caret
	txt: back tail get-gob-text/src gob ; richtext block
	car/caret/1: car/highlight-start/1: car/highlight-end/1: txt
	
	car/caret/2: face/state/cursor: at face/facets/text-edit pos
	car/highlight-start/2: none
	car/highlight-end/2:   none
]

caret-xy?: funct [
	"Return cursor caret offset from text gob."
	gob
][
	any [
		all [
			car: select get-gob-text gob 'caret ; get caret object
			car/caret/1
			car/caret/2
			;probe index? car/caret/2
			;probe
			caret-to-oft gob car/caret/1 car/caret/2
		]
		0x0
	]
]

see-caret: funct [
	"Force window to scroll for caret to be seen."
	face
][
	;don't process the function(at least for now) if text is not horizontal
	if all [get-facet face [rotate:] rotate <> 0] [exit]
	
	tgob: first face/gob ;	text gob
	rowh: second face-char-size? face ; row height
	sizy: tgob/size/y
	scroll: get-gob-scroll tgob
	cpos: scroll + caret-xy? tgob

	;setup X scroll
	case [
		cpos/x < 0 [
			scroll/x: scroll/x - cpos/x + 1
		]
		cpos/x > tgob/size/x [
			scroll/x: scroll/x - (cpos/x - tgob/size/x) - 2
		]
		tgob/size/x > first size-txt tgob [
			scroll/x: 0
		]
	]

	if sizy < rowh [
		;gob is too small for v. scrolling
		scroll/y: 0
		set-gob-scroll tgob scroll
		exit
	]
	
	posy: rowh + cpos/y; cursor as xy position
	tsiz: size-text-face face as-pair tgob/size/x 10000

	case [
		posy < rowh [ ; top
			scroll/y: scroll/y - posy + rowh
		]
		posy > sizy [ ; bottom
			scroll/y: scroll/y - (posy - sizy)
		]
	]
	set-gob-scroll tgob scroll
]

move-caret: funct [
	"Move caret vertically. Return cursor string index."
	face
	action [word!]
][
	tgob: sub-gob? face
	xy: caret-xy? tgob ; offset of cursor
	unless xy [return face/state/cursor]
	rowh: second face-char-size? face ; height of font

	; Determine the current X pixel offset.
	; Use xpos to keep the position stable for up/down.
	x: face/state/xpos: any [face/state/xpos xy/x]

	; Determine the vertical delta:
	v: switch action [
		up [negate rowh]
		down [rowh]
		page-up [negate face/gob/size/y]
		page-down [face/gob/size/y]
	]

	; Determine the vertical pixel offset (from center of line):
	y: xy/y + (rowh / 2) + v

	; Get cursor from offset:
	caret: oft-to-caret tgob as-pair x y
	if empty? caret [			; we are after the text
		caret: back tail caret	; move back to text
		caret/1: tail caret/1	; and set text to end
	]
	first caret ; return cursor
]

clear-all-carets: funct [
	"Clear all carets in a window/face"
	face
][
	fields: tagged-faces face 'edit
	foreach f fields [
		if in f/state 'caret [	; some tagged fields are not really fields (CHECK IT)
			clear-text-caret f
		]
	]
]