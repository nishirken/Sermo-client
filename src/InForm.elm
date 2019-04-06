module InForm exposing (..)

import Browser
import Html exposing (Html, button, h3, div, input, text)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput)
import Browser.Navigation as Nav
import Http
import Json.Decode exposing (Decoder (..), field, string)
import Json.Encode as E
import Common exposing (
  successDecoder
  , JSONError
  , errorMessage
  , GlobalMsg (..)
  , responseDecoder
  , JSONResponse
  , expectJsonResponse
  , getJsonData
  , getJsonError
  )
import Routes exposing (Route (..))

loginForm = Browser.element
  { init = \_ -> (initialModel, Cmd.none)
  , update = updateLogin
  , view = loginFormView
  , subscriptions = \_ -> Sub.none
  }

signinForm = Browser.element
  { init = \_ -> (initialModel, Cmd.none)
  , update = updateSignin
  , view = signinFormView
  , subscriptions = \_ -> Sub.none
  }

initialModel = Model "" "" ""

type alias Model =
  { email : String
  , password : String
  , error : String
  }

type Msg a
  = Send
  | Email String
  | Password String
  | DataReseived (Result Http.Error (JSONResponse a))

type alias SigninMsg = Msg Bool
type alias LoginMsg = Msg String

loginDecoder : Decoder String
loginDecoder = field "token" string

loginRequest : Model -> Http.Body
loginRequest { email, password } =
  Http.jsonBody (E.object [("email", E.string email), ("password", E.string password)])  

updateLogin : LoginMsg -> Model -> (Model, Cmd LoginMsg)
updateLogin msg model =
  case msg of
    Email email -> ({ model | email = email }, Cmd.none)
    Password password -> ({ model | password = password }, Cmd.none)
    Send -> (model, Http.post
      { url = "http://localhost:8080/login"
      , body = loginRequest model
      , expect = expectJsonResponse loginDecoder DataReseived
      })
    DataReseived result ->
      case result of
        Ok res -> let error = getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none)
            Nothing -> (model, Cmd.none)
        Err httpError -> ({ model | error = errorMessage httpError }, Cmd.none)

updateSignin : SigninMsg -> Model -> (Model, Cmd SigninMsg)
updateSignin msg model =
  case msg of
    Email email -> ({ model | email = email }, Cmd.none)
    Password password -> ({ model | password = password }, Cmd.none)
    Send -> (model, Http.post
      { url = "http://localhost:8080/signin"
      , body = loginRequest model
      , expect = expectJsonResponse successDecoder DataReseived
      })
    DataReseived result ->
      case result of
        Ok res -> let error = getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none)
            Nothing -> (model, Cmd.none)
        Err httpError ->
            ({ model | error = errorMessage httpError }, Cmd.none)

outLoginMsg : LoginMsg -> GlobalMsg
outLoginMsg msg =
  case msg of
    (DataReseived res) -> let data = getJsonData res in case data of
      (Just token) -> LoginSuccess token
      Nothing -> None
    _ -> None

outSigninMsg : SigninMsg -> GlobalMsg
outSigninMsg msg =
  case msg of
    (DataReseived res) -> let data = getJsonData res in case data of
      (Just _) -> SigninSuccess
      _ -> None
    _ -> None

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

inFormView : Model -> Route -> Html (Msg a)
inFormView model route =
  let t = (text << formText) route in
    div [] [
        h3 [] [t]
        , formInput "email" model.email Email
        , formInput "password" model.password Password
        , button [onClick Send] [t]
        , div [] [text model.error]
    ]

loginFormView : Model -> Html LoginMsg
loginFormView model = inFormView model Login

signinFormView : Model -> Html SigninMsg
signinFormView model = inFormView model Signin
