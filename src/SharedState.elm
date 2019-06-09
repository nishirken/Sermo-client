module SharedState exposing (..)

import Common
import Routes

type Msg
  = Login Common.AuthResponse
  | Logout
  | Authorized Bool
  | RouteChanged Routes.Route

type alias Model =
  { token : String
  , isAuthorized : Bool
  , userId : Maybe Int
  , currentRoute : Routes.Route
  }

initModel : Model
initModel =
  { token = ""
  , isAuthorized = False
  , userId = Nothing
  , currentRoute = Routes.Auth Routes.Login
  }

update : Msg -> Model -> Model
update msg model =
  case msg of
    (Login { id, token }) -> ({ model | userId = Just id, token = token, isAuthorized = True })
    Logout -> ({ model | token = "", userId = Nothing })
    (Authorized isAuthorized) -> ({ model | isAuthorized = isAuthorized })
    (RouteChanged newRoute) -> ({ model | currentRoute = newRoute })
