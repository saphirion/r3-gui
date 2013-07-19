REBOL [
	Title: "R3 GUI - Text: cursor movement"
	Purpose: {
		Move the cursor based on key (or other) actions.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

; Charsets used for text cursor and selection:
guie/char-space: charset " ^-^/^M/[](){}^""
guie/char-valid: complement guie/char-space

move-cursor: funct [
	"Move cursor up, down, left, right, home, end, or to a position."
	face [object!]
	action [word!]
	count
	select? "Add to marked text (selection)"
][
	state: face/state
	cursor: state/cursor
	sc: any [state/mark-head cursor] ; start for mark
	tc: none ; temp cursor
	reset-x: true

	cursor: switch action [

		left [
			sc: any [state/mark-tail cursor] ; we need makr-tail here instead of mark-hear or bad things happen
			skip cursor negate count
		]
		right [skip cursor count]

		down up
		page-down page-up [
			reset-x: false
			move-caret face action
		]

		head [head cursor]
		tail [tail cursor]

		end [
			loop count [
				unless tc: find cursor newline [break]
				cursor: next tc
			]
			any [tc tail cursor]
		]

		home [
			loop count [
				unless tc: find/reverse/tail cursor newline [break]
				cursor: back tc
			]
			any [tc head cursor]
		]

		back-word [
			tc: cursor
			loop count [
				all [
					tc
					tc: find/reverse tc guie/char-valid
					tc: find/reverse tc guie/char-space
					tc: next tc
				]
			]
			any [tc head cursor]
		]

		next-word [
			tc: next cursor
			loop count [
				all [
					tc
					tc: find tc guie/char-space
					tc: find tc guie/char-valid
				]
			]
			any [tc tail cursor]
		]

		back-para [
			tc: back cursor
			loop count [
				all [
					tc
					tc: find/reverse cursor newline
					tc: find/reverse tc guie/char-space
					tc: find/reverse/tail tc newline
				]
			]
			any [tc head cursor]
		]

		next-para [
			tc: cursor
			loop count [
				all [
					tc
					tc: find cursor newline
					tc: find tc guie/char-valid
				]
			]
			any [tc tail cursor]
		]

		full-word [
			select?: true
			tc: cursor
			sc: any [
				find/reverse/tail tc guie/char-space
				head cursor
			]
			cursor: any [
				find tc guie/char-space ; do not select trailing space!
				tail cursor
			]
		]
	]

	; The cached x position may be invalid:
	if reset-x [state/xpos: none]

	; Update selection:
	either select? [
			set bind [mark-head mark-tail] state reduce either (index? sc) < index? cursor [[sc cursor]][[cursor sc]]
	][
		clear-text-caret face
		select-none state ; unselect if needed
	]
	state/cursor: cursor
]
