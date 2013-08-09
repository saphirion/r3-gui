REBOL [
	Title: "R3 GUI - Text: draw"
	Purpose: {
		Make text draw GOB blocks.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

make-text: funct [
	"Make a text draw command block, with all necessary attributes."
	face
	body
][
	remind-gui ["making text:" face/style]
	style: face-font? face

	out: make block! 6
	foreach field [font para anti-alias] [
		if style/:field [repend out [field any [select face field style/:field]]]
	]

	; If it is scrollable, add SCROLL:
	if val: select face/state 'scroll [
		cs: negate max 0x0 face/facets/content-size
		repend out ['scroll as-pair val/x * cs/x  val/y * cs/y]
	]

	; If it is selectable, add CARET:
	if val: select face/state 'caret [
		repend out ['caret val]
	]

	;handle access key marker
	if id: select face/facets 'access-key [
		f: any [
			get select face/facets 'access-face
			face
		]

		if id: any [
			find-access-key f id
			id
		][
			if f: any [find/case body id find body id][
				i: index? f
				body: reduce [copy/part body i - 1 'u to string! body/:i 'u off copy skip body i]
			]
		]
	]
	
	append out body
]

make-text-gob: funct [
	"Creates special 'text gob' which is used for editable text"
	face [object!]
	gsize [pair!]
	text-data [string!]
] [
	gob: make gob! [offset: 0x0 size: gsize data: face]
	fstyle: face-font? face
	out: make block! 10 + length? text-data
	foreach field [font para anti-alias] [
		if fstyle/:field [repend out [field any [select face field fstyle/:field]]]
	]

	rot: get-facet face 'rotate

	append face 'draw-text

	face/draw-text: bind/copy compose/deep [
			(
				switch/default rot [
					90 [
						[
							translate (as-pair gob/size/x - facets/space/1/x - facets/space/2/x 0 - facets/space/1/y)
							rotate 90
						]
					]
					270 [
						[
							translate (as-pair 0 gob/size/y - facets/space/1/y)
							rotate 270
						]
					]
				][
				]
			)
			pen off
			fill-pen (out/font/color)
			anti-alias (out/anti-alias)
			text 0x0 none
			(either all [rot rot <> 0] ['vectorial]['aliased])
			[
				(append out compose [
					caret (select face/state 'caret)
					(text-data)
				])
			]
	] face

	gob
]

get-gob-text: func [
	"returns rich-text block (source dialect or resulting command block) of a 'text gob'"
	gob [gob!]
	/src "return the source text dialect block"
][
	first find any [
		all [src gob/data/draw-text]
		gob/draw 
		gob/data/draw-text
	] block!
]

get-gob-scroll: func [
	"returns scroll value of a 'text gob'"
	gob [gob!]
][
	gob/data/draw-text/text
]

set-gob-scroll: funct [
	"sets scroll value of a 'text gob'"
	gob [gob!]
	val [pair!]
][
	gob/data/draw-text/text: val
	all [
		gob/draw
		gob/draw/text: val
	]
]

oft-to-caret: funct [
	"offset-to-caret wrapper for text-gob only"
	gob [gob!]
	oft [pair!]
][
	tmp: gob/draw
	gob/text: get-gob-text gob
	result: offset-to-caret gob oft
	gob/draw: tmp
	result
]

caret-to-oft: funct [
	"caret-to-offset wrapper for 'text-gob' only"
	gob [gob!]
	element [block!]
	position [string!]
][
	tmp: gob/draw
	gob/text: get-gob-text gob
	result: caret-to-offset gob element position
	gob/draw: tmp
	result
]

size-txt: funct [
	"size-text wrapper for 'text-gob' only"
	gob [gob!]
][
	tmp: gob/draw
 	gob/text: get-gob-text gob
	unless tmp [gob/text: to-text gob/text copy []]
	result: size-text gob
	gob/draw: tmp
	result
]

size-text-face: funct [
	face 		[object!]
	limit-size	[pair!]
][
	gob: make gob! [offset: 0x0 size: limit-size]
	fstyle: face-font? face
	ffont: any [select face 'font fstyle/font]
	fpara: any [select face 'para fstyle/para]
	to-text compose [
		font (ffont)
		para (fpara)
		anti-alias (fstyle/anti-alias)
		(any [
			select face/facets 'text-body
			select face/facets 'text-edit
		])
	] gob/text: clear []
	; NOTE: This is here due to what I think is buggy behaviour of SIZE-TEXT
	(either fpara/wrap? [1x0][0x0]) + ;add 1px because of bug in "wrap mode" (todo: check host-kit RT code)
	ffont/offset + fpara/margin + fpara/origin + size-text gob
]

font-char-size?: funct [
	fstyle [word! object!]	"Font style"
	/with
		char [string!]
][
	if word? fstyle [fstyle: what-font? fstyle]
	unless with [char: "M"]
	gob: make gob! [offset: 0x0 size: 300x100]
	to-text reduce [
		'font fstyle/font
		'para make fstyle/para [wrap?: off] ; avoid infinite loop font bug
		'anti-alias fstyle/anti-alias
		char
	] gob/text: clear []
	size-text gob
]

font-text-size?: funct [
	fstyle [word! object!] "Font style"
	text [string! block!]
][
	font-char-size?/with fstyle text
]

resize-text-face: funct [
	face
][
	; TODO:
	; right now, resize-text-face ignores gob/text/scroll.
	; That means that after resizing, cursor position is not repositioned
	; with regards to new gob size. 

	face/state/xpos: none ; invalidates x position
	fstyle: face-font? face
;	print words-of face
	all [
		tgob: first face/gob ; text gob
		size: size-txt tgob
		tgob/size/y: -5 + second face/facets/viewport-box/bottom-right ; -5 prevents text from overflowing on bottom
;		tgob/size/y: size/y + any [fstyle/para/origin/y 0]
		tgob/size/x: -5 + face/facets/gob-size/x - any [fstyle/para/margin/x 0] ; -5 prevents text from overflowing on right
	]
]

limit-text-size: funct [ "Limit text size so it will fit in given gob size. Modifies!"
	text		[string! block! none!] "String to limit. Can convert none! to empty string too."
	size		[pair!]			"Maximal text size"
	fstyle						"Font size"
][
	; create test gob
	text: any [text ""]
	gob: make gob! [offset: 0x0 size: size]
	to-text compose [
		font (fstyle/font)
		para (fstyle/para)
		anti-alias (fstyle/anti-alias)
		(text)
	] gob/text: clear []

	t: tail gob/text
	while [
		all [
			t: find/reverse/only t string!
			size/x < first size-text gob
		]
	][
		either empty? t/1 [
			t: back t
		][
			remove back tail t/1
			t: next t
		]
	]
	text
]
