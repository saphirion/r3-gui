REBOL [
	Title: "R3 GUI - build"
	Purpose: "Builds a GUI (for release)."
]

#include %build-support.r

do-build flags: context [
	output: %../release/r3-gui.r3
	svn-version: svn-version? %../source/
 	header: make object! [
		title: "R3-GUI"
		file: %r3-gui.r3
		from: "RM-Asset"
		url: http://www.rm-asset.com/code/downloads/
		history: http://www.rm-asset.com/code/level1/r3-gui/
		license: http://www.rebol.com/r3/rsl.html
		version: svn-version/version
		date: svn-version/date
		purpose: "REBOL 3 GUI module"
	]
] [
	clear include-ctx/log
	
	; link the code
	code: include/only %../loader/loader.r3

	; use the header
	change code reduce ['REBOL body-of header]
	
	; save the output
	write output mold/only/all code
	
	write %build.log "flags: [^/"	
	write/append %build.log form flags
	write/append %build.log "^/]^/^/"
	
	write/append %build.log "include-ctx/log: [^/"
	write/append/lines %build.log include-ctx/log
	write/append %build.log "]^/^/"
	
	write %build-number.r form svn-version/version

	clear include-ctx/log
]
