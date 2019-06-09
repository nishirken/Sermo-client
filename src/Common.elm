module Common exposing (..)

import Http exposing (Error (..), expectJson, Expect, post, jsonBody)
import Graphql.Http as GraphqlHttp
import Graphql.SelectionSet as GraphqlSelectionSet
import Graphql.Operation as GraphqlOperation
import Graphql.Document as GraphqlDocument
import Json.Decode exposing (Decoder (..), field, string, field, int, nullable, map2, bool)
import Json.Encode as JE
import Task

withLog x = Debug.log (Debug.toString x) x

type GlobalMsg
  = LoginSuccess AuthResponse
  | SigninSuccess AuthResponse
  | Logout
  | Authorized Bool
  | AppEntered
  | None

type alias JSONError =
  { code : Int
  , message : Maybe String
  }

type alias JSONResponse a =
  { data : Maybe a
  , error : Maybe JSONError
  }

type alias GraphqlRequest =
  { token : String
  , body : String
  }

type alias AuthResponse =
  { id : Int
  , token : String
  }

graphqlRequestEncoder : String -> String -> JE.Value
graphqlRequestEncoder token graphqlData = JE.object [("token", JE.string token), ("body", JE.string graphqlData)]

errorDecoder : Decoder JSONError
errorDecoder = map2 JSONError (field "code" int) (field "message" (nullable string))

responseDecoder : Decoder a -> Decoder (JSONResponse a)
responseDecoder dataDecoder = map2 JSONResponse
  (field "data" (nullable dataDecoder)) (field "error" (nullable errorDecoder))

successDecoder : Decoder Bool
successDecoder = field "success" bool

expectJsonResponse : Decoder a -> (Result Error (JSONResponse a) -> msg) -> Expect msg
expectJsonResponse dataDecoder msg = expectJson msg (responseDecoder dataDecoder)

getJsonData : (Result Error (JSONResponse a)) -> Maybe a
getJsonData response = case response of
  (Ok res) -> res.data
  _ -> Nothing

getJsonError : (Result Error (JSONResponse a)) -> Maybe JSONError
getJsonError response = case response of
  (Ok res) -> res.error
  _ -> Nothing

errorMessage : Http.Error -> String
errorMessage error = case error of
  Timeout -> "Timeout error"
  NetworkError -> "Network error"
  (BadUrl url) -> "Bad url: " ++ url
  (BadBody msg) -> "Error with response decoding. " ++ msg
  (BadStatus code) -> "Something went wrong..." ++ " code: " ++ (String.fromInt code)

makeGraphQLRequest :
  (Result Error decodesTo -> msg) ->
  GraphqlSelectionSet.SelectionSet decodesTo GraphqlOperation.RootQuery ->
  String ->
  Cmd msg
makeGraphQLRequest msg query authToken =
  let
    expectGraphqlResponse = expectJson msg (GraphqlDocument.decoder query)
    graphqlBody = GraphqlDocument.serializeQuery query in
  post 
    { url = "http://localhost:8080/graphql"
    , body = jsonBody (graphqlRequestEncoder authToken graphqlBody)
    , expect = expectGraphqlResponse
    }

cmdMsg : msg -> Cmd msg
cmdMsg msg = Task.perform (\_ -> msg) (Task.succeed ())
