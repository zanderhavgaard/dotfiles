#!/bin/bash

# allow to exit..
set -e

# stream music from youtube to run in the background

# youtube video urls
synthwave="
https://www.youtube.com/watch?v=mZvQ9ipTK_8
https://www.youtube.com/watch?v=ICcFMBzOnYs
https://www.youtube.com/watch?v=gd6nEquwuhM
https://www.youtube.com/watch?v=6lBg2EEty24
https://www.youtube.com/watch?v=-7POr2G21LI
https://www.youtube.com/watch?v=_AXIOfilxi0
https://www.youtube.com/watch?v=isIj3tuQTDY
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
https://www.youtube.com/watch?v=ph_IhNseCBc
https://www.youtube.com/watch?v=qv3QkrYir5w
https://www.youtube.com/watch?v=OpYS5ATpI-U
https://www.youtube.com/watch?v=wOMwO5T3yT4
https://www.youtube.com/watch?v=ghvdhJRBMzE
https://www.youtube.com/watch?v=prHFVUaL_bU
https://www.youtube.com/watch?v=1pnoGkhxXaw
https://www.youtube.com/watch?v=KKkEklLLgS0
https://www.youtube.com/watch?v=oYprCmo1T-0
https://www.youtube.com/watch?v=hQqgdGgJPWw
https://www.youtube.com/watch?v=5B7UBni0yT8
https://www.youtube.com/watch?v=5B7UBni0yT8
https://www.youtube.com/watch?v=arzw0tFK5O4
https://www.youtube.com/watch?v=Eq7rItvK9Vg
https://www.youtube.com/watch?v=1Ho_8X16UHc
https://www.youtube.com/watch?v=L7BkunLMEpk
"

electronica="
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
https://www.youtube.com/watch?v=xHlqSABb7pI
https://www.youtube.com/watch?v=PC0rOWYWzDM
https://www.youtube.com/watch?v=LYgNN8lDQ5s
https://www.youtube.com/watch?v=SVrrjp-6pz8
https://www.youtube.com/watch?v=cVFzblT5VPE
https://www.youtube.com/watch?v=hicayypkI7g
https://www.youtube.com/watch?v=NCmmGtadax4
https://www.youtube.com/watch?v=2u6m7R2JV_g
"

misc_instrumental="
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

enter_dystopia_records="
https://www.youtube.com/watch?v=Yx5Q1N8Tiu8
https://www.youtube.com/watch?v=KS2mRR9EA4c
https://www.youtube.com/watch?v=gFTBNgZ9T3o
https://www.youtube.com/watch?v=ebNb7z6_OQY
https://www.youtube.com/watch?v=Gv3srScpOes
https://www.youtube.com/watch?v=J9Y4MSSxld4
https://www.youtube.com/watch?v=fF19V5KnJlg
https://www.youtube.com/watch?v=5dHJUmQZwGA
https://www.youtube.com/watch?v=2KoRKanghuo
https://www.youtube.com/watch?v=9fQQqz94alI
https://www.youtube.com/watch?v=YbLTzkoMb-s
https://www.youtube.com/watch?v=pkLy14BO8U0
https://www.youtube.com/watch?v=oCCaQLjW12U
https://www.youtube.com/watch?v=S4FgYsB9LC8
https://www.youtube.com/watch?v=nBvHKTljHqE
https://www.youtube.com/watch?v=E3R8FhK2jfY
https://www.youtube.com/watch?v=MnXbRJUEYmQ
https://www.youtube.com/watch?v=Bd1yJ1B-stA
https://www.youtube.com/watch?v=cz3kfT9mpiE
https://www.youtube.com/watch?v=z6VtGv1sOMI
https://www.youtube.com/watch?v=UcpNOJJceXY
https://www.youtube.com/watch?v=WO78DDfNJcI
https://www.youtube.com/watch?v=piFCQ4gGwZ4
https://www.youtube.com/watch?v=PI6JNj4XnjM
https://www.youtube.com/watch?v=3GGipHLNX4w
https://www.youtube.com/watch?v=BJb_i6_SO-8
https://www.youtube.com/watch?v=cjvl-mjuT5k
https://www.youtube.com/watch?v=M8M8etl4DzM
https://www.youtube.com/watch?v=m6YKWZd1vus
https://www.youtube.com/watch?v=Yw0Er8lTyn8
https://www.youtube.com/watch?v=fbgT0vCuANs
https://www.youtube.com/watch?v=NW2RUxrtTuE
https://www.youtube.com/watch?v=25o-sDMil0o
https://www.youtube.com/watch?v=EPBfoB6DTjE
https://www.youtube.com/watch?v=6ihuwXy2MtU
https://www.youtube.com/watch?v=msh5xdDo3f8
https://www.youtube.com/watch?v=jWLlVO5fVqA
https://www.youtube.com/watch?v=Ia5KDvCE1-s
https://www.youtube.com/watch?v=ThGu7SkhDak
https://www.youtube.com/watch?v=DBwfv4JXtRE
https://www.youtube.com/watch?v=9clsAa9ypi8
https://www.youtube.com/watch?v=bCbQXb2xPpA
https://www.youtube.com/watch?v=QkjHKPRrFII
https://www.youtube.com/watch?v=kOWPCZ7CnNU
https://www.youtube.com/watch?v=hUumqcL7f2o
https://www.youtube.com/watch?v=bfr73A9Cr_A
https://www.youtube.com/watch?v=5rEADN2IJ9k
https://www.youtube.com/watch?v=LyHjSz3ZGeI
https://www.youtube.com/watch?v=M0qybbtAu8s
https://www.youtube.com/watch?v=HR4dD-bDj0o
https://www.youtube.com/watch?v=Xj56R731QnY
https://www.youtube.com/watch?v=IENfuV_-924
https://www.youtube.com/watch?v=vwimxTQ2O4g
https://www.youtube.com/watch?v=vwimxTQ2O4g
https://www.youtube.com/watch?v=pfaOxu8ZKzk
https://www.youtube.com/watch?v=IVO05agHB_4
https://www.youtube.com/watch?v=xpeq_oJQNpc
https://www.youtube.com/watch?v=KjC-mstZXd8
https://www.youtube.com/watch?v=TZNYylQRV7E
https://www.youtube.com/watch?v=R6AiU2w1Fxk
https://www.youtube.com/watch?v=V5ru5t2Tz1U
https://www.youtube.com/watch?v=3ooPLnToOSE
https://www.youtube.com/watch?v=KQATTSmMxYc
https://www.youtube.com/watch?v=nn_unk8mCfI
https://www.youtube.com/watch?v=-ncgMODvsy4
https://www.youtube.com/watch?v=_-WFFqHJRoY
https://www.youtube.com/watch?v=WjRSrI0YGe4
https://www.youtube.com/watch?v=7LLfKbDgyF8
https://www.youtube.com/watch?v=-3exPL5Ip0Q
https://www.youtube.com/watch?v=RS2Nb5-VAWc
https://www.youtube.com/watch?v=dU_mfaDE0V4
https://www.youtube.com/watch?v=-40rSCVrjCk
https://www.youtube.com/watch?v=eL1YEOksKx8
https://www.youtube.com/watch?v=i-mLitakxz8
https://www.youtube.com/watch?v=-NFwbYDG8us
https://www.youtube.com/watch?v=TQPemdekXRY
https://www.youtube.com/watch?v=atSO4JtexH8
https://www.youtube.com/watch?v=SAfK9bUWcZk
https://www.youtube.com/watch?v=qwPOfEx5B_4
https://www.youtube.com/watch?v=SyeBqkvNbUc
https://www.youtube.com/watch?v=UXuZNMGyWLk
https://www.youtube.com/watch?v=RgIDqglqrxA
https://www.youtube.com/watch?v=UjjVlwsMOCk
https://www.youtube.com/watch?v=YVTtoAai-9k
https://www.youtube.com/watch?v=krTvsYDDIZw
https://www.youtube.com/watch?v=HqvG5hbErnc
https://www.youtube.com/watch?v=kA6d6dy4Xos
https://www.youtube.com/watch?v=ueeyID6pcag
https://www.youtube.com/watch?v=7bYDMTWL7DU
https://www.youtube.com/watch?v=5BxPt_8ewRA
https://www.youtube.com/watch?v=fCEiOoukh-Y
https://www.youtube.com/watch?v=N2cZ1FUbMEc
https://www.youtube.com/watch?v=eJRuKx23kUw
https://www.youtube.com/watch?v=bvyQWLUA2Bw
https://www.youtube.com/watch?v=CFDBlDv7pzM
https://www.youtube.com/watch?v=x7bTQO65MRo
https://www.youtube.com/watch?v=fdoA0b53Nl0
https://www.youtube.com/watch?v=ZEQdEeNqCe8
https://www.youtube.com/watch?v=r9opCd9q7xQ
https://www.youtube.com/watch?v=ax3iUVDnSHA
https://www.youtube.com/watch?v=nggGFpI9rxc
https://www.youtube.com/watch?v=AAFhdzNXH0E
https://www.youtube.com/watch?v=29psKDz4rhU
https://www.youtube.com/watch?v=1J_ssPVjbD8
https://www.youtube.com/watch?v=d6fmYn-kaFw
https://www.youtube.com/watch?v=vhg5nXQpvCc
https://www.youtube.com/watch?v=qtnW9m6EKPI
https://www.youtube.com/watch?v=eD95-1ig4O0
"

function stream_no_video {
	mpv \
		--ytdl-format=bestvideo+bestaudio \
		--cache=yes \
		--demuxer-max-bytes=123400KiB \
		--demuxer-readahead-secs=20 \
		--no-video \
		$1
}

function stream_with_video {
	mpv \
		--ytdl-format=bestvideo+bestaudio \
		--cache=yes \
		--demuxer-max-bytes=123400KiB \
		--demuxer-readahead-secs=20 \
		$1
}

function get_video_title {
	yt-dlp \
		--skip-download \
		--get-title \
		$1
}

function play_music {
	echo -e "\n>>> Press q to skip to next video <<<\n"
	shuffled=$(shuf -e $2)
	for url in $shuffled; do

		# clear the screen
		clear

		# get the video title
		video_title=$(get_video_title $url)

		# print title and url
		echo -e "Now playing ... ( $url )\n"
		figlet "$video_title"
		echo

		# play music
		[[ "$*" = *--show-video* ]] &&
			stream_with_video $url ||
			stream_no_video $url
	done
}

# concatenate urls
urls=$synthwave
urls+=' '
urls+=$electronica
urls+=' '
urls+=$misc_instrumental
urls+=' '
urls+=$enter_dystopia_records

# play video?
video=$1

# play the list of urls
play_music "$video" "$urls"

# say goodbye
echo -e "\tNo more music ..."
