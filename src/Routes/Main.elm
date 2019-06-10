module Routes.Main exposing (..)

import Url.Builder exposing (relative)
import Browser exposing (element, UrlRequest (..))
import Url exposing (Url, toString, fromString)
import Url.Parser exposing (Parser, parse, map, oneOf, top, s)
import Browser.Navigation exposing (Key, pushUrl, load)
import Common exposing (GlobalMsg (..), withLog)
import Task
import SharedState
import Routes.Route exposing (..)

type Msg
  = LinkClicked UrlRequest
  | UrlChanged Url

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

routeToUrl : Route -> Url -> Url
routeToUrl route currentUrl =
  let stringUrl = case route of
    Auth subRoute -> case subRoute of
      Signin -> relative ["signin"] []
      Login -> relative ["login"] []
    Application -> relative ["/"] []
    NotFound -> relative ["404"] [] in (Maybe.withDefault (fromString stringUrl) currentUrl)

update : Msg -> Model -> SharedState.Model -> (Model, Cmd Msg, Maybe SharedState.Msg)
update msg model sharedModel = case msg of
  LinkClicked urlRequest ->
    case urlRequest of
      Internal url ->
        (model, pushUrl sharedModel.navigationKey (toString url), Nothing)
      External href ->
        (model, load href, Nothing)
  UrlChanged url ->
    ({ model | url = url }, Cmd.none, Just (SharedState.RouteChanged (toRoute url)))

type alias GoToRoute = Route -> Msg

goToRoute : GoToRoute
goToRoute route = LinkClicked (Internal (routeToUrl route))
