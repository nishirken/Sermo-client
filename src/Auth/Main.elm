port module Auth.Main exposing (..)

import Browser
import Http
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
import Html.Styled exposing (div, Html, toUnstyled, map)
import Html.Styled.Attributes exposing (style)
import Auth.Common as AuthCommon
import Auth.SigninForm
import Auth.LoginForm
import Auth.Logout
import Auth.Buttons
import Common
import Routes.Main as Routes
import Routes.Route as Route
import Task
import Shared.Update exposing (Update, UpdateResult)
import Shared.State

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

update : Update Msg Model
update msg model sharedModel =
  case msg of
    (LoginFormMsg subMsg) ->
      let
        updatedResult : UpdateResult AuthCommon.InFormModel AuthCommon.InFormMsg
        updatedResult = Auth.LoginForm.update subMsg model.loginModel sharedModel
        { updatedModel, updatedCmd, stateMsg, routeCmd } = updatedResult
          in UpdateResult { model | loginModel = updatedModel } (Cmd.map LoginFormMsg updatedCmd) stateMsg routeCmd
    (SigninFormMsg subMsg) ->
      let
        { updatedModel, updatedCmd, stateMsg, routeCmd } = Auth.SigninForm.update subMsg model.signinModel sharedModel in
        UpdateResult { model | signinModel = updatedModel } (Cmd.map SigninFormMsg updatedCmd) stateMsg routeCmd
    AuthorizedSend -> UpdateResult
      model
      (Http.post
        { url = "http://localhost:8080/auth"
        , body = Http.jsonBody (authEncoder sharedModel.token)
        , expect = Common.expectJsonResponse Common.successDecoder DataReseived
        })
      Nothing
      Cmd.none
    DataReseived result -> case Common.getJsonData result of
      (Just isAuthorized) -> UpdateResult model Cmd.none (Just (Shared.State.Authorized isAuthorized)) Cmd.none
      Nothing -> UpdateResult model Cmd.none Nothing Cmd.none

form : Model -> Route.AuthRoute -> Html Msg
form { loginModel, signinModel } authRoute = case authRoute of
  Route.Login -> map LoginFormMsg (Auth.LoginForm.view loginModel)
  Route.Signin -> map SigninFormMsg (Auth.SigninForm.view signinModel)

authButton : Route.AuthRoute -> Html Msg
authButton route =
  case route of
    Route.Login -> Auth.Buttons.signinButton
    Route.Signin -> Auth.Buttons.loginButton

view : Model -> Shared.State.Model -> Html Msg
view model { currentRoute } =
  let
    route = case currentRoute of
      (Route.Auth r) -> r
      _ -> Route.Login
      in
        div [style "display" "flex", style "flex-direction" "column", style "align-items" "center"]
          [ authButton route
          , form model route
          ]
