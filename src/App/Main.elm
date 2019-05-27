module App.Main exposing (..)

import Graphql.Http as Http
import Browser
import Common
import Auth.Logout as Logout
import App.Models.User exposing (User (..))
import App.TextArea as TextArea
import App.FriendsList as FriendsList
import App.Chat as Chat
import App.Queries.User as UserQuery
import App.Styles as Styles
import Html.Styled exposing (Html, toUnstyled, div, text, map)

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = toUnstyled << view
  , subscriptions = \_ -> Sub.none
  }

type alias Model =
  { user : User
  , error : String
  , logoutModel : Logout.Model
  , chatModel : Chat.Model
  , friendsListModel : FriendsList.Model
  , textAreaModel : TextArea.Model
  }

initialModel =
  { user = AppCommon.User 0 "" []
  , error = ""
  , logoutModel = Logout.initialModel
  , chatModel = Chat.initialModel
  , friendsListModel = FriendsList.initialModel
  , textAreaModel = TextArea.initialModel
  }

type Msg
  = LoadUser
  | DataReceived (Result (Http.Error User) User)
  | LogoutMsg Logout.Msg
  | FriendsListMsg FriendsList.Msg
  | ChatMsg Chat.Msg
  | TextAreaMsg TextArea.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (LogoutMsg subMsg) -> let (updatedModel, updatedCmd) = Logout.update subMsg model.logoutModel in
      ({ model | logoutModel = updatedModel }, Cmd.map LogoutMsg updatedCmd)
    LoadUser -> (model, Http.send DataReceived (Http.queryRequest "http://localhost:8080" Schemas.userQuery))
    DataReceived result ->
      case result of
        Ok res -> ({ model | user = res }, Cmd.none)
        Err httpError -> ({ model | error = Common.errorMessage httpError }, Cmd.none)
    _ -> (model, Cmd.none)

outMsg : Msg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (LogoutMsg subMsg) -> Common.Logout
    _ -> Common.None

view : Model -> Html Msg
view { logoutModel, friendsListModel, chatModel, textAreaModel } = div []
  [ Styles.title [] [text "Application"]
  , Styles.appContainer []
    [ Styles.friendsListContainer [] [map FriendsListMsg (FriendsList.view friendsListModel)]
    , Styles.chatContainer []
      [ map ChatMsg (Chat.view chatModel)
      , map TextAreaMsg (TextArea.view textAreaModel)
      ]
    ]
  , map LogoutMsg (Logout.view logoutModel)
  ]
