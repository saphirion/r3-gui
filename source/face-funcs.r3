REBOL [
	Title: "R3 GUI - Face: misc. functions"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
	Date: 23-Jul-2012/14:15:14+2:00
]

resize-face: func [
	{adjust the size of the given FACE}
	face [object!]
	size [pair!]
	/no-show "do not update and show the parent layout"
] [
	; update the size of the face
	face/facets/gob-size: size
	
	either no-show [
		reinit/no-show face 
	] [
		reinit face
	]
]

reinit: func [
	{update the init-sizes of the relevant faces using their gob-sizes}
	face [object!]
	/no-show {do not update and show the parent layout}
	/local parent
] [
	; get the relevant parent
	while [
		all [
			parent: face/gob/parent
			parent: parent/data
			face: parent
			auto-sizes? face
		]
	] []

	recursive-reinit face
	
	either no-show [
		update-face/no-show face
	] [
		update-face face
	]
]

recursive-reinit: func [
	face [object!]
	/local gob
] [
	either all [in face/facets 'intern in face/facets/intern 'update?] [
		; looks like a layout
		if face/facets/gob-size [
			case [
				pair? face/facets/init-hint [
					face/facets/init-hint: face/facets/gob-size
				]
				block? face/facets/init-hint [
					if number? face/facets/init-hint/1 [
						face/facets/init-hint/1: face/facets/gob-size/x
					]
					if number? face/facets/init-hint/2 [
						face/facets/init-hint/2: face/facets/gob-size/y
					]
				]
			]
		]
		face/facets/intern/update?: true
		repeat i length? face/gob [
			gob: face/gob/:i
			recursive-reinit gob/data
		]
	] [
		if face/facets/gob-size [face/facets/init-size: face/facets/gob-size]
	]
]

auto-sizes?: func [
	{Find out whether the given LAYOUT auto-sizes.}
	layout [object!]
] [
	any [
		layout/facets/init-hint = 'auto
		layout/facets/min-hint = 'auto
		layout/facets/max-hint = 'auto
		all [
			block? layout/facets/init-hint
			find layout/facets/init-hint 'auto
		]
		all [
			block? layout/facets/min-hint
			find layout/facets/min-hint 'auto
		]
		all [
			block? layout/facets/max-hint
			find layout/facets/max-hint 'auto
		]
	]
]

update-face: funct [
	{Notifies, updates and shows the parents of the given FACE.}
	face [object!]
	/no-show {Do not really update and show.}
	/content {The given FACE is a layout and its contents changed.}
] [
	; the first layout to notify
	layout: either content [face] [
		all [layout: face/gob/parent layout/data]
	]

	; notify the parents
	while [
		all [
			layout
			face: layout
			not face/facets/intern/update?
			face/facets/intern/update?: true
			auto-sizes? face
			layout: face/gob/parent
			layout: layout/data
		]
	] []

	unless no-show [
		; find the topmost layout to update and show
		while [
			all [
				layout: face/gob/parent
				layout: layout/data
				layout/facets/intern/update?
				face: layout
			]
		] []

		either pair? face/facets/gob-size [
			; we know the present GOB-SIZE of the layout
			
			if auto-sizes? face [
				; adjust the layout size depending on the changes of contents
				old-init-size: face/facets/init-size
				do-actor face 'on-update none
				face/facets/gob-size: face/facets/gob-size * face/facets/init-size / old-init-size
			]
		] [
			; we don't know the GOB-SIZE of the layout
			do-actor face 'on-update none
			
			; use its INIT-SIZE
			face/facets/gob-size: face/facets/init-size
		]

		do-actor face 'on-resize face/facets/gob-size

		draw-face face
	]
]

extend-face: func [
	face [object!]
	field [word!]
	value
	/only
][
	apply :append [
		any [
			select face field
			extend face field make block! 1
		]
		value
		none
		none
		only
	]
]

attach-face: funct [
	src-face [object!]
	dst-face [object! word! lit-path!]
][
	extend-face/only src-face 'targets dst-face
]

show-face: funct [
	"Set the visibility attributes of a face/block of faces."
	face [object! block!] "a face or a block of faces"
	show [word!] "one of: VISIBLE HIDDEN IGNORED FIXED"
	/no-show
][
	visible: any [show = 'visible show = 'fixed]
	resizes: any [show = 'visible show = 'hidden]

	either object? face do-show: [	
		; hiding?
		if all [
			face/gob/size <> 0x-1 ; 0x-1 means the face is invisible
			not visible
		][
			; take care of the focus, if needed
			if guie/focal-face = face [unfocus]
	
			; save the size
			face/facets/gob-size: face/gob/size
			
			; hide the face
			face/gob/size: 0x-1
		]

		; showing?
		if all [
			face/gob/size = 0x-1
			visible
		][
			; restore the size
			face/gob/size: face/facets/gob-size
		]

		; changing the RESIZES attribute?
		either resizes <> face/facets/resizes [
			face/facets/resizes: resizes
			apply :update-face [face no-show]
		][
			unless no-show [
				draw-face either visible [face][face/gob/parent/data]
			]
		]
	][
		foreach face face do-show
	]
]

show?: funct [
	"Get the visibility attributes of the given FACE."
	face [object!]
][
	either face/gob/size = 0x-1 [
		either face/facets/resizes ['hidden]['ignored]
	][
		either face/facets/resizes ['visible]['fixed]
	]
]

focus: func [
	"Focus given FACE"
	face [object!]
	/force "force focus on already focused face (used in re-focusing cases)"
	/actor-result "returns on-focus actor result if possible"
	/local result
][
	unless window-face? face [
		;face is not part of any window
		return none
	]
	if all [not force guie/focal-face = face] [return face]
	; Unfocus prior focus:
	if guie/focal-face <> face [
		if 'stop-event = apply :unfocus [actor-result][
			return 'stop-event
		]
	]

	; Set new focus:
	set-facet window-face? face 'tab-face guie/focal-face: face
	result: do-actor face 'on-focus reduce [true force]

	either actor-result [
		result
	][
		face
	]
]

unfocus: func [
	/actor-result "returns on-focus actor result if possible"
	/self "used by recursive calls - don't call on-focus"
	/local win-face result
][
	if guie/focal-face [
		if win-face: window-face? guie/focal-face [;check if it is part of a window
			unless self [result: do-actor guie/focal-face 'on-focus reduce [false none]]
			set-facet win-face 'tab-face none
		]
		guie/focal-face: none
		if actor-result [
			result
		]
	]
]

next-focus: funct [
	face [object!] "Window face or any face from related window."
] [
	process-tab make object! [flags: none window: select window-face? face 'gob]
]

prev-focus: funct [
	face [object!] "Window face or any face from related window."
] [
	process-tab make object! [flags: [shift] window: select window-face? face 'gob]
]

tall-face?: funct [
	"Returns TRUE if the face is taller than it is wide."
	face
][
;	s: get-facet face 'size
;	s/y > s/x
	equal? face-axis? face 'y
]

face-axis?: funct [
	"Returns face major axis as 'x or 'y."
	face
][
	axis: get-facet face 'axis
	if none? axis [
		size: face/facets/viewport-box/bottom-right
		axis: either size [pick [x y] size/x < size/y][none]
		; sometimes the size is unitialized, so we leave axis as none to see if it causes problems
	]
	axis
]

find-title-text: func [
	"Finds the title text of a layout."
	layout [object!]
][
	foreach face faces? layout [
		if face/style = 'title [
			return get-facet face 'text-body
		]
	]
	none
]

face-text-size: funct [
	"Return position in text and height of visible area in precent!. Useful for scroller."
	face	[object!]
][
	if zero? height: second size-txt gob: sub-gob? face [height: 1]
	size: min 100% to percent! gob/size/y / height
	; TODO: fix hardcoded number (5 is added offset due to problem with size-text )
	t: max 0% negate gob/size/y - height - 5
	scroll: get-gob-scroll gob
	start: either zero? t [0%][limit to percent! negate scroll/y / t 0% 100%]
	reduce [start size]
]

init-drag: func [
	"Initialize drag operation, reusing a common drag object."
	face
	spot "Initial condition (initial value, offset, etc)."
	/only "Drag only inside face, do not use face for drag'n'drop."
	/data "Holds optional user data." 
		user-data
][
	guie/drag/face: face
	guie/drag/base: any [spot face/gob/offset]
	guie/drag/base-offset: face/gob/offset
	guie/drag/gob: either only [none][face/gob]
	guie/drag/delta: 0x0 ; window relative offset
	guie/drag/origin: find face/gob/parent face/gob
	guie/drag/show-parent?: true
	guie/drag/data: user-data
	guie/drag/active: false
	guie/drag/event: none
	guie/drag/start: none
	draw-face face
	guie/drag
]

reset-drag: does [
	set/pad guie/drag []
	guie/drag/show-parent?: true
	guie/drag/active: false
]

confine: func [
    {Return the correct offset to keep rectangular area in-bounds.}
    offset [pair!] "Initial offset"
    size [pair!] "Size of area"
    origin [pair!] "Lower bound (upper left)"
    margin [pair!] "Upper bound (lower right)"
][
    if offset/x < origin/x [offset/x: origin/x]
    if offset/y < origin/y [offset/y: origin/y]
    margin: margin - size
    if offset/x > margin/x [offset/x: margin/x]
    if offset/y > margin/y [offset/y: margin/y]
    offset
]

get-gob-offset: funct [
	gob
][
	offset: gob/offset
	; stop before win offset is added
	either all [gob/parent gob/parent/parent gob/parent/parent/parent] [
		offset + get-gob-offset gob/parent
	][
		offset
	]
]

map-face-offset: funct [
	"Map face's offset relative to another face"
	face [object!] "Face to map"
	base-face [object!]	"Base object (relative zero position)"
][
	(get-gob-offset face/gob) - get-gob-offset base-face/gob
]

center-face: funct [ ; NOTE; not very reliable yet, getting real current size of face or gob is almost impossible
	"Set face's offset so the face will be centered on the screen"
	face [object!]		"Face to center"
	/window				"Center to face's window"
	/with
	base-face [object!]	"Center face to this face"
][
	case [
		window		(base-face: window-face? face)
		not with	(base-face: system/view/screen-gob/face)
	]
	face-size: get-facet face 'gob-size
	base-size: get-facet base-face 'gob-size
	face/gob/offset: base-size - face-size / 2
]

get-fields?: funct [
	"Return fields that can be set using set-face/field"
	face
][
	fields: get-facet face 'get-fields
	either fields [words-of fields][clear []]
]

set-fields?: funct [
	"Return fields that can be set using set-face/field"
	face
][
	fields: get-facet face 'set-fields
	either fields [words-of fields][clear []]
]