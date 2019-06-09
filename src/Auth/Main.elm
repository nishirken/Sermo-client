port module Auth.Main exposing (..)

import Browser
import Http
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
import Html.Styled exposing (div, Html, toUnstyled, map)
import Html.Styled.Attributes exposing (style)
import Auth.Common as AuthCommon
import Auth.SigninButton
import Auth.SigninForm
import Auth.LoginForm
import Auth.LoginButton
import Auth.Logout
import Common
import Routes
import Task
import SharedState

type alias Model =
  { loginModel : AuthCommon.InFormModel
  , signinModel : AuthCommon.InFormModel
  }

type Msg
  = LoginFormMsg AuthCommon.InFormMsg
  | SigninFormMsg AuthCommon.InFormMsg
  | AuthorizedSend
  | DataReseived (Result Http.Error (Common.JSONResponse Bool))

initialModel =
  Model AuthCommon.initialInFormModel AuthCommon.initialInFormModel

initCmd : Cmd Msg
initCmd = Task.perform (\_ -> AuthorizedSend) (Task.succeed ())

authEncoder : String -> JsonEncode.Value
authEncoder token = JsonEncode.object [("token", JsonEncode.string token)]

update : Msg -> Model -> SharedState.Model -> (Model, Cmd Msg, Maybe SharedState.Msg)
update msg model { token } =
  case msg of
    (LoginFormMsg subMsg) -> let (updatedModel, updatedCmd, stateMsg) = Auth.LoginForm.update subMsg model.loginModel in
      ({ model | loginModel = updatedModel }, Cmd.map LoginFormMsg updatedCmd, stateMsg)
    (SigninFormMsg subMsg) ->
      let (updatedModel, updatedCmd, stateMsg) = Auth.SigninForm.update subMsg model.signinModel in
        ({ model | signinModel = updatedModel }, Cmd.map SigninFormMsg updatedCmd, Nothing)
    AuthorizedSend -> (model, Http.post
      { url = "http://localhost:8080/auth"
      , body = Http.jsonBody (authEncoder token)
      , expect = Common.expectJsonResponse Common.successDecoder DataReseived
      }, Nothing)
    DataReseived result -> case Common.getJsonData result of
      (Just isAuthorized) -> (model, Cmd.none, Just (SharedState.Authorized isAuthorized))
      Nothing -> (model, Cmd.none, Nothing)

form : Model -> Routes.AuthRoute -> Html Msg
form { loginModel, signinModel } authRoute = case authRoute of
  Routes.Login -> map LoginFormMsg (Auth.LoginForm.view loginModel)
  Routes.Signin -> map SigninFormMsg (Auth.SigninForm.view signinModel)

authButton : Routes.AuthRoute -> Html Msg
authButton route =
  case route of
    (Routes.Login) -> Auth.SigninButton.view
    (Routes.Signin) -> Auth.LoginButton.view

view : Model -> SharedState.Model -> Html Msg
view model { currentRoute } =
  let
    route = case currentRoute of
      (Routes.Auth r) -> r
      _ -> Routes.Login
      in
        div [style "display" "flex", style "flex-direction" "column", style "align-items" "center"]
          [ authButton route
          , form model route
          ]
