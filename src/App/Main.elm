module App.Main exposing (..)

import Http
import Browser
import Common
import Auth.Logout as Logout
import App.Models.User exposing (User)
import App.TextArea as TextArea
import App.FriendsList as FriendsList
import App.Messages as Messages
import App.Queries.User as UserQuery
import Html.Styled exposing (Html, toUnstyled, div, text, map)
import Task
import Shared.Update exposing (Update, UpdateResult)
import Shared.State
import App.Styles as AppStyles
import Routes.Route

type alias Model =
  { user : User
  , error : String
  , logoutModel : Logout.Model
  , messagesModel : Messages.Model
  , friendsListModel : FriendsList.Model
  , textAreaModel : TextArea.Model
  }

initialModel =
  { user = User 0 "" []
  , error = ""
  , logoutModel = Logout.initialModel
  , messagesModel = Messages.initialModel
  , friendsListModel = FriendsList.initialModel
  , textAreaModel = TextArea.initialModel
  }

initCmd = Cmd.none

type Msg
  = InitialLoad
  | DataReceived (Result Http.Error (Maybe User))
  | LogoutMsg Logout.Msg
  | FriendsListMsg FriendsList.Msg
  | MessagesMsg Messages.Msg
  | TextAreaMsg TextArea.Msg

initMsg : Msg
initMsg = InitialLoad

update : Update Msg Model
update msg model sharedModel = let { token, userId } = sharedModel in
  case msg of
    InitialLoad -> case userId of
      (Just id) -> UpdateResult
        model
        (Common.makeGraphQLRequest DataReceived (UserQuery.query id) token)
        Nothing
        Cmd.none
      Nothing -> UpdateResult model Cmd.none Nothing Cmd.none
    (LogoutMsg subMsg) ->
      let
        { updatedModel, updatedCmd, stateMsg, routeCmd } = Logout.update subMsg model.logoutModel sharedModel in
          UpdateResult { model | logoutModel = updatedModel } (Cmd.map LogoutMsg updatedCmd) stateMsg routeCmd
    DataReceived result ->
      let errorRes = UpdateResult { model | error = "Error with user load" } Cmd.none Nothing Cmd.none in
        case result of
          Ok res -> case res of
            (Just user) -> UpdateResult
              { model | user = user, friendsListModel = { friends = user.friends } } Cmd.none Nothing Cmd.none
            Nothing -> errorRes
          Err httpError -> errorRes
    _ -> UpdateResult model Cmd.none Nothing Cmd.none

view : Model -> Html Msg
view { logoutModel, friendsListModel, messagesModel, textAreaModel } = AppStyles.appContainer []
  [ map FriendsListMsg (FriendsList.view friendsListModel)
  , AppStyles.chatContainer []
    [ map MessagesMsg (Messages.view messagesModel)
    , map TextAreaMsg (TextArea.view textAreaModel)
    ]
  , map LogoutMsg (Logout.view logoutModel)
  ]
