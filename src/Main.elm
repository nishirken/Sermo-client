module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Url.Parser exposing (Parser, oneOf, map, s)
import Html exposing (text, h1, div)
import Html.Attributes exposing (href)
import Url.Parser exposing (Parser, parse, map, oneOf, top, s)
import Url
import SwitchButtons exposing (switchButtonsView)
import InForm
import Common exposing (Route (..))
import Application

type alias Model =
  { key : Nav.Key
  , url : Url.Url
  , route : Route
  , loginModel : InForm.Model
  , signinModel : InForm.Model
  , appModel : Application.Model
  }

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | LoginMsg InForm.LoginMsg
  | SigninMsg InForm.SigninMsg
  | AppMsg Application.Msg

main = Browser.application
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  , onUrlRequest = LinkClicked
  , onUrlChange = UrlChanged
  }

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init _ url key =
  (
    { url = url
    , key = key
    , route = Login
    , loginModel = InForm.initialModel
    , singinModel = InForm.initialModel
    , appModel = Application.initialModel
    }
  , Cmd.none
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          (model, Nav.pushUrl model.key (Url.toString url))
        Browser.External href ->
          (model, Nav.load href)
    UrlChanged url -> (
      { model
      | url = url
      , route = toRoute url
      },
      Cmd.none
      )

matchRoute : Parser (Route -> a) a
matchRoute =
  oneOf
    [ map Signin (s "signin")
    , map Login (s "login")
    , map Application top
    ]

toRoute : Url.Url -> Route
toRoute url = Maybe.withDefault NotFound (parse matchRoute url)

view : Model -> Browser.Document Msg
view model =
  {
    title = "Application"
    , body = [
        switchButtonsView
        , div [] [
          case model.route of
            Signin -> Html.map SigninMsg (InForm.signinFormView model.signinModel)
            Login -> Html.map LoginMsg (InForm.loginFormView model.loginModel)
            Application -> Html.map AppMsg (Application.view model.appModel)
            NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
