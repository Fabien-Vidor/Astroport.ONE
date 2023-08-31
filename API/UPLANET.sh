################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## API: UPLANET
## Dedicated to OSM2IPFS & UPlanet Client App
# ?uplanet=EMAIL&LAT=LON
## https://git.p2p.legal/qo-op/OSM2IPFS
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/../tools/my.sh"

start=`date +%s`

echo "PORT=$1
THAT=$2
AND=$3
THIS=$4
APPNAME=$5
WHAT=$6
OBJ=$7
VAL=$8
MOATS=$9
COOKIE=$10"
PORT="$1" THAT="$2" AND="$3" THIS="$4"  APPNAME="$5" WHAT="$6" OBJ="$7" VAL="$8" MOATS="$9" COOKIE="$10"
### transfer variables according to script
QRCODE=$(echo "$THAT" | cut -d ':' -f 1) # G1nkgo compatible

HTTPCORS="HTTP/1.1 200 OK
Access-Control-Allow-Origin: ${myASTROPORT}
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

"
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

## GET TW
mkdir -p ~/.zen/tmp/${MOATS}/

## DIRECT VISA.print.sh
PLAYER=${THAT}
SALT=${AND}
LAT=${AND}
PEPPER=${THIS}
LON=${THIS}
PASS=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-7)


                EMAIL="${PLAYER,,}" # lowercase

                [[ ! ${EMAIL} ]] && (echo "$HTTPCORS ERROR - MISSING ${EMAIL} FOR ${WHAT} CONTACT" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) &&  echo "(☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. &&  exit 0

                ## CHECK WHAT IS EMAIL
                if [[ "${EMAIL}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
                    echo "VALID ${EMAIL} EMAIL OK"
                else
                    echo "BAD EMAIL"
                    (echo "$HTTPCORS KO ${EMAIL} : bad '"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 0
                fi


echo "${MY_PATH}/../tools/VISA.print.sh" "${EMAIL}"  "'"$SALT"'" "'"$PEPPER"'" "'"$PASS"'"
${MY_PATH}/../tools/VISA.print.sh "${EMAIL}"  "$SALT" "$PEPPER" "$PASS" ##
[[ ${EMAIL} != "" && ${EMAIL} != $(cat ~/.zen/game/players/.current/.player 2>/dev/null) ]] && rm -Rf ~/.zen/game/players/${EMAIL}/

# UPLANET #############################################
## OCCUPY COMMON CRYPTO KEY CYBERSPACE
## SALT="UPLANET LAT $LAT" PEPPER="UPLANET LON $LON"
######################################################
echo "UMAP = $LAT:$LON"
echo "# CALCULATING MAP G1PUB WALLET"
${MY_PATH}/../tools/keygen -t duniter -o ~/.zen/tmp/${MOATS}/secret.key  "$LAT" "$LON"
G1PUB=$(cat ~/.zen/tmp/${MOATS}/secret.key | grep 'pub:' | cut -d ' ' -f 2)
[[ ! ${G1PUB} ]] && (echo "$HTTPCORS ERROR - (╥☁╥ ) - KEYGEN  COMPUTATION DISFUNCTON"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 1
echo "MAPG1PUB : ${G1PUB}"

echo "# CALCULATING UMAP IPNS ADDRESS"
ipfs key rm ${G1PUB} > /dev/null 2>&1
rm -f ~/.zen/tmp/${MOATS}/${G1PUB}.ipns.key
${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/tmp/${MOATS}/${G1PUB}.ipns.key "$LAT" "$LON"
UMAPNS=$(ipfs key import ${G1PUB} -f pem-pkcs8-cleartext ~/.zen/tmp/${MOATS}/${G1PUB}.ipns.key )
[[ ! ${UMAPNS} ]] && (echo "$HTTPCORS ERROR - (╥☁╥ ) - UMAPNS  COMPUTATION DISFUNCTON"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 1

echo "# OSM2IPFS using Chromium loading Umap.html"


echo "${HTTPCORS}" > ~/.zen/tmp/${MOATS}/http.rep
cat ~/.zen/tmp/${PLAYER}.moatube.json >> ~/.zen/tmp/${MOATS}/http.rep
cat ~/.zen/tmp/${MOATS}/http.rep | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &


end=`date +%s`
echo "(TW) MOA Operation time was "`expr $end - $start` seconds.
exit 0
