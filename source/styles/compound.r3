REBOL[
	Title: "REBOL 3 GUI Styles - Compound styles"
	Author: "Boleslav Brezovsky"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

log-t: now/time/precise
log: func [data /local t][
	data: rejoin append copy [] data
;	print rejoin [mold data " (" (t: now/time/precise) - log-t ")"]
	log-t: t
]

stylize [

	button-bar: htight [

		about: "Simple button bar."

		facets: [
			buttons: make map! 10
			button-style: 'tab-button
			names: true
			spacing: 1x0
		]

		tags: [compound internal]	; - TODO: when button-bar is not dependent on tab-box, remove internal tag

		options: [
			init-size: [pair!]
			button-layout: [issue!]		; button layout (#top, #bottom, #left, #right)
			data-block: [block!]	; block of button names (string!) or name(string!)/id(tag!)
		]

		state: [
			items: copy []
			active: #[none]			; active button
		]

		debug-draw: [
			pen red
			line-width 2
			box 1x1 viewport-box/bottom-right
		]

		actors: [
			on-set: [
				log ["BARon-set" arg]

				switch arg/1 [
					data [ ; [face-name: "face-text"]
						bar: do-actor face 'on-parse-data arg/2
						apply :set-content [face bar false none arg/3]
					]
					value [
						if face/state/active <> arg/2 [
							; handle buttons
							face/state/active: arg/2
							apply :set-face [face/names/(arg/2) 'down arg/3]
							; call actor code
							do-actor face 'on-action arg/2
						]
					]
				]

				log "===end of on-set"
			]

			DISABLED-on-drag-over: [
				; send TRUE to set cursor to arrow mode
				drag: arg/1
				drag-offset: drag/gob/offset - get-gob-offset face/gob ; map drag face inside this face
				all [
					not empty? face/gob/pane
					pos: drag-offset/x / button-width: (face/gob/pane/1/size/x + face/facets/spacing/x)
					button-id: to integer! round pos
					gob: face/gob/pane/:button-id
					left-boundary: button-id - 1 * button-width
					gob/offset/x: max left-boundary button-id * button-width - drag-offset/x * 2 + left-boundary
					show gob/parent
				]
				true
			]

			DISABLED-on-drop: [
				drag: arg/face ; tab-button
				items: to block! face/state/items
				id: get-facet drag 'id
				pos: (to integer! arg/event/offset/x / arg/gob/size/x) * 2 + 1
				pos-id: items/:pos
				either all [drag: find items id drop: find items pos-id][
					swap next drag next drop
					swap drag drop
					set-face face to map! items
					show-later window-face? face
					true	; ok, drag-face processed
				][false]	; no, we don't want this face
			]

			; support actor with code shared between more actors
			on-visible-count: [
				; create temporary button
				but: make-face get-facet face 'button-style []
				; get current face size (minus reserved space for arrows)
				cur-size: max 0 face/facets/viewport-box/bottom-right/x - 45 ; this size should be probably also computed to prevent problems when arrow-button size changes
				to integer! cur-size / (face/facets/spacing/x + but/facets/min-size/x)
			]

			on-show-button: [
				; fix bar position, so active button is visible
				count: do-actor face 'on-visible-count none
				pos: either pos: find arg face/state/active [(1 + index? pos) / 2][0] ; 0 - not found
				if pos > count [arg: skip arg pos - count * 2]
				arg
			]

			on-make-button: [ ;arg: [id name active?]
;				compose/deep [(get-facet face 'button-style) (arg/2) (arg/3) (get-facet face 'button-layout) options [id: (to string! arg/1)]]
				either none? arg/1 [[]][
					compose/deep [(arg/1) (get-facet face 'button-style) (arg/2) (arg/3) (get-facet face 'button-layout)]
				]
			]

			on-parse-data: [
				log "BARon-parse-data"
				; TODO: whole face is recreated every time
				;		cache whole button-bar and just add/remove elements (will be really useful?)
				;
				out: copy []
				parse arg [
					some [
						(t: none)
						opt set t set-word! ; NOTE: should be optional?
						set s string!
						(
							unless none? t [
								append out do-actor face 'on-make-button reduce [:t s equal? :t face/state/active]
							]
						)
					]
				]

				if find [#left #right] get-facet face 'button-layout [
					set-facet face 'layout-mode 'horizontal
				]

				face/state/items: arg	; set position
				log "===end of parse-data"
				out
			]
		]

	]

	old-tab-box: hpanel [

		about: "Multi sub-layout."

		tags: [layout tab compound]

		facets: [
			init-hint: 600x360
			max-hint: guie/max-pair
;			min-hint: 200x100
			border-size: [1x1 1x1]
			border-color: black
			bg-color: none
			box-model: none
			spacing: 0x0			; why?
			margin: [0x0 0x0]
			padding: [0x0 0x0]

			layout-mode: 'horizontal
			names: true
			focus-color: 239.222.205
			pen-color: 0.0.0 		; set by on-draw
			tabs: make map! []		; list of tab id's. tabs will be shown as ordered here
			layouts: make map! []	; list of tab faces
			previews: make map! []	; list of previews
			placement: #top			; tab-bar position [top bottom left right]	- do this in options somehow?
			break-after: 1

			set-fields: make map! [

				value [	; value: tab-id [word!]
					log ["*Value:" value]
					; hide current tab
					if act: face/state/active [
						show-face/no-show face/names/tab-area/names/:act 'ignore
					]

					; show active tab
					panel: layouts/:value

					hint: none
					sp: get in face/names 'sp
					if sp [hint: sp/gob/size]

					tab-area: face/names/tab-area
					print "tab area is ok"

					if block? panel [
						append-content tab-area reduce [
							to set-word! value 'hpanel panel 'options compose [
								show-mode: 'hidden
								border-size: [1x1 1x1]
								border-color: black
;								init-hint: 'auto
;								init-hint: (either hint [hint][to lit-word! 'auto])
							]
						]
;						print ["added? " mold words-of tab-area/names]
						layouts/:value: tab-area/names/:value
					]

					print "going to set tab"
;					if hint [resize-face tab-area/names/:value hint]
					print tab-area/names/:value/gob/size

					; show active tab and set button bar
					if value [
						face/state/active: value
;						print mold words-of face/names
;						print ["face:" face/gob/size]
;						print face/names/:value/gob/size

						show-face tab-area/names/:value 'visible

;						print ["sp<:" tab-area/names/sp/gob/size]

						set-face face/names/tab-bar value
					]
				]

				data [	; value: dialect [block!] ; set tabs
					log ["**Data:" value]
					parse value [
						some [ (id: nm: pn: none)
							opt set id word! set nm string! set pn block! (
								if none? id [id: to word! join "tab-" issue-id tabs]
								set-face/field face reduce [id nm pn] 'tab
							)
						]
					]
				]

				tab [ ; value: [tab-id [word!] tab-name [string!] tab [block!]]
					log ["***Tab: " mold value]
;					; check for ID - need to issue one
;					unless word? value/1 [insert head value to word! join "tab-" issue-id words-of tabs]
					; add tab to caches
					tabs/(value/1): value/2
					layouts/(value/1): value/3
					; redo bar
					tb: copy []
					foreach t tabs [repend tb [to set-word! t tabs/:t]]
					set-face/field face/names/tab-bar tb 'data
				]

			]
		]

		options: [
			init-size: [pair!]		; ?
			data: [block!]		; input data pairs ["name" [layout]] or triplets [#id "name" [layout]]
			placement: [issue!]	; tabs placement: #top, #bottom, #left, #right
		]

		state: [
			active: #[none]		; index of active layout
			tab-offset: 0		; offset from beginning of the first tab in bar
			shown-tabs: 0		; number of tabs to display in bar
		]

		actors: [
			on-make: [
				make-layout face 'panel
			]

			on-init: [
				log ["on-init"]

				; clear values for new instance of tab-box:
				set-facet face 'tabs make map! []
				set-facet face 'layouts make map! []

				; set basic layout: (TODO: placement of bar is ignored)
				layout-block: [
					tab-bar: button-bar [""] #top on-action [
						p: parent-face? face
						set-face p arg
					]
					hpanel [
						plane [
							tab-area: scroll-pane [] options [names: yes]
						]
						scroller
						scroller
					] options [
						break-after: 2
					]
				]

				content: [

				]

				set-content/no-show face layout-block

				; process data:
				set-face/field face get-facet face 'data 'data

				; show first tab:
				set-face face first words-of face/facets/tabs
			]

			on-set: [ ; arg: [word value]
				log ["on-set: " mold arg]
				get-facet face [previews: tabs: layouts: set-fields:]
				if find words-of set-fields arg/1 [			; check that field exists
					value: arg/2
					act: select set-fields arg/1
					words: collect-words/set/deep act
					use words bind act 'face
				]
				show-later face
			]

			on-get: [
				"Return block of two map!s - [tab-names layout-faces]"
				log ["on-get: " mold arg]
				get-facet face [tabs: layouts:]
				reduce [tabs layouts]
			]

			on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
				set-facet face 'bg-color either arg/1 [get-facet face 'focus-color][255.255.255.0]
				draw-face face
			]

			on-key: [
				tabs: find words-of face/facets/tabs face/state/active
				if 'key-up = arg/type [
					switch/default arg/key [
						left [set-face face first back tabs]
						right [if 1 <= length? next tabs [set-face face first next tabs]]
					][print "other key"]
				]
			]
		]
	]

	; >>> Henrik

	element-group: vpanel [

		about: "Vertical group of elements, which SET-FACE or GET-FACE manages with one value."

		tags: [layout tab compound internal state tab eat-tab]

		facets: [
			element: none
		]

		state: [
			over: 1
		]

		options: [
			values: [block!]
;			break-after: [integer!] ; doesn't work?
		]

		intern: [
			process-keys: funct [
				face
				arg
			][
				; set variables
				over: face/state/over
				faces: faces? face

				; process keys
				unless over [over: 0]
				switch/default arg/key [
					up		[over: over - 1]
					down	[over: over + 1]
					#" "	[set-face faces/:over true]
					#"M"	[set-face faces/:over true]
				][
;					print ["other key" mold arg/key]
				]

				face/state/over: over
			]
		]

		actors: [

			on-make: [
				make-layout face 'panel
			]

			on-init: [
				log ["on-init"]

				layout-block: copy []
				use [w s d] [ ; word string default
					parse face/facets/values [
						any [
							set w word! set s any-type! opt ['on (d: yes)] (
								repend layout-block [
									face/facets/element form s 'on-action compose [
										p: parent-face? face
										do-actor p 'on-process (to lit-word! w)
									]
								]
								if d [
									insert skip tail layout-block -2 'on
									d: no
								]
							)
						]
					]
				]
				set-content/no-show face layout-block
			]

			on-focus: [
;				set-facet face 'edge-color either arg/1 [guie/colors/focus][black]
				unless arg/1 [
					f: face/state/over
					faces: faces? face
					do-actor faces/:f 'on-focus [false none]
				]
			]

			on-key: [
				if arg/type = 'key-up [

					; process keys
					face/intern/process-keys face arg

					; get variables
					over: face/state/over
					faces: faces? face
					f: length? faces? face

					; check boundaries
					if over < 1 [over: f]
					if over > f [over: 1]

					; process focus
					do-actor faces/:over 'on-focus reduce [true none]
					face/state/over: over
				]
			]

		]
	]

	; need to invent more kinds of groups to justify ELEMENT-GROUP over table

	check-group: element-group [

		about: "Vertical group of check boxes."

		facets: [
			element: 'check
		]

		intern: [
			process-keys: funct [
				face
				arg
			][
				; set variables
				over: face/state/over
				faces: faces? face

				; process keys
				unless over [over: 0]
				switch/default arg/key [
					up		[over: over - 1]
					down	[over: over + 1]
					#" "	[set-face faces/:over not get-face faces/:over]
					#"M"	[set-face faces/:over not get-face faces/:over]
				][
;					print ["other key" mold arg/key]
				]

				face/state/over: over
			]
		]

		actors: [

			on-process: [
				"Handle changes comming from inside the style"
				; nothing needed here, ignore any input
			]

			on-set: [
				"Set using block of words"
				faces: faces? face
				i: 0
				foreach [word value] face/facets/values [
					i: i + 1
					apply :set-face [faces/:i find arg/value word arg/3]
				]
			]

			on-get: [
				"Return block of words"

				output: clear []
				faces: faces? face
				i: 0
				foreach [word val] face/facets/values [
					i: i + 1
					if get-face faces/:i [append output word]
				]
				set-facet face 'value copy output
				output ; needed?
			]

		]

	]

	radio-group: element-group [

		about: "Layout of radio buttons"

		facets: [
			element: 'radio
		]

		actors: [

			on-process: [
				"Handle changes comming from inside the style"
				; send data to on-set
				set-face face arg
			]

			on-set: [
				"Set using a single word"

				switch arg/1 [
					value [
						set-facet face 'value arg/value
						faces: faces? face
						i: (1 + index? find face/facets/values arg/value) / 2
						apply :set-face [faces/:i true arg/3]

					]
					data [
						; TODO: set new set of radio buttons
					]
				]
			]

			on-get: [
				"Get the set radio button"

				i: 0
				foreach fc faces? face [
					i: i + 1
					if get-face fc [return pick extract face/facets/values 2 i]
				]
			]

		]

	]

	; <<< Henrik

	tab-box: vpanel [

		facets: [
			names: true
			tab-ids: copy []
			tabs: make map! []
			spacing: 0x0
			row-min: [22]
			row-init: [22]
			row-max: [22]
		]

		options: [
			tab-size: [pair!]
			data: [block!]
		]

		content: [
			pad
			tab-area: scroll-panel [] options [border-size: [1x1 1x1] border-color: black]
			tab-control: button-bar [] options [max-hint: [auto 22] show-mode: 'fixed gob-offset: 6x4]
		]

		actors: [
			on-init: [
				; set tab data
				set-face/field face get-facet face 'data 'data

				; set active tab
				tabs: get-facet face 'tabs
				set-face face first words-of tabs
			]
			on-set: [
				get-facet face [tabs:]
				tab-area: face/names/tab-area

				switch arg/1 [
					value [
						id: arg/2
						tab: tabs/:id
						if block? tab [
							; store to cache
							tab: layout/options tab [
								spacing: 0x0
								margin: [0x0 0x0]
								padding: [0x0 0x0]
							]
							tabs/:id: tab
						]
						apply :set-face [tab-area tab arg/3]

					]
					data [
						lay: copy []
						foreach [name layout] arg/2 [
							id: issue-id face/facets/tab-ids
							s: font-text-size? 'button name
							append lay reduce [
								'button name to integer! s/x + 20
								'options compose [name: (id)]
								'on-action [
									id: to word! get-facet face 'name
									p: parent-face? parent-face? face
									set-face p id
								]
							]
							id: to word! id
							tabs/:id: layout
						]
						apply :append-content [face/names/tab-control lay arg/3]
					]
				]
			]
		]
	]

	color-box: box [
		tags: [internal]
		actors: [
			on-set: [
				switch arg/1 [
					value [
						cf: compound-face? face
						switch type?/word arg/2 [
							percent! decimal! [
								idx: index? find [sld-r sld-g sld-b] face/attached-face/name
								face/facets/bg-color/:idx: 255 * arg/2
							]
							tuple! [
								face/facets/bg-color: arg/2
								apply :set-face [cf face/facets/bg-color arg/3]
							]
						]
						apply :set-face [cf/names/ci face/facets/bg-color arg/3]
						apply :draw-face [face arg/3]
						apply :do-face [cf false none arg/3]
					]
				]
			]
		]
	]

	palette-box: box [
		tags: [internal]
		actors: [
			on-click: [
				cf: compound-face? face
				set-face cf/names/bx face/facets/bg-color
			]
		]
	]

	color-field: field [
		tags: [edit tab internal]
		facets: [
			text-style: 'centered-aa
		]
	]

	color-picker: vgroup [
		tags: [compound]
		facets: [
			names: true
			color: black
		]
		options: [
			init-hint: [pair!]
			color: [tuple!]
		]
		intern: [
			palette: [
				255.255.255
				255.192.192
				255.224.192
				255.255.192
				192.255.192
				192.255.255
				192.192.255
				255.192.255

				224.224.224
				255.128.128
				255.192.128
				255.255.128
				128.255.128
				128.255.255
				128.128.255
				255.128.255

				192.192.192
				255.0.0
				255.128.0
				255.255.0
				0.255.0
				0.255.255
				0.0.255
				255.0.255

				128.128.128
				192.0.0
				192.64.0
				192.192.0
				0.192.0
				0.192.192
				0.0.192
				192.0.192

				64.64.64
				128.0.0
				128.64.0
				128.128.0
				0.128.0
				0.128.128
				0.0.128
				128.0.128

				0.0.0
				64.0.0
				128.64.64
				64.64.0
				0.64.0
				0.64.64
				0.0.64
				64.0.64
			]
		]
		content: [
			pal: htight 8 [] options [spacing: 3x3]
			return
			bx: color-box black options [max-size: as-pair guie/max-coord 120]
			ci: color-field on-key [
				do-actor/style face 'on-key arg 'field
				switch arg/type [
					key-up [
						unless error? try [color: to tuple! get-face face][
							tmp: index? face/state/cursor
							cf: compound-face? face
							set-face cf/names/bx color
							face/state/cursor: tmp
							goto-caret face tmp
						]
					]
				]
			]
			return
			head-bar 45x20 "Red" red white
			sld-r: slider attach 'bx
			head-bar 45x20 "Green" green white
			sld-g: slider attach 'bx
			head-bar 45x20 "Blue" blue white
			sld-b: slider attach 'bx
		]
		actors: [
			on-init: [
				do-actor/style face 'on-init arg 'vgroup
				blk: copy []
				foreach col face/intern/palette [
					append blk compose [palette-box (col) options [min-size: 22x22 max-size: 22x22 init-size: 22x22]]
				]
				set-content/no-show face/names/pal blk
				set-face/no-show face face/facets/color
			]
			on-set: [
				switch arg/1 [
					value [
						n: 100% / 255
						apply :set-face [face/names/sld-r arg/2/1 * n arg/3]
						apply :set-face [face/names/sld-g arg/2/2 * n arg/3]
						apply :set-face [face/names/sld-b arg/2/3 * n arg/3]
					]
				]
			]
			on-get: [
				return switch/default arg [
					value [
						face/names/bx/facets/bg-color
					]
				][
					none
				]
			]
		]
	]

	color-array-box: box [
		tags: [internal]
		facets: [
			init-size: 50x50
			border-size: [3x3 3x3]
		]
		actors: [
			on-set: [
				switch arg/1 [
					value [
						cf: compound-face? face
						idx: index? find [sld-r sld-g sld-b] face/attached-face/name
						face/facets/bg-color/:idx: 255 * arg/2
						apply :set-face [cf/names/ci face/facets/bg-color arg/3]
						draw-face face
					]
				]
			]
			on-click: [
				if arg/type = 'down [
					focus face
				]
				true
			]
			on-focus: [
				if arg [
					cf: compound-face? face
					if cf/names/ca/facets/picked-box = face [exit]
					if cf/names/ca/facets/picked-box [
						cf/names/ca/facets/picked-box/facets/border-color: none
					]
					face/facets/border-color: black
					cf/names/ca/facets/picked-box: face
					draw-face cf/names/ca
					set-face cf/names/cp face/facets/bg-color
				]
			]
			on-draw: [
				either face/facets/border-color [
					compose [
						line-pattern white 5.0 5.0
						(arg)
					]
				][
					arg
				]
			]
		]
	]

	color-array-picker: hgroup [
		tags: [compound]
		facets: [
			names: true
			color-array: reduce [red green blue]
		]
		options: [
			init-hint: [pair!]
			color-array: [block!]
		]

		content: [
			ca: hpanel snow [
				pad
			] options [
				picked-box: none
			]
			vpanel [
				button 70 "Add" on-action [
					cf: compound-face? face
					either pb: cf/names/ca/facets/picked-box [
						insert-content/pos cf/names/ca [color-array-box] pb
					][
						append-content cf/names/ca [color-array-box]
					]
					f: faces? cf/names/ca
					focus first back any [find f pb f]

				]
				button 70 "Remove" on-action [
					cf: compound-face? face
					if pb: cf/names/ca/facets/picked-box [
						remove-content/pos cf/names/ca pb
					]
				]
			]
			return
			cp: color-picker on-action [
				cf: compound-face? face
				if pb: cf/names/ca/facets/picked-box [
					pb/facets/bg-color: arg
					draw-face pb
				]
			]
		]

		actors: [
			on-init: [
				do-actor face 'on-set reduce ['value face/facets/color-array true]
				unless empty? f: faces? face/names/ca [
					focus first f
				]
			]
			on-set: [
				switch arg/1 [
					value [
						color-array: copy []
						foreach col arg/2 [
							append color-array compose [
								color-array-box (col)
							]
						]
						apply :set-content [face/names/ca color-array none none arg/3]
					]
				]
			]
			on-get: [
				return switch/default arg [
					value [
						result: copy []
						foreach-face f face/names/ca [
							append result f/facets/bg-color
						]
						result
					]
				][
					none
				]
			]
		]
	]

	tool-button: [

		tags: [internal tab]

		facets: [
			init-size: 100x100
			min-size: 10x10
			bg-color: none
			draw-mode: 'normal
			padding: [0x0 0x0]
			margin: [0x0 0x0]
			text: none
		]

		options: [
			init-size: [pair!]
			text: [string!]
			image: [image!]
		]

		draw: [
			normal: [
				image (viewport-box/center - 12) gob/data/facets/image
			]

			highlight: [
				pen 178.178.178
				grad-pen viewport-box/center (negate viewport-box/center/x ) viewport-box/center/x 70 [230.230.230 210.210.210]
				box 1x1 (viewport-box/bottom-right - 2) 4.0
				image (viewport-box/center - (gob/data/facets/image/size * .5)) gob/data/facets/image
			]

			down: [
				pen 178.178.178
				grad-pen viewport-box/center (negate viewport-box/center/x ) viewport-box/center/x 70 [180.180.180 200.200.200]
				box 1.5x1.5 (viewport-box/bottom-right - 2.5) 4.0
				grad-pen off
				fill-pen off
				pen 148.148.148.191
				box 1x1 (viewport-box/bottom-right - 2) 4.0
				image (viewport-box/center - (gob/data/facets/image/size * .5) + 1) gob/data/facets/image
			]
		]

		actors: [
			on-over: [ ; arg: offset or none
;				either arg [focus face][unfocus]
				set-facet face 'draw-mode either arg [
					'highlight
				][
					'normal
				]
				draw-face face
			]

			on-click: [
				either arg/type = 'down [
					set-facet face 'draw-mode 'down
					draw-face face
				][
					unfocus
					focus face
					do-face face
				]
				true
			]

			on-focus: [ ; arg/1: TRUE for focus, FALSE for unfocus; arg/2 - forced re-focus flag
				set-facet face 'draw-mode either all [arg/1 not arg/2][
					'highlight
				][
					'normal
				]
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

			on-init: [
				face/facets/min-size:
				face/facets/max-size:
				face/facets/init-size: 40x40
			]
		]
	]

	tool-bar: hgroup [

	tags: [compound]
		facets: [
			padding: [0x0 0x0]
			spacing: 3x1
		]
		options: [
			init-hint: [pair!]
			tools-data: [block!]
		]

		content: []

		actors: [
			on-init: [
				blk: copy []

				img: title: action: lay: none

				parse face/facets/tools-data [
					some [
						set img image! opt set title string! opt set action block! (
							append blk compose/deep [
								tool-button (img) (any [title []]) on-action [(action)] options [tool-tip: (any [title "nothing"])]
							]
						)
						| 'layout set lay block! (append blk lay)
						| 'bar (
							append blk [div options [max-size: 3x35 valign: 'middle bg-color: gray]]
						)
						| 'break (
							append blk 'return
						)
					]
				]

				set-content/no-show face blk
			]
		]

	]

]