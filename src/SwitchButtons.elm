module SwitchButtons exposing (..)

import Browser
import Html exposing (Html, a, text, div)
import Html.Attributes exposing (href)
import Common exposing (testAttr)

switchButtonsView : Html msg
switchButtonsView = 
  div [] [
    a [href "/login", testAttr "login-link"] [text "Login"]
    , a [href "/signin", testAttr "signin-link"] [text "Signin"]
  ]
