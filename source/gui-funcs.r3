REBOL [
	Title: "R3 GUI - Misc functions"
	Purpose: {
		Various functions needed for GUI.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	version: "$Id$"
]

sum-pair: func [pair] [pair/x + pair/y]

merge-values: funct [
	"Merge a source object's defined values into a target object."
	obj [object!] "Target"
	src [object!] "Source"
	/force "Even if destination has a value, set it from source."
][
	foreach word words-of obj [
		if all [
			val: select src word
			any [force none? select obj word] ; if not already set
		][
			obj/:word: src/:word
		]
	]
]
