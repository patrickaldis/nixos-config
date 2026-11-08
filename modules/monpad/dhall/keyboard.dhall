{-  A full QWERTY keyboard, for landscape.

    Modifiers are plain buttons like any other, so monpad sends a key-down on
    touch and a key-up on release. Because the frontend tracks several touches
    at once, holding Shift (or Ctrl/Alt/Super) with one thumb and tapping a
    letter with the other behaves exactly like a physical keyboard, rather than
    needing a sticky-key layer.

    The keycodes are positional, as evdev keycodes always are: they name
    physical keys, and the target machine's own XKB layout decides what
    character each one produces. These labels assume a GB/US layout, matching
    modules/sway.nix.
-}
let c = ./common.dhall

let monpad = c.monpad

let Prelude = ./lib/Prelude.dhall

let KeyCap = { key : c.Key, label : Text }

let Indexed = { index : Natural, value : KeyCap }

let unit = { x = 180, y = 160 }

let step = 190

{-  Lay `caps` out left to right from `x0`, one `step` apart. Each key's label
    doubles as its element id, which monpad requires to be unique within a
    layout - true here because no label repeats.
-}
let row =
      λ(y : Integer) →
      λ(x0 : Integer) →
      λ(labelSize : Natural) →
      λ(caps : List KeyCap) →
        Prelude.List.map
          Indexed
          monpad.FullElement
          ( λ(e : Indexed) →
              c.rect
                unit
                c.KeySpec::{
                , x = Prelude.Integer.add x0 (Natural/toInteger (e.index * step))
                , y
                , key = e.value.key
                , name = e.value.label
                , label = e.value.label
                , labelSize
                }
          )
          (Prelude.List.indexed KeyCap caps)

-- Keys that need their own width, or that sit apart from a row's grid.
let wide =
      λ(width : Natural) →
      λ(k : c.KeySpec.Type) →
        c.rect { x = width, y = unit.y } (k ⫽ { labelSize = 36 })

in    { elements =
          row
            +255
            -855
            70
            [ { key = c.Key.KeyQ, label = "q" }
            , { key = c.Key.KeyW, label = "w" }
            , { key = c.Key.KeyE, label = "e" }
            , { key = c.Key.KeyR, label = "r" }
            , { key = c.Key.KeyT, label = "t" }
            , { key = c.Key.KeyY, label = "y" }
            , { key = c.Key.KeyU, label = "u" }
            , { key = c.Key.KeyI, label = "i" }
            , { key = c.Key.KeyO, label = "o" }
            , { key = c.Key.KeyP, label = "p" }
            ]
        # row
            +85
            -760
            70
            [ { key = c.Key.KeyA, label = "a" }
            , { key = c.Key.KeyS, label = "s" }
            , { key = c.Key.KeyD, label = "d" }
            , { key = c.Key.KeyF, label = "f" }
            , { key = c.Key.KeyG, label = "g" }
            , { key = c.Key.KeyH, label = "h" }
            , { key = c.Key.KeyJ, label = "j" }
            , { key = c.Key.KeyK, label = "k" }
            , { key = c.Key.KeyL, label = "l" }
            ]
        # row
            -85
            -760
            70
            [ { key = c.Key.KeyZ, label = "z" }
            , { key = c.Key.KeyX, label = "x" }
            , { key = c.Key.KeyC, label = "c" }
            , { key = c.Key.KeyV, label = "v" }
            , { key = c.Key.KeyB, label = "b" }
            , { key = c.Key.KeyN, label = "n" }
            , { key = c.Key.KeyM, label = "m" }
            , { key = c.Key.KeyComma, label = "," }
            , { key = c.Key.KeyDot, label = "." }
            ]
        # row
            -255
            -950
            36
            [ { key = c.Key.KeyEsc, label = "Esc" }
            , { key = c.Key.KeyTab, label = "Tab" }
            , { key = c.Key.KeyLeftctrl, label = "Ctrl" }
            , { key = c.Key.KeyLeftalt, label = "Alt" }
            , { key = c.Key.KeyLeftmeta, label = "Super" }
            ]
        # [ wide
              180
              c.KeySpec::{
              , x = +950
              , y = +85
              , key = c.Key.KeyBackspace
              , name = "Backspace"
              , label = "Bksp"
              , colour = c.cols.danger
              }
          , wide
              180
              c.KeySpec::{
              , x = -950
              , y = -85
              , key = c.Key.KeyLeftshift
              , name = "Shift"
              , label = "Shift"
              , colour = c.cols.slate
              }
          , wide
              180
              c.KeySpec::{
              , x = +950
              , y = -85
              , key = c.Key.KeySlash
              , name = "Slash"
              , label = "/"
              , colour = c.cols.periwinkle
              }
          , wide
              680
              c.KeySpec::{
              , x = +250
              , y = -255
              , key = c.Key.KeySpace
              , name = "Space"
              , label = "Space"
              , colour = c.cols.lilac
              }
          , wide
              370
              c.KeySpec::{
              , x = +780
              , y = -255
              , key = c.Key.KeyEnter
              , name = "Enter"
              , label = "Enter"
              , colour = c.cols.lilac
              }
          ]
      , viewBox = { x = -1050, y = -340, w = 2100, h = 680 }
      , backgroundColour = c.cols.ink
      , name = "keyboard"
      }
    : monpad.Layout
