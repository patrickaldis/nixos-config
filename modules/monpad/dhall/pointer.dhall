{-  Mouse: a trackpad-style stick for pointer motion, the three mouse buttons,
    and a scroll wheel down the right-hand edge.

    Portrait, laid out for one-handed use: the stick sits under the thumb and
    the buttons below it.
-}
let c = ./common.dhall

let monpad = c.monpad

in    { elements =
        [ {-  Relative motion, so each message nudges the pointer rather than
                warping it to an absolute position. Y is negated because monpad's
                Y axis points up and evdev's points down.
            -}
          monpad.Elem::{
          , element =
              monpad.Element.Stick
                { radius = 150
                , range = 380
                , stickColour = c.cols.lilac
                , backgroundColour = c.cols.slate
                , stickDataX = c.relAxis c.RelAxis.RelX +15
                , stickDataY = c.relAxis c.RelAxis.RelY -15
                }
          , location = { x = -100, y = +1030 }
          , name = "Pointer"
          }
        , {-  RelWheel is counted in notches, so the multiplier here is much
                smaller than the pointer's. `resetOnRelease` (set by
                `simpleSlider`) springs it back to centre, which stops a
                released slider from scrolling forever.
            -}
          monpad.Elem::{
          , element =
              monpad.simpleSlider
                { radius = 95
                , length = 1050
                , width = 110
                , sliderColour = c.cols.lilac
                , backgroundColour = c.cols.slate
                , vertical = True
                , sliderData = c.relAxis c.RelAxis.RelWheel +5
                }
          , location = { x = +380, y = +500 }
          , name = "Scroll"
          }
        , c.round
            170
            c.KeySpec::{
            , x = -330
            , y = +250
            , key = c.Key.BtnLeft
            , name = "Left"
            , label = "L"
            }
        , c.round
            120
            c.KeySpec::{
            , x = +0
            , y = +250
            , key = c.Key.BtnMiddle
            , name = "Middle"
            , label = "M"
            , labelSize = 50
            , colour = c.cols.slate
            }
        , c.round
            170
            c.KeySpec::{
            , x = +330
            , y = +250
            , key = c.Key.BtnRight
            , name = "Right"
            , label = "R"
            }
        ]
      , viewBox = { x = -500, y = +0, w = 1000, h = 1620 }
      , backgroundColour = c.cols.ink
      , name = "pointer"
      }
    : monpad.Layout
