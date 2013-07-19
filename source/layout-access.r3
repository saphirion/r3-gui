REBOL [
	Title: "R3 GUI - Layout: access methods"
	Purpose: {
		Provides access to layouts as a collection of faces.
		For example, to get the current values for all its faces,
		or to set or clear those faces.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id: layout-access.r3 2165 2011-03-18 12:51:02Z cyphre $"
]

set-layout: funct [
	"Set layout input face values from an object of values."
	layout [object!]
	values [object!]
][
	faces: faces? layout
	foreach face faces  [
		either tag-face? face 'layout [
			set-layout face values
		][
			all [
				in face 'name ; only faces with names
				tag-face? face [info edit state]
				val: get in values face/name
				set-face face val
			]
		]
	]
]

get-layout: funct [
	"Get layout input face values as an object."
	layout [object!]
][
	out: make object! []
	foreach face any [f: faces? layout to-block layout] [
		if tag-face? face [info edit state] [
			if select face 'name [
				repend out [to-set-word face/name get-face face]
			]
		]
		if f [
			out: make out get-layout face
		]
	]
	foreach face select layout 'trigger-faces [
		if tag-face? face [info edit state] [
			if in face 'name [
				extend out face/name get-face face
			]
		]
	]
	out
]

clear-layout: func [
	"Clear layout input face values."
	layout [object!]
][
	foreach face faces? layout [
		either tag-face? face 'layout [
			clear-layout face
		][
			all [
				tag-face? face [info edit state]
				do-actor face 'on-clear none
			]
		]
	]
]

get-parent-layout: funct [
	"Get layout input faces for the contextual parent layout."
	face
][
	; Move up the tree until we hit a layout namespace:
	while [not select face 'names][
		unless f: parent-face? face [break]
		face: f
	]

	get-layout face
]

get-layout-var: funct [
	"Get the value of a top level layout/names local variable."
	layout [gob!] "The window gob"
	name [word!]
][
	all [
		p: layout/data
		p: first faces? p
		p: p/names
		p/:name
	]
]

