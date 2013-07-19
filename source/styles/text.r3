REBOL [
	Title: "REBOL 3 GUI Styles - Text fields and areas"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
	Todo: [
		FIELD: "set min-size on init based on font's size"
	]

	Notes: [
	]

]

stylize [

text: [

	about: "Simple text without background."

	tags: [info]

	facets: [
		text-body: ""
		text-style: 'base
		init-size: #auto
		min-size: none
		max-size: none
		auto-size: false
;		auto-width: false
	]

	options: [
		text-body: [string! block!]
		text-color: [tuple!]
		init-size: [integer! pair! issue!]
	]


	; To debug, uncomment this line:
;	draw: [pen 100.100.100 line-width 2 box 0x0 (viewport-box/bottom-right - 1)]

	actors: [
		on-resize: [
			ff: face/facets

			if ff/auto-size [	;auto-size face according to the available "cell-space"
				
				ff/auto-size: false
				
				space: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2

				ff/min-size: min arg ff/init-size: space + size-text-face face arg
				
;				either ff/auto-width [
					ff/max-size: ff/init-size
;				][
;					ff/max-size/y: ff/init-size/y
;				]

				update-face/no-show face
			]
			
			; calculate the face size using "default actor"
			do-actor/style face 'on-resize arg 'face
		]
		
		on-init: [
			style: face-font? face

			all [
				a: get-facet face 'text-align
				a <> style/para/align
				extend face 'para make any [select face 'para style/para] [align: a]
			]

			all [
				v: get-facet face 'text-valign
				v <> style/para/valign
				extend face 'para make any [select face 'para style/para] [valign: v]
			]

			all [
				not none? w: get-facet face 'text-wrap
				w <> style/para/wrap?
				extend face 'para make any [select face 'para style/para] [wrap?: w]
			]

			all [
				c: get-facet face 'text-color
				extend face 'font make any [select face 'font style/font] [color: c]
			]

			all [
				s: get-facet face 'text-size
				extend face 'font make any [select face 'font style/font] [size: s]
			]

			
			size: get-facet face 'init-size
			
			ff: face/facets

			switch type?/word size [
				none! [	;one line text: minimum is text-line dimension, width expands to max-coord
					size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face guie/max-pair
					unless ff/min-size [ff/min-size: size]
					unless ff/max-size [ff/max-size: as-pair guie/max-coord size/y]
					ff/init-size: size
					size
				]
				issue! [	;auto-sized text: uses space which is available on first on-resize call
					ff/auto-size: true
;					if issue? size [ff/auto-width: true]
					
					text-size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face guie/max-pair					

					unless ff/min-size [ff/min-size: as-pair 0 text-size/y]
					unless ff/max-size [ff/max-size: guie/max-pair]

					ff/init-size: min ff/max-size 10000x10000					
				]
				integer! [ ;fixed widh text: one line, with fixed width
					text-size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face as-pair size guie/max-coord
					size: as-pair size text-size/y
					
					unless ff/min-size [ff/min-size: size]
					unless ff/max-size [ff/max-size: size]
					ff/init-size: size
				]
				pair! [ ;custom size text: by default fixed dimensions, but can be overriden by user OPTIONS
					unless ff/min-size [ff/min-size: size]
					unless ff/max-size [ff/max-size: size]
				]
			]
		]

		on-get: [ ; arg: word
			if arg = 'value [
				face/facets/text-body
			]
		]

		on-set: [
			if arg/1 = 'value [
				data: any [arg/2 ""]
				face/facets/text-body: either block? data [data][form data]
			]
		]

	]
]

title: text [

	about: "Title text style without background."

	facets: [
		text-style: 'title
	]
]

head-bar: text [

	about: "Boxed text bar for headings."

	facets: [
		init-size: none ;expands width to max
		margin: [1x1 1x1]
		bar-color: 255.255.255.155
		edge-color: 80.80.80.155
		text-style: 'head-bar
	]

	options: [
		text-body: [string! block!]
		bar-color: [tuple!]
		text-color: [tuple!]
		init-size: [pair! integer! issue!]
	]

	draw: [
		pen edge-color
		line-width 1.3
		fill-pen bar-color
		box padding-box/top-left (padding-box/bottom-right - 1) 2
	]

]

label: text [

	about: "Label text without background."

	facets: [
		text-style: 'label
		align: 'right
		valign: 'middle
	]
]

text-item: text [

	tags: [state tab internal]

	facets: [
		init-size: 100x18
		max-size: 2000x18
		min-size: 40x18
		bg-color: 255.255.255.155
		edge-color: black
		edge-width: 0.1
		text-style: 'list-item
		related: 'on-mutex
		margin: [2x0 2x0]

		material: 'piano
	]

	options: [
		text-body: [string! block!]
		bg-color: [tuple!]
	]

	draw: [
		pen edge-color
		line-width edge-width
		grad-pen linear 1x1 0 viewport-box/bottom-right/y 90 area-fill
		box 1x1 (viewport-box/bottom-right - 1)
	]

	actors: [
		on-make: [
			face/facets/init-size: face/facets/min-size: face/facets/max-size: 4x0 + size-text-face face 800x600
		]

		on-init: [
			make-material face get-facet face 'material
		]

		on-set: [
			all [
				arg/1 = 'value
				face/state/value: true? arg/2
				set-facet face 'edge-width 2
				parent-face: face/gob/parent/data
				parent-face/state/value: index? find faces? parent-face face
			]
			show-later face
		]

		on-click: [
			focus face/gob/parent/data ; focus parent-face
			if arg/type = 'up [
				set-face face true
				do-face face
			]
			true ;don't do unfocus
		]

		on-draw: [
			set-material face face/state/mode
			arg
		]

		on-mutex: [
			if all [
				face <> arg
				face/state/value
				all [
					; no explicit OF identifier
					not find select face 'reactors 'of
				]
			][
				set-facet face 'edge-width 0.1
				set-face face false
			]
		]
	]
]

text-area: [

	about: "General text input area, editable, scrollable, without background."

	tags: [internal edit]

	facets: [
		init-size: 200x120
		text-edit: ""
		lines: true
		text-style: 'area
		hide-input: false
		detab: false
	]

	options: [
		init-size: [pair!]
		text-edit: [string! block!]
		text-color: [tuple!]
	]

	state: [
		cursor:     ; string index for ibeam (insert/remove point)
		mark-head:  ; string index for head of selection (highlight)
		mark-tail:  ; string index for tail of selection (highlight)
		caret: none ; graphics subsystem object for above
		xpos: none	; x offset of caret (to avoid bobble in up/down)
		validity: none
	]

;	draw: [
;		pen yellow
;		box (gob/1/offset - space/1) (gob/1/size - 1)
;	]

	actors: [
		on-init: [

;			set-facet face 'max-size get-facet face 'init-size
		]
		on-make: [
			if face/facets/detab [
				tag-face face 'detab
			]
			
			extend face 'attached copy []
			if c: get-facet face 'text-color [
				style: face-font? face
				extend face 'font make style/font [color: c]
			]
			;
			face/state/value: face/facets/text-edit: copy face/facets/text-edit
			; The richtext itself is put in a separate GOB that is attached
			; to the background area face.
			; To edit text, we need a caret object:
			init-text-caret face ; (call before make-text)
			append face/gob gob: make-text-gob face face/gob/size "empty"
			; we don't have access to facets/space, so this code is here instead
			; it may be moved from on-make somewhere else later, where facets/space is available (on-draw?, on-resize?)

			gob/offset: (first get-facet face 'margin) + (first get-facet face 'border-size) + (first get-facet face 'padding)

			do-actor face 'on-update none
		]

;		on-attach: [ ; arg: scroller
;			; Called when a style auto attaches:
;			extend-face face 'attached arg
;			if r: get-facet arg 'default-reactor [
;				append-face-act face reduce bind r 'arg
;			]
;		]

		on-update: [
			gob: sub-gob? face
			either block? face/facets/text-edit [
				change clear skip find get-gob-text/src gob 'caret 2 to-text face/facets/text-edit clear []
;				change back back tail gob/text to-text face/facets/text-edit clear []
			][
				change back tail get-gob-text/src gob either face/facets/hide-input [append/dup clear "" "*" length? face/facets/text-edit][face/facets/text-edit]
			]
		]

		on-resize: [
			do-actor/style face 'on-resize arg 'face
			face/gob/1/offset: face/facets/space/1
			face/gob/1/size: face/facets/viewport-box/bottom-right - face/facets/viewport-box/top-left

;			do-actor face 'on-attached none
			do-attached/custom face [
				scroller [
					vals: face-text-size face
					set-face/no-show attached vals/1
					set-face/no-show/field attached vals/2 'delta
				]
			]
		]

		on-set: [ ; arg: [word value]
			switch arg/1 [
				value [
					face/state/cursor: tail face/facets/text-edit: reform any [face/state/value: arg/2 ""]
					clear-text-caret face
					;reset selection marks as well here
					select-none face/state
					do-actor face 'on-update none
					if guie/focal-face = face [update-text-caret face]
					do-actor face 'on-resize face/gob/size
				]
				locate [
					goto-caret face arg/2
					see-caret face
					do-attached/custom face [
						scroller [
							vals: face-text-size face
							set-face/no-show attached vals/1
							set-face/no-show/field attached vals/2 'delta
						]
					]
					show-later face
				]
			]
			do-attached face
;			do-face face
		]

		on-get: [ ; arg: word
			if arg = 'value [
				face/facets/text-edit
			]
		]

		on-clear: [
			clear face/facets/text-edit
			show-later face
		]

		on-scroll: [ ; arg: scroller
			gob: sub-gob? face
			scroll: get-gob-scroll gob
			size: gob/size - scroll
			tsize: size-txt gob
			; offset added due to a problem with size-text
			scroll/y: min 0 arg/state/value * negate tsize/y - gob/size/y + 5
			set-gob-scroll gob scroll
			show-later face
		]

		on-key: [ ; arg: event
			if arg/type = 'key [

				do-text-key face arg arg/key

				if guie/focal-face = face [
					;!! Optimize these: (e.g. do not redraw if not necessary)
					update-text-caret face
					see-caret face
;					do-actor face 'on-attached none
					do-attached/custom face [
						scroller [
							vals: face-text-size face
							set-face/no-show attached vals/1
							set-face/no-show/field attached vals/2 'delta
						]
					]
					show-later face
				]
			]
		]

		on-scroll-event: [ ; arg: event
			d: none
			; TODO: rewrite so BAR doesn't depend on psotion in attached
			if bars: select face 'attached [
				foreach bar bars [
					axis: get-facet bar 'axis
					switch arg/type [
						scroll-line [d: arg/offset/:axis / -30]
						scroll-page [d: negate arg/offset/:axis]
					]
					if d [
						do-actor first bars 'on-bump-scroll d
					]
				]
			]
			none
		]

		on-click: [ ; arg: event
			clear-all-carets window-face? face

			either system/version/4 = 13 [
				;touch controlled caret/selection handling (currenly for Android)
				
				cur: oft-to-caret sub-gob? face arg/offset
				
				if cur [
					switch arg/type [
						down [
							;allow text selection dragging only when face has been already focused
							if guie/focal-face = face [
								click-text-face face cur arg
								return init-drag/only face arg/offset
							]
						]
						up [
							;position the caret and show keyboard only when there was no text selection dragging before
							unless guie/drag/active [
								click-text-face face cur arg
								show-soft-keyboard/attach guie/focal-face/gob
							]
						]
					]
				]
			][
				;caret/selection handling using mouse
				if all [
					arg/type = 'down
					cur: oft-to-caret sub-gob? face arg/offset
				][
					click-text-face face cur arg
					return init-drag/only face arg/offset
				]
			]
			true ;don't do unfocus
		]

		on-drag: [ ;arg: drag object
;			prin "on-drag"
			if all [
				arg/event/gob = sub-gob? face ; must be in same gob
				cur: oft-to-caret sub-gob? face arg/event/offset
			][
				state: face/state
				unless state/mark-head [state/mark-head: state/cursor]
				state/mark-tail: state/cursor: first cur
				;!! Optimize these:
				update-text-caret face
				see-caret face

;				do-actor face 'on-attached none
				do-attached/custom face [
					scroller [
						vals: face-text-size face
						set-face/no-show attached vals/1
						set-face/no-show/field attached vals/2 'delta
					]
				]
				show-later face
			]
		]

		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			either arg/1 [
				unless face/state/cursor [
					face/state/cursor: tail face/facets/text-edit
				]
				update-text-caret face ; will restore previous caret and highlight
			][
				clear-text-caret face
			]
			show-later face
			none
		]

		on-reset: [
			txt: get-gob-text/src face/gob
			clear last txt
			show-later face
			none
		]

		on-set-bg-color: [
			if none? arg [arg: get-facet face 'bg-color]
			make-material/color face get-facet face 'material arg
			set-material face 'up
			draw-face/now face
		]

		;on-clear
		;on-undo
		;on-swipe: none
	]
]

text-box: text-area [

	about: "Text area with background box."

	tags: [edit tab]

	facets: [
		bg-color: snow
		margin: [3x3 3x3]
		padding: [3x3 3x3]
 		draw-mode: 'normal
		area-fill:
		material: 'field-groove
		focus-color: guie/colors/focus
	]

	options: [
		init-size: [pair!]
		text-edit: [string! block!]
		bg-color: [tuple!]
		text-color: [tuple!]
	]

	draw: [
		normal: [
			; top groove
			pen black
			grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
			box padding-box/top-left (padding-box/bottom-right - 1)
		]
		focus: [
			fill-pen focus-color
			box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 5
			fill-pen none
			; top groove
			pen black
			grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
			box padding-box/top-left (padding-box/bottom-right - 1)
		]
	]

	actors: [
		on-init: [
			do-actor/style face 'on-init arg 'text-area
			make-material/facet face get-facet face 'material 'bg-color
			set-material face 'up
		]

		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			set-facet face 'draw-mode either arg/1 ['focus]['normal]
			set-facet face 'focus-color either arg/1 [guie/colors/focus][255.255.255.0]
			draw-face face
			do-actor/style face 'on-focus arg 'text-area
		]
	]

]

field: text-box [

	about: "Single line text input, editable, with background box."

	facets: [
		init-size: 130x26
		max-size: 2000x26
		min-size: 26x26
		lines: false
		text-style: 'field
		padding: [3x3 3x0]
	]

	options: [
		init-size: [integer!]
		text-edit: [string! block!]
		bg-color: [tuple!]
		text-color: [tuple!]
	]

	actors: [
		on-init: [
			if integer? face/facets/init-size [
				face/facets/init-size: as-pair face/facets/init-size 26
			]
			do-actor/style face 'on-init arg 'text-box
		]
	
		on-validate: [ ; no argument
			face/state/validity: validate-face face
			set-facet face 'border-color switch face/state/validity [
				skipped [snow]
				required [white]
				not-required [snow]
				invalid [red]
				valid [green]
			]
			draw-face face
			set-face arg face/state/validity
		]


		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			set-facet face 'draw-mode either arg/1 ['focus]['normal]
			set-facet face 'focus-color either arg/1 [guie/colors/focus][255.255.255.0]
			either arg/1 [
				either arg/2 [
					;on re-focus only update caret
					update-text-caret face ; will restore previous caret and highlight
				][
					;highlight all on 'first focus'
					face/state/cursor: first back tail get-gob-text sub-gob? face
					select-all face
				]
			][
				clear-text-caret face
			]
			draw-face face
			show-later face
			none
		]
	]
]


info: text-area [

	about: "Text information fields, non-editable."

	tags: [tab select]

	facets: [
		margin: [3x3 3x3]
		padding: [3x2 3x2]
		init-size: 100x26
		max-size: as-pair guie/max-coord 26
		min-size: 20x26
		lines: false
		text-style: 'info
		edge-color: 100.100.100.55
		area-color: 240.240.240.105
	]

	options: [
		init-size: [pair!]
		text-edit: [string! block!]
		text-color: [tuple!]
	]

	draw: [
		clip margin-box/top-left margin-box/bottom-right
		pen edge-color
		line-width 1.5
		fill-pen area-color
		box padding-box/top-left (padding-box/bottom-right - 1) 1
	]
]

code: info [
	about: "Source code fields, non-editable."

	facets: [
		text-style: 'code
		edge-color: 0.0.0.55
		area-color: 240.240.240
	]
]

area: htight [

	about: "Multi-line text input, editable, scrollable, with background and scrollbars."

	facets: [
		break-after: 2
		bg-color: snow
		init-size: 400x200 ; test
		names: true
	]

	options: [
		text-edit: [string! block!]
		bg-color: [tuple!]
		init-size: [pair!]
	]

	content: [
		text-box: text-box :text-edit :bg-color :init-size on-key [
			do-actor parent-face? face 'on-key arg
		] options [text-style: :text-style detab: :detab]
		scroller: scroller
	]

	actors: [
		on-set: [ ; arg: [word value]
			do-actor first f: faces? face 'on-set arg
			; Auto-reset scroller:
			if arg/1 = 'value [
				apply :set-face [f/2 0% arg/3]
			]
		]

		on-get: [
			get-face first faces? face
		]

		on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
			all [ ;focus internal text-box only on 'focus' arg state(to avoid recursive loop)
				arg/1
				focus face/names/text-box
			]
		]

		on-key: [
			do-actor/style face/names/text-box 'on-key arg 'text-box
		]
	]
]

code-area: area [

	about: "Multi-line code input, editable, scrollable, with background and scrollbars."

	content: [
		code :text-edit options [
;			min-size: 200x200
			init-size: 200x200
			max-size: guie/max-pair
		]
		scroller
	]
]

info-area: area [

	about: "Multi-line text info, non-editable, scrollable, scrollbars."

	content: [
		info :text-edit options [
			init-size: 200x120
			max-size: guie/max-pair
			text-style: 'info-area
		]
		scroller
	]
]

tag-field: field [

	about: "Special kind of FIELD style for use in TAG-AREA. Adds oval and closing cross to text after editing."

	tags: [edit tab internal]
	
	facets: [
		close-color: black
		all-over: true	; continuous over events (for checking close button)
		original-tags: none
		original-title: none
	]

	draw: [
		normal: [
			; top groove
			pen black
			grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
			box padding-box/top-left (padding-box/bottom-right - 1) 6
			pen close-color
			line-width 3
			line (viewport-box/top-right - 14x-2) (viewport-box/bottom-right - 5)
			line (viewport-box/top-right - 5x-2) (viewport-box/bottom-right - 14x5)
		]

		focus: [
			fill-pen focus-color
			box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 5
			fill-pen none
			; top groove
			pen black
			grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
			box padding-box/top-left (padding-box/bottom-right - 1)
		]
	]

	actors: [

		on-key: [
			do-actor/style face 'on-key arg 'field
			
			if arg/type = 'key-up [
				switch arg/key [
					#"^[" #"^M" [
						p: compound-face? face ;must be called before on-update-tag !
						do-actor face 'on-update-tag none
						focus p
					]
				]
			]
		]

		on-update-tag: [
			; store tag and change style layout

			p: compound-face? face
			title: trim get-face face
			tags: get-face p

			either any [
				empty? title
				find face/facets/original-tags title
			][
				; If tag already exists or is empty, remove it
				set-face p face/facets/original-tags
			][
				; update tag-area (calls on-resize actor)
				update-face p
			]

			p/facets/edit-mode: false
			
			get-facet face [original-title:]
			diff: first difference face/facets/original-tags get-face p
			result: either diff [
				either all [
					original-title
					diff <> original-title
				][
					['set diff 'unset original-title]
				][
					['set diff]
				]
			][
				either original-title [
					['unset original-title]
				][
					none
				]
			]
			
			if result [do-actor p 'on-action reduce result]
		]
		
		on-focus: [
			do-actor/style face 'on-focus arg 'field

			either arg/1 [ ; focus
				title: get-face face
				set-facet face 'original-tags difference get-face compound-face? face reduce [title]
				set-facet face 'original-title all [not empty? title copy title]
			][ ; unfocus
				do-actor face 'on-update-tag none
			]
		]

		on-over: [
			do-actor/style face 'on-over arg 'field
			; change color of close button when needed
			get-facet face [viewport-box: close-color:]
			color: either all [arg arg/x > (viewport-box/top-right/x - 16)] [red][black]
			unless equal? color close-color [
				set-facet face 'close-color color
				draw-face face
			]
		]

		on-click: [
			either all [arg arg/offset/x > (face/facets/viewport-box/top-right/x - 16)][
				if arg/type = 'up [
					p: compound-face? face
					p/intern/remove-tag face
					update-face p
					do-actor p 'on-action reduce ['unset get-face face]
				]
			][
				if arg/type = 'down [
					p: compound-face? face
					if p/facets/edit-mode [unfocus exit]
				]
				do-actor/style face 'on-click arg 'field
			]
		]

	]

]

tag-area: hpanel [

	about: "Area of TAG-FIELDs."

	facets: [
		names: true
		border-color: black
		border-fsize: [1x1 1x1]
		
		draw-mode: 'normal
		bg-color: 220.220.220

		edit-mode: false ; tag-field is active, don't process on-click
		tags: []
	]

	options: [
		tags: [block!]
	]

	tags: [tab eat-tab compound]

	content: [
		tags: hgroup :init-size
			options [names: true spacing: 0x0 padding: [0x0 0x0] margin: [0x0 0x0]]
			on-click [
				p: parent-face? face
				if all [
					not p/facets/edit-mode
					arg/type = 'up
				][
					focus p/intern/add-tag p none
					p/facets/edit-mode: true
					show-later face
				]
			]
	]

	intern: [

		add-tag: funct [
			"Add tag face to tag panel. Return NONE, if tag already exists."
			face [object!] "Tag-area panel" ; TODO: change to panel?
			title [none! string!] "Tag text"
			/no-show
		][
			; check if tag exists
			tags: get-face face
			if find tags title [return none]

			; add tag
			unless title [title: ""]
			append tags title

			; check if new line is required
			lay: clear []
			faces: faces? face/names/tags
			either zero? length? faces [
				; this is first line
			][
				; add return
				append lay 'return
			]
			append lay reduce ['tag-field title]
			apply :append-content [face/names/tags lay no-show]

			last faces? face/names/tags
		]

		remove-tag: funct [
			"Remove tag face from panel"
			face [object!] "Tag-field face"
		][
			p: compound-face? face
			remove find p/facets/tags get-face face
			p/intern/layout-tags/force p
		]

		layout-tags: funct [
			face
			/force "Do not get tags from faces, use TAGS facet instead" ; TODO?: make /force opposite
		][
			tags: either force [get-facet face 'tags][get-face face]
			unless face/facets/gob-size [face/facets/gob-size: 100x100] ; override wrong size when called from on-init
			clear-content/no-show face/names/tags
			height: guie/styles/tag-field/facets/init-size/y
			tag-gob: make gob! reduce/no-set [size: as-pair 500 height]
			content: clear []
			width: 0
			foreach tag tags [
				tag-gob/text: tag
				size: 28 + size-text tag-gob ; 28 = text size + cross button + margin + padding
				width: width + size/x
				if width > face/facets/gob-size/x [
					append content 'return
					width: size/x
				]
				size/y: height
				repend content ['tag-field tag 'options compose [init-size: (size) min-size: (size) max-size: (size)]]
			]
			set-content/no-show face/names/tags content
		]
	]

	draw: [
		normal: [
			pen border-color
			fill-pen bg-color
			box (margin-box/top-left + 1) (margin-box/bottom-right - 2)
		]

		focus: [
			pen guie/colors/focus
			fill-pen bg-color
			line-width 3
			box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 3
			fill-pen off
			pen border-color
			line-width 1
			box (margin-box/top-left + 1) (margin-box/bottom-right - 2)
		]
	]
	
	actors: [

		on-init: [
			do-actor/style face 'on-init arg 'hpanel
			unless empty? tags: get-facet face 'tags [
				face/intern/layout-tags/force face
			]
		]

		on-get: [
			faces: faces? face/names/tags
			tags: copy []
			foreach fac faces [
				if equal? select fac 'style 'tag-field [
					append tags get-face fac
				]
			]
			tags
		]

		on-set: [
			switch arg/1 [
				value [
					apply :clear-content [face/names/tags false none arg/3]
					append clear get-facet face 'tags arg/2
					face/intern/layout-tags/force face
					apply :update-face [face arg/3]
				]
			]
		]

		on-resize: [
			face/intern/layout-tags face
			do-actor/style face 'on-resize arg 'hpanel
		]

		on-key: [ ; arg: event
			if arg/type = 'key [
				switch arg/key [
					#" " [
						; add new tag
						focus face/intern/add-tag face none
						face/facets/edit-mode: true
					]
				]
			]
		]

		on-focus: [
			set-facet face 'draw-mode either arg/1 ['focus]['normal]
			draw-face face
		]
	]
]

] ; -end-
