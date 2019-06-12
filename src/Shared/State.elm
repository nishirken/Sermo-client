module Shared.State exposing (..)

import Browser.Navigation exposing (Key)
import Common
import Routes.Route as Route

type Msg
  = Login Common.AuthResponse
  | Logout
  | Authorized Bool
  | RouteChanged Route.Route

type alias Model =
  { navigationKey : Key
  , token : String
  , isAuthorized : Bool
  , userId : Maybe Int
  , currentRoute : Route.Route
  }

initialModel : Key -> String -> Maybe Int -> Model
initialModel key token userId =
  { navigationKey = key
  , token = token
  , isAuthorized = False
  , userId = userId
  , currentRoute = Route.Auth Route.Login
  }

update : Msg -> Model -> Model
update msg model =
  case msg of
    (Login { id, token }) -> ({ model | userId = Just id, token = token, isAuthorized = True })
    Logout -> ({ model | token = "", userId = Nothing, isAuthorized = False })
    (Authorized isAuthorized) -> ({ model | isAuthorized = isAuthorized })
    (RouteChanged newRoute) -> ({ model | currentRoute = newRoute })
