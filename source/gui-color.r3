REBOL [
	Title: "R3 GUI - Color Conversion Functions"
	Version: "$Id$"
]

context [ ; Henrik - Color Conversion Functions

; Henrik - Review all names. Some are not so good.
; The idea is to provide functions for converting
; between RGB, HSV/HSB and HSI/HSL color space.

c: c-diff: c-sum: c-min: c-max: c-max-word: none

set-color: func [
	; INTERNAL - Converts color tuple to a block
	color [tuple!]
] [
	c: reduce [color/1 color/2 color/3]
]

set-min-max: func [
	; INTERNAL - Sets c, c-min, c-max and c-max-word
	color [tuple!]
][
	set-color color
	c-max: first c-max-index: maximum-of c
	c-min: first minimum-of c
	c-diff: c-max - c-min
	c-sum: c-max + c-min
	c-max-word: pick [r g b] index? c-max-index
]

set 'to-hsl-saturation func [ ; works
	"Calculates HSL-saturation from an RGB tuple."
	color [tuple!]
	/local l
][
	set-min-max color
	if c-max = c-min [return 0%]
	c-max: c-max / 255
	c-min: c-min / 255
	c-diff: c-diff / 255
	l: cm / 2 ; lightness
	to-percent case [
		l <= 50% [c-diff / c-sum]
		l > 50% [c-diff / (2 - c-sum)]
	]
]

set 'to-hsv-saturation func [ ; works
	"Calculates HSV-saturation from an RGB tuple."
	color [tuple!]
][
	set-min-max color
	if zero? c-max [return 0%]
	to-percent 1 - (c-min / c-max)
]

set 'to-hsl-lightness funct [ ; works
	"Calculates the HSL lightness from an RGB tuple"
	color [tuple!]
][
	set-min-max color
	to-percent c-sum / 2 / 255
]

set 'to-hsv-value func [ ; works
	"Calculates the HSV value from an RGB tuple."
	color [tuple!]
][
	set-min-max color
	to-percent c-max / 255 ; 254 instead? 127 does not equal 50% with 255.
]

set 'to-hue funct [ ; works
	"Calculates the HSV/HSL hue as a value (0 - 100%) from an RGB tuple."
	color [tuple!]
][
	set-min-max color
	if c-max = c-min [return 0%]
	val: do select [
		r [mod (60 * ((c/2 - c/3) / c-diff)) 360]
		g [(60 * ((c/3 - c/1) / c-diff) + 120)]
		b [(60 * ((c/1 - c/2) / c-diff) + 240)]
	] c-max-word
	to-percent val / 360
]

; seems to produce rounding errors here

set 'hsv-to-rgb func [ ; works
	"Converts an HSV value to an RGB value as tuple."
	hsv [block!] "Hue (0 - 100%), Saturation (0 - 100%) and Value (0 - 100%)."
	/local h h60 s v hi f p q t
][
	set [h s v] hsv
	h: h * 360
	h60: h / 60
	s: max 0% min 100% s
	hi: (round/floor h60) // 6 + 1
	f: h60 - round/floor h60
	v: round 255 * v
	p: round (1 - s) * v
	q: round (1 - (f * s)) * v
	t: round (1 - ((1 - f) * s) * v)
	to-tuple reduce pick [
		[v t p]
		[q v p]
		[p v t]
		[p q v]
		[t p v]
		[v p q]
	] hi
]

set 'rgb-to-hsv func [ ; untested
	"Converts an RGB tuple to HSV."
	rgb [tuple!]
][
	reduce [
		to-hue rgb
		to-hsv-saturation rgb
		to-hsv-value rgb
	]
]

set 'hsl-to-rgb func [ ; works
	"Converts an HSL value to an RGB value as tuple."
	hsl [block!] "Hue (0 - 100%), Saturation (0 - 100%) and Lightness (0 - 100%)."
	/local h s l hk f p q t t' tr tg tb
][
	set [hk s l] hsl
	h: hk * 360
	if l < 50% [q: l * (1 + s)]
	if l >= 50% [q: l + s - (l * s)]
	p: 2 * l - q
	tr: 1 / 3 + hk
	tg: hk
	tb: hk - (1 / 3)
	foreach t [tr tg tb] [
		t': get t
		if t' < 0 [set t t' + 1]
		if t' > 1 [set t t' - 1]
		t': get t
		set t round 255 * case [
			1 / 6 > t'
				[p + ((q - p) * 6 * t')]
			all [t' >= (1 / 6) t' < 0.5]
				q
			all [t' >= 0.5 t' < (2 / 3)]
				[p + ((q - p) * 6 * ((2 / 3) - t'))]
			true
				p
		]
	]
	to-tuple reduce [tr tg tb]
]

set 'rgb-to-hsl func [ ; untested
	"Converts an RGB tuple to HSL."
	rgb [tuple!]
][
	reduce [
		to-hue rgb
		to-hsl-saturation rgb
		to-hsl-lightness rgb
	]
]

set 'make-hues funct [ ; works
	"Creates N hues around the color wheel from a base color."
	rgb [tuple!]
	n [integer!]
][
	hues: make block! n
	append hues rgb
	h: first hsv: rgb-to-hsv rgb
	repeat i n - 1 [
		color: hsv-to-rgb head change hsv to-percent 100 / n + h * i / 100
		append hues color
	]
]

]