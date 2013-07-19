REBOL [
	Title: "REBOL 3 GUI - Text font definitions"
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

fontize compose/deep [

	base: [
		para: [
			origin: 0x0
			margin: 0x0
			wrap?: true
		]
		font: [
			color: black
			size: 12
			name: guie/font-sans
			offset: 0x0
		]
		anti-alias: (either system/version/4 = 13 ['on]['off])	;on Android antialiased text looks much better
	]

	bold: base [
		font: [
			style: 'bold
		]
	]

	field: base [
		para: [
			wrap?: false
			valign: 'top
		]
	]

	dir-text: field [
		font: [
			size: 15
		]
	]

	area: base [
	]

	info: field [
		anti-alias: on
	]

	info-area: info [
		para: [
			wrap?: true
		]
	]

	code: base [
		font: [
			name: guie/font-mono
		]
		anti-alias: off
	]

	head-bar: [
		font: [
			color: black
			size: 12
			style: 'bold
			name: guie/font-sans
		]
		para: [
			origin: 4x0
			valign: 'middle
			wrap?: false
		]
		anti-alias: on
	]

	centered: base [
		para: [
			margin: 0x0
			origin: 0x0
			align: 'center
			valign: 'middle
		]
	]

	centered-aa: centered [
		anti-alias: on
		para: [
			wrap?: false
		]
	]

	button: centered [
		font: [
			color: snow
			style: 'bold
			size: 12
			shadow: [0x1 2]
		]
		para: [
			origin: 0x-1
			wrap?: false
		]
		anti-alias: on
	]

	dropdown: button [
		para: [
			origin: 15x-1
		]
	]

	sbutton: centered [
		font: [
			color: 50.50.0
;			style: 'bold
			size: 11
			shadow: [0x1 1]
		]
		para: [
			origin: -5x0
			wrap?: false
		]
		anti-alias: on
	]

	label: base [
		font: [
			size: 12
			style: 'bold
		]
		para: [
			origin: 0x2
			margin: 4x0
			wrap?: false
			align: 'right
		]
	]
	title: label [
		font: [
			size: 18
		]
		para: [
			origin: 0x0
			align: 'left
			valign: 'top
		]
		anti-alias: on
	]

	heading: title [
		font: [
			size: 16
		]
		para: [
			align: 'left
		]
	]

	subheading: heading [
		font: [
			size: 14
		]
	]

	subsubheading: heading [
		font: [
			size: 12
		]
		para: [
			origin: 20x0
		]
	]

	radio: base [
		para: [
			origin: 18x0 ; offset for graphic
			valign: 'middle
		]
	]

	list-item: base [
		para: [
			wrap?: false
		]
		anti-alias: off
	]
]
