module Main exposing (..)

import Browser
import Html exposing (Html, button, h1, text, div)
import Html.Events exposing (onClick)
import Http exposing (header, post, send, getString, jsonBody)
import Json.Decode exposing (Decoder (..), field, string)
import Json.Encode as E
import GlobalState exposing (..)

main =
  Browser.element {
      init = init
      , update = update
      , view = view
      , subscriptions = subscriptions
      }

init : () -> (GlobalState, Cmd LoginMsg)
init _ = (GlobalState "", Cmd.none)

subscriptions : GlobalState -> Sub LoginMsg
subscriptions model = Sub.none

type LoginMsg
    = SendLogin
    | DataReseived (Result Http.Error String)

type alias LoginRequest =
    { 
        email : String
        , password : String 
    }

loginDecoder = field "token" string
loginRequest = jsonBody (E.object [("email", E.string "mail@gmail.com"), ("password", E.string "123456")])

update : LoginMsg -> GlobalState -> (GlobalState, Cmd LoginMsg)
update msg state =
    case msg of
        SendLogin -> (state, send DataReseived (post "http://localhost:8080/login" loginRequest loginDecoder))
        DataReseived result ->
            case result of
                Ok res -> (state, Cmd.none)
                Err httpError -> (state, Cmd.none)

view : GlobalState -> Html LoginMsg
view model =
    div [] [
        h1 [] [text "Application"]
        , button [onClick SendLogin] [text "Login"]
    ]
