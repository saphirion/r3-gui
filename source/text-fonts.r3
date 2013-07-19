REBOL [
	Title: "R3 GUI - Text: fonts"
	Purpose: {
		Font defintions and text style creation.
	}
	From: "REBOL Technologies"
	License: http://www.rebol.com/r3/rsl.html
	Version: "$Id$"
]

;-- Font Styles ------------------------------------------------------------=
;
;   Manage font styles.  Each font style is named, and defines a font
;   and a paragraph object. Anti-aliasing can also be specified.

guie/font: context [
	name:
	parent:
	font:
	para:
	anti-alias:
	char-size:
		none
]

fontize: funct [
	"Define text styles (from dialect)."
	spec [block!]
][
	name: parent: none
	assert-gui parse spec [
		some [
			spot:
			set name set-word!
			set parent opt word!
			set spec block!
			(make-text-style to-word name parent spec)
		]
	]["Invalid font syntax:" spot]
]

make-text-style: funct [
	"Define a new font style (used for text face styles)."
	font-name [word!]
	font-parent [word! none!]
	spec [block! none!]
][
	proto: either font-parent [guie/fonts/:font-parent][guie/font]
	unless proto [warn-gui ["Unknown parent:" font-parent "- for font:" font-name]]

	style: make proto [
		name: font-name
		parent: font-parent
		font: make any [proto/font system/standard/font] select spec to-set-word 'font
		para: make any [proto/para system/standard/para] select spec to-set-word 'para
		anti-alias: any [select spec to-set-word 'anti-alias proto/anti-alias]
		char-size: font-char-size? self
	]

	repend guie/fonts [font-name style]
]

what-font?: funct [
	"Given a name, return gui font object defined earlier. (helper)"
	name
][
	any [
		guie/fonts/:name
		warn-gui ["missing font:" name]
		guie/fonts/base
	]
]

face-font?: funct [
	"Given a face, return gui font object defined earlier. (helper)"
	face
][
	what-font? any [get-facet face 'text-style 'base]
]

font-font?: func [name] [select what-font? name 'font]

face-char-size?: funct [
	"Returns font char-size field. (helper)"
	face
][
	style: face-font? face
	style/char-size
]
