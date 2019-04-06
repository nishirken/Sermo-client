module Main exposing (..)

import Browser
import Html exposing (text, h1, div)
import Html.Attributes exposing (href)
import SwitchButtons exposing (switchButtonsView)
import InForm
import Common
import Application
import Routes
import Url exposing (Url)
import Browser.Navigation exposing (Key)

type alias Model =
  { token : String
  , routesModel : Routes.Model
  , loginModel : InForm.Model
  , signinModel : InForm.Model
  , appModel : Application.Model
  }

type Msg
  = RouteMsg Routes.Msg
  | LoginMsg InForm.LoginMsg
  | SigninMsg InForm.SigninMsg
  | AppMsg Application.Msg

main = Browser.application
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  , onUrlRequest = \urlReq -> RouteMsg (Routes.LinkClicked urlReq)
  , onUrlChange = \url -> RouteMsg (Routes.UrlChanged url)
  }

init : () -> Url -> Key -> (Model, Cmd Msg)
init _ url key =
  ({ token = ""
  , routesModel = Routes.initialModel url key
  , loginModel = InForm.initialModel
  , signinModel = InForm.initialModel
  , appModel = Application.initialModel
  }, Cmd.none)

updateInnerMsg : Msg -> Model -> (Model, Cmd Msg)
updateInnerMsg msg model =
  case msg of
    RouteMsg subMsg -> let (updatedModel, updatedCmd) = Routes.update subMsg model.routesModel in
      ({ model | routesModel = updatedModel }, Cmd.map RouteMsg updatedCmd)
    SigninMsg subMsg -> let (updatedModel, subCmd) = InForm.updateSignin subMsg model.signinModel in
      ({ model | signinModel = updatedModel }, Cmd.map SigninMsg subCmd)
    LoginMsg subMsg -> let (updatedModel, subCmd) = InForm.updateLogin subMsg model.loginModel in
      ({ model | loginModel = updatedModel }, Cmd.map LoginMsg subCmd)
    AppMsg subMsg -> let (updatedModel, subCmd) = Application.update subMsg model.appModel in
      ({ model | appModel = updatedModel }, Cmd.map AppMsg subCmd)

updateOutModel : Common.GlobalMsg -> Model -> Model
updateOutModel globalMsg model =
  case globalMsg of
    (Common.LoginSuccess token) -> { model | token = token }
    _ -> model

updateOutCmd : Common.GlobalMsg -> Model -> Cmd Msg
updateOutCmd msg model = Cmd.batch
  [Cmd.map RouteMsg (Routes.updateOutCmd msg model.routesModel)]

updateOutMsg : Msg -> Model -> (Model, Cmd Msg)
updateOutMsg msg model =
  case msg of
    (LoginMsg subMsg) ->
      let
        msg_ = InForm.outLoginMsg subMsg
        model_ = updateOutModel msg_ model in
      (model_, updateOutCmd msg_ model_)
    (SigninMsg subMsg) ->
      let
        msg_ = InForm.outSigninMsg subMsg
        model_ = updateOutModel msg_ model in
      (model_, updateOutCmd msg_ model_)
    _ -> (model, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    (innerModel, innerCmd) = updateInnerMsg msg model
    (outModel, outCmd) = updateOutMsg msg innerModel in
      (outModel, Cmd.batch [outCmd, innerCmd])

view : Model -> Browser.Document Msg
view { routesModel, signinModel, loginModel, appModel } =
  {
    title = "Sermo"
    , body = [
        switchButtonsView
        , div [] [
          case routesModel.route of
            Routes.Signin -> Html.map SigninMsg (InForm.signinFormView signinModel)
            Routes.Login -> Html.map LoginMsg (InForm.loginFormView loginModel)
            Routes.Application -> Html.map AppMsg (Application.view appModel)
            Routes.NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
