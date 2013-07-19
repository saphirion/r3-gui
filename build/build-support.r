REBOL [
	Author: "Ladislav Mecir"
	Purpose: {Support for builder scripts}
	File: %build-support.r
]

do-build: func [
	flags [object!]
	build-code [block!]
	/local flag-values flag-words
] [
	; find out which flag words are used
	flag-words: bind words-of flags 'rebol
	
	; remember the current flag values
	flag-values: copy []
	foreach word flag-words [append/only flag-values get/any word]
	
	; now set the flag values as required
	set/any flag-words values-of flags
	
	do funct [] build-code
	
	; restore the original flag values
	set/any flag-words flag-values
]

svn-version?: func [
	"Return the last date and version of a repository folder"
	path [file!] "repository folder"
	/local date version
] [
	date: to date! ask "Please give the folder date: "
	version: to integer! ask "Please give the folder version: "
	make object! compose [
		date: (date)
		version: (version)
	]
]
