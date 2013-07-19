REBOL [
	Title: "R3 GUI - Text: key handling"
	Purpose: {
		Handles keyboard events for text faces.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

; Key-Map: this object defines special actions for key processing.

text-key-map: context [

	; Used for local context:
	face: none
	key: none
	shift?: none

	chars: [
		#"^H" [ ; backspace
			remove-text-face face -1
			clear-text-caret face
		]
		#"^X" [ ; cut
			remove-text-face face 1
			clear-text-caret face
		]
		#"^C" [copy-text-face face] ; copy
		#"^V" [insert-text-face face load-clip-text] ; paste
		#"^-" [ ; tab
			;NEEDS: face (origin)
			;		window (can get from face)
			;		event (key)
;			all [
;				process-tab event face
;				print "Warning: TAB in key area, please check!"
;			]
			insert-text-face face tab
		]
		#"^M" [ ; enter
			either get-facet face 'lines [
				insert-text-face face pick [#"^-" #"^/"] key = tab
			][
;				next-focus face
				do-face face
				; would need to pass this through to window level, but can we guarantee that here?
				; I'd want super fixed functions for single-line actions
				;next-tab
				;back-tab
;				do-actor root-face? fa 'on-key make event! [key: #"^-"]
				all [
					face: window-face? face					;window may be already closed
					apply :find-tab-face? [face shift?]
				]
			]
		]
		#"^A" [select-all face] ; select all
		#"^[" [unfocus] ; escape
		#"^q" [quit] ; temporary! (for testing)
	]

	control: [ ; equates (word map)
		home head
		end tail
		up back-para
		down next-para
		left back-word
		right next-word
		delete delete-end
	]

	words: [
		left right
		up down
		home end
		page-down page-up 
		back-word next-word
		back-para next-para
		head tail [move-cursor face key 1 shift?]
		delete [remove-text-face face 1]
		delete-end [remove-text-face face 'end-line]
		deselect [select-none face/state]
		ignore [none]
	]

	no-edit: [ ; for read-only text faces
		#"^H" left
		#"^X" #"^C"
		#"^V" ignore
		#"^M" ignore
		delete deslect
		delete-end deselect
	]

]

do-text-key: funct [
	"Process text face keyboard events."
	face [object!]
	event [event! object!]
	key
][
	text-key-map/face: face
	text-key-map/shift?: find event/flags 'shift

	; If text edit is not allowed, modify the key:
;	if no-edit: get-facet face 'no-edit [
	if no-edit: not tag-face? face 'edit [
		key: any [select/skip text-key-map/no-edit key 2 key]
	]

	either char? key [
		; Process a char:
		text-key-map/key: key
		switch/default key bind text-key-map/chars 'event [
			unless no-edit [
				insert-text-face face key
;				clear-selection face
			]
		]
	][
		; Is control key added?
		if find event/flags 'control [
			key: any [select text-key-map/control key key]
		]
		; Process a word:
		text-key-map/key: key
		switch/default key text-key-map/words [return event]
	]
	none
]
