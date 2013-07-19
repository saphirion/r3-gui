REBOL [
	Title: "REBOL 3 GUI Styles - Text fields and areas"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"

	Todo: [
		"IMAGE currently ignores 'center' settings (or all other)"
	]
]

temp-ctx-doc: context [

	space: charset " ^-"
	nochar: charset " ^-^/"
	para-start: charset [#"!" - #"~"]

	image-root: %./

	parse-para: funct [
		"Convert paragraph with minor markup."
;		out [block!] "A richtext block"
		para "marked-up string"
	][
		buf: copy []
		; !!Note: load/markup is missing in current 3.0 alpha
		; so use simple (too simple) method...
		while [all [para not tail? para]] [
			either spot: find para #"<" [
				append buf copy/part para spot
				para: either end: find/tail spot #">" [
					switch copy/part spot end [
						"<b>" [append buf 'bold]
						"</b>" [append buf [bold off]] ; bug
						"<i>" [append buf 'italic]
						"</i>" [append buf [italic off]] ; bug
						"<em>" [append buf [bold italic]]
						"</em>" [append buf [bold off italic off]] ; bug
					]
					end
				][
					next spot
				]
			][
				append buf reduce [copy/part para tail para]
				para: none
			]
		]
		buf
	]

	emit-table: func [out /local s t] [
		if table? [
			t: copy/deep [hpanel 2 []]
			repeat i length? labs [
				repend t/3 ['label labs/:i 'text parse-para strs/:i 'options [one-line: true]]
			]
			labs: clear [] strs: clear []
			table?: no
			i: 1
			append out t
		]
	]
	table?: false
	labs: clear [] strs: clear [] ; labels and strings for tables

	set 'parse-doc funct/extern [
		"Parse the doc string input. Return rich-text output."
		text [string!]
		/path
		doc-path "Path to use for images loading"
	][
		unless path [doc-path: %./]
		text: trim/auto detab text
		if newline <> last text [append text newline]
		out: make block! (length? text) / 20 + 1 ; a guess
		emit: funct [data /local t] [
			emit-table out
			repend out data
		]

		t: s: none
		i: 1

		para: make string! 20

		parse/all text [
			; Document title:
			copy s to newline skip (emit ['title s])
			some [
				"###" break
				|
					; Heading line:
					"===" copy s to newline skip (emit ['title s 'options [text-style: 'heading]])
				|
					; Subheading line:
					"---" copy s to newline skip (emit ['title s 'options [text-style: 'subheading]])
				|
					; Subsubheading line:
					"+++" copy s to newline skip (emit ['title s 'options [text-style: 'subsubheading]])
				|
					; Image root:
					"=image-root" copy s to newline skip (image-root: join doc-path trim to file! s)
				|
					; Image:
					"=image" space opt ["center" space] copy s to newline skip (emit ['image join image-root to file! s 'options [align: 'center]])
				|
					; TODO: gather all ":" and emit together
					":" copy t to "- " 2 skip copy s to newline skip (table?: true append labs t append strs s)
				|
					; TODO: convert text using emit-para (currently problematic)
					"*" copy s to newline skip (table?: true append labs "*" append strs s)
				|
					; TODO: convert text using emit-para (currently problematic)
					"#" copy s to newline skip (table?: true append labs to string! ++ i append strs s)
				|
					; Gather and emit a paragraph:
					some [copy s [para-start to newline] (repend para [s " "]) skip]
						(
							emit ['text parse-para para]
							clear para
						)
				|
					; Gather and emit a code block:
					some [copy s [space thru newline] (append para skip s 4)] ( ; expecte tab as 4 spaces from detab above
						emit ['code-area 400x240 copy para 'options [align: 'center]]
						clear para
					)
				|
					newline
					opt [newline ()]
			]
		]
		emit-table out
		reduce ['vpanel out]
	][table? image-root]

]

stylize [

doc: plane [

	about: "A tiny document markup method for embedded docs, notes, messages."

	tags: [tab]

	facets: [
		path: %./		; path to document (required for images)
	]

	options: [
		init-size: [pair!]
		document: [string! block!]
	]

	actors: [

		on-init: [
			if doc: get-facet face 'document [
				set-face/no-show face doc
			]
		]

		on-set: [ ; arg: [word value]
			switch arg/1 [
				value [
					apply :set-content [face parse-doc/path arg/2 get-facet face 'path false none arg/3]
				]
			]
		]

		on-scroll-event: [
			if bars: select face 'attached [
				foreach bar bars [
					if axis: get-facet bar 'axis [
						set-face bar bar/state/value - to percent! .001 * arg/offset/:axis
					]
				]
			]
		]
	]
]


]