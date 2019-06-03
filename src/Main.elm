module Main exposing (..)

import Browser
import Html.Styled exposing (text, h1, div, toUnstyled, map)
import Auth.Main as Auth
import Common
import App.Main as App
import Routes
import Url exposing (Url)
import Browser.Navigation exposing (Key)
import LocalStorage

type alias Model =
  { token : String
  , isAuthorized : Bool
  , routesModel : Routes.Model
  , authModel : Auth.Model
  , appModel : App.Model
  }

type Msg
  = RouteMsg Routes.Msg
  | AuthMsg Auth.Msg
  | AppMsg App.Msg

main = Browser.application
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  , onUrlRequest = \urlReq -> RouteMsg (Routes.LinkClicked urlReq)
  , onUrlChange = \url -> RouteMsg (Routes.UrlChanged url)
  }

type alias Flags = { storageState : String }

init : Flags -> Url -> Key -> (Model, Cmd Msg)
init { storageState } url key = let { authToken } = (LocalStorage.decodeModel storageState) in
  ({ token = authToken
  , isAuthorized = False
  , routesModel = Routes.initialModel url key
  , authModel = let model = Auth.initialModel in { model | token = authToken }
  , appModel = let model = App.initialModel in { model | token = authToken }
  }, Cmd.batch [Cmd.map AuthMsg Auth.initCmd, Cmd.map AppMsg App.initCmd])

updateInnerMsg : Msg -> Model -> (Model, Cmd Msg)
updateInnerMsg msg model = let { authModel, routesModel, appModel } = model in
  case msg of
    RouteMsg subMsg ->
      let
        (updatedModel, updatedCmd) = Routes.update subMsg routesModel
        authRoute = case updatedModel.route of
          (Routes.AuthRoute subRoute) -> subRoute
          _ -> authModel.route in
        ({ model
        | routesModel = updatedModel
        , authModel = { authModel | route = authRoute }
        }, Cmd.map RouteMsg updatedCmd)
    AuthMsg subMsg -> let (updatedModel, subCmd) = Auth.update subMsg model.authModel in
      ({ model | authModel = updatedModel }, Cmd.map AuthMsg subCmd)
    AppMsg subMsg -> let (updatedModel, subCmd) = App.update subMsg model.appModel in
      ({ model | appModel = updatedModel }, Cmd.map AppMsg subCmd)

updateOutModel : Common.GlobalMsg -> Model -> Model
updateOutModel globalMsg model =
  case globalMsg of
    (Common.LoginSuccess { token }) ->
      { model
      | token = token
      , authModel = Auth.updateOutModel globalMsg model.authModel
      , appModel = App.updateOutModel globalMsg model.appModel
      }
    (Common.Authorized isAuthorized) -> { model | isAuthorized = isAuthorized }
    Common.Logout ->
      { model
      | token = ""
      , authModel = Auth.updateOutModel globalMsg model.authModel
      , appModel = App.updateOutModel globalMsg model.appModel
      }
    _ -> model

updateOutCmd : Common.GlobalMsg -> Model -> Cmd Msg
updateOutCmd msg model = Cmd.batch
  [ Cmd.map RouteMsg (Routes.updateOutCmd msg model.routesModel), Cmd.map AppMsg (App.updateOutCmd msg model.appModel) ]

updateOutMsg : Msg -> Model -> (Model, Cmd Msg)
updateOutMsg msg model =
  case msg of
    (AuthMsg subMsg) ->
      let
        msg_ = Auth.outMsg subMsg
        model_ = updateOutModel msg_ model in
      (model_, updateOutCmd msg_ model_)
    (AppMsg subMsg) ->
      let
        msg_ = App.outMsg subMsg
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
view { routesModel, authModel, appModel } =
  { title = "Sermo"
  , body = List.map toUnstyled [
      div [] [
        case routesModel.route of
          Routes.AuthRoute _ -> map AuthMsg (Auth.view authModel)
          Routes.Application -> map AppMsg (App.view appModel)
          Routes.NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
