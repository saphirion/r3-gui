REBOL [
	Title: "REBOL 3 GUI Styles - Bars of various kinds"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
	Date: 3-Feb-2011/17:01:51+1:00
]

stylize [

box: [

	about: "Simple rectangular box."

	facets: [
		init-size: 100x100
		min-size: 10x10
		bg-color: black
	]

	options: [
		init-size: [pair!]
		bg-color: [tuple!]
	]
]

bar: box [

	about: "Simple horizontal divider bar."

	facets: [
		init-size: 100x3
		min-size: 20x3
		max-size: 1000x3
	]
]

div: bar [

	about: "Simple vertical divider bar."

	facets: [
		init-size: 3x10
		min-size: 3x20
		max-size: 3x1000
	]
]

progress: [

	about: "Progress bar."

	tags: [indicator]

	facets: [
		init-size: 200x22
		max-size: 1000x22
		border-color: 96.96.96
		bg-color: 80.80.80.127

		material: 'radial-aluminum
		bar-size: 1x1 ; modified by the progress % value
	]

	options: [
		bg-color: [tuple!]
		init-size: [pair!]
		value: [percent!]
	]

	draw: [
		pen border-color
		line-width 1
		grad-pen 1x1 0 viewport-box/bottom-right/y 90 materials/down
		box 1x1 (viewport-box/bottom-right - 2) 3
		pen off
		grad-pen linear 1x1 0 viewport-box/bottom-right/y 90 area-fill
		box 2x2 bar-size 3
	]

	actors: [
		on-make: [
			make-material face get-facet face 'material
			set-material face 'up
			if value: get-facet face 'value [set-face face value]
		]

		on-set: [ ; arg: event
			; Update the bar size from the face value.
			if number? arg/2 [
				face/state/value: v: limit to percent! arg/2 0% 100%
				face/facets/bar-size: as-pair max 2 face/gob/size/x - 2 * v face/gob/size/y - 2
				apply :draw-face [face arg/3 true]
			]
		]
		
		on-resize: [
			do-actor/style face 'on-resize arg 'face
			set-face/no-show face face/state/value
		]
	]
]

slider: [

	about: "Slide-bar for numeric input (0% - 100%)"

	tags: [state action tab]

	facets: [
		init-size: 200x22
		min-size: 200x22
		max-size: 1000x22
		border-color: 96.96.96
		bg-color: 80.80.80
		knob-color: gray
		
		relay: true ; should be a tag or go away

		axis: none
		knob-xy: 
		bias-xy: 6x0 ; pointer adjustment at ends
		slider-size: 0x0
		material: 'radial-aluminum		
	]

	options: [
		init-size: [pair!]
		bg-color: [tuple!]
		knob-color: [tuple!]
		value: [percent!]
	]
	
	state: [
		value: [percent!]
		validity: [word!]
	]

	draw: [
		pen border-color
		line-width .4
		grad-pen 1x1 0 10 90 area-fill
		box 1x1 slider-size 3
		line-width 1.3
		fill-pen knob-color
		translate knob-xy
		triangle -6x16 0x2 6x16
	]

	actors: [
		on-init: [
			set-facet face 'knob-colors reduce [red face/facets/knob-color]
			make-material face get-facet face 'material
			set-material face 'up
			
			face/state/value: either in face/options 'value [max 0% min 100% face/options/value][0%]
			face/facets/axis: face-axis? face
		]

;		on-attach: [
;			extend-face face 'attached arg
;			if r: get-facet arg 'default-reactor [
;				append-face-act face reduce bind r 'arg
;			]
;		]

		on-resize: [ ; arg: size
			do-actor/style face 'on-resize arg 'face
			face/facets/slider-size: arg - 2 * 1x0 + 0x6
			face/facets/axis: face-axis? face
			do-actor face 'on-update none
		]

		on-update: [
			if face/facets/viewport-box/bottom-right [
				; Compute the knob offset from face/value:
				bias: face/facets/bias-xy
				size: face/facets/viewport-box/bottom-right - bias - bias
				val: face/state/value
				face/facets/knob-xy: val * size * 1x0 + bias
			]
		]

		on-offset: [ ; arg: offset
			; Compute face/value from knob offset:
			bias: face/facets/bias-xy
			arg:  max 0x0 arg - bias
			size: face/facets/viewport-box/bottom-right - bias - bias
			axis: pick [x y] 'y = get-facet face 'axis
			face/state/value: val: min 100% max 0% to-percent arg/:axis / size/:axis
			face/facets/knob-xy: val * size * 1x0 + bias
		]

		on-click: [ ; arg: event
			focus face
			if arg/type = 'down [drag: init-drag/only face arg/offset]
			do-actor face 'on-offset arg/offset
			if arg/type = 'down [
				draw-face face
				return drag
			]
;			do-attached face
			do-face face ; Click UP: compute percentage value from xy offset
			true ;don't do unfocus
		]

		on-drag: [ ; arg: drag
			do-actor face 'on-offset arg/delta + arg/base
			draw-face face
;			do-attached face
			do-face face
		]

		on-get: [ ; arg: field
			if arg = 'value [face/state/value]
		]

		on-set: [ ; arg: [field value]
			if all [
				'value = first arg
				number? second arg
			][
				face/state/value: limit second arg 0% 100%
			]
;			do-attached face
			do-targets face
			do-actor face 'on-update none ; will clip value range
		]
		
		on-clear: [
			set-face face 0
		]
		
		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			set-facet face 'knob-color pick face/facets/knob-colors arg/1
			draw-face face
		]
		
		on-key: [
			if arg/type = 'key [
				switch/default arg/key [
					left [set-face face -1% + get-face face]
					right [set-face face 1% + get-face face]
 				][
					unless e: error? try [
						n: -1 + to integer! to string! arg/key
					][
						if -1 = n [n: 9]
						set-face face to percent! n / 9
					]
				]
			]
		]

		on-validate: [
			face/state/validity: validate-face face
		]
	]
]

scroller: [

	about: "Scroll bar with end arrows."
	
	tags: [action part]

	facets: [
		init-size: 16x16
		min-size: 16x16
		max-size: 16x16

		init-length: none
		orientation: none

		btn-size: 16x16
		
		length-limit: 50 ;minimal scroller length in major axis
		
		all-over: true ; continuous over events
		relay: true
		
		material: 'scroller

		bg-color:  200.233.245
		border-color: 0.0.0.128
		arrow-color: black

		knob-xy:	; offset of knob (dragger)
		knob-size:	; size of knob
		knob-base:	; lowest xy of knob
		btn-xy:		0x0 ; offset of far button
		angles:		[0 180]	; angles for both button arrows (a block of 2)
		axis:		
			none
			
		set-fields: make map! [
			value [
				all [
					number? arg/2
					either percent? arg/2 [
						true
					][
						arg/2: to percent! arg/2 / pick face/gob/size face/facets/axis
					]
					face/state/value <> val: limit arg/2 0% 100%
					face/state/value: val
					dirty?: true
				]
;				do-face face
			]
			delta [
				if number? arg/2 [
					unless percent? arg/2 [arg/2: to percent! arg/2 / pick face/gob/size face/facets/axis]
					face/state/delta: limit arg/2 0% 100%
					dirty?: true
				]
;				do-face face
			]
		]
		
		get-fields: make map! [
			value	[face/state/value]
			delta	[face/state/delta]
		]
	]

	options: [
		init-length: [number!]
		orientation: [issue!]
		bg-color: [tuple!]
	]

	state: [
		value: 0%		; scroller offset
		delta: 10%		; "page size" increment / scroller knob size
	]

	draw: [
		; scroller background box
		pen border-color
		line-width 1
		grad-pen linear 1x1 0 16 (use 'a [a: angles/1 if a = 270 [a: 90] a]) materials/down ; todo: only arrows or bar gradient can work with angles/i without additional code. need to solve it
		box 1x1 (viewport-box/bottom-right - 1) 6
		
		; drag knob:
		grad-pen linear 1x1 0 16 (use 'a [a: angles/1 if a = 270 [a: 90] a]) materials/up
		box knob-xy (knob-xy + knob-size) 6
		pen false

		; first arrow head:
		transform angles/1 0x0 .6 .6 (btn-size / 2)
		pen arrow-color
		line-cap rounded
		fill-pen arrow-color
		polygon -6x5 0x-5 6x5

		; second arrow head:
		reset-matrix
		transform angles/2 .6 .6 0x0 (btn-xy - 1 + (btn-size / 2))
		polygon -6x5 0x-5 6x5
	]

	actors: [
		on-init: [
			; Find a prior face to attach the scroll bar to:
			if all [
				not get-facet face 'attached?	; check if face is already attached, so we don't add anoter target
				target: find-face-actor/reverse face 'on-scroll 
			][
;				do-actor target 'on-attach face
				attach-face face target
			]
			set-facet face 'target target
		]
		
		on-make: [
			; Prepare materials
			make-material face get-facet face 'material
			set-material face 'up
			
			;user forced orientation
			if face/facets/orientation [
				;setup scroller orientation
				a: face/facets/axis: pick [x y] face/facets/orientation = #h
				all [
					face/facets/init-length
					face/facets/init-size/:a: face/facets/init-length
				]
				face/facets/max-size/:a: guie/max-coord
				face/facets/min-size/:a: face/facets/length-limit
			]
		]

		on-attached: [
			either has-actor? arg/1 'on-scroll [
				unless arg/2 [
					do-actor arg/1 'on-scroll face
				]
				false	;break the attached chain here
			][
				do-actor/style face 'on-attached arg 'face			
			]
		]
		
		on-resize: [
			; this is the size of the 'available cell space'
			size: arg

			unless face/facets/axis [
				; clip size in its minor direction:
				a: pick [x y] size/y < size/x	; major axis
			
				;set scroller orientation for the first time
				set-facet face 'axis a

				all [
					face/facets/init-length
					face/facets/init-size/:a: face/facets/init-length
				]
				
				;enable expansion of the major axis
				face/facets/max-size/:a: guie/max-coord
				
				;set proper limit in the major axis
				face/facets/min-size/:a: face/facets/length-limit

				update-face/no-show face

				;once the scroller is oriented add 'scroll reactor
;				if select face/target: get-facet face 'target [
;					append-face-act face reduce ['scroll target]
;					do-actor targets 'on-scroll face
;				]

				do-targets/custom face [do-actor target 'on-scroll face]

;				; parent can set scroller values now
;				if target: get-facet face 'target [
;					do-actor target 'on-scroller face
;				]
			]

			; calculate the face size
			do-actor/style face 'on-resize size 'face

			get-facet face [gob-size: btn-size: axis:]

			; determine minor axis:
			z: pick [x y] axis = 'y
			
			; Set angles for arrow button directions:
			face/facets/angles: pick [[0 180] [270 90]] gob-size/y > gob-size/x
			
			; Set position of far button:
			bxy: gob-size - btn-size
			bxy/:z: 1
			face/facets/btn-xy: bxy
			
			; Update scroller:
			do-actor face 'on-update none
		]

		on-set: [ ; arg: [word value]
			dirty?: false
			if arg/2 [
				fields: get-facet face 'set-fields
				if find words-of fields arg/1 [			; check that field exists
					do bind select fields arg/1 'face 	; NOTE: check that arg is block?
				]
				if dirty? [do-actor face 'on-update none]
			]
		]

		on-get: [ ; arg: type
			fields: get-facet face 'get-fields
			do bind select fields arg 'face
		]

		on-reset: [
			face/state/value: 0%
			face/state/delta: 10%
		]

		on-update: [ 
			; get some values:
			get-facet face [btn-size: gob-size: axis:]
			value: face/state/value

			; get scroller's minor axis
			axim: either 'x = axis [1x0][0x1]
			
			; set new values
			unless none? gob-size [
				area: gob-size - (2 * btn-size)
				; limit size so knob doesn't get too small
				knob-size: max 12x12 area * axim * face/state/delta + (reverse axim * 12)
				knob-xy: area - knob-size * value  + btn-size * axim + (reverse axim * 2)
				
				set-facet face 'knob-xy knob-xy
				set-facet face 'knob-size knob-size
				draw-face face
			]	
			
			; TODO: treat attached actors...
			all [
 				act: find-face-actor/reverse face 'on-scroll
			]
		]

; NOTE: converted from external function
;
;		have a look if those funcs are really necessary
;

		on-sense-scroll: [ ; arg: offset
;			"Map scroller offset to sub-part index (1: knob 2: btn1 3: btn2)"
			get-facet face [gob-size: btn-size: knob-size: knob-xy:]
			axis: face-axis? face
			n: arg/:axis
			k: knob-xy/:axis
			case [
				n < btn-size/:axis [2]
				n > (gob-size/:axis - btn-size/:axis) [3]
				n < k [4]
				n > (k + knob-size/:axis) [5]
				true [1]
			]
		]
		
		on-bump-scroll: [	; arg: delta multiplier
;			"Increment or decrement the face value by the face delta."
			d: to percent! face/state/delta * arg
			set-face face face/state/value + d ; redraws
		]

; ------------------------

		on-click: [
			if arg/type = 'down [
				switch do-actor face 'on-sense-scroll arg/offset [
					1 [return init-drag/only face face/state/value]
					2 4 [do-actor face 'on-bump-scroll -1]
					3 5 [do-actor face 'on-bump-scroll 1]
				]
			]
			true ;don't do unfocus
		]

		on-drag: [ ; arg: drag
			axis: get-facet face 'axis
			size: face/facets/gob-size - (2 * face/facets/btn-size) - face/facets/knob-size + 1x1
			scroll-pos: size/:axis  * arg/base + arg/delta/:axis
			set-face face max 0% min 100% to percent! scroll-pos / size/:axis
			draw-face face
			do-face face
		]

		on-delta: [ ;arg: [x-delta% y-delta%]
			print "WARNING: scroller's on-delta called"
			; Called when some other face wants to update the DELTA field.
			face/state/delta: pick arg 'x = get-facet face 'axis
			if get-facet face 'gob-size [ ; we have been init'd
				set-face face face/state/value
				draw-face face
			]
		]

		on-scroll-event: [ ; arg: event
			; send event to target
			if target: get-facet face 'target [
				do-actor target 'on-scroll-event arg
			]
			none
		]
	]
]

] ; -end-
