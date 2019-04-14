module Auth.Main exposing (..)

import Browser
import Html exposing (div, Html)
import Html.Attributes exposing (style)
import Auth.Common as AuthCommon
import Auth.SigninButton
import Auth.SigninForm
import Auth.LoginForm
import Auth.LoginButton
import Auth.Logout
import Common
import Routes

type alias Model =
  { route : Routes.AuthRoute
  , loginModel : AuthCommon.InFormModel
  , signinModel : AuthCommon.InFormModel
  }

type Msg
  = LoginFormMsg Auth.LoginForm.LoginFormMsg
  | SigninFormMsg Auth.SigninForm.SigninFormMsg

initialModel = Model Routes.Login AuthCommon.initialInFormModel AuthCommon.initialInFormModel

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (LoginFormMsg subMsg) -> let (updatedModel, updatedCmd) = Auth.LoginForm.update subMsg model.loginModel in
      ({ model | loginModel = updatedModel }, Cmd.map LoginFormMsg updatedCmd)
    (SigninFormMsg subMsg) -> let (updatedModel, updatedCmd) = Auth.SigninForm.update subMsg model.signinModel in
      ({ model | signinModel = updatedModel }, Cmd.map SigninFormMsg updatedCmd)

outMsg : Msg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (LoginFormMsg subMsg) -> Auth.LoginForm.outMsg subMsg
    (SigninFormMsg subMsg) -> Auth.SigninForm.outMsg subMsg

form : Model -> Html Msg
form model = case model.route of
  Routes.Login -> Html.map LoginFormMsg (Auth.LoginForm.view model.loginModel)
  Routes.Signin -> Html.map SigninFormMsg (Auth.SigninForm.view model.signinModel)

authButton : Routes.AuthRoute -> Html Msg
authButton route =
  case route of
    (Routes.Login) -> Auth.SigninButton.view
    (Routes.Signin) -> Auth.LoginButton.view

view : Model -> Html Msg
view model =
  div [style "display" "flex", style "flex-direction" "column", style "align-items" "center"]
    [ authButton model.route
    , form model
    ]
