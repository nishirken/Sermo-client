module Common exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)

type Route
  = Signin
  | Login
  | Application
  | NotFound

testAttr : String -> Attribute msg
testAttr name = attribute "data-e2e" name
