module Album exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Models exposing (Model)
import Msgs exposing (Msg)
import Discogs exposing (Album, Artist)
import RemoteData exposing (WebData)
import Moosic


getAlbum : Int -> Cmd Msg
getAlbum id =
    Discogs.albumRequest id
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.Album


fromMaybe : Maybe a -> WebData a
fromMaybe =
    Maybe.map RemoteData.Success
        >> Maybe.withDefault RemoteData.NotAsked


ha : WebData (List a) -> WebData a
ha =
    RemoteData.map (List.head)
        >> RemoteData.andThen fromMaybe


getTrack : Album -> Discogs.Track -> Cmd Msg
getTrack a t =
    Moosic.searchRequest (artist a ++ " " ++ t.title)
        |> RemoteData.sendRequest
        |> Cmd.map (Msgs.GotUrl t << ha)


trackView : Album -> Discogs.Track -> Html Msg
trackView a t =
    li
        [ onClick <| Msgs.Play a t ]
        [ text t.title ]


image : Album -> String
image a =
    List.head a.images
        |> Maybe.map (\x -> x.uri150)
        |> Maybe.withDefault "http://www.free-icons-download.net/images/cd-music-icon-27881.png"


artist : Album -> String
artist a =
    List.head a.artists
        |> Maybe.map (\x -> x.name)
        |> Maybe.withDefault "no artist"


albumView : Album -> Html Msg
albumView a =
    div []
        [ div []
            [ img [ src <| image a ] []
            , div
                [ style [ ( "display", "inline-block" ) ] ]
                [ h1 [] [ text a.title ]
                , h6 [] [ text <| "by " ++ artist a ]
                ]
            ]
        , ol [] <| List.map (trackView a) a.tracklist
        ]


view : Model -> Html Msg
view model =
    RemoteData.map albumView model.album
        |> RemoteData.withDefault (text "Loading...")
