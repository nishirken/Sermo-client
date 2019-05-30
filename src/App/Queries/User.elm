module App.Queries.User exposing (..)

import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import App.Models.User exposing (User, userDecoder)
import App.Models.Friend exposing (Friend, friendDecoder)
import Graphql.Internal.Builder.Object exposing (selectionForField, selectionForCompositeField)
import Graphql.Internal.Builder.Argument exposing (required)
import Graphql.Internal.Encode exposing (int)
import Json.Decode as JD

userId : SelectionSet Int User
userId = selectionForField "Int" "id" [] JD.int

userEmail : SelectionSet String User
userEmail = selectionForField "String" "email" [] JD.string

userFriends : SelectionSet (List String) User
userFriends = selectionForField "(List Friends)" "friends" [] (JD.list JD.string)

userQuery : Int -> SelectionSet decodesTo User -> SelectionSet (Maybe decodesTo) RootQuery
userQuery id object_ = selectionForCompositeField "user" [required "id" id int] object_ (identity >> JD.nullable)

userSelection : SelectionSet User User
userSelection = SelectionSet.map3 User userId userEmail userFriends

query : Int -> SelectionSet (Maybe User) RootQuery
query id = userQuery id userSelection
