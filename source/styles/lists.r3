REBOL [
	Title: "REBOL 3 GUI Styles - Lists"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
	Notes: [
	]

	Known-bugs: [
	]

	ToDo: [
	]
]

time: now/time/precise

deltat: func [text /local t][
	print time
	print [text t: (n: now/time/precise) - time]
	time: n
]

stylize [

text-table: htight [

	facets: [

		; style maintance
		names: true
		break-after: 2
		all-over: true ; continuous over events

		; table settings
		filter: make map!	[]	; map of column filters

		atts: context [
			col: make block! 10		; column attributes, order in block is order on display ('index is index in source data)
			row: make map! 100		; row attributes (...)
			cell: []				; cell attributes (...)
		]

		show-header:	true	; is header visible?
		no-edit:		false	; table is read-only (overrides column attributes)
		show-empty:		false	; show indication of empty cells
		row-height: 18

		; colors
		bgd-color:	snow
		text-color:	black
		grid-color:	gray
		highlight-color: 120.120.250.75
		over-color: 220.220.220
		empty-color: 220.220.250

		drawing-block: []
		]

	state: [
		row-offset: 0	; offset for first visible row
		visible-rows: 0	; number of on-screen visible rows
		over: none		; highligted row (mouse or key is over)

		cell: 0x0		; pair! position of active cell (in original data)
		visible: []		; block of indexes of visible rows
		all-rows: []	; block of indexes of all rows
		unordered: []	; block of visible unordered indexes
		show-always: []	; block of indexes of lines that should ignore filter settings
		dirty?: no		; has data changed? if yes, ignore filter settings

		value: none		; selected value (should be same as cell, but also can be integer! for row index only - useful for lists)
	]

	tags: [compound tab eat-tab]

	options: [
		init-size: [pair!]
		labels: [block!]
		table-data: [block!]	; referenced table data
	]

	intern:	[
		process-data: funct [
			face	[object!]
			data	[block! none!]
			/force "Clear state (use with new data)"
		][
			either table: get-facet face 'table [
;				print ["process table..." table]
			][
				unless data [data: copy []]
				index: index? face/state/visible
				id: find face/state/visible to integer! face/state/cell/y
				if id [id: index? id]
				; set default values
				; TODO: optimize and add /force mode
				all-rows: make block! length? data
				repeat i length? data [append all-rows i]
				unless equal? all-rows face/state/all-rows [
					either force [
						; new data, clear sorting and filtering
						face/state/over: none
						face/state/visible: all-rows
						face/state/unordered: all-rows
						face/state/all-rows: all-rows
						set-facet face 'table-data data
						face/state/visible: at face/state/visible index
					][
						; data changed but we don't want to reset sorting and filtering
						get-facet face [sorting:]
						; filter data
						do-actor face 'on-filter-data none	; data changed, update view
						; sort data
						if sorting [do-actor face 'on-sort sorting]
					]

				]
			]
		]

		parse-labels: funct [
			face	[object!]
			dialect	[block! none!]
		][
			get-facet face [atts:]

			; set some values
			cols: make block! 20

			index: 0
 			if empty? dialect [dialect: copy [""]]
			label: col: width: dtype: no-edit: none

			; initialize empty columns
			cols: 0
			parse dialect [some [string! (++ cols) | 1 skip]]
			atts/col: array cols

			parse dialect [
				some [
					(col: width: dtype: no-edit: none)
					set label string!
					any [
						set col issue!
					|	set width integer!
					|	'no-edit (no-edit: true)
					|	set dtype word!	; datatype must be after keywords (or there may be list of supported datatypes)
					] (
						index: index +  1 ; index in displayed table

						; create attributes for col TODO?: change to map! or object! to prevent (possible) problem with duplicates?
						att: reduce [
							'index		either col [to integer! col][index]
							'width		either width [width][150]
							'type		either dtype [dtype]['text]
							'label		label
							'no-edit	no-edit
							'colpos		0		; xpos? x-pos? col-pos?
						]

						; update record in attributes
						col: either col [to integer! col][index]
						atts/col/:index: att
					)
				]
			]

			; process labels - create buttons
			label-block: copy []
			cols: atts/col
			forall cols [
				col: first cols
				lbl: index? cols
				srt-name: to set-word! join 'id lbl
				flt-name: to set-word! join 'f lbl
				repend label-block [
					srt-name 'button 			; sort button
						col/label
						'options compose [
							material: 'aluminum
							bg-color: 200.210.220
							min-size: 50x20
							init-size: (as-pair max 50 col/width - 20 20)
							max-size: (as-pair either last? cols [1000][max 50 col/width - 20] 20)
							text-style: 'sbutton
							states: [none up down]
							state: none
							related: 'on-mutex
						]
						'on-action [
							p: parent-face? parent-face? face
							col: (index? locate-face face) + 1 / 2
							get-facet p [atts:]
							get-facet face [states:]
							if tail? states: next states [states: head states]
							set-facet face 'states states
							state: first states
							set-facet face 'state state
							do-actor p 'on-sort s: reduce [atts/col/:col/index state]
							set-facet p 'sorting s
							do-related face 'on-mutex
							update-face p
						]
						'on-draw [
								; code for drawing sort arrow indication
								if arg [
									append arg [reset-matrix fill-pen black line-width 1]
									append arg switch get-facet face 'state [
										up		[
											[polygon 7x3 10x8 4x8]
										]
										down	[
											[polygon 7x8 10x3 4x3]
										]
										none	[
											[]
										]
									]
								]
								; call for original
								do-actor/style face 'on-draw arg 'button
								arg
						]
						'on-focus [
							do-actor parent-face? parent-face? face 'on-focus arg
						]
						'on-mutex [
							unless equal? face arg [
								get-facet face [states:]
								; reset arrow
								set-facet face 'states states: head states
								set-facet face 'state first states
							]
						]
						'on-set-arrow [ ; TODO: move to ON-SET? (probably not?)
							do-related face 'on-mutex
						]
					flt-name 'drop-arrow 		; filter drop-down
						'on-click [
							p: parent-face? parent-face? face
							data: copy ["<All>" "<Empty>" "<Not empty>" "<=======>"]
							col: (index? locate-face face) / 2
							; filter is not dirty anymore
							p/state/dirty?: no
							p/state/show-always: clear []
							; convert from visible index to real index
							get-facet p [atts:]
							append data sort unique do-actor p 'on-get-col reduce [atts/col/:col/index p/state/visible]
							; add invisible lines to filer too
							invisible: difference unique p/state/all-rows unique p/state/visible
							rest: do-actor p 'on-get-col reduce [atts/col/:col/index invisible]
							unless zero? length? rest [
								append data "<=======>"
								append data sort unique rest
							]
							forall data [if none? data/1 [remove data]]
							; set dropdown menu data and store them for later use
							set-face/field face data 'data
							set-facet p 'col-filters data
							; call original actor to open dropdown menu
							do-actor/style face 'on-click arg 'drop-arrow
						]
						'on-action [
							if arg [
								p: parent-face? parent-face? face
								col: (index? locate-face face) / 2
								data: get-facet p 'col-filters
								get-facet p [atts:]
								value: data/:arg
								flt: switch/default value [ ; todo: move filters to some list?
									"<All>" 		[[true]]
									"<empty>" 		[[any [none? value value = "" all [block? value empty? value]]]]
									"<not empty>" 	[[any [value <> "" all [block? value not empty? value]]]]
									"<=======>" 	[none]	; TODO: this may not work as expected
								][
									compose [value = (value)] ; 3 is length of predefined filters (see above)
								]
								if flt [
									; ignore click on separator
									do-actor p 'on-filter-data reduce [atts/col/:col/index flt]
									set-facet face 'arrow-color either any [[true] = flt] [black][red]
								]
								draw-face p
								; NOTE: this doesn't work as it's not possible to focus another window from R3 yet (only manually)
								focus p/names/tbl
							]
						]
				]
			]
			set-content/no-show face/names/btr label-block
		]

		layout-block: [
			btr: htight [] options [names: true]
			pad: pad options [max-size: 16x16]
			return
			tbl: drawing []
				options		[all-over: true dirty-focus?: false]
				on-over		[
					p: parent-face? face
					either arg [
						o: do-actor p 'on-find-cell arg/y
						p/state/cell/x: do-actor p 'on-find-col arg/x
						if o <> p/state/over [
							p/state/over: o
							do-actor p 'on-draw none
						]
					][
						p/state/over: none
						do-actor p 'on-draw none
					]

				]
				on-scroll-event	[
					p: parent-face? face
					do-actor p 'on-scroll-line negate arg/offset/y / 3
					draw-face p
				]
				on-click	[
					p: parent-face? face
					if 'up = arg/type [
						focus p
						; get (absolute) index of current cell
						if line: do-actor p 'on-find-cell arg/offset/y
						[
							; highlight selected cell
							p/state/cell/y: line
							switch/default type?/word p/state/value [
								integer!	[p/state/value: line]
								pair!		[p/state/value/y: line]
							][p/state/value: p/state/cell]

							draw-face p
							do-actor p 'on-set-value p/state/cell
							do-actor p 'on-action p/state/value
						]
					]
					true ;don't do unfocus
				]
			scr: scroller on-action [
				p: parent-face? face
				id: to integer! (length? head p/state/visible) - p/state/visible-rows * arg
				p/state/visible: skip head p/state/visible id
				do-actor p 'on-draw none
			]
			editor: hgroup 200.200.200 [] options [
				names: true
				box-model: 'tight
			] on-key [
				; custom action for CTRL+arrow - editor navigation
				if arg/type = 'key [
					get-facet face [cell:] ; get from 'editor face
					text-table: parent-face? face
					get-facet text-table [atts:]
					cols: atts/col
					col: 0
					foreach c cols [
						if cols/:c/index = cell/x [col: c]
					]
					switch arg/key [
						up [
							cell/y: first back find text-table/state/visible cell/y
							row: to integer! cell/y

							; check if scrolling is needed
							unless find text-table/state/visible row [
								text-table/state/visible: back text-table/state/visible
							]
						]
						down [
							if new-pos: select text-table/state/visible cell/y [cell/y: new-pos]
							row: to integer! cell/y

							; check if scrolling is needed
							pos: index? find text-table/state/visible row
							if pos > text-table/state/visible-rows [
								text-table/state/visible: next text-table/state/visible
							]
						]
						left [
							col: max 1 col - 1
						]
						right [
							col: min length? cols col + 1
						]
					]
					; store value, as if enter was pressed

					inner-editor: first values-of face/names ; inner editor must be always first named face in editor (or TODO: add some indication, of what is inner editor)
					do-face inner-editor
					do-actor text-table 'on-enter get-face inner-editor

					; TODO: solve the confusion between cell and value
					text-table/state/value: text-table/state/cell: as-pair cols/:col/index cell/y
					do-actor text-table 'on-place-editor reduce [face 'cell]
					cell-type: get-face/field text-table 'cell-type
					text-table/intern/open-editor text-table cell-type
				]
			]
		]

		editors: [
			text [
				field: field ""
					on-focus [
						do-actor/style face 'on-focus arg 'field					
						if all [arg/1 arg/2] [
							;if editor is refocused make sure it is visible
							editor: parent-face? face
							if 'ignored = show? editor [
								show-face editor 'fixed
							]
						]
						unless arg/1 [ ;don't focus next possible element
							unfocus/self
							do-face face
							'stop-event
						]
					]
					on-key [
						; process custom key actions or call standard actor
						case [
; commented out non-working ctrl+arrows custom code --Cyphre
;							all [
;								find arg/flags 'control
;								find [left right up down] arg/key
;							] (do-actor parent-face? face 'on-key arg)
							; TODO: this is called after ON-ACTION is called, maybe ON-ACTION is enough?
							all [
								arg/type = 'key ;-up - key-up is not received
								arg/key = #"^M"
							] (
								do-actor/style face 'on-key arg 'field
								do-actor parent-face? parent-face? face 'on-enter get-face face
							)
							true (do-actor/style face 'on-key arg 'field)
						]

					]
					on-action	[
						editor: parent-face? face
						text-table: parent-face? editor
						show-face/no-show editor 'ignored
						cell: get-facet editor 'cell
						row: to integer! second cell
						col: to integer! first cell
						data: get-facet text-table 'table-data
						data/:row/:col: arg
						draw-face text-table
						focus text-table
						do-actor text-table 'on-edit-action cell
					]
			]
			tags [
				pad 10x10
				head-bar "TAG editor"
				pad
				button 24x24 "X" options [max-size: 24x24] on-action [
					editor: parent-face? face
					text-table: parent-face? editor
					show-face/no-show editor 'ignored
					cell: get-facet editor 'cell
					row: to integer! second cell
					col: to integer! first cell

					data: get-facet text-table 'table-data
					data/:row/:col: get-face editor/names/tag-area
					draw-face text-table
				]
				return
				tag-area: tag-area on-action [
					print get-face faces
				]
			]
		]

		open-handlers: reduce [
			'text	funct [face][
				t: now/time/precise
				editor: face/names/editor
				field: editor/names/field
				do-actor face 'on-place-editor reduce [editor 'cell]
				show-face editor 'fixed
				set-face field get-face/field face 'cell
				focus field
			]
			'tags	funct [face][
				editor: face/names/editor
				tag-area: editor/names/tag-area
				do-actor face 'on-place-editor reduce [editor 'column]
				show-face editor 'fixed		; make field visible
				cell: get-face/field face 'cell
				set-face tag-area cell
				focus tag-area
			]
		]

		open-editor: funct [face name][
			; get editor layout
			editor: select face/intern/editors name
			; fallback for unsupported types
			unless editor [
				name: 'text
				editor: select face/intern/editors name
			]
			set-content face/names/editor editor
			open-func: select face/intern/open-handlers name
			open-func face
		]

	; attributes management

		set-att: func [
			face [object!]
			type [word!]	"COL, ROW, or CELL"
			name [word!]	"Attribute name"
			value [any-type!]	"Attribute value"
		][
			atts: get-facet face 'atts

			either 'cell = type [
				; CELL uses BLOCK!, needs special treatment
				either find atts/:type name [
					atts/:type/:name: value
				][
					repend atts/:type [name value]
				]
			][
				atts/:type/:name: value
			]
		]


	]

	actors: [

		on-init: [
			set-facet face 'cell-text copy []
			style: face-font? face
			foreach field [font para anti-alias] [
				if style/:field [repend face/facets/cell-text [field any [select face field style/:field]]]
			]
		
			; clear attributes
			set-facet face 'atts context [
				col: make block! 10	;
				row: make map! 100	;
				cell: []			; block, as map! cannot use pair! as index
			]

			; set content and table size
			set-content/no-show face face/intern/layout-block
			; set table data
			set-face/field/no-show face get-facet face 'labels 'labels
			data: get-facet face 'table-data
			unless data [data: copy []]
			set-face/field/no-show face data 'data


			if get-facet face 'table [do-actor face 'on-init-table none]

		]

		on-set: [
			switch arg/1 [
				value	[
					if arg/2 [
						face/state/value: as-pair 1
						face/state/cell/y: arg/2
					]
				]
				data	[
					set-facet face 'table-data arg/2
					face/intern/process-data/force face arg/2
				]
				labels	[face/intern/parse-labels face arg/2]
				state	[
					state: arg/2
					set-face/field face state/labels 'labels
					set-face/field face state/table-data 'data
					face/state: copy state/state
					apply :update-face [face arg/3]
					; force resize to update table header
					do-actor face 'on-resize face/gob/size
				]
				filter [
					; set filters
					set-facet face 'filter arg/2
					; set arrow indicators
					foreach filter arg/2 [
						arrow: get in face/names/btr/names to word! join 'f filter
						set-facet arrow 'arrow-color red
					]
					; clear list of rows to force new filtering
					do-actor face 'on-filter-data none
				;	clear face/state/all-rows
				]
				sort [
					; set sorting
					set-facet face 'sorting arg/2
					do-actor face 'on-sort arg/2
					; set arrow indicator
					button: get in face/names/btr/names to word! join 'id arg/2/1
					do-actor button 'on-set-arrow arg/2/2
					set-facet button 'state arg/2/2
				]
			]
		]

		on-get: [
			value: face/state/value
			get-facet face [table-data:]
			switch arg [
				value		[value]
				data		[get-facet face 'table-data]
				table		[get-facet face 'table-data]				; should be supported?
				row			[
					if pair? value [row: to integer! value/y]
					table-data/:row
				]
				col			[do-actor face 'on-get-col reduce [to integer! face/state/cell/x face/state/all-rows]]
				column		[
					c: to integer! face/state/cell/x
					if zero? c [c: 1]
					c
				] ; or column-id ?
				cell		[
					row: either pair? value [to integer! value/y][value]
					pick table-data/:row to integer! face/state/cell/x
				]
				cell-type	[	; col-type?
					col: to integer! face/state/cell/x
					face/facets/atts/col/:col/type
				]
				filter		[get-facet face 'filter]
				visible		[do-actor face 'on-get-view face/state/visible]
				record		[do-actor face 'on-get-record to integer! face/state/cell/y]
				over		[do-actor face 'on-get-record face/state/over]
				labels		[
					get-facet face [atts:]
					collect [
						foreach col atts/col [
							keep reduce [col/label to issue! to string! index? find atts/col col col/width to word! to lit-word! col/type]
						]
					]
				]
				state		[	; get run-time state
					context [
						labels: get-face/field face 'labels
						filters: get-face/field face 'filters
						table-data: get-facet face 'table-data
						state: face/state
					]
				]
			]
		]

		on-draw: [
			; get some values
			tbl: face/names/tbl
			scr: face/names/scr
			get-facet face [highlight-color: over-color: focus-color: grid-color: row-height: table-data: labels: atts: drawing-block]
			tbl-size: set-facet face 'tbl-size face/names/tbl/gob/size
			face/intern/process-data face table-data
			drawing-block: clear head drawing-block	; drawing block is facet so it's accessible outside of on-draw
			
			if tbl-size [
				do-actor face 'on-draw-grid none
				either table: get-facet face 'table [
					; DB Handler
					repeat i face/state/visible-rows [
						; get row and draw each cell
						row: do-actor face 'on-get-record face/state/visible/:i
						forall row [
							do-actor face 'on-draw-cell reduce [as-pair index? row i row/1]
						]
					]

				][
					visible: face/state/visible
					rows: to integer! tbl-size/y / face/facets/row-height
					; update slider
					set-face/field/no-show face/names/scr to percent! rows / max 1 length? head visible 'delta
					; draw text
					repeat y rows [
						if visible/:y [do-actor face 'on-draw-row y]
					]
				]
				set-face face/names/tbl drawing-block
			]
		]

		on-draw-grid: [
			get-facet face [tbl-size: highlight-color: over-color: focus-color: grid-color: row-height: atts: table-data: labels: drawing-block:]

			rows: to integer! tbl-size/y / face/facets/row-height
			if rows > length? face/state/visible [
				face/state/visible: skip tail face/state/visible negate 1 + rows
			]
			offset: index? face/state/visible
			; draw background and main box

			; set right witdh (with atts)
			w: 0	; total width

			foreach col atts/col [w: w + col/width]

			last-col: length? atts/col

			if tbl-size/x <> w [
				atts/col/:last-col/width: atts/col/:last-col/width + (tbl-size/x - w)
				w: tbl-size/x
			]

			tbl-size/x: w
			tbl-size/y: rows * row-height

			repend drawing-block [
				'pen face/facets/grid-color
				'fill-pen face/facets/bgd-color
				'box 0x0 as-pair tbl-size/x - 1 rows * row-height - 1
			]

			unless get-facet face 'show-header [
				show-face/no-show face/names/btr 'ignored
				show-face/no-show face/names/pad 'ignored
			]

			ypos: 0

			; draw over highlight
			all [
				face/state/over
				y: find face/state/visible to integer! face/state/over
				y: index? y
				y: y - index? face/state/visible
				y < rows
				repend drawing-block [
					'fill-pen over-color
					'box as-pair 0 y * row-height as-pair tbl-size/x - 1 y + 1 * row-height
				]
			]
			; draw selected highlight
			all [
				face/state/visible
				y: find face/state/visible to integer! face/state/cell/y
				ypos: index? y
				not zero? ypos
				y: ypos - index? face/state/visible
				y < rows
				repend drawing-block [
					'fill-pen highlight-color
					'pen focus-color
					'line-width 2
					'box as-pair 0 y * row-height as-pair tbl-size/x - 1 y + 1 * row-height 1
					'pen grid-color
					'line-width 1
				]
			]
			; draw highlight when no selected value (focus frame)
			all [
				equal? guie/focal-face face
				none? face/state/value
				repend drawing-block [
					'pen focus-color
					'fill-pen none
					'line-width 2
					'box 0x0 tbl-size - 1
					'pen grid-color
					'line-width 1
				]
			]
			; draw horizontal lines
			x: y: 0
			repend drawing-block ['pen grid-color]
			; limit number of rows for small datasets (currently disabled)
			rows: to integer! tbl-size/y / row-height
			loop 1 + rows [ ; 'rows is number of visible lines
				repend drawing-block ['line as-pair x y as-pair tbl-size/x y]
				y: y + face/facets/row-height
			]
			face/state/visible-rows: rows: to integer! rows

			; draw vertical lines
			tbl-size/y: row-height * rows
			xpos: 0

			repend drawing-block ['line 0x0 as-pair 0 tbl-size/y]

			foreach col atts/col [
				xpos: xpos + col/width
				repend drawing-block ['line as-pair xpos 0 as-pair xpos tbl-size/y]
			]

		]

		on-draw-row: [
			unless none? line: pick get-facet face 'table-data face/state/visible/:arg [
				get-facet face [atts:]
				cols: atts/col
				forall cols [
					col: first cols
					do-actor face 'on-draw-cell reduce [as-pair index? cols arg pick line col/index]
				]
			]
		]

		on-draw-cell: [	; ARG: [pos text]
			get-facet face [drawing-block: row-height: tbl-size: empty-color: atts:]
			c: to integer! arg/1/1
			y: to integer! arg/1/2

			either all [get-facet face 'show-empty any [
				none? arg/2
			]] [
				;repend drawing-block [
				append drawing-block reduce [
					'clip
						as-pair 0 y - 1 * face/facets/row-height
						as-pair 1000 y - 1 * face/facets/row-height + row-height
					'fill-pen empty-color
					'box
						as-pair atts/col/:c/colpos + 2 y - 1 * face/facets/row-height + 2
						as-pair atts/col/:c/colpos + atts/col/:c/width - 3 y - 1 * face/facets/row-height + row-height - 2
						10
				]
			] [
				if none? arg/2 [arg/2: ""]
				if find atts/col/1 'colpos [
					this-pos: atts/col/:c/colpos
					next-pos: atts/col/:c/colpos + atts/col/:c/width
;					w: next-pos - this-pos - 10
					origin: 1 + as-pair this-pos y - 1 * face/facets/row-height
					end: as-pair next-pos - 10 y - 1 * face/facets/row-height + row-height
				
					switch atts/col/:c/type [
						text [
							; process text
							text-block: append copy face/facets/cell-text either block? arg/2 [
								t: copy {}
								foreach w arg/2 [repend t [w ", "]]
								remove/part back back tail t 2
								reduce [t]
							][
								reduce [form arg/2]
							]

							repend drawing-block [
								'clip
									origin
									end
								'text text-block
									origin
							]
						]
						draw [
							append drawing-block compose/deep [
								clip
									(origin)
									(end)
								push [
									fill-pen off
									pen off
									translate
										(origin)
										(arg/2)
								]
							]
						]
					]
				]

;				s: size-text make gob! reduce/no-set [text: first t size: 10000x20]
;				if s/x > w [
;					repend drawing-block ['clip 0x0 tbl-size 'text ["..."] as-pair colpos/(c + 1) - 15 y - 1 * face/facets/row-height]
;				]
			]
		]

		on-resize: [
			get-facet face [atts: tbl-size:]
			cols: atts/col

			; get columns postions, fix size of last column
			xpos: 0
			foreach col cols [
				col/colpos: xpos
				xpos: xpos + col/width
			]

			last-id: length? cols ; CHECK

			; resize last column
			cols/:last-id/width: tbl-size/x - cols/:last-id/colpos
			do-actor/style face 'on-resize arg 'htight
		]

		on-focus: [
			; add highlight when missing (improves keyboard navigation) NOTE: add also unhighlight, when unfocusing?
			unless face/state/over [face/state/over: first face/state/visible]
			set-facet face 'focus-color either arg/1 [guie/colors/focus][255.255.255.0]
			draw-face face
		]

		on-key: [
			get-facet face [table-data: row-height: atts:]
			unless face/state/over [face/state/over: 1]

			if arg/type = 'key [
				switch arg/key [
					up		[
						if find arg/flags 'shift [
							; move line
							move at table-data face/state/over -1
						]
						; move cursor
						do-actor face 'on-scroll-line -1
					]
					down	[
						if find arg/flags 'shift [
							; move line
							move at table-data face/state/over 1
						]
						; move cursor
						do-actor face 'on-scroll-line 1
					]
					page-up [
						do-actor face 'on-scroll-line negate face/state/visible-rows
					]
					page-down [
						do-actor face 'on-scroll-line face/state/visible-rows
					]
					#"^M"	[	; enter
						face/state/cell/y: face/state/over
						do-actor face 'on-set-value face/state/cell
						do-actor face 'on-action face/state/value
					]
					#"^H"	[	; backspace
						do-actor face 'on-remove-row face/state/over
					]
					#" "	[
						face/state/cell/y: face/state/over
						do-actor face 'on-set-value face/state/cell
						do-actor face 'on-action face/state/value
					]
					#"+"	[
						either face/state/over [
							insert/only pos: at table-data face/state/over array length? atts/col
						][
							append/only pos: table-data array length? atts/col
						]
						; add new line to all-rows to reflect changes
						append face/state/all-rows 1 + last face/state/all-rows
						face/state/dirty?: yes				; data changed, ignore filter settings
						append face/state/show-always index? pos
						pos: index? face/state/visible
						do-actor face 'on-filter-data none	; data changed, update view
						face/state/visible: skip head face/state/visible pos - 1	; view is on beginning, skip back to current position
					]
					#"-"	[
						do-actor face 'on-remove-row to integer! face/state/value/y
					]
					#"e"	[
						do-actor face 'on-open-editor either find arg/flags 'shift ['quick-form][none]
					]
				]
				draw-face face
			]
			arg
		]

; -- support actors

		on-remove-row: [	; arg: row to remove (face/state/over)
			if over: find face/state/visible arg [
				remove pos: at face/facets/table-data arg
				; move cursor back when on last line
				if tail? next over [over: back over]
				face/state/over: first over
				; remove last line from all-rows to reflect changes
				remove back tail face/state/all-rows
				pos: index? face/state/visible
				do-actor face 'on-filter-data none ; data changed, update view
				face/state/visible: skip head face/state/visible pos - 1	; view is on beginning, skip back to current position
			]
		]

		on-open-editor: [
			; ARG: editor type - NONE (standard editor based on datatypes), QUICK-FORM (quick form editor - edit all fields in one pane)

			get-facet face [atts:]
			cols: atts/col
			col: case [
				none? face/state/value (1)
				integer? face/state/value (1)
				pair? face/state/value (to integer! face/state/value/x)
			]
			forall cols [
				c: first cols
				if c/index = col [col: index? cols break]
			]

			unless any [
				not face/state/value
				get-facet face 'no-edit
				atts/col/:col/no-edit
			] [
				; some preparation
				editor: face/names/editor
				show-face editor 'visible
				get-facet face [table-data:]

				; open editor
				either 'quick-form = arg [
					; open quick form editor
					row: to integer! face/state/value/y

					set-facet editor 'row row

					lay: compose [
						title "Quick form editor"
						return
						head-bar (join "row: " row)
						return
						button "Save" on-action [
							editor: parent-face? face
							text-table: parent-face? editor
							get-facet text-table [table-data: atts:]
							editors: editor/names/editors
							values: get-panel editors
							row: get-facet editor 'row
							row: table-data/:row

							; store data in table
							cols: atts/col
							foreach col cols [
								c: cols/:col/index
								row/:c: values/:col
							]

							; update GUI
							clear-content editor
							show-face editor 'ignored
							draw-face text-table
						]
						button "Cancel"
						editors: hpanel 2
					]
					editors: clear []

					cols: atts/col
					foreach col cols [
						c: col/index
						value: table-data/:row/:c
						default-editor: either col/no-edit ['head-bar]['field]

						inner-editor: switch/default col/type [
							tags [
								reduce ['tag-area value]
							]
						][
							reduce [default-editor form value]
						]

						; TODO: better conversion from label to name (or use just field1, field2... ?)
						name: copy col/label
						name: to set-word! lowercase name

						append editors compose [
							label (col/label) (name) (inner-editor)
						]
					]

					append/only lay editors
					append lay [options [names: true]]

					set-content face/names/editor lay

					do-actor face 'on-place-editor reduce [editor 'table]
					show-face editor 'fixed		; make field visible
					faces: faces? face/names/editor/names/editors
					focus second faces
				][
					; open custom type editor
					col: get-face/field face 'column
					type: atts/col/:col/type
					face/intern/open-editor face type
				]
			]
		]

		on-place-editor: [
			editor: arg/1
			placement: arg/2
			get-facet face [table-data: row-height: atts:]

			; check if any cell is selected. If not, autoselect first cell
			if 0x0 = face/state/cell [
				face/state/cell: 1x1
				either 1 = length? atts/col [
					face/state/value: 1
				][
					face/state/value: 1x1
				]
			]

			xpos: x: ix: 0
			cols: atts/col
			foreach col cols [
				x: col/width
				if col/index = face/state/cell/x [ix: col break]
				xpos: xpos + x
			]
			col: to integer! face/state/cell/x
			row: to integer! face/state/cell/y		; index in p/state/visible

			r: 1 + (index? find face/state/visible row) - index? face/state/visible	; index in visible view
			set-facet editor 'cell face/state/cell

			switch placement [
				cell [
					size: as-pair x 24
					editor/gob/offset: as-pair xpos r * row-height
					; TODO: offset change for missing header is hardcoded! fix it!
					unless get-facet face 'show-header [editor/gob/offset/y: editor/gob/offset/y - 22]
				]
				column [
					labels-height: 21 ; TODO: fix hardcoded offset (height of label buttons)
					size: as-pair x face/facets/gob-size/y - labels-height
					editor/gob/offset: as-pair xpos labels-height
				]
				table [
					size: face/facets/gob-size - 0x40
					editor/gob/offset: 0x0
				]
			]
			set-facet editor 'min-size size
			set-facet editor 'max-size size
			show-face/no-show editor 'fixed				; make field visible
			do-actor editor 'on-resize size
			draw-face editor
		]

		on-find-cell: [	; arg: y position
			"Return position of current line in original data"
			row-offset: 1 + to integer! arg / get-facet face 'row-height
			; if mouse is positioned on empty line, select last line
			if row-offset > length? face/state/visible [row-offset: length? face/state/visible]
			either table: get-facet face 'table [
				; DB-HANDLER
				row-offset
			][
				face/state/visible/:row-offset
			]
		]

		on-find-col: [	; arg: mouse x-pos
			get-facet face [atts:]
			total: 0
			idx: 0
			cols: atts/col
			foreach col cols [
				idx: idx + 1
				total: total + col/width
				if total > arg [
					total: col/index
					break
				]
			]
			total
		]

		on-sort: [	; arg (col dir) ; TODO: support NONE (no sorting or do not resort)
			visible: face/state/visible
			col: do-actor face 'on-get-col reduce [arg/1 visible]
			data: make block! 2 * length? visible
			foreach id visible [
				repend data [col/1 id]
				col: next col
			]
			face/state/visible: switch/default arg/2 [
				up		[
					sort/skip data 2
					forall data [remove data]
					data
				]
				down	[
					sort/skip/reverse data 2
					forall data [remove data]
					data
				]
			][face/state/unordered]
		]

		on-get-col: [	; arg: [(real) column index , block of visible indexes]
			; NOTE: if original has three columns that are arranged as [1 3 2] and user clicks on third visible column, it's index here is 2
			id: arg/1
			visible: arg/2
			data: get-facet face 'table-data
			out: make block! length? visible
			foreach row visible [
				append out data/:row/:id
			]
			out
		]

		on-filter-data: [	; arg: [column filter]
							; arg: none ; do not set filter, just filter data
							; TODO: or block of those blocks

			get-facet face [table-data: filter: atts:]
			out: make block! length? table-data

			if arg [
				col: arg/1
				flt: arg/2
				filter/:col: flt
			]

			; filter data
			forall table-data [
				pass?: true
				foreach f filter [
					value: table-data/1/:f
					pass?: pass? and true? do bind filter/:f 'value
				]
				if any [
					pass?
					all [face/state/dirty? find face/state/show-always index? table-data]
				][append out index? table-data]
			]

			view: do-actor face 'on-get-flat-view out
			face/state/unordered: out
			face/state/visible: out
		]

		; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		; TODO: check if flat block is needed, or block of block can be used in every case!
		; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		on-get-flat-view: [	; arg: block of indexes - return filtered view of table
			out: make block! length? arg
			foreach id arg [
				append out do-actor face 'on-get-record id
			]
			out
		]

		on-get-view: [	; arg: block of indexes - return filtered view of table
			out: make block! length? arg
			foreach id arg [
				unless none? (tmp: do-actor face 'on-get-record id) [append/only out tmp]
			]
			out
		]

		on-scroll-line: [	; arg: nr of lines to scroll (positive: down, negative: up)
			; if there's no 'over' row, move 'over' to first visible item
			either face/state/over [
				; find new over position
				v: find head face/state/visible face/state/over

				if v [
					v: skip v arg
					if tail? v [v: back v]
					face/state/over: first v
					face/state/visible: skip v negate to integer! face/state/visible-rows / 2
				]
				;
				while [
					all [
						face/state/visible-rows < length? head face/state/visible
						face/state/visible-rows > length? face/state/visible
					]
				][
					face/state/visible: back face/state/visible
				]
			][
				face/state/over: first face/state/visible
			]
			; set scroller
			set-face/no-show face/names/scr min 100% to percent! (-1 + index? face/state/visible) / max 1 ((length? head face/state/visible) - face/state/visible-rows)

			; scrolling causes editor to close
			editor: face/names/editor
			unless 0x-1 = editor/gob/size [	; NOTE: 0x-1 is IGNORED face. There better should be some facet to get this state.
				; code for closing (replacement for scrolling)
				show-face editor 'ignored
			]
		]

		on-get-record: [	; arg: rec-id
			; NOTE: should also support pair! id?
			; TODO: add support for db access

			i: arg

			either table: get-facet face 'table [

				get-facet face [labels:]

				; DB handler
				db-handler/rec-id: i
				db-handler/do-act 'set-id

				label-map: array length? labels
				foreach l labels [
					label-map/:l: to word! labels/:l
				]

				rec: db-handler/do-act 'get-record

				row: array length? labels
				foreach [key value] rec [
					if i: find label-map key [
						i: index? i
						row/:i: value
					]
				]

				row

			][
				; direct access
				face/facets/table-data/:arg
			]
		]

		on-set-value: [	; arg: cell
			"This actor will set right value to face/state/value"
			; This value is different in text-list and text-table
			face/state/value: arg
		]

		on-init-table: [
			; DB HANDLER
			; get and set basic values when using table
			if table: get-facet face 'table [
				db-handler/table: table
				all-rows: db-handler/do-act 'get-keys
				face/state/visible: all-rows
				face/state/unordered: all-rows
				face/state/all-rows: all-rows
			]
		]

		on-enter: [ ; actor is called when user enters a value in GUI
			; just a placeholder for custom ON-ENTER actor
		]

	]
]

; table variations

text-list: text-table [

	facets: [
		show-header: false
	]

	options: [
		init-size: [pair!]
		list-label: [string!]
		list-data: [block!]
	]

	actors: [

		on-init: [
			data: copy []
			foreach item get-facet face 'list-data [append/only data reduce [item]]
			set-facet face 'table-data data
			do-actor/style face 'on-init arg 'text-table
		]

		on-set: [
			switch/default arg/1 [
				labels [
					unless lb: arg/2 [lb: ""]
					do-actor/style face 'on-set reduce ['labels append clear [] lb] 'text-table
				]
				data [
					data: copy []
					foreach item arg/2 [append/only data reduce [item]]
					do-actor/style face 'on-set reduce ['data data] 'text-table
				]
			][
				do-actor/style face 'on-set arg 'text-table
			]
		]

		on-get: [
			value: face/state/value
			get-facet face [table-data:]
			switch arg [
				value		[either pair? value [to integer! value/y][value]]
				table-data	[table-data]
				data		[
					val: collect [
						foreach item table-data [keep first item]
					]
					if none? val [val: copy []]
					val
				]
				text		[either index: get-face face [pick table-data index][copy ""] ]
			]
		]

		on-set-value: [	; arg: cell
			"This actor will set right value to face/state/value"
			; This value is different in text-list and text-table
			face/state/value: to integer! arg/y
		]

	]

]

file-list: text-list [ ; better redo as compound style?

	facets: [
		show-header: true
	]

	options: [
		list-path: [file! string!]
	]

	actors: [

		on-init: [
			path: get-facet face 'list-path
			set-face/no-show face path

			do-actor/style face 'on-init arg 'text-table
		]

		on-set: [
			switch/default arg/1 [
				value [
					files: read arg/2
					set-face/field/no-show face files 'data
				]
				label [
					l: arg/2
					do-actor/style face 'on-set reduce ['labels append clear [] l] 'text-table
				]
				data [
					data: copy []
					foreach item arg/2 [append/only data reduce [item]]
					do-actor/style face 'on-set reduce ['data data] 'text-table
				]
			][
				do-actor/style face 'on-set arg 'text-table
			]
		]

	]
]



; - end of stylize
]


set-face-key: funct [
	"Set action when key is pressed in face"
	face	[object!]
	key		[char! word! block!]
	action	[block!]
][
	if block? key [key: catenate key "-"]
	key-acts: get-facet face 'key-acts
	key-acts/:key: action
]
