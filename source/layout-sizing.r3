REBOL [
	Title: "R3 GUI - Layout: sizing"
	Purpose: {
		Scans a layout and calculates the sizes and positions of its contents.
	}
	Copyright: {2010 2011 2012 2013 Saphirion AG, Zug, Switzerland}
	License: http://www.apache.org/licenses/LICENSE-2.0
	Version: "$Id: layout-sizing.r3 2329 2011-04-12 11:57:27Z ladislav $"
]

make object! [
	line-proto: make object! [
		start:
		length:
		net-length:
		init-size:
		min-size:
		max-size:
		offset:
		size:
		minification-index:
		magnification-index:
		none
		align: 'left
		valign: 'top
		init-ratio: none
	]

	max-coord: guie/max-coord
	
	add-max: func  [a b] [
		either any [max-coord = a max-coord = b] [max-coord] [a + b]
	]

	round-to: func [
		value [number!] {the value to round}
		scale [number!] {the scale to round to, assumed to be positive}
		/local r
	] [
		r: value // scale
		either negative? r [
			if scale + r < negate r [r: scale + r]
		] [
			if scale - r < r [r: r - scale]
		]
		value - r
	]
	
	group-modes: make object! [
		horizontal: [
			x ; the longitudinal coordinate
			y ; the transversal coordinate
			valign ; the transversal alignment attribute
			align ; the longitudinal alignment attribute
			pane-valign ; the transversal pane alignment attribute
			top ; alignment to the starting edge of the line
			middle ; alignment to the centre of the line
			bottom ; alignment to the ending edge of the line
			left ; alignment to the starting transversal edge of the pane
			center ; alignment to the centre of the pane
			right ; alignment to the ending transversal edge of the pane
		]
	
		vertical: [
			y ; the longitudinal coordinate
			x ; the transversal coordinate
			align ; the transversal alignment attribute
			valign ; the longitudinal alignment attribute
			pane-align ; the transversal pane alignment attribute
			left ; alignment to the starting edge of the line
			center ; alignment to the centre of the line
			right ; alignment to the ending edge of the line
			top ; alignment to the starting transversal edge of the pane
			middle ; alignment to the centre of the pane
			bottom ; alignment to the ending transversal edge of the pane
		]
	]

	set 'update-group funct [
		{
			given a group update:
				line dimensions
				pane dimensions
				minification and magnification indices
		}
		group [gob!]
	] [
;		print ["update group" group/data/style]

		do bind bind/copy [
			unless update? [exit]
			update?: false
			
			set [l: t:] group-modes/:layout-mode
	
			init-pane:
			min-pane:
			max-pane: 0x0
			
			net-lines: 0
			sort-block: copy []
			
			repeat i length? lines [
				line: lines/:i
				
				line/align: case [
					word? pane-align [pane-align]
					all [block? pane-align pick pane-align i] [
						pick pane-align i
					]
					true [line/align]
				]
				
				line/valign: case [
					word? pane-valign [pane-valign]
					all [block? pane-valign pick pane-valign i] [
						pick pane-valign i
					]
					true [line/valign]
				]

				this-line-min: case [
					not block? line-min [line-min]
					pick line-min i [pick line-min i]
					true ['max]
				]
				this-line-init: case [
					not block? line-init [line-init]
					pick line-init i [pick line-init i]
					true ['max]
				]
				this-line-max: case [
					not block? line-max [line-max]
					pick line-max i [pick line-max i]
					true ['max]
				]
				
				line/init-size:
				line/min-size:
				line/max-size: 0x0
				
				if number? this-line-min [line/min-size/:t: this-line-min]
				if number? this-line-init [line/init-size/:t: this-line-init]
				if number? this-line-max [line/max-size/:t: this-line-max]
								
				line-start: at group line/start
				line/net-length: 0
				
				repeat i line/length [
					sg: pick line-start i
					face: sg/data
					
					case [
						face/facets/resizes [
							do-actor face 'on-update none
		
							line/net-length: line/net-length + 1
							
							line/init-size/:l: line/init-size/:l
								+ face/facets/init-size/:l
							switch this-line-init [
								max [
									line/init-size/:t: max line/init-size/:t
										face/facets/init-size/:t
								]
								min [
									line/init-size/:t: min line/init-size/:t
										face/facets/init-size/:t
								]
							]
							
							line/min-size/:l: line/min-size/:l
								+ face/facets/min-size/:l
							switch this-line-min [
								max [
									line/min-size/:t: max line/min-size/:t
										face/facets/min-size/:t
								]
								min [
									line/min-size/:t: min line/min-size/:t
										face/facets/min-size/:t
								]
								init [
									line/min-size/:t: line/init-size/:t
								]								
							]

							line/max-size/:l: add-max line/max-size/:l 
								face/facets/max-size/:l
							switch this-line-max [
								max [
									line/max-size/:t: max line/max-size/:t
										face/facets/max-size/:t
								]
								min [
									line/max-size/:t: min line/max-size/:t
										face/facets/max-size/:t
								]
								init [
									line/max-size/:t: line/init-size/:t
								]
							]
						]
						face/gob/size <> 0x-1 [
							either in face/facets 'intern [
								if face/facets/intern/update? [
									do-actor face 'on-resize face/facets/gob-size
								]
							] [
								do-actor face 'on-update none
							]
						]
					]
				]

				; make line/min-size and line/max-size consistent
				if line/min-size/:l > line/max-size/:l [
					value: line/min-size/:l
					line/min-size/:l: line/max-size/:l
					line/max-size/:l: value
				]
				if line/min-size/:t > line/max-size/:t [
					value: line/min-size/:t
					line/min-size/:t: line/max-size/:t
					line/max-size/:t: value
				]

				line-spacing: spacing/:l * max 0 line/net-length - 1
				
				if line/net-length > 0 [net-lines: net-lines + 1]

				init-pane/:l: max
					init-pane/:l
					line-spacing + line/init-size/:l
				init-pane/:t: init-pane/:t + line/init-size/:t
				
				min-pane/:l: max min-pane/:l line-spacing + line/min-size/:l
				min-pane/:t: min-pane/:t + line/min-size/:t
				
				max-pane/:l: max max-pane/:l add-max line-spacing
					line/max-size/:l
				max-pane/:t: add-max max-pane/:t line/max-size/:t
				
				line/minification-index: make block! line/net-length

				clear sort-block				
				repeat i line/length [
					sg: pick line-start i
					face: sg/data
					if face/facets/resizes [
						append append sort-block
							either face/facets/init-size/:l = 0 [max-coord] [
								face/facets/min-size/:l
									/ face/facets/init-size/:l
							] i
					]
				]
				sort/skip/reverse sort-block 2
				foreach [value i] sort-block [append line/minification-index i]
	
				line/magnification-index: make block! line/net-length
				
				clear sort-block
				repeat i line/length [
					sg: pick line-start i
					face: sg/data
					if face/facets/resizes [
						append append sort-block
							either face/facets/init-size/:l = 0 [max-coord] [
								face/facets/max-size/:l
									/ face/facets/init-size/:l
							] i
					]
				]
				sort/skip sort-block 2
				foreach [value i] sort-block [append line/magnification-index i]
			]
	
			box-space: margin/1 + border-size/1 + padding/1 + margin/2
				+ border-size/2 + padding/2
			box-space/:t: box-space/:t + (spacing/:t * max 0 net-lines - 1)
			
			either word? init-hint [init-hint-x: init-hint-y: init-hint] [
				init-hint-x: init-hint/1
				init-hint-y: init-hint/2
			]
			init-size: as-pair
				case [
					init-hint-x = 'auto [init-pane/x + box-space/x]
					any [
						init-hint-x = 'init
						init-hint-x = 'keep
					] [init-size/x]
					true [init-hint/1]
				]
				case [
					init-hint-y = 'auto [init-pane/y + box-space/y]
					any [
						init-hint-y = 'init
						init-hint-y = 'keep
					] [init-size/y]
					true [init-hint/2]
				]

			either word? min-hint [min-hint-x: min-hint-y: min-hint] [
				min-hint-x: min-hint/1
				min-hint-y: min-hint/2
			]
			min-size: as-pair
				case [
					min-hint-x = 'auto [min-pane/x + box-space/x]
					min-hint-x = 'init [init-size/x]
					min-hint-x = 'keep [min-size/x]
					true [min-hint-x]
				]
				case [
					min-hint-y = 'auto [min-pane/y + box-space/y]
					min-hint-y = 'init [init-size/y]
					min-hint-y = 'keep [min-size/y]
					true [min-hint-y]
				]

			either word? max-hint [max-hint-x: max-hint-y: max-hint] [
				max-hint-x: max-hint/1
				max-hint-y: max-hint/2
			]
			max-size: as-pair
				case [
					max-hint-x = 'auto [
						either max-pane/x = max-coord [max-coord] [
							max-pane/x + box-space/x
						]
					]
					max-hint-x = 'init [init-size/x]
					max-hint-x = 'keep [max-size/x]
					true [max-hint-x]
				]
				case [
					max-hint-y = 'auto [
						either max-pane/y = max-coord [max-coord] [
							max-pane/y + box-space/y
						]
					]
					max-hint-y = 'init [init-size/y]
					max-hint-y = 'keep [max-size/y]
					true [max-hint-y]
				]

			minification-index: make block! net-lines
			
			clear sort-block
			repeat i length? lines [
				linei: pick lines i
				unless linei/net-length = 0 [
					append append sort-block either linei/init-size/:t = 0 [
						max-coord
					] [
						linei/min-size/:t / linei/init-size/:t
					] i
				]
			]

			sort/skip/reverse sort-block 2
			foreach [value i] sort-block [append minification-index i]
	
			magnification-index: make block! net-lines
	
			clear sort-block
			repeat i length? lines [
				linei: pick lines i
				unless linei/net-length = 0 [
					append append sort-block either linei/init-size/:t = 0 [
						max-coord
					] [
						linei/max-size/:t / linei/init-size/:t
					] i
				]
			]
			sort/skip sort-block 2
			foreach [value i] sort-block [append magnification-index i]
		] group/data/facets group/data/facets/intern
	]

	set 'update-panel funct [
		{
			given a layout of type panel update:
				row heights
				column widths
				pane dimensions
				minification and magnification indices
		}
		panel [gob!]
	] [
;		print ["update panel" panel/data/style]
		
		do bind bind/copy [
			unless update? [exit]
			update?: false

			net-panel: 0
			repeat i length? panel [
				sg: pick panel i
				face: sg/data
				case [
					face/facets/resizes [
						do-actor face 'on-update none
						net-panel: net-panel + 1
					]
					face/gob/size <> 0x-1 [
						either in face/facets 'intern [
							if face/facets/intern/update? [
								do-actor face 'on-resize face/facets/gob-size
							]
						] [
							do-actor face 'on-update none
						]
					]
				]
			]

			line-length: either break-after = 0 [net-panel] [break-after]
		
			either line-length = 0 [lines: 0] [
				last-line: net-panel // line-length
				lines: net-panel - last-line / line-length
				if last-line <> 0 [lines: lines + 1]
			]

			either layout-mode = 'horizontal [
				rows: lines 
				columns: line-length
			] [
				rows: line-length
				columns: lines
			]

			foreach [length block hint] reduce [
				rows init-heights row-init
				rows min-heights row-min
				rows max-heights row-max
				columns init-widths column-init
				columns min-widths column-min
				columns max-widths column-max
			] [
				either length > length? block [
					append/dup block 0 length - length? block
				] [
					clear at block length + 1
				]				
				repeat i length [
					this-hint: any [
						all [not block? hint hint]
						all [
							block? hint
							pick hint i
						]
						'max ; default value for an inconsistent case
					]
					case [
						this-hint = 'max [block/:i: 0]
						number? this-hint [block/:i: this-hint]
						this-hint = 'min [block/:i: max-coord]
					]
				]
			]

			row-number: 1			
			column-number: 1

			repeat i length? panel [
				sg: pick panel i
				face: sg/data
				
				if face/facets/resizes [
					row-min-hint: any [
						all [not block? row-min row-min]
						all [
							block? row-min
							pick row-min row-number
						]
						'max
					]
					row-init-hint: any [
						all [not block? row-init row-init]
						all [
							block? row-init
							pick row-init row-number
						]
						'max
					]
					row-max-hint: any [
						all [not block? row-max row-max]
						all [
							block? row-max
							pick row-max row-number
						]
						'max
					]

					column-min-hint: any [
						all [not block? column-min column-min]
						all [
							block? column-min
							pick column-min column-number
						]
						'max
					]
					column-init-hint: any [
						all [not block? column-init column-init]
						all [
							block? column-init
							pick column-init column-number
						]
						'max
					]
					column-max-hint: any [
						all [not block? column-max column-max]
						all [
							block? column-max
							pick column-max column-number
						]
						'max
					]

					case [
						row-init-hint = 'max [
							init-heights/:row-number: max
								init-heights/:row-number
								face/facets/init-size/y
						]
						row-init-hint = 'min [
							init-heights/:row-number: min
								init-heights/:row-number
								face/facets/init-size/y
						]
					]
				
					case [
						row-min-hint = 'max [
							min-heights/:row-number: max
								min-heights/:row-number
								face/facets/min-size/y
						]
						row-min-hint = 'min [
							min-heights/:row-number: min
								min-heights/:row-number
								face/facets/min-size/y
						]
					]
				
					case [
						row-max-hint = 'max [
							max-heights/:row-number: max
								max-heights/:row-number
								face/facets/max-size/y
						]
						row-max-hint = 'min [
							max-heights/:row-number: min
								max-heights/:row-number
								face/facets/max-size/y
						]
					]
			
					case [
						column-init-hint = 'max [
							init-widths/:column-number: max
								init-widths/:column-number
								face/facets/init-size/x
						]
						column-init-hint = 'min [
							init-widths/:column-number: min
								init-widths/:row-number
								face/facets/init-size/x
						]
					]
				
					case [
						column-min-hint = 'max [
							min-widths/:column-number: max
								min-widths/:column-number
								face/facets/min-size/x
						]
						column-min-hint = 'min [
							min-widths/:column-number: min
								min-widths/:column-number
								face/facets/min-size/x
						]
					]
				
					case [
						column-max-hint = 'max [
							max-widths/:column-number: max
								max-widths/:column-number
								face/facets/max-size/x
						]
						column-max-hint = 'min [
							max-widths/:column-number: min
								max-widths/:column-number
								face/facets/max-size/x
						]
					]

					either layout-mode = 'horizontal [
						column-number: column-number + 1
						if column-number > columns [
							column-number: 1
							row-number: row-number + 1
						]
					] [
						row-number: row-number + 1
						if row-number > rows [
							row-number: 1
							column-number: column-number + 1
						]					
					]
				]
			]

			repeat i rows [
				if any [
					row-min = 'init
					all [block? row-min 'init = pick row-min i]
				] [min-heights/:i: init-heights/:i]
				if any [
					row-max = 'init
					all [block? row-max 'init = pick row-max i]
				] [max-heights/:i: init-heights/:i]
			]

			repeat i columns [
				if any [
					column-min = 'init
					all [block? column-min 'init = pick column-min i]
				] [min-widths/:i: init-widths/:i]
				if any [
					column-max = 'init
					all [block? column-max 'init = pick column-max i]
				] [max-widths/:i: init-widths/:i]
			]

			; make min-heights and max-heights consistent
			repeat i rows [
				if min-heights/:i > max-heights/:i [
					value: min-heights/:i
					min-heights/:i: max-heights/:i
					max-heights/:i: value
				]
			]

			; make min-widths and max-widths consistent
			repeat i columns [
				if min-widths/:i > max-widths/:i [
					value: min-widths/:i
					min-widths/:i: max-widths/:i
					max-widths/:i: value
				]
			]

			init-pane:
			min-pane:
			max-pane: 0x0
			
			repeat i rows [
				init-pane/y: init-pane/y + init-heights/:i
				min-pane/y: min-pane/y + min-heights/:i
				max-pane/y: either any [
					max-pane/y = max-coord
					max-heights/:i = max-coord
				] [max-coord] [max-pane/y + max-heights/:i]
			]
			
			repeat i columns [
				init-pane/x: init-pane/x + init-widths/:i
				min-pane/x: min-pane/x + min-widths/:i
				max-pane/x: either any [
					max-pane/x = max-coord
					max-widths/:i = max-coord
				] [max-coord] [max-pane/x + max-widths/:i]
			]

			box-space: margin/1 + border-size/1 + padding/1 + margin/2
				+ border-size/2 + padding/2 + (
					spacing * max 0x0 (as-pair columns rows) - 1x1 
				)

			either word? init-hint [init-hint-x: init-hint-y: init-hint] [
				init-hint-x: init-hint/1
				init-hint-y: init-hint/2
			]
			init-size: as-pair
				case [
					init-hint-x = 'auto [init-pane/x + box-space/x]
					any [
						init-hint-x = 'init
						init-hint-x = 'keep
					] [init-size/x]
					true [init-hint/1]
				]
				case [
					init-hint-y = 'auto [init-pane/y + box-space/y]
					any [
						init-hint-y = 'init
						init-hint-y = 'keep
					] [init-size/y]
					true [init-hint/2]
				]
			

			either word? min-hint [min-hint-x: min-hint-y: min-hint] [
				min-hint-x: min-hint/1
				min-hint-y: min-hint/2
			]
			min-size: as-pair
				case [
					min-hint-x = 'auto [min-pane/x + box-space/x]
					min-hint-x = 'init [init-size/x]
					min-hint-x = 'keep [min-size/x]
					true [min-hint-x]
				]
				case [
					min-hint-y = 'auto [min-pane/y + box-space/y]
					min-hint-y = 'init [init-size/y]
					min-hint-y = 'keep [min-size/y]
					true [min-hint-y]
				]

			either word? max-hint [max-hint-x: max-hint-y: max-hint] [
				max-hint-x: max-hint/1
				max-hint-y: max-hint/2
			]
			max-size: as-pair
				case [
					max-hint-x = 'auto [
						either max-pane/x = max-coord [max-coord] [
							max-pane/x + box-space/x
						]
					]
					max-hint-x = 'init [init-size/x]
					max-hint-x = 'keep [max-size/x]
					true [max-hint-x]
				]
				case [
					max-hint-y = 'auto [
						either max-pane/y = max-coord [max-coord] [
							max-pane/y + box-space/y
						]
					]
					max-hint-y = 'init [init-size/y]
					max-hint-y = 'keep [max-size/y]
					true [max-hint-y]
				]

			row-minification-index: make block! rows
			sort-block: make block! 2 * max rows columns
			repeat row-number rows [
				append append sort-block either init-heights/:row-number = 0 [
					max-coord
				] [
					min-heights/:row-number / init-heights/:row-number
				] row-number
			]
			sort/skip/reverse sort-block 2
			foreach [value row-number] sort-block [
				append row-minification-index row-number
			]

			row-magnification-index: make block! rows
			clear sort-block
			repeat row-number rows [
				append append sort-block either init-heights/:row-number = 0 [
					max-coord
				] [
					max-heights/:row-number / init-heights/:row-number
				] row-number
			]
			sort/skip sort-block 2
			foreach [value row-number] sort-block [
				append row-magnification-index row-number
			]

			column-minification-index: make block! columns
			clear sort-block
			repeat column-number columns [
				append append sort-block either init-widths/:column-number = 0 [
					max-coord
				] [
					min-widths/:column-number / init-widths/:column-number
				] column-number
			]
			sort/skip/reverse sort-block 2
			foreach [value column-number] sort-block [
				append column-minification-index column-number
			]

			column-magnification-index: make block! columns
			clear sort-block
			repeat column-number columns [
				append append sort-block either init-widths/:column-number = 0 [
					max-coord
				] [
					max-widths/:column-number / init-widths/:column-number
				] column-number
			]
			sort/skip sort-block 2
			foreach [value column-number] sort-block [
				append column-magnification-index column-number
			]
		] panel/data/facets panel/data/facets/intern
	]

	line?: funct [
		{compute the line number of a group position}
		group [gob!]
		index [integer!]
	] [
		lines: group/data/facets/intern/lines
		b: length? lines
		case [
			lines/1/length >= index [1]
			lines/:b/start <= index [b]
			true [
				; binary search
				a: 1
				while [a + 1 < b] [
					m: shift a + b -1
					line: lines/:m
					case [
						line/start > index [b: m]
						line/start + line/length <= index [a: m]
						true [a: b: m]
					]
				]
				a
			]
		]
	]
		
	set 'remove-from-group funct [
		{remove subgob(s) from a group}
		group [gob!]
		index [integer!]
		length [integer!]
	] [
		lines: group/data/facets/intern/lines
		
		remove/part at group index length
		
		; find the line containing the position
		line-no: line? group index
		line: lines/:line-no
		last-index: index + length - 1
		either line/start + line/length > last-index [
			; deleting in one line only
			line/length: line/length - length
			either line/length = 0 [remove at lines line-no] [
				line-no: line-no + 1
			]
		] [
			if index > line/start [
				line/length: index - line/start
				line-no: line-no + 1
			]

			last-line-no: line? group last-index
			line: lines/:last-line-no
			line/length: line/start + line/length - 1 - last-index
			either line/length = 0 [
				last-line-no: last-line-no + 1
			] [
				line/start: last-index - length 
			]
			remove/part at lines line-no last-line-no - line-no
			line-no: last-line-no
		]

		foreach line at lines line-no [line/start: line/start - length]
	]

	set 'insert-into-group funct [
		{insert faces(s) into a group}
		group [gob!]
		index [integer!]
		face [word! object! block!] {RETURN signals line break}
	] [
		lines: group/data/facets/intern/lines
		
		if empty? lines [
			append lines make line-proto [
				start: 1
				length: 0
			]
		]
		
		line-no: line? group index
		
		lines: at lines line-no
		
		line: first lines
		lines: next lines
		length: 0
		trigs: none
		either block? face [
			faces: face
			remove-each f faces [
				face: f
				do process-face
			]
		] process-face: [
			either object? face [
				if t: select face/facets 'triggers [
					unless trigs [
						trigs: make block! 2
					]
					append trigs face						
				]
				not if any [none? t find t 'visible-trigger] [
					insert at group index face/gob
					line/length: line/length + 1
					length: length + 1
					index: index + 1
				]
			] [
				; processing RETURN
				new-line: make line-proto [
					start: index
					length: 0
				]
				lines: insert lines new-line
				line/length: index - line/start
				line: new-line
			]
		]

		; move the start of every subsequent line
		foreach line lines [line/start: line/start + length]
		
		trigs
	]

	set 'change-line-alignment funct [
		{changes alignments of lines in a group}
		group [gob!]
		align [word! block!]
		valign [word! block!]
	] [
		lines: group/data/facets/intern
		either word? align [
			foreach line lines [line/align: align]
		] [
			n: min length? align length? lines
			repeat i n [
				line: lines/:i
				line/align: align/:i
			]
		]
		either word? valign [
			foreach line lines [line/valign: valign]
		] [
			n: min length? valign length? lines
			repeat i n [
				line: lines/:i
				line/valign: valign/:i
			]
		]
	]

	set 'resize-group funct [
		{resize a group}
		group [gob!]
	] [
;		print ["resize group" group/data/style]

		do bind bind/copy [
			size: viewport-box/bottom-right
			
			set [
				l: t:
				talign: lalign:
				pane-talign:
				s-talign: m-talign: e-talign:
				s-lalign: m-lalign: e-lalign:
			] group-modes/:layout-mode

			phys-pixel: 1x1 / gui-metric 'unit-size
			phys-pixel-l: phys-pixel/:l
			phys-pixel-t: phys-pixel/:t
	
			; line resize
			
			source: init-pane/:t
			total: target: size/:t
				- (spacing/:t * max 0 (length? minification-index) - 1)
			
			; "erase line sizes"
			foreach line lines [line/size: none]
			
			min-index: minification-index
			max-index: magnification-index
			while [
				; find the first unresized line using min-index
				while [
					all [
						min-i: first min-index
						lines/:min-i/size
					]
				] [min-index: next min-index]

				min-i ; any unresized line?
			] [
				; find the first unresized line using max-index
				while [
					all [
						max-i: first max-index
						lines/:max-i/size
					]
				] [max-index: next max-index]
				
				ratio: either zero? source [1.0] [target / source]

				min-ratio: either zero? lines/:min-i/init-size/:t [max-coord] [
					lines/:min-i/min-size/:t / lines/:min-i/init-size/:t
				]

				max-ratio: either zero? lines/:max-i/init-size/:t [max-coord] [
					lines/:max-i/max-size/:t / lines/:max-i/init-size/:t
				]

				ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
					; use the min-index
					i: min-i
					max ratio min-ratio
				] [
					; use the max-index
					i: max-i
					min ratio max-ratio
				]

				lines/:i/size: round-to ratio * lines/:i/init-size/:t
					phys-pixel-t
				
				source: source - lines/:i/init-size/:t
				target: target - lines/:i/size
			]
			line-init-ratio: ratio

			offset: switch get bind pane-talign 'pane-align reduce [
				s-talign [space/1/:t]
				m-talign [
					round-to space/1/:t + group/size/:t - space/2/:t
						- (spacing/:t * max 0 (length? minification-index) - 1)
						- total + target / 2 phys-pixel-t
				]
				e-talign [
					group/size/:t - space/2/:t - (
						spacing/:t * max 0 (length? minification-index) - 1
					) - total + target
				]
			]
			foreach line lines [
				unless line/net-length = 0 [
					line/offset: offset
					offset: offset + line/size + spacing/:t
				]
			]
	
			; element resize
	
			foreach line lines [
				unless line/net-length = 0 [
					source: line/init-size/:l
					total: target: size/:l - (
						spacing/:l * max 0 line/net-length - 1
					)
		
					line-start: at group line/start
					
					; "erase gob sizes"
					repeat i line/length [
						sg: pick line-start i
						face: sg/data
						
						if face/facets/resizes [face/facets/gob-size: none]
					]

					min-index: line/minification-index
					max-index: line/magnification-index
					while [
						; find the first unresized element using min-index
						while [
							all [
								min-i: first min-index
								sg: pick line-start min-i
								min-face: sg/data 
								min-face/facets/gob-size
							]
						] [min-index: next min-index]
		
						min-i ; any unresized element?
					] [
						; find the first unresized element using max-index
						while [
							all [
								max-i: first max-index
								sg: pick line-start max-i
								max-face: sg/data
								max-face/facets/gob-size
							]
						] [max-index: next max-index]
						
						ratio: either zero? source [1.0] [target / source]
		
						min-ratio: either zero? min-face/facets/init-size/:l [
							max-coord
						] [
							min-face/facets/min-size/:l / min-face/facets/init-size/:l
						]
		
						max-ratio: either zero? max-face/facets/init-size/:l [
							max-coord
						] [
							max-face/facets/max-size/:l / max-face/facets/init-size/:l
						]
		
						ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
							; use the min-index
							i: min-i
							face: min-face
							max ratio min-ratio
						] [
							; use the max-index
							i: max-i
							face: max-face
							min ratio max-ratio
						]

						face/facets/gob-size: 0x0
						face/facets/gob-size/:l:
							round-to ratio * face/facets/init-size/:l
								phys-pixel-l
						face/facets/gob-size/:t: line/size
						
						do-actor face 'on-resize face/facets/gob-size
						
						source: source - face/facets/init-size/:l
						target: target - face/facets/gob-size/:l
					]
					line/init-ratio: ratio
				
					offset: switch line/:lalign reduce [
						s-lalign [space/1/:l]
						m-lalign [
							round-to space/1/:l + gob-size/:l - space/2/:l
								- (spacing/:l * max 0 line/length - 1) - total
								+ target / 2 phys-pixel-l
						]
						e-lalign [
							gob-size/:l - space/2/:l - (
								spacing/:l * max 0 line/length - 1
							) - total + target
						]
					]
					repeat i line/length [
						sg: pick line-start i
						face: sg/data
						sg/offset/:l: offset
						sg/offset/:t: line/offset + switch face/facets/:talign reduce [
							s-talign [0]
							m-talign [
								round-to line/size
									- face/facets/gob-size/:t / 2
									phys-pixel-t
							]
							e-talign [line/size - face/facets/gob-size/:t]
						] 
	
						offset: offset + face/facets/gob-size/:l + spacing/:l
					]
				]
			]
		] group/data/facets group/data/facets/intern
	]

	set 'resize-panel funct [
		{resize a layout of type panel}
		panel [gob!]
	] [
;		print ["resize panel" panel/data/style length? panel]

		do bind bind/copy [
			size: viewport-box/bottom-right
			
			rows: length? row-minification-index 
			columns: length? column-minification-index
	
			phys-pixel: 1x1 / gui-metric 'unit-size

			; row resize
	
			heights: head insert/dup copy [] none rows
			row-offsets: head insert/dup copy [] none rows
				
			source: init-pane/y
			total: target: size/y - (spacing/y * max 0 rows - 1)
			
			min-index: row-minification-index
			max-index: row-magnification-index
			while [
				; find the first unresized row using min-index
				while [
					all [
						min-i: first min-index
						heights/:min-i
					]
				] [min-index: next min-index]

				min-i ; any unresized row?
			] [
				; find the first unresized row using max-index
				while [
					all [
						max-i: first max-index
						heights/:max-i
					]
				] [max-index: next max-index]
				
				ratio: either zero? source [1.0] [target / source]

				min-ratio: either zero? init-heights/:min-i [max-coord] [
					min-heights/:min-i / init-heights/:min-i
				]

				max-ratio: either zero? init-heights/:max-i [max-coord] [
					max-heights/:max-i / init-heights/:max-i
				]

				ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
					; use the min-index
					i: min-i
					max ratio min-ratio
				] [
					; use the max-index
					i: max-i
					min ratio max-ratio
				]
				
				heights/:i: round-to ratio * init-heights/:i phys-pixel/y

				source: source - init-heights/:i
				target: target - heights/:i
			]
	
			offset: switch pane-valign [
				top [space/1/y]
				middle [
					round-to space/1/y + gob-size/y - space/2/y
						- (spacing/y * max 0 rows - 1) - total + target / 2
						phys-pixel/y
				]
				bottom [
					gob-size/y - space/2/y - (spacing/y * max 0 rows - 1)
						- total + target
				]
			]
			repeat row-number rows [
				row-offsets/:row-number: offset
				offset: offset + heights/:row-number + spacing/y
			]
			row-init-ratio: ratio
	
			; column resize
	
			widths: head insert/dup copy [] none columns
			column-offsets: head insert/dup copy [] none columns
				
			source: init-pane/x
			total: target: size/x - (spacing/x * max 0 columns - 1)
	
			min-index: column-minification-index
			max-index: column-magnification-index
			while [
				; find the first unresized column using min-index
				while [
					all [
						min-i: first min-index
						widths/:min-i
					]
				] [min-index: next min-index]

				min-i ; any unresized column?
			] [
				; find the first unresized column using max-index
				while [
					all [
						max-i: first max-index
						widths/:max-i
					]
				] [max-index: next max-index]
				
				ratio: either zero? source [1.0] [target / source]

				min-ratio: either zero? init-widths/:min-i [max-coord] [
					min-widths/:min-i / init-widths/:min-i
				]

				max-ratio: either zero? init-widths/:max-i [max-coord] [
					max-widths/:max-i / init-widths/:max-i
				]

				ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
					; use the min-index
					i: min-i
					max ratio min-ratio
				] [
					; use the max-index
					i: max-i
					min ratio max-ratio
				]
				
				widths/:i: round-to ratio * init-widths/:i phys-pixel/x

				source: source - init-widths/:i
				target: target - widths/:i
			]
			column-init-ratio: ratio

			offset: switch pane-align [
				left [space/1/x]
				center [
					round-to space/1/x + gob-size/x - space/2/x
						- (spacing/x * max 0 columns - 1) - total + target / 2
						phys-pixel/x
				]
				right [
					gob-size/x - space/2/x - (spacing/x * max 0 columns - 1)
						- total + target
				]
			]
			repeat column-number columns [
				column-offsets/:column-number: offset
				offset: offset + widths/:column-number + spacing/x
			]
	
			; element resize
	
			row-number: 1
			column-number: 1
			repeat i length? panel [
				sg: pick panel i
				face: sg/data
				
				if face/facets/resizes [
					face/facets/gob-size: as-pair
						widths/:column-number
						heights/:row-number
		
					do-actor face 'on-resize face/facets/gob-size
		
					sg/offset/x: column-offsets/:column-number + switch face/facets/align [
						left [0]
						center [
							round-to widths/:column-number
								- face/facets/gob-size/x / 2 phys-pixel/x
						]
						right [widths/:column-number - face/facets/gob-size/x]
					]
					
					sg/offset/y: row-offsets/:row-number + switch face/facets/valign [
						top [0]
						middle [
							round-to heights/:row-number
								- face/facets/gob-size/y / 2 phys-pixel/y
						]
						bottom [heights/:row-number - face/facets/gob-size/y]
					]
	
					either layout-mode = 'horizontal [
						column-number: column-number + 1
						if column-number > columns [
							column-number: 1
							row-number: row-number + 1
						]
					] [
						row-number: row-number + 1
						if row-number > rows [
							row-number: 1
							column-number: column-number + 1
						]					
					]
				]
			]
		] panel/data/facets panel/data/facets/intern
	]
] ;end of resizing context
