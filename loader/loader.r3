REBOL [
	Title: "R3 GUI - load and start"
	Purpose: "Load all files needed by GUI (for testing)."
]

#do [
	; use a temporary path to make sure only the "prescribed directories"
	; are used, and no other directory is in the INCLUDE-CTX/PATH
	; when building the GUI
	
	merge-files: func [temporary-path /local merged-files file-contents] [
		include-ctx/push temporary-path
		
		include %gui-files.r3
	
		merged-files: copy []
	
		foreach file files [
			file-contents: include/check/only file
			; skip REBOL header if present
			parse file-contents ['REBOL block! file-contents:]
			append merged-files file-contents
		]
	
		include-ctx/pop
	
		merged-files
	]

	merge-files reduce [
		clean-path %../source
		clean-path %../source/styles/
	]
]

; force the full initialization
system/view/event-port: none

init-view-system
