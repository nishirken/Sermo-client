port module Auth.Main exposing (..)

import Browser
import Http
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
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
import Task

type alias Model =
  { route : Routes.AuthRoute
  , loginModel : AuthCommon.InFormModel
  , signinModel : AuthCommon.InFormModel
  , token : String
  }

type Msg
  = LoginFormMsg Auth.LoginForm.LoginFormMsg
  | SigninFormMsg Auth.SigninForm.SigninFormMsg
  | AuthorizedSend
  | DataReseived (Result Http.Error (Common.JSONResponse Bool))

initialModel =
  Model Routes.Login AuthCommon.initialInFormModel AuthCommon.initialInFormModel ""

initCmd : Cmd Msg
initCmd = Task.perform (\_ -> AuthorizedSend) (Task.succeed ())

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

authEncoder : String -> JsonEncode.Value
authEncoder token = JsonEncode.object [("token", JsonEncode.string token)]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (LoginFormMsg subMsg) -> let (updatedModel, updatedCmd) = Auth.LoginForm.update subMsg model.loginModel in
      ({ model | loginModel = updatedModel }, Cmd.map LoginFormMsg updatedCmd)
    (SigninFormMsg subMsg) -> let (updatedModel, updatedCmd) = Auth.SigninForm.update subMsg model.signinModel in
      ({ model | signinModel = updatedModel }, Cmd.map SigninFormMsg updatedCmd)
    AuthorizedSend -> (model, Http.post
      { url = "http://localhost:8080/auth"
      , body = Http.jsonBody (authEncoder model.token)
      , expect = Common.expectJsonResponse Common.successDecoder DataReseived
      })
    DataReseived result -> (model, Cmd.none)

updateOutModel : Common.GlobalMsg -> Model -> Model
updateOutModel msg model =
  case msg of
    Common.Logout -> ({ model | token = "" })
    (Common.LoginSuccess token) -> ({ model | token = token })
    _ -> model

outMsg : Msg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (LoginFormMsg subMsg) -> Auth.LoginForm.outMsg subMsg
    (SigninFormMsg subMsg) -> Auth.SigninForm.outMsg subMsg
    (DataReseived result) -> case result of
      Ok _ -> let data = Common.getJsonData result in
        case data of
          (Just isAuthorized) -> Common.Authorized isAuthorized
          Nothing -> Common.Authorized False
      Err _ -> Common.Authorized False
    _ -> Common.None

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
