module Auth.LoginButton exposing (..)

import Browser
import Html.Styled exposing (Html, a, text, div, button)
import Html.Styled.Attributes exposing (href)

view : Html msg
view = 
  button [] [
    a [href "/login"] [text "Login"]
  ]
