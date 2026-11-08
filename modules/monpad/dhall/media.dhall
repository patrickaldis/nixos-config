{-  Media and display keys: transport controls, volume, and screen brightness.

    These are all the XF86* keys a desktop binds globally, so they work without
    the target window being focused - unlike the other layouts, which type into
    whatever happens to be in front.

    Labels are words rather than the usual ⏮/⏯/⏭ glyphs, which render
    inconsistently across phone browsers.
-}
let c = ./common.dhall

let monpad = c.monpad

in    { elements =
        [ c.round
            140
            c.KeySpec::{
            , x = -340
            , y = +1250
            , key = c.Key.KeyPrevioussong
            , name = "Previous"
            , label = "Prev"
            , labelSize = 46
            }
        , c.round
            190
            c.KeySpec::{
            , x = +0
            , y = +1250
            , key = c.Key.KeyPlaypause
            , name = "PlayPause"
            , label = "Play"
            , labelSize = 56
            , colour = c.cols.lilac
            }
        , c.round
            140
            c.KeySpec::{
            , x = +340
            , y = +1250
            , key = c.Key.KeyNextsong
            , name = "Next"
            , label = "Next"
            , labelSize = 46
            }
        , c.round
            175
            c.KeySpec::{
            , x = -310
            , y = +700
            , key = c.Key.KeyVolumedown
            , name = "VolumeDown"
            , label = "Vol -"
            , labelSize = 44
            }
        , c.round
            135
            c.KeySpec::{
            , x = +0
            , y = +700
            , key = c.Key.KeyMute
            , name = "Mute"
            , label = "Mute"
            , labelSize = 40
            , colour = c.cols.danger
            }
        , c.round
            175
            c.KeySpec::{
            , x = +310
            , y = +700
            , key = c.Key.KeyVolumeup
            , name = "VolumeUp"
            , label = "Vol +"
            , labelSize = 44
            }
        , c.round
            150
            c.KeySpec::{
            , x = -280
            , y = +230
            , key = c.Key.KeyBrightnessdown
            , name = "BrightnessDown"
            , label = "Dim"
            , labelSize = 42
            , colour = c.cols.slate
            }
        , c.round
            150
            c.KeySpec::{
            , x = +280
            , y = +230
            , key = c.Key.KeyBrightnessup
            , name = "BrightnessUp"
            , label = "Bright"
            , labelSize = 40
            , colour = c.cols.slate
            }
        ]
      , viewBox = { x = -500, y = +0, w = 1000, h = 1520 }
      , backgroundColour = c.cols.ink
      , name = "media"
      }
    : monpad.Layout
