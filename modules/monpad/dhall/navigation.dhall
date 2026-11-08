{-  Keyboard navigation: a d-pad of arrow keys with Enter in the middle, plus
    the modifiers and paging keys that are awkward to reach from the full
    keyboard layout.

    This is the one to reach for when driving a menu, a slideshow or a video
    player from across the room.
-}
let c = ./common.dhall

let monpad = c.monpad

let arrow = λ(k : c.KeySpec.Type) → c.round 150 (k ⫽ { labelSize = 90 })

let small = λ(k : c.KeySpec.Type) → c.round 130 (k ⫽ { labelSize = 40 })

in    { elements =
        [ arrow
            c.KeySpec::{
            , x = +0
            , y = +1380
            , key = c.Key.KeyUp
            , name = "Up"
            , label = "↑"
            }
        , arrow
            c.KeySpec::{
            , x = -320
            , y = +1080
            , key = c.Key.KeyLeft
            , name = "Left"
            , label = "←"
            }
        , arrow
            c.KeySpec::{
            , x = +320
            , y = +1080
            , key = c.Key.KeyRight
            , name = "Right"
            , label = "→"
            }
        , arrow
            c.KeySpec::{
            , x = +0
            , y = +780
            , key = c.Key.KeyDown
            , name = "Down"
            , label = "↓"
            }
        , c.round
            130
            c.KeySpec::{
            , x = +0
            , y = +1080
            , key = c.Key.KeyEnter
            , name = "Enter"
            , label = "Enter"
            , labelSize = 42
            , colour = c.cols.lilac
            }
        , c.round
            150
            c.KeySpec::{
            , x = -330
            , y = +430
            , key = c.Key.KeyEsc
            , name = "Escape"
            , label = "Esc"
            , labelSize = 46
            , colour = c.cols.danger
            }
        , c.round
            130
            c.KeySpec::{
            , x = +0
            , y = +430
            , key = c.Key.KeyTab
            , name = "Tab"
            , label = "Tab"
            , labelSize = 44
            , colour = c.cols.slate
            }
        , c.round
            150
            c.KeySpec::{
            , x = +330
            , y = +430
            , key = c.Key.KeyLeftmeta
            , name = "Super"
            , label = "Super"
            , labelSize = 42
            , colour = c.cols.lilac
            }
        , small
            c.KeySpec::{
            , x = -330
            , y = +140
            , key = c.Key.KeyPageup
            , name = "PageUp"
            , label = "PgUp"
            }
        , small
            c.KeySpec::{
            , x = +0
            , y = +140
            , key = c.Key.KeyBackspace
            , name = "Backspace"
            , label = "Bksp"
            , colour = c.cols.slate
            }
        , small
            c.KeySpec::{
            , x = +330
            , y = +140
            , key = c.Key.KeyPagedown
            , name = "PageDown"
            , label = "PgDn"
            }
        ]
      , viewBox = { x = -500, y = +0, w = 1000, h = 1600 }
      , backgroundColour = c.cols.ink
      , name = "navigation"
      }
    : monpad.Layout
