REBOL [
	Title: "R3 GUI - View: popups"
	Purpose: {
		Functions for popup requestors.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
]

request: funct [
	"Open a requestor modal dialog box. Returns result: true false none"
	title [string!]
	message [string! block!]
	/warn "Important message to user"
	/ask  "Ask user a question (yes/no)"
	/cancel "Add a cancel button (returns as false)"
	/custom "Specify custom ok/cancel button titles"
		titles [block!]
	/options "Specify request window face options"
		opts [block!]
	/resize
][
	btns: copy [default-button:]
	
	ok-btn: [
		button #auto ok-title on-action [close-window/result face window-face? face]
	]
	close-btn: [
		button #auto close-title on-action [close-window/result face false]	
	]
	
	either ask [
		ok-title: "Yes"
		close-title: "No"
	][
		either custom [
			set [ok-title close-title] titles
		][
			ok-title: "Ok"
			close-title: "Cancel"
		]
	]
	
	if all [ok-title not empty? ok-title] [append btns ok-btn]

	if all [
		any [ask cancel custom]
		close-title not empty? close-title
	][
		append btns close-btn
	]

	win-gob: view/modal/options compose/deep [
;		vpanel 240.100.80 [title (title)] options [min-hint: 'init max-hint: reduce [guie/max-coord 'init] material: none]
		(
			compose/deep either block? message [
				[vgroup [(message)] options [box-model: 'tight]]
			][
				[
					scroll-panel [
						doc (message)
					] options [init-hint: 'auto]
				]
			]
		)
		hgroup [(btns)] options [pane-align: 'right max-hint: reduce [guie/max-coord 'auto]]
		when [enter] on-action [focus default-button]
	] append copy [
		no-resize: not resize
		title: title
		margin: 0x0
		bg-color: silver
		min-hint: 'init
;		max-hint: either resize [(gui-metric 'work-size) - (gui-metric 'title-size) - (2 * gui-metric 'border-size)][to lit-word! 'auto]
		max-hint: (gui-metric 'work-size) - (gui-metric 'title-size) - (2 * gui-metric 'border-size)
		; pane-align: 'center max-hint: reduce [guie/max-coord 'auto]]
		names: true
		shortcut-keys: [
			#"^[" [
				all [
					arg/window/data
					close-window arg/window/data
				]
			]
		]
	] any [opts []]

	get-face win-gob/data
]

alert: func [
	"Open an alert reqeustor."
	message [string! block!]
][
	request/warn "Alert" reform message
]

locate-popup: funct [
	"Return the absolute coordinates for a popup below the given face."
	face [object!]
][
	set [gob: xy:] map-gob-offset/reverse face/gob 0x0
	face/gob/size * 0x1 + gob/offset + xy
]
