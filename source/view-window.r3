REBOL [
	Title: "R3 GUI - View: show"
	Purpose: {
		The main VIEW and UNVIEW API functions.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

view: funct [
	"Displays a window view from a layout block, face (layout), or low level graphics object (gob)."
	spec [block! object! gob!] "Layout block, face object, or gob type"
	/options
		opts [block!] "Optional features, in name: value format"
	/modal "Display a modal window (pop-up)"
	/no-wait "Return immediately - do not wait"
	/across "Use horizontal layout-mode for top layout (rather than vertical)"
	/as-is "Use GOB exactly as passed - do not add a parent gob"
	/maximized "Open window in maximized state"
	/minimized "Open window in minimized state"
	/on-error
		error-handler [block!] "specify global error handler"
][
	; Is the system screen (OS) initialized?
	unless screen: system/view/screen-gob [return none]

	; Evaluate options block and create a MAP to hold the options:
	opts: make map! reduce-opts any [opts []]

	; Set any additional options provided as refinements:
	if modal   [opts/modal: true]
	if no-wait [opts/no-wait: true]
	if across  [append opts [break-after: 0]] ;the key must be set-word!
	if as-is   [opts/as-is: true]
	if on-error [guie/error-handler: error-handler]
	
	; Process the spec according to its datatype:
	case [
		block? spec [ ; a layout
			win-face: apply :make-window-layout [spec opts maximized]
			win-gob: win-face/gob
		]
		object? spec [ ; a face (normally a layout)
			win-face: spec
			win-gob: win-face/gob
			opts/handler: guie/handler ; I'm sure this is not correct
			append win-face 'handler
			either maximized [
				title-space: either all [opts/flags opts/flags/no-title][0x0][gui-metric 'title-size]
				;use the exact maximized window size
				do-actor win-face 'on-resize (gui-metric 'work-size) - (gui-metric 'work-origin) - title-space
				;set the default window size for 'restore' operation
				win-face/gob/size: win-face/facets/init-size
			][
				do-actor win-face 'on-update none
				do-actor win-face 'on-resize win-face/facets/init-size
			]
			
			draw-face win-face
		]
		gob? spec [ ; low level graphics object
			either as-is [
				win-gob: spec
			][
				win-gob: make-window-gob spec opts
			]
		]
	]

	; Window title
	win-gob/text: any [opts/title win-gob/text all [system/script/header system/script/header/title] "REBOL: untitled"]

	; Determine the window offset from specified options:
	; (If none given, default to center of prior window or center of screen.)
	ds: screen/size - win-gob/size
	pos: any [
		opts/offset 
		if all [
			last-win: last screen
			last-win/text <> "tooltip popup"
		][ ; position over prior window if found
			max 0x0 last-win/size - win-gob/size / 2 + last-win/offset
		] 
		'center
	]

	win-gob/offset: case [
		pair? pos [pos]
		word? pos [
			max 5x5 switch pos [
				top-left [0x0]
				top-right [ds * 1x0]
				bottom-left [ds * 0x1]
				bottom-right [ds]
				center [ds - ((screen/size) - (gui-metric 'work-size)) / 2 + gui-metric 'work-origin]
			]
		]
		true [0x0]
	]

	; Process any special options:
	opts/flags: any [opts/flags copy [resize]]
	if opts/no-resize [
		alter opts/flags 'resize
	]
	if opts/modal [
		foreach g reverse screen/pane [
			unless g/text = "Tooltip popup" [
				win-gob/owner: g ; may be changed below
				append opts/flags [modal popup]
				break
			]
		]
		if win-face [win-face/state/value: none] ; where result is kept
	]
	if opts/owner [ ; parent window
		win-gob/owner: opts/owner
	]
	if opts/handler [
		handler: handle-events opts/handler
		handler/win-gob: win-gob
		win-gob/data/handler: handler ; face or mini-face object
	]
	if opts/reactors [
		if win-face [extend win-face 'reactors opts/reactors]
	]
	win-gob/flags: opts/flags

	; make sure the window title is not off the screen otherwise it will generate wrong events when resizing in Windows7
	if all [system/version/4 = 3 not find win-gob/flags 'no-title][
		win-gob/offset/y: max win-gob/offset/y second (gui-metric 'title-size) + gui-metric 'border-size
	]
	
	; Add the window to the screen. If it is already there, this action
	; will move it to the top:
	unless win-gob = screen [append screen win-gob] ; avoids loop

	; Open the window:
	if maximized [win-gob/flags: 'maximize]
	if minimized [win-gob/flags: 'minimize]

	show win-gob

	; We will wait if this is first window or modal:
	wait-now: all [
		any [modal 1 = length? screen]
		not opts/no-wait
	]

	if win-face [
		do-actor win-face 'on-init none	
		;call the ENTER trigger asynchronously so VIEW call always finishes and the trigger code blocks in the port wake-up call in the worst case
		e: make event! [type: 'custom window: win-gob code: 1]
		append system/ports/system e
	]

	show-now ; effect-layout win-face/gob/pane/1/data 'fly-down ??

	; Wait for the event port to tell us we can return:
	if wait-now [
		if handler [handler/status: 'active] ; only active handlers can WAKE from WAIT
		do-events
	]

	; Return window gob (used by requestors, etc.):
	win-gob
]

close-window: func [
	"Close the parent window of a face."
	face
	/result value "Set result value (for requestors)"
][
	if face: window-face? face [
		if result [set-face face value]
		do-actor face 'on-close face
	]
]

unview: funct [
	"Closes a window view. Wakes up a prior WAIT if necessary."
	/all "Close all views."
	/only "Close a single view. Window face or GOB."
		window [object! gob!]
][
	screen: system/view/screen-gob
	case [
		all [show clear screen exit] ;; bug: does not wake-events!!!
		gob? window [win-gob: window]
		object? window [
			self/all [
				;attempt to close the tool-tip window
				'window = get in window 'style
				gob? window/facets/tool-tip-gob
				unview/only window/facets/tool-tip-gob
			]
			win-gob: window/gob
		]
		true [win-gob: last screen] ; NONE is ok
	]

	remove find screen win-gob ; none ok
	show win-gob ; closes it, none ok

	if self/all [ ;all native has been overwritten so get it from self
		window: win-gob/data
		handler: select window 'handler ; it has a handler
		handler/status = 'active
	][
		wake-events handler ; awake WAIT in VIEW
	]
	win-gob
]

layout: funct [
	spec [block!]
	/options
		opts [block! map!]
	/gob "return GOB instead of face object"
	/only "return layout without the WINDOW face"
][
	if block? opts [opts: make map! reduce-opts opts]
	win-face: make-window-layout spec any [opts make map! []]
	if only [win-face: win-face/gob/pane/1/data]
	either gob [
		win-face/gob
	][
		win-face
	]
]

;-- Internal Functions -------------------------------------------------------

reduce-opts: func [
	opts [block!]
	/local result wrd val beg fin
][
	result: copy []
	parse opts [
		some [
			set wrd set-word! beg: (append result wrd) some [
				fin: [set-word! | end] (
					val: copy/part beg fin
					append result either lit-word? :val/1 [
						 :val/1
					][
						reduce val
					]
				) break
				| skip
			] :fin
			| skip
		]
	]
	result
]

make-window-layout: funct [
	;INTERNAL: temporary top level window layout maker
	content [block!]
	opts [map!]
	/maximized
][
	;propagate facets related options to backdrop style as well
	bopts: make block! 2 * length? opts
	facets: words-of guie/styles/backdrop/facets
	if bm: select guie/box-models guie/styles/backdrop/facets/box-model [
		facets: union facets words-of bm
	]
	foreach w intersect	words-of opts facets [
		append/only append bopts w opts/:w
	]

	win-face: make-face 'window append compose/deep [
		content: [
			backdrop [(content)]
			options [(bopts)]
		]
	] any [all [opts to block! opts] []]

	win-face/gob/text: find-title-text win-face/gob/1/data

	append win-face 'handler ; will be set in VIEW func

	title-space: either all [opts/flags opts/flags/no-title][0x0][gui-metric 'title-size]
	
	either maximized [
		;use the exact maximized window size
		do-actor win-face 'on-resize (gui-metric 'work-size) - (gui-metric 'work-origin) - title-space
		;set the default window size for 'restore' operation
		win-face/gob/size: win-face/facets/init-size
	][
		;on-update must be called to get INIT-SIZE value
		do-actor win-face 'on-update none
		do-actor win-face 'on-resize win-face/facets/init-size
	]

	;check if any update has been requested during on-resize
	while [win-face/facets/intern/update?][
		updated?: true
		do-actor win-face 'on-update none
;		do-actor win-face 'on-resize win-face/facets/init-size
	]

	;avoid content to be smaller than minimal size of the OS window
	min-win: (gui-metric 'window-min-size) - title-space - ((gui-metric either any [opts/no-resize all [opts/flags opts/flags/no-resize]]['border-fixed]['border-size]) * 2)

	if (to logic! if any [
			win-face/facets/min-size/x < min-win/x
			win-face/facets/min-size/y < min-win/y
		][
			win-face/facets/min-hint: max min-win win-face/facets/min-size
		])
	or
		to logic! if any [
			win-face/facets/max-size/x < min-win/x
			win-face/facets/max-size/y < min-win/y
		][
			win-face/facets/max-hint: max min-win win-face/facets/max-size
		]
	[
		updated?: true
		update-face/content/no-show win-face	
;		do-actor win-face 'on-resize win-face/facets/init-size
	]

	;re-size the layout in case of additional update
	if updated? [do-actor win-face 'on-resize win-face/facets/init-size]
	
	draw-face/no-show win-face

	unless opts/handler [opts/handler: guie/handler]
	clear guie/shows

	win-face ;returned
]

make-window-gob: funct [
	;INTERNAL: provide a crude framework for GOB window
	spec [gob!]
	opts [map!]
][
	; If AS-IS option use it as window, else make one:
	either opts/as-is [
		window: spec
	][
		spec/offset: 0x0
		window: make gob! [size: spec/size text: "Window"]
		append window spec
	]

	; Insert optional background gob behind the gob:
	if any [
		opts/color
		opts/draw
	][
		spec: copy [
			size: window/size
			offset: 0x0
		]
		if opts/color [append spec [color: opts/color]]
		if opts/draw  [append spec [draw: to-draw opts/draw copy []]]
		insert window make gob! spec
	]

	; Use default GOB handler block if not specified:
	unless opts/handler [opts/handler: gob-handler]

	; We need a mini-face object to provide handler location.
	; This can be extended by user for additional storage.
	window/data: make object! [
		handler: none ; set in VIEW function
		options: opts
	]
	
	window ; returned
]

gob-handler: [
	name: 'gob
	about: "Low level handler for VIEW of simple GOBs."
	priority: 50
	do-event: func [event] [
		print ["view-event:" event/type event/offset]
		either switch event/type [
			close [true]
			key [event/key = escape]
		][
			unview/only event/window
		][
			show event/window
		]
		none ; we handled it
	]
]
