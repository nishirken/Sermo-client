module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Url.Parser exposing (Parser, oneOf, map, s)
import Html exposing (text, h1, div)
import Html.Attributes exposing (href)
import GlobalState exposing (..)
import Url.Parser exposing (Parser, parse, map, oneOf, top, s)
import Url
import SwitchButtons exposing (switchButtonsView)
import Common exposing (Route (..))
import InForm

type alias Model =
  { key : Nav.Key
  , url: Url.Url
  , route: Route
  , formModel : (InForm.Model, Cmd InForm.Msg)
  }

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | FormMsg InForm.Msg

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
    , formModel = InForm.initialModel
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
    UrlChanged url ->
      ({ model | url = url, route = toRoute url }, Cmd.none)
    FormMsg subMsg -> let (updatedFormModel, formCmd) = InForm.update subMsg model.formModel in
      ({ model | formModel = updatedFormModel }, Cmd.map FormMsg formCmd)

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
            Signin -> Html.map FormMsg (InForm.signinFormView model.formModel)
            Login -> Html.map FormMsg (InForm.loginFormView model.formModel)
            Application -> div [] [text "Application"]
            NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
