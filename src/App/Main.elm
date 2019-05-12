module App.Main exposing (..)

import Http
import Html
import Browser
import Common
import Auth.Logout as Logout

application = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

type alias User =
  { id : Int
  , email : String
  , friends : Friends
  }

type Friends = Friends (List User)

type alias Model =
  { user : User
  , error : String
  , logoutModel : Logout.Model
  }

initialModel =
  { user = User 0 "" (Friends [])
  , error = ""
  , logoutModel = Logout.initialModel
  }

type Msg
  = LoadUser
  | DataReceived (Result Http.Error User)
  | LogoutMsg Logout.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (LogoutMsg subMsg) -> let (updatedModel, updatedCmd) = Logout.update subMsg model.logoutModel in
      ({ model | logoutModel = updatedModel }, Cmd.map LogoutMsg updatedCmd)
    LoadUser -> (model, Cmd.none)
    DataReceived result ->
      case result of
        Ok res -> ({ model | user = res }, Cmd.none)
        Err httpError -> ({ model | error = Common.errorMessage httpError }, Cmd.none)

outMsg : Msg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (LogoutMsg subMsg) -> Common.Logout
    _ -> Common.None

view : Model -> Html.Html Msg
view model = Html.div []
  [ Html.text "Application"
  , Html.map LogoutMsg (Logout.view model.logoutModel)
  ]
