port module LocalStorage exposing (..)

import Task
import Json.Encode as JsonEncode
import Json.Decode as JsonDecode
import Common

port setStorage : JsonEncode.Value -> Cmd msg

type alias LocalStorageState =
  { authToken : String
  , userId : Maybe Int
  }

maybeEncoder : Maybe a -> (a -> JsonEncode.Value) -> JsonEncode.Value
maybeEncoder value encoder =
  case value of
    (Just x) -> encoder x
    Nothing -> JsonEncode.null

encodedModel : LocalStorageState -> JsonEncode.Value
encodedModel { authToken, userId } =
  JsonEncode.object
    [ ("authToken", JsonEncode.string authToken)
    , ("userId",  maybeEncoder userId JsonEncode.int)
    ]

writeModel : LocalStorageState -> Cmd msg
writeModel model = setStorage (encodedModel model)

modelDecoder : JsonDecode.Decoder LocalStorageState
modelDecoder = JsonDecode.map2 LocalStorageState
  (JsonDecode.field "authToken" JsonDecode.string)
  (JsonDecode.nullable (JsonDecode.field "userId" JsonDecode.int))

decodeModel : String -> LocalStorageState
decodeModel value = case JsonDecode.decodeString modelDecoder value of
  (Ok x) -> x
  (Err _) -> defaultModel

key = "sermo"

defaultModel : LocalStorageState
defaultModel = LocalStorageState "" Nothing
