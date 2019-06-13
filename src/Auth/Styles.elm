module Auth.Styles exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Styles

formRow : List (Attribute msg) -> List (Html msg) -> Html msg
formRow = styled div
  [ marginBottom (px 20) ]
