module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (Parser, (</>), s, int, oneOf, top, string)
import Http


type alias AlbumId =
    Int


type alias Query =
    String


type Route
    = Search Query
    | Album AlbumId
    | NotFound


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ UrlParser.map Album <| s "album" </> int
        , UrlParser.map (Search << Maybe.withDefault "" << Http.decodeUri) string
        ]


parseLocation : Location -> Route
parseLocation =
    UrlParser.parseHash matchers >> Maybe.withDefault NotFound
