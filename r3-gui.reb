REBOL [
    title: "R3-GUI"
    file: %r3-gui.r3
    from: "RM-Asset"
    url: http://www.rm-asset.com/code/downloads/
    history: http://www.rm-asset.com/code/level1/r3-gui/
    license: http://www.rebol.com/r3/rsl.html
    version: ""
    date: 16-Mar-2015/9:24:39-4:00
    purpose: "REBOL 3 GUI module"
]
context [
    ext-shape: import 'shape
    ext-draw: import 'draw
    ext-text: import 'text
    lit-word: false
    any-arg?: false
    text-args: make object! [
        b: bold: [logic!]
        i: italic: [logic!]
        u: underline: [logic!]
        font: [object!]
        para: [object!]
        size: [integer!]
        shadow: [pair! | tuple! | number!]
        scroll: [pair!]
        drop: [integer!]
        anti-alias: [logic!]
        nl: newline: none
        caret: [object!]
        center: none
        left: none
        right: none
    ]
    shape-args: make object! [
        arc: [
            pair!
            | pair!
            | number!
            | 'sweep
            | 'large
        ]
        close: none
        curv: [pair! (any-arg?: true)]
        curve: [pair! (any-arg?: true)]
        hline: [number!]
        line: [pair! (any-arg?: true)]
        move: [pair!]
        qcurv: [pair!]
        qcurve: [pair! (any-arg?: true)]
        vline: [number!]
    ]
    draw-args: make object! [
        anti-alias: [logic!]
        arc: [
            pair!
            | pair!
            | number!
            | number!
            | 'closed
            | 'opened
        ]
        arrow: [tuple! | pair!]
        box: [pair! | pair! | number!]
        curve: [pair! (any-arg?: true)]
        circle: [pair! | number! | number!]
        clip: [pair! | pair! | logic!]
        ellipse: [pair! | pair!]
        fill-pen: [tuple! | image! | logic!]
        fill-rule: ['even-odd | 'non-zero]
        gamma: [number!]
        grad-pen: [
            'conic
            | 'cubic
            | 'diagonal
            | 'diamond
            | 'linear
            | 'radial
            | 'normal
            | 'repeat
            | 'reflect
            | pair!
            | pair!
            | number!
            | number!
            | number!
            | logic!
            | block!
        ]
        invert-matrix: none
        image: [
            image! |
            pair! (any-arg?: true)
        ]
        image-filter: [
            'nearest
            | 'bilinear
            | 'bicubic
            | 'gaussian
            | 'resize
            | 'resample
            | number!
        ]
        image-options: [
            tuple! | 'border | 'no-border
        ]
        image-pattern: [
            'normal | 'repeat | 'reflect | pair! | pair!
        ]
        line: [pair! (any-arg?: true)]
        line-cap: ['butt | 'square | 'rounded]
        line-join: ['miter | 'miter-bevel | 'round | 'bevel]
        line-pattern: [logic! | tuple! | number! (any-arg?: true)]
        line-width: [number! | 'fixed]
        matrix: [block!]
        pen: [tuple! | image! | logic!]
        polygon: [pair! (any-arg?: true)]
        push: [block!]
        reset-matrix: none
        rotate: [number!]
        scale: [pair! | number! | number!]
        shape: [block!]
        skew: [pair!]
        spline: [integer! | 'closed | pair! (any-arg?: true)]
        text: ['aliased | 'antialiased | 'vectorial | pair! | pair! | block!]
        transform: [number! | number! | number! | pair! | pair!]
        translate: [pair!]
        triangle: [pair! | pair! | pair! | tuple! | tuple! | tuple! | number!]
    ]
    text-words: words-of text-args
    shape-words: append words-of shape-args [
        sweep
        large
    ]
    draw-words: append words-of draw-args [
        even-odd
        non-zero
        conic
        cubic
        diagonal
        diamond
        linear
        radial
        normal
        repeat
        reflect
        butt
        square
        rounded
        miter
        miter-bevel
        round
        bevel
        fixed
        closed
        opened
        no-border
        border
        nearest
        bilinear
        bicubic
        gaussian
        resize
        resample
        aliased
        antialiased
        vectorial
    ]
    text-command: [
        string!
        | tuple!
        | char!
        | 'anti-alias
        | 'b
        | 'bold
        | 'caret
        | 'center
        | 'drop
        | 'font
        | 'i
        | 'italic
        | 'left
        | 'nl
        | 'newline
        | 'para
        | 'right
        | 'scroll
        | 'shadow
        | 'size
        | 'u
        | 'underline
    ]
    shape-command: [(lit-word: false)
        'arc
        | 'close
        | 'curv
        | 'curve
        | 'hline
        | 'line
        | 'move
        | 'qcurv
        | 'qcurve
        | 'vline
        | lit-word! (lit-word: true)
    ]
    draw-command: [
        'anti-alias
        | 'arc
        | 'arrow
        | 'box
        | 'circle
        | 'clip
        | 'curve
        | 'ellipse
        | 'fill-pen
        | 'fill-rule
        | 'gamma
        | 'grad-pen
        | 'invert-matrix
        | 'image
        | 'image-filter
        | 'image-options
        | 'image-pattern
        | 'line
        | 'line-cap
        | 'line-join
        | 'line-pattern
        | 'line-width
        | 'matrix
        | 'pen
        | 'polygon
        | 'push
        | 'reset-matrix
        | 'rotate
        | 'scale
        | 'shape
        | 'skew
        | 'spline
        | 'text
        | 'transform
        | 'translate
        | 'triangle
    ]
    text-types: make object! [
        logic!: []
        tuple!: []
        integer!: []
        object!: []
        pair!: []
    ]
    shape-types: make object! [
        pair!: []
        integer!: []
        decimal!: []
        word!: []
    ]
    draw-types: make object! [
        logic!: []
        pair!: []
        integer!: []
        decimal!: []
        tuple!: []
        word!: []
        block!: []
        image!: []
    ]
    set 'to-text func [
        src [block!]
        dst [block!]
        /local
        cmd args a text-arg t
    ] [
        parse reduce/only src text-words [
            some [
                set cmd text-command (
                    args: make text-types []
                    text-arg: either word? cmd [
                        all [
                            text-args/(cmd)
                            copy text-args/(cmd)
                        ]
                    ] [
                        none
                    ]
                )
                any [
                    set a text-arg (
                        all [
                            not none? a
                            append select args t: type?/word a a
                            remove/part find text-arg t 2
                        ]
                    )
                ] (
                    append dst reduce switch/default type?/word cmd [
                        string! [['text cmd]]
                        tuple! [['color cmd]]
                        string! [['text to string! cmd]]
                    ] [
                        append dst reduce switch/default cmd [
                            anti-alias [['anti-alias either args/logic!/1 = none [true] [args/logic!/1]]]
                            b bold [['bold either args/logic!/1 = none [true] [args/logic!/1]]]
                            caret [['caret args/object!/1]]
                            center [['center]]
                            drop [['drop any [args/integer!/1 1]]]
                            font [['font args/object!/1]]
                            i italic [['italic either args/logic!/1 = none [true] [args/logic!/1]]]
                            left [['left]]
                            nl newline [['text to string! newline]]
                            para [['para args/object!/1]]
                            right [['right]]
                            scroll [['scroll args/pair!/1]]
                            shadow [['shadow args/pair!/1 args/tuple!/1 args/integer!/1]]
                            size [['size args/integer!/1]]
                            u underline [['underline either args/logic!/1 = none [true] [args/logic!/1]]]
                        ] [[]] []
                    ]
                )
                | end
                | a: (
                    do make error! reform ["TO-TEXT - syntax error at:" copy/part mold/only at src index? a 50 "..."]
                )
            ]
        ]
        bind/only dst ext-text
    ]
    to-shape: func [
        src [block!]
        dst [block!]
        /local
        cmd args a shape-arg t
    ] [
        parse reduce/only src shape-words [
            some [
                set cmd shape-command (
                    args: make shape-types []
                    shape-arg: either word? cmd [
                        all [
                            shape-args/(cmd)
                            copy shape-args/(cmd)
                        ]
                    ] [
                        none
                    ]
                )
                any [(any-arg?: false) set a shape-arg (
                        all [
                            not none? a
                            append select args t: type?/word a a
                            unless any-arg? [
                                remove/part find shape-arg t 2
                            ]
                        ]
                    )] (
                    append dst reduce switch/default cmd [
                        arc [[
                                either lit-word ['arc'] ['arc]
                                args/pair!/1
                                args/pair!/2
                                any [args/integer!/1 args/decimal!/1]
                                any [all [args/word!/1 = 'sweep 'positive] 'negative]
                                any [args/word!/2 all [args/word!/1 = 'large 'large] 'small]
                            ]]
                        close [['close]]
                        curv [[either lit-word ['curv'] ['curv] args/pair!]]
                        curve [[either lit-word ['curve'] ['curve] args/pair!]]
                        hline [[either lit-word ['hline'] ['hline] any [args/integer!/1 args/decimal!/1]]]
                        line [[either lit-word ['line'] ['line] any [all [args/pair!/2 args/pair!] args/pair!/1]]]
                        move [[either lit-word ['move'] ['move] args/pair!/1]]
                        qcurve [[either lit-word ['qcurve'] ['qcurve] args/pair!]]
                        qcurv [[either lit-word ['qcurv'] ['qcurv] args/pair!/1]]
                        vline [[either lit-word ['vline'] ['vline] any [args/integer!/1 args/decimal!/1]]]
                    ] [[]]
                )
                | end
                | a: (
                    do make error! reform ["TO-SHAPE - syntax error at:" copy/part mold/only at src index? a 50 "..."]
                )
            ]
        ]
        bind/only dst ext-shape
    ]
    set 'to-draw func [
        src [block!]
        dst [block!]
        /local
        cmd args a t draw-arg
    ] [
        parse reduce/only src draw-words [
            some [
                set cmd draw-command (
                    args: make draw-types []
                    draw-arg: either word? cmd [
                        all [
                            draw-args/(cmd)
                            copy draw-args/(cmd)
                        ]
                    ] [
                        none
                    ]
                    all [draw-arg append draw-arg [| none! (any-arg?: true)]]
                )
                any [(any-arg?: false) set a draw-arg (
                        all [
                            not none? a
                            append/only select args t: type?/word a a
                            unless any-arg? [
                                remove/part find draw-arg t 2
                            ]
                        ]
                    )] (
                    append dst reduce switch/default cmd [
                        anti-alias [['anti-alias args/logic!/1]]
                        arc [[
                                'arc
                                args/pair!/1
                                args/pair!/2
                                any [args/integer!/1 args/decimal!/1 0.0]
                                any [args/integer!/2 args/decimal!/2 90.0]
                                any [args/word!/1 'closed]
                            ]]
                        arrow [['arrow args/pair!/1 args/tuple!/1]]
                        box [['box args/pair!/1 any [args/pair!/2 100x100] any [args/integer!/1 args/decimal!/1 0]]]
                        circle [[
                                'circle
                                any [args/pair!/1 50x50]
                                as-pair a: any [args/integer!/1 args/decimal!/1 50] any [args/integer!/2 args/decimal!/2 a]
                            ]]
                        clip [
                            either args/logic!/1 = false [['clip 0x0 10000x10000]] [['clip args/pair!/1 args/pair!/2]]
                        ]
                        curve [['curve args/pair!/1 args/pair!/2 args/pair!/3 args/pair!/4]]
                        ellipse [['ellipse args/pair!/1 args/pair!/2]]
                        fill-pen [['fill-pen either a: any [args/tuple!/1 args/image!/1 args/logic!/1] [a] [false]]]
                        fill-rule [['fill-rule args/word!/1]]
                        gamma [['gamma any [args/integer!/1 args/decimal!/1]]]
                        grad-pen [[
                                'grad-pen
                                any [args/word!/1 'linear]
                                any [args/word!/2 'normal]
                                any [args/pair!/1 0x0]
                                as-pair any [args/integer!/1 args/decimal!/1 0] any [args/integer!/2 args/decimal!/2 100]
                                any [args/integer!/3 args/decimal!/3 0]
                                any [args/pair!/2 1x1]
                                args/block!/1
                            ]]
                        image [['image args/image!/1 any [all [args/pair!/2 args/pair!] any [args/pair!/1 0x0]]]]
                        image-filter [[
                                'image-filter
                                any [args/word!/1 'nearest]
                                any [args/word!/2 'resize]
                                any [args/integer!/1 args/decimal!/1]
                            ]]
                        image-options [['image-options args/tuple!/1 any [args/word!/1 'no-border]]]
                        image-pattern [[
                                'image-pattern any [args/word!/1 'normal] any [args/pair!/1 0x0] any [args/pair!/2 0x0]
                            ]]
                        line [['line args/pair!]]
                        line-cap [['line-cap args/word!/1]]
                        line-join [['line-join args/word!/1]]
                        line-pattern [['line-pattern args/tuple!/1 any [args/decimal! args/integer!]]]
                        line-width [['line-width any [args/integer!/1 args/decimal!/1 1] any [args/word!/1 'variable]]]
                        invert-matrix [['invert-matrix]]
                        matrix [['matrix args/block!/1]]
                        pen [['pen either a: any [args/tuple!/1 args/image!/1 args/logic!/1] [a] [false]]]
                        polygon [['polygon args/pair!]]
                        push [['push to-draw args/block!/1 copy []]]
                        reset-matrix [['reset-matrix]]
                        rotate [['rotate any [args/integer!/1 args/decimal!/1]]]
                        scale [['scale any [args/pair!/1 as-pair any [args/integer!/1 args/decimal!/1] any [args/integer!/2 args/decimal!/2]]]]
                        shape [['shape to-shape args/block!/1 copy []]]
                        skew [['skew args/pair!/1]]
                        spline [['spline args/pair! any [args/integer!/1 0] any [args/word!/1 'opened]]]
                        text [[
                                'text
                                any [args/pair!/1 0x0]
                                args/pair!/2
                                any [args/word!/1 'raster]
                                to-text args/block!/1 copy []
                            ]]
                        transform [[
                                'transform
                                any [args/integer!/1 args/decimal!/1 0]
                                any [args/pair!/1 0x0]
                                any [as-pair a: any [args/integer!/2 args/decimal!/2 1] any [args/integer!/3 args/decimal!/3 a]]
                                any [args/pair!/2 0x0]
                            ]]
                        translate [['translate args/pair!/1]]
                        triangle [[
                                'triangle
                                args/pair!/1
                                any [args/pair!/2 100x100]
                                any [args/pair!/3 as-pair args/pair!/1/x any [args/pair!/2/y 100]]
                                args/tuple!/1
                                args/tuple!/2
                                args/tuple!/3
                                any [args/integer!/1 args/decimal!/1 0]
                            ]]
                    ] [[]]
                )
                | end
                | a: (
                    do make error! reform ["TO-DRAW - syntax error at:" copy/part mold/only at src index? a 50 "..."]
                )
            ]
        ]
        bind/only dst ext-draw
    ]
]
sum-pair: func [pair] [pair/x + pair/y]
merge-values: funct [
    {Merge a source object's defined values into a target object.}
    obj [object!] "Target"
    src [object!] "Source"
    /force {Even if destination has a value, set it from source.}
] [
    foreach word words-of obj [
        if all [
            val: select src word
            any [force none? select obj word]
        ] [
            obj/:word: src/:word
        ]
    ]
]
debug-gui: func [
    "GUI debugging function. Allows selective enabling."
    tag [word!] "Debug category"
    args [block! string!] "Values to print."
] [
    if any [find guie/debug tag find guie/debug 'all] [
        args: reduce args
        if object? args/1 [args/1: args/1/style]
        print ['-- tag args]
    ]
    true
]
fail-gui: func [msg] [
    print ["^/** GUI ERROR:" reform msg]
    halt
]
warn-gui: func [msg] [
    print ["^/** GUI WARNING:" reform msg]
    none
]
assert-gui: func [cond msg] [
    unless cond [fail-gui msg]
]
remind-gui: func [body /when cond] [
    if all [
        guie/remind
        any [not when cond]
    ] [
        print ["-- remind:" reform body]
    ]
]
debug-face: func [
    face
    word
    block
    /local flags style
] [
    if all [
        any [
            flags: select face 'debug
            all [
                style: select guie/styles face/style
                flags: select style 'debug
            ]
        ]
        any [
            not block? flags
            find flags word
        ]
    ] [
        print ajoin ["-- debug-face[" face/style ":" word "]: " remold block]
    ]
]
dump-face: func [face /indent d] [
    print [
        any [d ""]
        to-set-word face/style
        face/gob/offset
        "size:" face/gob/size
        any [select face 'name "*"]
        mold any [select face/facets 'text-body "*"]
    ]
]
dump-layout: func [layout /indent d] [
    unless d [d: copy ""]
    dump-face/indent layout d
    insert d "  "
    foreach-face f layout [
        either find [panel group] f/style [
            dump-layout/indent f d
        ] [
            dump-face/indent f d
        ]
    ]
    remove/part d 2
]
guie: context [
    max-pair: as-pair 3.4028235e38 3.4028235e38
    max-coord: max-pair/x
    debug: []
    remind: off
    styles: make map! 30
    fonts: make map! 20
    dialect: make object! 50
    shows: make block! 20
    tags: make map! 20
    colors:
    box-models:
    focal-face:
    popup-face:
    popup-parent:
    drag:
    style:
    font:
    face:
    face-state:
    char-space:
    char-valid:
    none
    handler: none
    error-handler: none
    timeout: false
    timer-id: 0
    timers: []
    tool-tip-delay: 1
    tool-tip-timeout: none
    tool-tip-follow: false
    font-sans: switch system/version/4 [
        3 [
            "Arial"
        ]
        13 [
            "/system/fonts/DroidSans.ttf"
        ]
    ]
    font-serif: switch system/version/4 [
        3 [
            "Times New Roman"
        ]
        13 [
            "/system/fonts/DroidSerif.ttf"
        ]
    ]
    font-mono: switch system/version/4 [
        3 [
            "Courier new"
        ]
        13 [
            "/system/fonts/DroidMono.ttf"
        ]
    ]
]
guie/style: object [
    name:
    facets:
    draw:
    actors:
    tags:
    options:
    parent:
    state:
    intern:
    content:
    none
    about: "Not documented."
]
guie/face: object [
    style:
    facets:
    state:
    gob:
    options:
    tags:
]
guie/face-state: object [
    mode: 'up
    over: no
    value: none
]
guie/style/facets: object [
    init-size: 100x100
    min-size: 0x0
    max-size: guie/max-pair
    align: 'left
    valign: 'top
    resizes: true
    box-model: 'tight
    gob: none
    gob-size: none
    space: [0x0 0x0]
    margin-box: [
        top-left: 0x0
        top-right: 0x0
        bottom-left: 0x0
        bottom-right: 0x0
        center: 0x0
    ]
    border-box: copy margin-box
    padding-box: copy margin-box
    viewport-box: copy margin-box
]
guie/box-models: reduce/no-set [
    tight: object [
        border-color: none
        border-size: [0x0 0x0]
        bg-color: none
        margin: [0x0 0x0]
        padding: [0x0 0x0]
        spacing: 0x0
    ]
    layout: object [
        border-color: none
        border-size: [0x0 0x0]
        bg-color: none
        margin: [0x0 0x0]
        padding: [3x3 3x3]
        spacing: 5x5
    ]
    frame: object [
        border-color: coal
        border-size: [1x1 1x1]
        bg-color: none
        margin: [0x0 0x0]
        padding: [3x3 3x3]
        spacing: 5x5
    ]
]
guie/drag: context [
    face:
    event:
    start:
    delta:
    base:
    base-offset:
    gob:
    origin:
    data:
    none
    active: false
    show-parent?: true
]
append guie/dialect [
    default: [set-word!]
    options: [block!]
    divider: []
    resizer: []
    attach: [word! lit-path!]
    debug: [block!]
    return: []
]
guie/colors: context [
    focus: 50.160.250
]
system-cursors: context [
    app-start: 32650
    hand: 32649
    help: 32651
    hourglass: 32650
    arrow: 32512
    cross: 32515
    i-shape: 32513
    no: 32648
    size-all: 32646
    size-nesw: 32643
    size-ns: 32645
    size-nwse: 32642
    size-we: 32644
    up-arrow: 32516
    wait: 32514
]
stylize: func [
    {Create one or more styles (with simple style dialect).}
    list [block!] "Format: name: [def], name: parent [def]"
    /local name parent spec style spot
] [
    assert-gui parse list [
        some [
            spot:
            set name set-word!
            set parent opt word!
            set spec block! (make-style to-word name parent spec)
        ]
    ] ["Invalid style syntax:" spot]
    debug-gui 'dialect [name]
]
make-style: funct [
    "GUI API function for creating a style."
    name [word!]
    parent [word! none!]
    spec [block! none!]
] [
    debug-gui 'make-style [name]
    parname: parent
    parent: either parent [guie/styles/:parent] [guie/style]
    assert-gui parent ["Unknown parent style for:" name]
    style: copy parent
    style/name: name
    if name <> parname [style/parent: parname]
    foreach [field code] [
        tags [if val [make-tags val]]
        facets [if val [make parent/facets val]]
        options [append-dialect name parent/name val]
        actors [if val [make-actors parent val]]
        intern [if val [if override: val/1 = 'override [val: next val] make any [all [not override parent/intern] object!] val]]
        draw [val]
        state [val]
        content [val]
        about [val]
        debug [extend style 'debug val val]
    ] [
        val: select spec to-set-word field
        unless any [none? :val block? :val string? :val] [
            print ["Invalid style field:" field "with" mold :val]
        ]
        if result: do code [style/:field: result]
    ]
    if find select style 'debug 'style [
        print ajoin ["-- debug-style [" name "]: " mold style]
    ]
    repend guie/styles [name style]
]
append-dialect: func [
    style-name [word!]
    parent [word! none!]
    block
    /local name types init options type-list
] [
    options: clear []
    type-list: head clear next [char!]
    either block? :block [
        parse block [
            some [
                set name set-word!
                set types block!
                opt string!
                set init opt block! (
                    repend options [name init]
                    append type-list either 1 < length? types [make typeset! types] [types]
                )
            ]
        ]
        type-list: copy type-list
    ] [
        type-list: select guie/dialect parent
        all [
            parent
            name: select guie/styles parent
            options: name/options
        ]
    ]
    extend guie/dialect style-name any [type-list copy []]
    either block? options [context options] [copy options]
]
style-tags: [
    internal
    layout
    compound
    edit
    state
    action
    info
    tab
    detab
    eat-tab
    auto-tab
    select
    keep
]
face-tags: [
    default
    focus
    disabled
    frozen
    dirty
]
window-tags: [
    form
    inform
    popup
]
guie/tags: make map! []
foreach tag style-tags [repend guie/tags [tag true]]
foreach tag face-tags [repend guie/tags [tag true]]
foreach tag window-tags [repend guie/tags [tag true]]
tag-error: funct [
    "Generate error on tag problem"
    words [word! block!]
    error [word!]
] [
    or-tag: func [w] [replace/all reform w " " " or "]
    fail-gui select [
        unknown ["Unknown tag:" words]
        coexist [words/1 "cannot coexist with " or-tag next words]
        requires [words/1 "requires" or-tag next words]
    ] error
]
tag-face?: funct [
    "Queries whether a tag exists for a face"
    face
    tag
    /deep
] [
    any [not word? tag guie/tags/:tag tag-error tag 'unknown]
    either deep [
        if deep [traverse-face [tag-face? face tag]]
    ] [
        either all [block? tag not empty? tag] [
            foreach t tag [if tag-face? face t [return true]]
        ] [
            all [face face/tags/:tag]
        ]
    ]
]
tag-face: funct [
    "Applies a tag to a face"
    face
    tag
    /deep
] [
    any [guie/tags/:tag tag-error tag 'unknown]
    unless apply :tag-face? [face tag deep] [face/tags/:tag: true]
    face
]
untag-face: funct [
    "Removes a tag from a face"
    face
    tag
    /deep
] [
    any [guie/tags/:tag tag-error tag 'unknown]
    face/tags/:tag: none
    if deep [traverse-face [face/tags/:tag: none]]
    face
]
make-tags: funct [
    tags
] [
    map: make map! 4
    foreach tag tags [repend map [tag true]]
    map
]
tagged-faces: funct [
    "Return all faces with a tag"
    face [object!] "Face to search for faces"
    tag [word!] "Tag to search for"
] [
    faces: copy []
    traverse-face face [if tag-face? face tag [append faces face]]
    unique faces
]
guie/style/tags: make-tags []
do-actor: funct [
    "Call actor function of face or style."
    faces [block! object!] "Face or block of faces"
    act [word!] "Actor identifier"
    data {Argument to the actor (use block for multiple args).}
    /style "Do actor from other style only"
    style-name [word!] "Style for actor"
    /bubble {Allow event to bubble up if specified actor not found}
] [
    result: none
    out: copy []
    blockified?: unless block? faces [faces: append copy [] faces]
    foreach face faces [
        result: none
        actor: none
        all [
            style: select guie/styles any [style-name face/style]
            any [
                actor: any [
                    all [not style-name select select face 'actors act]
                    all [style/actors select style/actors act]
                ]
                result: false
            ]
            set/any 'result actor face :data
        ]
        if unset? :result [result: none]
        all [
            bubble
            none? :actor
            face/gob/parent
            face/gob/parent/data
            result: apply :do-actor [face/gob/parent/data act data any [style-name] style-name bubble]
        ]
        append/only out :result
    ]
    either blockified? [:out/1] [out]
]
do-face: funct [
    "Execute standard action sequence of a face"
    face [object!]
    /from
    src-face [object!]
    /no-show
] [
    targets: select face 'targets
    forall targets [
        dst-face: targets/1: get-target face targets/1
        all [
            src-face <> dst-face
            dst-face/attached-face: f: any [src-face face]
            do-actor f 'on-attached reduce [dst-face no-show]
            none? dst-face/attached-face: none
            apply :do-face [dst-face from f no-show]
        ]
    ]
    unless no-show [do-actor face 'on-action get-face face]
]
has-actor?: func [
    "Return true if face/style has this actor."
    face [object!]
    act [word!] "Actor identifier"
] [
    true? any [
        select select face 'actors act
        select select select guie/styles face/style 'actors act
    ]
]
do-related: funct [
    {Find related faces and call their specified actor id.}
    face
    related [word! block!]
    /deep "nested traversal"
    /from "traverse form specific face"
    beg-face [object!]
] [
    if word? related [
        if parent: any [beg-face parent-face? face] [
            foreach fac faces? parent [
                do-actor fac related face
                if all [
                    deep
                    has-faces? fac
                ] [
                    do-related/deep/from face related fac
                ]
            ]
        ]
    ]
]
do-targets: funct [
    "Do all target faces to update them."
    face [object!]
    /custom "Do custom action instead"
    action [block!]
] [
    targets: select face 'targets
    forall targets [
        target: targets/1: get-target face targets/1
        either custom [
            do bind action 'target
        ] [
            do-face/from target face
        ]
    ]
]
do-attached: funct [
    "Do all attached faces to update them."
    face [object!]
    /custom "Add custom code for specific style"
    data "Tagged block [ style-name [custom-code] ]"
] [
    foreach attached select face 'attached [
        all [not object? attached attached: get attached]
        if all [
            custom
            c: select data attached/style
        ] [
            do bind c 'attached
        ]
        do-face/from attached face
    ]
]
find-face-actor: funct [
    {Find the next (or prior) face that responds to the given actor.}
    face [object!]
    act [word!]
    /reverse
] [
    dir: pick [-1 1] true? reverse
    if all [
        parent: parent-face? face
        faces: find faces? parent face
    ] [
        faces: skip faces dir
        forskip faces dir [
            if has-actor? first faces act [return first faces]
        ]
    ]
]
do-bind-actor: funct [face actor-block] [
    all [
        pf: parent-face? face
        in pf 'names
        actor-block: bind/copy actor-block pf/names
    ]
    all [
        in face 'names
        actor-block: bind/copy actor-block face/names
    ]
    do actor-block
]
get-target: funct [
    face [object!]
    target [object! word!]
] [
    unless object? target [
        target: any [
            all [
                cf: compound-face? face
                in cf 'names
                select cf/names target
            ]
            get target
        ]
    ]
    unless all [
        in target 'attached
        find target/attached face
    ] [
        extend-face target 'attached face
        do-actor target 'on-attach face
    ]
    unless in target 'attached-face [
        extend target 'attached-face 0
        target/attached-face: none
    ]
    target
]
bind-targets: funct [
    layout [object!]
] [
    foreach f faces? layout [
        targets: select f 'targets
        forall targets [
            targets/1: get-target f targets/1
        ]
        bind-targets f
    ]
]
make-actors: funct [
    parent
    actors
] [
    map: either parent [copy parent/actors] [make map! 4]
    unless parse actors [
        any [
            here:
            set-word! block! (
                repend map [here/1 funct/closure [face arg] here/2]
            )
        ]
    ] [
        fail-gui ["Bad style actor:" here]
    ]
    map
]
guie/style/actors: make-actors none [
    locate: [
        arg/offset
    ]
    on-resize: [
        if any [face/facets/resizes face/gob/size <> 0x-1] [
            if all [
                in face/facets 'intern
                in face/facets/intern 'update?
                face/facets/intern/update?
            ] [do-actor face 'on-update none]
            set-draw-keywords-in face/facets arg
        ]
        unless face/gob/size = 0x-1 [face/gob/size: face/facets/gob-size]
    ]
    on-get: [
        select face/state arg
    ]
    on-action: []
    on-attached: [
        apply :set-face [arg/1 get-face face arg/2]
        true
    ]
]
materials: make object! [
    base: make object! [
        up: down: over: make object! [
            specular: 'high
            intensity: 1
            diffusion: [1 1]
            opacity: 1
            texture: none
        ]
    ]
    shadow: make base [
        up: over: make up [
            diffusion: 0.0.0.55
        ]
        down: make up [
            diffusion: 255.255.255.155
        ]
    ]
    chrome: make base [
        up: make up [
            diffusion: [1.0 000% 0.9 5% 0.85 10% 0.78 70% 0.76 75% 0.7 80% 0.76 97% 1.0 100%]
        ]
        down: make up [
            intensity: 0.9
        ]
        over: make up [
            intensity: 1.05
        ]
    ]
    chrome-groove: make base [
        up: over: down: make up [
            diffusion: [0.7 000% 0.4 5% 0.5 20% 0.7 49% 0.72 50% 0.7 75%]
        ]
    ]
    scroller: make base [
        up: make up [
            diffusion: [0.7 000% 0.4 5% 0.65 20% 0.75 49% 0.72 50% 0.7 55% 0.5 80%]
        ]
        over: make up []
        down: make up [
            diffusion: [0.6 000% 0.8 65% 0.7 100%]
        ]
    ]
    piano: make chrome [
        up: make up [
            diffusion: [0.82 000% 0.72 49% 0.7 50% 0.6 51% 0.76 97% 1.0 100%]
        ]
        down: make up [
            intensity: 0.9
        ]
        over: make up [
            intensity: 1.05
        ]
    ]
    aluminum: make base [
        up: make up [
            diffusion: [1.0 000% 0.74 7% 0.7 70% 0.71 97% 1.0 100%]
        ]
        down: make up [
            diffusion: [0.67 000% 0.78 7% 0.71 70% 0.72 97% 1.0 100%]
        ]
        over: make up [
            intensity: 1.03
        ]
    ]
    container-groove: make base [
        up: down: over: make up [
            diffusion: [0.0.0.55 000% 0.0.0.0 50% 255.255.255.0 50% 255.255.255.35 100%]
        ]
    ]
    field-groove: make base [
        up: down: over: make up [
            specular: 'linear
            diffusion: [0 000% 0.5 10% 0.99 40% 1 100%]
        ]
    ]
    dark-groove: make base [
        up: down: over: make up [
            diffusion: [0.0.0.159 000% 0.0.0.127 50% 0.0.0.115 60% 0.0.0.95 90%]
        ]
    ]
    radial-aluminum: make aluminum [
        up: make up [
            intensity: 1.1
            diffusion: [0.8 000% 0.78 10% 0.72 70% 0.7 95% 0.8 100%]
        ]
        down: make up [
            intensity: 1
            diffusion: [0.65 000% 0.7 70% 0.75 95% 0.85 100%]
        ]
        over: make up [
            intensity: 1.03
        ]
    ]
    led: make base [
        on: make up [
            diffusion: [1.0 000% 0.68 5% 0.68 49% 0.75 50% 0.9 95% 1.0 100%]
        ]
        off: make on [
            diffusion: [1.0 000% 0.0 5% 0.0 49% 0.08 50% 0.25 95% 1.0 100%]
        ]
    ]
    plastic: make base [
        up: down: make up [
            specular: 'linear
            diffusion: [0.85 0.6]
        ]
        over: make up [
            intensity: 1.2
        ]
    ]
    paper: make base [
        up: make up [
            specular: 'mul
            diffusion: [0.75 0.75]
        ]
        down: make up [
            intensity: 0.9
        ]
        over: make up [
            intensity: 1.1
        ]
    ]
    groove: make base [
        up: down: over: make up [
            specular: 'mul
            diffusion: [0.1 000% 0.5 5% 0.65 50% 0.9 100%]
        ]
    ]
    fluorescent: make base [
        up: down: over: make up [
            specular: 'linear
            diffusion: [0.8 000% 1 100%]
            opacity: 0.7
        ]
    ]
    candy-stripe: make base [
        up: down: over: make up [
            diffusion: [255.255.255.0 255.255.255.0 255.255.255.15 255.255.255.15]
        ]
    ]
]
'materialize [
    base: [
        color: white
        specular: 'high
        diffusion: []
        opacity: 1
        texture: none
    ]
    chrome: base [
        diffusion: [1.0 000% 0.78 49% 0.76 50% 0.7 51% 0.76 97% 1.0 100%]
    ]
    aluminum: base [
        diffusion: [
            up: [1.0 000% 0.74 7% 0.7 70% 0.71 97% 1.0 100%]
            down: []
            over: []
        ]
    ]
    plastic: base [
        specular: 'linear
        diffusion: [0.76 0.73]
    ]
    fluorescent: base [
        specular: 'linear
        diffusion: [0.6 0.9 0.6]
        opacity: 0.7
    ]
    paper: base [
        specular: 'avg
        diffusion: [0.75 0.75]
    ]
    carpet: [
        specular: 'linear
        diffusion: [1.0 1.0]
        texture: random-noise-image
    ]
]
make-face: funct [
    {Returns a new face based on the style with various attributes.}
    style [word!] "Name of style"
    opts [block! none!] "Optional variations of style"
    /not-on-make "don't call on-make actor"
] [
    styl: guie/styles/:style
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
    face/gob: make gob! [data: face]
    face/facets/gob: face/gob
    unless not-on-make [
        set-box-model face
        do-actor face 'on-make none
    ]
    face
]
make-options: funct [
    style [word!]
    values [block!]
] [
    assert-gui styl: guie/styles/:style ["Unknown style:" style]
    options: clear []
    foreach word append clear next [access-key] words-of styl/options [
        if first values [repend options [to-set-word word first values]]
        values: next values
    ]
    options
]
resize-face: func [
    "adjust the size of the given FACE"
    face [object!]
    size [pair!]
    /no-show "do not update and show the parent layout"
] [
    face/facets/gob-size: size
    either no-show [
        reinit/no-show face
    ] [
        reinit face
    ]
]
reinit: func [
    {update the init-sizes of the relevant faces using their gob-sizes}
    face [object!]
    /no-show "do not update and show the parent layout"
    /local parent
] [
    while [
        all [
            parent: face/gob/parent
            parent: parent/data
            face: parent
            auto-sizes? face
        ]
    ] []
    recursive-reinit face
    either no-show [
        update-face/no-show face
    ] [
        update-face face
    ]
]
recursive-reinit: func [
    face [object!]
    /local gob
] [
    either all [in face/facets 'intern in face/facets/intern 'update?] [
        if face/facets/gob-size [
            case [
                pair? face/facets/init-hint [
                    face/facets/init-hint: face/facets/gob-size
                ]
                block? face/facets/init-hint [
                    if number? face/facets/init-hint/1 [
                        face/facets/init-hint/1: face/facets/gob-size/x
                    ]
                    if number? face/facets/init-hint/2 [
                        face/facets/init-hint/2: face/facets/gob-size/y
                    ]
                ]
            ]
        ]
        face/facets/intern/update?: true
        repeat i length? face/gob [
            gob: face/gob/:i
            recursive-reinit gob/data
        ]
    ] [
        if face/facets/gob-size [face/facets/init-size: face/facets/gob-size]
    ]
]
auto-sizes?: func [
    "Find out whether the given LAYOUT auto-sizes."
    layout [object!]
] [
    any [
        layout/facets/init-hint = 'auto
        layout/facets/min-hint = 'auto
        layout/facets/max-hint = 'auto
        all [
            block? layout/facets/init-hint
            find layout/facets/init-hint 'auto
        ]
        all [
            block? layout/facets/min-hint
            find layout/facets/min-hint 'auto
        ]
        all [
            block? layout/facets/max-hint
            find layout/facets/max-hint 'auto
        ]
    ]
]
update-face: funct [
    {Notifies, updates and shows the parents of the given FACE.}
    face [object!]
    /no-show "Do not really update and show."
    /content {The given FACE is a layout and its contents changed.}
] [
    layout: either content [face] [
        all [layout: face/gob/parent layout/data]
    ]
    while [
        all [
            layout
            face: layout
            not face/facets/intern/update?
            face/facets/intern/update?: true
            auto-sizes? face
            layout: face/gob/parent
            layout: layout/data
        ]
    ] []
    unless no-show [
        while [
            all [
                layout: face/gob/parent
                layout: layout/data
                layout/facets/intern/update?
                face: layout
            ]
        ] []
        either pair? face/facets/gob-size [
            if auto-sizes? face [
                old-init-size: face/facets/init-size
                do-actor face 'on-update none
                face/facets/gob-size: face/facets/gob-size * face/facets/init-size / old-init-size
            ]
        ] [
            do-actor face 'on-update none
            face/facets/gob-size: face/facets/init-size
        ]
        do-actor face 'on-resize face/facets/gob-size
        draw-face face
    ]
]
extend-face: func [
    face [object!]
    field [word!]
    value
    /only
] [
    apply :append [
        any [
            select face field
            extend face field make block! 1
        ]
        value
        none
        none
        only
    ]
]
attach-face: funct [
    src-face [object!]
    dst-face [object! word! lit-path!]
] [
    extend-face/only src-face 'targets dst-face
]
show-face: funct [
    {Set the visibility attributes of a face/block of faces.}
    face [object! block!] "a face or a block of faces"
    show [word!] "one of: VISIBLE HIDDEN IGNORED FIXED"
    /no-show
] [
    visible: any [show = 'visible show = 'fixed]
    resizes: any [show = 'visible show = 'hidden]
    either object? face do-show: [
        if all [
            face/gob/size <> 0x-1
            not visible
        ] [
            if guie/focal-face = face [unfocus]
            face/facets/gob-size: face/gob/size
            face/gob/size: 0x-1
        ]
        if all [
            face/gob/size = 0x-1
            visible
        ] [
            face/gob/size: face/facets/gob-size
        ]
        either resizes <> face/facets/resizes [
            face/facets/resizes: resizes
            apply :update-face [face no-show]
        ] [
            unless no-show [
                draw-face either visible [face] [face/gob/parent/data]
            ]
        ]
    ] [
        foreach face face do-show
    ]
]
show?: funct [
    "Get the visibility attributes of the given FACE."
    face [object!]
] [
    either face/gob/size = 0x-1 [
        either face/facets/resizes ['hidden] ['ignored]
    ] [
        either face/facets/resizes ['visible] ['fixed]
    ]
]
focus: func [
    "Focus given FACE"
    face [object!]
    /force {force focus on already focused face (used in re-focusing cases)}
    /actor-result "returns on-focus actor result if possible"
    /local result
] [
    unless window-face? face [
        return none
    ]
    if all [not force guie/focal-face = face] [return face]
    if guie/focal-face <> face [
        if 'stop-event = apply :unfocus [actor-result] [
            return 'stop-event
        ]
    ]
    set-facet window-face? face 'tab-face guie/focal-face: face
    result: do-actor face 'on-focus reduce [true force]
    either actor-result [
        result
    ] [
        face
    ]
]
unfocus: func [
    /actor-result "returns on-focus actor result if possible"
    /self "used by recursive calls - don't call on-focus"
    /local win-face result
] [
    if guie/focal-face [
        if win-face: window-face? guie/focal-face [
            unless self [result: do-actor guie/focal-face 'on-focus reduce [false none]]
            set-facet win-face 'tab-face none
        ]
        guie/focal-face: none
        if actor-result [
            result
        ]
    ]
]
next-focus: funct [
    face [object!] "Window face or any face from related window."
] [
    process-tab make object! [flags: none window: select window-face? face 'gob]
]
prev-focus: funct [
    face [object!] "Window face or any face from related window."
] [
    process-tab make object! [flags: [shift] window: select window-face? face 'gob]
]
tall-face?: funct [
    {Returns TRUE if the face is taller than it is wide.}
    face
] [
    equal? face-axis? face 'y
]
face-axis?: funct [
    "Returns face major axis as 'x or 'y."
    face
] [
    axis: get-facet face 'axis
    if none? axis [
        size: face/facets/viewport-box/bottom-right
        axis: either size [pick [x y] size/x < size/y] [none]
    ]
    axis
]
find-title-text: func [
    "Finds the title text of a layout."
    layout [object!]
] [
    foreach face faces? layout [
        if face/style = 'title [
            return get-facet face 'text-body
        ]
    ]
    none
]
face-text-size: funct [
    {Return position in text and height of visible area in precent!. Useful for scroller.}
    face [object!]
] [
    if zero? height: second size-txt gob: sub-gob? face [height: 1]
    size: min 100% to percent! gob/size/y / height
    t: max 000% negate gob/size/y - height - 5
    scroll: get-gob-scroll gob
    start: either zero? t [000%] [limit to percent! negate scroll/y / t 000% 100%]
    reduce [start size]
]
init-drag: func [
    {Initialize drag operation, reusing a common drag object.}
    face
    spot "Initial condition (initial value, offset, etc)."
    /only {Drag only inside face, do not use face for drag'n'drop.}
    /data "Holds optional user data."
    user-data
] [
    guie/drag/face: face
    guie/drag/base: any [spot face/gob/offset]
    guie/drag/base-offset: face/gob/offset
    guie/drag/gob: either only [none] [face/gob]
    guie/drag/delta: 0x0
    guie/drag/origin: find face/gob/parent face/gob
    guie/drag/show-parent?: true
    guie/drag/data: user-data
    guie/drag/active: false
    guie/drag/event: none
    guie/drag/start: none
    draw-face face
    guie/drag
]
reset-drag: does [
    set/pad guie/drag []
    guie/drag/show-parent?: true
    guie/drag/active: false
]
confine: func [
    {Return the correct offset to keep rectangular area in-bounds.}
    offset [pair!] "Initial offset"
    size [pair!] "Size of area"
    origin [pair!] "Lower bound (upper left)"
    margin [pair!] "Upper bound (lower right)"
] [
    if offset/x < origin/x [offset/x: origin/x]
    if offset/y < origin/y [offset/y: origin/y]
    margin: margin - size
    if offset/x > margin/x [offset/x: margin/x]
    if offset/y > margin/y [offset/y: margin/y]
    offset
]
get-gob-offset: funct [
    gob
] [
    offset: gob/offset
    either all [gob/parent gob/parent/parent gob/parent/parent/parent] [
        offset + get-gob-offset gob/parent
    ] [
        offset
    ]
]
map-face-offset: funct [
    "Map face's offset relative to another face"
    face [object!] "Face to map"
    base-face [object!] "Base object (relative zero position)"
] [(get-gob-offset face/gob) - get-gob-offset base-face/gob]
center-face: funct [
    {Set face's offset so the face will be centered on the screen}
    face [object!] "Face to center"
    /window "Center to face's window"
    /with
    base-face [object!] "Center face to this face"
] [
    case [
        window (base-face: window-face? face)
        not with (base-face: system/view/screen-gob/face)
    ]
    face-size: get-facet face 'gob-size
    base-size: get-facet base-face 'gob-size
    face/gob/offset: base-size - face-size / 2
]
get-fields?: funct [
    "Return fields that can be set using set-face/field"
    face
] [
    fields: get-facet face 'get-fields
    either fields [words-of fields] [clear []]
]
set-fields?: funct [
    "Return fields that can be set using set-face/field"
    face
] [
    fields: get-facet face 'set-fields
    either fields [words-of fields] [clear []]
]
sub-gob?: func [
    "Return face's internal area gob."
    face [object!]
] [
    face/gob/1
]
parent-face?: func [
    "Return face's parent or none for top face."
    face [object!]
] [
    all [
        face/gob/parent
        face/gob/parent/data
    ]
]
window-face?: funct [
    "Return window face where face belongs."
    face [object!]
] [
    all [
        gob: map-gob-offset/reverse face/gob 1x1
        gob: first gob
        find system/view/screen-gob gob
        gob/data
    ]
]
root-face?: funct [
    "Returns whether the face is a root face"
    face [object!]
] [
    face/style = 'window
]
tip-face?: funct [
    {Travels inward through all last faces in starting at the given face and returns the innermost one.}
    face [object!]
] [
    if empty? faces: faces? face [return face]
    last-face: last faces
    tip-face: none
    until [
        faces: faces? last-face
        either empty? faces [
            tip-face: :last-face
        ] [
            last-face: last :faces
        ]
        tip-face
    ]
]
return-face?: funct [
    {Returns the next possible face outward and then forward in the hierarchy}
    face [object!]
] [
    unless face/gob/parent [return face]
    return-face: none
    fp: parent-face? face
    until [
        either root-face? fp [
            return-face: fp
        ] [
            faces: locate-face fp
            either all [faces single? faces] [
                fp: parent-face? fp
            ] [
                return-face: faces/2
            ]
        ]
        return-face
    ]
]
locate-face: funct [
    {Locate the index for the given face in the parent face block}
    face [object!]
    /reverse "Find backwards"
] [
    fp: parent-face? face
    fpp: if fp [faces? fp]
    if block? fpp [find fpp face]
]
back-face?: funct [
    "Returns the face before this one."
    face [gob! object!]
    /no-recurse
] [
    if gob? face [face: face/data]
    if root-face? face [return tip-face? face]
    faces: locate-face face
    if head? faces [return parent-face? face]
    either no-recurse [first back faces] [tip-face? first back faces]
]
next-face?: funct [
    "Returns the face after this one."
    face [gob! object!]
    /no-recurse
] [
    if gob? face [face: face/data]
    if any [root-face? face all [not no-recurse not empty? f: faces? face]] [return first any [f faces? face]]
    faces: locate-face face
    any [
        faces/2
        return-face? face
    ]
]
find-face?: funct [
    {Deeply find the next face from specs relative to the given face.}
    face [gob! object!]
    spec
    /reverse "Find backwards"
    /no-recurse "disable recursion"
    /only "disable recursion only for the first searched face"
] [
    fc: either gob? face [face/data] [face]
    all [only no-recurse: true]
    until [
        face: apply either reverse [:back-face?] [:next-face?] [face no-recurse]
        all [
            only
            only: no-recurse: false
        ]
        any [
            face = fc
            do bind spec 'face
        ]
    ]
    if face <> fc [face]
]
traverse-face: funct [
    {Traverses a face deeply and performs a function on each subface.}
    face [gob! object!]
    action
    /only these-faces
] [
    if gob? face [face: face/data]
    if empty? faces? face [return face]
    last-face: tip-face? face
    func-act: func [face] action
    these-act: all [only func [face] these-faces]
    until [
        face: next-face? face
        all [
            any [not only these-act face]
            func-act face
        ]
        same? last-face face
    ]
]
within-face?: funct [
    "Returns whether a face exists within another face."
    child [gob! object!]
    parent [gob! object!]
] [
    if gob? child [child: child/data]
    result: false
    traverse-face parent [result: any [result face = child]]
    to-logic result
]
find-tab-face?: funct [
    {Return the next tab face in the window face for the given tab face}
    tab-face [object!]
    /reverse
    /no-recurse
] [
    if reverse [
        lf: tab-face
        until [
            f: back-face?/no-recurse lf
            unless tag-face? f 'eat-tab [
                f: back-face? lf
            ]
            tag-face? lf: f 'tab
        ]
        no-recurse: tag-face? f 'eat-tab
    ]
    apply :find-face? [tab-face [all [tag-face? face 'tab face/gob/size <> 0x-1]] reverse all [reverse no-recurse] all [not reverse no-recurse]]
]
compound-face?: funct [
    {Return the compound face for an existing face, or the face itself, if no face is found}
    face [object! gob!]
] [
    if gob? face [face: face/data]
    fc: face
    until [
        face: parent-face? face
        any [root-face? face found: tag-face? face 'compound]
    ]
    either found [face] [fc]
]
find-access-key: funct [
    face [object!]
    id [char!]
] [
    if all [
        win: window-face? face
        access-keys: select win/facets 'access-keys
    ] [
        any [
            key: find/skip next access-keys id 2
            parse access-keys [
                some [
                    block! ak: block! (
                        all [
                            key: find/skip next ak/1 id 2
                            break
                        ]
                    )
                    | skip
                ]
            ]
        ]
    ]
    all [key first back key]
]
process-access-key: funct [
    "Process access key if available"
    event [event!] "Keyboard event"
] [
    if event/flags <> [control shift] [return none]
    win: event/window/data
    if all [
        char? event/key
        32 > to integer! key: event/key
    ] [
        key: to char! key + 64
    ]
    either access-keys: select win/facets 'access-keys [
        id: any [
            select/skip access-keys key 2
            all [
                not find/skip next access-keys key 2
                key
            ]
        ]
    ] [
        id: key
    ]
    if all [
        id
        f: find-face? win [id = select face/facets 'access-key]
    ] [
        f: any [
            get select f/facets 'access-face
            f
        ]
        focus f
        unless tag-face? f 'edit [
            e: make event! [
                type: 'key
                key: #" "
            ]
            do-actor f 'on-key e
        ]
        f
    ]
]
process-shortcut-key: funct [
    "Process shortcut key if available"
    event [event!] "Keyboard event"
] [
    if all [
        win: event/window/data
        shortcut-keys: select win/facets 'shortcut-keys
        action: select/skip/case shortcut-keys event/key 2
    ] [
        not 'propagate-event = do funct [arg] action event
    ]
]
process-tab: funct [
    "Process tab key (move focus)"
    event [event! object!] {Keyboard event (tab key) or event compatible object.}
] [
    if find event/flags 'control [return none]
    win: event/window/data
    unless tab-face: get-facet win 'tab-face [
        tab-face: win
    ]
    if tag-face? tab-face 'detab [
        return 'propagate-event
    ]
    if all [
        tab-face <> win
        tab-face <> guie/focal-face
    ] [
        focus tab-face
        exit
    ]
    shift-key: found? find event/flags 'shift
    if new-tab-face: apply :find-tab-face? [tab-face shift-key tag-face? tab-face 'eat-tab] [
        switch focus/actor-result new-tab-face [
            propagate-event [
                return 'propagate-event
            ]
            stop-event [
                return 'stop-event
            ]
        ]
        tab-face: new-tab-face
    ]
    tab-face
]
faces?: funct [
    "Get a block of faces in a layout"
    face [object!]
] [
    face: face/gob
    result: make block! length? face
    repeat i length? face [
        sg: face/:i
        if same? sg sg/data/gob [append result sg/data]
    ]
    result
]
foreach-face: closure [
    {Evaluates the BODY block for each subface in the layout.}
    'word [word!] "Word to set each time (local)"
    layout [object!] "The layout to traverse"
    body [block!] "Block to evaluate each time"
    /local sg result
] [
    word: repeat (word) 1 reduce [:quote word]
    body: bind/copy body word
    layout: layout/gob
    repeat i length? layout [
        sg: layout/:i
        if same? sg sg/data/gob [
            set word sg/data
            set/any 'result do body
        ]
    ]
    get/any 'result
]
has-faces?: funct [
    "Finds out whether the face has content"
    face [object!]
] [
    face: face/gob
    repeat i length? face [
        sg: face/:i
        if same? sg sg/data/gob [return true]
    ]
]
dialect-draw: make object! [
    type-spec: [block!]
    anti-alias: [logic!]
    arc: [
        pair! pair! decimal! decimal! word!
        decimal! word!
    ]
    arrow: [tuple! pair!]
    box: [pair! pair! decimal!]
    circle: [pair! decimal! decimal!]
    clip: [pair! pair! logic!]
    curve: [* pair!]
    effect: [pair! pair! block!]
    ellipse: [pair! pair!]
    fill-pen: [tuple! image! logic!]
    fill-rule: [word!]
    gamma: [decimal!]
    grad-pen: [word! word! pair! logic! decimal! decimal! decimal! pair! block!]
    invert-matrix: []
    image: [image! tuple! word! word! integer! integer! integer! integer! * pair!]
    image-filter: [word! word! decimal!]
    line: [* pair!]
    line-cap: [word!]
    line-join: [word!]
    line-pattern: [logic! tuple! * decimal!]
    line-width: [decimal! word!]
    matrix: [block!]
    pen: [tuple! image! logic!]
    polygon: [* pair!]
    push: [block!]
    reset-matrix: []
    rotate: [decimal!]
    scale: [decimal! decimal!]
    shape: [block!]
    skew: [pair!]
    spline: [integer! word! * pair!]
    text: [word! pair! pair! block!]
    transform: [decimal! pair! decimal! decimal! pair!]
    translate: [pair!]
    triangle: [pair! pair! pair! tuple! tuple! tuple! decimal!]
    close: []
    curv: [* pair!]
    hline: [decimal!]
    move: [* pair!]
    qcurv: [pair!]
    qcurve: [* pair!]
    vline: [decimal!]
    radial: none
    conic: none
    diamond: none
    linear: none
    diagonal: none
    cubic: none
    non-zero: none
    even-odd: none
    border: none
    nearest: none
    bilinear: none
    bicubic: none
    gaussian: none
    resample: none
    butt: none
    square: none
    rounded: none
    miter: none
    miter-bevel: none
    round: none
    bevel: none
    fixed: none
    closed: none
    opened: none
    normal: none
    repeat: none
    reflect: none
    large: none
    sweep: none
    vectorial: none
]
set-draw-keywords-in: funct [
    context [object!]
    size [pair!]
] [
    do bind [
        gob-size: min max size min-size max-size
        space: reduce [
            margin/1 + border-size/1 + padding/1
            margin/2 + border-size/2 + padding/2
        ]
        size: gob-size - space/1 - space/2
        margin-box/top-left: negate space/1
        margin-box/bottom-right: size + space/2
        margin-box/top-right: as-pair margin-box/bottom-right/x margin-box/top-left/y
        margin-box/bottom-left: as-pair margin-box/top-left/x margin-box/bottom-right/y
        margin-box/center: margin-box/bottom-right + margin-box/top-left * 0.5
        border-box/top-left: margin-box/top-left + margin/1
        border-box/bottom-right: margin-box/bottom-right - margin/2
        border-box/top-right: as-pair border-box/bottom-right/x border-box/top-left/y
        border-box/bottom-left: as-pair border-box/top-left/x border-box/bottom-right/y
        border-box/center: border-box/bottom-right + border-box/top-left * 0.5
        padding-box/top-left: border-box/top-left + border-size/1
        padding-box/bottom-right: border-box/bottom-right - border-size/2
        padding-box/top-right: as-pair padding-box/bottom-right/x padding-box/top-left/y
        padding-box/bottom-left: as-pair padding-box/top-left/x padding-box/bottom-right/y
        padding-box/center: padding-box/bottom-right + padding-box/top-left * 0.5
        viewport-box/top-left: 0x0
        viewport-box/bottom-right: size
        viewport-box/top-right: as-pair viewport-box/bottom-right/x viewport-box/top-left/y
        viewport-box/bottom-left: as-pair viewport-box/top-left/x viewport-box/bottom-right/y
        viewport-box/center: size * 0.5
    ] context
]
box-model: [
    translate (space/1)
    clip (max margin-box/top-left margin-box/top-left - gob/offset + any [all [gob/parent gob/parent/data/facets/space/1] 0x0]) (margin-box/bottom-right - (margin-box/bottom-right + gob/offset - any [all [gob/parent gob/parent/data/facets/viewport-box/bottom-right + gob/parent/data/facets/space/1] 0x0]))
    anti-alias off
    pen off (
        all [
            bg-color
            not select gob/data/facets 'material [
                fill-pen bg-color
                box border-box/top-left border-box/bottom-right
                fill-pen off
            ]
        ]
    ) (
        all [
            border-color [pen border-color]
        ]
    ) (
        all [
            border-size/1/y > 0 [
                line-cap (pick [square butt] border-size/1/y = 1)
                line-width (border-size/1/y)
                line (border-box/top-left - 1x0 + (0x1 * (to integer! border-size/1/y / 2))) (border-box/top-right + (0x1 * (to integer! border-size/1/y / 2)))
            ]
        ]
    ) (
        all [
            border-size/1/x > 0 [
                line-cap (pick [square butt] border-size/1/x = 1)
                line-width (border-size/1/x)
                line (border-box/top-left - 0x1 + (1x0 * (to integer! border-size/1/x / 2))) (border-box/bottom-left + (1x0 * (to integer! border-size/1/x / 2)))
            ]
        ]
    ) (
        all [
            border-size/2/y > 0 [
                line-cap (pick [square butt] border-size/2/y = 1)
                line-width (border-size/2/y)
                line (border-box/bottom-left - 1x0 - (0x1 * (to integer! border-size/2/y / 2 + 0.5))) (border-box/bottom-right - (0x1 * (to integer! border-size/2/y / 2 + 0.5)))
            ]
        ]
    ) (
        all [
            border-size/2/x > 0 [
                line-cap (pick [square butt] border-size/2/x = 1)
                line-width (border-size/2/x)
                line (border-box/top-right - 0x1 - (1x0 * (to integer! border-size/2/x / 2 + 0.5))) (border-box/bottom-right - (1x0 * (to integer! border-size/2/x / 2 + 0.5)))
            ]
        ]
    )
    line-width 1
    pen white
    fill-pen off
    anti-alias on
]
set-box-model: funct [
    face [object!]
] [
    if name: select face/facets 'box-model [
        face/facets: make copy/types select any [
            select face 'box-models
            guie/box-models
        ] name block! face/facets
    ]
]
draw-face: funct [
    "Given a face, generate its DRAW block."
    face [object!]
    /no-show "Do not queue it for refresh"
    /now "refresh the face immediately"
] [
    draw-buf: copy []
    unless empty? face/gob [
        foreach-face f face [draw-face/no-show f]
    ]
    if any [
        face/gob/color
        face/gob/text
        face/gob/effect
    ] [
        unless no-show [
            either now [
                show-now
            ] [
                show-later face
            ]
        ]
        exit
    ]
    if all [
        face/gob/1
        face/gob/1/data = face
    ] [
        face/gob/1/draw: to-draw compose/deep face/draw-text copy []
    ]
    style: select guie/styles face/style
    append draw-buf box-model
    usr-drw: any [select face 'draw select style 'draw]
    if word? d: get-facet face 'draw-mode [
        if block? d: select usr-drw to set-word! d [usr-drw: d]
    ]
    all [
        usr-drw
        append draw-buf usr-drw
    ]
    all [
        drw: do-actor face 'on-draw draw-buf
        draw-buf: drw
    ]
    if select face 'debug [
        draw-buf: append copy [pen red line-width 1 box 0x0 (margin-box/bottom-right - 1)] draw-buf
    ]
    if tb: get-facet face 'text-body [
        append draw-buf reduce [
            'text 0x0 to paren! [viewport-box/bottom-right - 1] make-text face tb
        ]
    ]
    if empty? draw-buf [exit]
    all [
        style/facets
        bind draw-buf style/facets
    ]
    bind draw-buf face/facets
    delect/all dialect-draw compose/deep draw-buf drw: copy []
    to-draw drw face/gob/draw: any [all [face/gob/draw clear face/gob/draw] copy []]
    unless no-show [
        show-later face
        if now [
            show-now
        ]
    ]
]
get-face: funct [
    "Get a variable from the face state"
    face [object! block! path!] "Face or block of faces to get"
    /field
    word [word! block! none!]
    /state "Get face state"
] [
    if block? face [
        out: make block! 10
        foreach fac face [
            append out get-face fac
        ]
        return out
    ]
    if path? face [
        face: to block! face
        word: copy next face
        face: get first face
    ]
    either state [
        state: make map! 10
        foreach field get-fields? face [
            state/:field: get-face/field face field
        ]
        state
    ] [
        do-actor face 'on-get any [word 'value]
    ]
]
set-face: func [
    {Set some facets in the given face, redraw the face.}
    face [object!]
    value
    /no-show "Do not redraw the face at this time."
    /field "Set only the specific facet."
    word [word! none!]
    /state "Set all key facets as in VALUE."
    {VALUE has to be a map having word keys in this case.}
] [
    either state [
        foreach word value [do-actor face 'on-set reduce [word value/:word no-show]]
    ] [
        do-actor face 'on-set reduce [any [word 'value] :value no-show]
    ]
    unless no-show [
        draw-face face
    ]
    if get-facet face 'relay [apply :do-face [face false none no-show]]
]
set-facet: func [
    {Set a named facet in face/facets. Creates it if needed.}
    face [object!]
    word [word!]
    value
] [
    append face/facets reduce [to-set-word word :value]
    :value
]
get-facet: funct [
    "Get a named facet(s) from the face or style."
    face [object!]
    field [word! block!] "A word or block of words (set-words allowed)."
] [
    either word? f: field body: [
        any [
            all [
                val: in face/facets f
                any [
                    val: get/any :val
                    true
                ]
            ]
            all [
                style: select guie/styles face/style
                val: in style/facets f
                val: get/any :val
            ]
        ]
        val
    ] [
        foreach word field [
            if any-word? :word [
                f: to word! word
                set :word do body
            ]
        ]
    ]
]
get-panel: funct [
    "Get values for named faces"
    panel [object!]
] [
    names: select panel 'names
    either names [
        out: copy []
        foreach face values-of panel/names [
            append/only out get-face face
        ]
        out
    ] [
        none
    ]
]
validators: []
validate-face: funct [
    {Sets face's validity as word and returns logic value.}
    face [object!] "Face to validate"
    /full "Return all informations, not just validity"
] [
    if get-facet face 'skip [
        validity: 'skipped
        return none
    ]
    value: get-face face
    validator: get-facet face 'validator
    valid?: either 2 = length? validator [
        res: collect [
            foreach v validator/2 [keep do bind select validators v 'value]
        ]
        do reduce [validator/1 res]
    ] [
        validator: select validators validator
        either validator [
            print ["validating value" mold value]
            do bind validator 'value
        ] [true]
    ]
    validity: either valid? ['valid] ['invalid]
    validity
]
make-face-validator: funct [
    "Add new face validator"
    blk
] [
    name: description: val: err: none
    parse blk [
        any [
            set name word!
            opt [set description string!]
            set val block!
            set err [word! | string!] (repend validators [name val err])
        ]
    ]
]
chars: charset [#"a" - #"z" #"A" - #"Z"]
integers: charset [#"0" - #"9"]
points: charset [#"." #","]
signs: charset [#"-" #"+"]
numbers: union integers union points signs
number: [opt signs any [integers | points]]
integer: [opt signs any integers]
make-face-validator [
    only-chars
    {The field may only contain characters a-z and A-Z, not numbers.} [all [series? value parse value [any chars]]]
    "contains other than alphabetic characters"
    not-empty
    {The field must contain a string and it may not be empty.} [all [string? value not empty? value]]
    "is empty"
    only-numbers
    {The field must contain only numbers from 0-9, +, -, comma and period.} [all [series? value not empty? value parse value number]]
    "contains other than numbers"
    only-integers
    "The field must contain only integers from 0-9." [all [series? value not empty? value parse value integer]]
    "contains other than integers"
    only-positive
    "The field must contain only positive numbers." [positive? value]
    "contains negative numbers"
    selected
    {The field must have a non-empty block or may not be none.} [any [all [any-block? value not empty? value] all [not any-block? value not none? value]]]
    "has no item selected"
    email
    "The field must have a valid email address." [
        parse value [
            end |
            some [chars | numbers] #"@" some [chars | integers] #"." some chars
        ]
    ]
    "is not an email address"
]
make-layout: funct [
    face [object!]
    layout-type [word!]
] [
    init-layout face layout-type
    bind-faces face
    if face/style = 'window [
        bind-targets face
    ]
    do-actor faces: faces? face 'on-init none
    foreach f select face 'trigger-faces [
        unless find f/facets/triggers 'visible-trigger [
            do-actor f 'on-init none
        ]
    ]
    do-triggers/no-recursive face 'load
]
init-layout: funct [
    {Initialize a layout face object. Init subfaces and set size.}
    layout [object!]
    layout-type [word!]
    /local d1 d2 w rule
] [
    unless block: select layout/options 'content [
        if all [
            style: select guie/styles layout/style
            block: select style 'content
            block: copy/deep block
        ] [
            parse block rule: [
                some [
                    w: get-word! (
                        w/1: get-facet layout to-word w/1
                        any [
                            all [
                                word? w/1
                                w/1: to lit-word! w/1
                            ]
                            all [
                                path? w/1
                                w/1: to lit-path! w/1
                            ]
                        ]
                    )
                    | and block! into rule
                    | skip
                ]
            ]
        ]
    ]
    faces: apply :parse-layout [block get-facet layout 'names]
    panel?: layout-type = 'panel
    trigs: none
    i: 0
    remove-each face faces [
        hidden?: true
        either object? face [
            hidden?: if t: get-facet face 'triggers [
                unless trigs [trigs: make block! 2]
                append trigs face
                not find t 'visible-trigger
            ]
            all [
                not hidden?
                ++ i
                panel?
                append layout/gob face/gob
            ]
            hidden?
        ] [
            switch/default face [
                divider resizer [
                    unless select layout/facets 'dividers [set-facet layout 'dividers copy []]
                    append layout/facets/dividers compose/deep [(i) [type (face)]]
                    true
                ]
            ] [
                false
            ]
        ]
    ]
    extend layout 'trigger-faces trigs
    if pair? select layout/options 'init-hint [
        unless layout/facets/min-hint [layout/facets/min-hint: 0x0]
        unless layout/facets/max-hint [layout/facets/max-hint: guie/max-pair]
    ]
    unless layout/facets/min-hint [layout/facets/min-hint: 'auto]
    unless layout/facets/max-hint [layout/facets/max-hint: 'auto]
    append layout/facets reduce/no-set switch layout-type [
        panel [[
                break-after: any [
                    select layout/facets 'break-after
                    0
                ]
                pane-align: any [
                    select layout/facets 'pane-align
                    'left
                ]
                pane-valign: any [
                    select layout/facets 'pane-valign
                    'top
                ]
                row-max: any [
                    select layout/facets 'row-max
                    'max
                ]
                column-max: any [
                    select layout/facets 'column-max
                    'max
                ]
                row-min: any [
                    select layout/facets 'row-min
                    'max
                ]
                column-min: any [
                    select layout/facets 'column-min
                    'max
                ]
                row-init: any [
                    select layout/facets 'row-init
                    'max
                ]
                column-init: any [
                    select layout/facets 'column-init
                    'max
                ]
                layout-mode: any [
                    select layout/facets 'layout-mode
                    'horizontal
                ]
                spacing: any [
                    select layout/facets 'spacing
                    0x0
                ]
                intern: make object! [
                    update?: true
                    init-pane: none
                    heights: copy []
                    init-heights: copy []
                    min-heights: copy []
                    max-heights: copy []
                    widths: copy []
                    init-widths: copy []
                    min-widths: copy []
                    max-widths: copy []
                    row-minification-index: copy []
                    row-magnification-index: copy []
                    column-minification-index: copy []
                    column-magnification-index: copy []
                    row-init-ratio: none
                    column-init-ratio: none
                ]
            ]]
        group [[
                pane-align: any [
                    select layout/facets 'pane-align
                    'left
                ]
                pane-valign: any [
                    select layout/facets 'pane-valign
                    'top
                ]
                layout-mode: any [
                    select layout/facets 'layout-mode
                    'horizontal
                ]
                line-max: any [
                    select layout/facets 'line-max
                    'max
                ]
                line-min: any [
                    select layout/facets 'line-min
                    'max
                ]
                line-init: any [
                    select layout/facets 'line-init
                    'max
                ]
                spacing: any [
                    select layout/facets 'spacing
                    0x0
                ]
                intern: make object! [
                    update?: true
                    init-pane: none
                    lines: copy []
                    minification-index: copy []
                    magnification-index: copy []
                    line-init-ratio: none
                ]
            ]]
    ]
    unless panel? [
        insert-into-group layout/gob 1 + length? layout/gob faces
    ]
    layout
]
set-layout: funct [
    {Set layout input face values from an object of values.}
    layout [object!]
    values [object!]
] [
    faces: faces? layout
    foreach face faces [
        either tag-face? face 'layout [
            set-layout face values
        ] [
            all [
                in face 'name
                tag-face? face [info edit state]
                val: get in values face/name
                set-face face val
            ]
        ]
    ]
]
get-layout: funct [
    "Get layout input face values as an object."
    layout [object!]
] [
    out: make object! []
    foreach face any [f: faces? layout to-block layout] [
        if tag-face? face [info edit state] [
            if select face 'name [
                repend out [to-set-word face/name get-face face]
            ]
        ]
        if f [
            out: make out get-layout face
        ]
    ]
    foreach face select layout 'trigger-faces [
        if tag-face? face [info edit state] [
            if in face 'name [
                extend out face/name get-face face
            ]
        ]
    ]
    out
]
clear-layout: func [
    "Clear layout input face values."
    layout [object!]
] [
    foreach face faces? layout [
        either tag-face? face 'layout [
            clear-layout face
        ] [
            all [
                tag-face? face [info edit state]
                do-actor face 'on-clear none
            ]
        ]
    ]
]
get-parent-layout: funct [
    {Get layout input faces for the contextual parent layout.}
    face
] [
    while [not select face 'names] [
        unless f: parent-face? face [break]
        face: f
    ]
    get-layout face
]
get-layout-var: funct [
    {Get the value of a top level layout/names local variable.}
    layout [gob!] "The window gob"
    name [word!]
] [
    all [
        p: layout/data
        p: first faces? p
        p: p/names
        p/:name
    ]
]
set-content: funct [
    layout [object!]
    content [block! object!]
    /pos
    index [integer! object! gob!]
    /no-show
] [
    apply :clear-content [layout index index true]
    apply :insert-content [
        layout content true 1 + length? layout/gob no-show
    ]
]
clear-content: funct [
    layout [object!]
    /pos
    index [integer! object! gob!]
    /no-show
] [
    index: any [index 1]
    if object? index [index: index/gob]
    index: either gob? index [
        either index: find layout/gob index [index? index] [
            1 + length? layout/gob
        ]
    ] [
        max index 1
    ]
    either index > len: length? layout/gob [layout] [
        do-actor layout 'on-content reduce ['clear no-show index len]
    ]
]
insert-content: funct [
    layout [object!]
    content [block! object!]
    /pos
    index [integer! object! gob!] "pane index, face, or gob"
    /no-show
] [
    index: any [index 1]
    if object? index [index: index/gob]
    index: case [
        gob? index [
            either index: find layout/gob index [index? index] [
                1 + length? layout/gob
            ]
        ]
        integer? index [min max index 1 1 + length? layout/gob]
    ]
    content: either block? content [
        apply :parse-layout [
            content all [in layout/facets 'names layout/facets/names]
        ]
    ] [
        reduce [content]
    ]
    either empty? content [layout] [
        do-actor layout 'on-content reduce ['insert no-show content index]
    ]
]
append-content: funct [
    layout [object!]
    content [block! object!]
    /no-show
] [
    apply :insert-content [
        layout content true 1 + length? layout/gob no-show
    ]
]
change-content: funct [
    layout [object!]
    content [block! object!]
    /pos
    index [integer! object! gob!]
    /part
    range [integer!]
    /no-show
] []
remove-content: func [
    layout [object!]
    /pos
    index [integer! object! gob!]
    /part
    range [integer!]
    /no-show
] [
    index: any [index 1]
    if object? index [index: index/gob]
    index: case [
        gob? index [
            either index: find layout/gob index [index? index] [
                1 + length? layout/gob
            ]
        ]
        integer? index [min max index 1 1 + length? layout/gob]
    ]
    range: any [range 1]
    range: max range 1 - index
    if range < 0 [
        index: index + range
        range: negate range
    ]
    if index > length? layout/gob [return layout]
    range: min range 1 - index + length? layout/gob
    if range = 0 [return layout]
    do-actor layout 'on-content reduce ['remove no-show index range]
]
make object! [
    line-proto: make object! [
        start:
        length:
        net-length:
        init-size:
        min-size:
        max-size:
        offset:
        size:
        minification-index:
        magnification-index:
        none
        align: 'left
        valign: 'top
        init-ratio: none
    ]
    max-coord: guie/max-coord
    add-max: func [a b] [
        either any [max-coord = a max-coord = b] [max-coord] [a + b]
    ]
    round-to: func [
        value [number!] "the value to round"
        scale [number!] "the scale to round to, assumed to be positive"
        /local r
    ] [
        r: value // scale
        either negative? r [
            if scale + r < negate r [r: scale + r]
        ] [
            if scale - r < r [r: r - scale]
        ]
        value - r
    ]
    group-modes: make object! [
        horizontal: [
            x
            y
            valign
            align
            pane-valign
            top
            middle
            bottom
            left
            center
            right
        ]
        vertical: [
            y
            x
            align
            valign
            pane-align
            left
            center
            right
            top
            middle
            bottom
        ]
    ]
    set 'update-group funct [
        {
^-^-^-given a group update:
^-^-^-^-line dimensions
^-^-^-^-pane dimensions
^-^-^-^-minification and magnification indices
^-^-}
        group [gob!]
    ] [
        do bind bind/copy [
            unless update? [exit]
            update?: false
            set [l: t:] group-modes/:layout-mode
            init-pane:
            min-pane:
            max-pane: 0x0
            net-lines: 0
            sort-block: copy []
            repeat i length? lines [
                line: lines/:i
                line/align: case [
                    word? pane-align [pane-align]
                    all [block? pane-align pick pane-align i] [
                        pick pane-align i
                    ]
                    true [line/align]
                ]
                line/valign: case [
                    word? pane-valign [pane-valign]
                    all [block? pane-valign pick pane-valign i] [
                        pick pane-valign i
                    ]
                    true [line/valign]
                ]
                this-line-min: case [
                    not block? line-min [line-min]
                    pick line-min i [pick line-min i]
                    true ['max]
                ]
                this-line-init: case [
                    not block? line-init [line-init]
                    pick line-init i [pick line-init i]
                    true ['max]
                ]
                this-line-max: case [
                    not block? line-max [line-max]
                    pick line-max i [pick line-max i]
                    true ['max]
                ]
                line/init-size:
                line/min-size:
                line/max-size: 0x0
                if number? this-line-min [line/min-size/:t: this-line-min]
                if number? this-line-init [line/init-size/:t: this-line-init]
                if number? this-line-max [line/max-size/:t: this-line-max]
                line-start: at group line/start
                line/net-length: 0
                repeat i line/length [
                    sg: pick line-start i
                    face: sg/data
                    case [
                        face/facets/resizes [
                            do-actor face 'on-update none
                            line/net-length: line/net-length + 1
                            line/init-size/:l: line/init-size/:l
                            + face/facets/init-size/:l
                            switch this-line-init [
                                max [
                                    line/init-size/:t: max line/init-size/:t
                                    face/facets/init-size/:t
                                ]
                                min [
                                    line/init-size/:t: min line/init-size/:t
                                    face/facets/init-size/:t
                                ]
                            ]
                            line/min-size/:l: line/min-size/:l
                            + face/facets/min-size/:l
                            switch this-line-min [
                                max [
                                    line/min-size/:t: max line/min-size/:t
                                    face/facets/min-size/:t
                                ]
                                min [
                                    line/min-size/:t: min line/min-size/:t
                                    face/facets/min-size/:t
                                ]
                                init [
                                    line/min-size/:t: line/init-size/:t
                                ]
                            ]
                            line/max-size/:l: add-max line/max-size/:l
                            face/facets/max-size/:l
                            switch this-line-max [
                                max [
                                    line/max-size/:t: max line/max-size/:t
                                    face/facets/max-size/:t
                                ]
                                min [
                                    line/max-size/:t: min line/max-size/:t
                                    face/facets/max-size/:t
                                ]
                                init [
                                    line/max-size/:t: line/init-size/:t
                                ]
                            ]
                        ]
                        face/gob/size <> 0x-1 [
                            either in face/facets 'intern [
                                if face/facets/intern/update? [
                                    do-actor face 'on-resize face/facets/gob-size
                                ]
                            ] [
                                do-actor face 'on-update none
                            ]
                        ]
                    ]
                ]
                if line/min-size/:l > line/max-size/:l [
                    value: line/min-size/:l
                    line/min-size/:l: line/max-size/:l
                    line/max-size/:l: value
                ]
                if line/min-size/:t > line/max-size/:t [
                    value: line/min-size/:t
                    line/min-size/:t: line/max-size/:t
                    line/max-size/:t: value
                ]
                line-spacing: spacing/:l * max 0 line/net-length - 1
                if line/net-length > 0 [net-lines: net-lines + 1]
                init-pane/:l: max
                init-pane/:l
                line-spacing + line/init-size/:l
                init-pane/:t: init-pane/:t + line/init-size/:t
                min-pane/:l: max min-pane/:l line-spacing + line/min-size/:l
                min-pane/:t: min-pane/:t + line/min-size/:t
                max-pane/:l: max max-pane/:l add-max line-spacing
                line/max-size/:l
                max-pane/:t: add-max max-pane/:t line/max-size/:t
                line/minification-index: make block! line/net-length
                clear sort-block
                repeat i line/length [
                    sg: pick line-start i
                    face: sg/data
                    if face/facets/resizes [
                        append append sort-block
                        either face/facets/init-size/:l = 0 [max-coord] [
                            face/facets/min-size/:l
                            / face/facets/init-size/:l
                        ] i
                    ]
                ]
                sort/skip/reverse sort-block 2
                foreach [value i] sort-block [append line/minification-index i]
                line/magnification-index: make block! line/net-length
                clear sort-block
                repeat i line/length [
                    sg: pick line-start i
                    face: sg/data
                    if face/facets/resizes [
                        append append sort-block
                        either face/facets/init-size/:l = 0 [max-coord] [
                            face/facets/max-size/:l
                            / face/facets/init-size/:l
                        ] i
                    ]
                ]
                sort/skip sort-block 2
                foreach [value i] sort-block [append line/magnification-index i]
            ]
            box-space: margin/1 + border-size/1 + padding/1 + margin/2
            + border-size/2 + padding/2
            box-space/:t: box-space/:t + (spacing/:t * max 0 net-lines - 1)
            either word? init-hint [init-hint-x: init-hint-y: init-hint] [
                init-hint-x: init-hint/1
                init-hint-y: init-hint/2
            ]
            init-size: as-pair
            case [
                init-hint-x = 'auto [init-pane/x + box-space/x]
                any [
                    init-hint-x = 'init
                    init-hint-x = 'keep
                ] [init-size/x]
                true [init-hint/1]
            ]
            case [
                init-hint-y = 'auto [init-pane/y + box-space/y]
                any [
                    init-hint-y = 'init
                    init-hint-y = 'keep
                ] [init-size/y]
                true [init-hint/2]
            ]
            either word? min-hint [min-hint-x: min-hint-y: min-hint] [
                min-hint-x: min-hint/1
                min-hint-y: min-hint/2
            ]
            min-size: as-pair
            case [
                min-hint-x = 'auto [min-pane/x + box-space/x]
                min-hint-x = 'init [init-size/x]
                min-hint-x = 'keep [min-size/x]
                true [min-hint-x]
            ]
            case [
                min-hint-y = 'auto [min-pane/y + box-space/y]
                min-hint-y = 'init [init-size/y]
                min-hint-y = 'keep [min-size/y]
                true [min-hint-y]
            ]
            either word? max-hint [max-hint-x: max-hint-y: max-hint] [
                max-hint-x: max-hint/1
                max-hint-y: max-hint/2
            ]
            max-size: as-pair
            case [
                max-hint-x = 'auto [
                    either max-pane/x = max-coord [max-coord] [
                        max-pane/x + box-space/x
                    ]
                ]
                max-hint-x = 'init [init-size/x]
                max-hint-x = 'keep [max-size/x]
                true [max-hint-x]
            ]
            case [
                max-hint-y = 'auto [
                    either max-pane/y = max-coord [max-coord] [
                        max-pane/y + box-space/y
                    ]
                ]
                max-hint-y = 'init [init-size/y]
                max-hint-y = 'keep [max-size/y]
                true [max-hint-y]
            ]
            minification-index: make block! net-lines
            clear sort-block
            repeat i length? lines [
                linei: pick lines i
                unless linei/net-length = 0 [
                    append append sort-block either linei/init-size/:t = 0 [
                        max-coord
                    ] [
                        linei/min-size/:t / linei/init-size/:t
                    ] i
                ]
            ]
            sort/skip/reverse sort-block 2
            foreach [value i] sort-block [append minification-index i]
            magnification-index: make block! net-lines
            clear sort-block
            repeat i length? lines [
                linei: pick lines i
                unless linei/net-length = 0 [
                    append append sort-block either linei/init-size/:t = 0 [
                        max-coord
                    ] [
                        linei/max-size/:t / linei/init-size/:t
                    ] i
                ]
            ]
            sort/skip sort-block 2
            foreach [value i] sort-block [append magnification-index i]
        ] group/data/facets group/data/facets/intern
    ]
    set 'update-panel funct [
        {
^-^-^-given a layout of type panel update:
^-^-^-^-row heights
^-^-^-^-column widths
^-^-^-^-pane dimensions
^-^-^-^-minification and magnification indices
^-^-}
        panel [gob!]
    ] [
        do bind bind/copy [
            unless update? [exit]
            update?: false
            net-panel: 0
            repeat i length? panel [
                sg: pick panel i
                face: sg/data
                case [
                    face/facets/resizes [
                        do-actor face 'on-update none
                        net-panel: net-panel + 1
                    ]
                    face/gob/size <> 0x-1 [
                        either in face/facets 'intern [
                            if face/facets/intern/update? [
                                do-actor face 'on-resize face/facets/gob-size
                            ]
                        ] [
                            do-actor face 'on-update none
                        ]
                    ]
                ]
            ]
            line-length: either break-after = 0 [net-panel] [break-after]
            either line-length = 0 [lines: 0] [
                last-line: net-panel // line-length
                lines: net-panel - last-line / line-length
                if last-line <> 0 [lines: lines + 1]
            ]
            either layout-mode = 'horizontal [
                rows: lines
                columns: line-length
            ] [
                rows: line-length
                columns: lines
            ]
            foreach [length block hint] reduce [
                rows init-heights row-init
                rows min-heights row-min
                rows max-heights row-max
                columns init-widths column-init
                columns min-widths column-min
                columns max-widths column-max
            ] [
                either length > length? block [
                    append/dup block 0 length - length? block
                ] [
                    clear at block length + 1
                ]
                repeat i length [
                    this-hint: any [
                        all [not block? hint hint]
                        all [
                            block? hint
                            pick hint i
                        ]
                        'max
                    ]
                    case [
                        this-hint = 'max [block/:i: 0]
                        number? this-hint [block/:i: this-hint]
                        this-hint = 'min [block/:i: max-coord]
                    ]
                ]
            ]
            row-number: 1
            column-number: 1
            repeat i length? panel [
                sg: pick panel i
                face: sg/data
                if face/facets/resizes [
                    row-min-hint: any [
                        all [not block? row-min row-min]
                        all [
                            block? row-min
                            pick row-min row-number
                        ]
                        'max
                    ]
                    row-init-hint: any [
                        all [not block? row-init row-init]
                        all [
                            block? row-init
                            pick row-init row-number
                        ]
                        'max
                    ]
                    row-max-hint: any [
                        all [not block? row-max row-max]
                        all [
                            block? row-max
                            pick row-max row-number
                        ]
                        'max
                    ]
                    column-min-hint: any [
                        all [not block? column-min column-min]
                        all [
                            block? column-min
                            pick column-min column-number
                        ]
                        'max
                    ]
                    column-init-hint: any [
                        all [not block? column-init column-init]
                        all [
                            block? column-init
                            pick column-init column-number
                        ]
                        'max
                    ]
                    column-max-hint: any [
                        all [not block? column-max column-max]
                        all [
                            block? column-max
                            pick column-max column-number
                        ]
                        'max
                    ]
                    case [
                        row-init-hint = 'max [
                            init-heights/:row-number: max
                            init-heights/:row-number
                            face/facets/init-size/y
                        ]
                        row-init-hint = 'min [
                            init-heights/:row-number: min
                            init-heights/:row-number
                            face/facets/init-size/y
                        ]
                    ]
                    case [
                        row-min-hint = 'max [
                            min-heights/:row-number: max
                            min-heights/:row-number
                            face/facets/min-size/y
                        ]
                        row-min-hint = 'min [
                            min-heights/:row-number: min
                            min-heights/:row-number
                            face/facets/min-size/y
                        ]
                    ]
                    case [
                        row-max-hint = 'max [
                            max-heights/:row-number: max
                            max-heights/:row-number
                            face/facets/max-size/y
                        ]
                        row-max-hint = 'min [
                            max-heights/:row-number: min
                            max-heights/:row-number
                            face/facets/max-size/y
                        ]
                    ]
                    case [
                        column-init-hint = 'max [
                            init-widths/:column-number: max
                            init-widths/:column-number
                            face/facets/init-size/x
                        ]
                        column-init-hint = 'min [
                            init-widths/:column-number: min
                            init-widths/:row-number
                            face/facets/init-size/x
                        ]
                    ]
                    case [
                        column-min-hint = 'max [
                            min-widths/:column-number: max
                            min-widths/:column-number
                            face/facets/min-size/x
                        ]
                        column-min-hint = 'min [
                            min-widths/:column-number: min
                            min-widths/:column-number
                            face/facets/min-size/x
                        ]
                    ]
                    case [
                        column-max-hint = 'max [
                            max-widths/:column-number: max
                            max-widths/:column-number
                            face/facets/max-size/x
                        ]
                        column-max-hint = 'min [
                            max-widths/:column-number: min
                            max-widths/:column-number
                            face/facets/max-size/x
                        ]
                    ]
                    either layout-mode = 'horizontal [
                        column-number: column-number + 1
                        if column-number > columns [
                            column-number: 1
                            row-number: row-number + 1
                        ]
                    ] [
                        row-number: row-number + 1
                        if row-number > rows [
                            row-number: 1
                            column-number: column-number + 1
                        ]
                    ]
                ]
            ]
            repeat i rows [
                if any [
                    row-min = 'init
                    all [block? row-min 'init = pick row-min i]
                ] [min-heights/:i: init-heights/:i]
                if any [
                    row-max = 'init
                    all [block? row-max 'init = pick row-max i]
                ] [max-heights/:i: init-heights/:i]
            ]
            repeat i columns [
                if any [
                    column-min = 'init
                    all [block? column-min 'init = pick column-min i]
                ] [min-widths/:i: init-widths/:i]
                if any [
                    column-max = 'init
                    all [block? column-max 'init = pick column-max i]
                ] [max-widths/:i: init-widths/:i]
            ]
            repeat i rows [
                if min-heights/:i > max-heights/:i [
                    value: min-heights/:i
                    min-heights/:i: max-heights/:i
                    max-heights/:i: value
                ]
            ]
            repeat i columns [
                if min-widths/:i > max-widths/:i [
                    value: min-widths/:i
                    min-widths/:i: max-widths/:i
                    max-widths/:i: value
                ]
            ]
            init-pane:
            min-pane:
            max-pane: 0x0
            repeat i rows [
                init-pane/y: init-pane/y + init-heights/:i
                min-pane/y: min-pane/y + min-heights/:i
                max-pane/y: either any [
                    max-pane/y = max-coord
                    max-heights/:i = max-coord
                ] [max-coord] [max-pane/y + max-heights/:i]
            ]
            repeat i columns [
                init-pane/x: init-pane/x + init-widths/:i
                min-pane/x: min-pane/x + min-widths/:i
                max-pane/x: either any [
                    max-pane/x = max-coord
                    max-widths/:i = max-coord
                ] [max-coord] [max-pane/x + max-widths/:i]
            ]
            box-space: margin/1 + border-size/1 + padding/1 + margin/2
            + border-size/2 + padding/2 + (
                spacing * max 0x0 (as-pair columns rows) - 1x1
            )
            either word? init-hint [init-hint-x: init-hint-y: init-hint] [
                init-hint-x: init-hint/1
                init-hint-y: init-hint/2
            ]
            init-size: as-pair
            case [
                init-hint-x = 'auto [init-pane/x + box-space/x]
                any [
                    init-hint-x = 'init
                    init-hint-x = 'keep
                ] [init-size/x]
                true [init-hint/1]
            ]
            case [
                init-hint-y = 'auto [init-pane/y + box-space/y]
                any [
                    init-hint-y = 'init
                    init-hint-y = 'keep
                ] [init-size/y]
                true [init-hint/2]
            ]
            either word? min-hint [min-hint-x: min-hint-y: min-hint] [
                min-hint-x: min-hint/1
                min-hint-y: min-hint/2
            ]
            min-size: as-pair
            case [
                min-hint-x = 'auto [min-pane/x + box-space/x]
                min-hint-x = 'init [init-size/x]
                min-hint-x = 'keep [min-size/x]
                true [min-hint-x]
            ]
            case [
                min-hint-y = 'auto [min-pane/y + box-space/y]
                min-hint-y = 'init [init-size/y]
                min-hint-y = 'keep [min-size/y]
                true [min-hint-y]
            ]
            either word? max-hint [max-hint-x: max-hint-y: max-hint] [
                max-hint-x: max-hint/1
                max-hint-y: max-hint/2
            ]
            max-size: as-pair
            case [
                max-hint-x = 'auto [
                    either max-pane/x = max-coord [max-coord] [
                        max-pane/x + box-space/x
                    ]
                ]
                max-hint-x = 'init [init-size/x]
                max-hint-x = 'keep [max-size/x]
                true [max-hint-x]
            ]
            case [
                max-hint-y = 'auto [
                    either max-pane/y = max-coord [max-coord] [
                        max-pane/y + box-space/y
                    ]
                ]
                max-hint-y = 'init [init-size/y]
                max-hint-y = 'keep [max-size/y]
                true [max-hint-y]
            ]
            row-minification-index: make block! rows
            sort-block: make block! 2 * max rows columns
            repeat row-number rows [
                append append sort-block either init-heights/:row-number = 0 [
                    max-coord
                ] [
                    min-heights/:row-number / init-heights/:row-number
                ] row-number
            ]
            sort/skip/reverse sort-block 2
            foreach [value row-number] sort-block [
                append row-minification-index row-number
            ]
            row-magnification-index: make block! rows
            clear sort-block
            repeat row-number rows [
                append append sort-block either init-heights/:row-number = 0 [
                    max-coord
                ] [
                    max-heights/:row-number / init-heights/:row-number
                ] row-number
            ]
            sort/skip sort-block 2
            foreach [value row-number] sort-block [
                append row-magnification-index row-number
            ]
            column-minification-index: make block! columns
            clear sort-block
            repeat column-number columns [
                append append sort-block either init-widths/:column-number = 0 [
                    max-coord
                ] [
                    min-widths/:column-number / init-widths/:column-number
                ] column-number
            ]
            sort/skip/reverse sort-block 2
            foreach [value column-number] sort-block [
                append column-minification-index column-number
            ]
            column-magnification-index: make block! columns
            clear sort-block
            repeat column-number columns [
                append append sort-block either init-widths/:column-number = 0 [
                    max-coord
                ] [
                    max-widths/:column-number / init-widths/:column-number
                ] column-number
            ]
            sort/skip sort-block 2
            foreach [value column-number] sort-block [
                append column-magnification-index column-number
            ]
        ] panel/data/facets panel/data/facets/intern
    ]
    line?: funct [
        "compute the line number of a group position"
        group [gob!]
        index [integer!]
    ] [
        lines: group/data/facets/intern/lines
        b: length? lines
        case [
            lines/1/length >= index [1]
            lines/:b/start <= index [b]
            true [
                a: 1
                while [a + 1 < b] [
                    m: shift a + b -1
                    line: lines/:m
                    case [
                        line/start > index [b: m]
                        line/start + line/length <= index [a: m]
                        true [a: b: m]
                    ]
                ]
                a
            ]
        ]
    ]
    set 'remove-from-group funct [
        "remove subgob(s) from a group"
        group [gob!]
        index [integer!]
        length [integer!]
    ] [
        lines: group/data/facets/intern/lines
        remove/part at group index length
        line-no: line? group index
        line: lines/:line-no
        last-index: index + length - 1
        either line/start + line/length > last-index [
            line/length: line/length - length
            either line/length = 0 [remove at lines line-no] [
                line-no: line-no + 1
            ]
        ] [
            if index > line/start [
                line/length: index - line/start
                line-no: line-no + 1
            ]
            last-line-no: line? group last-index
            line: lines/:last-line-no
            line/length: line/start + line/length - 1 - last-index
            either line/length = 0 [
                last-line-no: last-line-no + 1
            ] [
                line/start: last-index - length
            ]
            remove/part at lines line-no last-line-no - line-no
            line-no: last-line-no
        ]
        foreach line at lines line-no [line/start: line/start - length]
    ]
    set 'insert-into-group funct [
        "insert faces(s) into a group"
        group [gob!]
        index [integer!]
        face [word! object! block!] "RETURN signals line break"
    ] [
        lines: group/data/facets/intern/lines
        if empty? lines [
            append lines make line-proto [
                start: 1
                length: 0
            ]
        ]
        line-no: line? group index
        lines: at lines line-no
        line: first lines
        lines: next lines
        length: 0
        trigs: none
        either block? face [
            faces: face
            remove-each f faces [
                face: f
                do process-face
            ]
        ] process-face: [
            either object? face [
                if t: select face/facets 'triggers [
                    unless trigs [
                        trigs: make block! 2
                    ]
                    append trigs face
                ]
                not if any [none? t find t 'visible-trigger] [
                    insert at group index face/gob
                    line/length: line/length + 1
                    length: length + 1
                    index: index + 1
                ]
            ] [
                new-line: make line-proto [
                    start: index
                    length: 0
                ]
                lines: insert lines new-line
                line/length: index - line/start
                line: new-line
            ]
        ]
        foreach line lines [line/start: line/start + length]
        trigs
    ]
    set 'change-line-alignment funct [
        "changes alignments of lines in a group"
        group [gob!]
        align [word! block!]
        valign [word! block!]
    ] [
        lines: group/data/facets/intern
        either word? align [
            foreach line lines [line/align: align]
        ] [
            n: min length? align length? lines
            repeat i n [
                line: lines/:i
                line/align: align/:i
            ]
        ]
        either word? valign [
            foreach line lines [line/valign: valign]
        ] [
            n: min length? valign length? lines
            repeat i n [
                line: lines/:i
                line/valign: valign/:i
            ]
        ]
    ]
    set 'resize-group funct [
        "resize a group"
        group [gob!]
    ] [
        do bind bind/copy [
            size: viewport-box/bottom-right
            set [
                l: t:
                talign: lalign:
                pane-talign:
                s-talign: m-talign: e-talign:
                s-lalign: m-lalign: e-lalign:
            ] group-modes/:layout-mode
            phys-pixel: 1x1 / gui-metric 'log-size
            phys-pixel-l: phys-pixel/:l
            phys-pixel-t: phys-pixel/:t
            source: init-pane/:t
            total: target: size/:t
            - (spacing/:t * max 0 (length? minification-index) - 1)
            foreach line lines [line/size: none]
            min-index: minification-index
            max-index: magnification-index
            while [
                while [
                    all [
                        min-i: first min-index
                        lines/:min-i/size
                    ]
                ] [min-index: next min-index]
                min-i
            ] [
                while [
                    all [
                        max-i: first max-index
                        lines/:max-i/size
                    ]
                ] [max-index: next max-index]
                ratio: either zero? source [1.0] [target / source]
                min-ratio: either zero? lines/:min-i/init-size/:t [max-coord] [
                    lines/:min-i/min-size/:t / lines/:min-i/init-size/:t
                ]
                max-ratio: either zero? lines/:max-i/init-size/:t [max-coord] [
                    lines/:max-i/max-size/:t / lines/:max-i/init-size/:t
                ]
                ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
                    i: min-i
                    max ratio min-ratio
                ] [
                    i: max-i
                    min ratio max-ratio
                ]
                lines/:i/size: round-to ratio * lines/:i/init-size/:t
                phys-pixel-t
                source: source - lines/:i/init-size/:t
                target: target - lines/:i/size
            ]
            line-init-ratio: ratio
            offset: switch get bind pane-talign 'pane-align reduce [
                s-talign [space/1/:t]
                m-talign [
                    round-to space/1/:t + group/size/:t - space/2/:t
                    - (spacing/:t * max 0 (length? minification-index) - 1)
                    - total + target / 2 phys-pixel-t
                ]
                e-talign [
                    group/size/:t - space/2/:t - (
                        spacing/:t * max 0 (length? minification-index) - 1
                    ) - total + target
                ]
            ]
            foreach line lines [
                unless line/net-length = 0 [
                    line/offset: offset
                    offset: offset + line/size + spacing/:t
                ]
            ]
            foreach line lines [
                unless line/net-length = 0 [
                    source: line/init-size/:l
                    total: target: size/:l - (
                        spacing/:l * max 0 line/net-length - 1
                    )
                    line-start: at group line/start
                    repeat i line/length [
                        sg: pick line-start i
                        face: sg/data
                        if face/facets/resizes [face/facets/gob-size: none]
                    ]
                    min-index: line/minification-index
                    max-index: line/magnification-index
                    while [
                        while [
                            all [
                                min-i: first min-index
                                sg: pick line-start min-i
                                min-face: sg/data
                                min-face/facets/gob-size
                            ]
                        ] [min-index: next min-index]
                        min-i
                    ] [
                        while [
                            all [
                                max-i: first max-index
                                sg: pick line-start max-i
                                max-face: sg/data
                                max-face/facets/gob-size
                            ]
                        ] [max-index: next max-index]
                        ratio: either zero? source [1.0] [target / source]
                        min-ratio: either zero? min-face/facets/init-size/:l [
                            max-coord
                        ] [
                            min-face/facets/min-size/:l / min-face/facets/init-size/:l
                        ]
                        max-ratio: either zero? max-face/facets/init-size/:l [
                            max-coord
                        ] [
                            max-face/facets/max-size/:l / max-face/facets/init-size/:l
                        ]
                        ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
                            i: min-i
                            face: min-face
                            max ratio min-ratio
                        ] [
                            i: max-i
                            face: max-face
                            min ratio max-ratio
                        ]
                        face/facets/gob-size: 0x0
                        face/facets/gob-size/:l:
                        round-to ratio * face/facets/init-size/:l
                        phys-pixel-l
                        face/facets/gob-size/:t: line/size
                        do-actor face 'on-resize face/facets/gob-size
                        source: source - face/facets/init-size/:l
                        target: target - face/facets/gob-size/:l
                    ]
                    line/init-ratio: ratio
                    offset: switch line/:lalign reduce [
                        s-lalign [space/1/:l]
                        m-lalign [
                            round-to space/1/:l + gob-size/:l - space/2/:l
                            - (spacing/:l * max 0 line/length - 1) - total
                            + target / 2 phys-pixel-l
                        ]
                        e-lalign [
                            gob-size/:l - space/2/:l - (
                                spacing/:l * max 0 line/length - 1
                            ) - total + target
                        ]
                    ]
                    repeat i line/length [
                        sg: pick line-start i
                        face: sg/data
                        sg/offset/:l: offset
                        sg/offset/:t: line/offset + switch face/facets/:talign reduce [
                            s-talign [0]
                            m-talign [
                                round-to line/size
                                - face/facets/gob-size/:t / 2
                                phys-pixel-t
                            ]
                            e-talign [line/size - face/facets/gob-size/:t]
                        ]
                        offset: offset + face/facets/gob-size/:l + spacing/:l
                    ]
                ]
            ]
        ] group/data/facets group/data/facets/intern
    ]
    set 'resize-panel funct [
        "resize a layout of type panel"
        panel [gob!]
    ] [
        do bind bind/copy [
            size: viewport-box/bottom-right
            rows: length? row-minification-index
            columns: length? column-minification-index
            phys-pixel: 1x1 / gui-metric 'log-size
            heights: head insert/dup copy [] none rows
            row-offsets: head insert/dup copy [] none rows
            source: init-pane/y
            total: target: size/y - (spacing/y * max 0 rows - 1)
            min-index: row-minification-index
            max-index: row-magnification-index
            while [
                while [
                    all [
                        min-i: first min-index
                        heights/:min-i
                    ]
                ] [min-index: next min-index]
                min-i
            ] [
                while [
                    all [
                        max-i: first max-index
                        heights/:max-i
                    ]
                ] [max-index: next max-index]
                ratio: either zero? source [1.0] [target / source]
                min-ratio: either zero? init-heights/:min-i [max-coord] [
                    min-heights/:min-i / init-heights/:min-i
                ]
                max-ratio: either zero? init-heights/:max-i [max-coord] [
                    max-heights/:max-i / init-heights/:max-i
                ]
                ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
                    i: min-i
                    max ratio min-ratio
                ] [
                    i: max-i
                    min ratio max-ratio
                ]
                heights/:i: round-to ratio * init-heights/:i phys-pixel/y
                source: source - init-heights/:i
                target: target - heights/:i
            ]
            offset: switch pane-valign [
                top [space/1/y]
                middle [
                    round-to space/1/y + gob-size/y - space/2/y
                    - (spacing/y * max 0 rows - 1) - total + target / 2
                    phys-pixel/y
                ]
                bottom [
                    gob-size/y - space/2/y - (spacing/y * max 0 rows - 1)
                    - total + target
                ]
            ]
            repeat row-number rows [
                row-offsets/:row-number: offset
                offset: offset + heights/:row-number + spacing/y
            ]
            row-init-ratio: ratio
            widths: head insert/dup copy [] none columns
            column-offsets: head insert/dup copy [] none columns
            source: init-pane/x
            total: target: size/x - (spacing/x * max 0 columns - 1)
            min-index: column-minification-index
            max-index: column-magnification-index
            while [
                while [
                    all [
                        min-i: first min-index
                        widths/:min-i
                    ]
                ] [min-index: next min-index]
                min-i
            ] [
                while [
                    all [
                        max-i: first max-index
                        widths/:max-i
                    ]
                ] [max-index: next max-index]
                ratio: either zero? source [1.0] [target / source]
                min-ratio: either zero? init-widths/:min-i [max-coord] [
                    min-widths/:min-i / init-widths/:min-i
                ]
                max-ratio: either zero? init-widths/:max-i [max-coord] [
                    max-widths/:max-i / init-widths/:max-i
                ]
                ratio: either (min-ratio - ratio) >= (ratio - max-ratio) [
                    i: min-i
                    max ratio min-ratio
                ] [
                    i: max-i
                    min ratio max-ratio
                ]
                widths/:i: round-to ratio * init-widths/:i phys-pixel/x
                source: source - init-widths/:i
                target: target - widths/:i
            ]
            column-init-ratio: ratio
            offset: switch pane-align [
                left [space/1/x]
                center [
                    round-to space/1/x + gob-size/x - space/2/x
                    - (spacing/x * max 0 columns - 1) - total + target / 2
                    phys-pixel/x
                ]
                right [
                    gob-size/x - space/2/x - (spacing/x * max 0 columns - 1)
                    - total + target
                ]
            ]
            repeat column-number columns [
                column-offsets/:column-number: offset
                offset: offset + widths/:column-number + spacing/x
            ]
            row-number: 1
            column-number: 1
            repeat i length? panel [
                sg: pick panel i
                face: sg/data
                if face/facets/resizes [
                    face/facets/gob-size: as-pair
                    widths/:column-number
                    heights/:row-number
                    do-actor face 'on-resize face/facets/gob-size
                    sg/offset/x: column-offsets/:column-number + switch face/facets/align [
                        left [0]
                        center [
                            round-to widths/:column-number
                            - face/facets/gob-size/x / 2 phys-pixel/x
                        ]
                        right [widths/:column-number - face/facets/gob-size/x]
                    ]
                    sg/offset/y: row-offsets/:row-number + switch face/facets/valign [
                        top [0]
                        middle [
                            round-to heights/:row-number
                            - face/facets/gob-size/y / 2 phys-pixel/y
                        ]
                        bottom [heights/:row-number - face/facets/gob-size/y]
                    ]
                    either layout-mode = 'horizontal [
                        column-number: column-number + 1
                        if column-number > columns [
                            column-number: 1
                            row-number: row-number + 1
                        ]
                    ] [
                        row-number: row-number + 1
                        if row-number > rows [
                            row-number: 1
                            column-number: column-number + 1
                        ]
                    ]
                ]
            ]
        ] panel/data/facets panel/data/facets/intern
    ]
]
parse-layout: funct [
    {Parses the layout dialect and returns a block of faces/commands.}
    block [block! none!]
    /no-names "don't set face name references"
] [
    unless block [return copy []]
    pane: make block! length? block
    dial: block
    opts: make block! 10
    trigs: make block! 2
    last-face: none
    build-face: func [
        /not-on-make
    ] [
        if all [not not-on-make object? last-face] [
            if show? [
                show-face/no-show last-face show?
            ]
            set-box-model last-face
            do-actor last-face 'on-make none
            if show? = 'fixed [
                do-actor last-face 'on-update none
                do-actor last-face 'on-resize last-face/facets/init-size
            ]
            show?: none
        ]
        all [
            block? last-face
            data: last-face/1
            last-face: last-face/1: apply :make-face [data/1 make-options data/1 data/2 not-on-make]
            if data/3 [
                extend last-face 'name data/3
                unless no-names [
                    set data/3 last-face
                ]
            ]
        ]
    ]
    forever [
        if error? err: try [
            dial: delect guie/dialect dial opts
        ] [
            either all [
                word? act: dial/1
                block? body: get dial/2
            ] [
                build-face/not-on-make
                extend-face last-face 'actors reduce [act funct/closure [face arg] body]
                dial: skip dial 2
                continue
            ] [
                fail-gui ["Cannot parse the GUI dialect at:" mold/only copy/part dial 5]
            ]
        ]
        unless dial [break]
        if word: first opts [
            arg: second opts
            case [
                word = 'face [
                    build-face
                    last-face: arg
                    if name [extend last-face 'name name name: none]
                    append pane last-face
                ]
                select guie/styles word [
                    build-face
                    insert/only last-face: tail pane reduce [word copy next opts name]
                    name: none
                ]
                word = 'default [
                    name: to-word arg
                ]
                word = 'return [
                    build-face
                    last-face: none
                    append pane 'return
                ]
                any [word = 'divider word = 'resizer] [
                    build-face
                    last-face: none
                    append pane word
                ]
                word = 'attach [
                    build-face
                    attach-face last-face any [opts/2 opts/3]
                ]
                last-face [
                    build-face/not-on-make
                    switch word [
                        options [
                            if arg [
                                arg: reduce/no-set arg
                                if arg/gob-offset [
                                    last-face/gob/offset: arg/gob-offset
                                    remove/part find/skip arg 'gob-offset 2 2
                                ]
                                if arg/show-mode [
                                    show?: arg/show-mode
                                    remove/part find/skip arg 'show-mode 2 2
                                ]
                                forskip arg 2 [
                                    if set-word? arg/1 [
                                        append last-face/facets copy/part arg 2
                                    ]
                                ]
                                either last-face/facets/gob-size = none [
                                    last-face/facets/gob-size: last-face/facets/init-size
                                ] [
                                    last-face/facets/init-size: last-face/facets/gob-size
                                ]
                            ]
                        ]
                        debug [
                            extend last-face 'debug any [arg [make]]
                            debug-face last-face 'make last-face
                        ]
                    ]
                ]
            ]
        ]
    ]
    build-face
    pane
]
bind-faces: funct [
    layout
] [
    unless get-facet layout 'names [exit]
    names: make object! 4
    find-layout-names layout names
    extend layout 'names names
    bind-layout-acts layout names
]
find-layout-names: funct [
    layout [object!]
    names [object!]
] [
    faces: faces? layout
    trigger-faces: select layout 'trigger-faces
    foreach field [faces trigger-faces] [
        foreach face get field [
            if item: select face 'name [
                repend names [item face]
                face/name: bind item names
            ]
        ]
    ]
    foreach face faces? layout [
        if all [
            not empty? faces? face
            not get-facet face 'names
        ] [
            find-layout-names face names
        ]
    ]
]
bind-layout-acts: funct [
    layout
    names [object!]
] [
    faces: faces? layout
    trigger-faces: select layout 'trigger-faces
    foreach field [faces trigger-faces] [
        foreach face get field [
            if item: select face 'reactors [
                bind item names
            ]
        ]
    ]
    foreach face faces? layout [
        if all [
            not empty? faces? face
            not get-facet face 'names
        ] [
            bind-layout-acts face names
        ]
    ]
]
do-triggers: funct [
    "Process all layout triggers of a given type."
    layout [object!]
    id [word!] "Type of trigger"
    /arg "optional arg value passed to trigger call"
    arg-value [any-type!]
    /once {immediately return the result of first triggered reactor}
    /no-recursive "don't recurse into sub-layouts"
] [
    result: none
    foreach face select layout 'trigger-faces [
        if all [
            triggers: select face/facets 'triggers
            find triggers id
        ] [
            set/any 'result do-actor face 'on-action any [arg-value get-face face]
            all [once return either none? :result [false] [:result]]
        ]
    ]
    unless no-recursive [
        foreach-face sub-face layout [
            unless all [
                empty? faces? sub-face
                empty? select sub-face 'trigger-faces
            ] [
                set/any 'result apply :do-triggers [sub-face id arg arg-value once false]
                all [once not none? :result return :result]
            ]
        ]
    ]
    result
]
init-effect-fly: funct [
    layout
    effect
] [
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
] [
    foreach face layout/faces [
        dest: first+ dests
        size: face/gob/size
        inc: max 1x1 dest + size / 6
        xy: face/gob/offset
        switch effect [
            fly-right [xy/y: dest/y]
            fly-left [xy/y: dest/y inc: negate inc]
            fly-down [xy/x: dest/x]
            fly-up [xy/x: dest/x inc: negate inc]
        ]
        op: get pick [max min] negative? inc
        while [xy <> dest] [
            face/gob/offset: xy
            show face/gob
            wait 0.01
            xy: op dest xy + inc
        ]
        face/gob/offset: dest
        show face/gob
    ]
]
effect-layout: funct [
    "Display a layout transition effect."
    layout [object!] "Layout face"
    effect [word! none!] "Effect word"
] [
    switch effect [
        fly-right
        fly-left
        fly-up
        fly-down [dests: init-effect-fly layout effect]
    ]
    draw-face/no-show layout
    switch effect [
        fly-right
        fly-left
        fly-up
        fly-down [anim-effect-fly layout effect dests]
    ]
]
view-layout: func [
    layout
    child
] [
    extend layout 'faces reduce [child]
    append clear layout/gob child/gob
    show-later layout
]
switch-layout: funct [
    "Switch content (faces) of a layout."
    top-layout [object!] "target"
    new-layout [object!] "source"
    effect [word! none!]
] [
    size: top-layout/gob/size
    margin: get-facet top-layout 'margin
    show clear top-layout/gob
    extend top-layout 'faces reduce [new-layout]
    append top-layout/gob new-layout/gob
    new-layout/gob/offset: margin
    s: size - margin - margin
    new-layout/gob/size: new-layout/facets/size: s
    new-layout/facets/area-size: s - 2x2
    collect-sizes top-layout
    do-actor top-layout 'on-resize size
    do-triggers new-layout 'enter
    effect-layout new-layout effect
]
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
] [
    name: parent: none
    assert-gui parse spec [
        some [
            spot:
            set name set-word!
            set parent opt word!
            set spec block! (make-text-style to-word name parent spec)
        ]
    ] ["Invalid font syntax:" spot]
]
make-text-style: funct [
    {Define a new font style (used for text face styles).}
    font-name [word!]
    font-parent [word! none!]
    spec [block! none!]
] [
    proto: either font-parent [guie/fonts/:font-parent] [guie/font]
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
    {Given a name, return gui font object defined earlier. (helper)}
    name
] [
    any [
        guie/fonts/:name
        warn-gui ["missing font:" name]
        guie/fonts/base
    ]
]
face-font?: funct [
    {Given a face, return gui font object defined earlier. (helper)}
    face
] [
    what-font? any [get-facet face 'text-style 'base]
]
font-font?: func [name] [select what-font? name 'font]
face-char-size?: funct [
    "Returns font char-size field. (helper)"
    face
] [
    style: face-font? face
    style/char-size
]
text-key-map: context [
    face: none
    key: none
    shift?: none
    chars: [
        #"^H" [
            remove-text-face face -1
            clear-text-caret face
        ]
        #"^X" [
            remove-text-face face 1
            clear-text-caret face
        ]
        #"^C" [copy-text-face face]
        #"^V" [insert-text-face face load-clip-text]
        #"^-" [
            insert-text-face face tab
        ]
        #"^M" [
            either get-facet face 'lines [
                insert-text-face face pick [#"^-" #"^/"] key = tab
            ] [
                do-face face
                all [
                    face: window-face? face
                    apply :find-tab-face? [face shift?]
                ]
            ]
        ]
        #"^A" [select-all face]
        #"^[" [unfocus]
        #"^Q" [quit]
    ]
    control: [
        home head
        end tail
        up back-para
        down next-para
        left back-word
        right next-word
        delete delete-end
    ]
    words: [
        left right
        up down
        home end
        page-down page-up
        back-word next-word
        back-para next-para
        head tail [move-cursor face key 1 shift?]
        delete [remove-text-face face 1]
        delete-end [remove-text-face face 'end-line]
        deselect [select-none face/state]
        ignore [none]
    ]
    no-edit: [
        #"^H" left
        #"^X" #"^C"
        #"^V" ignore
        #"^M" ignore
        delete deselect
        delete-end deselect
    ]
]
do-text-key: funct [
    "Process text face keyboard events."
    face [object!]
    event [event! object!]
    key
] [
    text-key-map/face: face
    text-key-map/shift?: find event/flags 'shift
    if no-edit: not tag-face? face 'edit [
        key: any [select/skip text-key-map/no-edit key 2 key]
    ]
    either char? key [
        text-key-map/key: key
        switch/default key bind text-key-map/chars 'event [
            unless no-edit [
                insert-text-face face key
            ]
        ]
    ] [
        if find event/flags 'control [
            key: any [select text-key-map/control key key]
        ]
        text-key-map/key: key
        switch/default key text-key-map/words [return event]
    ]
    none
]
insert-text-face: funct [
    {Insert text into field or area at cursor/mark position.}
    face [object!]
    text [char! string!]
] [
    state: face/state
    if mhead: state/mark-head [
        t: head state/cursor
        state/cursor: mhead
        remove/part mhead state/mark-tail
        if get-facet face 'hide-input [
            remove/part at face/facets/text-edit index? mhead index? state/mark-tail
        ]
        select-none state
        clear-text-caret face
    ]
    state/cursor: insert state/cursor either get-facet face 'hide-input [
        insert at face/facets/text-edit index? state/cursor text
        either string? text [
            append/dup clear "" "*" length? text
        ] [
            "*"
        ]
    ] [
        text
    ]
]
remove-text-face: funct [
    {Remove text from a field or area at cursor/mark position.}
    face [object!]
    len
    /clip
] [
    state: face/state
    either mhead: state/mark-head [
        mtail: state/mark-tail
        state/cursor: either positive? offset? mhead mtail [mhead] [mtail]
        select-none state
    ] [
        mhead: state/cursor
        mtail: len
        case [
            len = 'end-line [mtail: any [find mhead newline tail mhead]]
            negative? len [state/cursor: skip mhead len]
        ]
    ]
    if get-facet face 'hide-input [
        take/part at face/facets/text-edit index? mhead either string? mtail [index? mtail] [mtail]
    ]
    text: take/part mhead mtail
    if clip [save-clip-text text]
]
copy-text-face: funct [
    {Copy text from a field or area at cursor/mark position.}
    face
] [
    state: face/state
    either mhead: state/mark-head [
        save-clip-text copy/part mhead state/mark-tail
    ] [
        if get-facet face 'quick-copy [save-clip-text head face/cursor]
    ]
]
select-all: funct [
    "Select and mark all text in face"
    face
] [
    face/state/mark-head: head face/state/cursor
    face/state/cursor: face/state/mark-tail: tail face/state/cursor
    update-text-caret face
]
select-none: func [state] [
    state/mark-head: state/mark-tail: none
]
click-text-face: funct [
    "Make text face the focus and setup cursor."
    face
    cursor
    event
] [
    if block? cursor [cursor: first cursor]
    clear-text-caret face
    face/state/cursor: cursor
    face/state/xpos: none
    if event [
        case [
            find event/flags 'double [
                move-cursor face 'full-word 1 true
            ]
            all [
                find event/flags 'shift
                face/state/mark-head
            ] [
                face/state/mark-tail: cursor
            ]
            true [select-none face/state]
        ]
    ]
    apply :focus [face guie/focal-face = face]
]
save-clip-text: func [txt] [
    write clipboard:// to-binary enline txt
]
load-clip-text: does [
    ret: copy ""
    p: open clipboard://
    p/awake: func [evt] [
        if 'read = evt/type [
            ret: to string! copy evt/port/data
        ]
        true
    ]
    either none? ret: read p [
        wait/only [p 0.5]
    ] [
        ret: to string! ret
    ]
    close p
    deline ret
]
make-text: funct [
    {Make a text draw command block, with all necessary attributes.}
    face
    body
] [
    remind-gui ["making text:" face/style]
    style: face-font? face
    out: make block! 6
    foreach field [font para anti-alias] [
        if style/:field [repend out [field any [select face field style/:field]]]
    ]
    if val: select face/state 'scroll [
        cs: negate max 0x0 face/facets/content-size
        repend out ['scroll as-pair val/x * cs/x val/y * cs/y]
    ]
    if val: select face/state 'caret [
        repend out ['caret val]
    ]
    if id: select face/facets 'access-key [
        f: any [
            get select face/facets 'access-face
            face
        ]
        if id: any [
            find-access-key f id
            id
        ] [
            if f: any [find/case body id find body id] [
                i: index? f
                body: reduce [copy/part body i - 1 'u to string! body/:i 'u off copy skip body i]
            ]
        ]
    ]
    append out body
]
make-text-gob: funct [
    {Creates special 'text gob' which is used for editable text}
    face [object!]
    gsize [pair!]
    text-data [string!]
] [
    gob: make gob! [offset: 0x0 size: gsize data: face]
    fstyle: face-font? face
    out: make block! 10 + length? text-data
    foreach field [font para anti-alias] [
        if fstyle/:field [repend out [field any [select face field fstyle/:field]]]
    ]
    rot: get-facet face 'rotate
    append face 'draw-text
    face/draw-text: bind/copy compose/deep [(
            switch/default rot [
                90 [[
                        translate (as-pair gob/size/x - facets/space/1/x - facets/space/2/x 0 - facets/space/1/y)
                        rotate 90
                    ]]
                270 [[
                        translate (as-pair 0 gob/size/y - facets/space/1/y)
                        rotate 270
                    ]]
            ] []
        )
        pen off
        fill-pen (out/font/color)
        anti-alias (out/anti-alias)
        text 0x0 none (either all [rot rot <> 0] ['vectorial] ['aliased]) [(append out compose [
                    caret (select face/state 'caret) (text-data)
                ])]
    ] face
    gob
]
get-gob-text: func [
    {returns rich-text block (source dialect or resulting command block) of a 'text gob'}
    gob [gob!]
    /src "return the source text dialect block"
] [
    first find any [
        all [src gob/data/draw-text]
        gob/draw
        gob/data/draw-text
    ] block!
]
get-gob-scroll: func [
    "returns scroll value of a 'text gob'"
    gob [gob!]
] [
    gob/data/draw-text/text
]
set-gob-scroll: funct [
    "sets scroll value of a 'text gob'"
    gob [gob!]
    val [pair!]
] [
    gob/data/draw-text/text: val
    all [
        gob/draw
        gob/draw/text: val
    ]
]
oft-to-caret: funct [
    "offset-to-caret wrapper for text-gob only"
    gob [gob!]
    oft [pair!]
] [
    tmp: gob/draw
    gob/text: get-gob-text gob
    result: offset-to-caret gob oft
    gob/draw: tmp
    result
]
caret-to-oft: funct [
    "caret-to-offset wrapper for 'text-gob' only"
    gob [gob!]
    element [block!]
    position [string!]
] [
    tmp: gob/draw
    gob/text: get-gob-text gob
    result: caret-to-offset gob element position
    gob/draw: tmp
    result
]
size-txt: funct [
    "size-text wrapper for 'text-gob' only"
    gob [gob!]
] [
    tmp: gob/draw
    gob/text: get-gob-text gob
    unless tmp [gob/text: to-text gob/text copy []]
    result: size-text gob
    gob/draw: tmp
    result
]
size-text-face: funct [
    face [object!]
    limit-size [pair!]
] [
    gob: make gob! [offset: 0x0 size: limit-size]
    fstyle: face-font? face
    ffont: any [select face 'font fstyle/font]
    fpara: any [select face 'para fstyle/para]
    to-text compose [
        font (ffont)
        para (fpara)
        anti-alias (fstyle/anti-alias) (any [
                select face/facets 'text-body
                select face/facets 'text-edit
            ])
    ] gob/text: clear [] (either fpara/wrap? [1x0] [0x0]) +
    ffont/offset + fpara/margin + fpara/origin + size-text gob
]
font-char-size?: funct [
    fstyle [word! object!] "Font style"
    /with
    char [string!]
] [
    if word? fstyle [fstyle: what-font? fstyle]
    unless with [char: "M"]
    gob: make gob! [offset: 0x0 size: 300x100]
    to-text reduce [
        'font fstyle/font
        'para make fstyle/para [wrap?: off]
        'anti-alias fstyle/anti-alias
        char
    ] gob/text: clear []
    size-text gob
]
font-text-size?: funct [
    fstyle [word! object!] "Font style"
    text [string! block!]
] [
    font-char-size?/with fstyle text
]
resize-text-face: funct [
    face
] [
    face/state/xpos: none
    fstyle: face-font? face
    all [
        tgob: first face/gob
        size: size-txt tgob
        tgob/size/y: -5 + second face/facets/viewport-box/bottom-right
        tgob/size/x: -5 + face/facets/gob-size/x - any [fstyle/para/margin/x 0]
    ]
]
limit-text-size: funct [{Limit text size so it will fit in given gob size. Modifies!}
    text [string! block! none!] {String to limit. Can convert none! to empty string too.}
    size [pair!] "Maximal text size"
    fstyle "Font size"
] [
    text: any [text ""]
    gob: make gob! [offset: 0x0 size: size]
    to-text compose [
        font (fstyle/font)
        para (fstyle/para)
        anti-alias (fstyle/anti-alias) (text)
    ] gob/text: clear []
    t: tail gob/text
    while [
        all [
            t: find/reverse/only t string!
            size/x < first size-text gob
        ]
    ] [
        either empty? t/1 [
            t: back t
        ] [
            remove back tail t/1
            t: next t
        ]
    ]
    text
]
init-text-caret: func [face] [
    face/state/caret: context [
        caret: copy/deep [[""] ""]
        highlight-start: copy/deep [[""] ""]
        highlight-end: copy/deep [[""] ""]
    ]
]
clear-text-caret: funct [face] [
    car: face/state/caret
    car/caret/1: car/highlight-start/1: car/highlight-end/1: copy [""]
    car/caret/2: car/highlight-start/2: car/highlight-end/2: copy ""
]
update-text-caret: funct [face] [
    car: face/state/caret
    car/caret/1: car/highlight-start/1: car/highlight-end/1: back tail get-gob-text face/gob/1
    car/caret/2: face/state/cursor
    car/highlight-start/2: face/state/mark-head
    car/highlight-end/2: face/state/mark-tail
]
goto-caret: funct [
    "Set text caret to a specific position."
    face
    pos [string! integer! none!]
] [
    unless pos [exit]
    if string? pos [pos: index? pos]
    gob: first face/gob
    car: select get-gob-text gob 'caret
    txt: back tail get-gob-text/src gob
    car/caret/1: car/highlight-start/1: car/highlight-end/1: txt
    car/caret/2: face/state/cursor: at face/facets/text-edit pos
    car/highlight-start/2: none
    car/highlight-end/2: none
]
caret-xy?: funct [
    "Return cursor caret offset from text gob."
    gob
] [
    any [
        all [
            car: select get-gob-text gob 'caret
            car/caret/1
            car/caret/2
            caret-to-oft gob car/caret/1 car/caret/2
        ]
        0x0
    ]
]
see-caret: funct [
    "Force window to scroll for caret to be seen."
    face
] [
    if all [get-facet face [rotate:] rotate <> 0] [exit]
    tgob: first face/gob
    rowh: second face-char-size? face
    sizy: tgob/size/y
    scroll: get-gob-scroll tgob
    cpos: scroll + caret-xy? tgob
    case [
        cpos/x < 0 [
            scroll/x: scroll/x - cpos/x + 1
        ]
        cpos/x > tgob/size/x [
            scroll/x: scroll/x - (cpos/x - tgob/size/x) - 2
        ]
        tgob/size/x > first size-txt tgob [
            scroll/x: 0
        ]
    ]
    if sizy < rowh [
        scroll/y: 0
        set-gob-scroll tgob scroll
        exit
    ]
    posy: rowh + cpos/y
    tsiz: size-text-face face as-pair tgob/size/x 10000
    case [
        posy < rowh [
            scroll/y: scroll/y - posy + rowh
        ]
        posy > sizy [
            scroll/y: scroll/y - (posy - sizy)
        ]
    ]
    set-gob-scroll tgob scroll
]
move-caret: funct [
    "Move caret vertically. Return cursor string index."
    face
    action [word!]
] [
    tgob: sub-gob? face
    xy: caret-xy? tgob
    unless xy [return face/state/cursor]
    rowh: second face-char-size? face
    x: face/state/xpos: any [face/state/xpos xy/x]
    v: switch action [
        up [negate rowh]
        down [rowh]
        page-up [negate face/gob/size/y]
        page-down [face/gob/size/y]
    ]
    y: xy/y + (rowh / 2) + v
    caret: oft-to-caret tgob as-pair x y
    if empty? caret [
        caret: back tail caret
        caret/1: tail caret/1
    ]
    first caret
]
clear-all-carets: funct [
    "Clear all carets in a window/face"
    face
] [
    fields: tagged-faces face 'edit
    foreach f fields [
        if in f/state 'caret [
            clear-text-caret f
        ]
    ]
]
guie/char-space: charset { ^-
^M/[](){}"}
guie/char-valid: complement guie/char-space
move-cursor: funct [
    {Move cursor up, down, left, right, home, end, or to a position.}
    face [object!]
    action [word!]
    count
    select? "Add to marked text (selection)"
] [
    state: face/state
    cursor: state/cursor
    sc: any [state/mark-head cursor]
    tc: none
    reset-x: true
    cursor: switch action [
        left [
            sc: any [state/mark-tail cursor]
            skip cursor negate count
        ]
        right [skip cursor count]
        down up
        page-down page-up [
            reset-x: false
            move-caret face action
        ]
        head [head cursor]
        tail [tail cursor]
        end [
            loop count [
                unless tc: find cursor newline [break]
                cursor: next tc
            ]
            any [tc tail cursor]
        ]
        home [
            loop count [
                unless tc: find/reverse/tail cursor newline [break]
                cursor: back tc
            ]
            any [tc head cursor]
        ]
        back-word [
            tc: cursor
            loop count [
                all [
                    tc
                    tc: find/reverse tc guie/char-valid
                    tc: find/reverse tc guie/char-space
                    tc: next tc
                ]
            ]
            any [tc head cursor]
        ]
        next-word [
            tc: next cursor
            loop count [
                all [
                    tc
                    tc: find tc guie/char-space
                    tc: find tc guie/char-valid
                ]
            ]
            any [tc tail cursor]
        ]
        back-para [
            tc: back cursor
            loop count [
                all [
                    tc
                    tc: find/reverse cursor newline
                    tc: find/reverse tc guie/char-space
                    tc: find/reverse/tail tc newline
                ]
            ]
            any [tc head cursor]
        ]
        next-para [
            tc: cursor
            loop count [
                all [
                    tc
                    tc: find cursor newline
                    tc: find tc guie/char-valid
                ]
            ]
            any [tc tail cursor]
        ]
        full-word [
            select?: true
            tc: cursor
            sc: any [
                find/reverse/tail tc guie/char-space
                head cursor
            ]
            cursor: any [
                find tc guie/char-space
                tail cursor
            ]
        ]
    ]
    if reset-x [state/xpos: none]
    either select? [
        set bind [mark-head mark-tail] state reduce either (index? sc) < index? cursor [[sc cursor]] [[cursor sc]]
    ] [
        clear-text-caret face
        select-none state
    ]
    state/cursor: cursor
]
base-handler: context [
    do-event: func [event] [
        print "(Missing event handler)"
        event
    ]
    win-gob: none
    status: 'made
    name: 'no-name
    priority: 0
    about: "Main template for VIEW event handlers."
]
handle-events: func [
    "Adds a handler to the view event system."
    handler [block!]
    /local sys-hand
] [
    handler: make base-handler handler
    sys-hand: system/view/event-port/locals/handlers
    unless foreach [here: hand] sys-hand [
        if handler/priority > hand/priority [
            insert here handler
            break/return true
        ]
    ] [
        append sys-hand handler
    ]
    handler/status: 'init
    debug-gui 'handler ["added for:" handler/name]
    handler
]
unhandle-events: func [
    "Removes a handler from the view event system."
    handler [object!]
] [
    remove find system/view/event-port/locals/handlers handler
    exit
]
handled-events?: func [
    {Returns event handler object matching a given name.}
    name
] [
    foreach hand system/view/event-port/locals/handlers [
        if hand/name = name [return hand]
    ]
    none
]
wake-events: funct [
    "Awake the prior DO-EVENTS WAIT call."
    handler
] [
    handler/status: 'wake
]
do-events: funct [
    {Waits for window events. Returns when all windows are closed.}
] [
    wait-block: reduce [system/view/event-port 0 none]
    update-timers: does [
        either tail? guie/timers [
            wait-block/2:
            wait-block/3: none
        ] [
            wait-block/2: max 0 to decimal! difference guie/timers/2/timeout now/precise
            wait-block/3: guie/timers/1
        ]
    ]
    err: none
    if error? set/any 'err try [
        forever [
            either system/view/event-port = wait wait-block [
                either guie/timeout [
                    update-timers
                ] [
                    break
                ]
            ] [
                if all [
                    wait-block/3
                    pos: find/skip guie/timers wait-block/3 2
                ] [
                    timer: second pos
                    timer/callback
                    either timer/rate [
                        timer/timeout: timer/timeout + timer/rate
                        sort/skip/compare guie/timers 2 2
                    ] [
                        remove/part pos 2
                    ]
                ]
                update-timers
            ]
            guie/timeout: false
        ]
    ] [
        either guie/error-handler [
            do funct [error [error!]] guie/error-handler err
            do-events
        ] [
            do err
        ]
    ]
]
set-timer: funct [
    {Calls a function after a specified amount of time. Returns timer ID reference.}
    code [block!]
    timeout [number! time!]
    /repeat "Periodically repeat the function."
] [
    t: now/precise
    if number? timeout [timeout: to time! timeout]
    sort/skip/compare append guie/timers compose/deep/only [(id: guie/timer-id: guie/timer-id + 1) [
            timeout (t + timeout)
            rate (all [
                    repeat
                    max 0:00 timeout
                ])
            callback (funct [] code)
        ]] 2 2
    guie/timeout: true
    id
]
clear-timer: func [
    "Clears a timer set with the SET-TIMER function."
    timer-id [integer!]
] [
    remove/part find/skip guie/timers timer-id 2 2
    guie/timeout: true
]
init-view-system: func [
    "Initialize the View event subsystem."
    /local ep
] [
    init system/view/screen-gob: make gob! [text: "Top Gob"]
    if system/view/event-port [exit]
    ep: open [scheme: 'event]
    system/view/event-port: ep
    ep/locals: context [handlers: copy []]
    ep/awake: funct [event] [
        either all [
            obj: event/window/data
            obj: select obj 'handler
        ] [
            obj/do-event event
            if guie/timeout [
                return true
            ]
        ] [
            print "A mystery GUI event?"
            halt
        ]
        if obj/status = 'wake [
            obj/status: 'awake
            unhandle-events obj
            debug-gui 'handler ["Awake from WAIT:" obj/name]
            if find event/window/flags 'modal [
                return true
            ]
        ]
        tail? system/view/screen-gob
    ]
]
gui-events: context [
    handlers: none
    over-face:
    over-where:
    none
    within-clip?: funct [
        event [event!]
        face [object!]
    ] [
        all [
            pf: parent-face? face select pf 'facets
            oft: event/offset + face/gob/offset - pf/facets/space/1
            siz: pf/facets/viewport-box/bottom-right
            oft/x < siz/x
            oft/x >= 0
            oft/y < siz/y
            oft/y >= 0
        ]
    ]
    handlers: context [
        down: up: context [
            down-face: none
            do-event: func [event] [
                down-face: handler/(event/type)/do-event event down-face
            ]
            handler: context [
                down:
                alt-down:
                aux-down: context [
                    do-event: func [event face /local where] [
                        where: event/offset
                        event: map-event event
                        face: event/gob/data
                        unless within-clip? event face [
                            event/offset: event/offset + face/gob/offset
                            face: parent-face? face
                        ]
                        if face [
                            unless event: do-actor face 'on-click event [
                                unfocus
                            ]
                            if object? event [
                                event/start: where
                            ]
                        ]
                        face
                    ]
                ]
                up:
                alt-up:
                aux-up: context [
                    do-event: func [event down-face /local face drag] [
                        drag: all [guie/drag/face guie/drag]
                        if all [drag drag/gob] [
                            show drag/gob
                            remove find/last event/window drag/gob
                            cursor system-cursors/arrow
                        ]
                        event: map-event event
                        face: event/gob/data
                        unless within-clip? event face [
                            event/offset: event/offset + face/gob/offset
                            face: parent-face? face
                        ]
                        if face [event/offset: do-actor face 'locate event]
                        if all [down-face not drag down-face = face] [
                            do-actor down-face 'on-click event
                            return none
                        ]
                        case/all [
                            all [drag drag/gob drag/gob/offset = drag/base-offset] [
                                do-actor drag/face 'on-click event
                                drag: none
                            ]
                            all [drag drag/gob] [
                                f: face
                                drag/event: event
                                while [all [f not ret: do-actor f 'on-drop drag]] [
                                    drag/event/offset: drag/event/offset + f/gob/offset
                                    f: parent-face? f
                                ]
                                unless ret [
                                    do-actor drag/face 'on-over none
                                    base-pos: drag/base-offset + get-gob-offset drag/origin
                                    delta: base-pos - drag/gob/offset / 10
                                    loop 11 [
                                        drag/gob/offset: drag/gob/offset + delta
                                        show drag/gob
                                        wait/only 0.0125
                                    ]
                                    drag/gob/offset: drag/base-offset
                                    insert guie/drag/origin drag/gob
                                    win: window-face? drag/face
                                    show win/gob
                                ]
                                drag: none
                            ]
                            drag [
                                do-actor drag/face 'on-click event
                                drag: none
                            ]
                        ]
                        reset-drag
                        none
                    ]
                ]
            ]
        ]
        alt-down: alt-up: make down []
        aux-down: aux-up: make down []
        move: context [
            do-event: func [event /local face where window] [
                either drag: all [guie/drag/face guie/drag] [
                    either not drag/gob [
                        drag/delta: event/offset - drag/start
                        if any [drag/active not zero? drag/delta] [
                            drag/active: true
                            drag/event: map-event event
                            do-actor drag/face 'on-drag drag
                        ]
                    ] [
                        if any [drag/active greater? sum-pair abs drag/start - event/offset 2] [
                            drag/active: true
                            extend drag 'offset event/offset
                            window: event/window
                            drag/gob/offset: get-gob-offset drag/gob
                            do-actor drag/face 'on-drag drag
                            remove find/last event/window drag/gob
                            event: map-event event
                            face: event/gob/data
                            append window drag/gob
                            show-later either drag/show-parent? [drag/show-parent?: false drag/gob/parent] [drag/gob]
                            where: do-actor face 'locate event
                            if all [
                                any [
                                    face <> over-face
                                    where <> over-where
                                ]
                                any [
                                    do-actor/bubble face 'on-drag-over reduce [drag where yes] (
                                        cursor system-cursors/no
                                        false
                                    )
                                ]
                            ] [
                                cursor system-cursors/arrow
                                if over-face [
                                    do-actor over-face 'on-drag-over reduce [drag over-where no]
                                ]
                                do-actor face 'on-drag-over reduce [drag where yes]
                            ]
                            over-face: face
                            over-where: where
                        ]
                    ]
                ] [
                    win-face: event/window/data
                    mouse-offset: event/offset
                    event: map-event event
                    face: event/gob/data
                    unless within-clip? event face [
                        event/offset: event/offset + face/gob/offset
                        face: parent-face? face
                    ]
                    if face [
                        all [
                            win-face
                            do-actor win-face 'on-window-over reduce [face mouse-offset]
                        ]
                        do-actor face 'on-move event
                        either over-face <> face [
                            if over-face [
                                do-actor over-face 'on-over none
                            ]
                            over-face: face
                            do-actor face 'on-over event/offset
                        ] [
                            if get-facet face 'all-over [
                                do-actor face 'on-over event/offset
                            ]
                        ]
                    ]
                ]
            ]
        ]
        resize: context [
            do-event: func [event] [
                do-actor event/window/data 'on-resize event/offset
                clear guie/shows
                wait/only 0.001
                draw-face event/window/data
            ]
        ]
        rotate: context [
            do-event: func [event] [
                do-actor event/window/data 'on-rotate event
            ]
        ]
        key: key-up: context [
            do-event: func [event /local win face] [
                do-actor event/window/data 'on-key event
            ]
        ]
        custom: context [
            do-event: func [event] [
                switch pick [enter] event/offset/x [
                    enter [
                        do-triggers/arg event/window/data 'enter event/window/data
                    ]
                ]
            ]
        ]
        close: context [
            do-event: func [event] [
                do-actor event/window/data 'on-close event
            ]
        ]
        active: inactive: restore: offset: minimize: maximize: context [
            do-event: func [event] [
                do-actor event/window/data 'on-window event
            ]
        ]
        scroll-line: scroll-page: context [
            do-event: func [event /local face] [
                if over-face [
                    face: over-face
                    until [
                        event: do-actor face 'on-scroll-event event
                        not all [face: parent-face? face event? event]
                    ]
                ]
            ]
        ]
        drop-file: context [
            do-event: func [event /local gob ofs face where] [
                print "drop-file"
                event: map-event event
                face: event/gob/data
                event/offset: do-actor face 'locate event
                do-actor face 'on-drop event
            ]
        ]
    ]
    guie/handler: [
        name: 'gui
        priority: 0
        do-event: func [event] [
            debug-gui 'events [event/type event/offset]
            if any [
                not guie/popup-face
                all [guie/popup-face event/gob/data = guie/popup-face]
                all [guie/popup-face event/gob/data <> guie/popup-face do-actor guie/popup-face 'on-popup reduce ['outside-event event]]
            ] [
                handlers/(event/type)/do-event event
            ]
            show-now
            none
        ]
    ]
]
black: 0.0.0
coal: 64.64.64
gray: 128.128.128
pewter: 170.170.170
silver: 192.192.192
snow: 240.240.240
white: 255.255.255
blue: 0.0.255
green: 0.255.0
cyan: 0.255.255
red: 255.0.0
yellow: 255.255.0
magenta: 255.0.255
navy: 0.0.128
leaf: 0.128.0
teal: 0.128.128
maroon: 128.0.0
olive: 128.128.0
purple: 128.0.128
orange: 255.150.10
oldrab: 72.72.16
brown: 139.69.19
coffee: 76.26.0
sienna: 160.82.45
crimson: 220.20.60
violet: 72.0.90
brick: 178.34.34
pink: 255.164.200
gold: 255.205.40
tan: 222.184.135
beige: 255.228.196
ivory: 255.255.240
linen: 250.240.230
khaki: 179.179.126
rebolor: 142.128.110
wheat: 245.222.129
aqua: 40.100.130
forest: 0.48.0
water: 80.108.142
papaya: 255.80.37
sky: 164.200.255
mint: 100.136.116
lime: 40.200.40
reblue: 38.58.108
base-color: 200.200.200
yello: 255.240.120
request: funct [
    {Open a requestor modal dialog box. Returns result: true false none}
    title [string!]
    message [string! block!]
    /warn "Important message to user"
    /ask "Ask user a question (yes/no)"
    /cancel "Add a cancel button (returns as false)"
    /custom "Specify custom ok/cancel button titles"
    titles [block!]
    /options "Specify request window face options"
    opts [block!]
    /resize
] [
    btns: copy [default-button:]
    ok-btn: [
        button #auto ok-title on-action [close-window/result face window-face? face]
    ]
    close-btn: [
        button #auto close-title on-action [close-window/result face false]
    ]
    either ask [
        ok-title: "Yes"
        close-title: "No"
    ] [
        either custom [
            set [ok-title close-title] titles
        ] [
            ok-title: "Ok"
            close-title: "Cancel"
        ]
    ]
    if all [ok-title not empty? ok-title] [append btns ok-btn]
    if all [
        any [ask cancel custom]
        close-title not empty? close-title
    ] [
        append btns close-btn
    ]
    win-gob: view/modal/options compose/deep [(
            compose/deep either block? message [[vgroup [(message)] options [box-model: 'tight]]] [[
                    scroll-panel [
                        doc (message)
                    ] options [init-hint: 'auto]
                ]]
        )
        hgroup [(btns)] options [pane-align: 'right max-hint: reduce [guie/max-coord 'auto]]
        when [enter] on-action [focus default-button]
    ] append copy [
        no-resize: not resize
        title: title
        margin: 0x0
        bg-color: silver
        min-hint: 'init
        max-hint: (gui-metric 'work-size) - (gui-metric 'title-size) - (2 * gui-metric 'border-size)
        names: true
        shortcut-keys: [
            #"^[" [
                all [
                    arg/window/data
                    close-window arg/window/data
                ]
            ]
        ]
    ] any [opts []]
    get-face win-gob/data
]
alert: func [
    "Open an alert reqeustor."
    message [string! block!]
] [
    request/warn "Alert" reform message
]
locate-popup: funct [
    {Return the absolute coordinates for a popup below the given face.}
    face [object!]
] [
    set [gob: xy:] map-gob-offset/reverse face/gob 0x0
    face/gob/size * 0x1 + gob/offset + xy
]
show-later: func [
    item [gob! object! block! none!]
] [
    if object? item [item: select item 'gob]
    all [
        item
        append guie/shows item
    ]
]
contains-gob?: funct [
    "Check if the gob tree contains target gob."
    gob [gob!]
    tgob [gob!]
] [
    repeat i length? gob [
        sg: gob/:i
        all [
            any [
                sg = tgob
                contains-gob? sg tgob
            ]
            return true
        ]
    ]
    false
]
show-now: has [no-show] [
    no-show: clear []
    gobs: guie/shows
    foreach g gobs [
        foreach g2 gobs [
            all [
                g <> g2
                not no-show/:g2
                contains-gob? g g2
                append append no-show g2 true
            ]
        ]
    ]
    foreach g gobs [
        unless no-show/:g [
            show g
            append append no-show g true
        ]
    ]
    clear gobs
]
view: funct [
    {Displays a window view from a layout block, face (layout), or low level graphics object (gob).}
    spec [block! object! gob!] "Layout block, face object, or gob type"
    /options
    opts [block!] "Optional features, in name: value format"
    /modal "Display a modal window (pop-up)"
    /no-wait "Return immediately - do not wait"
    /across {Use horizontal layout-mode for top layout (rather than vertical)}
    /as-is {Use GOB exactly as passed - do not add a parent gob}
    /maximized "Open window in maximized state"
    /minimized "Open window in minimized state"
    /on-error
    error-handler [block!] "specify global error handler"
    /return-face "return a face object instead of a gob!"
] [
    unless screen: system/view/screen-gob [return none]
    opts: make map! reduce-opts any [opts []]
    if modal [opts/modal: true]
    if no-wait [opts/no-wait: true]
    if across [append opts [break-after: 0]]
    if as-is [opts/as-is: true]
    if on-error [guie/error-handler: error-handler]
    case [
        block? spec [
            win-face: apply :make-window-layout [spec opts maximized]
            win-gob: win-face/gob
        ]
        object? spec [
            win-face: spec
            win-gob: win-face/gob
            opts/handler: guie/handler
            append win-face 'handler
            either maximized [
                title-space: either all [opts/flags opts/flags/no-title] [0x0] [gui-metric 'title-size]
                do-actor win-face 'on-resize (gui-metric 'work-size) - (gui-metric 'work-origin) - title-space
                win-face/gob/size: win-face/facets/init-size
            ] [
                do-actor win-face 'on-update none
                do-actor win-face 'on-resize win-face/facets/init-size
            ]
            draw-face win-face
        ]
        gob? spec [
            either as-is [
                win-gob: spec
            ] [
                win-gob: make-window-gob spec opts
            ]
        ]
    ]
    win-gob/text: any [opts/title win-gob/text all [system/script/header system/script/header/title] "REBOL: untitled"]
    ds: screen/size - win-gob/size
    pos: any [
        opts/offset
        if all [
            last-win: last screen
            last-win/text <> "tooltip popup"
        ] [
            max 0x0 last-win/size - win-gob/size / 2 + last-win/offset
        ]
        'center
    ]
    win-gob/offset: case [
        pair? pos [pos]
        word? pos [
            max 5x5 switch pos [
                top-left [0x0]
                top-right [ds * 1x0]
                bottom-left [ds * 0x1]
                bottom-right [ds]
                center [ds - ((screen/size) - (gui-metric 'work-size)) / 2 + gui-metric 'work-origin]
            ]
        ]
        true [0x0]
    ]
    opts/flags: any [opts/flags copy [resize]]
    if opts/no-resize [
        alter opts/flags 'resize
    ]
    if opts/modal [
        foreach g reverse screen/pane [
            unless g/text = "Tooltip popup" [
                win-gob/owner: g
                append opts/flags [modal popup]
                break
            ]
        ]
        if win-face [win-face/state/value: none]
    ]
    if opts/owner [
        win-gob/owner: opts/owner
    ]
    if opts/handler [
        handler: handle-events opts/handler
        handler/win-gob: win-gob
        win-gob/data/handler: handler
    ]
    if opts/reactors [
        if win-face [extend win-face 'reactors opts/reactors]
    ]
    win-gob/flags: opts/flags
    if all [system/version/4 = 3 not find win-gob/flags 'no-title] [
        win-gob/offset/y: max win-gob/offset/y second (gui-metric 'title-size) + gui-metric 'border-size
    ]
    unless win-gob = screen [append screen win-gob]
    if maximized [win-gob/flags: 'maximize]
    if minimized [win-gob/flags: 'minimize]
    show win-gob
    wait-now: all [
        any [modal 1 = length? screen]
        not opts/no-wait
    ]
    if win-face [
        do-actor win-face 'on-init none
        e: make event! [type: 'custom window: win-gob code: 1]
        append system/ports/system e
    ]
    show-now
    if wait-now [
        if handler [handler/status: 'active]
        do-events
    ]
    either return-face [
        win-face
    ] [
        win-gob
    ]
]
close-window: func [
    "Close the parent window of a face."
    face
    /result value "Set result value (for requestors)"
] [
    if face: window-face? face [
        if result [set-face face value]
        do-actor face 'on-close face
    ]
]
unview: funct [
    {Closes a window view. Wakes up a prior WAIT if necessary.}
    /all "Close all views."
    /only "Close a single view. Window face or GOB."
    window [object! gob!]
] [
    screen: system/view/screen-gob
    case [
        all [show clear screen exit]
        gob? window [win-gob: window]
        object? window [
            self/all [
                'window = get in window 'style
                gob? window/facets/tool-tip-gob
                unview/only window/facets/tool-tip-gob
            ]
            win-gob: window/gob
        ]
        true [win-gob: last screen]
    ]
    remove find screen win-gob
    show win-gob
    if self/all [
        window: win-gob/data
        handler: select window 'handler
        handler/status = 'active
    ] [
        wake-events handler
    ]
    win-gob
]
layout: funct [
    spec [block!]
    /options
    opts [block! map!]
    /gob "return GOB instead of face object"
    /only "return layout without the WINDOW face"
] [
    if block? opts [opts: make map! reduce-opts opts]
    win-face: make-window-layout spec any [opts make map! []]
    if only [win-face: win-face/gob/pane/1/data]
    either gob [
        win-face/gob
    ] [
        win-face
    ]
]
reduce-opts: func [
    opts [block!]
    /local result wrd val beg fin
] [
    result: copy []
    parse opts [
        some [
            set wrd set-word! beg: (append result wrd) some [
                fin: [set-word! | end] (
                    val: copy/part beg fin
                    append result either lit-word? :val/1 [
                        :val/1
                    ] [
                        reduce val
                    ]
                ) break
                | skip
            ] :fin
            | skip
        ]
    ]
    result
]
make-window-layout: funct [
    content [block!]
    opts [map!]
    /maximized
] [
    bopts: make block! 2 * length? opts
    facets: words-of guie/styles/backdrop/facets
    if bm: select guie/box-models guie/styles/backdrop/facets/box-model [
        facets: union facets words-of bm
    ]
    foreach w intersect words-of opts facets [
        append/only append bopts w opts/:w
    ]
    win-face: make-face 'window append compose/deep [
        content: [
            backdrop [(content)]
            options [(bopts)]
        ]
    ] any [all [opts to block! opts] []]
    win-face/gob/text: find-title-text win-face/gob/1/data
    append win-face 'handler
    title-space: either all [opts/flags opts/flags/no-title] [0x0] [gui-metric 'title-size]
    either maximized [
        do-actor win-face 'on-resize (gui-metric 'work-size) - (gui-metric 'work-origin) - title-space
        win-face/gob/size: win-face/facets/init-size
    ] [
        do-actor win-face 'on-update none
        do-actor win-face 'on-resize win-face/facets/init-size
    ]
    while [win-face/facets/intern/update?] [
        updated?: true
        do-actor win-face 'on-update none
    ]
    min-win: (gui-metric 'window-min-size) - title-space - ((gui-metric either any [opts/no-resize all [opts/flags opts/flags/no-resize]] ['border-fixed] ['border-size]) * 2)
    if (to logic! if any [
            win-face/facets/min-size/x < min-win/x
            win-face/facets/min-size/y < min-win/y
        ] [
            win-face/facets/min-hint: max min-win win-face/facets/min-size
        ])
    or
    to logic! if any [
        win-face/facets/max-size/x < min-win/x
        win-face/facets/max-size/y < min-win/y
    ] [
        win-face/facets/max-hint: max min-win win-face/facets/max-size
    ] [
        updated?: true
        update-face/content/no-show win-face
    ]
    if updated? [do-actor win-face 'on-resize win-face/facets/init-size]
    draw-face/no-show win-face
    unless opts/handler [opts/handler: guie/handler]
    clear guie/shows
    win-face
]
make-window-gob: funct [
    spec [gob!]
    opts [map!]
] [
    either opts/as-is [
        window: spec
    ] [
        spec/offset: 0x0
        window: make gob! [size: spec/size text: "Window"]
        append window spec
    ]
    if any [
        opts/color
        opts/draw
    ] [
        spec: copy [
            size: window/size
            offset: 0x0
        ]
        if opts/color [append spec [color: opts/color]]
        if opts/draw [append spec [draw: to-draw opts/draw copy []]]
        insert window make gob! spec
    ]
    unless opts/handler [opts/handler: gob-handler]
    window/data: make object! [
        handler: none
        options: opts
    ]
    window
]
gob-handler: [
    name: 'gob
    about: "Low level handler for VIEW of simple GOBs."
    priority: 50
    do-event: func [event] [
        print ["view-event:" event/type event/offset]
        either switch event/type [
            close [true]
            key [event/key = escape]
        ] [
            unview/only event/window
        ] [
            show event/window
        ]
        none
    ]
]
issue-id: funct [
    "Issue unique id"
    pool [block! map!] "Where to look for issued ids"
] [
    id: make string! 8
    loop 8 [append id first random "abcdefghijklmnopqrstuvwxyz0123456789"]
    if map? pool [pool: words-of pool]
    either any [
        find pool id
        find "0123456789" first id
    ] [issue-id pool] [id]
]
inside?: funct [
    "Check if pair is inside two pairs box"
    value [pair!]
    top-left-corner [pair!]
    bottom-right-corner [pair!]
] [
    not any [(t: value - top-left-corner) <> abs t (t: bottom-right-corner - value) <> abs t]
]
ifv: func [
    {If condition is true assign block's value to word otherwise keep curent value}
    :value
    condition
    then-block
] [
    either condition [set value do then-block] [get value]
]
if=: func [
    {If condition has value, return it, otherwise evaluate the block.}
    condition
    then-block
] [
    either condition [condition] then-block
]
ift: func [
    {If condition is TRUE, evaluates the block. Returns TRUE otherwise.}
    condition
    then-block
] [
    either condition then-block [true]
]
limit: func ["Limit number in between boundaries"
    number [number!] "Number to limit"
    min-value [number!] "Lower boundary"
    max-value [number!] "Highwe boundary"
] [
    min max-value max min-value number
]
limit?: func [{Return TRUE if number is in between boundaries, FALSE otherwise}
    number [number!] "Number to limit"
    min-value [number!] "Lower boundary"
    max-value [number!] "Highwe boundary"
] [
    all [number <= max-value number >= min-value]
]
auto-complete: func [{Return list of all itemps that begin with the string}
    list [block!] "List of available choices"
    string [char! string!] "String to search"
    /index "Return index of first match"
    /local len
] [
    local: copy []
    string: to string! string
    len: length? string
    forall list [
        all [
            equal? string copy/part to string! list/1 len
            append local list/1
            index
            return index? list
        ]
    ]
    either index [none] [local]
]
show-tooltip: funct [
    tooltip [object!]
    parent-face [object!]
] [
    win: window-face? parent-face
    tooltip/gob/offset: parent-face/gob/size * 0x1 + second map-gob-offset/reverse parent-face/gob 1x1
    tooltip/style: 'tooltip
    append win/gob tooltip/gob
    show tooltip/gob
]
hide-tooltip: funct [
    face [object!] "Face from window where to close tooltip"
] [
    win: window-face? face
    faces: faces? win
    until [
        either all [tt: first faces 'tooltip = tt/style] [
            tt: tt/gob
            tt/alpha: tt/color: tt/draw: tt/image: tt/text: tt/pane: none
            show tt
            remove at win/gob index? faces
        ] [
            faces: next faces
        ]
        tail? faces
    ]
]
show-popup: funct ["Displays a popup view"
    popup [gob! block! object!] "Popup gob, VID face, or VID layout block"
    parent-face [object!] "Parent face that opens popup"
    /offset offs
    /size siz
] [
    main-win: window-face? parent-face
    if not siz [
        siz: as-pair parent-face/gob/size/x 120
    ]
    off: main-win/gob/offset + (second map-gob-offset/reverse parent-face/gob 1x1) + (0x1 * parent-face/gob/size) - 0x2
    if offs [off: off + offs]
    guie/popup-parent: parent-face
    show-now
    popup: view/options popup [
        owner: main-win/gob
        flags: [popup on-top no-title]
        as-is: true
        offset: off
        init-hint: siz - 2x0
    ]
    guie/popup-face: popup/data
    guie/popup-parent: parent-face
    guie/popup-face
]
hide-popup: funct [
    "Close popup view"
] [
    if guie/popup-face [
        unview/only guie/popup-face
        unhandle-events guie/popup-face/handler
        guie/focal-face:
        guie/popup-face:
        guie/popup-parent: none
    ]
]
do-popup-parent: func [
    "Call a popup's parent style actor function."
    act [word!] "Actor identifier"
    data {Argument to the actor (use block for multiple args).}
] [
    do-actor guie/popup-parent :act :data
    do-face guie/popup-parent
]
place-popup: funct [
    "Place popup where the popup's parent is."
] [
    main-win: window-face? guie/popup-parent
    guie/popup-face/gob/offset: main-win/gob/offset + (second map-gob-offset/reverse guie/popup-parent/gob 1x1) + (0x1 * guie/popup-parent/gob/size)
]
get-style-actors: funct [
    style-name [word!]
] [
    style: select guie/styles style-name
    words-of style/actors
]
catenate: funct ["Joins values with delimiter."
    src [block!]
    delimiter [char! string!]
] [
    out: make string! 20
    forall src [repend out [src/1 delimiter]]
    head remove back tail out
]
specular-functions: reduce [
    'mul func [c v] [
        c * v
    ]
    'linear func [c v] [
        c * v
    ]
    'high func [c v] [
        c * v + min 255 to-integer max 0 800 * v - 545
    ]
    'avg func [c v] [
        to-tuple reduce [
            min 255 255 * v + c/1 * v / 2
            min 255 255 * v + c/2 * v / 2
            min 255 255 * v + c/3 * v / 2
        ]
    ]
]
set-opacity: func [
    "Sets opacity for a single color between 0 and 100%"
    color [tuple!]
    v [integer! decimal! percent!]
] [
    color/4: v * 255
    color
]
make-gradient: funct [
    {Build a gradient color span based on a material object.}
    color [tuple!]
    mat-obj [object!] "Material object"
] [
    fn: any [
        select specular-functions mat-obj/specular
        select specular-functions 'mul
    ]
    out: make block! length? mat-obj/diffusion
    foreach v mat-obj/diffusion [
        append out case [
            percent? :v [
                to-decimal v
            ]
            tuple? :v [
                v
            ]
            number? :v [
                set-opacity fn color v * mat-obj/intensity mat-obj/opacity
            ]
        ]
    ]
]
make-material: funct [
    {Adds a materials facet to face from material's name.}
    face [object!] "Face object"
    material [word! none!] "Material's name"
    /color clr [tuple!] "Optional color to use"
    /facet fct [word!] {Optional facet to use to get color (standard is 'bg-color)}
] [
    unless material [exit]
    unless facet [fct: 'bg-color]
    unless color [clr: any [get-facet face fct gray]]
    mat-obj: make object! []
    mat: materials/:material
    foreach mode words-of mat [
        mm: mat/:mode
        repend mat-obj [
            mode
            either tuple? mm/diffusion [
                mm/diffusion
            ] [
                make-gradient clr mm
            ]
        ]
    ]
    set-facet face 'materials mat-obj
]
set-material: funct [
    {Chooses the gradient from a material object to use with a face mode}
    face [object!]
    mode [word! none!]
] [
    all [
        mat: get-facet face 'materials
        set-facet face 'area-fill any [
            all [mode select mat mode]
            select mat 'up
            select mat first words-of mat
        ]
    ]
]
use-material: func [
    "Gets a gradient or color directly from a material"
    color [tuple!]
    'material [word!]
] [
    set-material make-material color (material) none
]
make-color: funct [
    {Creates a material object from a material asset and an input color and intensity}
    color [tuple!]
    intensity [number!]
    'material [word!]
] [
    mat: materials/:material
    mat-obj: make object! []
    foreach mode words-of mat [
        repend mat-obj [
            mode
            do select specular-functions
            get in get in mat first words-of mat 'specular
            color
            intensity
        ]
    ]
    mat-obj
]
set-color: func [
    {Chooses the color from a material object to use with a face mode}
    mat [object!]
    mode [word! none!]
] [
    set-material mat mode
]
use-color: func [
    "Gets a color directly from a material"
    color [tuple!]
    intensity [number!]
    'material [word!]
] [
    set-color make-color color intensity (material) none
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
        anti-alias: (either system/version/4 = 13 ['on] ['off])
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
    area: base []
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
            origin: 18x0
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
stylize [
    face: [
        about: "A special style used passing pre-built faces."
        options: [
            content: [object!]
            init-size: [pair!]
        ]
    ]
    window: [
        about: "A special style used by system for window layouts."
        tags: [form]
        facets: [
            tab-face: none
            last-focus: none
            tool-tip-popup: false
            tool-tip-gob: none
            tool-tip-cb: none
            tool-tip-timer: none
            tool-tip-delay-timer: none
            tool-tip-over-face: none
            mouse-pos: none
            over-face: none
            init-hint: 'auto
            min-hint: none
            max-hint: none
        ]
        intern: [
            hide-tooltip: func [face] [
                unless face/facets/tool-tip-gob/offset/y = -10000 [
                    face/facets/tool-tip-gob/offset/y: -10000
                    show face/facets/tool-tip-gob
                ]
            ]
            show-tooltip: funct [face] [
                face/facets/tool-tip-gob/offset: confine pos: face/gob/offset + face/facets/mouse-pos + 1x23 face/facets/tool-tip-gob/size + 1 gui-metric 'work-origin gui-metric 'work-size
                if not-equal? face/facets/tool-tip-gob/offset/y pos/y [
                    face/facets/tool-tip-gob/offset/y: pos/y - face/facets/tool-tip-gob/size/y - 25
                ]
                show face/facets/tool-tip-gob
            ]
            clear-tool-tip-timers: func [face] [
                all [
                    face/facets/tool-tip-timer
                    clear-timer face/facets/tool-tip-timer
                    face/facets/tool-tip-timer: none
                ]
                all [
                    face/facets/tool-tip-delay-timer
                    clear-timer face/facets/tool-tip-delay-timer
                    face/facets/tool-tip-delay-timer: none
                ]
            ]
        ]
        actors: [
            on-window-over: [
                if any [
                    face/facets/tool-tip-popup
                    face/facets/mouse-pos = arg/2
                ] [
                    exit
                ]
                face/facets/over-face: arg/1
                face/facets/mouse-pos: arg/2
                either in arg/1/facets 'tool-tip [
                    either any [
                        not face/facets/tool-tip-timer
                        all [
                            face/facets/tool-tip-over-face <> face/facets/over-face
                            face/intern/hide-tooltip face
                        ]
                    ] [
                        face/intern/clear-tool-tip-timers face
                        face/facets/tool-tip-over-face: face/facets/over-face
                        face/facets/tool-tip-timer: set-timer face/facets/tool-tip-cb any [
                            all [
                                in arg/1/facets 'tool-tip-delay
                                arg/1/facets/tool-tip-delay
                            ]
                            guie/tool-tip-delay
                        ]
                    ] [
                        if all [
                            not-equal? face/facets/tool-tip-gob/offset/y -10000
                            any [
                                all [
                                    in face/facets/over-face/facets 'tool-tip-follow
                                    face/facets/over-face/facets/tool-tip-follow
                                ]
                                guie/tool-tip-follow
                            ]
                        ] [
                            face/intern/show-tooltip face
                        ]
                    ]
                ] [
                    face/intern/clear-tool-tip-timers face
                    face/intern/hide-tooltip face
                ]
            ]
            on-make: [
                make-layout face 'panel
            ]
            on-init: [
                unless any [
                    face/facets/tool-tip-popup
                    face/facets/tool-tip-gob
                ] [
                    face/facets/tool-tip-cb: bind/copy [
                        if in facets/over-face/facets 'tool-tip [
                            set-content facets/tool-tip-gob/1/data either block? facets/over-face/facets/tool-tip [
                                facets/over-face/facets/tool-tip
                            ] [[text facets/over-face/facets/tool-tip options [one-line: true]]]
                            update-face/content facets/tool-tip-gob/data
                            intern/show-tooltip self
                            if hide-timeout: any [
                                all [
                                    in facets/over-face/facets 'tool-tip-timeout
                                    facets/over-face/facets/tool-tip-timeout
                                ]
                                guie/tool-tip-timeout
                            ] [
                                facets/tool-tip-delay-timer: set-timer [
                                    intern/hide-tooltip self
                                    facets/tool-tip-delay-timer: none
                                ] hide-timeout
                            ]
                        ]
                    ] face
                    face/facets/tool-tip-gob: view/no-wait/options [] [
                        title: "tooltip popup"
                        flags: [popup no-title on-top]
                        owner: get in window-face? face 'gob
                        bg-color: 255.255.225
                        tool-tip-popup: true
                        offset: 0x-10000
                        padding: [2x2 2x2]
                    ]
                    f: face/facets/tool-tip-gob/data/facets
                    f/min-hint: 'init
                    f/init-hint: 'auto
                    f/max-hint: 'init
                    f/padding: [0x0 0x0]
                ]
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                resize-panel face/gob
                do-actor face 'on-popup [moved]
            ]
            on-rotate: [
                do-triggers/arg face 'rotate arg
                do-actor face 'on-resize arg/offset
                draw-face face
            ]
            on-update: [
                update-panel face/gob
            ]
            on-content: [
                do-actor/style face 'on-content arg 'hpanel
            ]
            on-window: [
                switch arg/type [
                    offset [
                        if face <> guie/popup-face [
                            do-actor face 'on-popup [moved]
                        ]
                    ]
                    active [
                        if face/facets/tool-tip-popup [
                            face/facets/owner/flags: 'active
                            show face/facets/owner
                            exit
                        ]
                        if face/facets/last-focus [
                            focus/force face/facets/last-focus
                        ]
                    ]
                    inactive [
                        unless face/facets/tool-tip-popup [
                            face/intern/hide-tooltip face
                            face/intern/clear-tool-tip-timers face
                        ]
                        face/facets/last-focus: either all [guie/focal-face face = window-face? guie/focal-face] [
                            guie/focal-face
                        ] [
                            none
                        ]
                        all [
                            face/facets/last-focus
                            unfocus
                        ]
                    ]
                ]
                none
            ]
            on-close: [
                result: none
                set/any 'result do-triggers/once/arg face 'close arg
                unless all [value? 'result result] [
                    unview/only face
                ]
            ]
            on-popup: [
                if guie/popup-face [
                    switch arg/1 [
                        moved [
                            place-popup
                            show-later guie/popup-face/gob
                        ]
                        outside-event [
                            if arg/2/type = 'down [
                                hide-popup
                                exit
                            ]
                            true
                        ]
                    ]
                ]
            ]
            on-key: [
                all [
                    arg/type = 'key
                    either arg/key = #"^-" [
                        'propagate-event <> process-tab arg
                    ] [
                        any [
                            process-access-key arg
                            process-shortcut-key arg
                        ]
                    ]
                    exit
                ]
                all [
                    guie/focal-face
                    window-face? guie/focal-face
                    do-actor guie/focal-face 'on-key arg
                ]
            ]
            on-set: [face/state/value: arg/2]
            on-get: [face/state/value]
        ]
    ]
    hgroup: [
        about: {For spaced groups. No background or borders. Default horizontal.}
        tags: [layout]
        facets: [
            draw-mode: 'plain
            area-fill:
            material:
            min-hint:
            max-hint: none
            init-hint: 'auto
            layout-mode: 'horizontal
            box-model: 'layout
            dividers:
            mouse-pointers:
            hints:
            old-hints: none
            divider-over: none
        ]
        options: [
            content: [block!]
            init-hint: [pair!]
            bg-color: [tuple!]
        ]
        intern: [
            make-dividers: funct [
                face [object!]
                dividers [block!]
            ] [
                out: make block! length? dividers
                lines: make block! length? face/facets/intern/lines
                a: pick [[x y] [y x]] face/facets/layout-mode = 'vertical
                foreach l face/facets/intern/lines [
                    append lines l/length + any [last lines 0]
                ]
                foreach [id specs] dividers [
                    if f: find lines id [
                        append/only out append compose [id (index? f) size 0 axis (a/1) color (pewter)] specs
                    ]
                ]
                if empty? out [return none]
                unless get-facet face 'mouse-pointers [
                    set-facet face 'mouse-pointers reduce ['x system-cursors/size-we 'y system-cursors/size-ns]
                ]
                out
            ]
        ]
        actors: [
            on-make: [
                switch get-facet face 'box-model [
                    frame [
                        set-facet face 'material 'container-groove
                    ]
                ]
                make-material face get-facet face 'material
                set-material face 'up
                all [
                    get-facet face 'area-fill
                    set-facet face 'draw-mode 'gradient
                ]
                make-layout face 'group
            ]
            on-init: [
                if get-facet face [dividers:] [
                    face/facets/dividers: face/intern/make-dividers face dividers
                ]
            ]
            on-attach: [
                set-face arg face/state/value
            ]
            on-content: [
                switch arg/1 [
                    clear [
                        remove-from-group face/gob arg/3 arg/4
                        if trigger-faces: select face 'trigger-faces [clear trigger-faces]
                        bind-faces face
                        apply :update-face [face arg/2 true]
                        face
                    ]
                    insert [
                        content: arg/3
                        index: arg/4
                        trigs: insert-into-group face/gob index content
                        bind-faces face
                        do-actor content 'on-init none
                        all [
                            trigs
                            extend-face face 'trigger-faces trigs
                            do-actor trigs 'on-init none
                        ]
                        do-triggers/no-recursive face 'load
                        apply :update-face [face arg/2 true]
                        face
                    ]
                    remove [
                        index: arg/3
                        range: arg/4
                        if trigger-faces: select face 'trigger-faces [
                            foreach g apply :copy [at face/gob/pane index range range] [
                                if f: find trigger-faces g/data [remove f]
                            ]
                        ]
                        apply :remove-from-group [face/gob index range]
                        bind-faces face
                        apply :update-face [face arg/2 true]
                        face
                    ]
                ]
            ]
            on-scroll: [
                gob: face/gob
                sgob: sub-gob? face
                bars: select face 'attached
                if all [bars sgob] [
                    axis: face-axis? arg
                    if sgob/size/:axis > 0 [
                        set-face/field/no-show arg to percent! gob/size/:axis / sgob/size/:axis 'delta
                        sgob/offset/:axis: negate (sgob/size/:axis + (2 * face/facets/spacing/:axis)) - gob/size/:axis * arg/state/value - face/facets/spacing/:axis
                        show-later sgob
                    ]
                ]
            ]
            on-set: [
                if all [arg/1 = 'value block? arg/2] [
                    set-layout face arg/2
                ]
            ]
            on-get: [
                get-layout face
            ]
            on-clear: [
                clear-layout face
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                resize-group face/gob
                foreach bar select face 'attached [
                    if bar/style = 'scroller [
                        do-face bar
                    ]
                ]
                get-facet face [dividers:]
                forall dividers [
                    axis: dividers/1/axis
                    w: face/facets/padding/1/:axis
                    repeat n dividers/1/id [
                        w: w + face/facets/intern/lines/:n/size
                    ]
                    dividers/1/size: w + (dividers/1/id - 1 * face/facets/spacing/:axis)
                ]
                dividers
            ]
            on-update: [
                update-group face/gob
                if get-facet face 'dividers [
                    either block? face/facets/line-init [
                        append/dup face/facets/line-init 'max (length? face/facets/intern/lines) - length? face/facets/line-init
                    ] [
                        face/facets/line-init: head insert/dup copy [] face/facets/line-init length? face/facets/intern/lines
                    ]
                ]
            ]
            on-move: [
                get-facet face [dividers: mouse-pointers:]
                foreach d dividers [
                    axis: d/axis
                    size: d/size
                    either all [
                        arg/offset/:axis >= size
                        arg/offset/:axis < (size + face/facets/spacing/:axis)
                    ] [
                        cursor mouse-pointers/:axis
                        unless d/color = tan [
                            d/color: tan
                            face/facets/divider-over: d
                            draw-face face
                        ]
                        break
                    ] [
                        cursor system-cursors/arrow
                    ]
                ]
            ]
            on-over: [
                unless arg [
                    cursor system-cursors/arrow
                    if face/facets/divider-over [
                        face/facets/divider-over/color: pewter
                        face/facets/divider-over: none
                        draw-face face
                    ]
                ]
            ]
            on-click: [
                if logic? arg [return arg]
                either arg/type = 'down [
                    foreach d get-facet face 'dividers [
                        size: d/size
                        axis: d/axis
                        if all [
                            arg/offset/:axis >= size
                            arg/offset/:axis < (size + face/facets/spacing/:axis)
                        ] [
                            return init-drag/only/data face arg/offset d
                        ]
                    ]
                ] [
                    if face/facets/hints [
                        set face/facets/hints face/facets/old-hints
                        update-face/content face
                        face/facets/hints: face/facets/old-hints: none
                    ]
                ]
                false
            ]
            on-drag: [
                d: arg/data
                i: d/id
                w: d/size
                axis: d/axis
                r: face/facets/intern/line-init-ratio
                p: face/facets/intern/lines/:i
                mprev: p/min-size/:axis
                xprev: p/max-size/:axis
                either d/type = 'resizer [
                    j: length? face/facets/line-init
                ] [
                    j: i + 1
                ]
                n: face/facets/intern/lines/:j
                prev: p/size
                next: n/size
                mnext: n/min-size/:axis
                xnext: n/max-size/:axis
                iprev: p/init-size/:axis
                inext: n/init-size/:axis
                pn: prev + next
                face/facets/line-init/:i: (t: max
                    max pn - xnext mprev
                    min
                    min pn - mnext xprev (arg/base/:axis + arg/delta/:axis - (w - prev))
                ) / r
                face/facets/line-init/:j: (max
                    mnext
                    min
                    xnext (pn - t)
                ) / r
                unless face/facets/old-hints [
                    face/facets/old-hints: reduce face/facets/hints: bind [
                        min-hint
                        max-hint
                        init-hint
                    ] face/facets
                    set face/facets/hints 'keep
                ]
                update-face/content face
            ]
            on-draw: [
                foreach d get-facet face 'dividers [
                    size: d/size - face/facets/padding/1/(d/axis)
                    either d/axis = 'x [
                        p1: as-pair size face/facets/viewport-box/top-left/y + face/facets/padding/1/y
                        p2: as-pair size + face/facets/spacing/x face/facets/viewport-box/bottom-right/y - face/facets/padding/2/y
                    ] [
                        p1: as-pair face/facets/viewport-box/top-left/x + face/facets/padding/1/x size
                        p2: as-pair face/facets/viewport-box/bottom-right/x - face/facets/padding/2/x size + face/facets/spacing/y
                    ]
                    append arg compose [
                        pen off
                        fill-pen (d/color)
                        box (p1) (p2) 3.5
                    ]
                ]
                arg
            ]
            on-reset: [
                clear-layout face
            ]
        ]
        draw: [
            plain: []
            gradient: [
                clip border-box/top-left border-box/bottom-right
                pen none
                line-width 0
                grad-pen linear 1x1 0 gob/size/y 90 area-fill
                box (margin-box/top-left + 1) (margin-box/bottom-right - 1) 1
            ]
        ]
    ]
    vgroup: hgroup [
        facets: [
            layout-mode: 'vertical
        ]
    ]
    hpanel: hgroup [
        about: "For grouping faces with a background and borders."
        tags: [layout]
        facets: [
            break-after: 0
            layout-mode: 'horizontal
        ]
        options: [
            content: [block! object!]
            init-hint: [pair!]
            bg-color: [tuple!]
            break-after: [integer!]
        ]
        intern: [
            make-dividers: funct [
                face [object!]
                dividers [block!]
            ] [
                out: make block! length? dividers
                c: get-facet face 'break-after
                r: to integer! (f: length? faces? face) / (any [all [c > 0 c] 1]) + 0.5
                a: pick [[x y] [y x]] face/facets/layout-mode = 'vertical
                foreach [id specs] dividers [
                    unless any [
                        id = 0
                        id = f
                    ] [
                        i: id
                        if c > 0 [
                            i: id // c
                        ]
                        either i = 0 [
                            axis: a/1
                            i: id / c
                        ] [
                            axis: a/2
                        ]
                        sizes: pick [[widths init-widths column-init] [heights init-heights row-init]] axis = 'x
                        unless any [
                            i = 0
                            all [d: select out i d/axis = axis]
                        ] [
                            append/only out append compose/only [id (i) size 0 axis (axis) sizes (sizes) color (pewter)] specs
                        ]
                    ]
                ]
                if empty? out [return none]
                unless get-facet face 'mouse-pointers [
                    set-facet face 'mouse-pointers reduce ['x system-cursors/size-we 'y system-cursors/size-ns]
                ]
                out
            ]
        ]
        actors: [
            on-make: [
                switch get-facet face 'box-model [
                    frame [
                        set-facet face 'material 'container-groove
                    ]
                ]
                make-material face get-facet face 'material
                set-material face 'up
                all [
                    get-facet face 'area-fill
                    set-facet face 'draw-mode 'gradient
                ]
                make-layout face 'panel
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                resize-panel face/gob
                foreach f select face 'attached [
                    if f/style = 'scroller [
                        do-face f
                    ]
                ]
                get-facet face [dividers:]
                forall dividers [
                    axis: dividers/1/axis
                    w: face/facets/padding/1/:axis
                    sizes: dividers/1/sizes/1
                    repeat n dividers/1/id [
                        w: w + face/facets/intern/(sizes)/:n
                    ]
                    dividers/1/size: w + (dividers/1/id - 1 * face/facets/spacing/:axis)
                ]
            ]
            on-update: [
                update-panel face/gob
                if get-facet face 'dividers [
                    either block? face/facets/column-init [
                        append/dup face/facets/column-init 'max (length? face/facets/intern/init-widths) - length? face/facets/column-init
                    ] [
                        face/facets/column-init: head insert/dup copy [] face/facets/column-init length? face/facets/intern/init-widths
                    ]
                    either block? face/facets/row-init [
                        append/dup face/facets/row-init 'max (length? face/facets/intern/init-heights) - length? face/facets/row-init
                    ] [
                        face/facets/row-init: head insert/dup copy [] face/facets/row-init length? face/facets/intern/init-heights
                    ]
                ]
            ]
            on-drag: [
                d: arg/data
                w: d/size
                i: d/id
                axis: d/axis
                sizes: d/sizes
                ms: face/facets/intern/(select [x min-widths y min-heights] axis)
                xs: face/facets/intern/(select [x max-widths y max-heights] axis)
                r: face/facets/intern/(select [x column-init-ratio y row-init-ratio] axis)
                s: face/facets/intern/(sizes/1)
                j: either d/type = 'resizer [
                    length? s
                ] [
                    i + 1
                ]
                prev: s/:i
                next: s/:j
                pn: prev + next
                face/facets/(sizes/3)/:i: (t: max
                    max pn - xs/:j ms/:i
                    min
                    min pn - ms/:j xs/:i (arg/base/:axis + arg/delta/:axis - (w - prev))
                ) / r
                face/facets/(sizes/3)/:j: (max
                    ms/:j
                    min
                    xs/:j (pn - t)
                ) / r
                unless face/facets/old-hints [
                    face/facets/old-hints: reduce face/facets/hints: bind [
                        min-hint
                        max-hint
                        init-hint
                    ] face/facets
                    set face/facets/hints 'keep
                ]
                update-face/content face
            ]
            on-content: [
                switch arg/1 [
                    clear [
                        clear select face/facets 'dividers
                        clear at face/gob arg/3
                        if trigger-faces: select face 'trigger-faces [clear trigger-faces]
                        bind-faces face
                        apply :update-face [face arg/2 true]
                    ]
                    insert [
                        content: arg/3
                        index: arg/4
                        trigs: none
                        dividers: clear []
                        remove-each f content [
                            either object? f [
                                if t: select f/facets 'triggers [
                                    unless trigs [
                                        trigs: make block! 2
                                    ]
                                    append trigs f
                                ]
                                if any [none? t find t 'visible-trigger] [
                                    insert at face/gob index f/gob
                                    ++ index
                                ]
                                false
                            ] [
                                switch f [
                                    divider [
                                        append dividers index - 1
                                    ]
                                ]
                                true
                            ]
                        ]
                        unless empty? dividers [
                            if dividers: face/intern/make-dividers face dividers [
                                unless get-facet face 'dividers [set-facet face 'dividers copy []]
                                append face/facets/dividers dividers
                            ]
                        ]
                        bind-faces face
                        do-actor content 'on-init none
                        all [
                            trigs
                            extend-face face 'trigger-faces trigs
                            do-actor trigs 'on-init none
                        ]
                        do-triggers/no-recursive face 'load
                        apply :update-face [face arg/2 true]
                    ]
                    remove [
                        index: arg/3
                        range: arg/4
                        if trigger-faces: select face 'trigger-faces [
                            foreach g apply :copy [at face/gob/pane index range range] [
                                if f: find trigger-faces g/data [remove f]
                            ]
                        ]
                        apply :remove [at face/gob index range range]
                        if get-facet face [layout-mode: dividers:] [
                            end: index + range
                            r: 0
                            remove-each d dividers [
                                all [
                                    d/id >= index
                                    d/id < end
                                    ++ r
                                ]
                            ]
                            forall dividers [
                                dividers/1: either index < id: dividers/1/id [dividers/1: id - r] [id]
                            ]
                            set-facet face 'dividers face/intern/make-dividers face dividers
                        ]
                        bind-faces face
                        apply :update-face [face arg/2 true]
                    ]
                ]
            ]
        ]
    ]
    vpanel: hpanel [
        facets: [
            layout-mode: 'vertical
        ]
    ]
    htight: hpanel [
        about: {Tightly spaced and packed group. No background or borders. Horizontal default.}
        tags: [layout]
        facets: [
            box-model: 'tight
        ]
    ]
    vtight: htight [
        facets: [
            layout-mode: 'vertical
        ]
    ]
    tight: vtight []
    backdrop: hpanel [
        facets: [
            bg-color: 200.200.200
            padding: [5x5 5x5]
            break-after: 1
        ]
        actors: [
            on-make: [
                make-layout face 'panel
                unless any [face/facets/border-color face/facets/dividers] [
                    face/gob/color: get-facet face 'bg-color
                ]
            ]
        ]
    ]
    tooltip: [
        about: "Fake style."
        tags: [internal]
        facets: []
        actors: []
    ]
    pad: [
        about: "Padding for blank spaces."
        facets: [
            init-size: 10x10
            bg-color: none
        ]
        options: [
            init-size: [pair!]
        ]
    ]
    when: [
        about: "A special style for defining layout triggers."
        facets: [
            triggers: []
        ]
        options: [
            triggers: [block!] "Trigger words"
        ]
    ]
    data: [
        about: "A special style for storing data."
        tags: [state]
        options: [
            block: [block!]
        ]
        actors: [
            on-init: [
                show-face/no-show face 'ignored
                face/state/value: reduce any [get-facet face 'block []]
            ]
        ]
    ]
    embed: data [
        about: {A special style for including data values in SUBMIT.}
        tags: [edit]
    ]
    tags: when [
        about: {A special style that defines tags for the previously laid out face.}
        options: [
            block: [block!] "Block will REDUCE immediately"
        ]
        facets: [
            triggers: [load]
        ]
        actors: [
            on-init: [
                probe face/gob/parent
                probe get-facet face 'block
            ]
        ]
    ]
    scroll-pane: vtight [
        tags: [internal]
        facets: [
            init-hint: 'auto
            min-hint: 'init
            max-hint: 'auto
        ]
    ]
    plane: vtight [
        about: {A lean sub-layout used as a scroll frame. No internal resizing.}
        tags: [internal]
        options: [
            layout-face: [block! object!]
        ]
        facets: [
            min-hint: 'init
            max-hint: guie/max-pair
            names: true
        ]
        content: [
            sp: scroll-pane
        ]
        actors: [
            on-init: [
                set-face/no-show face get-facet face 'layout-face
            ]
            on-set: [
                if all [arg/1 = 'value arg/2] [
                    apply :set-content [face/names/sp arg/2 none none arg/3]
                    foreach bar select face 'attached [
                        if all [
                            bar/style = 'scroller
                            axis: bar/facets/axis
                            face/gob/1/size/:axis <> 0
                        ] [
                            set-face/no-show/field bar to percent! min 1 face/gob/size/:axis / face/gob/1/size/:axis 'delta
                        ]
                    ]
                ]
            ]
        ]
    ]
    scroll-panel: hgroup [
        facets: [
            names: true
            init-hint: 400x300
            min-hint: 26x26
            max-hint: guie/max-pair
            hide-scrollers: yes
        ]
        content: [
            pl: plane on-resize [
                do-actor/style face 'on-resize arg 'plane
                do-actor parent-face? face 'on-show-scrollers false
            ]
            v-scroller: scroller #v
            return
            h-scroller: scroller #h
        ]
        options: [
            init-hint: [pair!]
            layout-face: [block! object!]
        ]
        actors: [
            on-init: [
                set-face/no-show face any [get-facet face 'layout-face []]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        all [
                            pair? face/facets/init-hint
                            face/names/pl/facets/init-hint: face/facets/init-hint - 30
                        ]
                        all [
                            pair? face/facets/min-hint
                            face/names/pl/facets/min-hint: face/facets/min-hint - 30
                        ]
                        apply :set-face [face/names/pl arg/2 arg/3]
                    ]
                    h-scroll [apply :set-face [face/names/h-scroller arg/2 arg/3]]
                    v-scroll [apply :set-face [face/names/v-scroller arg/2 arg/3]]
                ]
                apply :update-face [face arg/3]
            ]
            on-get: [
                switch arg [
                    value [
                        get-face face/names/pl
                    ]
                    h-scroll [
                        get-face face/names/h-scroller
                    ]
                    v-scroll [
                        get-face face/names/v-scroller
                    ]
                ]
            ]
            on-resize: [
                do-actor face 'on-show-scrollers true
                do-actor/style face 'on-resize arg 'hgroup
            ]
            on-show-scrollers: [
                if get-facet face 'hide-scrollers [
                    apply :show-face [face/names/h-scroller either 100% = face/names/h-scroller/state/delta ['ignored] ['visible] arg]
                    apply :show-face [face/names/v-scroller either 100% = face/names/v-scroller/state/delta ['ignored] ['visible] arg]
                    update-face/no-show/content face
                ]
            ]
        ]
    ]
]
stylize [
    clicker: [
        about: {Single-action button without text. Basis of other styles.}
        tags: [internal]
        facets: [
            init-size: 28x28
            bg-color: 80.100.120
            border-color: 0.0.0.127
            pen-color:
            area-fill:
            material: 'chrome
            focus-color: guie/colors/focus
            draw-mode: 'normal
            materials: none
            face-width: none
        ]
        options: [
            face-width: [integer!]
            init-size: [pair!]
            bg-color: [tuple!]
        ]
        state: [
            validity: none
        ]
        draw: [
            normal: [
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
                box 1x1 (viewport-box/bottom-right - 2) 1
            ]
            focus: [
                fill-pen focus-color
                box -1x-1 viewport-box/bottom-right 5
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
                box 1x1 (viewport-box/bottom-right - 2) 1
            ]
        ]
        actors: [
            on-make: [
                if face/facets/face-width [
                    face/facets/init-size/x: face/facets/min-size/x: face/facets/max-size/x: face/facets/face-width
                ]
            ]
            on-init: [
                set-facet face 'materials make-material face get-facet face 'material
            ]
            on-draw: [
                set-material face face/state/mode
                color: get-facet face 'border-color
                if face/state/mode = 'over [
                    color: color / 2
                    color/4: 255 - color/4
                ]
                face/facets/pen-color: color
                arg
            ]
            on-over: [
                face/state/mode: pick [over up] face/state/over: not not arg
                draw-face face
            ]
            on-click: [
                face/state/mode: arg/type
                if 'up = face/state/mode [face/state/mode: 'over]
                draw-face face
                if arg/type = 'up [
                    focus face
                    do-face face
                ]
                true
            ]
            on-focus: [
                set-facet face 'draw-mode either get arg/1 ['focus] ['normal]
                set-facet face 'focus-color either get arg/1 [guie/colors/focus] [255.255.255.0]
                draw-face face
            ]
            on-key: [
                if arg/type = 'key [
                    switch arg/key [
                        #" " [
                            do-face face
                        ]
                    ]
                ]
            ]
            on-validate: [
                face/state/validity: validate-face face
            ]
        ]
    ]
    button: clicker [
        about: "Single action button with text."
        tags: [action tab]
        facets: [
            init-size: 130x24
            text: "Button"
            text-style: 'button
            max-size: 260x24
            min-size: 24x24
            text-size-pad: 20x0
        ]
        options: [
            text: [string! block!]
            bg-color: [tuple!]
            init-size: [pair!]
            face-width: [integer! issue!]
        ]
        actors: [
            on-make: [
                either face/facets/face-width = #auto [
                    face/facets/max-size:
                    face/facets/init-size: face/facets/text-size-pad + as-pair first font-text-size? face-font? face face/facets/text 24
                ] [
                    do-actor/style face 'on-make arg 'clicker
                ]
            ]
            on-set: [
                if arg/1 = 'value [
                    face/facets/text: form any [arg/2 ""]
                    show-later face
                ]
            ]
            on-get: [
                if arg = 'value [
                    face/facets/text
                ]
            ]
            on-draw: [
                t: get-facet face 'text
                l: limit-text-size copy/deep t face/gob/size - face/facets/text-size-pad face-font? face
                set-facet face 'text-body either equal? t l [t] [join l "..."]
                do-actor/style face 'on-draw arg 'clicker
            ]
        ]
    ]
    toggle: button [
        about: "Dual action button with text and LED indicator."
        tags: [action tab]
        facets: [
            led-colors: reduce [green coal]
            text: "Toggle"
            led-color: none
            material: 'aluminum
        ]
        options: [
            text: [string! block!]
            bg-color: [tuple!]
            orig-state: [logic!]
            init-size: [pair!]
        ]
        draw: [
            normal: [
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
                box 1x1 (gob/size - 2) 1
                line-width 0.4
                fill-pen led-color
                box 7x7 (gob/size - 7 * 0x1 + 12x0) 1
            ]
            focus: [
                fill-pen focus-color
                box -1x-1 viewport-box/bottom-right 5
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
                box 1x1 (gob/size - 2) 1
                line-width 0.4
                fill-pen led-color
                box 7x7 (gob/size - 7 * 0x1 + 12x0) 1
            ]
        ]
        actors: [
            on-init: [
                face/state/value: true? get-facet face 'orig-state
                make-material face get-facet face 'material
            ]
            on-set: [
                if arg/1 = 'value [face/state/value: true? arg/2]
            ]
            on-get: [
                face/state/value
            ]
            on-clear: [
                set-face face false
            ]
            on-draw: [
                face/facets/led-color: pick get-facet face 'led-colors not not face/state/value
                do-actor/style face 'on-draw arg 'button
            ]
            on-click: [
                if arg/type = 'up [
                    focus face
                    set-face face not face/state/value
                    do-face face
                ]
                true
            ]
            on-key: [
                if all [arg/type = 'key arg/key = #" "] [
                    set-face face not face/state/value
                    do-face face
                ]
            ]
        ]
    ]
    check: toggle [
        tags: [state tab]
        facets: [
            init-size: 300x10
            max-size: 2000x24
            led-colors: reduce [leaf 50.50.50.55]
            text-style: 'radio
            auto-wide: 0x0
            text: "Check"
            focus-color: 255.255.255.0
        ]
        draw: [
            line-width 0
            fill-pen focus-color
            translate (as-pair 3 gob/size/y - 13 / 2)
            box -2x-2 14x14 3
            pen pen-color
            line-width 1
            fill-pen snow
            box 0x0 11x11
            line-width 2
            pen led-color
            fill-pen led-color
            polygon 1x4 5x10 12x-1 5x6 1x3
            reset-matrix
        ]
        actors: [
            on-make: [
                if all [
                    s: get-facet face 'auto-wide
                    not select face/options 'init-size
                ] [
                    set-facet face 'text-body face/facets/text
                    set-facet face 'init-size max face/facets/min-size min face/facets/max-size s + size-text-face face 2000x100
                ]
            ]
            on-focus: [
                do-actor/style face 'on-focus arg 'toggle
                do-related face 'on-mutex-focus
            ]
            on-mutex-focus: [
                if face <> arg [
                    do-actor/style face 'on-focus reduce [false none] 'toggle
                ]
            ]
        ]
    ]
    radio: check [
        tags: [state tab]
        facets: [
            related: none
            text: "Radio"
            auto-wide: 0x0
            max-size: 2000x30
        ]
        options: [
            text: [string! block!]
            bg-color: [tuple!]
            orig-state: [logic!]
            init-size: [pair!]
            related: [money!]
        ]
        draw: [
            pen none
            line-width 0
            fill-pen focus-color
            translate (as-pair 3 gob/size/y - 12 / 2)
            circle 5.5x5.5 7.8
            pen pen-color
            line-width 1.5
            fill-pen snow
            circle 5x5 5.6
            line-width 0.1
            fill-pen led-color
            circle 5x5 2.5
            reset-matrix
        ]
        actors: [
            on-click: [
                if arg/type = 'up [
                    focus face
                    set-face face true
                    do-face face
                ]
                true
            ]
            on-set: [
                do-actor/style face 'on-set arg 'check
                either face/facets/related [
                    do-related/deep/from face 'on-mutex window-face? face
                ] [
                    do-related face 'on-mutex
                ]
            ]
            on-key: [
                if all [arg/type = 'key arg/key = #" "] [
                    set-face face true
                    do-face face
                ]
            ]
            on-mutex: [
                if all [
                    face <> arg
                    arg/facets/related = face/facets/related
                    face/state/value
                ] [
                    do-actor/style face 'on-set reduce ['value false] 'check
                    draw-face face
                ]
            ]
        ]
    ]
    arrow-button: clicker [
        about: "Single action button with arrow (but no text)."
        facets: [
            init-size:
            min-size:
            max-size: 20x20
            arrow-color: snow
            angle: 0
            material: 'aluminum
            center-point: none
        ]
        options: [
            init-size: [pair!]
            bg-color: [tuple!]
            angle: [integer!]
        ]
        draw: [
            pen pen-color
            line-width 1.3
            grad-pen cubic 1x1 0 40 area-fill
            box 1x1 (gob/size - 2) 3
            transform angle 0.7 0.7 0x0 center-point
            pen arrow-color
            line-width 2.7
            line-cap rounded
            line -6x5 0x-5 6x5 0x-1 -6x5
        ]
        actors: [
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                face/facets/center-point: face/facets/gob-size - 2 / 2
            ]
        ]
    ]
    drop-down: button [
        about: "Drop-down test."
        tags: [tab state]
        facets: [
            text-style: 'dropdown
            text?: true
            area-fill: none
            arrow-center: 0x0
            pen-color: none
            text-size-pad: 40x0
        ]
        options: [
            list-data: [block!]
            value: [integer!]
        ]
        state: [
            value: [string!]
            validity: [word!]
        ]
        draw: [
            normal: [
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 40 90 area-fill
                box 1x1 (viewport-box/bottom-right - 2) 1
                transform 180 0.6 0.6 0x0 arrow-center
                pen border-color
                line-width 1
                line-cap rounded
                polygon -12x10 0x-10 12x10
                line-width 1
                line 20x12 20x-12
                reset-matrix
                translate -20x0
            ]
            focus: [
                fill-pen focus-color
                box -1x-1 viewport-box/bottom-right 5
                pen pen-color
                line-width 1
                grad-pen linear 1x1 0 40 90 area-fill
                box 1x1 (viewport-box/bottom-right - 2) 1
                transform 180 0.6 0.6 0x0 arrow-center
                pen border-color
                line-width 1
                line-cap rounded
                polygon -12x10 0x-10 12x10
                line-width 1
                line 20x12 20x-12
                reset-matrix
                translate -20x0
            ]
        ]
        actors: [
            on-make: [
                if none? get-facet face 'value [set-facet face 'value 1]
                if none? get-facet face 'list-data [set-facet face 'list-data ["No data set!"]]
            ]
            on-draw: [
                set-facet face 'text any [pick get-facet face 'list-data get-facet face 'value "No data set!"]
                do-actor/style face 'on-draw arg 'button
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                face/facets/arrow-center: face/gob/size - 15x12
            ]
            on-set: [
                switch arg/1 [
                    data [
                        set-facet face 'list-data arg/2
                        face/state/value: set-facet face 'value 1
                    ]
                    value [
                        get-facet face [list-data:]
                        unless empty? list-data [
                            face/state/value: set-facet face 'value max 1 min length? list-data arg/2
                            if get-facet face 'text? [set-facet face 'text-body pick list-data face/state/value]
                        ]
                    ]
                ]
                apply :draw-face [face arg/3]
            ]
            on-get: [
                switch arg [
                    value [
                        get-facet face 'value
                    ]
                    data [
                        get-facet face 'list-data
                    ]
                ]
            ]
            on-clear: [
                set-face face 1
            ]
            on-key: [
                if all [arg/type = 'key arg/key = #" "] [
                    do-actor face 'on-open arg
                ]
                arg
            ]
            on-click: [
                if arg/type = 'up [
                    focus face
                    do-actor face 'on-open arg
                ]
                true
            ]
            on-open: [
                ld: get-facet face 'list-data
                popup: show-popup [
                    ld: text-list ld on-action [
                        do-popup-parent 'on-set reduce ['value arg]
                        hide-popup
                    ] options [max-size: 2000x3000]
                    when [enter] on-action [wait 0.001 focus ld]
                ] face
            ]
        ]
    ]
    drop-arrow: drop-down [
        tags: [internal]
        facets: [
            init-size: 20x20
            max-size: 20x20
            min-size: 20x20
            arrow-color: black
            bg-color: 200.210.220
            material: 'aluminum
            text-body: none
            text?: no
        ]
        draw: [
            pen pen-color
            line-width 1
            grad-pen linear 1x1 0 (viewport-box/bottom-right/y) 90 area-fill
            box 1x1 (viewport-box/bottom-right - 2) 1
            transform 180 0.7 0.7 0x0 (viewport-box/bottom-right / 2)
            pen arrow-color
            fill-pen arrow-color
            line-cap rounded
            polygon -6x5 0x-5 6x5
        ]
        actors: [
            on-draw: [
                set-material face face/state/mode
                color: get-facet face 'border-color
                if face/state/mode = 'over [
                    color: color / 2
                    color/4: 255 - color/4
                ]
                face/facets/pen-color: color
                arg
            ]
            on-get: [
                face/state/value
            ]
        ]
    ]
    tab-button: clicker [
        about: "Tab button. For internal use."
        tags: [internal state]
        facets: [
            init-size: 70x20
            max-size: 120x20
            min-size: 50x20
            text-style: 'sbutton
            led-colors: reduce [green coal red]
            material: 'aluminum
            bg-color: 200.210.220
            passive-color: 200.210.220
            active-color: 220.230.240
            led-color: none
        ]
        options: [
            text-body: [string! block!]
            id: [tag!]
            layout: [issue!]
            active: [logic!]
        ]
        actors: [
            on-make: [
                face/state/value: get in face/options 'active
                face/state/mode: none
                mode: get-facet face 'layout
                if none? mode [mode: 'top]
            ]
            on-draw: [
                set-material face face/state/mode
                color: get-facet face 'border-color
                face/facets/led-color: pick get-facet face 'led-colors not not face/state/value
                if face/state/mode = 'over [
                    face/facets/led-color: pick get-facet face 'led-colors 3
                    color: color / 2
                ]
                face/facets/pen-color: color
                arg
            ]
            on-click: [
                if arg/type = 'down [
                    hide-tooltip face
                ]
                if arg/type = 'up [
                    set-face face 'down
                    set-facet face 'bg-color get-facet face 'active-color
                    draw-face face
                    set-face parent-face? face face/name
                ]
                true
            ]
            on-set: [
                either 'value = arg/1 [
                    do-related face 'on-mutex
                    face/state/value: true
                    face/state/mode: arg/2
                    draw-face face
                ] [
                    show-later face
                ]
            ]
            on-mutex: [
                face/state/value: false
                face/state/mode: none
                draw-face face
            ]
            on-over: [
                p: parent-face? face
                face/state/mode: either arg ['over] [
                    either face/state/value ['down] [none]
                ]
                draw-face face
                if face/gob/parent [
                    parent: face/gob/parent/data
                    either arg [
                        buttons: compound-face? face
                        tab-box: compound-face? buttons
                        unless tab-box/style = 'tab-box [exit]
                    ] []
                ]
            ]
            on-drag: [
                face/gob/offset: arg/offset - arg/base
                show face/gob
            ]
            on-drag-over: [
                bar: parent-face? face
                do-actor bar 'on-drag-over reduce [arg/1 face/gob/offset + arg/2 arg/3]
                true
            ]
            on-key: [
                print "onkey button"
                if arg/type = 'key [
                    switch arg/key [
                        left [print "left"]
                        right [print "right"]
                    ]
                ]
            ]
        ]
    ]
]
stylize [
    box: [
        about: "Simple rectangular box."
        facets: [
            init-size: 100x100
            min-size: 10x10
            bg-color: black
        ]
        options: [
            init-size: [pair!]
            bg-color: [tuple!]
        ]
    ]
    bar: box [
        about: "Simple horizontal divider bar."
        facets: [
            init-size: 100x3
            min-size: 20x3
            max-size: 1000x3
        ]
    ]
    div: bar [
        about: "Simple vertical divider bar."
        facets: [
            init-size: 3x10
            min-size: 3x20
            max-size: 3x1000
        ]
    ]
    progress: [
        about: "Progress bar."
        tags: [indicator]
        facets: [
            init-size: 200x22
            max-size: 1000x22
            border-color: 96.96.96
            bg-color: 80.80.80.127
            material: 'radial-aluminum
            bar-size: 1x1
        ]
        options: [
            bg-color: [tuple!]
            init-size: [pair!]
            value: [percent!]
        ]
        draw: [
            pen border-color
            line-width 1
            grad-pen 1x1 0 viewport-box/bottom-right/y 90 materials/down
            box 1x1 (viewport-box/bottom-right - 2) 3
            pen off
            grad-pen linear 1x1 0 viewport-box/bottom-right/y 90 area-fill
            box 2x2 bar-size 3
        ]
        actors: [
            on-make: [
                make-material face get-facet face 'material
                set-material face 'up
                if value: get-facet face 'value [set-face face value]
            ]
            on-set: [
                if number? arg/2 [
                    face/state/value: v: limit to percent! arg/2 000% 100%
                    face/facets/bar-size: as-pair max 2 face/gob/size/x - 2 * v face/gob/size/y - 2
                    apply :draw-face [face arg/3 true]
                ]
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                set-face/no-show face face/state/value
            ]
        ]
    ]
    slider: [
        about: "Slide-bar for numeric input (0% - 100%)"
        tags: [state action tab]
        facets: [
            init-size: 200x22
            min-size: 200x22
            max-size: 1000x22
            border-color: 96.96.96
            bg-color: 80.80.80
            knob-color: gray
            relay: true
            axis: none
            knob-xy:
            bias-xy: 6x0
            slider-size: 0x0
            material: 'radial-aluminum
        ]
        options: [
            init-size: [pair!]
            bg-color: [tuple!]
            knob-color: [tuple!]
            value: [percent!]
        ]
        state: [
            value: [percent!]
            validity: [word!]
        ]
        draw: [
            pen border-color
            line-width 0.4
            grad-pen 1x1 0 10 90 area-fill
            box 1x1 slider-size 3
            line-width 1.3
            fill-pen knob-color
            translate knob-xy
            triangle -6x16 0x2 6x16
        ]
        actors: [
            on-init: [
                set-facet face 'knob-colors reduce [red face/facets/knob-color]
                make-material face get-facet face 'material
                set-material face 'up
                face/state/value: either in face/options 'value [max 000% min 100% face/options/value] [000%]
                face/facets/axis: face-axis? face
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                face/facets/slider-size: arg - 2 * 1x0 + 0x6
                face/facets/axis: face-axis? face
                do-actor face 'on-update none
            ]
            on-update: [
                if face/facets/viewport-box/bottom-right [
                    bias: face/facets/bias-xy
                    size: face/facets/viewport-box/bottom-right - bias - bias
                    val: face/state/value
                    face/facets/knob-xy: val * size * 1x0 + bias
                ]
            ]
            on-offset: [
                bias: face/facets/bias-xy
                arg: max 0x0 arg - bias
                size: face/facets/viewport-box/bottom-right - bias - bias
                axis: pick [x y] 'y = get-facet face 'axis
                face/state/value: val: min 100% max 000% to-percent arg/:axis / size/:axis
                face/facets/knob-xy: val * size * 1x0 + bias
            ]
            on-click: [
                focus face
                if arg/type = 'down [drag: init-drag/only face arg/offset]
                do-actor face 'on-offset arg/offset
                if arg/type = 'down [
                    draw-face face
                    return drag
                ]
                do-face face
                true
            ]
            on-drag: [
                do-actor face 'on-offset arg/delta + arg/base
                draw-face face
                do-face face
            ]
            on-get: [
                if arg = 'value [face/state/value]
            ]
            on-set: [
                if all [
                    'value = first arg
                    number? second arg
                ] [
                    face/state/value: limit second arg 000% 100%
                ]
                do-targets face
                do-actor face 'on-update none
            ]
            on-clear: [
                set-face face 0
            ]
            on-focus: [
                set-facet face 'knob-color pick face/facets/knob-colors arg/1
                draw-face face
            ]
            on-key: [
                if arg/type = 'key [
                    switch/default arg/key [
                        left [set-face face -1% + get-face face]
                        right [set-face face 1% + get-face face]
                    ] [
                        unless e: error? try [
                            n: -1 + to integer! to string! arg/key
                        ] [
                            if -1 = n [n: 9]
                            set-face face to percent! n / 9
                        ]
                    ]
                ]
            ]
            on-validate: [
                face/state/validity: validate-face face
            ]
        ]
    ]
    scroller: [
        about: "Scroll bar with end arrows."
        tags: [action part]
        facets: [
            init-size: 16x16
            min-size: 16x16
            max-size: 16x16
            init-length: none
            orientation: none
            btn-size: 16x16
            length-limit: 50
            all-over: true
            relay: true
            material: 'scroller
            bg-color: 200.233.245
            border-color: 0.0.0.128
            arrow-color: black
            knob-xy:
            knob-size:
            knob-base:
            btn-xy: 0x0
            angles: [0 180]
            axis:
            none
            set-fields: make map! [
                value [
                    all [
                        number? arg/2
                        either percent? arg/2 [
                            true
                        ] [
                            arg/2: to percent! arg/2 / pick face/gob/size face/facets/axis
                        ]
                        face/state/value <> val: limit arg/2 000% 100%
                        face/state/value: val
                        dirty?: true
                    ]
                ]
                delta [
                    if number? arg/2 [
                        unless percent? arg/2 [arg/2: to percent! arg/2 / pick face/gob/size face/facets/axis]
                        face/state/delta: limit arg/2 000% 100%
                        dirty?: true
                    ]
                ]
            ]
            get-fields: make map! [
                value [face/state/value]
                delta [face/state/delta]
            ]
        ]
        options: [
            init-length: [number!]
            orientation: [issue!]
            bg-color: [tuple!]
        ]
        state: [
            value: 000%
            delta: 10%
        ]
        draw: [
            pen border-color
            line-width 1
            grad-pen linear 1x1 0 16 (use 'a [a: angles/1 if a = 270 [a: 90] a]) materials/down
            box 1x1 (viewport-box/bottom-right - 1) 6
            grad-pen linear 1x1 0 16 (use 'a [a: angles/1 if a = 270 [a: 90] a]) materials/up
            box knob-xy (knob-xy + knob-size) 6
            pen false
            transform angles/1 0x0 0.6 0.6 (btn-size / 2)
            pen arrow-color
            line-cap rounded
            fill-pen arrow-color
            polygon -6x5 0x-5 6x5
            reset-matrix
            transform angles/2 0.6 0.6 0x0 (btn-xy - 1 + (btn-size / 2))
            polygon -6x5 0x-5 6x5
        ]
        actors: [
            on-init: [
                if all [
                    not get-facet face 'attached?
                    target: find-face-actor/reverse face 'on-scroll
                ] [
                    attach-face face target
                ]
                set-facet face 'target target
            ]
            on-make: [
                make-material face get-facet face 'material
                set-material face 'up
                if face/facets/orientation [
                    a: face/facets/axis: pick [x y] face/facets/orientation = #h
                    all [
                        face/facets/init-length
                        face/facets/init-size/:a: face/facets/init-length
                    ]
                    face/facets/max-size/:a: guie/max-coord
                    face/facets/min-size/:a: face/facets/length-limit
                ]
            ]
            on-attached: [
                either has-actor? arg/1 'on-scroll [
                    unless arg/2 [
                        do-actor arg/1 'on-scroll face
                    ]
                    false
                ] [
                    do-actor/style face 'on-attached arg 'face
                ]
            ]
            on-resize: [
                size: arg
                unless face/facets/axis [
                    a: pick [x y] size/y < size/x
                    set-facet face 'axis a
                    all [
                        face/facets/init-length
                        face/facets/init-size/:a: face/facets/init-length
                    ]
                    face/facets/max-size/:a: guie/max-coord
                    face/facets/min-size/:a: face/facets/length-limit
                    update-face/no-show face
                    do-targets/custom face [do-actor target 'on-scroll face]
                ]
                do-actor/style face 'on-resize size 'face
                get-facet face [gob-size: btn-size: axis:]
                z: pick [x y] axis = 'y
                face/facets/angles: pick [[0 180] [270 90]] gob-size/y > gob-size/x
                bxy: gob-size - btn-size
                bxy/:z: 1
                face/facets/btn-xy: bxy
                do-actor face 'on-update none
            ]
            on-set: [
                dirty?: false
                if arg/2 [
                    fields: get-facet face 'set-fields
                    if find words-of fields arg/1 [
                        do bind select fields arg/1 'face
                    ]
                    if dirty? [do-actor face 'on-update none]
                ]
            ]
            on-get: [
                fields: get-facet face 'get-fields
                do bind select fields arg 'face
            ]
            on-reset: [
                face/state/value: 000%
                face/state/delta: 10%
            ]
            on-update: [
                get-facet face [btn-size: gob-size: axis:]
                value: face/state/value
                axim: either 'x = axis [1x0] [0x1]
                unless none? gob-size [
                    area: gob-size - (2 * btn-size)
                    knob-size: max 12x12 area * axim * face/state/delta + (reverse axim * 12)
                    knob-xy: area - knob-size * value + btn-size * axim + (reverse axim * 2)
                    set-facet face 'knob-xy knob-xy
                    set-facet face 'knob-size knob-size
                    draw-face face
                ]
                all [
                    act: find-face-actor/reverse face 'on-scroll
                ]
            ]
            on-sense-scroll: [
                get-facet face [gob-size: btn-size: knob-size: knob-xy:]
                axis: face-axis? face
                n: arg/:axis
                k: knob-xy/:axis
                case [
                    n < btn-size/:axis [2]
                    n > (gob-size/:axis - btn-size/:axis) [3]
                    n < k [4]
                    n > (k + knob-size/:axis) [5]
                    true [1]
                ]
            ]
            on-bump-scroll: [
                d: to percent! face/state/delta * arg
                set-face face face/state/value + d
            ]
            on-click: [
                if arg/type = 'down [
                    switch do-actor face 'on-sense-scroll arg/offset [
                        1 [return init-drag/only face face/state/value]
                        2 4 [do-actor face 'on-bump-scroll -1]
                        3 5 [do-actor face 'on-bump-scroll 1]
                    ]
                ]
                true
            ]
            on-drag: [
                axis: get-facet face 'axis
                size: face/facets/gob-size - (2 * face/facets/btn-size) - face/facets/knob-size + 1x1
                scroll-pos: size/:axis * arg/base + arg/delta/:axis
                set-face face max 000% min 100% to percent! scroll-pos / size/:axis
                draw-face face
                do-face face
            ]
            on-delta: [
                print "WARNING: scroller's on-delta called"
                face/state/delta: pick arg 'x = get-facet face 'axis
                if get-facet face 'gob-size [
                    set-face face face/state/value
                    draw-face face
                ]
            ]
            on-scroll-event: [
                if target: get-facet face 'target [
                    do-actor target 'on-scroll-event arg
                ]
                none
            ]
        ]
    ]
]
stylize [
    text: [
        about: "Simple text without background."
        tags: [info]
        facets: [
            text-body: ""
            text-style: 'base
            init-size: #auto
            min-size: none
            max-size: none
            auto-size: false
        ]
        options: [
            text-body: [string! block!]
            text-color: [tuple!]
            init-size: [integer! pair! issue!]
        ]
        actors: [
            on-resize: [
                ff: face/facets
                if ff/auto-size [
                    ff/auto-size: false
                    space: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2
                    ff/min-size: min arg ff/init-size: space + size-text-face face arg
                    ff/max-size: ff/init-size
                    update-face/no-show face
                ]
                do-actor/style face 'on-resize arg 'face
            ]
            on-init: [
                style: face-font? face
                all [
                    a: get-facet face 'text-align
                    a <> style/para/align
                    extend face 'para make any [select face 'para style/para] [align: a]
                ]
                all [
                    v: get-facet face 'text-valign
                    v <> style/para/valign
                    extend face 'para make any [select face 'para style/para] [valign: v]
                ]
                all [
                    not none? w: get-facet face 'text-wrap
                    w <> style/para/wrap?
                    extend face 'para make any [select face 'para style/para] [wrap?: w]
                ]
                all [
                    c: get-facet face 'text-color
                    extend face 'font make any [select face 'font style/font] [color: c]
                ]
                all [
                    s: get-facet face 'text-size
                    extend face 'font make any [select face 'font style/font] [size: s]
                ]
                size: get-facet face 'init-size
                ff: face/facets
                switch type?/word size [
                    none! [
                        size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face guie/max-pair
                        unless ff/min-size [ff/min-size: size]
                        unless ff/max-size [ff/max-size: as-pair guie/max-coord size/y]
                        ff/init-size: size
                        size
                    ]
                    issue! [
                        ff/auto-size: true
                        text-size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face guie/max-pair
                        unless ff/min-size [ff/min-size: as-pair 0 text-size/y]
                        unless ff/max-size [ff/max-size: guie/max-pair]
                        ff/init-size: min ff/max-size 10000x10000
                    ]
                    integer! [
                        text-size: ff/margin/1 + ff/border-size/1 + ff/padding/1 + ff/margin/2 + ff/border-size/2 + ff/padding/2 + size-text-face face as-pair size guie/max-coord
                        size: as-pair size text-size/y
                        unless ff/min-size [ff/min-size: size]
                        unless ff/max-size [ff/max-size: size]
                        ff/init-size: size
                    ]
                    pair! [
                        unless ff/min-size [ff/min-size: size]
                        unless ff/max-size [ff/max-size: size]
                    ]
                ]
            ]
            on-get: [
                if arg = 'value [
                    face/facets/text-body
                ]
            ]
            on-set: [
                if arg/1 = 'value [
                    data: any [arg/2 ""]
                    face/facets/text-body: either block? data [data] [form data]
                ]
            ]
        ]
    ]
    title: text [
        about: "Title text style without background."
        facets: [
            text-style: 'title
        ]
    ]
    head-bar: text [
        about: "Boxed text bar for headings."
        facets: [
            init-size: none
            margin: [1x1 1x1]
            bar-color: 255.255.255.155
            edge-color: 80.80.80.155
            text-style: 'head-bar
        ]
        options: [
            text-body: [string! block!]
            bar-color: [tuple!]
            text-color: [tuple!]
            init-size: [pair! integer! issue!]
        ]
        draw: [
            pen edge-color
            line-width 1.3
            fill-pen bar-color
            box padding-box/top-left (padding-box/bottom-right - 1) 2
        ]
    ]
    label: text [
        about: "Label text without background."
        facets: [
            text-style: 'label
            align: 'right
            valign: 'middle
        ]
    ]
    text-item: text [
        tags: [state tab internal]
        facets: [
            init-size: 100x18
            max-size: 2000x18
            min-size: 40x18
            bg-color: 255.255.255.155
            edge-color: black
            edge-width: 0.1
            text-style: 'list-item
            related: 'on-mutex
            margin: [2x0 2x0]
            material: 'piano
        ]
        options: [
            text-body: [string! block!]
            bg-color: [tuple!]
        ]
        draw: [
            pen edge-color
            line-width edge-width
            grad-pen linear 1x1 0 viewport-box/bottom-right/y 90 area-fill
            box 1x1 (viewport-box/bottom-right - 1)
        ]
        actors: [
            on-make: [
                face/facets/init-size: face/facets/min-size: face/facets/max-size: 4x0 + size-text-face face 800x600
            ]
            on-init: [
                make-material face get-facet face 'material
            ]
            on-set: [
                all [
                    arg/1 = 'value
                    face/state/value: true? arg/2
                    set-facet face 'edge-width 2
                    parent-face: face/gob/parent/data
                    parent-face/state/value: index? find faces? parent-face face
                ]
                show-later face
            ]
            on-click: [
                focus face/gob/parent/data
                if arg/type = 'up [
                    set-face face true
                    do-face face
                ]
                true
            ]
            on-draw: [
                set-material face face/state/mode
                arg
            ]
            on-mutex: [
                if all [
                    face <> arg
                    face/state/value
                    all [
                        not find select face 'reactors 'of
                    ]
                ] [
                    set-facet face 'edge-width 0.1
                    set-face face false
                ]
            ]
        ]
    ]
    text-area: [
        about: {General text input area, editable, scrollable, without background.}
        tags: [internal edit]
        facets: [
            init-size: 200x120
            text-edit: ""
            lines: true
            text-style: 'area
            hide-input: false
            detab: false
        ]
        options: [
            init-size: [pair!]
            text-edit: [string! block!]
            text-color: [tuple!]
        ]
        state: [
            cursor:
            mark-head:
            mark-tail:
            caret: none
            xpos: none
            validity: none
        ]
        actors: [
            on-init: []
            on-make: [
                if face/facets/detab [
                    tag-face face 'detab
                ]
                extend face 'attached copy []
                if c: get-facet face 'text-color [
                    style: face-font? face
                    extend face 'font make style/font [color: c]
                ]
                face/state/value: face/facets/text-edit: copy face/facets/text-edit
                init-text-caret face
                append face/gob gob: make-text-gob face face/gob/size "empty"
                gob/offset: (first get-facet face 'margin) + (first get-facet face 'border-size) + (first get-facet face 'padding)
                do-actor face 'on-update none
            ]
            on-update: [
                gob: sub-gob? face
                either block? face/facets/text-edit [
                    change clear skip find get-gob-text/src gob 'caret 2 to-text face/facets/text-edit clear []
                ] [
                    change back tail get-gob-text/src gob either face/facets/hide-input [append/dup clear "" "*" length? face/facets/text-edit] [face/facets/text-edit]
                ]
            ]
            on-resize: [
                do-actor/style face 'on-resize arg 'face
                face/gob/1/offset: face/facets/space/1
                face/gob/1/size: face/facets/viewport-box/bottom-right - face/facets/viewport-box/top-left
                do-attached/custom face [
                    scroller [
                        vals: face-text-size face
                        set-face/no-show attached vals/1
                        set-face/no-show/field attached vals/2 'delta
                    ]
                ]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        face/state/cursor: change clear face/facets/text-edit reform any [face/state/value: arg/2 ""]
                        clear-text-caret face
                        select-none face/state
                        do-actor face 'on-update none
                        if guie/focal-face = face [update-text-caret face]
                        do-actor face 'on-resize face/gob/size
                    ]
                    locate [
                        goto-caret face arg/2
                        see-caret face
                        do-attached/custom face [
                            scroller [
                                vals: face-text-size face
                                set-face/no-show attached vals/1
                                set-face/no-show/field attached vals/2 'delta
                            ]
                        ]
                        show-later face
                    ]
                ]
                do-attached face
            ]
            on-get: [
                if arg = 'value [
                    face/facets/text-edit
                ]
            ]
            on-clear: [
                clear face/facets/text-edit
                show-later face
            ]
            on-scroll: [
                gob: sub-gob? face
                scroll: get-gob-scroll gob
                size: gob/size - scroll
                tsize: size-txt gob
                scroll/y: min 0 arg/state/value * negate tsize/y - gob/size/y + 5
                set-gob-scroll gob scroll
                show-later face
            ]
            on-key: [
                if arg/type = 'key [
                    do-text-key face arg arg/key
                    if guie/focal-face = face [
                        update-text-caret face
                        see-caret face
                        do-attached/custom face [
                            scroller [
                                vals: face-text-size face
                                set-face/no-show attached vals/1
                                set-face/no-show/field attached vals/2 'delta
                            ]
                        ]
                        show-later face
                    ]
                ]
            ]
            on-scroll-event: [
                d: none
                if bars: select face 'attached [
                    foreach bar bars [
                        axis: get-facet bar 'axis
                        switch arg/type [
                            scroll-line [d: arg/offset/:axis / -30]
                            scroll-page [d: negate arg/offset/:axis]
                        ]
                        if d [
                            do-actor first bars 'on-bump-scroll d
                        ]
                    ]
                ]
                none
            ]
            on-click: [
                clear-all-carets window-face? face
                either system/version/4 = 13 [
                    cur: oft-to-caret tg: sub-gob? face arg/offset - get-gob-scroll tg
                    if cur [
                        switch arg/type [
                            down [
                                if guie/focal-face = face [
                                    click-text-face face cur arg
                                    return init-drag/only face arg/offset
                                ]
                            ]
                            up [
                                unless guie/drag/active [
                                    click-text-face face cur arg
                                    show-soft-keyboard/attach guie/focal-face/gob
                                ]
                            ]
                        ]
                    ]
                ] [
                    if all [
                        arg/type = 'down
                        cur: oft-to-caret tg: sub-gob? face arg/offset - get-gob-scroll tg
                    ] [
                        click-text-face face cur arg
                        return init-drag/only face arg/offset
                    ]
                ]
                true
            ]
            on-drag: [
                if all [
                    arg/event/gob = tg: sub-gob? face
                    cur: oft-to-caret tg arg/event/offset - get-gob-scroll tg
                ] [
                    state: face/state
                    unless state/mark-head [state/mark-head: state/cursor]
                    state/mark-tail: state/cursor: first cur
                    update-text-caret face
                    see-caret face
                    do-attached/custom face [
                        scroller [
                            vals: face-text-size face
                            set-face/no-show attached vals/1
                            set-face/no-show/field attached vals/2 'delta
                        ]
                    ]
                    show-later face
                ]
            ]
            on-focus: [
                either arg/1 [
                    unless face/state/cursor [
                        face/state/cursor: tail face/facets/text-edit
                    ]
                    update-text-caret face
                ] [
                    clear-text-caret face
                ]
                show-later face
                none
            ]
            on-reset: [
                txt: get-gob-text/src face/gob
                clear last txt
                show-later face
                none
            ]
            on-set-bg-color: [
                if none? arg [arg: get-facet face 'bg-color]
                make-material/color face get-facet face 'material arg
                set-material face 'up
                draw-face/now face
            ]
        ]
    ]
    text-box: text-area [
        about: "Text area with background box."
        tags: [edit tab]
        facets: [
            bg-color: snow
            margin: [3x3 3x3]
            padding: [3x3 3x3]
            draw-mode: 'normal
            area-fill:
            material: 'field-groove
            focus-color: guie/colors/focus
        ]
        options: [
            init-size: [pair!]
            text-edit: [string! block!]
            bg-color: [tuple!]
            text-color: [tuple!]
        ]
        draw: [
            normal: [
                pen black
                grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
                box padding-box/top-left (padding-box/bottom-right - 1)
            ]
            focus: [
                fill-pen focus-color
                box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 5
                fill-pen none
                pen black
                grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
                box padding-box/top-left (padding-box/bottom-right - 1)
            ]
        ]
        actors: [
            on-init: [
                do-actor/style face 'on-init arg 'text-area
                make-material/facet face get-facet face 'material 'bg-color
                set-material face 'up
            ]
            on-focus: [
                set-facet face 'draw-mode either arg/1 ['focus] ['normal]
                set-facet face 'focus-color either arg/1 [guie/colors/focus] [255.255.255.0]
                draw-face face
                do-actor/style face 'on-focus arg 'text-area
            ]
        ]
    ]
    field: text-box [
        about: {Single line text input, editable, with background box.}
        facets: [
            init-size: 130x26
            max-size: 2000x26
            min-size: 26x26
            lines: false
            text-style: 'field
            padding: [3x3 3x0]
        ]
        options: [
            init-size: [integer!]
            text-edit: [string! block!]
            bg-color: [tuple!]
            text-color: [tuple!]
        ]
        actors: [
            on-init: [
                if integer? face/facets/init-size [
                    face/facets/init-size: as-pair face/facets/init-size 26
                ]
                do-actor/style face 'on-init arg 'text-box
            ]
            on-validate: [
                face/state/validity: validate-face face
                set-facet face 'border-color switch face/state/validity [
                    skipped [snow]
                    required [white]
                    not-required [snow]
                    invalid [red]
                    valid [green]
                ]
                draw-face face
                set-face arg face/state/validity
            ]
            on-focus: [
                set-facet face 'draw-mode either arg/1 ['focus] ['normal]
                set-facet face 'focus-color either arg/1 [guie/colors/focus] [255.255.255.0]
                either arg/1 [
                    either arg/2 [
                        update-text-caret face
                    ] [
                        face/state/cursor: first back tail get-gob-text sub-gob? face
                        select-all face
                    ]
                ] [
                    clear-text-caret face
                ]
                draw-face face
                show-later face
                none
            ]
        ]
    ]
    info: text-area [
        about: "Text information fields, non-editable."
        tags: [tab select]
        facets: [
            margin: [3x3 3x3]
            padding: [3x2 3x2]
            init-size: 100x26
            max-size: as-pair guie/max-coord 26
            min-size: 20x26
            lines: false
            text-style: 'info
            edge-color: 100.100.100.55
            area-color: 240.240.240.105
        ]
        options: [
            init-size: [pair!]
            text-edit: [string! block!]
            text-color: [tuple!]
        ]
        draw: [
            clip margin-box/top-left margin-box/bottom-right
            pen edge-color
            line-width 1.5
            fill-pen area-color
            box padding-box/top-left (padding-box/bottom-right - 1) 1
        ]
    ]
    code: info [
        about: "Source code fields, non-editable."
        facets: [
            text-style: 'code
            edge-color: 0.0.0.55
            area-color: 240.240.240
        ]
    ]
    area: htight [
        about: {Multi-line text input, editable, scrollable, with background and scrollbars.}
        facets: [
            break-after: 2
            bg-color: snow
            init-size: 400x200
            names: true
        ]
        options: [
            text-edit: [string! block!]
            bg-color: [tuple!]
            init-size: [pair!]
        ]
        content: [
            text-box: text-box :text-edit :bg-color :init-size on-key [
                do-actor parent-face? face 'on-key arg
            ] options [text-style: :text-style detab: :detab]
            scroller: scroller
        ]
        actors: [
            on-set: [
                do-actor first f: faces? face 'on-set arg
                if arg/1 = 'value [
                    apply :set-face [f/2 000% arg/3]
                ]
            ]
            on-get: [
                get-face first faces? face
            ]
            on-focus: [
                all [
                    arg/1
                    focus face/names/text-box
                ]
            ]
            on-key: [
                do-actor/style face/names/text-box 'on-key arg 'text-box
            ]
        ]
    ]
    code-area: area [
        about: {Multi-line code input, editable, scrollable, with background and scrollbars.}
        content: [
            code :text-edit options [
                init-size: 200x200
                max-size: guie/max-pair
            ]
            scroller
        ]
    ]
    info-area: area [
        about: {Multi-line text info, non-editable, scrollable, scrollbars.}
        content: [
            info :text-edit options [
                init-size: 200x120
                max-size: guie/max-pair
                text-style: 'info-area
            ]
            scroller
        ]
    ]
    tag-field: field [
        about: {Special kind of FIELD style for use in TAG-AREA. Adds oval and closing cross to text after editing.}
        tags: [edit tab internal]
        facets: [
            close-color: black
            all-over: true
            original-tags: none
            original-title: none
        ]
        draw: [
            normal: [
                pen black
                grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
                box padding-box/top-left (padding-box/bottom-right - 1) 6
                pen close-color
                line-width 3
                line (viewport-box/top-right - 14x-2) (viewport-box/bottom-right - 5)
                line (viewport-box/top-right - 5x-2) (viewport-box/bottom-right - 14x5)
            ]
            focus: [
                fill-pen focus-color
                box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 5
                fill-pen none
                pen black
                grad-pen linear (padding-box/top-left + 1) -2 10 90 area-fill
                box padding-box/top-left (padding-box/bottom-right - 1)
            ]
        ]
        actors: [
            on-key: [
                do-actor/style face 'on-key arg 'field
                if arg/type = 'key-up [
                    switch arg/key [
                        #"^[" #"^M" [
                            p: compound-face? face
                            do-actor face 'on-update-tag none
                            focus p
                        ]
                    ]
                ]
            ]
            on-update-tag: [
                p: compound-face? face
                title: trim get-face face
                tags: get-face p
                either any [
                    empty? title
                    find face/facets/original-tags title
                ] [
                    set-face p face/facets/original-tags
                ] [
                    update-face p
                ]
                p/facets/edit-mode: false
                get-facet face [original-title:]
                diff: first difference face/facets/original-tags get-face p
                result: either diff [
                    either all [
                        original-title
                        diff <> original-title
                    ] [['set diff 'unset original-title]] [['set diff]]
                ] [
                    either original-title [['unset original-title]] [
                        none
                    ]
                ]
                if result [do-actor p 'on-action reduce result]
            ]
            on-focus: [
                do-actor/style face 'on-focus arg 'field
                either arg/1 [
                    title: get-face face
                    set-facet face 'original-tags difference get-face compound-face? face reduce [title]
                    set-facet face 'original-title all [not empty? title copy title]
                ] [
                    do-actor face 'on-update-tag none
                ]
            ]
            on-over: [
                do-actor/style face 'on-over arg 'field
                get-facet face [viewport-box: close-color:]
                color: either all [arg arg/x > (viewport-box/top-right/x - 16)] [red] [black]
                unless equal? color close-color [
                    set-facet face 'close-color color
                    draw-face face
                ]
            ]
            on-click: [
                either all [arg arg/offset/x > (face/facets/viewport-box/top-right/x - 16)] [
                    if arg/type = 'up [
                        p: compound-face? face
                        p/intern/remove-tag face
                        update-face p
                        do-actor p 'on-action reduce ['unset get-face face]
                    ]
                ] [
                    if arg/type = 'down [
                        p: compound-face? face
                        if p/facets/edit-mode [unfocus exit]
                    ]
                    do-actor/style face 'on-click arg 'field
                ]
            ]
        ]
    ]
    tag-area: hpanel [
        about: "Area of TAG-FIELDs."
        facets: [
            names: true
            border-color: black
            border-fsize: [1x1 1x1]
            draw-mode: 'normal
            bg-color: 220.220.220
            edit-mode: false
            tags: []
        ]
        options: [
            tags: [block!]
        ]
        tags: [tab eat-tab compound]
        content: [
            tags: hgroup :init-size
            options [names: true spacing: 0x0 padding: [0x0 0x0] margin: [0x0 0x0]]
            on-click [
                p: parent-face? face
                if all [
                    not p/facets/edit-mode
                    arg/type = 'up
                ] [
                    focus p/intern/add-tag p none
                    p/facets/edit-mode: true
                    show-later face
                ]
            ]
        ]
        intern: [
            add-tag: funct [
                {Add tag face to tag panel. Return NONE, if tag already exists.}
                face [object!] "Tag-area panel"
                title [none! string!] "Tag text"
                /no-show
            ] [
                tags: get-face face
                if find tags title [return none]
                unless title [title: ""]
                append tags title
                lay: clear []
                faces: faces? face/names/tags
                either zero? length? faces [] [
                    append lay 'return
                ]
                append lay reduce ['tag-field title]
                apply :append-content [face/names/tags lay no-show]
                last faces? face/names/tags
            ]
            remove-tag: funct [
                "Remove tag face from panel"
                face [object!] "Tag-field face"
            ] [
                p: compound-face? face
                remove find p/facets/tags get-face face
                p/intern/layout-tags/force p
            ]
            layout-tags: funct [
                face
                /force "Do not get tags from faces, use TAGS facet instead"
            ] [
                tags: either force [get-facet face 'tags] [get-face face]
                unless face/facets/gob-size [face/facets/gob-size: 100x100]
                clear-content/no-show face/names/tags
                height: guie/styles/tag-field/facets/init-size/y
                tag-gob: make gob! reduce/no-set [size: as-pair 500 height]
                content: clear []
                width: 0
                foreach tag tags [
                    tag-gob/text: tag
                    size: 28 + size-text tag-gob
                    width: width + size/x
                    if width > face/facets/gob-size/x [
                        append content 'return
                        width: size/x
                    ]
                    size/y: height
                    repend content ['tag-field tag 'options compose [init-size: (size) min-size: (size) max-size: (size)]]
                ]
                set-content/no-show face/names/tags content
            ]
        ]
        draw: [
            normal: [
                pen border-color
                fill-pen bg-color
                box (margin-box/top-left + 1) (margin-box/bottom-right - 2)
            ]
            focus: [
                pen guie/colors/focus
                fill-pen bg-color
                line-width 3
                box (margin-box/top-left + 1) (margin-box/bottom-right - 2) 3
                fill-pen off
                pen border-color
                line-width 1
                box (margin-box/top-left + 1) (margin-box/bottom-right - 2)
            ]
        ]
        actors: [
            on-init: [
                do-actor/style face 'on-init arg 'hpanel
                unless empty? tags: get-facet face 'tags [
                    face/intern/layout-tags/force face
                ]
            ]
            on-get: [
                faces: faces? face/names/tags
                tags: copy []
                foreach fac faces [
                    if equal? select fac 'style 'tag-field [
                        append tags get-face fac
                    ]
                ]
                tags
            ]
            on-set: [
                switch arg/1 [
                    value [
                        apply :clear-content [face/names/tags false none arg/3]
                        append clear get-facet face 'tags arg/2
                        face/intern/layout-tags/force face
                        apply :update-face [face arg/3]
                    ]
                ]
            ]
            on-resize: [
                face/intern/layout-tags face
                do-actor/style face 'on-resize arg 'hpanel
            ]
            on-key: [
                if arg/type = 'key [
                    switch arg/key [
                        #" " [
                            focus face/intern/add-tag face none
                            face/facets/edit-mode: true
                        ]
                    ]
                ]
            ]
            on-focus: [
                set-facet face 'draw-mode either arg/1 ['focus] ['normal]
                draw-face face
            ]
        ]
    ]
]
temp-ctx-doc: context [
    space: charset " ^-"
    nochar: charset " ^-^/"
    para-start: charset [#"!" - #"~"]
    image-root: %./
    parse-para: funct [
        "Convert paragraph with minor markup."
        para "marked-up string"
    ] [
        buf: copy []
        while [all [para not tail? para]] [
            either spot: find para #"<" [
                append buf copy/part para spot
                para: either end: find/tail spot #">" [
                    switch copy/part spot end [
                        "<b>" [append buf 'bold]
                        "</b>" [append buf [bold off]]
                        "<i>" [append buf 'italic]
                        "</i>" [append buf [italic off]]
                        "<em>" [append buf [bold italic]]
                        "</em>" [append buf [bold off italic off]]
                    ]
                    end
                ] [
                    next spot
                ]
            ] [
                append buf reduce [copy/part para tail para]
                para: none
            ]
        ]
        buf
    ]
    emit-table: func [out /local s t] [
        if table? [
            t: copy/deep [hpanel 2 []]
            repeat i length? labs [
                repend t/3 ['label labs/:i 'text parse-para strs/:i 'options [one-line: true]]
            ]
            labs: clear [] strs: clear []
            table?: no
            i: 1
            append out t
        ]
    ]
    table?: false
    labs: clear [] strs: clear []
    set 'parse-doc funct/extern [
        {Parse the doc string input. Return rich-text output.}
        text [string!]
        /path
        doc-path "Path to use for images loading"
    ] [
        unless path [doc-path: %./]
        text: trim/auto detab text
        if newline <> last text [append text newline]
        out: make block! (length? text) / 20 + 1
        emit: funct [data /local t] [
            emit-table out
            repend out data
        ]
        t: s: none
        i: 1
        para: make string! 20
        parse/all text [
            copy s to newline skip (emit ['title s])
            some [
                "###" break
                |
                "===" copy s to newline skip (emit ['title s 'options [text-style: 'heading]])
                |
                "---" copy s to newline skip (emit ['title s 'options [text-style: 'subheading]])
                |
                "+++" copy s to newline skip (emit ['title s 'options [text-style: 'subsubheading]])
                |
                "=image-root" copy s to newline skip (image-root: join doc-path trim to file! s)
                |
                "=image" space opt ["center" space] copy s to newline skip (emit ['image join image-root to file! s 'options [align: 'center]])
                |
                ":" copy t to "- " 2 skip copy s to newline skip (table?: true append labs t append strs s)
                |
                "*" copy s to newline skip (table?: true append labs "*" append strs s)
                |
                "#" copy s to newline skip (table?: true append labs to string! ++ i append strs s)
                |
                some [copy s [para-start to newline] (repend para [s " "]) skip] (
                    emit ['text parse-para para]
                    clear para
                )
                |
                some [copy s [space thru newline] (append para skip s 4)] (
                    emit ['code-area 400x240 copy para 'options [align: 'center]]
                    clear para
                )
                |
                newline
                opt [newline ()]
            ]
        ]
        emit-table out
        reduce ['vpanel out]
    ] [table? image-root]
]
stylize [
    doc: plane [
        about: {A tiny document markup method for embedded docs, notes, messages.}
        tags: [tab]
        facets: [
            path: %./
        ]
        options: [
            init-size: [pair!]
            document: [string! block!]
        ]
        actors: [
            on-init: [
                if doc: get-facet face 'document [
                    set-face/no-show face doc
                ]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        apply :set-content [face parse-doc/path arg/2 get-facet face 'path false none arg/3]
                    ]
                ]
            ]
            on-scroll-event: [
                if bars: select face 'attached [
                    foreach bar bars [
                        if axis: get-facet bar 'axis [
                            set-face bar bar/state/value - to percent! 0.001 * arg/offset/:axis
                        ]
                    ]
                ]
            ]
        ]
    ]
]
stylize [
    sensor: [
        about: "Has no graphics, but can be clicked."
        tags: [internal]
        facets: [
            init-size: 100x100
        ]
        options: [
            init-size: [pair!]
        ]
        actors: [
            on-click: [
                if arg/type = 'up [do-face face 'hit]
                true
            ]
        ]
    ]
    drawing: sensor [
        about: "Simple scalar vector draw block. Can be clicked."
        tags: [tab]
        facets: [
            drawing: []
        ]
        options: [
            drawing: [block!]
            init-size: [pair!]
        ]
        actors: [
            on-make: [
                if all [in face/facets 'drawing block? drw: face/facets/drawing] [
                    set-face/no-show face copy drw
                ]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        face/facets/drawing: arg/2
                        show-later face
                    ]
                ]
            ]
            on-draw: [append arg face/facets/drawing]
            on-set-drawing-size: [
                unless empty? arg/1 [
                    max-size: 0x0
                    parse arg/1 [
                        some [
                            set p pair! (
                                if p/x > max-size/x [max-size/x: p/x]
                                if p/y > max-size/y [max-size/y: p/y]
                            )
                            | 1 skip
                        ]
                    ]
                    face/facets/min-size: max-size
                    face/facets/max-size: max-size
                    apply :resize-face [face max-size arg/2]
                ]
            ]
        ]
    ]
    image: sensor [
        about: "Simple image with optional border. Can be clicked."
        tags: [tab]
        facets: [
            init-size: 200x100
            img: make image! 50x50
            bg-color: none
            force: false
        ]
        options: [
            src: [image! file! url!]
            init-size: [pair!]
        ]
        draw: [
            image-filter bilinear resample 0.5
            image img 0x0 viewport-box/bottom-right
        ]
        actors: [
            on-init: [
                if src: get-facet face 'src [
                    set-face/no-show face src
                ]
            ]
            on-set: [
                if arg/1 = 'value [
                    unless image? img: arg/2 [
                        either get-facet face 'force [
                            img: attempt [load img]
                            unless img [
                                draw img: make image! 100x100
                                to-draw compose/deep [
                                    text 20x24 [
                                        font (make object! [size: 22 color: white])
                                        anti-alias on
                                        "no^/image"
                                    ]
                                    pen red
                                    line-width 3
                                    line 10x10 30x30
                                    line 10x30 30x10
                                ] copy []
                            ]
                        ] [
                            img: load img
                        ]
                    ]
                    if image? img [
                        apply :resize-face [face img/size arg/3]
                        set-facet face 'img img
                    ]
                ]
            ]
        ]
    ]
    icon: image [
        about: "Icon image with optional text below."
        tags: [tab]
    ]
    indicator: [
        about: "Visual indication of whether a face is valid."
        tags: [info]
        facets: [
            bg-color: none
            init-size: 20x20
            min-size: 20x20
            max-size: 20x20
            text-body: ""
            text-style: 'base
            draw-mode: 'skipped
            default-reactor: ['indicate arg]
        ]
        actors: [
            on-init: [
                if target: find-face-actor/reverse face 'on-validate [
                    do-actor target 'on-attach face
                ]
            ]
            on-set: [
                set-facet face 'draw-mode arg/2
                show-later face
            ]
        ]
        draw: [
            invalid: [
                pen red
                line-width 3
                line 4x4 18x18
                line 4x18 18x4
            ]
            valid: [
                pen 0.128.0
                line-width 3
                arc 1x20 10x10 -60 60
                arc 27x20 15x20 -180 60
            ]
            required: [
                pen black
                fill-pen black
                line-width 1
                circle 5 11x11
            ]
            not-required: [
                pen black
                line-width 1
                circle 5 11x11
            ]
            skipped: [
                pen 128.128.128
                line-width 1
                circle 5 11x11
            ]
        ]
    ]
    dir-text: drawing [
        facets: [
            init-angle: 0
            init-color: black
            drawing: copy []
        ]
        options: [
            init-text: [string!]
            init-angle: [decimal!]
            init-color: [tuple!]
        ]
        actors: [
            on-make: [
                set-face/no-show face face/facets/init-text
            ]
            on-set: [
                switch arg/1 [
                    value [
                        rfont: guie/fonts/dir-text/font
                        rpara: guie/fonts/dir-text/para
                        angle: face/facets/init-angle
                        if angle < 0 [angle: angle + 360]
                        g: make gob! 1000x1000
                        g/text: to-text [font rfont arg/2] copy []
                        size: size-text g
                        case [(angle >= 0) and (angle <= 90) [
                                size: as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
                                face/facets/drawing: compose/deep [
                                    transform (angle) 0x0 (as-pair 2 + rfont/size * sine angle 0)
                                    pen (face/facets/init-color)
                                    line-width 1
                                    text [font (rfont) para (rpara) (arg/2)] vectorial
                                ]
                            ] (angle > 90) and (angle <= 180) [
                                an: 180 - angle
                                size: as-pair (size/x * cosine an) + (size/y * sine an) (size/y * cosine an) + (size/x * sine an)
                                face/facets/drawing: compose/deep [
                                    transform (angle) 0x0 (as-pair size/x size/y * (1 - sine angle))
                                    pen (face/facets/init-color)
                                    line-width 1
                                    text [font (rfont) para (rpara) (arg/2)] vectorial
                                ]
                            ] (angle > 180) and (angle <= 270) [
                                size: abs as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
                                face/facets/drawing: compose/deep [
                                    transform (angle) 0x0 (as-pair size/x * (cosine 180 - angle) size/y)
                                    pen (face/facets/init-color)
                                    line-width 1
                                    text [font (rfont) para (rpara) (arg/2)] vectorial
                                ]
                            ] (angle > 270) and (angle < 360) [
                                face/facets/drawing: compose/deep [
                                    transform (angle) 0x0 (as-pair -5 -2 + size/x * sine angle - 180)
                                    pen (face/facets/init-color)
                                    line-width 1
                                    text [font (rfont) para (rpara) (arg/2)] vectorial
                                ]
                                size: abs as-pair (size/x * cosine angle) + (size/y * sine angle) (size/y * cosine angle) + (size/x * sine angle)
                            ]]
                        apply :resize-face [face size arg/3]
                        show-later face
                    ]
                ]
            ]
        ]
    ]
]
time: now/time/precise
deltat: func [text /local t] [
    print time
    print [text t: (n: now/time/precise) - time]
    time: n
]
stylize [
    text-table: htight [
        facets: [
            names: true
            break-after: 2
            all-over: true
            filter: make map! []
            atts: context [
                col: make block! 10
                row: make map! 100
                cell: []
            ]
            show-header: true
            no-edit: false
            show-empty: false
            row-height: 18
            bgd-color: snow
            text-color: black
            grid-color: gray
            highlight-color: 120.120.250.75
            over-color: 220.220.220
            empty-color: 220.220.250
            drawing-block: []
        ]
        state: [
            row-offset: 0
            visible-rows: 0
            over: none
            cell: 0x0
            visible: []
            all-rows: []
            unordered: []
            show-always: []
            dirty?: no
            value: none
        ]
        tags: [compound tab eat-tab]
        options: [
            init-size: [pair!]
            labels: [block!]
            table-data: [block!]
        ]
        intern: [
            process-data: funct [
                face [object!]
                data [block! none!]
                /force "Clear state (use with new data)"
            ] [
                either table: get-facet face 'table [] [
                    unless data [data: copy []]
                    index: index? face/state/visible
                    id: find face/state/visible to integer! face/state/cell/y
                    if id [id: index? id]
                    all-rows: make block! length? data
                    repeat i length? data [append all-rows i]
                    unless equal? all-rows face/state/all-rows [
                        either force [
                            face/state/over: none
                            face/state/visible: all-rows
                            face/state/unordered: all-rows
                            face/state/all-rows: all-rows
                            set-facet face 'table-data data
                            face/state/visible: at face/state/visible index
                        ] [
                            get-facet face [sorting:]
                            do-actor face 'on-filter-data none
                            if sorting [do-actor face 'on-sort sorting]
                        ]
                    ]
                ]
            ]
            parse-labels: funct [
                face [object!]
                dialect [block! none!]
            ] [
                get-facet face [atts:]
                cols: make block! 20
                index: 0
                if empty? dialect [dialect: copy [""]]
                label: col: width: dtype: no-edit: none
                cols: 0
                parse dialect [some [string! (++ cols) | 1 skip]]
                atts/col: array cols
                parse dialect [
                    some [(col: width: dtype: no-edit: none)
                        set label string!
                        any [
                            set col issue!
                            | set width integer!
                            | 'no-edit (no-edit: true)
                            | set dtype word!
                        ] (
                            index: index + 1
                            att: reduce [
                                'index either col [to integer! col] [index]
                                'width either width [width] [150]
                                'type either dtype [dtype] ['text]
                                'label label
                                'no-edit no-edit
                                'colpos 0
                            ]
                            col: either col [to integer! col] [index]
                            atts/col/:index: att
                        )
                    ]
                ]
                label-block: copy []
                cols: atts/col
                forall cols [
                    col: first cols
                    lbl: index? cols
                    srt-name: to set-word! join 'id lbl
                    flt-name: to set-word! join 'f lbl
                    repend label-block [
                        srt-name 'button
                        col/label
                        'options compose [
                            material: 'aluminum
                            bg-color: 200.210.220
                            min-size: 50x20
                            init-size: (as-pair max 50 col/width - 20 20)
                            max-size: (as-pair either last? cols [1000] [max 50 col/width - 20] 20)
                            text-style: 'sbutton
                            states: [none up down]
                            state: none
                            related: 'on-mutex
                        ]
                        'on-action [
                            p: parent-face? parent-face? face
                            col: (index? locate-face face) + 1 / 2
                            get-facet p [atts:]
                            get-facet face [states:]
                            if tail? states: next states [states: head states]
                            set-facet face 'states states
                            state: first states
                            set-facet face 'state state
                            do-actor p 'on-sort s: reduce [atts/col/:col/index state]
                            set-facet p 'sorting s
                            do-related face 'on-mutex
                            update-face p
                        ]
                        'on-draw [
                            if arg [
                                append arg [reset-matrix fill-pen black line-width 1]
                                append arg switch get-facet face 'state [
                                    up [[polygon 7x3 10x8 4x8]]
                                    down [[polygon 7x8 10x3 4x3]]
                                    none [[]]
                                ]
                            ]
                            do-actor/style face 'on-draw arg 'button
                            arg
                        ]
                        'on-focus [
                            do-actor parent-face? parent-face? face 'on-focus arg
                        ]
                        'on-mutex [
                            unless equal? face arg [
                                get-facet face [states:]
                                set-facet face 'states states: head states
                                set-facet face 'state first states
                            ]
                        ]
                        'on-set-arrow [
                            do-related face 'on-mutex
                        ]
                        flt-name 'drop-arrow
                        'on-click [
                            p: parent-face? parent-face? face
                            data: copy ["<All>" "<Empty>" "<Not empty>" "<=======>"]
                            col: (index? locate-face face) / 2
                            p/state/dirty?: no
                            p/state/show-always: clear []
                            get-facet p [atts:]
                            append data sort unique do-actor p 'on-get-col reduce [atts/col/:col/index p/state/visible]
                            invisible: difference unique p/state/all-rows unique p/state/visible
                            rest: do-actor p 'on-get-col reduce [atts/col/:col/index invisible]
                            unless zero? length? rest [
                                append data "<=======>"
                                append data sort unique rest
                            ]
                            forall data [if none? data/1 [remove data]]
                            set-face/field face data 'data
                            set-facet p 'col-filters data
                            do-actor/style face 'on-click arg 'drop-arrow
                        ]
                        'on-action [
                            if arg [
                                p: parent-face? parent-face? face
                                col: (index? locate-face face) / 2
                                data: get-facet p 'col-filters
                                get-facet p [atts:]
                                value: data/:arg
                                flt: switch/default value [
                                    "<All>" [[true]]
                                    "<empty>" [[any [none? value value = "" all [block? value empty? value]]]]
                                    "<not empty>" [[any [value <> "" all [block? value not empty? value]]]]
                                    "<=======>" [none]
                                ] [
                                    compose [value = (value)]
                                ]
                                if flt [
                                    do-actor p 'on-filter-data reduce [atts/col/:col/index flt]
                                    set-facet face 'arrow-color either any [[true] = flt] [black] [red]
                                ]
                                draw-face p
                                focus p/names/tbl
                            ]
                        ]
                    ]
                ]
                set-content/no-show face/names/btr label-block
            ]
            layout-block: [
                btr: htight [] options [names: true]
                pad: pad options [max-size: 16x16]
                return
                tbl: drawing []
                options [all-over: true dirty-focus?: false]
                on-over [
                    p: parent-face? face
                    either arg [
                        o: do-actor p 'on-find-cell arg/y
                        p/state/cell/x: do-actor p 'on-find-col arg/x
                        if o <> p/state/over [
                            p/state/over: o
                            do-actor p 'on-draw none
                        ]
                    ] [
                        p/state/over: none
                        do-actor p 'on-draw none
                    ]
                ]
                on-scroll-event [
                    p: parent-face? face
                    do-actor p 'on-scroll-line negate arg/offset/y / 3
                    draw-face p
                ]
                on-click [
                    p: parent-face? face
                    if 'up = arg/type [
                        focus p
                        if line: do-actor p 'on-find-cell arg/offset/y [
                            p/state/cell/y: line
                            switch/default type?/word p/state/value [
                                integer! [p/state/value: line]
                                pair! [p/state/value/y: line]
                            ] [p/state/value: p/state/cell]
                            draw-face p
                            do-actor p 'on-set-value p/state/cell
                            do-actor p 'on-action p/state/value
                        ]
                    ]
                    true
                ]
                scr: scroller on-action [
                    p: parent-face? face
                    id: to integer! (length? head p/state/visible) - p/state/visible-rows * arg
                    p/state/visible: skip head p/state/visible id
                    do-actor p 'on-draw none
                ]
                editor: hgroup 200.200.200 [] options [
                    names: true
                    box-model: 'tight
                ] on-key [
                    if arg/type = 'key [
                        get-facet face [cell:]
                        text-table: parent-face? face
                        get-facet text-table [atts:]
                        cols: atts/col
                        col: 0
                        foreach c cols [
                            if cols/:c/index = cell/x [col: c]
                        ]
                        switch arg/key [
                            up [
                                cell/y: first back find text-table/state/visible cell/y
                                row: to integer! cell/y
                                unless find text-table/state/visible row [
                                    text-table/state/visible: back text-table/state/visible
                                ]
                            ]
                            down [
                                if new-pos: select text-table/state/visible cell/y [cell/y: new-pos]
                                row: to integer! cell/y
                                pos: index? find text-table/state/visible row
                                if pos > text-table/state/visible-rows [
                                    text-table/state/visible: next text-table/state/visible
                                ]
                            ]
                            left [
                                col: max 1 col - 1
                            ]
                            right [
                                col: min length? cols col + 1
                            ]
                        ]
                        inner-editor: first values-of face/names
                        do-face inner-editor
                        do-actor text-table 'on-enter get-face inner-editor
                        text-table/state/value: text-table/state/cell: as-pair cols/:col/index cell/y
                        do-actor text-table 'on-place-editor reduce [face 'cell]
                        cell-type: get-face/field text-table 'cell-type
                        text-table/intern/open-editor text-table cell-type
                    ]
                ]
            ]
            editors: [
                text [
                    field: field ""
                    on-focus [
                        do-actor/style face 'on-focus arg 'field
                        if all [arg/1 arg/2] [
                            editor: parent-face? face
                            if 'ignored = show? editor [
                                show-face editor 'fixed
                            ]
                        ]
                        unless arg/1 [
                            unfocus/self
                            do-face face
                            'stop-event
                        ]
                    ]
                    on-key [
                        case [
                            all [
                                arg/type = 'key
                                arg/key = #"^M"
                            ] (
                                do-actor/style face 'on-key arg 'field
                                do-actor parent-face? parent-face? face 'on-enter get-face face
                            )
                            true (do-actor/style face 'on-key arg 'field)
                        ]
                    ]
                    on-action [
                        editor: parent-face? face
                        text-table: parent-face? editor
                        show-face/no-show editor 'ignored
                        cell: get-facet editor 'cell
                        row: to integer! second cell
                        col: to integer! first cell
                        data: get-facet text-table 'table-data
                        data/:row/:col: arg
                        draw-face text-table
                        focus text-table
                        do-actor text-table 'on-edit-action cell
                    ]
                ]
                tags [
                    pad 10x10
                    head-bar "TAG editor"
                    pad
                    button 24x24 "X" options [max-size: 24x24] on-action [
                        editor: parent-face? face
                        text-table: parent-face? editor
                        show-face/no-show editor 'ignored
                        cell: get-facet editor 'cell
                        row: to integer! second cell
                        col: to integer! first cell
                        data: get-facet text-table 'table-data
                        data/:row/:col: get-face editor/names/tag-area
                        draw-face text-table
                    ]
                    return
                    tag-area: tag-area on-action [
                        print get-face faces
                    ]
                ]
            ]
            open-handlers: reduce [
                'text funct [face] [
                    t: now/time/precise
                    editor: face/names/editor
                    field: editor/names/field
                    do-actor face 'on-place-editor reduce [editor 'cell]
                    show-face editor 'fixed
                    set-face field get-face/field face 'cell
                    focus field
                ]
                'tags funct [face] [
                    editor: face/names/editor
                    tag-area: editor/names/tag-area
                    do-actor face 'on-place-editor reduce [editor 'column]
                    show-face editor 'fixed
                    cell: get-face/field face 'cell
                    set-face tag-area cell
                    focus tag-area
                ]
            ]
            open-editor: funct [face name] [
                editor: select face/intern/editors name
                unless editor [
                    name: 'text
                    editor: select face/intern/editors name
                ]
                set-content face/names/editor editor
                open-func: select face/intern/open-handlers name
                open-func face
            ]
            set-att: func [
                face [object!]
                type [word!] "COL, ROW, or CELL"
                name [word!] "Attribute name"
                value [any-type!] "Attribute value"
            ] [
                atts: get-facet face 'atts
                either 'cell = type [
                    either find atts/:type name [
                        atts/:type/:name: value
                    ] [
                        repend atts/:type [name value]
                    ]
                ] [
                    atts/:type/:name: value
                ]
            ]
        ]
        actors: [
            on-init: [
                set-facet face 'cell-text copy []
                style: face-font? face
                foreach field [font para anti-alias] [
                    if style/:field [repend face/facets/cell-text [field any [select face field style/:field]]]
                ]
                set-facet face 'atts context [
                    col: make block! 10
                    row: make map! 100
                    cell: []
                ]
                set-content/no-show face face/intern/layout-block
                set-face/field/no-show face get-facet face 'labels 'labels
                data: get-facet face 'table-data
                unless data [data: copy []]
                set-face/field/no-show face data 'data
                if get-facet face 'table [do-actor face 'on-init-table none]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        if arg/2 [
                            face/state/value: as-pair 1
                            face/state/cell/y: arg/2
                        ]
                    ]
                    data [
                        set-facet face 'table-data arg/2
                        face/intern/process-data/force face arg/2
                    ]
                    labels [face/intern/parse-labels face arg/2]
                    state [
                        state: arg/2
                        set-face/field face state/labels 'labels
                        set-face/field face state/table-data 'data
                        face/state: copy state/state
                        apply :update-face [face arg/3]
                        do-actor face 'on-resize face/gob/size
                    ]
                    filter [
                        set-facet face 'filter arg/2
                        foreach filter arg/2 [
                            arrow: get in face/names/btr/names to word! join 'f filter
                            set-facet arrow 'arrow-color red
                        ]
                        do-actor face 'on-filter-data none
                    ]
                    sort [
                        set-facet face 'sorting arg/2
                        do-actor face 'on-sort arg/2
                        button: get in face/names/btr/names to word! join 'id arg/2/1
                        do-actor button 'on-set-arrow arg/2/2
                        set-facet button 'state arg/2/2
                    ]
                ]
            ]
            on-get: [
                value: face/state/value
                get-facet face [table-data:]
                switch arg [
                    value [value]
                    data [get-facet face 'table-data]
                    table [get-facet face 'table-data]
                    row [
                        if pair? value [row: to integer! value/y]
                        table-data/:row
                    ]
                    col [do-actor face 'on-get-col reduce [to integer! face/state/cell/x face/state/all-rows]]
                    column [
                        c: to integer! face/state/cell/x
                        if zero? c [c: 1]
                        c
                    ]
                    cell [
                        row: either pair? value [to integer! value/y] [value]
                        pick table-data/:row to integer! face/state/cell/x
                    ]
                    cell-type [
                        col: to integer! face/state/cell/x
                        face/facets/atts/col/:col/type
                    ]
                    filter [get-facet face 'filter]
                    visible [do-actor face 'on-get-view face/state/visible]
                    record [do-actor face 'on-get-record to integer! face/state/cell/y]
                    over [do-actor face 'on-get-record face/state/over]
                    labels [
                        get-facet face [atts:]
                        collect [
                            foreach col atts/col [
                                keep reduce [col/label to issue! to string! index? find atts/col col col/width to word! to lit-word! col/type]
                            ]
                        ]
                    ]
                    state [
                        context [
                            labels: get-face/field face 'labels
                            filters: get-face/field face 'filters
                            table-data: get-facet face 'table-data
                            state: face/state
                        ]
                    ]
                ]
            ]
            on-draw: [
                tbl: face/names/tbl
                scr: face/names/scr
                get-facet face [highlight-color: over-color: focus-color: grid-color: row-height: table-data: labels: atts: drawing-block]
                tbl-size: set-facet face 'tbl-size face/names/tbl/gob/size
                face/intern/process-data face table-data
                drawing-block: clear head drawing-block
                if tbl-size [
                    do-actor face 'on-draw-grid none
                    either table: get-facet face 'table [
                        repeat i face/state/visible-rows [
                            row: do-actor face 'on-get-record face/state/visible/:i
                            forall row [
                                do-actor face 'on-draw-cell reduce [as-pair index? row i row/1]
                            ]
                        ]
                    ] [
                        visible: face/state/visible
                        rows: to integer! tbl-size/y / face/facets/row-height
                        set-face/field/no-show face/names/scr to percent! rows / max 1 length? head visible 'delta
                        repeat y rows [
                            if visible/:y [do-actor face 'on-draw-row y]
                        ]
                    ]
                    set-face face/names/tbl drawing-block
                ]
            ]
            on-draw-grid: [
                get-facet face [tbl-size: highlight-color: over-color: focus-color: grid-color: row-height: atts: table-data: labels: drawing-block:]
                rows: to integer! tbl-size/y / face/facets/row-height
                if rows > length? face/state/visible [
                    face/state/visible: skip tail face/state/visible negate 1 + rows
                ]
                offset: index? face/state/visible
                w: 0
                foreach col atts/col [w: w + col/width]
                last-col: length? atts/col
                if tbl-size/x <> w [
                    atts/col/:last-col/width: atts/col/:last-col/width + (tbl-size/x - w)
                    w: tbl-size/x
                ]
                tbl-size/x: w
                tbl-size/y: rows * row-height
                repend drawing-block [
                    'pen face/facets/grid-color
                    'fill-pen face/facets/bgd-color
                    'box 0x0 as-pair tbl-size/x - 1 rows * row-height - 1
                ]
                unless get-facet face 'show-header [
                    show-face/no-show face/names/btr 'ignored
                    show-face/no-show face/names/pad 'ignored
                ]
                ypos: 0
                all [
                    face/state/over
                    y: find face/state/visible to integer! face/state/over
                    y: index? y
                    y: y - index? face/state/visible
                    y < rows
                    repend drawing-block [
                        'fill-pen over-color
                        'box as-pair 0 y * row-height as-pair tbl-size/x - 1 y + 1 * row-height
                    ]
                ]
                all [
                    face/state/visible
                    y: find face/state/visible to integer! face/state/cell/y
                    ypos: index? y
                    not zero? ypos
                    y: ypos - index? face/state/visible
                    y < rows
                    repend drawing-block [
                        'fill-pen highlight-color
                        'pen focus-color
                        'line-width 2
                        'box as-pair 0 y * row-height as-pair tbl-size/x - 1 y + 1 * row-height 1
                        'pen grid-color
                        'line-width 1
                    ]
                ]
                all [
                    equal? guie/focal-face face
                    none? face/state/value
                    repend drawing-block [
                        'pen focus-color
                        'fill-pen none
                        'line-width 2
                        'box 0x0 tbl-size - 1
                        'pen grid-color
                        'line-width 1
                    ]
                ]
                x: y: 0
                repend drawing-block ['pen grid-color]
                rows: to integer! tbl-size/y / row-height
                loop 1 + rows [
                    repend drawing-block ['line as-pair x y as-pair tbl-size/x y]
                    y: y + face/facets/row-height
                ]
                face/state/visible-rows: rows: to integer! rows
                tbl-size/y: row-height * rows
                xpos: 0
                repend drawing-block ['line 0x0 as-pair 0 tbl-size/y]
                foreach col atts/col [
                    xpos: xpos + col/width
                    repend drawing-block ['line as-pair xpos 0 as-pair xpos tbl-size/y]
                ]
            ]
            on-draw-row: [
                unless none? line: pick get-facet face 'table-data face/state/visible/:arg [
                    get-facet face [atts:]
                    cols: atts/col
                    forall cols [
                        col: first cols
                        do-actor face 'on-draw-cell reduce [as-pair index? cols arg pick line col/index]
                    ]
                ]
            ]
            on-draw-cell: [
                get-facet face [drawing-block: row-height: tbl-size: empty-color: atts:]
                c: to integer! arg/1/1
                y: to integer! arg/1/2
                either all [get-facet face 'show-empty any [
                        none? arg/2
                    ]] [
                    append drawing-block reduce [
                        'clip
                        as-pair 0 y - 1 * face/facets/row-height
                        as-pair 1000 y - 1 * face/facets/row-height + row-height
                        'fill-pen empty-color
                        'box
                        as-pair atts/col/:c/colpos + 2 y - 1 * face/facets/row-height + 2
                        as-pair atts/col/:c/colpos + atts/col/:c/width - 3 y - 1 * face/facets/row-height + row-height - 2
                        10
                    ]
                ] [
                    if none? arg/2 [arg/2: ""]
                    if find atts/col/1 'colpos [
                        this-pos: atts/col/:c/colpos
                        next-pos: atts/col/:c/colpos + atts/col/:c/width
                        origin: 1 + as-pair this-pos y - 1 * face/facets/row-height
                        end: as-pair next-pos - 10 y - 1 * face/facets/row-height + row-height
                        switch atts/col/:c/type [
                            text [
                                text-block: append copy face/facets/cell-text either block? arg/2 [
                                    t: copy ""
                                    foreach w arg/2 [repend t [w ", "]]
                                    remove/part back back tail t 2
                                    reduce [t]
                                ] [
                                    reduce [form arg/2]
                                ]
                                repend drawing-block [
                                    'clip
                                    origin
                                    end
                                    'text text-block
                                    origin
                                ]
                            ]
                            draw [
                                append drawing-block compose/deep [
                                    clip (origin) (end)
                                    push [
                                        fill-pen off
                                        pen off
                                        translate (origin) (arg/2)
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            on-resize: [
                get-facet face [atts: tbl-size:]
                cols: atts/col
                xpos: 0
                foreach col cols [
                    col/colpos: xpos
                    xpos: xpos + col/width
                ]
                last-id: length? cols
                cols/:last-id/width: tbl-size/x - cols/:last-id/colpos
                do-actor/style face 'on-resize arg 'htight
            ]
            on-focus: [
                unless face/state/over [face/state/over: first face/state/visible]
                set-facet face 'focus-color either arg/1 [guie/colors/focus] [255.255.255.0]
                draw-face face
            ]
            on-key: [
                get-facet face [table-data: row-height: atts:]
                unless face/state/over [face/state/over: 1]
                if arg/type = 'key [
                    switch arg/key [
                        up [
                            if find arg/flags 'shift [
                                move at table-data face/state/over -1
                            ]
                            do-actor face 'on-scroll-line -1
                        ]
                        down [
                            if find arg/flags 'shift [
                                move at table-data face/state/over 1
                            ]
                            do-actor face 'on-scroll-line 1
                        ]
                        page-up [
                            do-actor face 'on-scroll-line negate face/state/visible-rows
                        ]
                        page-down [
                            do-actor face 'on-scroll-line face/state/visible-rows
                        ]
                        #"^M" [
                            face/state/cell/y: face/state/over
                            do-actor face 'on-set-value face/state/cell
                            do-actor face 'on-action face/state/value
                        ]
                        #"^H" [
                            do-actor face 'on-remove-row face/state/over
                        ]
                        #" " [
                            face/state/cell/y: face/state/over
                            do-actor face 'on-set-value face/state/cell
                            do-actor face 'on-action face/state/value
                        ]
                        #"+" [
                            either face/state/over [
                                insert/only pos: at table-data face/state/over array length? atts/col
                            ] [
                                append/only pos: table-data array length? atts/col
                            ]
                            append face/state/all-rows 1 + last face/state/all-rows
                            face/state/dirty?: yes
                            append face/state/show-always index? pos
                            pos: index? face/state/visible
                            do-actor face 'on-filter-data none
                            face/state/visible: skip head face/state/visible pos - 1
                        ]
                        #"-" [
                            do-actor face 'on-remove-row to integer! face/state/value/y
                        ]
                        #"e" [
                            do-actor face 'on-open-editor either find arg/flags 'shift ['quick-form] [none]
                        ]
                    ]
                    draw-face face
                ]
                arg
            ]
            on-remove-row: [
                if over: find face/state/visible arg [
                    remove pos: at face/facets/table-data arg
                    if tail? next over [over: back over]
                    face/state/over: first over
                    remove back tail face/state/all-rows
                    pos: index? face/state/visible
                    do-actor face 'on-filter-data none
                    face/state/visible: skip head face/state/visible pos - 1
                ]
            ]
            on-open-editor: [
                get-facet face [atts:]
                cols: atts/col
                col: case [
                    none? face/state/value (1)
                    integer? face/state/value (1)
                    pair? face/state/value (to integer! face/state/value/x)
                ]
                forall cols [
                    c: first cols
                    if c/index = col [col: index? cols break]
                ]
                unless any [
                    not face/state/value
                    get-facet face 'no-edit
                    atts/col/:col/no-edit
                ] [
                    editor: face/names/editor
                    show-face editor 'visible
                    get-facet face [table-data:]
                    either 'quick-form = arg [
                        row: to integer! face/state/value/y
                        set-facet editor 'row row
                        lay: compose [
                            title "Quick form editor"
                            return
                            head-bar (join "row: " row)
                            return
                            button "Save" on-action [
                                editor: parent-face? face
                                text-table: parent-face? editor
                                get-facet text-table [table-data: atts:]
                                editors: editor/names/editors
                                values: get-panel editors
                                row: get-facet editor 'row
                                row: table-data/:row
                                cols: atts/col
                                foreach col cols [
                                    c: cols/:col/index
                                    row/:c: values/:col
                                ]
                                clear-content editor
                                show-face editor 'ignored
                                draw-face text-table
                            ]
                            button "Cancel"
                            editors: hpanel 2
                        ]
                        editors: clear []
                        cols: atts/col
                        foreach col cols [
                            c: col/index
                            value: table-data/:row/:c
                            default-editor: either col/no-edit ['head-bar] ['field]
                            inner-editor: switch/default col/type [
                                tags [
                                    reduce ['tag-area value]
                                ]
                            ] [
                                reduce [default-editor form value]
                            ]
                            name: copy col/label
                            name: to set-word! lowercase name
                            append editors compose [
                                label (col/label) (name) (inner-editor)
                            ]
                        ]
                        append/only lay editors
                        append lay [options [names: true]]
                        set-content face/names/editor lay
                        do-actor face 'on-place-editor reduce [editor 'table]
                        show-face editor 'fixed
                        faces: faces? face/names/editor/names/editors
                        focus second faces
                    ] [
                        col: get-face/field face 'column
                        type: atts/col/:col/type
                        face/intern/open-editor face type
                    ]
                ]
            ]
            on-place-editor: [
                editor: arg/1
                placement: arg/2
                get-facet face [table-data: row-height: atts:]
                if 0x0 = face/state/cell [
                    face/state/cell: 1x1
                    either 1 = length? atts/col [
                        face/state/value: 1
                    ] [
                        face/state/value: 1x1
                    ]
                ]
                xpos: x: ix: 0
                cols: atts/col
                foreach col cols [
                    x: col/width
                    if col/index = face/state/cell/x [ix: col break]
                    xpos: xpos + x
                ]
                col: to integer! face/state/cell/x
                row: to integer! face/state/cell/y
                r: 1 + (index? find face/state/visible row) - index? face/state/visible
                set-facet editor 'cell face/state/cell
                switch placement [
                    cell [
                        size: as-pair x 24
                        editor/gob/offset: as-pair xpos r * row-height
                        unless get-facet face 'show-header [editor/gob/offset/y: editor/gob/offset/y - 22]
                    ]
                    column [
                        labels-height: 21
                        size: as-pair x face/facets/gob-size/y - labels-height
                        editor/gob/offset: as-pair xpos labels-height
                    ]
                    table [
                        size: face/facets/gob-size - 0x40
                        editor/gob/offset: 0x0
                    ]
                ]
                set-facet editor 'min-size size
                set-facet editor 'max-size size
                show-face/no-show editor 'fixed
                do-actor editor 'on-resize size
                draw-face editor
            ]
            on-find-cell: [
                "Return position of current line in original data"
                row-offset: 1 + to integer! arg / get-facet face 'row-height
                if row-offset > length? face/state/visible [row-offset: length? face/state/visible]
                either table: get-facet face 'table [
                    row-offset
                ] [
                    face/state/visible/:row-offset
                ]
            ]
            on-find-col: [
                get-facet face [atts:]
                total: 0
                idx: 0
                cols: atts/col
                foreach col cols [
                    idx: idx + 1
                    total: total + col/width
                    if total > arg [
                        total: col/index
                        break
                    ]
                ]
                total
            ]
            on-sort: [
                visible: face/state/visible
                col: do-actor face 'on-get-col reduce [arg/1 visible]
                data: make block! 2 * length? visible
                foreach id visible [
                    repend data [col/1 id]
                    col: next col
                ]
                face/state/visible: switch/default arg/2 [
                    up [
                        sort/skip data 2
                        forall data [remove data]
                        data
                    ]
                    down [
                        sort/skip/reverse data 2
                        forall data [remove data]
                        data
                    ]
                ] [face/state/unordered]
            ]
            on-get-col: [
                id: arg/1
                visible: arg/2
                data: get-facet face 'table-data
                out: make block! length? visible
                foreach row visible [
                    append out data/:row/:id
                ]
                out
            ]
            on-filter-data: [
                get-facet face [table-data: filter: atts:]
                out: make block! length? table-data
                if arg [
                    col: arg/1
                    flt: arg/2
                    filter/:col: flt
                ]
                forall table-data [
                    pass?: true
                    foreach f filter [
                        value: table-data/1/:f
                        pass?: pass? and true? do bind filter/:f 'value
                    ]
                    if any [
                        pass?
                        all [face/state/dirty? find face/state/show-always index? table-data]
                    ] [append out index? table-data]
                ]
                view: do-actor face 'on-get-flat-view out
                face/state/unordered: out
                face/state/visible: out
            ]
            on-get-flat-view: [
                out: make block! length? arg
                foreach id arg [
                    append out do-actor face 'on-get-record id
                ]
                out
            ]
            on-get-view: [
                out: make block! length? arg
                foreach id arg [
                    unless none? (tmp: do-actor face 'on-get-record id) [append/only out tmp]
                ]
                out
            ]
            on-scroll-line: [
                either face/state/over [
                    v: find head face/state/visible face/state/over
                    if v [
                        v: skip v arg
                        if tail? v [v: back v]
                        face/state/over: first v
                        face/state/visible: skip v negate to integer! face/state/visible-rows / 2
                    ]
                    while [
                        all [
                            face/state/visible-rows < length? head face/state/visible
                            face/state/visible-rows > length? face/state/visible
                        ]
                    ] [
                        face/state/visible: back face/state/visible
                    ]
                ] [
                    face/state/over: first face/state/visible
                ]
                set-face/no-show face/names/scr min 100% to percent! (-1 + index? face/state/visible) / max 1 ((length? head face/state/visible) - face/state/visible-rows)
                editor: face/names/editor
                unless 0x-1 = editor/gob/size [
                    show-face editor 'ignored
                ]
            ]
            on-get-record: [
                i: arg
                either table: get-facet face 'table [
                    get-facet face [labels:]
                    db-handler/rec-id: i
                    db-handler/do-act 'set-id
                    label-map: array length? labels
                    foreach l labels [
                        label-map/:l: to word! labels/:l
                    ]
                    rec: db-handler/do-act 'get-record
                    row: array length? labels
                    foreach [key value] rec [
                        if i: find label-map key [
                            i: index? i
                            row/:i: value
                        ]
                    ]
                    row
                ] [
                    face/facets/table-data/:arg
                ]
            ]
            on-set-value: [
                {This actor will set right value to face/state/value}
                face/state/value: arg
            ]
            on-init-table: [
                if table: get-facet face 'table [
                    db-handler/table: table
                    all-rows: db-handler/do-act 'get-keys
                    face/state/visible: all-rows
                    face/state/unordered: all-rows
                    face/state/all-rows: all-rows
                ]
            ]
            on-enter: []
        ]
    ]
    text-list: text-table [
        facets: [
            show-header: false
        ]
        options: [
            init-size: [pair!]
            list-label: [string!]
            list-data: [block!]
        ]
        actors: [
            on-init: [
                data: copy []
                foreach item get-facet face 'list-data [append/only data reduce [item]]
                set-facet face 'table-data data
                do-actor/style face 'on-init arg 'text-table
            ]
            on-set: [
                switch/default arg/1 [
                    labels [
                        unless lb: arg/2 [lb: ""]
                        do-actor/style face 'on-set reduce ['labels append clear [] lb] 'text-table
                    ]
                    data [
                        data: copy []
                        foreach item arg/2 [append/only data reduce [item]]
                        do-actor/style face 'on-set reduce ['data data] 'text-table
                    ]
                ] [
                    do-actor/style face 'on-set arg 'text-table
                ]
            ]
            on-get: [
                value: face/state/value
                get-facet face [table-data:]
                switch arg [
                    value [either pair? value [to integer! value/y] [value]]
                    table-data [table-data]
                    data [
                        val: collect [
                            foreach item table-data [keep first item]
                        ]
                        if none? val [val: copy []]
                        val
                    ]
                    text [either index: get-face face [pick table-data index] [copy ""]]
                ]
            ]
            on-set-value: [
                {This actor will set right value to face/state/value}
                face/state/value: to integer! arg/y
            ]
        ]
    ]
    file-list: text-list [
        facets: [
            show-header: true
        ]
        options: [
            list-path: [file! string!]
        ]
        actors: [
            on-init: [
                path: get-facet face 'list-path
                set-face/no-show face path
                do-actor/style face 'on-init arg 'text-table
            ]
            on-set: [
                switch/default arg/1 [
                    value [
                        files: read arg/2
                        set-face/field/no-show face files 'data
                    ]
                    label [
                        l: arg/2
                        do-actor/style face 'on-set reduce ['labels append clear [] l] 'text-table
                    ]
                    data [
                        data: copy []
                        foreach item arg/2 [append/only data reduce [item]]
                        do-actor/style face 'on-set reduce ['data data] 'text-table
                    ]
                ] [
                    do-actor/style face 'on-set arg 'text-table
                ]
            ]
        ]
    ]
]
set-face-key: funct [
    "Set action when key is pressed in face"
    face [object!]
    key [char! word! block!]
    action [block!]
] [
    if block? key [key: catenate key "-"]
    key-acts: get-facet face 'key-acts
    key-acts/:key: action
]
stylize [
    table-panel: hpanel [
        options: [
            panel-id: [integer!]
            content: [block!]
            bg-color: [tuple!]
        ]
        facets: [
            break-after: 1
            margin: [0x0 0x0]
            padding: [0x0 0x0]
            spacing: 0x0
            border-size: [0x0 0x0]
            bg-color: none
            panel-id: none
        ]
        draw: []
    ]
    table-plane: vpanel [
        options: [
            bg-color: [tuple!]
        ]
        facets: [
            margin: [0x0 0x0]
            padding: [0x0 0x0]
            spacing: 0x0
            border-size: [1x1 1x1]
            bg-color: none
            resize?: false
        ]
        draw: []
    ]
    table-viewport: hpanel [
        options: [
            bg-color: [tuple!]
        ]
        facets: [
            break-after: 1
            margin: [0x0 0x0]
            padding: [0x0 0x0]
            spacing: 0x0
            border-size: [0x0 0x0]
            bg-color: none
            border-color: none
            names: true
            rows-per-panel: 50
            total-rows: 0
            rows-data: none
            visible-panels: none
            last-scr: -1
        ]
        content: [
            pad options [max-size: 642x882 min-size: 420x340]
            tp: table-plane options [show?: 'fixed bg-color: none]
        ]
        actors: [
            on-init: [
                face/facets/visible-panels: copy []
            ]
            on-update-panels: [
                f: face/facets
                tp: face/names/tp
                vscr: face/attached/1
                upd?: false
                row-beg: f/total-rows * vscr/state/value
                panel-id: to-integer row-beg / f/rows-per-panel
                unless f/visible-panels/1 = panel-id [
                    clear-panel-content/no-show tp
                    clear f/visible-panels
                ]
                forever [
                    unless find f/visible-panels panel-id [
                        lay: reduce ['table-panel either odd? panel-id [red] [white] panel-id copy []]
                        repeat n f/rows-per-panel [
                            row-data: pick f/rows-data panel-id * f/rows-per-panel + n
                            unless row-data [break]
                            append last lay compose/deep [
                                text (row-data/2) (as-pair 140 row-data/3) options [min-size: (as-pair 100 row-data/3)]
                            ]
                        ]
                        if empty? last lay [
                            break
                        ]
                        append f/visible-panels panel-id
                        append-panel-content tp lay
                        upd?: true
                    ]
                    h: tp/gob/size/y + tp/gob/offset/y
                    if h >= f/gob-size/y [break]
                    panel-id: panel-id + 1
                ]
                pnl: first faces? tp
                tp/gob/offset/y: negate (row-beg // f/rows-per-panel) * (pnl/gob/size/y / f/rows-per-panel)
                if tp/gob/offset/y = f/last-scr [exit]
                f/last-scr: tp/gob/offset/y
                apply :show-later [tp not upd?]
            ]
            on-scroll: [
                if face/facets/rows-data [
                    pf: parent-face? face
                    either arg = pf/names/vscr [
                        do-actor face 'on-update-panels none
                    ] [
                        tp/gob/offset/x: negate tp/gob/size/x - face/facets/gob-size/x * arg/state/value
                        tp/show-only?: true
                        show-later face/names/tp
                    ]
                ]
            ]
        ]
        draw: []
    ]
    table: hpanel [
        options: [
            data: [block!]
        ]
        facets: [
            break-after: 2
            bg-color: white
            names: true
        ]
        content: [
            tv: table-viewport options [bg-color: none] vscr: scroller
            hscr: scroller
        ]
        actors: [
            on-init: [
                if data: face/facets/data [
                    tv/facets/total-rows: -1 + length? data
                    tv/facets/rows-data: data
                    set-face tv/attached/1 probe reduce [000% 10%]
                    set-face tv/attached/2 probe reduce [000% 30%]
                ]
            ]
        ]
        draw: []
    ]
]
log-t: now/time/precise
log: func [data /local t] [
    data: rejoin append copy [] data
    log-t: t
]
stylize [
    button-bar: htight [
        about: "Simple button bar."
        facets: [
            buttons: make map! 10
            button-style: 'tab-button
            names: true
            spacing: 1x0
        ]
        tags: [compound internal]
        options: [
            init-size: [pair!]
            button-layout: [issue!]
            data-block: [block!]
        ]
        state: [
            items: copy []
            active: #[none]
        ]
        debug-draw: [
            pen red
            line-width 2
            box 1x1 viewport-box/bottom-right
        ]
        actors: [
            on-set: [
                log ["BARon-set" arg]
                switch arg/1 [
                    data [
                        bar: do-actor face 'on-parse-data arg/2
                        apply :set-content [face bar false none arg/3]
                    ]
                    value [
                        if face/state/active <> arg/2 [
                            face/state/active: arg/2
                            apply :set-face [face/names/(arg/2) 'down arg/3]
                            do-actor face 'on-action arg/2
                        ]
                    ]
                ]
                log "===end of on-set"
            ]
            DISABLED-on-drag-over: [
                drag: arg/1
                drag-offset: drag/gob/offset - get-gob-offset face/gob
                all [
                    not empty? face/gob/pane
                    pos: drag-offset/x / button-width: (face/gob/pane/1/size/x + face/facets/spacing/x)
                    button-id: to integer! round pos
                    gob: face/gob/pane/:button-id
                    left-boundary: button-id - 1 * button-width
                    gob/offset/x: max left-boundary button-id * button-width - drag-offset/x * 2 + left-boundary
                    show gob/parent
                ]
                true
            ]
            DISABLED-on-drop: [
                drag: arg/face
                items: to block! face/state/items
                id: get-facet drag 'id
                pos: (to integer! arg/event/offset/x / arg/gob/size/x) * 2 + 1
                pos-id: items/:pos
                either all [drag: find items id drop: find items pos-id] [
                    swap next drag next drop
                    swap drag drop
                    set-face face to map! items
                    show-later window-face? face
                    true
                ] [false]
            ]
            on-visible-count: [
                but: make-face get-facet face 'button-style []
                cur-size: max 0 face/facets/viewport-box/bottom-right/x - 45
                to integer! cur-size / (face/facets/spacing/x + but/facets/min-size/x)
            ]
            on-show-button: [
                count: do-actor face 'on-visible-count none
                pos: either pos: find arg face/state/active [(1 + index? pos) / 2] [0]
                if pos > count [arg: skip arg pos - count * 2]
                arg
            ]
            on-make-button: [
                either none? arg/1 [[]] [
                    compose/deep [(arg/1) (get-facet face 'button-style) (arg/2) (arg/3) (get-facet face 'button-layout)]
                ]
            ]
            on-parse-data: [
                log "BARon-parse-data"
                out: copy []
                parse arg [
                    some [(t: none)
                        opt set t set-word!
                        set s string! (
                            unless none? t [
                                append out do-actor face 'on-make-button reduce [:t s equal? :t face/state/active]
                            ]
                        )
                    ]
                ]
                if find [#left #right] get-facet face 'button-layout [
                    set-facet face 'layout-mode 'horizontal
                ]
                face/state/items: arg
                log "===end of parse-data"
                out
            ]
        ]
    ]
    old-tab-box: hpanel [
        about: "Multi sub-layout."
        tags: [layout tab compound]
        facets: [
            init-hint: 600x360
            max-hint: guie/max-pair
            border-size: [1x1 1x1]
            border-color: black
            bg-color: none
            box-model: none
            spacing: 0x0
            margin: [0x0 0x0]
            padding: [0x0 0x0]
            layout-mode: 'horizontal
            names: true
            focus-color: 239.222.205
            pen-color: 0.0.0
            tabs: make map! []
            layouts: make map! []
            previews: make map! []
            placement: #top
            break-after: 1
            set-fields: make map! [
                value [
                    log ["*Value:" value]
                    if act: face/state/active [
                        show-face/no-show face/names/tab-area/names/:act 'ignore
                    ]
                    panel: layouts/:value
                    hint: none
                    sp: get in face/names 'sp
                    if sp [hint: sp/gob/size]
                    tab-area: face/names/tab-area
                    print "tab area is ok"
                    if block? panel [
                        append-content tab-area reduce [
                            to set-word! value 'hpanel panel 'options compose [
                                show-mode: 'hidden
                                border-size: [1x1 1x1]
                                border-color: black
                            ]
                        ]
                        layouts/:value: tab-area/names/:value
                    ]
                    print "going to set tab"
                    print tab-area/names/:value/gob/size
                    if value [
                        face/state/active: value
                        show-face tab-area/names/:value 'visible
                        set-face face/names/tab-bar value
                    ]
                ]
                data [
                    log ["**Data:" value]
                    parse value [
                        some [(id: nm: pn: none)
                            opt set id word! set nm string! set pn block! (
                                if none? id [id: to word! join "tab-" issue-id tabs]
                                set-face/field face reduce [id nm pn] 'tab
                            )
                        ]
                    ]
                ]
                tab [
                    log ["***Tab: " mold value]
                    tabs/(value/1): value/2
                    layouts/(value/1): value/3
                    tb: copy []
                    foreach t tabs [repend tb [to set-word! t tabs/:t]]
                    set-face/field face/names/tab-bar tb 'data
                ]
            ]
        ]
        options: [
            init-size: [pair!]
            data: [block!]
            placement: [issue!]
        ]
        state: [
            active: #[none]
            tab-offset: 0
            shown-tabs: 0
        ]
        actors: [
            on-make: [
                make-layout face 'panel
            ]
            on-init: [
                log ["on-init"]
                set-facet face 'tabs make map! []
                set-facet face 'layouts make map! []
                layout-block: [
                    tab-bar: button-bar [""] #top on-action [
                        p: parent-face? face
                        set-face p arg
                    ]
                    hpanel [
                        plane [
                            tab-area: scroll-pane [] options [names: yes]
                        ]
                        scroller
                        scroller
                    ] options [
                        break-after: 2
                    ]
                ]
                content: []
                set-content/no-show face layout-block
                set-face/field face get-facet face 'data 'data
                set-face face first words-of face/facets/tabs
            ]
            on-set: [
                log ["on-set: " mold arg]
                get-facet face [previews: tabs: layouts: set-fields:]
                if find words-of set-fields arg/1 [
                    value: arg/2
                    act: select set-fields arg/1
                    words: collect-words/set/deep act
                    use words bind act 'face
                ]
                show-later face
            ]
            on-get: [
                {Return block of two map!s - [tab-names layout-faces]}
                log ["on-get: " mold arg]
                get-facet face [tabs: layouts:]
                reduce [tabs layouts]
            ]
            on-focus: [
                set-facet face 'bg-color either arg/1 [get-facet face 'focus-color] [255.255.255.0]
                draw-face face
            ]
            on-key: [
                tabs: find words-of face/facets/tabs face/state/active
                if 'key-up = arg/type [
                    switch/default arg/key [
                        left [set-face face first back tabs]
                        right [if 1 <= length? next tabs [set-face face first next tabs]]
                    ] [print "other key"]
                ]
            ]
        ]
    ]
    element-group: vpanel [
        about: {Vertical group of elements, which SET-FACE or GET-FACE manages with one value.}
        tags: [layout tab compound internal state tab eat-tab]
        facets: [
            element: none
        ]
        state: [
            over: 1
        ]
        options: [
            values: [block!]
        ]
        intern: [
            process-keys: funct [
                face
                arg
            ] [
                over: face/state/over
                faces: faces? face
                unless over [over: 0]
                switch/default arg/key [
                    up [over: over - 1]
                    down [over: over + 1]
                    #" " [set-face faces/:over true]
                    #"M" [set-face faces/:over true]
                ] []
                face/state/over: over
            ]
        ]
        actors: [
            on-make: [
                make-layout face 'panel
            ]
            on-init: [
                log ["on-init"]
                layout-block: copy []
                use [w s d] [
                    parse face/facets/values [
                        any [
                            set w word! set s any-type! opt ['on (d: yes)] (
                                repend layout-block [
                                    face/facets/element form s 'on-action compose [
                                        p: parent-face? face
                                        do-actor p 'on-process (to lit-word! w)
                                    ]
                                ]
                                if d [
                                    insert skip tail layout-block -2 'on
                                    d: no
                                ]
                            )
                        ]
                    ]
                ]
                set-content/no-show face layout-block
            ]
            on-focus: [
                unless arg/1 [
                    f: face/state/over
                    faces: faces? face
                    do-actor faces/:f 'on-focus [false none]
                ]
            ]
            on-key: [
                if arg/type = 'key-up [
                    face/intern/process-keys face arg
                    over: face/state/over
                    faces: faces? face
                    f: length? faces? face
                    if over < 1 [over: f]
                    if over > f [over: 1]
                    do-actor faces/:over 'on-focus reduce [true none]
                    face/state/over: over
                ]
            ]
        ]
    ]
    check-group: element-group [
        about: "Vertical group of check boxes."
        facets: [
            element: 'check
        ]
        intern: [
            process-keys: funct [
                face
                arg
            ] [
                over: face/state/over
                faces: faces? face
                unless over [over: 0]
                switch/default arg/key [
                    up [over: over - 1]
                    down [over: over + 1]
                    #" " [set-face faces/:over not get-face faces/:over]
                    #"M" [set-face faces/:over not get-face faces/:over]
                ] []
                face/state/over: over
            ]
        ]
        actors: [
            on-process: [
                "Handle changes comming from inside the style"
            ]
            on-set: [
                "Set using block of words"
                faces: faces? face
                i: 0
                foreach [word value] face/facets/values [
                    i: i + 1
                    apply :set-face [faces/:i find arg/value word arg/3]
                ]
            ]
            on-get: [
                "Return block of words"
                output: clear []
                faces: faces? face
                i: 0
                foreach [word val] face/facets/values [
                    i: i + 1
                    if get-face faces/:i [append output word]
                ]
                set-facet face 'value copy output
                output
            ]
        ]
    ]
    radio-group: element-group [
        about: "Layout of radio buttons"
        facets: [
            element: 'radio
        ]
        actors: [
            on-process: [
                "Handle changes comming from inside the style"
                set-face face arg
            ]
            on-set: [
                "Set using a single word"
                switch arg/1 [
                    value [
                        set-facet face 'value arg/value
                        faces: faces? face
                        i: (1 + index? find face/facets/values arg/value) / 2
                        apply :set-face [faces/:i true arg/3]
                    ]
                    data []
                ]
            ]
            on-get: [
                "Get the set radio button"
                i: 0
                foreach fc faces? face [
                    i: i + 1
                    if get-face fc [return pick extract face/facets/values 2 i]
                ]
            ]
        ]
    ]
    tab-box: vpanel [
        facets: [
            names: true
            tab-ids: copy []
            tabs: make map! []
            spacing: 0x0
            row-min: [22]
            row-init: [22]
            row-max: [22]
        ]
        options: [
            tab-size: [pair!]
            data: [block!]
        ]
        content: [
            pad
            tab-area: scroll-panel [] options [border-size: [1x1 1x1] border-color: black]
            tab-control: button-bar [] options [max-hint: [auto 22] show-mode: 'fixed gob-offset: 6x4]
        ]
        actors: [
            on-init: [
                set-face/field face get-facet face 'data 'data
                tabs: get-facet face 'tabs
                set-face face first words-of tabs
            ]
            on-set: [
                get-facet face [tabs:]
                tab-area: face/names/tab-area
                switch arg/1 [
                    value [
                        id: arg/2
                        tab: tabs/:id
                        if block? tab [
                            tab: layout/options tab [
                                spacing: 0x0
                                margin: [0x0 0x0]
                                padding: [0x0 0x0]
                            ]
                            tabs/:id: tab
                        ]
                        apply :set-face [tab-area tab arg/3]
                    ]
                    data [
                        lay: copy []
                        foreach [name layout] arg/2 [
                            id: issue-id face/facets/tab-ids
                            s: font-text-size? 'button name
                            append lay reduce [
                                'button name to integer! s/x + 20
                                'options compose [name: (id)]
                                'on-action [
                                    id: to word! get-facet face 'name
                                    p: parent-face? parent-face? face
                                    set-face p id
                                ]
                            ]
                            id: to word! id
                            tabs/:id: layout
                        ]
                        apply :append-content [face/names/tab-control lay arg/3]
                    ]
                ]
            ]
        ]
    ]
    color-box: box [
        tags: [internal]
        actors: [
            on-set: [
                switch arg/1 [
                    value [
                        cf: compound-face? face
                        switch type?/word arg/2 [
                            percent! decimal! [
                                idx: index? find [sld-r sld-g sld-b] face/attached-face/name
                                face/facets/bg-color/:idx: 255 * arg/2
                            ]
                            tuple! [
                                face/facets/bg-color: arg/2
                                apply :set-face [cf face/facets/bg-color arg/3]
                            ]
                        ]
                        apply :set-face [cf/names/ci face/facets/bg-color arg/3]
                        apply :draw-face [face arg/3]
                        apply :do-face [cf false none arg/3]
                    ]
                ]
            ]
        ]
    ]
    palette-box: box [
        tags: [internal]
        actors: [
            on-click: [
                cf: compound-face? face
                set-face cf/names/bx face/facets/bg-color
            ]
        ]
    ]
    color-field: field [
        tags: [edit tab internal]
        facets: [
            text-style: 'centered-aa
        ]
    ]
    color-picker: vgroup [
        tags: [compound]
        facets: [
            names: true
            color: black
        ]
        options: [
            init-hint: [pair!]
            color: [tuple!]
        ]
        intern: [
            palette: [
                255.255.255
                255.192.192
                255.224.192
                255.255.192
                192.255.192
                192.255.255
                192.192.255
                255.192.255
                224.224.224
                255.128.128
                255.192.128
                255.255.128
                128.255.128
                128.255.255
                128.128.255
                255.128.255
                192.192.192
                255.0.0
                255.128.0
                255.255.0
                0.255.0
                0.255.255
                0.0.255
                255.0.255
                128.128.128
                192.0.0
                192.64.0
                192.192.0
                0.192.0
                0.192.192
                0.0.192
                192.0.192
                64.64.64
                128.0.0
                128.64.0
                128.128.0
                0.128.0
                0.128.128
                0.0.128
                128.0.128
                0.0.0
                64.0.0
                128.64.64
                64.64.0
                0.64.0
                0.64.64
                0.0.64
                64.0.64
            ]
        ]
        content: [
            pal: htight 8 [] options [spacing: 3x3]
            return
            bx: color-box black options [max-size: as-pair guie/max-coord 120]
            ci: color-field on-key [
                do-actor/style face 'on-key arg 'field
                switch arg/type [
                    key-up [
                        unless error? try [color: to tuple! get-face face] [
                            tmp: index? face/state/cursor
                            cf: compound-face? face
                            set-face cf/names/bx color
                            face/state/cursor: tmp
                            goto-caret face tmp
                        ]
                    ]
                ]
            ]
            return
            head-bar 45x20 "Red" red white
            sld-r: slider attach 'bx
            head-bar 45x20 "Green" green white
            sld-g: slider attach 'bx
            head-bar 45x20 "Blue" blue white
            sld-b: slider attach 'bx
        ]
        actors: [
            on-init: [
                do-actor/style face 'on-init arg 'vgroup
                blk: copy []
                foreach col face/intern/palette [
                    append blk compose [palette-box (col) options [min-size: 22x22 max-size: 22x22 init-size: 22x22]]
                ]
                set-content/no-show face/names/pal blk
                set-face/no-show face face/facets/color
            ]
            on-set: [
                switch arg/1 [
                    value [
                        n: 100% / 255
                        apply :set-face [face/names/sld-r arg/2/1 * n arg/3]
                        apply :set-face [face/names/sld-g arg/2/2 * n arg/3]
                        apply :set-face [face/names/sld-b arg/2/3 * n arg/3]
                    ]
                ]
            ]
            on-get: [
                return switch/default arg [
                    value [
                        face/names/bx/facets/bg-color
                    ]
                ] [
                    none
                ]
            ]
        ]
    ]
    color-array-box: box [
        tags: [internal]
        facets: [
            init-size: 50x50
            border-size: [3x3 3x3]
        ]
        actors: [
            on-set: [
                switch arg/1 [
                    value [
                        cf: compound-face? face
                        idx: index? find [sld-r sld-g sld-b] face/attached-face/name
                        face/facets/bg-color/:idx: 255 * arg/2
                        apply :set-face [cf/names/ci face/facets/bg-color arg/3]
                        draw-face face
                    ]
                ]
            ]
            on-click: [
                if arg/type = 'down [
                    focus face
                ]
                true
            ]
            on-focus: [
                if arg [
                    cf: compound-face? face
                    if cf/names/ca/facets/picked-box = face [exit]
                    if cf/names/ca/facets/picked-box [
                        cf/names/ca/facets/picked-box/facets/border-color: none
                    ]
                    face/facets/border-color: black
                    cf/names/ca/facets/picked-box: face
                    draw-face cf/names/ca
                    set-face cf/names/cp face/facets/bg-color
                ]
            ]
            on-draw: [
                either face/facets/border-color [
                    compose [
                        line-pattern white 5.0 5.0 (arg)
                    ]
                ] [
                    arg
                ]
            ]
        ]
    ]
    color-array-picker: hgroup [
        tags: [compound]
        facets: [
            names: true
            color-array: reduce [red green blue]
        ]
        options: [
            init-hint: [pair!]
            color-array: [block!]
        ]
        content: [
            ca: hpanel snow [
                pad
            ] options [
                picked-box: none
            ]
            vpanel [
                button 70 "Add" on-action [
                    cf: compound-face? face
                    either pb: cf/names/ca/facets/picked-box [
                        insert-content/pos cf/names/ca [color-array-box] pb
                    ] [
                        append-content cf/names/ca [color-array-box]
                    ]
                    f: faces? cf/names/ca
                    focus first back any [find f pb f]
                ]
                button 70 "Remove" on-action [
                    cf: compound-face? face
                    if pb: cf/names/ca/facets/picked-box [
                        remove-content/pos cf/names/ca pb
                    ]
                ]
            ]
            return
            cp: color-picker on-action [
                cf: compound-face? face
                if pb: cf/names/ca/facets/picked-box [
                    pb/facets/bg-color: arg
                    draw-face pb
                ]
            ]
        ]
        actors: [
            on-init: [
                do-actor face 'on-set reduce ['value face/facets/color-array true]
                unless empty? f: faces? face/names/ca [
                    focus first f
                ]
            ]
            on-set: [
                switch arg/1 [
                    value [
                        color-array: copy []
                        foreach col arg/2 [
                            append color-array compose [
                                color-array-box (col)
                            ]
                        ]
                        apply :set-content [face/names/ca color-array none none arg/3]
                    ]
                ]
            ]
            on-get: [
                return switch/default arg [
                    value [
                        result: copy []
                        foreach-face f face/names/ca [
                            append result f/facets/bg-color
                        ]
                        result
                    ]
                ] [
                    none
                ]
            ]
        ]
    ]
    tool-button: [
        tags: [internal tab]
        facets: [
            init-size: 100x100
            min-size: 10x10
            bg-color: none
            draw-mode: 'normal
            padding: [0x0 0x0]
            margin: [0x0 0x0]
            text: none
        ]
        options: [
            init-size: [pair!]
            text: [string!]
            image: [image!]
        ]
        draw: [
            normal: [
                image (viewport-box/center - 12) gob/data/facets/image
            ]
            highlight: [
                pen 178.178.178
                grad-pen viewport-box/center (negate viewport-box/center/x) viewport-box/center/x 70 [230.230.230 210.210.210]
                box 1x1 (viewport-box/bottom-right - 2) 4.0
                image (viewport-box/center - (gob/data/facets/image/size * 0.5)) gob/data/facets/image
            ]
            down: [
                pen 178.178.178
                grad-pen viewport-box/center (negate viewport-box/center/x) viewport-box/center/x 70 [180.180.180 200.200.200]
                box 1.5x1.5 (viewport-box/bottom-right - 2.5) 4.0
                grad-pen off
                fill-pen off
                pen 148.148.148.191
                box 1x1 (viewport-box/bottom-right - 2) 4.0
                image (viewport-box/center - (gob/data/facets/image/size * 0.5) + 1) gob/data/facets/image
            ]
        ]
        actors: [
            on-over: [
                set-facet face 'draw-mode either arg [
                    'highlight
                ] [
                    'normal
                ]
                draw-face face
            ]
            on-click: [
                either arg/type = 'down [
                    set-facet face 'draw-mode 'down
                    draw-face face
                ] [
                    unfocus
                    focus face
                    do-face face
                ]
                true
            ]
            on-focus: [
                set-facet face 'draw-mode either all [arg/1 not arg/2] [
                    'highlight
                ] [
                    'normal
                ]
                draw-face face
            ]
            on-key: [
                if arg/type = 'key [
                    switch arg/key [
                        #" " [
                            do-face face
                        ]
                    ]
                ]
            ]
            on-init: [
                face/facets/min-size:
                face/facets/max-size:
                face/facets/init-size: 40x40
            ]
        ]
    ]
    tool-bar: hgroup [
        tags: [compound]
        facets: [
            padding: [0x0 0x0]
            spacing: 3x1
        ]
        options: [
            init-hint: [pair!]
            tools-data: [block!]
        ]
        content: []
        actors: [
            on-init: [
                blk: copy []
                img: title: action: lay: none
                parse face/facets/tools-data [
                    some [
                        set img image! opt set title string! opt set action block! (
                            append blk compose/deep [
                                tool-button (img) (any [title []]) on-action [(action)] options [tool-tip: (any [title "nothing"])]
                            ]
                        )
                        | 'layout set lay block! (append blk lay)
                        | 'bar (
                            append blk [div options [max-size: 3x35 valign: 'middle bg-color: gray]]
                        )
                        | 'break (
                            append blk 'return
                        )
                    ]
                ]
                set-content/no-show face blk
            ]
        ]
    ]
]
system/view/event-port: none
init-view-system