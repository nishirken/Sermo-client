module App.Queries.User exposing (..)

import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import App.Models.User exposing (User)
import Graphql.Internal.Builder.Object exposing (selectionField)
import Graphql.Internal.Builder.Argument exposing (required)
import Graphql.Internal.Encode exposing (int)

userQuery : Int -> SelectionSet User RootQuery
userQuery id = selectionField "user" [required id int]
