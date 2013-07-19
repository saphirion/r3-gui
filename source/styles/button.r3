REBOL [
	Title: "REBOL 3 GUI Styles - Primary types of buttons"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

stylize [

clicker: [

	about: "Single-action button without text. Basis of other styles."

	tags: [internal]

	facets: [
		init-size: 28x28
		bg-color: 80.100.120
		border-color: 0.0.0.127

		pen-color: ; set by on-draw
		area-fill: ; set by on-draw
		material: 'chrome
		focus-color: guie/colors/focus
		draw-mode: 'normal
		materials: none
		face-width: none
	]

	options: [
		face-width: [integer!]
		init-size: [pair!]
		bg-color: [tuple!]
	]

	state: [
		validity: none
	]

	draw: [	
		normal: [
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
			box 1x1 (viewport-box/bottom-right - 2) 1
		]
		focus: [
			fill-pen focus-color
			box -1x-1 viewport-box/bottom-right 5
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
			box 1x1 (viewport-box/bottom-right - 2) 1
		]
	]
	actors: [
		on-make: [
			if face/facets/face-width [
				face/facets/init-size/x: face/facets/min-size/x: face/facets/max-size/x: face/facets/face-width
			]
		]
	
		on-init: [
			set-facet face 'materials make-material face get-facet face 'material
		]

;		on-attach: [
;			; Called when some face auto-attaches:
;			extend-face face 'attached arg
;			if r: get-facet arg 'default-reactor [
;				append-face-act face reduce bind r 'arg
;			]
;		]
		
		on-draw: [
			set-material face face/state/mode
			color: get-facet face 'border-color
			if face/state/mode = 'over [
				color: color / 2
				color/4: 255 - color/4
			]
			face/facets/pen-color: color
			arg ; return draw block
		]

		on-over: [ ; arg: offset or none
			face/state/mode: pick [over up] face/state/over: not not arg
			draw-face face
		]

		on-click: [ ; arg: event
			face/state/mode: arg/type
			if 'up = face/state/mode [face/state/mode: 'over]
			draw-face face
			if arg/type = 'up [
				focus face
				do-face face
			]
			true ;don't do unfocus
		]
		
		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			set-facet face 'draw-mode either get arg/1 ['focus]['normal]
			set-facet face 'focus-color either get arg/1 [guie/colors/focus][255.255.255.0]
			draw-face face
		]
		
		on-key: [ ; arg: event
			if arg/type = 'key [
				switch arg/key [
					#" " [
						do-face face
					]
				]
			]
		]

		on-validate: [
			face/state/validity: validate-face face
		]
	]
]

button: clicker [

	about: "Single action button with text."
	
	tags: [action tab]

	facets: [
		init-size: 130x24
		text: "Button"
		text-style: 'button
		max-size: 260x24
		min-size: 24x24
		text-size-pad: 20x0
	]

	options: [
		text: [string! block!]
		bg-color: [tuple!]
		init-size: [pair!]
		face-width: [integer! issue!]
	]
	
	actors: [
		on-make: [
			either face/facets/face-width = #auto [
				face/facets/max-size:
				face/facets/init-size: face/facets/text-size-pad + as-pair first font-text-size? face-font? face face/facets/text 24
			][
				do-actor/style face 'on-make arg 'clicker			
			]
		]
		
		on-set: [
			if arg/1 = 'value [
				face/facets/text: form any [arg/2 ""]
				show-later face
			]
		]
		on-get: [
			if arg = 'value [
				face/facets/text
			]
		]
		on-draw: [
			t: get-facet face 'text
			; limit-text-size modifies, so we need to copy
			; size is made 20px smaller to incorporate "..." (see text-size-pad)
			l: limit-text-size copy/deep t face/gob/size - face/facets/text-size-pad face-font? face
			set-facet face 'text-body either equal? t l [t][join l "..."]
			do-actor/style face 'on-draw arg 'clicker
		]
	]
]

toggle: button [

	about: "Dual action button with text and LED indicator."
	
	tags: [action tab]

	facets: [
		led-colors: reduce [green coal]
		text: "Toggle"

		; (includes button fields)
		led-color: none
		material: 'aluminum
	]

	options: [
		text: [string! block!]
		bg-color: [tuple!]
		orig-state: [logic!]
		init-size: [pair!]
	]

	draw: [
		normal: [
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
			box 1x1 (gob/size - 2) 1
			line-width 0.4
			fill-pen led-color
			box 7x7 (gob/size - 7 * 0x1 + 12x0) 1
		]	
		focus: [
			fill-pen focus-color
			box -1x-1 viewport-box/bottom-right 5
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
			box 1x1 (gob/size - 2) 1
			line-width 0.4
			fill-pen led-color
			box 7x7 (gob/size - 7 * 0x1 + 12x0) 1
		]
	]

	actors: [
		on-init: [
			face/state/value: true? get-facet face 'orig-state
			make-material face get-facet face 'material
		]

		on-set: [
			if arg/1 = 'value [face/state/value: true? arg/2]
		]

		on-get: [
			face/state/value
		]

		on-clear: [
			set-face face false
		]

		on-draw: [
			face/facets/led-color: pick get-facet face 'led-colors not not face/state/value
			do-actor/style face 'on-draw arg 'button			
		]

		on-click: [ ; arg: event
			if arg/type = 'up [
				focus face
				set-face face not face/state/value
				do-face face
			]
			true ;don't do unfocus			
		]
		
		on-key: [
			if all [arg/type = 'key arg/key = #" "][
				set-face face not face/state/value
				do-face face
			]
		]
	]
]

check: toggle [
	
	tags: [state tab]

	facets: [
		init-size: 300x10
		max-size: 2000x24
		led-colors: reduce [leaf 50.50.50.55]
		text-style: 'radio
		auto-wide: 0x0 ; (padding added to text size)
		text: "Check"
		focus-color: 255.255.255.0
	]

	draw: [
		; focus box
		line-width 0
		fill-pen focus-color
		translate (as-pair 3 gob/size/y - 13 / 2)
		box -2x-2 14x14	3
		; check box
		pen pen-color
		line-width 1
		fill-pen snow
		box 0x0 11x11
		line-width 2
		pen led-color
		fill-pen led-color
		polygon 1x4 5x10 12x-1 5x6 1x3
		reset-matrix
	]

	actors: [
		on-make: [
			; If auto-wide, reset size based on text size:
			if all [
				s: get-facet face 'auto-wide
				not select face/options 'init-size
			][
				set-facet face 'text-body face/facets/text
				set-facet face 'init-size max face/facets/min-size min face/facets/max-size s + size-text-face face 2000x100
			]
		]
		
		on-focus: [
			; do original focus
			do-actor/style face 'on-focus arg 'toggle
			; send signal to related faces
			do-related face 'on-mutex-focus
		]
		
		on-mutex-focus: [
			if face <> arg [
				do-actor/style face 'on-focus reduce [false none] 'toggle
			]
		]
	]
]

radio: check [
	
	tags: [state tab]

	facets: [
		related: none
		text: "Radio"
		auto-wide: 0x0
		max-size: 2000x30
	]

	options: [
		text: [string! block!]
		bg-color: [tuple!]
		orig-state: [logic!]
		init-size: [pair!]
		related: [money!]
	]

	draw: [
		;focus circle
		pen none
		line-width 0
		fill-pen focus-color
		translate (as-pair 3 gob/size/y - 12 / 2)
		circle 5.5x5.5 7.8 ; HUH????????
		pen pen-color
		line-width 1.5
		fill-pen snow
		circle 5x5 5.6
		line-width 0.1
		fill-pen led-color
		circle 5x5 2.5
		reset-matrix
	]

	actors: [
		on-click: [ ; arg: event
			if arg/type = 'up [
				focus face
				set-face face true
				do-face face
			]
			true ;don't do unfocus
		]
		
		on-set: [
			do-actor/style face 'on-set arg 'check
			either face/facets/related [
				do-related/deep/from face 'on-mutex window-face? face
			][
				do-related face 'on-mutex
			]
		]

		on-key: [
			if all [arg/type = 'key arg/key = #" "][
				set-face face true
				do-face face
			]
		]

		on-mutex: [
			; Turn off related faces...
			if all [
				face <> arg
				arg/facets/related = face/facets/related
				face/state/value
			][
				; set face to FALSE (can't use set-face to prevent loop)
				do-actor/style face 'on-set reduce ['value false] 'check
				draw-face face
			]
		]
	]
]

arrow-button: clicker [

	about: "Single action button with arrow (but no text)."

	facets: [
		init-size:
		min-size:
		max-size: 20x20
		arrow-color: snow

		angle: 0
		material: 'aluminum
		center-point: none
	]

	options: [
		init-size: [pair!]
		bg-color: [tuple!]
		angle: [integer!]
	]

	draw: [
		pen pen-color
		line-width 1.3
		grad-pen cubic 1x1 0 40 area-fill
		box 1x1 (gob/size - 2) 3
		; arrow part:
		transform angle .7 .7 0x0 center-point
		pen arrow-color
		line-width 2.7
		line-cap rounded
		line -6x5 0x-5 6x5 0x-1 -6x5
	]

	actors: [
		on-resize: [ ; arg: size
			do-actor/style face 'on-resize arg 'face
			face/facets/center-point: face/facets/gob-size - 2 / 2
		]
	]
]

drop-down: button [ ; THERE ARE PROBLEMS WITH STATE vs. FACETS
	
	about: "Drop-down test."
	
	tags: [tab state]

	facets: [
		text-style: 'dropdown
		text?: true

		area-fill: none
		arrow-center: 0x0
		pen-color: none		;set by on-draw
		text-size-pad: 40x0
	]

	options: [
		list-data: [block!]
		value: [integer!]
	]

	state: [
		value: [string!]
		validity: [word!]
	]	

	draw: [
		normal: [
			;draw button frame
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 40 90 area-fill
			box 1x1 (viewport-box/bottom-right - 2) 1
			;draw arrow
			transform 180 0.6 0.6 0x0 arrow-center
			pen border-color
			line-width 1
			line-cap rounded
			polygon -12x10 0x-10 12x10 ;0x-1 -12x10
			line-width 1
			line 20x12 20x-12
			reset-matrix
			;center following text
			translate -20x0
		]
		focus: [
			fill-pen focus-color
			box -1x-1 viewport-box/bottom-right 5
			;draw button frame
			pen pen-color
			line-width 1
			grad-pen linear 1x1 0 40 90 area-fill
			box 1x1 (viewport-box/bottom-right - 2) 1
			;draw arrow
			transform 180 0.6 0.6 0x0 arrow-center
			pen border-color
			line-width 1
			line-cap rounded
			polygon -12x10 0x-10 12x10 ;0x-1 -12x10
			line-width 1
			line 20x12 20x-12
			reset-matrix
			;center following text
			translate -20x0
		]
	]
	
	actors: [
		
		on-make: [
			if none? get-facet face 'value [set-facet face 'value 1]
			if none? get-facet face 'list-data [set-facet face 'list-data ["No data set!"]]
		]

		on-draw: [
			set-facet face 'text any [pick get-facet face 'list-data get-facet face 'value "No data set!"]
			do-actor/style face 'on-draw arg 'button
		]
		
		on-resize: [ ; arg is the size
			do-actor/style face 'on-resize arg 'face
			face/facets/arrow-center: face/gob/size - 15x12
		]
		
		on-set: [ ; arg is index in list-data
			;set face text and value
			
			switch arg/1 [
				data [
					set-facet face 'list-data arg/2
					face/state/value: set-facet face 'value 1
				]
				value [
					get-facet face [list-data:]
					unless empty? list-data [
						face/state/value: set-facet face 'value max 1 min length? list-data arg/2
						if get-facet face 'text? [set-facet face 'text-body pick list-data face/state/value ]
					]
				]
			]
			apply :draw-face [face arg/3]
		]
		
		on-get: [
;			pick get-facet face 'list-data get-facet face 'value
			switch arg [
				value [
					get-facet face 'value
				]
				data [
					get-facet face 'list-data
				]
			]
		]
		
		on-clear: [
			set-face face 1
		]
		
		on-key: [
			if all [arg/type = 'key arg/key = #" "][
				do-actor face 'on-open arg
			]
			;this should change value on up/down keys
			arg
		]
		
		on-click: [
			if arg/type = 'up	[
				focus face
				do-actor face 'on-open arg
			]
			true ;don't do unfocus
		]	
		
		on-open: [
				ld: get-facet face 'list-data
				popup: show-popup [
					ld: text-list ld on-action [
						do-popup-parent 'on-set reduce ['value arg]		; set value in popup's parent (this button)
						hide-popup
					] options [max-size: 2000x3000]
					when [enter] on-action [wait .001 focus ld]
				] face
		]
	]
]

drop-arrow: drop-down [

	tags: [internal]
	
	facets: [
		init-size: 20x20
		max-size: 20x20
		min-size: 20x20
;		center-point: 10x10
		arrow-color: black
		bg-color: 200.210.220
		material: 'aluminum
		text-body: none
		text?: no
	]
	
	draw: [
		
		pen pen-color
		line-width 1
;		grad-pen cubic 1x1 0 40 area-fill
;		box 1x1 (gob/size - 2) 1
		grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
		box 1x1 (viewport-box/bottom-right - 2) 1
		; arrow part:
		transform 180 .7 .7 0x0 (viewport-box/bottom-right / 2)
		pen arrow-color
		fill-pen arrow-color
		line-cap rounded
		polygon -6x5 0x-5 6x5 ;0x-1 -6x5
	
	]
	
	actors: [

		on-draw: [
			set-material face face/state/mode
			color: get-facet face 'border-color				
			if face/state/mode = 'over [
				color: color / 2
				color/4: 255 - color/4
			]
			face/facets/pen-color: color
;			set-facet face 'text-body pick get-facet face 'list-data get-facet face 'value
			arg ; return draw block
		]
	
		on-get: [
			face/state/value
		]	
		
	]
]

tab-button: clicker [
	
	about: "Tab button. For internal use."
	
	tags: [internal state]

;options [material: 'aluminum bg-color: 200.210.220 min-size: 50x20 init-size: 70x20 max-size: 1000x20 text-style: 'sbutton]


	facets: [
		init-size: 70x20 ; should tab-buttons change its size?
		max-size: 120x20
		min-size: 50x20
		text-style: 'sbutton
;		related: 'on-mutex
		led-colors: reduce [green coal red]
		material: 'aluminum
		bg-color: 200.210.220
		passive-color: 200.210.220
		active-color: 220.230.240
		; (includes button fields)
		led-color: none
	]

	options: [
		text-body:	[string! block!]
		id:			[tag!]
		layout:		[issue!]
		active:		[logic!]
	]
	
	actors: [
		
		on-make: [
			face/state/value: get in face/options 'active
			face/state/mode: none
			;set button layout
			mode: get-facet face 'layout
			if none? mode [mode: 'top]
;			set-facet face 'draw-mode to word! mode
		]
		
		on-draw: [
			set-material face face/state/mode
			color: get-facet face 'border-color
			face/facets/led-color: pick get-facet face 'led-colors not not face/state/value
			if face/state/mode = 'over [
				face/facets/led-color: pick get-facet face 'led-colors 3
				color: color / 2
			]
			face/facets/pen-color: color
			arg ; return draw block
		]
		
		on-click: [ ; arg: event
			if arg/type = 'down [
				hide-tooltip face
				; init drag
;				return init-drag face arg/offset
			]
			if arg/type = 'up [				
				set-face face 'down
				set-facet face 'bg-color get-facet face 'active-color
				draw-face face
				set-face parent-face? face face/name
			]
			true ; don't do unfocus
		]

		on-set: [ ; arg [key value]
			; NONE: inactive
			; DOWN: selected button
			either 'value = arg/1 [
				do-related face 'on-mutex
				; we expect 'DOWN here
				face/state/value: true
				face/state/mode: arg/2
				draw-face face
			][
				show-later face
			]
		]
		
		on-mutex: [ ; arg: face
			; used to turn off all faces, active is set separately
			; turn all faces off
			face/state/value: false
			face/state/mode: none
			draw-face face
		]

		on-over: [ ; arg: offset/none
			p: parent-face? face
			face/state/mode: either arg ['over][
				either face/state/value ['down][none]
			]
			draw-face face
			if face/gob/parent [
				parent: face/gob/parent/data
				either arg [
					buttons: compound-face? face
					tab-box: compound-face? buttons
					unless tab-box/style = 'tab-box [exit]
					
				][
; NOTE: There's a problem with HIDE-TOOLTIP - stops receiving events					
		;			hide-tooltip face
				]
			]
		]
		
		on-drag: [ ; arg: drag
			face/gob/offset: arg/offset - arg/base
			show face/gob
		]

		on-drag-over: [
			bar: parent-face? face
			do-actor bar 'on-drag-over reduce [arg/1 face/gob/offset + arg/2 arg/3]
			true
		]
			
		on-key: [ ; arg: event
			print "onkey button"
			if arg/type = 'key [
				switch arg/key [
					left [print "left"]
					right [print "right"]
				]
			]
		]
	]
]


] ; -end-
