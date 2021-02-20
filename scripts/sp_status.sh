#!/bin/bash

# spotify seems to keep running a few processes in the background,
# but usually less than 4, but runs 4 when actually running...
# anyway very hacky

function setStatusIcon(){
  case $(playerctl status) in
  "Playing"*)
    status_icon="";;
  "Paused"*)
    status_icon="";;
  *)
    status_icon="";;
  esac
}

# FIXME
# if [[ $(ps a | grep background_music) ]]; then
    # music_url=$(ps a | grep -oP "https\:\/\/www.youtube.com/watch\?v\=.*")
    # music_title=$(youtube-dl --skip-download --get-title $music_url)
    # # we set the title
    # echo " $music_title"
    # url=$(ps a | grep -oP "https\:\/\/www.youtube.com/watch\?v\=.*")
    # # we don't need to update the script until we play the next track,
    # # so we just wait until a new track is playing
    # while [[ $url == $music_url ]] ; do
        # url=$(ps a | grep -oP "https\:\/\/www.youtube.com/watch\?v\=.*")
    # done
# condition is a super HACK fix, it some point..
# if [[ $(ps cax | grep -c spotify) < 4 ]]; then
if [[ $(ps cax | grep -c spotify) > 3 ]] || [[ $(ps cax | grep -c ncspot) > 0 ]]; then
  setStatusIcon
  echo " $status_icon $(playerctl metadata artist): $(playerctl metadata title) "
else
  echo "off"
fi
