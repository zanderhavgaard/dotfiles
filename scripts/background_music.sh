#!/bin/bash

# allow to exit..
set -e

# stream music from youtube to run in the background

# youtube video urls
music_urls="

https://www.youtube.com/watch?v=mZvQ9ipTK_8
https://www.youtube.com/watch?v=ICcFMBzOnYs
https://www.youtube.com/watch?v=gd6nEquwuhM
https://www.youtube.com/watch?v=6lBg2EEty24
https://www.youtube.com/watch?v=-7POr2G21LI
https://www.youtube.com/watch?v=_AXIOfilxi0
https://www.youtube.com/watch?v=isIj3tuQTDY
https://www.youtube.com/watch?v=dgCnYsDTiXU
https://www.youtube.com/watch?v=6TEGPexTqr4
https://www.youtube.com/watch?v=ByS1Rlk_AL8
https://www.youtube.com/watch?v=WI4-HUn8dFc
https://www.youtube.com/watch?v=dgCnYsDTiXU
https://www.youtube.com/watch?v=5E4uPA2wwjY
https://www.youtube.com/watch?v=8iNczzhZmbc
https://www.youtube.com/watch?v=PWMTDRWJqu4
https://www.youtube.com/watch?v=4P9xkQagCcc
https://www.youtube.com/watch?v=Fs13eG36VR8
https://www.youtube.com/watch?v=oquatvvKyBc
https://www.youtube.com/watch?v=qWZL5RnfgtI
https://www.youtube.com/watch?v=KPa1_7AF1lM
https://www.youtube.com/watch?v=e6zZ7PIk9Vc
https://www.youtube.com/watch?v=7q1bbRzNQmI
https://www.youtube.com/watch?v=KPWGYWr_3O0
https://www.youtube.com/watch?v=POZ41np5d5U
https://www.youtube.com/watch?v=C3ANuZFjNm8
https://www.youtube.com/watch?v=sN9OxR-JTn4
https://www.youtube.com/watch?v=Pz1a9MM-Vn4
https://www.youtube.com/watch?v=Ig-86pjzzXg
https://www.youtube.com/watch?v=6TEGPexTqr4
https://www.youtube.com/watch?v=qk1nnAHI1mI
https://www.youtube.com/watch?v=wOMwO5T3yT4
https://www.youtube.com/watch?v=emNgfuw8vlA
https://www.youtube.com/watch?v=kwLTw8F8yN8
https://www.youtube.com/watch?v=GBUCmMxmup0
https://www.youtube.com/watch?v=BfCgF10C58Q
https://www.youtube.com/watch?v=a0O616pwkYk
https://www.youtube.com/watch?v=OvYeYtujzjQ
https://www.youtube.com/watch?v=Ya3XufguZMY
https://www.youtube.com/watch?v=ph_IhNseCBc
https://www.youtube.com/watch?v=qv3QkrYir5w
https://www.youtube.com/watch?v=OpYS5ATpI-U
https://www.youtube.com/watch?v=wOMwO5T3yT4
https://www.youtube.com/watch?v=ghvdhJRBMzE
https://www.youtube.com/watch?v=prHFVUaL_bU
https://www.youtube.com/watch?v=1pnoGkhxXaw
https://www.youtube.com/watch?v=KKkEklLLgS0


https://www.youtube.com/watch?v=qEI1_oGPQr0
https://www.youtube.com/watch?v=B2J0ZUe6zzk
https://www.youtube.com/watch?v=JrQLGtNeguk
https://www.youtube.com/watch?v=v5i_j10Ur9k
https://www.youtube.com/watch?v=YxZRw1Xh8_c
https://www.youtube.com/watch?v=MzRoBRQVlzM
https://www.youtube.com/watch?v=kquBS_VpRZ4
https://www.youtube.com/watch?v=6u5a7_-a3vM
https://www.youtube.com/watch?v=zfzurK_w4qo
https://www.youtube.com/watch?v=liHgt4CbodY
https://www.youtube.com/watch?v=iEGFFyv0MH4
https://www.youtube.com/watch?v=wtg7AetxuWo
https://www.youtube.com/watch?v=GGBm9gTY2NU
https://www.youtube.com/watch?v=avmjunRX_xo
https://www.youtube.com/watch?v=tM0sxOAu7mc
https://www.youtube.com/watch?v=YQWA0kkT3lY
https://www.youtube.com/watch?v=2_kNjDFg4t8
https://www.youtube.com/watch?v=IVvpfQjR6jQ
https://www.youtube.com/watch?v=xHlqSABb7pI
https://www.youtube.com/watch?v=PC0rOWYWzDM
https://www.youtube.com/watch?v=LYgNN8lDQ5s
https://www.youtube.com/watch?v=SVrrjp-6pz8
https://www.youtube.com/watch?v=MzmenT8hz9Q
https://www.youtube.com/watch?v=cVFzblT5VPE
https://www.youtube.com/watch?v=hicayypkI7g
https://www.youtube.com/watch?v=NCmmGtadax4
https://www.youtube.com/watch?v=2u6m7R2JV_g


https://www.youtube.com/watch?v=Zz6oob45faU
https://www.youtube.com/watch?v=N0LZ20ppkNo
https://www.youtube.com/watch?v=s-jtdKjzQaE
https://www.youtube.com/watch?v=kNRIFhkYONc
https://www.youtube.com/watch?v=-gXrS6eKfjk
https://www.youtube.com/watch?v=kjxxVkSd0XA
https://www.youtube.com/watch?v=mA8szi1YFZc
https://www.youtube.com/watch?v=pwa4U0ccECY
https://www.youtube.com/watch?v=2rxG8quzCtA
https://www.youtube.com/watch?v=uh-zU_XODpc
https://www.youtube.com/watch?v=44Q5VePSaCs
https://www.youtube.com/watch?v=w0jyU13gtBs
https://www.youtube.com/watch?v=aXMX0sAL9bQ



"

mpv_command="mpv --ytdl-format=bestvideo+bestaudio --cache=yes --demuxer-max-bytes=123400KiB --demuxer-readahead-secs=20"

# the command to play videos
if [[ "$*" != *--show-video* ]]; then
    mpv_command="${mpv_command} --no-video"
fi

echo -e "\n>>> Press q to skip to next video <<<\n"

for url in $(shuf -e $music_urls) ; do

    # get the video title
    video_title=$(youtube-dl --skip-download --get-title $url)

    # print stuff
    echo
    echo -e "\tNow playing ..."
    echo
    echo -e "\t$url"
    echo
    figlet "$video_title"
    echo


    # play music
    $mpv_command $url

    echo

done

# say goodbye
echo -e "\tNo more music ..."
