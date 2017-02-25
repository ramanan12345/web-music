module Main exposing (..)

import Navigation exposing (Location)
import Search
import Album
import Routing exposing (Route)
import Msgs exposing (Msg)
import Models exposing (Model)
import RemoteData
import Html exposing (Html)


init : Location -> ( Model, Cmd Msg )
init loc =
    updLocation (Models.initialModel <| Routing.parseLocation loc) loc


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Debug.log (toString msg) <|
        case msg of
            Msgs.Input s ->
                model ! [ Navigation.modifyUrl <| "#" ++ s ]

            Msgs.DebounceMsg msg ->
                Search.onDebounce model msg

            Msgs.Albums str r ->
                if Search.sameQuery model.route str then
                    { model | albums = RemoteData.map (\x -> x.results) r } ! []
                else
                    model ! []

            Msgs.Click res ->
                model ! [ Navigation.newUrl <| "#album/" ++ toString res.id ]

            Msgs.OnLocationChange location ->
                updLocation model location

            Msgs.Album album ->
                { model | album = album } ! []

            Msgs.Play a t ->
                model ! [ Album.getTrack a t ]

            Msgs.GotUrl t1 t2 ->
                model ! []


updLocation : Model -> Location -> ( Model, Cmd Msg )
updLocation model location =
    let
        route =
            Routing.parseLocation location
    in
        case route of
            Routing.Search str ->
                Search.newInput model str

            Routing.Album id ->
                { model
                    | route = route
                    , album = RemoteData.Loading
                }
                    ! [ Album.getAlbum id ]

            _ ->
                { model | route = route } ! []


view : Model -> Html Msg
view model =
    case model.route of
        Routing.Album _ ->
            Album.view model

        _ ->
            Search.view model


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
