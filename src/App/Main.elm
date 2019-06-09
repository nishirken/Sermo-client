module App.Main exposing (..)

import Http
import Browser
import Common
import Auth.Logout as Logout
import App.Models.User exposing (User)
import App.TextArea as TextArea
import App.FriendsList as FriendsList
import App.Chat as Chat
import App.Queries.User as UserQuery
import App.Styles as Styles
import Html.Styled exposing (Html, toUnstyled, div, text, map)
import Task
import SharedState

type alias Model =
  { user : User
  , error : String
  , logoutModel : Logout.Model
  , chatModel : Chat.Model
  , friendsListModel : FriendsList.Model
  , textAreaModel : TextArea.Model
  }

initialModel =
  { user = User 0 "" []
  , error = ""
  , logoutModel = Logout.initialModel
  , chatModel = Chat.initialModel
  , friendsListModel = FriendsList.initialModel
  , textAreaModel = TextArea.initialModel
  }

initCmd = Cmd.none

type Msg
  = DataReceived (Result Http.Error (Maybe User))
  | LogoutMsg Logout.Msg
  | FriendsListMsg FriendsList.Msg
  | ChatMsg Chat.Msg
  | TextAreaMsg TextArea.Msg

update : Msg -> Model -> (Model, Cmd Msg, Maybe SharedState.Msg)
update msg model =
  case msg of
    (LogoutMsg subMsg) -> let (updatedModel, updatedCmd, stateMsg) = Logout.update subMsg model.logoutModel in
      ({ model | logoutModel = updatedModel }, Cmd.map LogoutMsg updatedCmd, stateMsg)
    DataReceived result -> let errorRes = ({ model | error = "Error with user load" }, Cmd.none, Nothing) in
      case result of
        Ok res -> case res of
          (Just user) -> ({ model | user = user, friendsListModel = { friends = user.friends } }, Cmd.none, Nothing)
          Nothing -> errorRes
        Err httpError -> errorRes
    _ -> (model, Cmd.none, Nothing)

loadUser : SharedState.Model -> Cmd Msg
loadUser { userId, token } = case userId of
  (Just id) -> Common.makeGraphQLRequest DataReceived (UserQuery.query id) token
  Nothing -> Cmd.none

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
