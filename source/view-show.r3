REBOL [
	Title: "R3 GUI - View: show"
	Purpose: {
		This code optimizes the use of SHOW, the way all windows
		get refreshed.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Date: 19-Jan-2011/16:35:15+1:00
]

;   Notes: Most code uses SHOW-LATER instead of using SHOW directly.
;   This way, gobs to be shown are collected in a list, and there is
;   only one SHOW call per event. Since the SHOW native optimizes
;   this case, it ensures that gobs are only shown once.

show-later: func [
	item [gob! object! block! none!]
][
	if object? item [item: select item 'gob] ; a face
	all [
		item
		append guie/shows item
	]
]

contains-gob?: funct [
	"Check if the gob tree contains target gob."
	gob [gob!]
	tgob [gob!]
][
	repeat i length? gob [
		sg: gob/:i
		all [
			any [
				sg = tgob
				contains-gob? sg tgob
			]
			return true
		]
	]
	false
]

show-now: has [no-show][
;	print "--------------------"
	no-show: clear []
	gobs: guie/shows
	foreach g gobs [
		foreach g2 gobs [
			all [
				g <> g2
				not no-show/:g2
				contains-gob? g g2
				append append no-show g2 true
			]
		]
	]
;	print [length? gobs length? no-show]
	foreach g gobs [
		unless no-show/:g [
;			print ["show" g/data/style]
;			probe dt [
				show g
;			]
			append append no-show g true
		]
	]
	clear gobs
]
