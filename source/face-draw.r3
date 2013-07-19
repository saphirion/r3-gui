REBOL [
	Title: "R3 GUI - Face: draw"
	Purpose: {
		Generates the scalar graphic DRAW block for a face.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

dialect-draw: make object! [
    type-spec: [block!]
    anti-alias: [logic!]
    arc: [
        pair! pair! decimal! decimal! word!
        decimal! word!
    ]
    arrow: [tuple! pair!]
    box: [pair! pair! decimal!]
    circle: [pair! decimal! decimal!]
    clip: [pair! pair! logic!]
    curve: [* pair!]
    effect: [pair! pair! block!]
    ellipse: [pair! pair!]
    fill-pen: [tuple! image! logic!]
    fill-rule: [word!]
    gamma: [decimal!]
    grad-pen: [word! word! pair! logic! decimal! decimal! decimal! decimal! decimal! block!]
    invert-matrix: []
    image: [image! tuple! word! word! integer! integer! integer! integer! * pair!]
    image-filter: [word! word! decimal!]
    line: [* pair!]
    line-cap: [word!]
    line-join: [word!]
    line-pattern: [logic! tuple! * decimal!]
    line-width: [decimal! word!]
    matrix: [block!]
    pen: [tuple! image! logic!]
    polygon: [* pair!]
    push: [block!]
    reset-matrix: []
    rotate: [decimal!]
    scale: [decimal! decimal!]
    shape: [block!]
    skew: [decimal!]
    spline: [integer! word! * pair!]
    text: [word! pair! pair! block!]
    transform: [decimal! pair! decimal! decimal! pair!]
    translate: [pair!]
    triangle: [pair! pair! pair! tuple! tuple! tuple! decimal!]
    close: []
    curv: [* pair!]
    hline: [decimal!]
    move: [* pair!]
    qcurv: [pair!]
    qcurve: [* pair!]
    vline: [decimal!]
    radial: none
    conic: none
    diamond: none
    linear: none
    diagonal: none
    cubic: none
    non-zero: none
    even-odd: none
    border: none
    nearest: none
    bilinear: none
    bicubic: none
    gaussian: none
    resample: none
    butt: none
    square: none
    rounded: none
    miter: none
    miter-bevel: none
    round: none
    bevel: none
    fixed: none
    closed: none
    normal: none
    repeat: none
    reflect: none
    large: none
    sweep: none
    vectorial: none
]

comment {
parse-box-sizes: funct [
	data [pair! block! integer! none!]
][
	parse reduce [any [data 0]][
		some [
			set val pair! (
				result: reduce [val val]
			)
			| set val block! (
				result: either 1 < length? val [
					val
				][
					compose [(val) 0x0]
				]
			)
			| set val integer! (
				val: as-pair val val
				result: reduce [val val]
			)
		]
	]
	result
]
}

set-draw-keywords-in: funct [
	context [object!]
	size [pair!]
][
	do bind [
		gob-size: min max size min-size max-size

		space: reduce [
			margin/1 + border-size/1 + padding/1
			margin/2 + border-size/2 + padding/2
		]
		
		size: gob-size - space/1 - space/2
		
		margin-box/top-left: negate space/1
		margin-box/bottom-right: size + space/2
		margin-box/top-right: as-pair margin-box/bottom-right/x margin-box/top-left/y
		margin-box/bottom-left: as-pair margin-box/top-left/x margin-box/bottom-right/y
		margin-box/center: margin-box/bottom-right + margin-box/top-left * .5

		border-box/top-left: margin-box/top-left + margin/1
		border-box/bottom-right: margin-box/bottom-right - margin/2
		border-box/top-right: as-pair border-box/bottom-right/x border-box/top-left/y
		border-box/bottom-left: as-pair border-box/top-left/x border-box/bottom-right/y
		border-box/center: border-box/bottom-right + border-box/top-left * .5
		
		padding-box/top-left: border-box/top-left + border-size/1
		padding-box/bottom-right: border-box/bottom-right - border-size/2
		padding-box/top-right: as-pair padding-box/bottom-right/x padding-box/top-left/y
		padding-box/bottom-left: as-pair padding-box/top-left/x padding-box/bottom-right/y
		padding-box/center: padding-box/bottom-right + padding-box/top-left * .5
		
		viewport-box/top-left: 0x0
		viewport-box/bottom-right: size
		viewport-box/top-right: as-pair viewport-box/bottom-right/x viewport-box/top-left/y
		viewport-box/bottom-left: as-pair viewport-box/top-left/x viewport-box/bottom-right/y
		viewport-box/center: size * .5
	] context
]

;NOTE: box-model block is not deep copied(to save one copy/deep call) in the draw-face function
;so the content is bound to face/faces of *all* faces that are passed to the draw-face function
;because of this, we have to access values that are optional in facets object rather thru gob/data/facets
;instead of taking advantage of the binding to avoid value collisions
;as example see the 'material value handling below

box-model: [
	;move the coordinates so 0x0 begins at the top-left viewport corner
	translate (space/1)
	clip (max margin-box/top-left margin-box/top-left - gob/offset + any [all [gob/parent gob/parent/data/facets/space/1] 0x0])
		 (margin-box/bottom-right - (margin-box/bottom-right + gob/offset - any [all [gob/parent gob/parent/data/facets/viewport-box/bottom-right + gob/parent/data/facets/space/1 ] 0x0]))
	
	anti-alias off
	pen off
	(
		all [
			bg-color
			not select gob/data/facets 'material
			[
				fill-pen bg-color
				box border-box/top-left border-box/bottom-right
				fill-pen off
			]
		]
	)
	
;			translate (negate space/1)

	(
		all [
			border-color
			[pen border-color]
		]
	)
	
	;calculate borders
	;top
	(
		all [
			border-size/1/y > 0
			[
				line-cap (pick [square butt] border-size/1/y = 1)
				line-width (border-size/1/y)
				line (border-box/top-left - 1x0 + (0x1 * (to integer! border-size/1/y / 2)))
					(border-box/top-right + (0x1 * (to integer! border-size/1/y / 2)))
				]
		]
	)
	;left
	(
		all [
			border-size/1/x > 0
			[
				line-cap (pick [square butt] border-size/1/x = 1)
				line-width (border-size/1/x)
				line (border-box/top-left - 0x1 + (1x0 * (to integer! border-size/1/x / 2)))
					(border-box/bottom-left + (1x0 * (to integer! border-size/1/x / 2)))
			]
		]
	)
	;bottom
	(
		all [
			border-size/2/y > 0
			[
				line-cap (pick [square butt] border-size/2/y = 1)
				line-width (border-size/2/y)
				line (border-box/bottom-left - 1x0 - (0x1 * (to integer! border-size/2/y / 2 + .5)))
					(border-box/bottom-right - (0x1 * (to integer! border-size/2/y / 2 + .5)))
			]
		]
	)
	;right
	(
		all [
			border-size/2/x > 0
			[
				line-cap (pick [square butt] border-size/2/x = 1)
				line-width (border-size/2/x)
				line (border-box/top-right - 0x1 - (1x0 * (to integer! border-size/2/x / 2 + .5)))
					(border-box/bottom-right - (1x0 * (to integer! border-size/2/x / 2 + .5)))
			]
		]
	)
	
	;clip the 'viewport' only
;	clip viewport-box/top-left viewport-box/bottom-right
	
	;set defaults for the 'user defined' DRAW that can follow
	line-width 1
	pen white
	fill-pen off
	anti-alias on
]

set-box-model: funct [
	face [object!]
][
	if name: select face/facets 'box-model [
		face/facets: make copy/types select any [
			select face 'box-models
			guie/box-models
		] name block! face/facets
	]
]

draw-face: funct [
	"Given a face, generate its DRAW block."
	face [object!]
	/no-show "Do not queue it for refresh"
	/now "refresh the face immediately"
][
;	debug-gui 'draw [face/style]
	draw-buf: copy [] ;must be a copy to handle nested draw-face calls

	; Check if we need to draw its subfaces:
	unless empty? face/gob [
;		foreach f faces? face [draw-face/no-show f]
		foreach-face f face [draw-face/no-show f]
	]

	;don't set DRAW if color, text or effect is used
	if any [
		face/gob/color
		face/gob/text
		face/gob/effect
	][
;		face/draw-result: none
		unless no-show [
			either now [
				show-now
			][
				show-later face
			]
		]
		exit
	]
	
	;check if face has a "text-gob" and update it
	if all [
		face/gob/1
		face/gob/1/data = face
	][
		face/gob/1/draw: to-draw compose/deep face/draw-text copy []
	]
	
	style: select guie/styles face/style

	;add the box model DRAW commands - no need to use copy/deep(see note above the 'box-model definition)
	append draw-buf box-model

	; The DRAW block can come from the style or face
	usr-drw: any [select face 'draw select style 'draw]

	;if DRAW-MODE is set(multiple draw blocks) pick the specific DRAW block
	if word? d: get-facet face 'draw-mode [
		if block? d: select usr-drw to set-word! d [usr-drw: d]
	]
	
	;join the box-model and style defined graphics
	all [
		usr-drw
		append draw-buf usr-drw
	]
	
	; optionally override with the result of the ON-DRAW actor
	all [
		drw: do-actor face 'on-draw draw-buf
		draw-buf: drw
	]

	if select face 'debug [
		draw-buf: append copy [pen red line-width 1 box 0x0 (margin-box/bottom-right - 1)] draw-buf
	]

	; If the face is text-based, generate text draw block:
	if tb: get-facet face 'text-body [
		append draw-buf reduce [
			'text 0x0 to paren! [viewport-box/bottom-right - 1] make-text face tb
		]
	]

	if empty? draw-buf [exit]

	; bind the DRAW block
	all [
		style/facets			; BB: facets may be none in very special cases
		bind draw-buf style/facets
	]
	bind draw-buf face/facets

;	delect/all dialect-draw compose/deep draw-buf face/draw-result: copy []
	delect/all dialect-draw compose/deep draw-buf drw: copy []
;	to-draw drw face/draw-result: copy []
	to-draw drw face/gob/draw: any [all [face/gob/draw clear face/gob/draw] copy []]

;	debug-face face 'redraw [face/draw-result]

	unless no-show [
		show-later face ; queued
		if now [
			show-now
		]
	]
]

