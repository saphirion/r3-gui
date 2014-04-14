REBOL [
	Title: "R3 GUI - Layout: layout dialect"
	Purpose: {
		Parses and converts GUI language into a block of objects.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

;	This code has purposely been kept minimal to make it easier to
;	understand and debug.
;
;	Note: Some keywords are not styles, they are special options for the
;	face. For example, DO or BROWSE attach as actions to the prior face.
;
;	Face names (set-words) are handled via the default parse action
;	supported by DELECT.

parse-layout: funct [
	"Parses the layout dialect and returns a block of faces/commands."
	block [block! none!]
	/no-names "don't set face name references"
][
	unless block [return copy []]

	pane: make block! length? block ; more than needed

	dial: block
	opts: make block! 10
	trigs: make block! 2
	last-face: none ; to attach special actions

	build-face: func [
		/not-on-make
	][
		if all [not not-on-make object? last-face][
			if show? [
				show-face/no-show last-face show?
			]

			set-box-model last-face
			
			do-actor last-face 'on-make none 

			if show? = 'fixed [
				do-actor last-face 'on-update none
				do-actor last-face 'on-resize last-face/facets/init-size
			]
			show?: none
		]
		all [
			block? last-face
			data: last-face/1
			last-face: last-face/1: apply :make-face [data/1 make-options data/1 data/2 not-on-make]
			; If this is a named face (from a set word), store the name:
			if data/3 [
				extend last-face 'name data/3
				unless no-names [
					;set the name reference as well
					set data/3 last-face
				]
			]
		]
	]

	forever [
		; Parse the next chunk of the GUI dialect. Each chunk is defined
		; by the GUI/dialect, and includes style names and any special keywords.
		if error? err: try [
			dial: delect guie/dialect dial opts
		][
			either all [
				word? act: dial/1
				block? body: get dial/2
			][
				;its word! block! combo so treat it as ACTOR (re)definition
				build-face/not-on-make

				extend-face last-face 'actors reduce [act funct/closure [face arg] body]

				dial: skip dial 2
				continue
			][
				fail-gui ["Cannot parse the GUI dialect at:" mold/only copy/part dial 5]
			]
		]

		unless dial [break]

		; Now process the parsed result block, which is normally a style
		; name to create a face instance.
		if word: first opts [
			arg: second opts

			; Is it a style, action, or special command?
			case [
				word = 'face [
					;make the previously defined face
					build-face
	
					; Special case for direct inclusion of a premade face:
					last-face: arg
					if name [extend last-face 'name name  name: none]
					append pane last-face
				]

				select guie/styles word [
					;make the previously defined face
					build-face
					insert/only last-face: tail pane reduce [word copy next opts name]
					name: none
				]

				word = 'default [
					; Keep track of SET-WORD for use as face name:
					name: to-word arg
				]

				word = 'return [
					;make the previously defined face
					build-face
					last-face: none
					
					append pane 'return
				]

				any [word = 'divider word = 'resizer] [
					build-face
					last-face: none
					append pane word
				]

				word = 'attach [
;					print ["attach" opts/2]
					build-face
					attach-face last-face any [opts/2 opts/3]

;					set-face/field get name get-face/field face field self-field ; (none is allowed)
;					do-face get name
				]
				
				last-face [
					; No matches, so must be OPTS, DEBUG, or a face ACT
					; Make the face based on the given style:
					build-face/not-on-make

					switch word [
						; Special keywords:
						options [
							if arg [
								arg: reduce/no-set arg ; NOTE: reduced out of context
								
								;handling of special 'setter' keywords
								if arg/gob-offset [
									last-face/gob/offset: arg/gob-offset
									remove/part find/skip arg 'gob-offset 2 2
								]
								if arg/show-mode [
									show?: arg/show-mode
									remove/part find/skip arg 'show-mode 2 2
								]

;								append last-face/facets arg
								forskip arg 2 [
									if set-word? arg/1 [
										append last-face/facets copy/part arg 2 ;NOTE append/part doesn't work on objects so far :-/
									]
								]
								
								either last-face/facets/gob-size = none [
									last-face/facets/gob-size: last-face/facets/init-size
								][
									last-face/facets/init-size: last-face/facets/gob-size
								]
							]
						]
						debug [
							extend last-face 'debug any [arg [make]]
							debug-face last-face 'make last-face
						]
					]
				]
			]
		]
	]
	build-face
	pane
]
