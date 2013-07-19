REBOL [
	Title: "R3 GUI - Event: event funcs"
	Purpose: {
		Support functions for events.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
]

base-handler: context [
	do-event: func [event] [ ; at top for performance
		print "(Missing event handler)"
		event
	]
	win-gob: none
	status: 'made
	name: 'no-name
	priority: 0
	about: "Main template for VIEW event handlers."
]

handle-events: func [
	"Adds a handler to the view event system."
	handler [block!]
	/local sys-hand
][
	handler: make base-handler handler
	sys-hand: system/view/event-port/locals/handlers
	; Insert by priority:
	unless foreach [here: hand] sys-hand [
		if handler/priority > hand/priority [
			insert here handler
			break/return true
		]
	][
		append sys-hand handler
	]
	handler/status: 'init
	debug-gui 'handler ["added for:" handler/name]
	handler
]

unhandle-events: func [
	"Removes a handler from the view event system."
	handler [object!]
][
	remove find system/view/event-port/locals/handlers handler
	exit
]

handled-events?: func [
	"Returns event handler object matching a given name."
	name
][
	foreach hand system/view/event-port/locals/handlers [
		if hand/name = name [return hand]
	]
	none
]

wake-events: funct [
	"Awake the prior DO-EVENTS WAIT call."
	handler
][
	handler/status: 'wake ; cause it to self terminate
]

do-events: funct [
	"Waits for window events. Returns when all windows are closed."
][
	wait-block: reduce [system/view/event-port 0 none]	;port timeout timer-id
	update-timers: does [
		either tail? guie/timers [
			;no other timers left - reset values
			wait-block/2:
			wait-block/3: none
		][
			;set next timer values
			wait-block/2: max 0 to decimal! difference guie/timers/2/timeout now/precise
			wait-block/3: guie/timers/1
		]
	]
	err: none
	if error? set/any 'err try [
		forever [
			either system/view/event-port = wait wait-block [
				either guie/timeout [
					;set new timer
					update-timers
				][
					;end of WAIT loop
					break
				]
			][
				;do timer callback
				if all [
					wait-block/3
					pos: find/skip guie/timers wait-block/3 2
				][
					timer: second pos
					timer/callback
					either timer/rate [
						;periodic timer - update timeout
						timer/timeout: timer/timeout + timer/rate
						sort/skip/compare guie/timers 2 2
					][
						remove/part pos 2
					]
				]

				update-timers
			]
			guie/timeout: false
		]
	][
		either guie/error-handler [
			do funct [error [error!]] guie/error-handler err
			do-events
		][
			do err
		]
	]
]

set-timer: funct [
	"Calls a function after a specified amount of time. Returns timer ID reference."
	code [block!]
	timeout [number! time!]
	/repeat "Periodically repeat the function."
][
	t: now/precise
	if number? timeout [timeout: to time! timeout]
	sort/skip/compare append guie/timers compose/deep/only [
		(id: guie/timer-id: guie/timer-id + 1)
		[
			timeout (t + timeout)
			rate (all [
				repeat
				max 0:0:0 timeout
			])
			callback (funct [] code)
		]
	] 2 2
	guie/timeout: true
	id
]

clear-timer: func [
	"Clears a timer set with the SET-TIMER function."
	timer-id [integer!]
][
	remove/part find/skip guie/timers timer-id 2 2
	guie/timeout: true
]

init-view-system: func [
	"Initialize the View event subsystem."
	/local ep
][
	;initialize the low level graphics system
	init system/view/screen-gob: make gob! [text: "Top Gob"]

	; Already initialized?
	if system/view/event-port [exit]

	; Open the event port:
	ep: open [scheme: 'event]
	system/view/event-port: ep

	; Create block of event handlers:
	ep/locals: context [handlers: copy []]

	; Make the event handler for the view system:
	ep/awake: funct [event] [

		; WARNING: high performance code

		; Obtain face or handler object, do event handling:
		either all [
			obj: event/window/data
			obj: select obj 'handler
		][
			;print ["Do-event" event/type "for:" obj/name]
			event: obj/do-event event
			if guie/timeout [
				;new timer has been set - awake from WAIT loop
				return true
			]
		][
			print "A mystery GUI event?"
			halt
		]

;		handlers: event/port/locals/handlers
;		forall handlers [
;			; Handlers should return event in order to continue.
;			h: handlers/1
;			if event/window = h/win-gob [
;				unless event? event: h/handler event [break]
;			]
;		]

		; If event is the word WAKE, then terminate the WAIT:
		if obj/status = 'wake [
			obj/status: 'awake
			unhandle-events obj
			debug-gui 'handler ["Awake from WAIT:" obj/name]
			return true ; awake from WAIT function
		]

		; If there are no windows, we should awake from WAIT:
		tail? system/view/screen-gob
	]
]