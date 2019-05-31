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

main = Browser.element
  { init = \() -> (initialModel, initCmd)
  , update = update
  , view = toUnstyled << view
  , subscriptions = \_ -> Sub.none
  }

type alias Model =
  { userId : Int
  , token : String
  , user : User
  , error : String
  , logoutModel : Logout.Model
  , chatModel : Chat.Model
  , friendsListModel : FriendsList.Model
  , textAreaModel : TextArea.Model
  }

initialModel =
  { userId = 0
  , token = ""
  , user = User 0 "" []
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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (LogoutMsg subMsg) -> let (updatedModel, updatedCmd) = Logout.update subMsg model.logoutModel in
      ({ model | logoutModel = updatedModel }, Cmd.map LogoutMsg updatedCmd)
    DataReceived result -> let errorRes = ({ model | error = "Error with user load" }, Cmd.none) in
      case result of
        Ok res -> case res of
          (Just user) -> ({ model | user = user, friendsListModel = { friends = user.friends } }, Cmd.none)
          Nothing -> errorRes
        Err httpError -> errorRes
    _ -> (model, Cmd.none)

loadUser : Model -> Cmd Msg
loadUser model = Common.makeGraphQLRequest DataReceived (UserQuery.query 6) model.token

updateOutModel : Common.GlobalMsg -> Model -> Model
updateOutModel globalMsg model =
  case globalMsg of
    (Common.LoginSuccess token) -> ({ model | token = token })
    Common.Logout -> ({ model | token = "" })
    _ -> model

updateOutCmd : Common.GlobalMsg -> Model -> Cmd Msg
updateOutCmd globalMsg model =
  case globalMsg of
    (Common.Authorized res) -> if res == True then loadUser model else Cmd.none
    _ -> Cmd.none

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
