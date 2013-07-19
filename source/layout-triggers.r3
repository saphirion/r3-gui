REBOL [
	Title: "R3 GUI - Layout: triggers"
	Purpose: {
		Layout triggers are actions that occur when specific
		layout events occur. The WHEN triggers for example.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

bind-faces: funct [
	; INTERNAL: collect and bind all layout names (including sublayouts):
	layout
][
	unless get-facet layout 'names [exit]
	names: make object! 4
	find-layout-names layout names
	extend layout 'names names
;	probe words-of names
	bind-layout-acts layout names
]

find-layout-names: funct [
	; INTERNAL: collect face names for all child faces
	layout [object!]
	names [object!]
][
	faces: faces? layout 
	trigger-faces: select layout 'trigger-faces
	; The presence of face/name field indicates a var:
	foreach field [faces trigger-faces] [
		foreach face get field [
			if item: select face 'name [
				repend names [item face]
				;bind the name word so it always bounds to the layout/names context
				face/name: bind item names
			]
		]
	]

	; Nest search into all sublayouts:
	foreach face faces? layout [
		if all [
			not empty? faces? face
			not get-facet face 'names ; a separate name space
		][
			find-layout-names face names
		]
	]
]

bind-layout-acts: funct [
	; INTERNAL: bind face acts to layouts names context
	layout
	names [object!]
][
	faces: faces? layout
	trigger-faces: select layout 'trigger-faces
	; Bind all acts of all layout:
	foreach field [faces trigger-faces] [
		foreach face get field [	
			if item: select face 'reactors [
				bind item names
			]
		]
	]

	; Nest into all sublayouts:
	foreach face faces? layout [
		if all [
			not empty? faces? face
			not get-facet face 'names ; a separate name space
		][
			bind-layout-acts face names
		]
	]
]

do-triggers: funct [
	"Process all layout triggers of a given type."
	layout [object!]
	id [word!] "Type of trigger"
	/arg "optional arg value passed to trigger call"
		arg-value [any-type!]
	/once "immediately return the result of first triggered reactor"	
	/no-recursive "don't recurse into sub-layouts"		
][
	result: none
;	changes: none
	foreach face select layout 'trigger-faces [
		if all [
			triggers: select face/facets 'triggers
			find triggers id
		][
;			print [id 'trigger face/style]
;			changes: true
			set/any 'result do-actor face 'on-action any [arg-value get-face face]
			all [once return either none? :result [false][:result]]
		]
	]

	unless no-recursive [
		; Nest into sub-layouts:
		foreach-face sub-face layout [
			unless all [
				empty? faces? sub-face
				empty? select sub-face 'trigger-faces
			][
;			unless has-faces? sub-face [
				set/any 'result apply :do-triggers [sub-face id arg arg-value once false]
				;if the result is not NONE trigger has been detected -> return the result in ONCE mode
				all [once not none? :result return :result]
			]
		]
	]
	
	;Removed line below, because it will glitch switch-layout
	;by forcing the display to show.
	;if changes [show-now] ; is this overkill? (putting it here)
	
	;propagate the result
	result
]
