REBOL [
	Title: "R3 GUI - Layout: make"
	Purpose: {
		Makes new layouts from descriptions provided in a layout
		dialect along with extra options that are provided.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id: layout-make.r3 2332 2011-04-12 16:37:28Z cyphre $"
	Date: 17-Feb-2011/17:09:03+1:00
]

make-layout: funct [
	face [object!]
	layout-type [word!]
][
	init-layout face layout-type
	; If we have a private namespace:
	bind-faces face

	if face/style = 'window [
		;bind any target faces
		bind-targets face
	]
	
	; Tell all faces layout is ready:
	do-actor faces: faces? face 'on-init none
	
	; some trigger styles may have on-init
	foreach f select face 'trigger-faces [
		unless find f/facets/triggers 'visible-trigger [
			do-actor f 'on-init none
		]
	]

	do-triggers/no-recursive face 'load
]

init-layout: funct [
	"Initialize a layout face object. Init subfaces and set size."
	layout [object!]
	layout-type [word!]
	/local d1 d2 w rule
][
;	print ["init-layout" layout/style layout-type layout/facets/init-size]

	; Obtain the content block. It comes from either the
	; face options or from a style content block (for
	; composite styles.
	unless block: select layout/options 'content [
		if all [
			style: select guie/styles layout/style
			block: select style 'content
			block: copy/deep block ; we will modify it below
		][
			; Replace GET-WORDs with their actual values.
			; This gives content faces an easy way to
			; be initialized from the parent's facets/options.
			parse block rule: [
				some [
					w: get-word! (
						w/1: get-facet layout to-word w/1
						;todo: find a way how to get rid of this conversion!!!
						any [
							all [
								word? w/1
								w/1: to lit-word! w/1
							]
							all [
								path? w/1
								w/1: to lit-path! w/1
							]
						]
					)
					| and block! into rule
					| skip
				]
			]
		]
	]

	; Parse the layout's layout content block:
	faces: apply :parse-layout [block get-facet layout 'names]

	panel?: layout-type = 'panel
	
	; Remove trigger styles from the faces block:

	trigs: none
	i: 0
	remove-each face faces [
		hidden?: true
		either object? face [
			hidden?: if t: get-facet face 'triggers [
				unless trigs [trigs: make block! 2]
				append trigs face
				not find t 'visible-trigger
			]
			all [
				not hidden?
				++ i
				panel?
				;add visible gob to layout
				append layout/gob face/gob
			]
			;remove trigger if it is 'invisible'
			hidden?
		][
			switch/default face [
				divider resizer [
					unless select layout/facets 'dividers [set-facet layout 'dividers copy []]
					append layout/facets/dividers compose/deep [(i) [type (face)]]
					true
				]
			][
				false
			]
		]
	]

	; Add triggers to layout:
	extend layout 'trigger-faces trigs ; only if trigs is non-none

	;special case when inline pair with container is defined in layout block
	if pair? select layout/options 'init-hint [
		unless layout/facets/min-hint [layout/facets/min-hint: 0x0]
		unless layout/facets/max-hint [layout/facets/max-hint: guie/max-pair]
	]
	unless layout/facets/min-hint [layout/facets/min-hint: 'auto]
	unless layout/facets/max-hint [layout/facets/max-hint: 'auto]
	
	; Extend the facets object depending on resizing/layout engine type
	append layout/facets reduce/no-set switch layout-type [
		panel [
			[
				break-after: any [
					select layout/facets 'break-after
					0
				]
				pane-align: any [
					select layout/facets 'pane-align
					'left
				]
				pane-valign: any [
					select layout/facets 'pane-valign
					'top
				]
				row-max: any [
					select layout/facets 'row-max
					'max
				]
				column-max: any [
					select layout/facets 'column-max
					'max
				]
				row-min: any [
					select layout/facets 'row-min
					'max
				]
				column-min: any [
					select layout/facets 'column-min
					'max
				]
				row-init: any [
					select layout/facets 'row-init
					'max
				]
				column-init: any [
					select layout/facets 'column-init
					'max
				]
				layout-mode: any [
					select layout/facets 'layout-mode
					'horizontal
				]

				spacing: any [
					select layout/facets 'spacing
					0x0
				]				

				intern: make object! [
					update?: true
					init-pane: none
					heights: copy []
					init-heights: copy []
					min-heights: copy []
					max-heights: copy []
					widths: copy []
					init-widths: copy []
					min-widths: copy []
					max-widths: copy []
					row-minification-index: copy []
					row-magnification-index: copy []
					column-minification-index: copy []
					column-magnification-index: copy []
					row-init-ratio: none
					column-init-ratio: none
				]
			]
		]
		group [
			[
				pane-align: any [
					select layout/facets 'pane-align
					'left
				]
				pane-valign: any [
					select layout/facets 'pane-valign
					'top
				]
				layout-mode: any [
					select layout/facets 'layout-mode
					'horizontal
				]
				line-max: any [
					select layout/facets 'line-max
					'max
				]
				line-min: any [
					select layout/facets 'line-min
					'max
				]
				line-init: any [
					select layout/facets 'line-init
					'max
				]

				spacing: any [
					select layout/facets 'spacing
					0x0
				]				
				intern: make object! [
					update?: true
					init-pane: none
					lines: copy []
					minification-index: copy []
					magnification-index: copy []
					line-init-ratio: none
				]
			]
		]
	]

	unless panel? [
		;it's group - add sub-gobs
		insert-into-group layout/gob 1 + length? layout/gob faces
	]

	layout
]
