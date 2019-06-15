module Auth.Styles exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Styles

formContainer : List (Attribute msg) -> List (Html msg) -> Html msg
formContainer = styled div
  [ displayFlex
  , alignItems right
  , flexDirection column
  , marginTop <| px 30
  ]

formTitle : List (Attribute msg) -> List (Html msg) -> Html msg
formTitle = styled Styles.title
  [ alignSelf center
  , important <| fontSize <| px 32
  , important <| marginBottom <| px 80
  ]

formRow : List (Attribute msg) -> List (Html msg) -> Html msg
formRow = styled div
  [ displayFlex
  , marginBottom (px 30)
  ]

submitButton : List (Attribute msg) -> List (Html msg) -> Html msg
submitButton = styled Styles.styledButton
  [ important <| marginLeft auto ]
