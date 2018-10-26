module Main exposing (..)

import Browser
import Html exposing (button, h1, text, div)
import Html.Events exposing (onClick)
import Http exposing (post, send, jsonBody)
import Json.Decode exposing (Decoder (..), field, string)
import Json.Encode as E
import GlobalState exposing (..)

main =
  Browser.document {
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

view : GlobalState -> Browser.Document LoginMsg
view model =
  {
    title = "Sermo"
    , body = [
        div [] [
          h1 [] [text "App"]
          , button [onClick SendLogin] [text "Login"]
        ]
    ]
  }
