REBOL [
	Title: "R3 GUI - GUI system object"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
	Date: 19-Mar-2011/13:02:29+1:00
]

;-- GUI Environment -----------------------------------------------------------

guie: context [
	; This is the system GUI object used for GUI-global lists and objects.

	; the maximal pair of 32-bit IEEE 754 binary floating point numbers
	max-pair: as-pair 3.4028235e38 3.4028235e38
	; the maximal 32-bit IEEE 754 binary floating point number
	max-coord: max-pair/x
	
	debug: []    ; debugging flags, eg: [draw] (grep for debug-gui for others)
	remind: off  ; special reminders (development mode)

	styles:  make map! 30     ; GUI catalog of styles (classes)
	fonts:   make map! 20     ; GUI font definitions
	dialect: make object! 50  ; GUI dialect grammar
	shows:   make block! 20   ; GOBs queued to show (after all events processed)
	tags:    make map! 20     ; list of valid GUI tags
	colors:                   ; GUI colors
	
	box-models:               ; default box-model presets
	
	focal-face:               ; The focus (face) to receive key events

	popup-face:				  ; holds popup window
	popup-parent:			  ; holds popup's parent face
	
	drag:                     ; object used for tracking drag events

	style:                    ; object prototype style object
	font:                     ; object prototype font style object
	face:                     ; object prototype face object
	face-state:               ; object prototype face/state object

	char-space:               ; charset: key event space
	char-valid:               ; charset: key event non-space
		none

	handler: none             ; GUI event handler
	
	error-handler: none		  ;global error handler
	
	timeout: false			  ; timeout flag for timer handling
	timer-id: 0				  ; timer id counter
	timers: []				  ; holds timer(s) data
	
	;note: following values can be set also per face (in FACETS block)
	tool-tip-delay: 1		  ; default delay (in seconds) for tool-tip popup
	tool-tip-timeout: none	  ; default timeout (in seconds) for tool-tip hiding - NONE = keep tool-tip visible until mouse is over the specific face
	tool-tip-follow: false	  ; if enabled tool-tip follows the mouse pointer when visible
	
	font-sans: switch system/version/4 [
		3 [
			"Arial"
		]
		13 [
			"/system/fonts/DroidSans.ttf"
		]
	]
	font-serif: switch system/version/4 [
		3 [
			"Times New Roman"
		]
		13 [
			"/system/fonts/DroidSerif.ttf"
		]
	]
	font-mono: switch system/version/4 [
		3 [
			"Courier new"
		]
		13 [
			"/system/fonts/DroidMono.ttf"
		]
	]
]

guie/style: object [
	; Styles implement the look and feel of GUI objects.
	; NOTE: If you add to this, you MUST add to MAKE-STYLE too.
	name:    ; WORD!   - style's name (identifies the style)
	facets:  ; OBJECT! - the modifyable attributes of the style (properties)
	draw:    ; BLOCK!  - draw block with facet words (from face and style)
	actors:  ; MAP!    - face actor functions (e.g. on-click, on-resize)
	tags:    ; MAP!    - face tags (determines type and state of face)
	options: ; OBJECT! - prototype of face/options object
	parent:  ; WORD!   - parent style (if specified)
	state:   ; BLOCK!  - prototype of (extensions to) face/state object
	intern:  ; OBJECT! - context for internal 'static values' used in the style (shared between all face instances)
	content: ; BLOCK!  - layout for composite styles
		none

	about: "Not documented."
]

guie/face: object [
	; Faces hold the state and options of instances of a style.
	style:   ; WORD!   - name of the style for this face
	facets:  ; OBJECT! - properties unique to this face
	state:   ; OBJECT! - state variables (not properties)
	gob:     ; GOB!    - graphical object(s) for this face
	options: ; OBJECT! - optional facet changes as specified
	tags:    ; MAP!    - tags for this face

	; NOTE: optionally extended in face creation with:
	;name    ; WORD!   - reference name
	;reactors; BLOCK!  - block of user actions
	;targets ; BLOCK!  - faces which the face targets to attach
	;attached; BLOCK!  - faces which are attached TO the face

	; LAYOUT faces also add:
	;trigger-faces; BLOCK!  - faces which reacts on triggers in layouts
]

guie/face-state: object [
	;prototype of face/state (face instance state)
	mode: 'up
	over: no
	value: none
]

guie/style/facets: object [
	;prototype of face/facets (face instance facets)

	;inital size
	init-size: 100x100
	
	;lower limit of face size
	min-size: 0x0

	;upper limit of face size
	max-size: guie/max-pair

	;face alignment
	align: 'left
	valign: 'top
	
	;is the face handled by resizing system?
	resizes: true

	; BOX-MODEL preset
	box-model: 'tight

	;shortcut for face/gob
	gob: none
	
	;shortcut for face/gob/size
	gob-size: none

	;sum of margin, padding and border sizes
	space: [0x0 0x0]
	
	;positional keywords used in DRAW block
	margin-box: [
		top-left: 0x0
		top-right: 0x0
		bottom-left: 0x0
		bottom-right: 0x0
		center: 0x0
	]
	border-box: copy margin-box
	padding-box: copy margin-box
	viewport-box: copy margin-box
]

;box-model presets

guie/box-models: reduce/no-set [
	tight: object [
		border-color: none
		border-size: [0x0 0x0]
		bg-color: none
		margin: [0x0 0x0]
		padding: [0x0 0x0]
		spacing: 0x0
	]

	layout: object [
		border-color: none
		border-size: [0x0 0x0]
		bg-color: none
		margin: [0x0 0x0]
		padding: [3x3 3x3]
		spacing: 5x5
	]
	
	frame: object [
		border-color: coal
		border-size: [1x1 1x1]
		bg-color: none
		margin: [0x0 0x0]
		padding: [3x3 3x3]
		spacing: 5x5
	]
]

guie/drag: context [
	; Stores the state of an object when it is dragged:
	face:    ; OBJECT! - the down-click face that orignated the drag
	event:   ; EVENT! - current event
	start:   ; PAIR! - window-relative starting offset
	delta:   ; PAIR! - difference from above START offset
	base:    ; any - base reference value
	base-offset: ; PAIR! - base offset of face (so it has a place to return)
	gob:     ; GOB! - graphical object that moves during drag
	origin:  ; BLOCK! - pane where drag originated
	data:    ; any - optional user defined data 
		none
	active:  false ; LOGIC! - drag has started (mouse has moved)		
	show-parent?: true	; Draw optimization flag
; Trimmed these for now:
;   lower:   ; PAIR! - lower bounds (relative)
;   upper:   ; PAIR! - upper bounds (relative)
;   offset:  ; PAIR! - gob starting offset (relative)
;   value:   ; PERCENT! - position
;	none
]

; Default GUI dialect words. (Others are added via make-style)
append guie/dialect [
	default: [set-word!]  ; For parsing:  name: (name of face)
	options: [block!]     ; Provide optional facets as variables
	divider: []           ; used for setting dividers in layouts
	resizer: []           ; used for setting resizers in layouts
	attach: [word! lit-path!]       ; used for interconnecting faces
	debug: [block!]       ; Special debug options	
	return: []			  ; used for group formatting
]

; Default GUI colors
guie/colors: context [
	focus:	50.160.250
]

; Cursor equates:
;!! This is windows specific. Abstract it somehow.
system-cursors: context [
	app-start: 32650
	hand: 32649
	help: 32651
	hourglass: 32650
	arrow: 32512
	cross: 32515
	i-shape: 32513
	no: 32648
	size-all: 32646
	size-nesw: 32643
	size-ns: 32645
	size-nwse: 32642
	size-we: 32644
	up-arrow: 32516
	wait: 32514
]

