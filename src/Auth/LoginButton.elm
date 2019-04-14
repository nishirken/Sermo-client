module Auth.LoginButton exposing (..)

import Browser
import Html exposing (Html, a, text, div, button)
import Html.Attributes exposing (href)

view : Html msg
view = 
  button [] [
    a [href "/login"] [text "Login"]
  ]
