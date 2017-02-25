module Search exposing (..)

import Discogs exposing (PagedResults, SearchResult)
import Debounce exposing (Debounce)
import Time exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Routing exposing (Route)
import Models exposing (Model)


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later <| 250 * millisecond
    , transform = Msgs.DebounceMsg
    }


newInput : Model -> String -> ( Model, Cmd Msg )
newInput model str =
    let
        ( debounce, cmd ) =
            Debounce.push debounceConfig str model.debounce
    in
        { model | debounce = debounce, route = Routing.Search str } ! [ cmd ]


searchAlbums : String -> Cmd Msg
searchAlbums str =
    Discogs.searchRequest str
        |> RemoteData.sendRequest
        |> Cmd.map (Msgs.Albums str)


onDebounce : Model -> Debounce.Msg -> ( Model, Cmd Msg )
onDebounce model msg =
    let
        ( debounce, cmd ) =
            Debounce.update debounceConfig (Debounce.takeLast searchAlbums) msg model.debounce
    in
        { model | debounce = debounce } ! [ cmd ]


queryStr : Route -> Maybe Routing.Query
queryStr route =
    case route of
        Routing.Search s ->
            Just s

        _ ->
            Nothing


sameQuery : Route -> String -> Bool
sameQuery route str =
    queryStr route == Just str


rowView : SearchResult -> Html Msg
rowView res =
    li [ onClick <| Msgs.Click res ]
        [ img [ src res.thumb ] []
        , text res.title
        ]


view : Model -> Html Msg
view model =
    div []
        [ input
            [ autofocus True
            , onInput Msgs.Input
            , queryStr model.route
                |> Maybe.withDefault ""
                |> value
            ]
            []
        , ol [] <| List.map rowView <| RemoteData.withDefault [] model.albums
        ]
