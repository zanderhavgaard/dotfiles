# list of countries to fetch mirrors for
COUNTRY_LIST="country=DK&country=SE&country=NO&country=DE"

# what protocols should be used
PROTOCOLS="https"

# build the URL for the request to the mirrorlist generator
URL="https://archlinux.org/mirrorlist/?$COUNTRY_LIST&protocol=$PROTOCOLS&use_mirror_status=on"

echo "Will use this url to fetch mirrors:"
echo "$URL"

echo "Getting mirrors and ranking by speed ..."

# first fetch up-to-date mirrors from the mirrorlist generator, then uncomment each line, and rank the mirrors using rankmirrors
curl -s "$URL" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - > /etc/pacman.d/mirrorlist

echo "Wrote new mirrorlist to /etc/pacman.d/mirrorlist"
echo "Contents:"
cat /etc/pacman.d/mirrorlist
