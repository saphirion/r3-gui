REBOL [
	Title: "R3 GUI - Face: navigation"
	Purpose: {
		Provides navigation functions to navigate the face tree.
	}
	Version: "$Id$"
	Date: 27-Jan-2011/16:29:23+1:00
]


sub-gob?: func [
	"Return face's internal area gob."
	face [object!]
] [
	face/gob/1
]

parent-face?: func [
	"Return face's parent or none for top face."
	face [object!]
][
	all [
		face/gob/parent
		face/gob/parent/data
	]
]

window-face?: funct [
	"Return window face where face belongs."
	face [object!]
][
	all [
		gob: map-gob-offset/reverse face/gob 1x1
		gob: first gob
		find system/view/screen-gob gob		;sanity check in case gob is not part of any window structure
		gob/data
	]
]

root-face?: funct [
	"Returns whether the face is a root face"
	face [object!]
] [
	face/style = 'window
]

tip-face?: funct [
	"Travels inward through all last faces in starting at the given face and returns the innermost one."
	face [object!]
] [
	if empty? faces: faces? face [return face]
	last-face: last faces
	tip-face: none
	until [
		faces: faces? last-face
		either empty? faces [
			tip-face: :last-face
		][
			last-face: last :faces
		]
		tip-face
	]
]

return-face?: funct [
	"Returns the next possible face outward and then forward in the hierarchy"
	face [object!]
] [
	unless face/gob/parent [return face]
	return-face: none
	fp: parent-face? face
	until [
		either root-face? fp [
			return-face: fp
		][
			faces: locate-face fp
			either all [faces single? faces] [
				fp: parent-face? fp
			][
				return-face: faces/2
			]
		]
		return-face
	]
]

locate-face: funct [
	"Locate the index for the given face in the parent face block"
	face [object!]
	/reverse "Find backwards"
] [
	fp: parent-face? face
	fpp: if fp [faces? fp] ; no support for multiple faces blocks yet
	if block? fpp [find fpp face]
]

;- General navigation functions

back-face?: funct [
	"Returns the face before this one."
	face [gob! object!]
	/no-recurse
] [
	if gob? face [face: face/data]
	if root-face? face [return tip-face? face]
	faces: locate-face face
	if head? faces [return parent-face? face]
	either no-recurse [first back faces][tip-face? first back faces]
]

next-face?: funct [
	"Returns the face after this one."
	face [gob! object!]
	/no-recurse
] [
	if gob? face [face: face/data]
	if any [root-face? face all [not no-recurse not empty? f: faces? face]] [return first any [f faces? face]]				; first face inside this face
	faces: locate-face face									; current position
	any [
		faces/2												; next face
		return-face? face
	]
]

find-face?: funct [
	"Deeply find the next face from specs relative to the given face."
	face [gob! object!]
	spec
	/reverse "Find backwards"
	/no-recurse "disable recursion"
	/only "disable recursion only for the first searched face"
] [
	fc: either gob? face [face/data][face]
	all [only no-recurse: true]
	until [
		face: apply either reverse [:back-face?][:next-face?] [face no-recurse]
		all [
			only
			only: no-recurse: false ;allow recursion after first next/back face
		]
		any [
			face = fc ; if loop hits the beginning face itself, stop looping
			do bind spec 'face
		]
	]
	if face <> fc [face]
]

traverse-face: funct [
	"Traverses a face deeply and performs a function on each subface."
	face [gob! object!]
	action
	/only these-faces
] [
	if gob? face [face: face/data]
	if empty? faces? face [return face]
	last-face: tip-face? face
	func-act: func [face] action
	these-act: all [only func [face] these-faces]
	until [
		face: next-face? face
		all [
			any [not only these-act face]
			func-act face
		]
		same? last-face face
	]
]

within-face?: funct [
	"Returns whether a face exists within another face."
	child [gob! object!]
	parent [gob! object!]
] [
	if gob? child [child: child/data]
	result: false
	traverse-face parent [result: any [result face = child]]
	to-logic result
]

find-tab-face?: funct [
	"Return the next tab face in the window face for the given tab face"
	tab-face [object!]
	/reverse
	/no-recurse
] [
	if reverse [
		lf: tab-face
		until [
			f: back-face?/no-recurse lf
			unless tag-face? f 'eat-tab [
				f: back-face? lf
			]
			tag-face? lf: f 'tab
		]
		no-recurse: tag-face? f 'eat-tab
	]
	apply :find-face? [tab-face [all [tag-face? face 'tab face/gob/size <> 0x-1]] reverse all [reverse no-recurse] all [not reverse no-recurse]]
]

compound-face?: funct [
	"Return the compound face for an existing face, or the face itself, if no face is found"
	face [object! gob!]
] [
	if gob? face [face: face/data]
	fc: face
	until [
		face: parent-face? face
		any [root-face? face found: tag-face? face 'compound]
	]
	either found [face][fc]
]

find-access-key: funct [
	face [object!]
	id [char!]
][
	if all [
		win: window-face? face
		access-keys: select win/facets 'access-keys
	][
		any [
			key: find/skip next access-keys id 2
			parse access-keys [
				some [
					block! ak: block! (
						all [
							key: find/skip next ak/1 id 2
							break
						]
					)
					| skip
				]
			]
		]
	]
	all [key first back key]
]

process-access-key: funct [
	"Process access key if available"
	event [event!] "Keyboard event"
][
	if event/flags <> [control shift][return none]
	win: event/window/data
	;convert control chars
	if all [
		char? event/key
		32 > to integer! key: event/key
	][
		key: to char! key + 64
	]
	either access-keys: select win/facets 'access-keys [
		id: any [
			select/skip access-keys key 2
			all [
				not find/skip next access-keys key 2
				key
			]
		]
	][
		id: key
	]

	if all [
		id
		f: find-face? win [id = select face/facets 'access-key]
	][
		f: any [
			get select f/facets 'access-face
			f
		]
		focus f
		;execute default action for non-editable faces
		unless tag-face? f 'edit [
			e: make event! [
				type: 'key
				key: #" "
			]
			do-actor f 'on-key e
		]
		f
	]
]

process-shortcut-key: funct [
	"Process shortcut key if available"
	event [event!] "Keyboard event"
][
	if all [
		win: event/window/data
		shortcut-keys: select win/facets 'shortcut-keys
		action: select/skip/case shortcut-keys event/key 2
	][
		not 'propagate-event = do funct [arg] action event
	]
]

process-tab: funct [ ; may need better name
	"Process tab key (move focus)"
	event [event! object!] "Keyboard event (tab key) or event compatible object."
][
	;ignore command when Ctrl is active
	if find event/flags 'control [return none]

	win: event/window/data

	;get the actual tab-face
	unless tab-face: get-facet win 'tab-face [
		;set-facet win 'tab-face
		tab-face: win
	]

	if tag-face? tab-face 'detab [
		return 'propagate-event
	]

	;special case - focus again the face that has been unfocused last time (by pressing Esc or clicking outside etc.)
	if all [
		tab-face <> win
		tab-face <> guie/focal-face
	][
		focus tab-face
		exit
	]

	shift-key: found? find event/flags 'shift

	; find new tab-face and focus it
	if new-tab-face: apply :find-tab-face? [tab-face shift-key tag-face? tab-face 'eat-tab] [
		switch focus/actor-result new-tab-face [
			propagate-event [
				return 'propagate-event
			]
			stop-event [
				return 'stop-event
			]
		]
		tab-face: new-tab-face
	]
	
	tab-face
]

faces?: funct [
	{Get a block of faces in a layout}
	face [object!]
][
	face: face/gob
	result: make block! length? face
	repeat i length? face [
		sg: face/:i
		if same? sg sg/data/gob [append result sg/data]
	]
	result
]

foreach-face: closure [
    "Evaluates the BODY block for each subface in the layout."
    'word [word!] "Word to set each time (local)"
    layout [object!] "The layout to traverse"
    body [block!] "Block to evaluate each time"
    /local sg result
][
	word: repeat (word) 1 reduce [:quote word]
	body: bind/copy body word
	layout: layout/gob
	repeat i length? layout [
		sg: layout/:i
		if same? sg sg/data/gob [
			set word sg/data
			set/any 'result do body
		]
	]
	get/any 'result
]

has-faces?: funct [
	"Finds out whether the face has content"
	face [object!]
][
	face: face/gob
	repeat i length? face [
		sg: face/:i
		if same? sg sg/data/gob [return true]
	]
]
