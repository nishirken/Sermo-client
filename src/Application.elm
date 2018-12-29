module Application exposing (..)

import Http
import Html
import Browser

application = Browser.element
  { init = \_ -> initialModel
   , update = updateLogin
  , view = view
  , subscriptions = \_ -> Sub.none
  }

type alias User =
  { id : Int
    , email : String
    , friends : Friends
  }

type Friends = Friends (List User)

type alias Model = { user : User, errorMessage : String }

initialModel = (Model (User 0 "" (Friends [])) "", Cmd.none)

type Msg
  = LoadUser
  | DataReceived (Result Http.Error User)

-- decoder 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoadUser -> (model, send DataReseived (post ("http://localhost:8080/graphql") (loginRequest model) loginDecoder))
    DataReseived result ->
      case result of
        Ok res -> ({ mode | user = res }, Cmd.none)
        Err httpError -> ({ model | error = errorMessage httpError }, Cmd.none)

view : Model -> Html.Html Msg
view model = Html.div [] [Html.text "Application"]
