REBOL [
	Title: "REBOL 3 GUI Styles - Images and drawings"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

; NOTE: Image loaders are missing from current release, so not tested!!

stylize [

sensor: [

	about: "Has no graphics, but can be clicked."

	tags: [internal]

	facets: [
		init-size: 100x100
	]

	options: [
		init-size: [pair!]
	]

	actors: [
		on-click: [ ; arg: event
			if arg/type = 'up [do-face face 'hit]
			true ;don't do unfocus
		]
	]
]

drawing: sensor [

	about: "Simple scalar vector draw block. Can be clicked."

	tags: [tab]

	facets: [
;		init-size: 100x100
;		min-size: 100x100
		drawing: []
	]

	options: [
		drawing: [block!]
		init-size: [pair!]
	]

	actors: [
		on-make: [ ; on-init instead?
			if all [in face/facets 'drawing block? drw: face/facets/drawing] [
				set-face/no-show face copy drw
			]
		]

		on-set: [
			switch arg/1 [
				value [
					face/facets/drawing: arg/2
					; get and set drawing size from dialect
;					do-actor face 'on-set-drawing-size reduce [arg/2 arg/3]
					show-later face
				]
			]
		]

		on-draw: [append arg face/facets/drawing]

		on-set-drawing-size: [
			; WARNING: EXPERIMENTAL
			; NOTE: this is detection of drawing size
			;		so when content changes/ drawing is resized
			;		this will probably bring some problems and should be solved differently
			;		SO WACH OUT FOR THIS!
			unless empty? arg/1 [
				max-size: 0x0
				parse arg/1 [
					some [
						set p pair! (
							if p/x > max-size/x [max-size/x: p/x]
							if p/y > max-size/y [max-size/y: p/y]
						)
					|	1 skip
					]
				]
				face/facets/min-size: max-size
				face/facets/max-size: max-size
				apply :resize-face [face max-size arg/2]
			]
		]
	]
]

image: sensor [

	about: "Simple image with optional border. Can be clicked."

	tags: [tab]

	; need image loader and database
	facets: [
		init-size: 200x100
		img: make image! 50x50
		bg-color: none
		force: false			; force displaying image even if not found (as in HTML)
	]

	options: [
		src: [image! file! url!]
		init-size: [pair!]
	]

	draw: [
		image-filter bilinear resample 0.5
		image img 0x0 viewport-box/bottom-right
	]

	actors: [
		on-init: [
			if src: get-facet face 'src [
		 		set-face face src
			]
		]
		on-set: [ ; arg: [tag value]
			if arg/1 = 'value [
				unless image? img: arg/2 [
					either get-facet face 'force [
						img: attempt [load img]
						unless img [
							draw img: make image! 100x100
							to-draw compose/deep [ ; move definition elsewhere?
								text 20x24 [
									font (make object! [size: 22 color: white])
									anti-alias on
									"no^/image"
								]
								pen red
								line-width 3
								line 10x10 30x30
								line 10x30 30x10
							] copy []
						]
					][
						img: load img
					]

				]
				if image? img [
					apply :resize-face [face img/size arg/3]
					set-facet face 'img img
				]
			]
		]
	]
]

icon: image [

	about: "Icon image with optional text below."

	tags: [tab]

]

indicator: [
	about: "Visual indication of whether a face is valid."
	tags: [info]
	facets: [
		bg-color: none
		init-size: 20x20
		min-size: 20x20
		max-size: 20x20
		text-body: ""
		text-style: 'base
		draw-mode: 'skipped
		default-reactor: ['indicate arg]
	]
	actors: [
;
;	TODO: currently INDICATOR attaches to faces that have ON-VALIDATE actor
;			however this actor does nothing in e.g. CHECK
;			so it should probably work differently
;			needs more testing befor final decission
;
;
		on-init: [
			if target: find-face-actor/reverse face 'on-validate [
;				append-face-act face reduce ['validate target]
				do-actor target 'on-attach face
			]
		]

		on-set: [
			set-facet face 'draw-mode arg/2
			show-later face
		]
	]
	draw: [
		invalid: [
			;-- red X
			pen red
			line-width 3
			line 4x4 18x18
			line 4x18 18x4
		]
		valid: [
			;-- green checkbox
			pen 0.128.0
			line-width 3
			arc 1x20 10x10 -60 60
			arc 27x20 15x20 -180 60
		]
		required: [
			;-- black solid circle
			pen black
			fill-pen black
			line-width 1
			circle 5 11x11
		]
		not-required: [
			;-- black hollow circle
			pen black
			line-width 1
			circle 5 11x11
		]
		skipped: [
			;-- gray hollow circle
			pen 128.128.128
			line-width 1
			circle 5 11x11
		]
	]
]

dir-text: drawing [

	facets: [
		init-angle: 0
		init-color: black
		drawing: copy []

	;	border-size: [1x1 1x1]
	;	border-color: black
	]

	options: [
		init-text: [string!]
		init-angle: [decimal!]
		init-color: [tuple!]
	]

	actors: [

		on-make: [
			set-face/no-show face face/facets/init-text
		]

		on-set: [
			switch arg/1 [
				value [
					rfont: guie/fonts/dir-text/font
					rpara: guie/fonts/dir-text/para
					angle: face/facets/init-angle
					if angle < 0 [angle: angle + 360]

					g: make gob! 1000x1000
					g/text: to-text [font rfont arg/2] copy [] ; CHECK: clear?
					size: size-text g

					case [
						(angle >= 0) and (angle <= 90) [
							size: as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
							face/facets/drawing: compose/deep [
								transform (angle) 0x0 (as-pair 2 + rfont/size * sine angle 0)
								pen (face/facets/init-color)
								line-width 1
								text [font (rfont) para (rpara) (arg/2)] vectorial
							]
						]
						(angle > 90) and (angle <= 180) [
							an: 180 - angle
							size: as-pair (size/x * cosine an) + (size/y * sine an) (size/y * cosine an) + (size/x * sine an)
							face/facets/drawing: compose/deep [
								transform (angle) 0x0 (as-pair size/x  size/y * (1 - sine angle))
								pen (face/facets/init-color)
								line-width 1
								text [font (rfont) para (rpara) (arg/2)] vectorial
							]
						]
						(angle > 180) and (angle <= 270) [
							size: abs as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
							face/facets/drawing: compose/deep [
								transform (angle) 0x0 (as-pair size/x * (cosine 180 - angle) size/y) ; works for 265
								pen (face/facets/init-color)
								line-width 1
								text [font (rfont) para (rpara) (arg/2)] vectorial
							]
						]
						(angle > 270) and (angle < 360) [
							face/facets/drawing: compose/deep [
								transform (angle) 0x0 (as-pair -5 -2 + size/x * sine angle - 180)
								pen (face/facets/init-color)
								line-width 1
								text [font (rfont) para (rpara) (arg/2)] vectorial
							]
							; TODO: fix this sizing, has some problems
							size: abs as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
						]
					]
					apply :resize-face [face size arg/3]
					show-later face
				]
			]
		]
	]
]

]