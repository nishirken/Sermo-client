module Auth.Logout exposing (..)

import Browser
import Common
import Html
import Html.Events exposing (onClick)

main = Browser.sandbox
  { init = \_ -> ()
  , update = \_ model -> model
  , view = view
  }

view : (a -> ()) -> Html.Html Common.GlobalMsg
view _ =
  Html.button [onClick Common.Logout] [Html.text "Logout"]
