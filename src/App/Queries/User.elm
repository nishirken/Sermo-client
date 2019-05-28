module App.Queries.User exposing (..)

import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import App.Models.User exposing (User, userDecoder)
import Graphql.Internal.Builder.Object exposing (selectionForField)
import Graphql.Internal.Builder.Argument exposing (required)
import Graphql.Internal.Encode exposing (int)

userQuery : Int -> SelectionSet (Maybe User) RootQuery
userQuery id = selectionForField "User" "user" [required "id" id int] userDecoder
