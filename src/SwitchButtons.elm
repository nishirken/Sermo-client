module SwitchButtons exposing (..)

import Browser
import Html exposing (Html, a, text, div)
import Html.Attributes exposing (href)

switchButtonsView : Html msg
switchButtonsView = 
  div [] [
    a [href "/login"] [text "Login"]
    , a [href "/signin"] [text "Signin"]
    , a [href "/"] [text "Home"]
  ]
