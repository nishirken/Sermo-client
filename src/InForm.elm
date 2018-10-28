module InForm exposing (..)

import Browser
import Html exposing (Html, button, h3, div, input, text)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput)
import Http exposing (post, send, jsonBody)
import Json.Decode exposing (Decoder (..), field, string)
import Json.Encode as E
import GlobalState exposing (..)
import Common exposing (Route (..))

loginForm = Browser.element
  { init = \_ -> initialModel
  , update = update
  , view = loginFormView
  , subscriptions = \_ -> Sub.none
  }

signinForm = Browser.element
  { init = \_ -> initialModel
  , update = update
  , view = signinFormView
  , subscriptions = \_ -> Sub.none
  }

initialModel = (Model "" "", Cmd.none)

type alias Model =
  { email : String
  , password : String
  }

type Msg
  = Send String
  | Email String
  | Password String
  | DataReseived (Result Http.Error String)

loginDecoder = field "token" string
loginRequest { email, password } =
    jsonBody (E.object [("email", E.string email), ("password", E.string password)])

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Email email -> ({ model | email = email }, Cmd.none)
        Password password -> ({ model | password = password }, Cmd.none)
        Send to -> (model, send DataReseived (post ("http://localhost:8080/" ++ to) (loginRequest model) loginDecoder))
        DataReseived result ->
            case result of
                Ok res -> (model, Cmd.none)
                Err httpError -> (model, Cmd.none)

formInput : String -> String -> (String -> msg) -> Html msg
formInput p v toMsg =
    input
    [A.type_ "text", onInput toMsg, A.placeholder p, A.required True, A.value v]
    []

formText : Route -> String
formText route =
  case route of
    Login -> "Login"
    Signin -> "Signin"
    _ -> ""

toSend : Route -> String
toSend route =
  case route of
    Login -> "login"
    Signin -> "signin"
    _ -> ""

inFormView : Model -> Route -> Html Msg
inFormView model route =
  let t = (text << formText) route in
    div [] [
        h3 [] [t]
        , formInput "email" model.email Email
        , formInput "password" model.password Password
        , button [onClick ((Send << toSend) route)] [t]
    ]

loginFormView : Model -> Html Msg
loginFormView model = inFormView model Login

signinFormView : Model -> Html Msg
signinFormView model = inFormView model Signin
