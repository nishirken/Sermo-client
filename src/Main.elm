module Main exposing (..)

import Browser
import Html.Styled exposing (text, h1, div, toUnstyled, map)
import Html.Styled.Lazy exposing (lazy)
import Auth.Main as Auth
import Auth.Common as AuthCommon
import Common
import App.Main as App
import Routes.Main as Routes
import Routes.Route as Route
import Routes.Msg as RoutesMsg
import Url exposing (Url)
import Browser.Navigation exposing (Key)
import LocalStorage
import Shared.Update exposing (Update, UpdateResult)
import Shared.State

type alias Model =
  { routesModel : Routes.Model
  , pagesModel : Pages
  , sharedModel : Shared.State.Model
  }

type alias Pages =
  { appModel : App.Model
  , authModel : Auth.Model
  }

type Msg
  = RouteMsg RoutesMsg.Msg
  | StateMsg Shared.State.Msg
  | PageMsg PageMsg

type PageMsg
  = AuthMsg Auth.Msg
  | AppMsg App.Msg

main = Browser.application
  { init = init
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  , onUrlRequest = \urlReq -> RouteMsg (RoutesMsg.LinkClicked urlReq)
  , onUrlChange = \url -> RouteMsg (RoutesMsg.UrlChanged url)
  }

type alias Flags = { storageState : String }

init : Flags -> Url -> Key -> (Model, Cmd Msg)
init { storageState } url key = let { authToken, userId } = (LocalStorage.decodeModel storageState) in
  ( { routesModel = Routes.initialModel url
    , pagesModel =
      { authModel = Auth.initialModel
      , appModel = App.initialModel
      }
    , sharedModel = Shared.State.initialModel key authToken userId
    }
  , Cmd.batch [ Cmd.map (PageMsg << AuthMsg) Auth.initCmd, Cmd.map (PageMsg << AppMsg) App.initCmd ]
  )

stateUpdate : Maybe Shared.State.Msg -> Shared.State.Model -> Shared.State.Model
stateUpdate stateMsg model = case stateMsg of
  (Just msg) -> Shared.State.update msg model
  Nothing -> model

appInit : Maybe Shared.State.Msg -> App.Model -> Shared.State.Model -> UpdateResult App.Model App.Msg
appInit stateMsg appModel sharedModel = let empty = UpdateResult appModel Cmd.none Nothing Cmd.none in
  case stateMsg of
    (Just x) -> case x of
      (Shared.State.RouteChanged route) ->
        if route == Route.Application then App.update App.initMsg appModel sharedModel else empty
      _ -> empty
    Nothing -> empty

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let { routesModel, pagesModel, sharedModel } = model in
  case msg of
    RouteMsg subMsg ->
      let
        { updatedModel, updatedCmd, stateMsg } = Routes.update subMsg routesModel sharedModel
        appUpdate = appInit stateMsg pagesModel.appModel sharedModel in
        ( { model
          | routesModel = updatedModel
          , sharedModel = stateUpdate stateMsg sharedModel
          , pagesModel = { pagesModel | appModel = appUpdate.updatedModel }
          }
        , Cmd.batch [ Cmd.map RouteMsg updatedCmd, Cmd.map (PageMsg << AppMsg) appUpdate.updatedCmd ]
        ) 
    (PageMsg pageMsg) -> updatePage pageMsg model
    _ -> (model, Cmd.none)

updatePage : PageMsg -> Model -> (Model, Cmd Msg)
updatePage msg model = let { pagesModel, sharedModel } = model in
  case msg of
    AuthMsg subMsg ->
      let { updatedModel, updatedCmd, stateMsg, routeCmd } = Auth.update subMsg pagesModel.authModel sharedModel in
        ( { model
          | pagesModel = { pagesModel | authModel = updatedModel }
          , sharedModel = stateUpdate stateMsg sharedModel
          }
        , Cmd.batch [ Cmd.map (PageMsg << AuthMsg) updatedCmd, Cmd.map RouteMsg routeCmd ]
        )
    AppMsg subMsg ->
      let { updatedModel, updatedCmd, stateMsg, routeCmd } = App.update subMsg pagesModel.appModel sharedModel in
        ( { model
          | pagesModel = { pagesModel | appModel = updatedModel }
          , sharedModel = stateUpdate stateMsg sharedModel
          }
        , Cmd.batch [ Cmd.map (PageMsg << AppMsg) updatedCmd, Cmd.map RouteMsg routeCmd ]
        )

view : Model -> Browser.Document Msg
view { pagesModel, sharedModel } =
  { title = "Sermo"
  , body = List.map toUnstyled [
      div [] [
        case sharedModel.currentRoute of
          Route.Auth _ -> map (PageMsg << AuthMsg) (Auth.view pagesModel.authModel sharedModel)
          Route.Application -> map (PageMsg << AppMsg) (lazy App.view pagesModel.appModel)
          Route.NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
