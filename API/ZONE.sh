################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## API: ZONE
## Used by OSM2IPFS map_render.html & other UPlanet Client App
# ?zone=DEG&ulat=LAT&ulon=LON
## Search for TW numbers in received zone
# = json
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

HTTPCORS="HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

"

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

## RUNNING UPLANET LAT/LON TW DETECTION
mkdir -p ~/.zen/tmp/${MOATS}/
# GET RECEPTION : zone=0.001&ulat=0.02&ulon=0.01
DEG=${THAT}
[[ -z $DEG ]] && DEG=1
# DEG=$(echo "$DEG * 10" | bc -l )
LAT=${THIS}
[[ -z $LAT ]] && LAT=0.00
LON=${WHAT}
[[ -z $LON ]] && LON=0.00

# PREPARE HTTP RESPONSE (application/json)
echo "${HTTPCORS}" > ~/.zen/tmp/${MOATS}.http
sed -i "s~text/html~application/json~g"  ~/.zen/tmp/${MOATS}.http

LAT=$(makecoord $LAT)
LON=$(makecoord $LON)

echo "REQUEST $LAT / $LON / $DEG"

## REGION LEVEL
if [[ $DEG == "0.1" ]]; then
    # /ipfs/QmYNpzG3qi6GzciP6D6NsLgv5KwcsKtYJ5EZt7s23ToaNj/map_render.html?southWestLat=43.60&southWestLon=1.40&deg=0.1
    LAT=$(echo ${LAT} | cut -d '.' -f 1)
    LON=$(echo ${LON} | cut -d '.' -f 1)
    REGION="_${LAT}_${LON}"
    echo "REGION = ${REGION}"
fi

## SECTOR LEVEL
if [[ $DEG == "0.01" ]]; then
    # /ipfs/QmYNpzG3qi6GzciP6D6NsLgv5KwcsKtYJ5EZt7s23ToaNj/map_render.html?southWestLat=43.60&southWestLon=1.40&deg=0.1
    SECLAT="${LAT::-1}"
    SECLON="${LON::-1}"
    SECTOR="_${SECLAT}_${SECLON}"
    echo "SECTOR = ${SECTOR}"
    ZONEG1PUB=$(${MY_PATH}/../tools/keygen -t duniter "${UPLANETNAME}${SECTOR}" "${UPLANETNAME}${SECTOR}")
    ZONETW="/ipns/"$(${MY_PATH}/../tools/keygen -t ipfs "${UPLANETNAME}${SECTOR}" "${UPLANETNAME}${SECTOR}")"/TW"

fi

## UMAP LEVEL
if [[ $DEG == "0.001" ]]; then

    G1PUB=$(${MY_PATH}/../tools/keygen -t duniter "${UPLANETNAME}${LAT}" "${UPLANETNAME}${LON}")
    ${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/tmp/${MOATS}/${UMAP}.priv  "${UPLANETNAME}${LAT}" "${UPLANETNAME}${LON}"
    ipfs key rm ${G1PUB} > /dev/null 2>&1 ## AVOID ERROR ON IMPORT
    UMAPNS=$(ipfs key import ${G1PUB} -f pem-pkcs8-cleartext ~/.zen/tmp/${MOATS}/${UMAP}.priv)

    echo '{ "gridNumbers": [ {"lat": '${LAT}', "lon": '${LON}', "number": "UMAP_'${LAT}'_'${LON}'", "ipns": "'${myIPFS}/ipns/${UMAPNS}/_index.html'" } ] }' >> ~/.zen/tmp/${MOATS}.http
    cat ~/.zen/tmp/${MOATS}.http | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
    rm -Rf ~/.zen/tmp/${MOATS}/
    end=`date +%s`
    echo "(EXPLORE ZONE $DEG)_${LAT}_${LON} $UMAPNS Operation time was "`expr $end - $start` seconds.
    exit 0

fi

## ALL OTHER DEG : SEARCH FOR UPLANET TW NUMBERS
echo '{ "gridNumbers": [' >> ~/.zen/tmp/${MOATS}.http

for i in $(seq 0 9);
do
    ZLAT=$(echo "$LAT + $DEG * $i" | bc -l )
    [[ -z  ${ZLAT} ]] && ZLAT=0
    # [[ ! $(echo $ZLAT | grep "\." ) ]] && ZLAT="${ZLAT}."
        for j in $(seq 0 9); do
            ZLON=$(echo "$LON + $DEG * $j" | bc -l )
            [[ -z  ${ZLON} ]] && ZLON=0
            # [[ ! $(echo $ZLON | grep "\." ) ]] && ZLON="${ZLON}."
            echo " ## SEARCH _${ZLAT}*_${ZLON}*"
            swarmnum=$(ls -d ~/.zen/tmp/swarm/*/UPLANET/_${ZLAT}*_${ZLON}*/TW/* 2>/dev/null | wc -l )
            nodenum=$(ls -d ~/.zen/tmp/${IPFSNODEID}/UPLANET/_${ZLAT}*_${ZLON}*/TW/* 2>/dev/null | wc -l )
            totnum=$(( swarmnum + nodenum ))

            [[ $totnum -gt 9 ]] && totnum="X"

            [[ $totnum != "0" ]] && echo '{"lat": '${ZLAT}', "lon": '${ZLON}', "number": "'${totnum}'", "ipns": "'${ZONETW}'" }
            ,' >> ~/.zen/tmp/${MOATS}.http && echo "$DEG :" '{"lat": '${ZLAT}', "lon": '${ZLON}', "number": "'${totnum}'", "ipns": "'${ZONETW}'" }'

        done
done

sed -i '$ d' ~/.zen/tmp/${MOATS}.http ## REMOVE LAST ','

echo ']}'  >> ~/.zen/tmp/${MOATS}.http

cat ~/.zen/tmp/${MOATS}.http | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &

rm -Rf ~/.zen/tmp/${MOATS}/
end=`date +%s`
echo "(ZONE) Operation time was "`expr $end - $start` seconds.
exit 0
