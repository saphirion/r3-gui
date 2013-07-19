REBOL [
	Title: "R3 GUI - Face: validation"
	Purpose: {
		Provides support face validation
	}
	From: "RM Asset"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

validators: []

validate-face: funct [
	"Sets face's validity as word and returns logic value."
	face [object!]	"Face to validate"
	/full			"Return all informations, not just validity"
][
	;print "===validate face"
	if get-facet face 'skip [
		validity: 'skipped			; is it really need to set here?
		return none
	]
	value: get-face face
	validator: get-facet face 'validator

	; check if one or more validators are used
	valid?: either 2 = length? validator [
		res: collect [
			foreach v validator/2 [keep do bind select validators v 'value]
		]
		do reduce [validator/1 res]
	][
		validator: select validators validator ;get-facet face 'validator
		either validator [
;			value: to string! value
			print ["validating value" mold value]
			do bind validator 'value
		][true]
	]

	; set validation result	
	validity: either valid? ['valid]['invalid]
	validity
]

; add new validators using this function
make-face-validator: funct [
	"Add new face validator"
	blk
][
	name: description: val: err: none
	parse blk [
		any [
			set name word!						; name of validator
			opt [set description string!]		; description of validator
			set val block!						; code block of validator
			set err [word! | string!]			; error string on failure
			(repend validators [name val err])
		]
	]
]

; these should be local to the validation scheme

chars: charset [#"a" - #"z" #"A" - #"Z"]
integers: charset [#"0" - #"9"]
points: charset [#"." #","]
signs: charset [#"-" #"+"]
numbers: union integers union points signs ; simpler way to join many bitsets?
number: [opt signs any [integers | points]]
integer: [opt signs any integers]

make-face-validator [
	only-chars
		"The field may only contain characters a-z and A-Z, not numbers."
		[all [series? value parse value [any chars]]]
		"contains other than alphabetic characters"

	not-empty
		"The field must contain a string and it may not be empty."
		[all [string? value not empty? value]]
		"is empty"

	only-numbers
		"The field must contain only numbers from 0-9, +, -, comma and period."
		[all [series? value not empty? value parse value number]]
		"contains other than numbers"

	only-integers
		"The field must contain only integers from 0-9."
		[all [series? value not empty? value parse value integer]]
		"contains other than integers"

	only-positive
		"The field must contain only positive numbers."
		[positive? value]
		"contains negative numbers"

	selected
		"The field must have a non-empty block or may not be none."
		[any [all [any-block? value not empty? value] all [not any-block? value not none? value]]]
		"has no item selected"

	email
		"The field must have a valid email address."
		[
			parse value [
				end |
				some [chars | numbers] #"@" some [chars | integers] #"." some chars ; find better method
			]
		]
		"is not an email address"
]
