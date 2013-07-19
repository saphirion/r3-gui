REBOL [
	Title: "REBOL 3 GUI - Style material definitions"
	Version: "$Id$"
]

; Henrik - EXPERIMENTAL way to bring in different materials and to make gradient descriptions shorter
; and abstracted away from the style itself

; This will change into MATERIALIZE later (structure like FONTIZE),
; but I used it here for simpler testing of MAKE-MATERIAL, which works now.

; When the MATERIALIZE function is made, there needs to be appropriate changes in:
; MAKE-MATERIAL
; MAKE-COLOR

; MATERIALIZE should reside in g-materials.r

materials: make object! [
	base: make object! [
		up: down: over: make object! [
			specular: 'high
			intensity: 1
			diffusion: [1 1]
			opacity: 1
			texture: none
		]
	]
	shadow: make base [
		up: over: make up [
			diffusion: 0.0.0.55
		]
		down: make up [
			diffusion: 255.255.255.155
		]
	]
	chrome: make base [
		up: make up [
			diffusion: [1.00 0% 0.9 5% 0.85 10% 0.78 70% 0.76 75% 0.7 80% 0.76 97% 1.00 100%]
		]
		down: make up [
			intensity: 0.9
		]
		over: make up [
			intensity: 1.05
		]
	]
	chrome-groove: make base [
		up: over: down: make up [
			diffusion: [0.70 0% 0.4 5% 0.5 20% 0.7 49% 0.72 50% 0.7 75%]
;			diffusion: [0.70 0% 0.4 5% 0.65 20% 0.75 49% 0.6 50% 0.7 55% .5 80%]
		]
	]
	scroller: make base [
		up: make up [
			diffusion: [0.70 0% 0.4 5% 0.65 20% 0.75 49% 0.72 50% 0.7 55% .5 80%]
		]
		over: make up []
		down: make up [
			diffusion: [0.6 0% .8 65% 0.7 100%]
		]
	]
	piano: make chrome [
		up: make up [
			diffusion: [0.82 0% 0.72 49% 0.70 50% 0.60 51% 0.76 97% 1.00 100%]
		]
		down: make up [
			intensity: 0.9
		]
		over: make up [
			intensity: 1.05
		]
	]
	aluminum: make base [
		up: make up [
			diffusion: [1.00 0% 0.74 7% 0.70 70% 0.71 97% 1.00 100%]
		]
		down: make up [
			diffusion: [0.67 0% 0.78 7% 0.71 70% 0.72 97% 1.00 100%]
		]
		over: make up [
			intensity: 1.03
		]
	]
	; for use in container in various box styles
	container-groove: make base [
		up: down: over: make up [
			diffusion: [0.0.0.55 0% 0.0.0.0 50% 255.255.255.0 50% 255.255.255.35 100%]
		]
	]
	; top groove in a field
	field-groove: make base [
		up: down: over: make up [
			specular: 'linear
			diffusion: [0 0% 0.5 10% .99 40% 1 100%]
		]
	]
	; for use directly against background, without container
	dark-groove: make base [
		up: down: over: make up [
			diffusion: [0.0.0.159 0% 0.0.0.127 50% 0.0.0.115 60% 0.0.0.95 90%]
	]
	]
	; for use in rounded items, like slider knob
	radial-aluminum: make aluminum [
		up: make up [
			intensity: 1.1
			diffusion: [0.80 0% 0.78 10% 0.72 70% 0.70 95% 0.80 100%]
		]
		down: make up [
			intensity: 1
			diffusion: [0.65 0% 0.70 70% 0.75 95% 0.85 100%]
		]
		over: make up [
			intensity: 1.03
		]
	]
	led: make base [
		on: make up [
			diffusion: [1.00 0% 0.68 5% 0.68 49% 0.75 50% 0.90 95% 1.00 100%]
		]
		off: make on [
			diffusion: [1.00 0% 0.00 5% 0.00 49% 0.08 50% 0.25 95% 1.00 100%]
		]
	]
	plastic: make base [
		up: down: make up [
			specular: 'linear
			diffusion: [0.85 0.60]
		]
		over: make up [
			intensity: 1.2
		]
	]
	paper: make base [
		up: make up [
			specular: 'mul
			diffusion: [0.75 0.75]
		]
		down: make up [
			intensity: 0.9
		]
		over: make up [
			intensity: 1.1
		]
	]
	groove: make base [
		up: down: over: make up [
			specular: 'mul
			diffusion: [0.1 0% 0.5 5% 0.65 50% 0.9 100%] 
		]
	]
	fluorescent: make base [
		up: down: over: make up [
			specular: 'linear
			diffusion: [0.8 0% 1 100%]
			opacity: 0.7
		]
	]
	candy-stripe: make base [
		up: down: over: make up [
			diffusion: [255.255.255.0 255.255.255.0 255.255.255.15 255.255.255.15]
		]
	]
]

; The following is a SUGGESTION, not final code. There's no way to use it yet.

; To use a material, it has to be mixed with a color,
; which can be either the built-in color or a color suggested by MAKE-GRADIENT.

; There would be a MAKE-MATERIAL function, which grabs the information from here.
; The output of MAKE-MATERIAL would be a gradient directly usable in DRAW

; in your style you would set a fill like this:

; area-fill: make-material bg-color chrome

; There could also be a MAKE-COLOR function, which outputs a tuple directly
; usable in DRAW, but adjusted according to a specific material.
; This would not be used nearly as much, though.

; in your style you would set a color like this:

; highlight-color: make-color bg-color 0.5 chrome

; specular produces a color lightness range from a mathematical function,
; used to create correct specular highlights
; for a given material. This is illustrated here:
; http://rebol.hmkdesign.dk/files/r3/gui/026.png

; when switching highlight for the same gradient, you can make the appearance
; of a different material, because the highlight is made bigger or smaller,
; more or less intense.

; All that MATERIALIZE gives you, are colors and gradients for direct use in DRAW.
; If an image texture is to be used, then we need some more tools to deal
; with that, perhaps MAKE-TEXTURE.

'materialize [

	base: [
		color: white ; can be overridden in the style with MAKE-MATERIAL
		specular: 'high ; one of 'linear, 'high, 'avg or 'mul
		diffusion: [] ; gradient as specified by MAKE-GRADIENT
		opacity: 1 ; alpha between 0 (max alpha) and 1 (no alpha)
		texture: none ; can be image!
	]

	chrome: base [
		diffusion: [1.00 0% 0.78 49% 0.76 50% 0.7 51% 0.76 97% 1.00 100%]
	]

	; shows the incorporation of different modes in the same material
	; always use mode words
	
	aluminum: base [
		diffusion: [
			up: [1.00 0% 0.74 7% 0.70 70% 0.71 97% 1.00 100%]
			down: []
			over: []
		]
	]

	plastic: base [
		specular: 'linear
		diffusion: [0.76 0.73]
	]
	
	fluorescent: base [
		specular: 'linear
		diffusion: [0.6 0.9 0.6]
		opacity: 0.7
	]

	paper: base [
		specular: 'avg
		diffusion: [0.75 0.75]
	]

	carpet: [
		specular: 'linear
		diffusion: [1.0 1.0]
		texture: random-noise-image
	]
	
]