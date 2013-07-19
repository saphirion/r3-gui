REBOL [
	Title: "R3 GUI - Debug related functions"
	Note: "Some of these can be removed before release."
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
]

debug-gui: func [
	"GUI debugging function. Allows selective enabling."
	tag [word!] "Debug category"
	args [block! string!] "Values to print."
][
	if any [find guie/debug tag find guie/debug 'all] [
		;tag face action data
		args: reduce args
		if object? args/1 [args/1: args/1/style]
		print ['-- tag args]
	]
	true
]

;!! Temporary error functions (later, use ERROR objects)
fail-gui: func [msg] [
	print ["^/** GUI ERROR:" reform msg]
	halt
]

warn-gui: func [msg] [
	print ["^/** GUI WARNING:" reform msg]
	none ; return
]

assert-gui: func [cond msg] [
	unless cond [fail-gui msg]
]

; Remind: for things we need to remember to fix or examine:
remind-gui: func [body /when cond] [
	if all [
		guie/remind
		any [not when cond]
	][
		print ["-- remind:" reform body]
	]
]

debug-face: func [
	; Special debug function (Decide: remove before release??)
	face
	word
	block
	/local flags style
][
	; If FACE or STYLE contains DEBUG variable, then search it for WORD
	; and print the block if WORD is found.
	if all [
		any [
			flags: select face 'debug
			all [
				style: select guie/styles face/style
				flags: select style 'debug
			]
		]
		any [
			not block? flags
			find flags word
		]
	][
		print ajoin ["-- debug-face[" face/style ":" word "]: " remold block]
	]
]

dump-face: func [face /indent d] [
	print [
		any [d ""]
		to-set-word face/style
		face/gob/offset
		"size:" face/gob/size
		;;"nats:" face/facets/size
		any [select face 'name "*"]
		mold any [select face/facets 'text-body "*"]
	]
]

dump-layout: func [layout /indent d] [
	unless d [d: copy ""]
	dump-face/indent layout d
	;print [d to-set-word layout/style layout/facets/size layout/]
	insert d "  "
	foreach-face f layout [
		either find [panel group] f/style [
			dump-layout/indent f d
		][
			dump-face/indent f d
		]
	]
	remove/part d 2
]
