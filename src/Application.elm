module Application exposing (..)

import Http
import Html
import Browser
import Common exposing (errorMessage)

application = Browser.element
  { init = \_ -> (initialModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

type alias User =
  { id : Int
    , email : String
    , friends : Friends
  }

type Friends = Friends (List User)

type alias Model = { user : User, error : String }

initialModel = Model (User 0 "" (Friends [])) ""

type Msg
  = LoadUser
  | DataReceived (Result Http.Error User)

-- decoder 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoadUser -> (model, Cmd.none)
    DataReceived result ->
      case result of
        Ok res -> ({ model | user = res }, Cmd.none)
        Err httpError -> ({ model | error = errorMessage httpError }, Cmd.none)

view : Model -> Html.Html Msg
view model = Html.div [] [Html.text "Application"]
