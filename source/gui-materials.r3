REBOL [
	Title: "REBOL 3 GUI - Skin material functions"
	Version: "$Id$"
]

specular-functions: reduce [
	'mul func [c v] [
		c * v
	]
	'linear func [c v] [
		c * v ; Henrik - Really?
	]
	'high func [c v] [
		; must handle alpha separately
		c * v + min 255 to-integer max 0 800 * v - 545
	]
	'avg func [c v] [
		to-tuple reduce [
			min 255 255 * v + c/1 * v / 2
			min 255 255 * v + c/2 * v / 2
			min 255 255 * v + c/3 * v / 2
			; must handle alpha
		]
	]
]

; Henrik - Material Functions

set-opacity: func [
	"Sets opacity for a single color between 0 and 100%"
	color [tuple!]
	v [integer! decimal! percent!]
] [
	color/4: v * 255
	color
]

make-gradient: funct [
	"Build a gradient color span based on a material object."
	color [tuple!]
	mat-obj [object!] "Material object"
][
	fn: any [
		select specular-functions mat-obj/specular
		select specular-functions 'mul
	]
;	out: make-block mat-obj/diffusion 1
	out: make block! length? mat-obj/diffusion
	foreach v mat-obj/diffusion [
		append out case [
			percent? :v [
				to-decimal v
			]
			tuple? :v [
				; do we want to set opacity here?
				; no, we need to do something else
				v
			]
			number? :v [
				set-opacity fn color v * mat-obj/intensity mat-obj/opacity
			]
		]
	]
]

make-material: funct [
	"Adds a materials facet to face from material's name."
	face [object!]		"Face object"
	material [word! none!]	"Material's name"
	/color clr [tuple!]	"Optional color to use"
	/facet fct [word!]	"Optional facet to use to get color (standard is 'bg-color)"
][
	unless material [exit]
 	unless facet [fct: 'bg-color]
 	unless color [clr: any [get-facet face fct gray]]
	mat-obj: make object! []
	mat: materials/:material
	foreach mode words-of mat [
		mm: mat/:mode
		repend mat-obj [
			mode
			either tuple? mm/diffusion [
				mm/diffusion
			][
				make-gradient clr mm
			]
		]
	]
	set-facet face 'materials mat-obj
]

set-material: funct [
	"Chooses the gradient from a material object to use with a face mode"
	face [object!]
	mode [word! none!]
][
	all [
		mat: get-facet face 'materials
		set-facet face 'area-fill any [
			all [mode select mat mode]
			select mat 'up ; default mode is 'up, for none inputs
			select mat first words-of mat ; if 'up does not exist, use first word
		]
	]
]

; This is useful for cases where a gradient or color is only set once,
; for example during ON-MAKE
; USE-MATERIAL uses the initial mode for simplicity.

use-material: func [
	"Gets a gradient or color directly from a material"
	color [tuple!]
	'material [word!]
][
	set-material make-material color (material) none
]

; This creates a material object with single colors for each mode.

make-color: funct [
	"Creates a material object from a material asset and an input color and intensity"
	color [tuple!]
	intensity [number!]
	'material [word!]
][
	mat: materials/:material
	mat-obj: make object! []
	foreach mode words-of mat [
		repend mat-obj [
			mode
			do select specular-functions
				get in get in mat first words-of mat 'specular
				color
				intensity
		]
	]
	mat-obj
]

set-color: func [
	"Chooses the color from a material object to use with a face mode"
	mat [object!]
	mode [word! none!]
][
	; Henrik - functionality appears to be the same as SET-MATERIAL,
	; Perhaps this function is not really necessary?
	; The name would be necessary for clarity though.
	set-material mat mode
]

; USE-COLOR is locked into the initial mode for simplicity

use-color: func [
	"Gets a color directly from a material"
	color [tuple!]
	intensity [number!]
	'material [word!]
][
	set-color make-color color intensity (material) none
]
