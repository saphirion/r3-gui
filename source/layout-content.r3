REBOL [
	Title: "R3 GUI - Layout: content handling"
	Version: "$Id: layout-content.r3 852 2010-10-07 13:28:26Z cyphre $"
	Date: 22-Dec-2010/17:01+1:00
]

set-content: funct [
	layout [object!]
	content [block! object!]
	/pos
		index [integer! object! gob!]
	/no-show
][
	apply :clear-content [layout index index true]
	apply :insert-content [
		layout content true 1 + length? layout/gob no-show
	]
]

clear-content: funct [
	layout [object!]
	/pos
		index [integer! object! gob!]
	/no-show
][
	index: any [index 1]
	if object? index [index: index/gob]
	index: either gob? index [
		either index: find layout/gob index [index? index][
			1 + length? layout/gob
		]
	][
		max index 1
	]

	either index > len: length? layout/gob [layout][
		do-actor layout 'on-content reduce ['clear no-show index len]
	]
]

insert-content: funct [
	layout [object!]
	content [block! object!]
	/pos
		index [integer! object! gob!] {pane index, face, or gob}
	/no-show
][
	index: any [index 1]
	if object? index [index: index/gob]
	index: case [
		gob? index [
			either index: find layout/gob index [index? index][
				1 + length? layout/gob
			]
		]
		integer? index [min max index 1 1 + length? layout/gob]
	]

	content: either block? content [
		apply :parse-layout [
			content all [in layout/facets 'names layout/facets/names]
		]
	][
		reduce [content]
	]

	either empty? content [layout][
		do-actor layout 'on-content reduce ['insert no-show content index]
	]
]

append-content: funct [
	layout [object!]
	content [block! object!]
	/no-show
][
	apply :insert-content [
		layout content true 1 + length? layout/gob no-show
	]
]

change-content: funct [
	layout [object!]
	content [block! object!]
	/pos
		index [integer! object! gob!]
	/part
		range [integer!]
	/no-show
][
	;not implemented until CHANGE and POKE works on gob!s
]

remove-content: func [
	layout [object!]
	/pos
		index [integer! object! gob!]	
	/part
		range [integer!]	
	/no-show
][
	index: any [index 1]
	if object? index [index: index/gob]
	index: case [
		gob? index [
			either index: find layout/gob index [index? index][
				1 + length? layout/gob
			]
		]
		integer? index [min max index 1 1 + length? layout/gob]
	]

	range: any [range 1]
	range: max range 1 - index
	if range < 0  [
		; a "backward remove", transform it to a "forward remove"
		index: index + range
		range: negate range
	]
	if index > length? layout/gob [return layout]
	range: min range 1 - index + length? layout/gob
	if range = 0 [return layout]

	do-actor layout 'on-content reduce ['remove no-show index range]
]
