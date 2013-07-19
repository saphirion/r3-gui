REBOL [
	Title: "GUI Operations"
	Date: 27-Apr-2010
	Note: "GUI & CORE support functions"
	Version: "$Id$"
]

issue-id: funct [
	"Issue unique id"
	pool [block! map!] "Where to look for issued ids"
][
	id: make string! 8
	loop 8 [append id first random "abcdefghijklmnopqrstuvwxyz0123456789"]
	if map? pool [pool: words-of pool]
	either any [						; issue new ID in case that:
		find pool id 					; 	ID is already issued
		find "0123456789" first id		; 	ID starts with number (can't be used as word!)
	] [issue-id pool][id]
]

inside?: funct [
	"Check if pair is inside two pairs box"
	value				[pair!]
	top-left-corner		[pair!]
	bottom-right-corner	[pair!]
][
	not any [
		(t: value - top-left-corner) <> abs t
		(t: bottom-right-corner - value) <> abs t
	]
]


ifv: func [
	"If condition is true assign block's value to word otherwise keep curent value"
	:value 
	condition 
	then-block
][
	either condition [set value do then-block][get value]
]
if=: func [
	"If condition has value, return it, otherwise evaluate the block."
	condition 
	then-block
][
	either condition [condition] then-block
]
ift: func [
	"If condition is TRUE, evaluates the block. Returns TRUE otherwise."
	condition
	then-block
][
	;useful in ALL [...] ; where you need IF than won't break the flow
	either condition then-block [true]
]

limit: func [ "Limit number in between boundaries"
	number [number!] "Number to limit"
	min-value [number!] "Lower boundary"
	max-value [number!] "Highwe boundary"
][
	min max-value max min-value number
]

limit?: func [ "Return TRUE if number is in between boundaries, FALSE otherwise"
	number [number!] "Number to limit"
	min-value [number!] "Lower boundary"
	max-value [number!] "Highwe boundary"
][
	;NOTE : it should support a mode where min-/max- value is not part of limit
	all [number <= max-value number >= min-value]
]


; support for POPUP style

;move auto-complete to actors? on-search or on-complete ... ?
auto-complete: func [ "Return list of all itemps that begin with the string"
	list [block!] "List of available choices"
	string [char! string!] "String to search"
	/index	"Return index of first match"
	/local len
][
	local: copy []
	string: to string! string
	len: length? string
	forall list [
		all [
			equal? string copy/part to string! list/1 len 
			append local list/1
			index
			return index? list
		]
	]
	either index [none][local]
]

show-tooltip: funct [
	tooltip [object!]
	parent-face [object!]
][
	win: window-face? parent-face
	; hard set below parent-face. handle this outside?
	tooltip/gob/offset: parent-face/gob/size * 0x1 + second map-gob-offset/reverse parent-face/gob 1x1
	tooltip/style: 'tooltip
	; there's nothing like expand-layout, so I have to do this ?
;	append win/faces tooltip
	append win/gob tooltip/gob
	show tooltip/gob
]

hide-tooltip: funct [
	face [object!] "Face from window where to close tooltip" ; is it needed?
][
	win: window-face? face
	faces: faces? win
	; hide all tooltips:
	until [
		either all [tt: first faces 'tooltip = tt/style] [
			tt: tt/gob
			tt/alpha: tt/color: tt/draw: tt/image: tt/text: tt/pane: none
			show tt
;			remove win/faces
			remove at win/gob index? faces
		][
			faces: next faces
		]
		tail? faces
	]
;	win/faces: head win/faces
]

show-popup: funct [ "Displays a popup view"
	popup [gob! block! object!] "Popup gob, VID face, or VID layout block"
	parent-face [object!] "Parent face that opens popup"
	/offset offs
	/size siz
][
	main-win: window-face? parent-face
	if not siz [
		siz: as-pair parent-face/gob/size/x 120
	]
	off: main-win/gob/offset + (second map-gob-offset/reverse parent-face/gob 1x1) + (0x1 * parent-face/gob/size) - 0x2
	if offs [off: off + offs]
	guie/popup-parent: parent-face ; moved before or view, or doesn't work
	show-now	;update all possible queued faces now, before the popup is opened
	;it's not possible to use place-popup here
	popup: view/options popup [
		owner: main-win/gob					;this needs to be defined so the POPUP flag works correctly -Richard
		flags: [popup on-top no-title]		;use the POPUP flag so it doesn't open new window-bar
		as-is: true
		offset: off
		init-hint: siz - 2x0
	]

	guie/popup-face: popup/data
	guie/popup-parent: parent-face	; must be moved up, see above
	guie/popup-face
]

hide-popup: funct [
	"Close popup view"
][
	if guie/popup-face [
		unview/only guie/popup-face
		unhandle-events guie/popup-face/handler
		guie/focal-face:
		guie/popup-face: 
		guie/popup-parent: none
	]
]

do-popup-parent: func [
	"Call a popup's parent style actor function."
	act [word!] "Actor identifier"
	data "Argument to the actor (use block for multiple args)."
][
	do-actor guie/popup-parent :act :data
	do-face guie/popup-parent
]

place-popup: funct [
	"Place popup where the popup's parent is."
][
	main-win: window-face? guie/popup-parent
	guie/popup-face/gob/offset: main-win/gob/offset + (second map-gob-offset/reverse guie/popup-parent/gob 1x1) + (0x1 * guie/popup-parent/gob/size) ; + system/view/metrics/title-size
	; show is left to outside functions right now
	; if it's more efficient to place it here, it will be done
]

get-style-actors: funct [
	style-name [word!]
][
	style: select guie/styles style-name
;	print type? style/actors
	words-of style/actors
]

catenate: funct [ "Joins values with delimiter."
	src [block!]
	delimiter [char! string!]
][
	out: make string! 20
	forall src [repend out [src/1 delimiter]]
	head remove back tail out
]