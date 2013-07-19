REBOL [
	Title: "REBOL 3 GUI Styles - Layouts"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id: layout.r3 2367 2011-04-15 13:54:01Z cyphre $"
	Date: 22-Dec-2010/16:03:58+1:00
]

stylize [
	; NOTE: 'face style must be defined first
	face: [

		about: "A special style used passing pre-built faces."

		options: [
			content: [object!]
			init-size: [pair!]
		]
	]

	window: [

		about: "A special style used by system for window layouts."

		tags: [form]

		facets: [
			tab-face: none
			last-focus: none

			tool-tip-popup: false
			tool-tip-gob: none
			tool-tip-cb: none
			tool-tip-timer: none
			tool-tip-delay-timer: none
			tool-tip-over-face: none

			mouse-pos: none
			over-face: none

			;turn auto-sizing on
			init-hint: 'auto
			min-hint: none
			max-hint: none
		]

		intern: [
			hide-tooltip: func [face][
				unless face/facets/tool-tip-gob/offset/y = -10000 [
					face/facets/tool-tip-gob/offset/y: -10000
					show face/facets/tool-tip-gob

				]
			]
			show-tooltip: funct [face][
				face/facets/tool-tip-gob/offset: confine pos: face/gob/offset + face/facets/mouse-pos + 1x23 face/facets/tool-tip-gob/size + 1 gui-metric 'work-origin gui-metric 'work-size
				if not-equal? face/facets/tool-tip-gob/offset/y pos/y [
					face/facets/tool-tip-gob/offset/y: pos/y - face/facets/tool-tip-gob/size/y - 25
				]
				show face/facets/tool-tip-gob
			]
			clear-tool-tip-timers: func [face][
				all [
					face/facets/tool-tip-timer
					clear-timer face/facets/tool-tip-timer
					face/facets/tool-tip-timer: none
				]
				all [
					face/facets/tool-tip-delay-timer
					clear-timer face/facets/tool-tip-delay-timer
					face/facets/tool-tip-delay-timer: none
				]
			]
		]

		actors: [
			on-window-over: [
				if any [
					face/facets/tool-tip-popup
					face/facets/mouse-pos = arg/2
				][
					exit
				]

				face/facets/over-face: arg/1
				face/facets/mouse-pos: arg/2

				either in arg/1/facets 'tool-tip [	;face has tool-tip defined

					either any [
						not face/facets/tool-tip-timer
						all [
							face/facets/tool-tip-over-face <> face/facets/over-face
							face/intern/hide-tooltip face
						]
					][
						;attempt to clear tool-tip popup and hiding timers
						face/intern/clear-tool-tip-timers face

						face/facets/tool-tip-over-face: face/facets/over-face

						;setup timer for tool-tip popup
						face/facets/tool-tip-timer: set-timer face/facets/tool-tip-cb any [
							all [
								in arg/1/facets 'tool-tip-delay
								arg/1/facets/tool-tip-delay
							]
							guie/tool-tip-delay
						]
					][
						if all [
							not-equal? face/facets/tool-tip-gob/offset/y -10000
							any [
								all [
									in face/facets/over-face/facets 'tool-tip-follow
									face/facets/over-face/facets/tool-tip-follow
								]
								guie/tool-tip-follow
							]
						][
							;follow the mouse position
							face/intern/show-tooltip face
						]
					]

				][	;face has no tool-tip defined

					;attempt to clear tool-tip popup and hiding timers
					face/intern/clear-tool-tip-timers face

					;hide previous tool-tip if it is visible
					face/intern/hide-tooltip face
				]
			]

			on-make: [
				make-layout face 'panel
			]

			on-init: [
				;initialize tool-tip support
				unless any [
					face/facets/tool-tip-popup
					face/facets/tool-tip-gob
				][
					;setup and bind tool-tip main callback
					face/facets/tool-tip-cb: bind/copy [
						 if in facets/over-face/facets 'tool-tip [
							;mouse is still over the face - bild and show tool-tip content
							set-content facets/tool-tip-gob/1/data either block? facets/over-face/facets/tool-tip [
								;tool-tip is block! - show as layout
								facets/over-face/facets/tool-tip
							][
								;tool-tip is string! - show as simple text
								[text facets/over-face/facets/tool-tip options [one-line: true]]
							]

							update-face/content facets/tool-tip-gob/data

							intern/show-tooltip self

							;setup timer for optional tool-tip auto-hiding
							if hide-timeout: any [
								all [
									in facets/over-face/facets 'tool-tip-timeout
									facets/over-face/facets/tool-tip-timeout
								]
								guie/tool-tip-timeout
							][
								facets/tool-tip-delay-timer: set-timer [
									intern/hide-tooltip self
									facets/tool-tip-delay-timer: none
								] hide-timeout
							]
						]
					] face

					face/facets/tool-tip-gob: view/no-wait/options [
					][
						title: "tooltip popup"
						flags: [popup no-title on-top]
						owner: get in window-face? face 'gob
						bg-color: 255.255.225
						tool-tip-popup: true
						offset: 0x-10000
						padding: [2x2 2x2]
					]

					f: face/facets/tool-tip-gob/data/facets
					f/min-hint: 'init
					f/init-hint: 'auto
					f/max-hint: 'init
					f/padding: [0x0 0x0]
				]
			]

			on-resize: [
;				print ["on-resize" arg face/gob/text]
				do-actor/style face 'on-resize arg 'face
				resize-panel face/gob

				do-actor face 'on-popup [moved]
			]

			on-rotate: [
;				print ["on-rotate" arg/offset]
				do-triggers/arg face 'rotate arg
				do-actor face 'on-resize arg/offset
				draw-face face
			]
			
			on-update: [
				update-panel face/gob
			]

			on-content: [
				do-actor/style face 'on-content arg 'hpanel
			]

			on-window: [ ; arg: event
;				print ["on-window" arg/type face/facets/tool-tip-popup]
				switch arg/type [
					offset [
						if face <> guie/popup-face [
							do-actor face 'on-popup [moved]
						]
					]
					active [
						if face/facets/tool-tip-popup [
							face/facets/owner/flags: 'active
							show face/facets/owner
							exit
						]
						if face/facets/last-focus [
							focus/force face/facets/last-focus ;force re-focusing
						]
					]
					inactive [
						unless face/facets/tool-tip-popup [
							face/intern/hide-tooltip face
							face/intern/clear-tool-tip-timers face
						]
						face/facets/last-focus: either all [guie/focal-face face = window-face? guie/focal-face] [
							guie/focal-face
						][
							none
						]
						all [
							face/facets/last-focus
							unfocus
						]
					]
				]
				none
			]

			on-close: [
				result: none
				set/any 'result do-triggers/once/arg face 'close arg
				unless all [value? 'result result] [
					unview/only face
				]
			]

			on-popup: [
				if guie/popup-face [
					switch arg/1 [
						moved [
							place-popup
							show-later guie/popup-face/gob
						]
						outside-event [
							if arg/2/type = 'down [
								hide-popup
								exit ;don't propagate the event
							]
							true
						]
					]
				]
			]

			on-key: [ ; arg: event
				;process any special keys
				all [
					arg/type = 'key
					either arg/key = #"^-" [
						'propagate-event <> process-tab arg
					][
						any [
							process-access-key arg
							process-shortcut-key arg
						]
					]
					exit
				]

				;otherwise dispatch event to focal face
				all [
					guie/focal-face
					window-face? guie/focal-face
					do-actor guie/focal-face 'on-key arg
				]
			]

			; Used by requestors for setting and returning a value:
			on-set: [face/state/value: arg/2]
			on-get: [face/state/value]
		]
	]

	hgroup: [

		about: "For spaced groups. No background or borders. Default horizontal."

		tags: [layout]

		facets: [
			draw-mode: 'plain
			area-fill:
			material:

			;turn auto-sizing on
			min-hint:
			max-hint: none
			init-hint: 'auto

			layout-mode: 'horizontal
			box-model: 'layout

			dividers:
			mouse-pointers:
			hints:
			old-hints: none
			divider-over: none
		]

		options: [
			content: [block!]
			init-hint: [pair!]
			bg-color: [tuple!]
		]

		intern:	[
			make-dividers: funct [
				face [object!]
				dividers [block!]
			][
				out: make block! length? dividers
				lines: make block! length? face/facets/intern/lines
				a: pick [[x y][y x]] face/facets/layout-mode = 'vertical
				foreach l face/facets/intern/lines [
					append lines l/length + any [last lines 0]
				]
				foreach [id specs] dividers [
					if f: find lines id [
						append/only out append compose [id (index? f) size 0 axis (a/1) color (pewter)] specs
					]
				]
				if empty? out [return none]
				unless get-facet face 'mouse-pointers [
					set-facet face 'mouse-pointers reduce ['x system-cursors/size-we 'y system-cursors/size-ns]
				]

				out
			]
		]

		actors: [
			on-make: [
				;will be removed once skinning is added
				switch get-facet face 'box-model [
					frame [
						set-facet face 'material 'container-groove
					]
				]

				make-material face get-facet face 'material
				set-material face 'up
				all [
					get-facet face 'area-fill
					set-facet face 'draw-mode 'gradient
				]
				make-layout face 'group
			]

			on-init: [
				if get-facet face [dividers:] [
					face/facets/dividers: face/intern/make-dividers face dividers
				]
			]

			on-attach: [ ; arg: scroller
;				; Called when a face auto-attaches:
;				extend-face face 'attached arg
				set-face arg face/state/value
			]

			on-content: [
				switch arg/1 [
					clear [
						remove-from-group face/gob arg/3 arg/4
						if trigger-faces: select face 'trigger-faces [clear trigger-faces]
						bind-faces face
						apply :update-face [face arg/2 true]
						face
					]
					insert [
						content: arg/3
						index: arg/4
						trigs: insert-into-group face/gob index content
						bind-faces face
						do-actor content 'on-init none
						all [
							trigs
							extend-face face 'trigger-faces trigs
							do-actor trigs 'on-init none
						]
						do-triggers/no-recursive face 'load
						apply :update-face [face arg/2 true]
						face
					]
					remove [
						index: arg/3
						range: arg/4

						if trigger-faces: select face 'trigger-faces [
							;remove trigger faces
							foreach g apply :copy [at face/gob/pane index range range][
								if f: find trigger-faces g/data [remove f]
							]
						]

						apply :remove-from-group [face/gob index range]
						bind-faces face
						apply :update-face [face arg/2 true]
						face
					]
				]
			]

			on-scroll: [ ; arg: scroller
				gob: face/gob
				sgob: sub-gob? face
;				bars: face/attached
				bars: select face 'attached
				if all [bars sgob] [
					axis: face-axis? arg
					if sgob/size/:axis > 0 [
						set-face/field/no-show arg to percent! gob/size/:axis / sgob/size/:axis 'delta
						sgob/offset/:axis: negate (sgob/size/:axis + (2 * face/facets/spacing/:axis)) - gob/size/:axis * arg/state/value - face/facets/spacing/:axis
						show-later sgob
					]
				]
			]

			on-set: [ ; arg: [tag value no-show]
				if all [arg/1 = 'value block? arg/2] [
					set-layout face arg/2
				]
			]

			on-get: [ ; arg: field
				get-layout face ;arg
			]

			on-clear: [
				clear-layout face
			]

			on-resize: [
				do-actor/style face 'on-resize arg 'face
				resize-group face/gob

				foreach bar select face 'attached [
					if bar/style = 'scroller [
						do-face bar
					]
				]

				get-facet face [dividers:]
				forall dividers [
					axis: dividers/1/axis
					w: face/facets/padding/1/:axis
					repeat n dividers/1/id [
						w: w + face/facets/intern/lines/:n/size
					]
					dividers/1/size: w + (dividers/1/id - 1 * face/facets/spacing/:axis)
				]
				dividers
			]

			on-update: [
				update-group face/gob
				if get-facet face 'dividers [
					either block? face/facets/line-init [
						append/dup face/facets/line-init 'max (length? face/facets/intern/lines) - length? face/facets/line-init
					][
						face/facets/line-init: head insert/dup copy [] face/facets/line-init length? face/facets/intern/lines
					]
				]
			]

			on-move: [
				get-facet face [dividers: mouse-pointers:]
				foreach d dividers [
					axis: d/axis
					size: d/size

					either all [
						arg/offset/:axis >= size
						arg/offset/:axis < (size + face/facets/spacing/:axis)
					][
						cursor mouse-pointers/:axis
						unless d/color = tan [
							d/color: tan
							face/facets/divider-over: d
							draw-face face
						]
						break
					][
						cursor system-cursors/arrow
					]
				]
			]

			on-over: [
				unless arg [
					cursor system-cursors/arrow
					if face/facets/divider-over [
						face/facets/divider-over/color: pewter
						face/facets/divider-over: none
						draw-face face
					]
				]
			]

			on-click: [ ; arg: event
				if logic? arg [return arg]

				either arg/type = 'down [
					foreach d get-facet face 'dividers [
						size: d/size
						axis: d/axis
						if all [
							arg/offset/:axis >= size
							arg/offset/:axis < (size + face/facets/spacing/:axis)
						][
							; init drag
							return init-drag/only/data face arg/offset d
						]
					]
				][
					;end of dragging
					if face/facets/hints [
						set face/facets/hints face/facets/old-hints
						update-face/content face
						face/facets/hints: face/facets/old-hints: none
					]
				]
				false ;do unfocus
			]

			on-drag: [
				d: arg/data
				i: d/id
				w: d/size
				axis: d/axis

				r: face/facets/intern/line-init-ratio
				p: face/facets/intern/lines/:i
				mprev: p/min-size/:axis
				xprev: p/max-size/:axis

				either d/type = 'resizer [
					j: length? face/facets/line-init
				][
					j: i + 1
				]

				n: face/facets/intern/lines/:j
				prev: p/size
				next: n/size
				mnext: n/min-size/:axis
				xnext: n/max-size/:axis
				iprev: p/init-size/:axis
				inext: n/init-size/:axis
				pn: prev + next

				face/facets/line-init/:i:
					(t: max
						max pn - xnext mprev
					min
						min pn - mnext xprev
						(arg/base/:axis + arg/delta/:axis - (w - prev))
					) / r

				face/facets/line-init/:j:
					(max
						mnext
					min
						xnext
						(pn - t)
					) / r

				unless face/facets/old-hints [
					;set hints to 'keep to avoid propagation of 'update' updward
					face/facets/old-hints: reduce face/facets/hints: bind [
						min-hint
						max-hint
						init-hint
					] face/facets

					set face/facets/hints 'keep
				]

				update-face/content face
			]

			on-draw: [
				foreach d get-facet face 'dividers [
					size: d/size - face/facets/padding/1/(d/axis)
					either d/axis = 'x [
						p1: as-pair size face/facets/viewport-box/top-left/y + face/facets/padding/1/y
						p2: as-pair size + face/facets/spacing/x face/facets/viewport-box/bottom-right/y - face/facets/padding/2/y
					][
						p1: as-pair face/facets/viewport-box/top-left/x + face/facets/padding/1/x  size
						p2: as-pair face/facets/viewport-box/bottom-right/x - face/facets/padding/2/x size + face/facets/spacing/y
					]
					append arg compose [
						pen off
						fill-pen  (d/color)
						box (p1) (p2) 3.5
					]
				]
				arg
			]

			on-reset: [
				clear-layout face
			]
		]

		draw: [
			plain: []
			gradient: [
				clip border-box/top-left border-box/bottom-right
				pen none
				line-width 0
				grad-pen linear 1x1 0 gob/size/y 90 area-fill
				box (margin-box/top-left + 1) (margin-box/bottom-right - 1) 1
			]
		]
	]

	vgroup: hgroup [
		facets: [
			layout-mode: 'vertical
		]
	]

	hpanel: hgroup [

		about: "For grouping faces with a background and borders."

		tags: [layout]

		facets: [
			break-after: 0
			layout-mode: 'horizontal
		]

		options: [
			content: [block! object!]
			init-hint: [pair!]
			bg-color: [tuple!]
			break-after: [integer!]
		]

		intern:	[
			make-dividers: funct [
				face [object!]
				dividers [block!]
			][
				out: make block! length? dividers
				c: get-facet face 'break-after
				r: to integer! (f: length? faces? face) / (any [all [c > 0 c] 1]) + .5
				a: pick [[x y][y x]] face/facets/layout-mode = 'vertical

				foreach [id specs] dividers [
					unless any [
						id = 0
						id = f
					][
						i: id
						if c > 0 [
							i: id // c
						]
						either i = 0 [
							axis: a/1
							i: id / c
						][
							axis: a/2
						]
						sizes: pick [[widths init-widths column-init] [heights init-heights row-init]] axis = 'x
						unless any [
							i = 0
							all [d: select out i d/axis = axis]
						][
							append/only out append compose/only [id (i) size 0 axis (axis) sizes (sizes) color (pewter)] specs
						]
					]
				]
				if empty? out [return none]
				unless get-facet face 'mouse-pointers [
					set-facet face 'mouse-pointers reduce ['x system-cursors/size-we 'y system-cursors/size-ns]
				]
				out
			]
		]

		actors: [

			on-make: [
				;will be removed once skinning is added
				switch get-facet face 'box-model [
					frame [
						set-facet face 'material 'container-groove
					]
				]

				make-material face get-facet face 'material
				set-material face 'up

				all [
					get-facet face 'area-fill
					set-facet face 'draw-mode 'gradient
				]
				make-layout face 'panel
			]

			on-resize: [
				do-actor/style face 'on-resize arg 'face
				resize-panel face/gob

				foreach f select face 'attached [
					if f/style = 'scroller [
						do-face f
					]
				]

				get-facet face [dividers:]
				forall dividers [
					axis: dividers/1/axis
					w: face/facets/padding/1/:axis
					sizes: dividers/1/sizes/1
					repeat n dividers/1/id [
						w: w + face/facets/intern/(sizes)/:n
					]
					dividers/1/size: w + (dividers/1/id - 1 * face/facets/spacing/:axis)
				]
			]

			on-update: [
				update-panel face/gob
				if get-facet face 'dividers [
					either block? face/facets/column-init [
						append/dup face/facets/column-init 'max (length? face/facets/intern/init-widths) - length? face/facets/column-init
					][
						face/facets/column-init: head insert/dup copy [] face/facets/column-init length? face/facets/intern/init-widths
					]
					either block? face/facets/row-init [
						append/dup face/facets/row-init 'max (length? face/facets/intern/init-heights) - length? face/facets/row-init
					][
						face/facets/row-init: head insert/dup copy [] face/facets/row-init length? face/facets/intern/init-heights
					]
				]
			]

			on-drag: [
				d: arg/data
				w: d/size
				i: d/id
				axis: d/axis
				sizes: d/sizes
				ms: face/facets/intern/(select [x min-widths y min-heights] axis)
				xs: face/facets/intern/(select [x max-widths y max-heights] axis)
				r: face/facets/intern/(select [x column-init-ratio y row-init-ratio] axis)
				s: face/facets/intern/(sizes/1)

				j: either d/type = 'resizer [
					length? s
				][
					i + 1
				]

				prev: s/:i
				next: s/:j

				pn: prev + next

				face/facets/(sizes/3)/:i:
					(t: max
					max	pn - xs/:j ms/:i
					min
						min pn - ms/:j xs/:i
						(arg/base/:axis + arg/delta/:axis - (w - prev))
					) / r

				face/facets/(sizes/3)/:j:
					(max
						ms/:j
					min
						xs/:j
						(pn - t)
					) / r

				unless face/facets/old-hints [
					;set hints to 'keep to avoid propagation of 'update' updward
					face/facets/old-hints: reduce face/facets/hints: bind [
						min-hint
						max-hint
						init-hint
					] face/facets

					set face/facets/hints 'keep
				]

				update-face/content face
			]

			on-content: [
				switch arg/1 [
					clear [
						clear select face/facets 'dividers
						clear at face/gob arg/3
						if trigger-faces: select face 'trigger-faces [clear trigger-faces]
						bind-faces face
						apply :update-face [face arg/2 true]
					]
					insert [
						content: arg/3
						index: arg/4
						trigs: none
						dividers: clear []
						remove-each f content [
							either object? f [
								if t: select f/facets 'triggers [
									unless trigs [
										trigs: make block! 2
									]
									append trigs f
								]
								if any [none? t find t 'visible-trigger][
									insert at face/gob index f/gob
									++ index
								]
								false
							][
								switch f [
									divider [
										append dividers index - 1
									]
								]
								true
							]
						]
						unless empty? dividers [
							if dividers: face/intern/make-dividers face dividers [
								unless get-facet face 'dividers [set-facet face 'dividers copy []]
								append face/facets/dividers dividers
							]
						]
						bind-faces face
						do-actor content 'on-init none
						all [
							trigs
							extend-face face 'trigger-faces trigs
							do-actor trigs 'on-init none
						]
						do-triggers/no-recursive face 'load
						apply :update-face [face arg/2 true]
					]
					remove [
						index: arg/3
						range: arg/4

						if trigger-faces: select face 'trigger-faces [
							;remove trigger faces
							foreach g apply :copy [at face/gob/pane index range range][
								if f: find trigger-faces g/data [remove f]
							]
						]

						apply :remove [at face/gob index range range]

						if get-facet face [layout-mode: dividers:][
							end: index + range
							r: 0
							remove-each d dividers [
								all [
									d/id >= index
									d/id < end
									++ r
								]
							]
							forall dividers [
								dividers/1: either index < id: dividers/1/id [dividers/1: id - r][id]
							]
							set-facet face 'dividers face/intern/make-dividers face dividers
						]

						bind-faces face
						apply :update-face [face arg/2 true]
					]
				]
			]
		]
	]

	vpanel: hpanel [
		facets: [
			layout-mode: 'vertical
		]
	]

	htight: hpanel [

		about: "Tightly spaced and packed group. No background or borders. Horizontal default."

		tags: [layout]

		facets: [
			box-model: 'tight
		]
	]

	vtight: htight [
		facets: [
			layout-mode: 'vertical
		]
	]

	tight: vtight [] ; for compatibility right now, will be removed

	backdrop: hpanel [
		facets: [
			bg-color: 200.200.200
			padding: [5x5 5x5]
			break-after: 1
		]

		actors: [
			on-make: [
				make-layout face 'panel
				unless any [face/facets/border-color face/facets/dividers] [
					face/gob/color: get-facet face 'bg-color
				]
			]
		]
	]

	tooltip: [

		about: "Fake style."

		tags: [internal]

		facets: []

		actors: []
	]

	pad: [

		about: "Padding for blank spaces."

		facets: [
			init-size: 10x10
			bg-color: none
		]

		options: [
			init-size: [pair!]
		]
	]

	when: [

		about: "A special style for defining layout triggers."

		facets: [
			triggers: []
		]

		options: [
			triggers: [block!] "Trigger words"
		]

		; This is a special style that creates a face that is removed
		; from the layout/faces block to a layout/triggers block. These
		; triggers are activated at various points in layout loading,
		; entry, exit, etc. For each face in this list, the ACT block
		; is used to perform various actions, just like other faces.
	]

	data: [

		about: "A special style for storing data."

		tags: [state]

		options: [
			block: [block!]
		]

		actors: [
			on-init: [
				show-face/no-show face 'ignored
				face/state/value: reduce any [get-facet face 'block []]
			]
		]
	]

	embed: data [

		about: "A special style for including data values in SUBMIT."

		tags: [edit]

	]

	tags: when [

		about: "A special style that defines tags for the previously laid out face."

		options: [
			block: [block!] "Block will REDUCE immediately"
		]

		facets: [
			triggers: [load]
		]

		actors: [
			on-init: [
				; parent is none, so we can't immediately find the previous face
				; need to figure out how the trigger really runs on exit
				probe face/gob/parent
				probe get-facet face 'block
			]
		]
	]

	scroll-pane: vtight [

		tags: [internal]

		facets: [
			init-hint: 'auto
			min-hint: 'init
			max-hint: 'auto
		]

;		draw: [
;			fill-pen red
;			clip viewport-box/top-left viewport-box/bottom-right
;			box viewport-box/top-left (viewport-box/bottom-right - 1)
;		]
	]

	plane: vtight [

		about: "A lean sub-layout used as a scroll frame. No internal resizing."

		tags: [internal]	; it's not exactly internal style, but you'd better know what you're doing with it...

		options: [
			layout-face: [block! object!]
		]

		facets: [
			min-hint: 'init
			max-hint: guie/max-pair
			names: true
		]

		content: [
			sp: scroll-pane
		]

		actors: [
			on-init: [
				set-face/no-show face get-facet face 'layout-face
			]

			on-set: [;arg/3 is /no-show refinement state of SET-FACE call
				if all [arg/1 = 'value arg/2] [
					apply :set-content [face/names/sp arg/2 none none arg/3]
					foreach bar select face 'attached [
						if all [
							bar/style = 'scroller
							axis: bar/facets/axis
							face/gob/1/size/:axis <> 0
						][
							set-face/no-show/field bar to percent! min 1 face/gob/size/:axis / face/gob/1/size/:axis 'delta
						]
					]
				]
			]

			; should propagate on-get

		]
	]

	scroll-panel: hgroup [
		facets: [
			names: true
			init-hint: 400x300
			min-hint: 26x26
			max-hint: guie/max-pair

			hide-scrollers: yes		; hide scrollers when not needed?
		]

		content: [
			pl: plane on-resize [
				do-actor/style face 'on-resize arg 'plane
				;check scrollers when plane resizes
				do-actor parent-face? face 'on-show-scrollers false
			]
			v-scroller: scroller #v
			return
			h-scroller: scroller #h
		]

		options: [
			init-hint: [pair!]
			layout-face: [block! object!]
		]

		actors: [
			on-init: [
				set-face/no-show face any [get-facet face 'layout-face []]
			]
			on-set: [ ;arg/3 is /no-show refinement state of SET-FACE call
				switch arg/1 [
					value [
						all [
							pair? face/facets/init-hint
							face/names/pl/facets/init-hint: face/facets/init-hint - 30
						]
						all [
							pair? face/facets/min-hint
							face/names/pl/facets/min-hint: face/facets/min-hint - 30
						]
						apply :set-face [face/names/pl arg/2 arg/3]
					]
					h-scroll [apply :set-face [face/names/h-scroller arg/2 arg/3]]
					v-scroll [apply :set-face [face/names/v-scroller arg/2 arg/3]]
				]
				apply :update-face [face arg/3]
			]
			on-get: [
				switch arg [
					value [
						get-face face/names/pl
					]
					h-scroll [
						get-face face/names/h-scroller
					]
					v-scroll [
						get-face face/names/v-scroller
					]
				]
			]
			on-resize: [
				do-actor face 'on-show-scrollers true
				do-actor/style face 'on-resize arg 'hgroup
			]
			on-show-scrollers: [
				if get-facet face 'hide-scrollers [
					apply :show-face [face/names/h-scroller either 100% = face/names/h-scroller/state/delta ['ignored]['visible] arg]
					apply :show-face [face/names/v-scroller either 100% = face/names/v-scroller/state/delta ['ignored]['visible] arg]
					update-face/no-show/content face
				]
			]
		]
	]

] ; -end-
