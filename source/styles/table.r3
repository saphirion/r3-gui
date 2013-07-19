REBOL [
	Title: "REBOL 3 GUI Styles - Primary types of tables,grids etc."
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

;-- Internal Style Functions -------------------------------------------------- 

;-- Styles Definitions -------------------------------------------------- 

stylize [
	table-panel: hpanel [
		options: [
			panel-id: [integer!]
			content: [block!]
			bg-color: [tuple!]
		]
		facets: [
			break-after: 1
			margin: [0x0 0x0]
			padding: [0x0 0x0]
			spacing: 0x0
			border-size: [0x0 0x0]
			bg-color: none
			panel-id: none
		]
		draw: []
	]

	table-plane: vpanel [
		options: [
			bg-color: [tuple!]
		]
		
		facets: [
			margin: [0x0 0x0]
			padding: [0x0 0x0]
			spacing: 0x0
			border-size: [1x1 1x1]
			bg-color: none
			resize?: false
		]
		
		draw: []
	]

	table-viewport: hpanel [
		options: [
			bg-color: [tuple!]
		]
		facets: [
			break-after: 1
			margin: [0x0 0x0]
			padding: [0x0 0x0]
			spacing: 0x0
			border-size: [0x0 0x0]
			bg-color: none
			border-color: none
			names: true
			
			rows-per-panel: 50
			total-rows: 0
			rows-data: none
			visible-panels: none
			last-scr: -1
		]
		content: [
			pad options [max-size: 642x882 min-size: 420x340]
			tp: table-plane options [show?: 'fixed bg-color: none]
		]
		
		actors: [
			on-init: [
				face/facets/visible-panels: copy []
			]
			
;			on-attach: [
;				extend-face face 'attached arg
;			]
			
			on-update-panels: [
				f: face/facets
				tp: face/names/tp
				vscr: face/attached/1
				upd?: false
				
				row-beg: f/total-rows * vscr/state/value
				
				panel-id: to-integer row-beg / f/rows-per-panel

				unless f/visible-panels/1 = panel-id [
					clear-panel-content/no-show tp
					clear f/visible-panels
				]
				
				forever [
					unless find f/visible-panels panel-id [
						lay: reduce ['table-panel either odd? panel-id [red][white] panel-id copy []]
						repeat n f/rows-per-panel [
							row-data: pick f/rows-data panel-id * f/rows-per-panel + n
							unless row-data [break]
							append last lay compose/deep [
								text (row-data/2) (as-pair 140 row-data/3) options [min-size: (as-pair 100 row-data/3)]; material: 'base]							
							]
						]
						if empty? last lay [
							break
						]
						append f/visible-panels panel-id
;						print ["append" panel-id now/time/precise]
						append-panel-content tp lay
						upd?: true
;						print ["append END" now/time/precise]
					]
					h: tp/gob/size/y + tp/gob/offset/y

					if h >= f/gob-size/y [break]
					panel-id: panel-id + 1
				]

				pnl: first faces? tp
				tp/gob/offset/y: negate (row-beg // f/rows-per-panel) * (pnl/gob/size/y / f/rows-per-panel)
				;- (/gob-size/y * vscr/state/value)

				if tp/gob/offset/y = f/last-scr [exit]

				f/last-scr: tp/gob/offset/y
				apply :show-later [tp not upd?]
			]
			
			on-scroll: [
				if face/facets/rows-data [
					pf: parent-face? face
					either arg = pf/names/vscr [
						do-actor face 'on-update-panels none
					][
						tp/gob/offset/x: negate tp/gob/size/x - face/facets/gob-size/x * arg/state/value
						tp/show-only?: true
						show-later face/names/tp
					]
				]
			]
		]
		
		draw: []
	]
	
	table: hpanel [
		options: [
			data: [block!]
		]
		
		facets: [
			break-after: 2
			bg-color: white
			names: true
		]

		content: [
			tv: table-viewport options [bg-color: none] vscr: scroller
			hscr: scroller
		]
		
		actors: [
			on-init: [
				if data: face/facets/data [
					tv/facets/total-rows: -1 + length? data
					tv/facets/rows-data: data
					set-face tv/attached/1 probe reduce [0% 10%]
					set-face tv/attached/2 probe reduce [0% 30%]
				]
			]
		]
		
		draw: []
	]

]