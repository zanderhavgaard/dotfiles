#!/bin/bash

# spotify seems to keep running a few processes in the background,
# but usually less than 4, but runs 4 when actually running...
# anyway very hacky

function setStatusIcon() {
  case $(playerctl status) in
  "Playing"*)
    status_icon=""
    ;;
  "Paused"*)
    status_icon=""
    ;;
  *)
    status_icon=""
    ;;
  esac
}

function echoPlaying() {
  echo " $status_icon $(playerctl metadata artist): $(playerctl metadata title) "
}

playerctl status >>/dev/null
playing=$?
if [ $playing = 0 ]; then
  setStatusIcon
  echoPlaying
else
  echo " off "
fi
