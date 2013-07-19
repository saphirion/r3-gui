REBOL [
	Title: "R3 GUI - module files"
	Purpose: "The files used to build the GUI subsystem."
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

files: [
	%gfx-pre.r3
	%gui-funcs.r3
	%gui-debug.r3
	%gui-object.r3

; GUI style definitions:
	%style-make.r3
	%style-tags.r3
	%style-actors.r3
	%style-materials.r3

; GUI face handling
	%face-make.r3
	%face-funcs.r3
	%face-nav.r3
	%face-draw.r3
	%face-access.r3
	%face-validation.r3

; GUI layouts, sizing, viewing:
	%layout-make.r3
	%layout-access.r3
	%layout-content.r3
	%layout-sizing.r3
	%layout-dialect.r3
	%layout-triggers.r3
	%layout-effects.r3
	%layout-view.r3

; Text handling:
	%text-fonts.r3
	%text-keys.r3
	%text-edit.r3
	%text-draw.r3
	%text-caret.r3
	%text-cursor.r3

; Event handling:
	%event-funcs.r3
	%event-handler.r3

; Top level VIEW features:
	%view-colors.r3
	%view-request.r3
	%view-show.r3
	%view-window.r3

; Support Functions
	%gui-operations.r3
	%gui-materials.r3
	
; Standard styles:
	%fonts.r3
	%layout.r3
	%button.r3
	%bars.r3
	%text.r3
	%doc.r3
	%image.r3
	%lists.r3
	%table.r3
	%compound.r3

]