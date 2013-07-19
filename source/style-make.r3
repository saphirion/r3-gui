REBOL [
	Title: "R3 GUI - Style: make"
	Purpose: {
		Make a new GUI style and add it to the system.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

stylize: func [
	"Create one or more styles (with simple style dialect)."
	list [block!] "Format: name: [def], name: parent [def]"
	/local name parent spec style spot
][
	assert-gui parse list [
		some [
			spot:
			set name set-word!
			set parent opt word!
			set spec block!
			(make-style to-word name parent spec)
		]
	]["Invalid style syntax:" spot]

	debug-gui 'dialect [name]
]

make-style: funct [
	"GUI API function for creating a style."
	name [word!]
	parent [word! none!]
	spec [block! none!]
][
	debug-gui 'make-style [name]
	parname: parent
	parent: either parent [guie/styles/:parent][guie/style]
	assert-gui parent ["Unknown parent style for:" name]
	style: copy parent
	style/name: name
	if name <> parname [style/parent: parname] ; Set if not redefining

	foreach [field code] [
		tags    [if val [make-tags val]]
		facets  [if val [make parent/facets val]]
		options [append-dialect name parent/name val]
		actors  [if val [make-actors parent val]] ;append copy parent/actors reduce/no-set val]]
		intern	[if val [if override: val/1 = 'override [val: next val] make any [all [not override parent/intern] object!] val]]
		draw    [val]
		state   [val]
		content [val]
		about   [val]
		debug   [extend style 'debug val val]
	][
		; Get spec field, evaluate code, and set style field if result is valid.
		; Otherwise, we will reuse the parent value (without copying it)
		val: select spec to-set-word field
		unless any [none? :val block? :val string? :val] [
			print ["Invalid style field:" field "with" mold :val]
		]
		if result: do code [style/:field: result]
		;print [":::" field mold val mold result]
	]

	if find select style 'debug 'style [
		print ajoin ["-- debug-style [" name "]: " mold style]
	]

	repend guie/styles [name style]
]

append-dialect: func [
	;INTERNAL: Add style syntax to the dialect. Return face/state prototype.
	style-name [word!]
	parent [word! none!]
	block
	/local name types init options type-list
][
	options: clear []

	; Create a block of typesets used in DELECT dialect.
	type-list: head clear next [char!]    ;NOTE: CHAR! is used for shortcut definition by default for all styles
	either block? :block [
		parse block [
			some [
				set name set-word!
				set types block!
				opt string!
				set init opt block!
				(
					repend options [name init]
					;separate multiple types into typeset!
					append type-list either 1 < length? types [make typeset! types][types]
				)
			]
		]
		type-list: copy type-list
	][
		type-list: select guie/dialect parent
		all [
			parent
			name: select guie/styles parent
			options: name/options
		]
	]

	extend guie/dialect style-name any [type-list copy []]

	; This state block will initialize the face/state object.
	either block? options [context options][copy options]
]
