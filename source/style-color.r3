REBOL [
	Title: "REBOL 3 GUI - Color Management Styles"
	Version: "$Id$"
]

get-rgb: does [
	to-tuple reduce [get-face r get-face g get-face b]
]

; Sets the RGB value from the XY position in the RGB spectrum

get-rgb-pos: funct [xy size] [
	sz: size - 1
	h: xy/x / sz/x
	v: 1 - (xy/y / sz/y)
	case [
		v < 50% [s: 1 v: v * 2]
		v >= 50% [s: 1 - v * 2 v: 1]
	]
	hsv-to-rgb reduce [h s v]
]

set-pos-from-rgb: func [color size /local h s v x y] [
	size: size - 1
	set [h s v] probe rgb-to-hsv color
	x: h * size/x
	y: 0
	; so it's the saturation part that is not correct here
	; the position must be set absolutely correct using this function alone. no calculations outside
	; because on-resize and on-set produce slightly different output here.
	; Be very careful.
	case [
		zero? v [y: size/y]
		zero? s [y: 0]
		; the values inbetween here is bat country
		; ; when we have a color, we can't care about its saturation if its value is the highest value
		; that's not very easy to deal with
		; so perhaps we should postpone this so we can get some action into this system
		v < 1 [y: 1]
		s < 1 [y: 1]
	]
	probe as-pair x y
]

; Sets the HSV values of a colorwheel from input offset

set-wheel: funct [face offset] [
	pos: offset - face/facets/center
	size: (min-axis face/facets/center) - face/facets/bias-xy
	dist: square-root add power pos/x 2 power pos/y 2
	dist: min 1 dist / size
	angle: 0
	unless pos/x = 0 [
		angle: arctangent negate pos/y / pos/x
	]
	angle: case [
		pos = 0x0 [0]
		all [pos/x > 0 pos/y = 0] [0]
		all [pos/x = 0 pos/y < 0] [90]
		all [pos/x < 0 pos/y = 0] [180]
		all [pos/x = 0 pos/y > 0] [270]
		all [pos/x > 0 pos/y < 0] [angle]
		pos/x < 0 [angle + 180]
		all [pos/x > 0 pos/y > 0] [360 + angle]
	]
	set-face face reduce [angle / 360 dist face/facets/value]
]

stylize [

rgb-spectrum: [

	about: "Displays the RGB color spectrum in a rectangle."

	facets: [
		init-size: 200x100
		min-size: 100x100
		max-size: 2000x2000
		lightness: 0
		corner: 0x0
		relay: true
		
		; WAR - make image! bug causes color distortions,
		; so I'm using a clumsy CHANGE routine here.
		; !!! - Image should not need the upper row, as lightness adjustment would handle that?
		; Need to find a more correct way to have this
		img: make image! 7x3
			change/dup img 255.255.255 7
			change at img 8 255.0.0
			change at img 9 255.255.0
			change at img 10 0.255.0
			change at img 11 0.255.255
			change at img 12 0.0.255
			change at img 13 255.0.255
			change at img 14 255.0.0
		region: none
		knob-xy: 1x1
		spectrum-xy: 0x0
		spectrum-size: 0x0
		bias-xy: 6
		h-ticks: none
		v-ticks: none
	]
	
	options: [
		init-size: [pair!]
	]

	draw: [
		anti-alias off
		translate (bias-xy * 1x1 + 0x1) ; moves the clipping as well

		; shadow
		pen false
		grad-pen (gob-size * 0x1 + 1x-4) 0 1 90 [0.0.0.96 0.0.0.55]
		box (gob-size * 0x1 + 1x-4) (gob-size - 4x2)
		fill-pen 0.0.0.159

		; ticks
		pen 0.0.0.159
		translate -1x1
		shape v-ticks
		translate 2x-6
		shape h-ticks
		pen false
		translate -1x5

		; RGB spectrum
		box 0x0 (gob-size - 3)
		fill-pen false
		clip 1x1 (gob-size - 4)
		image img (corner * -1) (gob-size + corner - 3)
		reset-matrix ; Must be reset, otherwise the clip will be transformed as well
		clip false

		; X knob
		translate (knob-xy + 2 * 1x0 + 0x1)
		fill-pen black
		triangle 0x0 5x5 9x0
		fill-pen 0.0.0.95
		triangle 0x1 5x6 9x1

		; Y knob
		reset-matrix
		translate (knob-xy + 2 * 0x1 + 1x0)
		fill-pen black
		triangle 0x0 5x5 0x9
		fill-pen 0.0.0.95
		triangle 0x1 5x6 0x10

		anti-alias on
		fill-pen false

		; XY knob
		reset-matrix
		translate (bias-xy * 1x1 + 0x1)
		pen 0.0.0.95
		line-width 4.5
		circle (knob-xy) 4
		pen 0.0.0.127
		line-width 3
		circle (knob-xy) 4
		pen white
		line-width 1
		circle (knob-xy) 4
	]

	actors: [
		on-make: [
			face/state/value: 0.0.0
		]

		on-resize: [
			do-actor/style face 'on-resize arg 'face
;			face/gob/size: 
			size: arg
			facets: face/facets
			facets/gob-size: 2 + area-size: size - (2 * facets/bias-xy)
			facets/spectrum-size: spc: area-size - 3
			; do we need corner?
			set-facet face 'corner as-pair area-size/x / 14 area-size/y - 1 / 4
			; need to adjust spectrum size for knob-xy
			facets/knob-xy: set-pos-from-rgb face/state/value spc
			; draw-face face
			facets/v-ticks: make-ticks [3 1] as-pair 4 spc/y - 1 'left
			facets/h-ticks: make-ticks [7 1] as-pair spc/x - 1 4 'up
		]

		on-set: [
			if val: select arg 'value [
				facets: face/facets
				case [
					tuple? val [
						; !!! - get better name than SET-RGB-POS, because we are setting the XY position of the knob from an RGB value
						facets/knob-xy: set-pos-from-rgb val facets/spectrum-size
					]
					any [
						percent? val
						decimal? val
					] [
						; adjust brightness in image
						set-facet face 'lightness val
						foreach [pixel channel] [
							; map of pixels and channels to change
							8 2 8 3
							9 3
							10 1 10 3
							11 1
							12 1 12 2
							13 2
							14 2 14 3
						] [
							; WAR - work around for image channel set bug,
							; otherwise this would be one line of code
							p: facets/img/:pixel
							p/:channel: round val * 255
							facets/img/:pixel: p
						]
						change/dup at facets/img 15 to-tuple array/initial 3 round val * 255 7
						draw-face face
					]
				]
			]
		]

		on-click: [
			facets: face/facets
			facets/region: none
			; Henrik - Isn't this complicated to figure out?
			if arg/type = 'down [drag: init-drag face arg/offset]
			do-actor face 'on-offset arg/offset
			spc: facets/spectrum-size
			offset: arg/offset - facets/bias-xy

			; need more regions, one at the bottom.

			if arg/type = 'down [
				; set the X knob
				if inside? arg/offset 4x0 as-pair spc/x 4 [
					facets/region: 'x
					facets/knob-xy/x: offset/x
				]
				; set the Y knob
				if inside? arg/offset 0x4 as-pair 4 spc/y [
					facets/region: 'y
					facets/knob-xy/y: offset/y
				]
				; set the XY knob
				if inside? arg/offset facets/bias-xy * 1x1 spc [
					facets/knob-xy: offset
				]

				facets/knob-xy: min facets/gob-size - 5 max 1x1 facets/knob-xy
				spc-xy: facets/knob-xy - 1
				draw-face face
				do-face face
				face/state/value: get-rgb-pos spc-xy spc
				return drag
			]
			none
		]
		
		on-drag: [ ; arg
			facets: face/facets
			spc: facets/spectrum-size
			offset: arg/delta + arg/base
			xy: offset - facets/bias-xy
			switch/default facets/region [
				x [facets/knob-xy/x: xy/x]
				y [facets/knob-xy/y: xy/y]
			][
				facets/knob-xy: xy
			]
			facets/knob-xy: min spc max 1x1 facets/knob-xy
			spc-xy: facets/knob-xy - 1
			draw-face face
			face/state/value: get-rgb-pos spc-xy spc
			do-face face
		]
	]

]

color-wheel: [

	about: "HSV or HSL color wheel"
	
	facets: [
		init-size: 200x200
		min-size: 100x100
		max-size: 1000x1000
	;	relay: true
	
		lightness: reduce [255.255.255 255.255.255.0]
		bias-xy: 10
		knob-xy: 0x0
		hue: 0
		saturation: 0
		value: 0
		center: 0x0
		radius: 0
	]
	
	options: [
		init-size: [pair!]
	]

	draw: [
		; rim
		translate center
		fill-pen 0.0.0.55
		pen 0.0.0.75
		circle 0x0 (min-axis center)

		; wheel
		grad-pen conic 0x0 0 360 [
		; needs to be adjustable in lightness, so we need to generate this
		; using on-set, I suppose
		; so value would be the Hue and Saturation
		; then the lightness would be a separate value
		; perhaps just a tri-block with all three values input to it
		; we can do that with the existing RGB->HSL/HSV functions
			0.255.255 0.255.0 255.255.0 255.0.0 255.0.255 0.0.255 0.255.255
;			0.255.255 0.0.255 255.0.255 255.0.0 255.255.0 0.255.0 0.255.255
;			255.0.0 255.255.0 0.255.0 0.255.255 0.0.255 255.0.255 255.0.0
		]
		circle 0x0 radius
		pen false

		; lightness/value
		grad-pen radial 0x0 0 radius lightness
		circle 0x0 radius

		; line
		; from center to edge at correct angle
		pen 0.0.0.95
		; rotation is phase of color
		rotate (negate 360 * hue)
		line 0x0 (1x0 * radius)
		; edge-knob
		translate (1x0 * radius)
		pen false
		fill-pen black ; !!! - allow this to change during on-click
		triangle 0x0 5x4 5x-4

		; wheel-knob
		fill-pen false
		reset-matrix
		translate center
		pen 0.0.0.95
		line-width 4.5
		circle (knob-xy) 4
		pen 0.0.0.127
		line-width 3
		circle (knob-xy) 4
		pen white
		line-width 1
		circle (knob-xy) 4
	]

	actors: [
		on-make: [
			face/state/value: hsv-to-rgb reduce [
				face/facets/hue: 0
				face/facets/saturation: 0
				face/facets/value: 1
			]
		]
		
		on-reset: [
			do-face face 'on-make
			set-face face reduce [facets/hue facets/saturation facets/value]
		]

		on-resize: [
			do-actor/style face 'on-resize arg 'face
;			face/gob/size:
			size: arg
			facets: face/facets
			facets/gob-size: 2 + area-size: size - 2
			facets/center: area-size / 2
			facets/radius: min-axis facets/center - facets/bias-xy
			set-face face reduce [facets/hue facets/saturation facets/value]
		]

		on-click: [
			if arg/type = 'down [
				drag: init-drag face arg/offset
				set-wheel face arg/offset
				draw-face face
				return drag
			]
			none
		]

		on-drag: [
			set-wheel face arg/base + arg/delta
			draw-face face
			do-face face
		]

		on-set: [
			; Hue (angle)
			; Saturation (distance from center)
			; Value (global lightness of the circle) !!! - needs to be done
			facets: face/facets
			if val: select arg 'value [
			probe val
			; !!! - RGB spectrum hue works the wrong way around
			; !!! - RGB spectrum hue is way too fast for color wheel
				case [
					block? val [
						; set HSV
						facets/hue: min 100% max 0% to-percent val/1
						facets/saturation: min 100% max 0% to-percent val/2
						facets/value: min 100% max 0% to-percent val/3
					]
					tuple? val [
						; set HSV from RGB
						val: rgb-to-hsv val
						facets/hue: val/1
						facets/saturation: val/2
						facets/value: val/3
					]
					percent? val [
						; set V
						facets/value: min 100% max 0% val
					]
					decimal? val [
						; set V
						facets/value: min 100% max 0% to-percent val
					]
				]
				dist: facets/saturation * facets/radius
				hue: facets/hue * 360
				facets/knob-xy: 1x-1 * as-pair dist * cosine hue dist * sine hue
				face/state/value: hsv-to-rgb reduce [facets/hue facets/saturation facets/value]
				draw-face face
			]
		]
	]

]

]