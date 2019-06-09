module Routes exposing (..)

import Url.Builder exposing (relative)
import Browser exposing (element, UrlRequest (..))
import Url exposing (Url, toString)
import Url.Parser exposing (Parser, parse, map, oneOf, top, s)
import Browser.Navigation exposing (Key, pushUrl, load)
import Common exposing (GlobalMsg (..), withLog)
import Task

type Msg
  = LinkClicked UrlRequest
  | UrlChanged Url

type AuthRoute = Login | Signin

type Route
  = Auth AuthRoute
  | Application
  | NotFound

type alias Model =
  { route : Route
  , key : Key
  , url : Url
  }

initialModel : Url -> Key -> Model
initialModel url key =
  { url = url
  , key = key
  , route = toRoute url
  }

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
  Auth subRoute -> case subRoute of
    Signin -> relative ["signin"] []
    Login -> relative ["login"] []
  Application -> relative ["/"] []
  NotFound -> relative ["404"] []

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  LinkClicked urlRequest ->
    case urlRequest of
      Internal url ->
        (model, pushUrl model.key (toString url))
      External href ->
        (model, load href)
  UrlChanged url ->
    ({ model
    | url = url
    , route = toRoute url
    }, Cmd.none)

authorizedRoute : Bool -> Route -> Route
authorizedRoute isAuthorized route =
  if isAuthorized == True
    then Application
    else if route == Application then Auth Login else route

updateOutCmd : GlobalMsg -> Model -> Cmd Msg
updateOutCmd msg model =
  case msg of
    LoginSuccess _ -> pushUrl model.key (routeToUrl Application)
    SigninSuccess _ -> pushUrl model.key (routeToUrl Application)
    Logout -> pushUrl model.key (routeToUrl (Auth Login))
    (Authorized res) -> pushUrl model.key (routeToUrl (authorizedRoute res model.route))
    _ -> Cmd.none
