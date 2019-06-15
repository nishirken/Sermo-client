module Auth.Buttons exposing (..)

import Browser
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (href)
import Styles
import Auth.Styles

authLink : List (Attribute msg) -> List (Html msg) -> Html msg
authLink = styled a
  [ width <| pct 100
  , height <| pct 100
  , position absolute
  , top <| px 0
  , left <| px 0
  , displayFlex
  , alignItems center
  , justifyContent center
  ]

loginButton : Html msg
loginButton = 
  Styles.absoluteButton [] [
    authLink [href "/login"] [text "Login"]
  ]

signinButton : Html msg
signinButton = 
  Styles.absoluteButton [] [
    authLink [href "/signin"] [text "Signin"]
  ]
