REBOL [
	Title: "R3 GUI - Layout: viewing"
	Purpose: {
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
]

view-layout: func [
	; INTERNAL: Temporary -- for changing sublayout (plane) !!!
	layout
	child
][
	extend layout 'faces reduce [child]
	append clear layout/gob child/gob
	show-later layout
	;dump-layout layout
]

switch-layout: funct [
	"Switch content (faces) of a layout."
	top-layout [object!] "target"
	new-layout [object!] "source"
	effect [word! none!]
][
	size: top-layout/gob/size ; must already be known
	margin: get-facet top-layout 'margin

	; Be sure we see no residual buffer fragments:
	show clear top-layout/gob

	; Top layout gets a single sublayout:
	extend top-layout 'faces reduce [new-layout]
	append top-layout/gob new-layout/gob
	new-layout/gob/offset: margin

	; Set new size for sublayout:
	s: size - margin - margin
	new-layout/gob/size: new-layout/facets/size: s
	new-layout/facets/area-size: s - 2x2

	; Recompute grid pressures:
	collect-sizes top-layout

	; Resize top-layout and new-layout:
	do-actor top-layout 'on-resize size

	do-triggers new-layout 'enter
	effect-layout new-layout effect
;	show-later new-layout ; rather than effect-layout (debug)
]
