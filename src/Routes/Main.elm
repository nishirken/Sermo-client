module Routes.Main exposing (..)

import Url.Builder exposing (relative)
import Browser exposing (element, UrlRequest (..))
import Url exposing (Url, toString, fromString)
import Url.Parser exposing (Parser, parse, map, oneOf, top, s)
import Browser.Navigation exposing (Key, pushUrl, load)
import Common exposing (GlobalMsg (..), withLog)
import Task
import Shared.Update exposing (Update, UpdateResult)
import Shared.State
import Routes.Route exposing (..)
import Routes.Msg exposing (..)

type alias Model = { url : Url }

initialModel : Url -> Model
initialModel = Model

matchAuthRoute : Parser (AuthRoute -> a) a
matchAuthRoute =
  oneOf
    [ map Signin (s "signin")
    , map Login (s "login")
    ]

matchRoute : Parser (Route -> a) a
matchRoute =
  oneOf
    [ map Auth matchAuthRoute
    , map Application top
    ]

toRoute : Url -> Route
toRoute url = Maybe.withDefault NotFound (parse matchRoute url)

routeToUrl : Route -> String
routeToUrl route = case route of
  (Auth subRoute) -> case subRoute of
    Signin -> relative ["signin"] []
    Login -> relative ["login"] []
  Application -> relative ["/"] []
  NotFound -> relative ["404"] []

update : Update Msg Model
update msg model sharedModel = case msg of
  LinkClicked urlRequest ->
    case urlRequest of
      Internal url ->
        UpdateResult model (pushUrl sharedModel.navigationKey (toString url)) Nothing Cmd.none
      External href ->
        UpdateResult model (load href) Nothing Cmd.none
  UrlChanged url ->
    UpdateResult { model | url = url } Cmd.none (Just (Shared.State.RouteChanged (toRoute url))) Cmd.none

type alias GoToRoute = Key -> Route -> Cmd Msg

goToRoute : GoToRoute
goToRoute key route = pushUrl key (routeToUrl route)
