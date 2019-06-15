module App.TextArea exposing (..)

import Browser
import Html.Styled exposing (Html, input, toUnstyled)
import Html.Styled.Events exposing (onInput)
import App.Styles as Styles

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = toUnstyled << view
  , subscriptions = \_ -> Sub.none
  }

initialModel = Model ""

type Msg = OnInput String | SendMessage

type alias Model = { textValue : String }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    (OnInput xs) -> ({ model | textValue = xs }, Cmd.none)
    _ -> (model, Cmd.none)

view : Model -> Html Msg
view model =
  Styles.chatTextArea
    [ onInput OnInput
    ]
    []
