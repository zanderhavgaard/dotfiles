#!/bin/bash
if [[ -z $(ps cax | grep xautolock) ]]; then
	# not running / caffinated
	echo -e ''
else
	# running / not caffinated
	echo -e '﯈'
fi
