REBOL [
	Title: "R3 GUI - Layout: transition effects"
	Purpose: {
		Adds effects to layout transitions.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
]

; Note: effects still need some improvements, but this is
; the general idea, and there are many others possible.

; Also: this code calls WAIT, and that will need to be
; removed to avoid nesting within the event system.

init-effect-fly: funct [
	layout
	effect
][
	faces: layout/faces
	dests: make block! length? faces
	foreach face faces [
		append dests face/gob/offset
		switch effect [
			fly-right
			fly-down [face/gob/offset: negate face/gob/size]
			fly-left
			fly-up [face/gob/offset: layout/gob/size + 2]
		]
	]
	dests
]

anim-effect-fly: funct [
	layout
	effect
	dests
][
	foreach face layout/faces [
		dest: first+ dests
		size: face/gob/size
		inc: max 1x1 dest + size / 6
		xy: face/gob/offset
		switch effect [
			fly-right [xy/y: dest/y]
			fly-left  [xy/y: dest/y inc: negate inc]
			fly-down  [xy/x: dest/x]
			fly-up    [xy/x: dest/x inc: negate inc]
		]
		op: get pick [max min] negative? inc
		while [xy <> dest] [
			face/gob/offset: xy
			show face/gob
			wait .01
			xy: op dest xy + inc
			;?? [inc xy dest]
		]
		face/gob/offset: dest
		show face/gob
	]
]

effect-layout: funct [
	"Display a layout transition effect."
	layout [object!] "Layout face"
	effect [word! none!] "Effect word"
][
	switch effect [
		fly-right
		fly-left
		fly-up
		fly-down
			[dests: init-effect-fly layout effect]
	]

	draw-face/no-show layout

	switch effect [
		fly-right
		fly-left
		fly-up
		fly-down
			[anim-effect-fly layout effect dests]
	]
]
