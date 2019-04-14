module App.Main exposing (..)

import Http
import Html
import Browser
import Common
import Auth.Logout as Logout

application = Browser.element
  { init = \_ -> (initialModel, Cmd.none)
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

type alias Model = { user : User, error : String }

initialModel = Model (User 0 "" (Friends [])) ""

type Msg
  = LoadUser
  | DataReceived (Result Http.Error User)
  | LogoutMsg Common.GlobalMsg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoadUser -> (model, Cmd.none)
    DataReceived result ->
      case result of
        Ok res -> ({ model | user = res }, Cmd.none)
        Err httpError -> ({ model | error = Common.errorMessage httpError }, Cmd.none)
    _ -> (model, Cmd.none)

outMsg : Msg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (LogoutMsg subMsg) -> subMsg
    _ -> Common.None

view : Model -> Html.Html Msg
view model = Html.div []
  [ Html.text "Application"
  , Html.map LogoutMsg (Logout.view (\_ -> ()))
  ]
