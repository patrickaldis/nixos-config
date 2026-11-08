{-  Helpers shared by the layouts in this directory.

    `./lib` is monpad's own Dhall library, which the builder in ../default.nix
    copies in alongside these files, so the relative imports below resolve just
    as they do in monpad's own `dhall/` directory. The builder also swaps
    `lib/Prelude.dhall` for a copy from nixpkgs, since upstream's is a remote
    import and the Nix sandbox has no network.
-}
let AllOS = ./lib/all-os.dhall

let Evdev = ./lib/evdev.dhall

let monpad = ./lib/monpad.dhall AllOS.Axis AllOS.Button

{-  Buttons and axes carry one payload per supported OS. Only the Linux (evdev)
    backend is implemented upstream - `lib/windows.dhall` and `lib/mac.dhall`
    both define their payload as the empty record - so every element built here
    fills in `linux` and leaves the other two empty.
-}
let keyData = λ(k : Evdev.Key) → { linux = k, windows = {=}, mac = {=} }

{-  Relative axes: the multiplier is how far one full deflection travels, in
    device units. Only `Rel*` axes are used by these layouts - `Abs*` would
    make the virtual device look like a joystick rather than a mouse.
-}
let relAxis =
      λ(a : Evdev.RelAxis) →
      λ(multiplier : Integer) →
        { linux = { axis = Evdev.Axis.Rel a, multiplier }
        , windows = {=}
        , mac = {=}
        }

let rgb =
      λ(r : Double) →
      λ(g : Double) →
      λ(b : Double) →
        { red = r, green = g, blue = b, alpha = 1.0 }

-- The sway theme from modules/sway.nix, so the controller matches the machine.
let cols =
      { lilac = rgb 0.741 0.561 0.910
      , periwinkle = rgb 0.561 0.592 0.910
      , slate = rgb 0.376 0.400 0.592
      , ink = rgb 0.282 0.302 0.435
      , danger = rgb 0.878 0.424 0.459
      , white = rgb 1.0 1.0 1.0
      }

let label =
      λ(size : Natural) →
      λ(text : Text) →
        Some
          { text
          , style =
              monpad.noTextStyle ⫽ { size, colour = cols.white, bold = True }
          , alignX = monpad.PosX.Centre
          , alignY = monpad.PosY.Middle
          }

{-  `name` is the element id monpad keys its button/axis maps on, so it has to
    be unique within a layout; `label` is only what gets drawn. They're
    separate so that e.g. an arrow key can be named "Up" but drawn as "↑".
-}
let KeySpec =
      { Type =
          { x : Integer
          , y : Integer
          , key : Evdev.Key
          , name : Text
          , label : Text
          , labelSize : Natural
          , colour : monpad.Colour
          }
      , default = { labelSize = 60, colour = cols.periwinkle }
      }

let round =
      λ(radius : Natural) →
      λ(k : KeySpec.Type) →
        monpad.Elem::{
        , element =
            monpad.Element.Button
              { buttonData = keyData k.key
              , colour = k.colour
              , shape = monpad.Shape.Circle radius
              }
        , location = { x = k.x, y = k.y }
        , name = k.name
        , text = label k.labelSize k.label
        }

-- `Rectangle` takes the full width and height, unlike `Circle`'s radius.
let rect =
      λ(size : monpad.V2 Natural) →
      λ(k : KeySpec.Type) →
        monpad.Elem::{
        , element =
            monpad.Element.Button
              { buttonData = keyData k.key
              , colour = k.colour
              , shape = monpad.Shape.Rectangle size
              }
        , location = { x = k.x, y = k.y }
        , name = k.name
        , text = label k.labelSize k.label
        }

in  { monpad
    , Evdev
    , Key = Evdev.Key
    , RelAxis = Evdev.RelAxis
    , keyData
    , relAxis
    , rgb
    , cols
    , label
    , KeySpec
    , round
    , rect
    }
