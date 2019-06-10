module Main exposing (..)

import Browser
import Html.Styled exposing (text, h1, div, toUnstyled, map)
import Auth.Main as Auth
import Auth.Common as AuthCommon
import Common
import App.Main as App
import Routes.Main as Routes
import Url exposing (Url)
import Browser.Navigation exposing (Key)
import LocalStorage
import SharedState

type alias Model =
  { token : String
  , isAuthorized : Bool
  , routes : Routes.Model
  , pages : Pages
  , sharedState : SharedState.Model
  }

type alias Pages =
  { appModel : App.Model
  , authModel : Auth.Model
  }

type Msg
  = RouteMsg Routes.Msg
  | StateMsg SharedState.Msg
  | PageMsg PageMsg

type PageMsg
  = AuthMsg Auth.Msg
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
  , routes = Routes.initialModel url key
  , pages =
    { authModel = Auth.initialModel
    , appModel = App.initialModel
    }
  , sharedState = let model = SharedState.initModel in { model | token = authToken }
  }, Cmd.batch [Cmd.map (PageMsg << AuthMsg) Auth.initCmd, Cmd.map (PageMsg << AppMsg) App.initCmd])

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = let { routes, pages, sharedState } = model in
  case msg of
    RouteMsg subMsg ->
      let
        (updatedModel, updatedCmd) = Routes.update subMsg routes
        authRoute = case updatedModel.route of
          (Routes.Auth subRoute) -> subRoute
          _ -> sharedState.authModel.route in
        ({ model | routesModel = updatedModel}, Cmd.map RouteMsg updatedCmd)
    (PageMsg pageMsg) -> updatePage pageMsg model
    _ -> (model, Cmd.none)

updatePage : PageMsg -> Model -> (Model, Cmd Msg)
updatePage msg model =
  let
    { pages, sharedState } = model
    stateUpdate stateMsg =
      case stateMsg of
        (Just m) -> SharedState.update m model.sharedState
        Nothing -> model.sharedState
    in
  case msg of
    AuthMsg subMsg -> let (updatedModel, subCmd, stateMsg) = Auth.update subMsg pages.authModel sharedState in
      ( { model | pages = { pages | authModel = updatedModel }, sharedState = stateUpdate stateMsg }
      , Cmd.map (PageMsg << AuthMsg) subCmd
      )
    AppMsg subMsg -> let (updatedModel, subCmd, stateMsg) = App.update subMsg pages.appModel sharedState in
      ( { model | pages = { pages | appModel = updatedModel }, sharedState = stateUpdate stateMsg }
      , Cmd.map (PageMsg << AppMsg) subCmd
      )

view : Model -> Browser.Document Msg
view { routes, pages, sharedState } =
  { title = "Sermo"
  , body = List.map toUnstyled [
      div [] [
        case sharedState.currentRoute of
          Routes.Auth _ -> map (PageMsg << AuthMsg) (Auth.view pages.authModel sharedState)
          Routes.Application -> map (PageMsg << AppMsg) (App.view pages.appModel)
          Routes.NotFound -> div [] [text "404 Not found"]  
        ]
    ]
  }
