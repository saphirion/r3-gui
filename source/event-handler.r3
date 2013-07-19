REBOL [
	Title: "R3 GUI - Event: main handler"
	Purpose: {
		This is the main handler for all GUI events.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

; WARNING:
;   This code is from VID 3.3 and is still being converted as needed.
;   Some advanced events are not yet functional (will error out).

; NOTE: Replace these sub-objects with functors?

gui-events: context [

	handlers: none  ; (slightly better performance with this at top)
	over-face:		; current face mouse is over (single-state)
	over-where:		; position where over occurred
		none

	within-clip?: funct [	
		event [event!]
		face [object!]
	][
		all [
			pf: parent-face? face select pf 'facets
			oft: event/offset + face/gob/offset - pf/facets/space/1
			siz: pf/facets/viewport-box/bottom-right
			oft/x < siz/x
			oft/x >= 0
			oft/y < siz/y
			oft/y >= 0
		]	
	]
	
	handlers: context [

		down: up: context [

			; mouse clicks. down-face is the face that got the down
			; (see below, there is one for each class of click)

			down-face: none
			; handle down-face, then delegate to handler subobject

			do-event: func [event] [
				; Redispatch the handler function:
				down-face: handler/(event/type)/do-event event down-face
			]

			handler: context [

				down:
				alt-down:
				aux-down: context [

					; down event - call on-click, bubble up if necessary

					do-event: func [event face /local where] [
						where: event/offset
						event: map-event event
						face: event/gob/data

						unless within-clip? event face [
							event/offset: event/offset + face/gob/offset						
							face: parent-face? face
						]

						if face [
							unless event: do-actor face 'on-click event [
								unfocus
							]

							if object? event [; can return drag object
								; on-click started a drag:
								event/start: where
							]
						]
						face ; returned (down-face) - may be none
					]
				]

				up:
				alt-up:
				aux-up: context [

					; up event - terminate dragging, call on-click or on-drop if necessary

					do-event: func [event down-face /local face drag] [
						drag: all [guie/drag/face guie/drag]
						if all [drag drag/gob] [
							; Remove drag object from current window...
							; Avoid showing the whole window and don't use show-later
							; because it will not work properly in this specific case.
							;??? drag/gob/offset: negate drag/gob/size ; force it to clip
							show drag/gob
							remove find/last event/window drag/gob
							cursor system-cursors/arrow
						]

						event: map-event event
						face: event/gob/data
						
						unless within-clip? event face [
							event/offset: event/offset + face/gob/offset						
							face: parent-face? face
						]
						
						if face [event/offset: do-actor face 'locate event]
						
						; normal click - stop here
						if all [down-face not drag down-face = face] [
							do-actor down-face 'on-click event
							return none
						]
						
						; handle possible drag cases
						case/all [
							; click on dragable face, but no movement
							all [drag drag/gob drag/gob/offset = drag/base-offset][
								do-actor drag/face 'on-click event
								drag: none
							]
							
							; drag dropped on face
							all [drag drag/gob] [
								; check for on-drop actor or pass to parent face
								f: face
								drag/event: event
								while [all [f not ret: do-actor f 'on-drop drag]][
									drag/event/offset: drag/event/offset + f/gob/offset ; remap offset
									f: parent-face? f
								]
								
								unless ret [
									; Call "on-away"
									do-actor drag/face 'on-over none
									; Drag should now return to original place
									base-pos: drag/base-offset + get-gob-offset drag/origin
									delta: base-pos - drag/gob/offset / 10
									; Animate return to original place
									loop 11 [
										drag/gob/offset: drag/gob/offset + delta
										show drag/gob
										wait 0.0125
									]
									drag/gob/offset: drag/base-offset
									insert guie/drag/origin drag/gob
									win: window-face? drag/face
									show win/gob
								]
								drag: none
							]
							
							; end drag inside face
							drag [
								;send mouse-up as well to be able detect end of dragging in the ON-CLICK handler of the face
								do-actor drag/face 'on-click event
								drag: none
							]
						]

						reset-drag
						
					;needs offset:	if face/state/over [do-actor face 'on-over on] ;??needed?
						none ; returned
					]
				]
			]
		]

		; each kind of mouse button needs its own down-face variable.
		alt-down: alt-up: make down [ ]
		aux-down: aux-up: make down [ ]

		move: context [
			
			do-event: func [event /local face where window] [

				either drag: all [guie/drag/face guie/drag] [
					either not drag/gob [
						; A normal internal drag...
						drag/delta: event/offset - drag/start ; delta xy
						if any [drag/active not zero? drag/delta][
							drag/active: true
							drag/event: map-event event
							do-actor drag/face 'on-drag drag ; show dragger change
						]
					][
						; not an internal drag (normal drag&drop) - move gob, call on-drag/over etc.
						if any [drag/active greater? sum-pair abs drag/start - event/offset 2][
							
							; Update drag object:
							drag/active: true
							extend drag 'offset event/offset
							window: event/window
							
							; Drag face movement must be dealt in ON-DRAG actor:
							drag/gob/offset: get-gob-offset drag/gob
							do-actor drag/face 'on-drag drag
							
							; Remove the drag gob so we can find what is under it:
							remove find/last event/window drag/gob
							event: map-event event
							face: event/gob/data

							; Bring gob back and show it:
							append window drag/gob
							; Update parent on first show to remove visual artifacts
							; but only drag gob susequently, to make it faster
							show-later either drag/show-parent? [drag/show-parent?: false drag/gob/parent] [drag/gob]

							where: do-actor face 'locate event
; TODO: this part needs rewrite, it's bit strange
							if all [
								any [
									face  <> over-face
									where <> over-where
								]
								any [
									do-actor/bubble face 'on-drag-over reduce [drag where yes]
									(
										cursor system-cursors/no
										false
									)
								]
							][
								cursor system-cursors/arrow
								if over-face [
									do-actor over-face 'on-drag-over reduce [drag over-where no]
								]
								do-actor face 'on-drag-over reduce [drag where yes]
							]

							over-face: face
							over-where: where
						]
					]
				][
					; we are not dragging
					win-face: event/window/data
					mouse-offset: event/offset
					event: map-event event
					face: event/gob/data

					unless within-clip? event face [
						event/offset: event/offset + face/gob/offset						
						face: parent-face? face
					]

					if face [
						all [
							win-face
							do-actor win-face 'on-window-over reduce [face mouse-offset]
						]
						do-actor face 'on-move event
						either over-face <> face [
							if over-face [
								do-actor over-face 'on-over none
							]
							over-face: face
							do-actor face 'on-over event/offset
						][
							if get-facet face 'all-over [
								do-actor face 'on-over event/offset
							]
						]
					]
				]
			]
		]

		; resize event - call window
		resize: context [
			do-event: func [event] [
				do-actor event/window/data 'on-resize event/offset
				clear guie/shows
				wait 0.001 ;give some time to event pump (a must in Windows to avoid infinite resizing loops in some special cases)
				draw-face event/window/data
			]
		]

		rotate: context [
			do-event: func [event] [
				do-actor event/window/data 'on-rotate event
			]
		]

		; key events
		key: key-up: context [
			do-event: func [event /local win face] [
				;call the window on-key actor to dispatch key events
				do-actor event/window/data 'on-key event
			]
		]

		;custom event types (currently used by only 'ENTER async trigger)
		custom: context [
			do-event: func [event] [
				switch pick [enter] event/offset/x [
					enter [
						do-triggers/arg event/window/data 'enter event/window/data
					]
				]
			]
		]
		
		close: context [
			; close event - just unview window (should we have a window/feel/on-close ?)
			do-event: func [event] [
				do-actor event/window/data 'on-close event
			]
		]

		; do nothing on restore, offset, minimize, maximize (should it send action event to window face?)
		active: inactive: restore: offset: minimize: maximize: context [
			do-event: func [event] [
				do-actor event/window/data 'on-window event
			]
		]

		; scroll wheel - scroll face under mouse, bubble up if necessary
		scroll-line: scroll-page: context [
			do-event: func [event /local face] [
				if over-face [
					face: over-face
					; bubble up if necessary
					until [
						event: do-actor face 'on-scroll-event event
						not all [face: parent-face? face event? event]
					]
				]
			]
		]

		; file dropped on window - call on-drop with none as origin face
		drop-file: context [
			do-event: func [event /local gob ofs face where] [
				print "drop-file"
				event: map-event event
				face: event/gob/data
				event/offset: do-actor face 'locate event
				do-actor face 'on-drop event ; event/data has FILE path
			]
		]
	]

	guie/handler: [
		name: 'gui
		priority: 0
;		print "handler added"
		do-event: func [event] [
			debug-gui 'events [event/type event/offset]
;			print [event/type event/offset]
			if any [
				not guie/popup-face
				all [guie/popup-face event/gob/data = guie/popup-face]
				all [guie/popup-face event/gob/data <> guie/popup-face do-actor guie/popup-face 'on-popup reduce ['outside-event event]]
			][
				handlers/(event/type)/do-event event
			]
			
			; all the handlers use show-later instead of SHOW, so that everything is
			; shown in one go here with SHOW-NOW.
			show-now
			; If a reactor set handler status to 'wake, return handler to remove it from handlers,
			; and awake from the WAIT. Else, return NONE.
			none
		]
	]
]

