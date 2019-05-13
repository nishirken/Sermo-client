module App.Schemas exposing (..)

import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import App.Common exposing (User, Friend)

userQuery : Int -> SelectionSet (Maybe User) RootQuery
userQuery id =
  AppCommon.human { id = id } humanSelection
