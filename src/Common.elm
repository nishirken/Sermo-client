module Common exposing (..)

import Http exposing (Error (..), expectJson, Expect)
import Json.Decode exposing (Decoder (..), field, string, field, int, nullable, map2, bool)

type GlobalMsg
  = LoginSuccess String
  | SigninSuccess
  | None

type alias JSONError =
  { code : Int
  , message : Maybe String
  }

type alias JSONResponse a =
  { data : Maybe a
  , error : Maybe JSONError
  }

errorDecoder : Decoder JSONError
errorDecoder = map2 JSONError (field "code" int) (field "message" (nullable string))

responseDecoder : Decoder a -> Decoder (JSONResponse a)
responseDecoder dataDecoder = map2 JSONResponse
  (field "data" (nullable dataDecoder)) (field "error" (nullable errorDecoder))

successDecoder : Decoder Bool
successDecoder = field "success" bool

expectJsonResponse : Decoder a -> (Result Error (JSONResponse a) -> msg) -> Expect msg
expectJsonResponse dataDecoder data = expectJson data (responseDecoder dataDecoder)

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
