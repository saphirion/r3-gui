REBOL [
	Title: "R3 GUI - Style: action"
	Purpose: {
		These are the main functions for evaluating style related code.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Notes: [
		"BB - do-actor changed to return event back"
	]
	Version: "$Id$"
	Date: 10-Jan-2011/16:50:25+1:00
]

do-actor: funct [
	"Call actor function of face or style."
	faces [block! object!] "Face or block of faces"
	act [word!] "Actor identifier"
	data "Argument to the actor (use block for multiple args)."
	/style	"Do actor from other style only"
		style-name [word!] "Style for actor"
	/bubble "Allow event to bubble up if specified actor not found"
][
;	unless find [on-draw on-resize on-over on-move on-init] act [print ["do-actor" act faces/style]]
	result: none
	out: copy []
	blockified?: unless block? faces [faces: append copy [] faces]

	foreach face faces [
		result: none
		actor: none
		all [
			style: select guie/styles any [style-name face/style]
			any [
				actor: any [
					all [not style-name select select face 'actors act]
					all [style/actors select style/actors act]
				]
				result: false ; we need to notify event-handler that there's no actor and parent-face should be processed
			]
			set/any 'result actor face :data
		]
		if unset? :result [result: none] ; and change it to none

		all [
			bubble
			none? :actor
			face/gob/parent
			face/gob/parent/data
			result: apply :do-actor [face/gob/parent/data act data any [style-name] style-name bubble]
		]

		append/only out :result
	]
	either blockified? [:out/1][out] ; for single face, return direct value, not block
]

do-face: funct [
	"Execute standard action sequence of a face"
	face [object!]
	/from
		src-face [object!]
	/no-show
][
;	print ["DO-FACE" select face 'name "FROM" all [from select src-face 'name]]
;	foreach dst-face select face 'targets [
;		all [not object? dst-face dst-face: get dst-face]
	targets: select face 'targets	
	forall targets [
		dst-face: targets/1: get-target face targets/1
		all [
			src-face <> dst-face
			dst-face/attached-face: f: any [src-face face]
			do-actor f 'on-attached reduce [dst-face no-show]
			none? dst-face/attached-face: none
			apply :do-face [dst-face from f no-show]
		]
	]
;print ">>"
;set 'fac face
;? face
	unless no-show [do-actor face 'on-action get-face face]
;print "<<"	
;	print "DO-FACE end"
]

has-actor?: func [
	"Return true if face/style has this actor."
	face [object!]
	act [word!] "Actor identifier"
][
	true? any [
		select select face 'actors act
		select select select guie/styles face/style 'actors act
	]
]

do-related: funct [
	"Find related faces and call their specified actor id."
	face ;[object!] checked earlier
	related [word! block!]
	/deep "nested traversal"
	/from "traverse form specific face"
		beg-face [object!]
][
	; Related field can be symbolic (a word):
	if word? related [
		if parent: any [beg-face parent-face? face] [
			foreach fac faces? parent [
				do-actor fac related face
				if all [
					deep
					has-faces? fac
				][
					do-related/deep/from face related fac
				]
			]
		]
	]

	; Or, related field can be block of [word face] pairs:
;	if block? related [
;		foreach [act fac] related [do-actor fac act face]
;	]
]

do-targets: funct [
	"Do all target faces to update them."
	face [object!]
	/custom "Do custom action instead"
		action [block!]
][
;	print ["DO-targets" face/name]
;	foreach target select face 'targets [
;		all [not object? target target: get target]
	targets: select face 'targets	
	forall targets [
		target: targets/1: get-target face targets/1
		either custom [
			do bind action 'target
		][
			do-face/from target face
		]
	]
;	print "DO-targets END"
]

do-attached: funct [
	"Do all attached faces to update them."
	face [object!]
	/custom	"Add custom code for specific style"
		data	"Tagged block [ style-name [custom-code] ]"
][
;	print ["DO-ATTACHED" face/name]
	foreach attached select face 'attached [
		all [not object? attached attached: get attached]
		if all [
			custom 
			c: select data attached/style 
		][
			do bind c 'attached
		]
		do-face/from attached face
;		do-actor attached 'on-action none
	]
]

find-face-actor: funct [
	"Find the next (or prior) face that responds to the given actor."
	face [object!]
	act [word!]
	/reverse
][
	dir: pick [-1 1] true? reverse
	if all [
		parent: parent-face? face 
		faces: find faces? parent face
	][
		faces: skip faces dir
		forskip faces dir [
			if has-actor? first faces act [return first faces]
		]
	]
]

do-bind-actor: funct [face actor-block][
	;we try to bind the actor function body to the parent namespace (if exists)
	;layout's actors are bound also to own local namespace (overwrites possible parent bindings)
	all [
		pf: parent-face? face
		in pf 'names
		actor-block: bind/copy actor-block pf/names
	]
	all [
		in face 'names
		actor-block: bind/copy actor-block face/names
	]
	do actor-block
]

get-target: funct [
	face [object!]
	target [object! word!]
	;INTERNAL function
][
	unless object? target [
		target: any [
			all [
				cf: compound-face? face
				in cf 'names
				select cf/names target
			]
			get target
		]
	]

	unless all [
		in target 'attached
		find target/attached face
	][
		extend-face target 'attached face
		do-actor target 'on-attach face
	]
	
	unless in target 'attached-face [
		extend target 'attached-face 0
		target/attached-face: none
	]
	target
]

bind-targets: funct [
	;INTERNAL function
	layout [object!]
][
	foreach f faces? layout [
		targets: select f 'targets
		forall targets [
			targets/1: get-target f targets/1
		]
		bind-targets f
	]
]

make-actors: funct [
	; INTERNAL: make the style/actor map.
	parent
	actors ; name: [block]
][
	map: either parent [copy parent/actors][make map! 4]
	unless parse actors [
		any [
			here:
			set-word! block! (
				repend map [here/1 funct/closure [face arg] here/2]
			)
		]
	][
		fail-gui ["Bad style actor:" here]
	]
	map
]

;-- Standard Actors -----------------------------------------------------------
;
;   These are the default actors for all styles. May be overridden.

guie/style/actors: make-actors none [

	locate: [ ; arg: event
		; Generic: returns location during mouse position mapping.
		arg/offset
	]

	on-resize: [ ; arg: size
		; simple resize for all GOBs

		if any [face/facets/resizes face/gob/size <> 0x-1][
			if all [
				in face/facets 'intern
				in face/facets/intern 'update?
				face/facets/intern/update?
			][do-actor face 'on-update none]
			set-draw-keywords-in face/facets arg
		]

		unless face/gob/size = 0x-1 [face/gob/size: face/facets/gob-size]
	]

	on-get: [ ; arg: the field to get
		select face/state arg ; Should this be face/state/:arg which would error if missing?
	] ;default

	on-action: [ ;arg: face value (using get-face)
	]
	
	on-attached: [	;arg: dst-face no-show-flag
;		print ["ON-ATTACHED set" arg/style "get" face/style]
		apply :set-face [arg/1 get-face face arg/2]
		true
	]
	
]

