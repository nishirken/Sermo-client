module Main exposing (..)

import Browser
import Html.Styled exposing (text, h1, div, toUnstyled, map)
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
import Styles

type alias Model =
  { token : String
  , isAuthorized : Bool
  , routesModel : Routes.Model
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
init { storageState } url key = let { authToken } = (LocalStorage.decodeModel storageState) in
  ({ token = authToken
  , isAuthorized = False
  , routesModel = Routes.initialModel url
  , pagesModel =
    { authModel = Auth.initialModel
    , appModel = App.initialModel
    }
  , sharedModel = Shared.State.initialModel key
  }, Cmd.batch [Cmd.map (PageMsg << AuthMsg) Auth.initCmd, Cmd.map (PageMsg << AppMsg) App.initCmd])

stateUpdate : Maybe Shared.State.Msg -> Shared.State.Model -> Shared.State.Model
stateUpdate stateMsg model = case stateMsg of
  (Just msg) -> Shared.State.update msg model
  Nothing -> model

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let { routesModel, pagesModel, sharedModel } = model in
  case msg of
    RouteMsg subMsg ->
      let { updatedModel, updatedCmd, stateMsg } = Routes.update subMsg routesModel sharedModel in
        ( { model
          | routesModel = updatedModel
          , sharedModel = stateUpdate stateMsg sharedModel
          }
        , Cmd.map RouteMsg updatedCmd
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
  , body = List.map toUnstyled
    [ Styles.appContainer []
      [ case sharedModel.currentRoute of
          Route.Auth _ -> map (PageMsg << AuthMsg) (Auth.view pagesModel.authModel sharedModel)
          Route.Application -> map (PageMsg << AppMsg) (App.view pagesModel.appModel)
          Route.NotFound -> div [] [text "404 Not found"]
      , Styles.logoBackdrop [] []
      ]
    , Styles.globalStyles
    ]
  }
