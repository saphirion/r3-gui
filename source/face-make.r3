REBOL [
	Title: "R3 GUI - Face: make"
	Purpose: {
		Makes new faces from a style and the attributes provided.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

make-face: funct [
	"Returns a new face based on the style with various attributes."
	style [word!] "Name of style"
	opts [block! none!] "Optional variations of style"
	/not-on-make "don't call on-make actor"
][
	; Verify the style and its look and feel:
	styl: guie/styles/:style

	; Create the face object:
	face: make guie/face [
		facets: make styl/facets opts
		options: make object! any [opts []]
		tags: copy styl/tags
		state: make guie/face-state select styl 'state
		intern: styl/intern
	]
	
	if select styl 'debug [
		append face reduce/no-set [debug: styl/debug]
	]
	
	face/style: style

	; Create the GOB for the face:
	face/gob: make gob! [data: face]

	face/facets/gob: face/gob
	
	unless not-on-make [
		set-box-model face
	
		do-actor face 'on-make none
	]

	face
]

make-options: funct [
;	"Internal: Merge option value block with options object. Used for face/options."
	style [word!]
	values [block!]
][
	assert-gui styl: guie/styles/:style ["Unknown style:" style]
	options: clear []
	; Only use the options that are actually set, ignore NONE options.
	foreach word append clear next [access-key] words-of styl/options [
		if first values [repend options [to-set-word word first values]]
		values: next values
	]
	options ; removed context !!
]
