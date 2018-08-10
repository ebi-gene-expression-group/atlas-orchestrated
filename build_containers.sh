#!/bin/env bash

### Constants ###

SCRIPT_NAME="${0##*/}"
TRUE='true'
FALSE='false'
DFT_DOCKER_PUSH_ENABLED=$TRUE

### Functions ###

function log() {
  echo -e "$@" >&2
}

function error {
	local msg=$1
	local code=$2
	[[ -z $code ]] && code=1
	log "[ERROR] $msg"

	exit $code
}


function debug {
    local msg=$1
    local level=$2
    [[ -n $level ]] || level=1

    [[ $DEBUG -lt $level ]] || log "[DEBUG] $msg"
}

function warning {
    local msg=$1

    log "[WARNING] ##### $msg #####"
}

function print_help {
    (
        echo "Usage: $SCRIPT_NAME [options]"
        echo
        echo "Build Atlas docker images for different purposes."
        echo
        echo "Options:"
        echo "   -g, --debug                    Debug mode. [false]"
        echo "   -h, --help                     Print this help message."
        echo "   -p, --push                     Push docker images. You can also set environment variable DOCKER_PUSH_ENABLED to \"true\". [true]"
        echo "   +p, --no-push                  Do not push dockers. You can also set environment variable DOCKER_PUSH_ENABLED to \"false\"."
        echo "       --no-cache                 Tell Docker not to use cached images. [false]"
        echo "       --postgres-tag   <tag>     Set the tag for the Postgres container image."
        echo "       --sc-tag        <tag>      Set the tag for the Atlas SC container image."
        echo "   -u, --container-user <user>    Set the container user. You can also set the environment variable CONTAINER_USER."
        echo "   -r, --container-registry <reg> Set the container registry. You can also set the environment variable CONTAINER_REGISTRY."
        echo
    ) >&2
}

function read_args {

    local args="$*" # save arguments for debugging purpose

    # Read options
    while [[ $# > 0 ]] ; do
        shift_count=1
        case $1 in
            -g|--debug)              DEBUG=$((DEBUG + 1)) ;;
            -h|--help)               print_help ; exit 0 ;;
            -p|--push)               DOCKER_PUSH_ENABLED=$TRUE ;;
            +p|--no-push)            DOCKER_PUSH_ENABLED=$FALSE ;;
            --no-cache)              NO_CACHE="--no-cache" ;;
            --postgres-tag)          OVERRIDE_POSTGRES_TAG="$2" ; shift_count=2 ;;
            --sc-tag)                OVERRIDE_SC_TAG="$2" ; shift_count=2 ;;
            -u|--container-user)     CONTAINER_USER="$2" ; shift_count=2 ;;
            -r|--container-registry) CONTAINER_REGISTRY="$2" ; shift_count=2 ;;
            *) error "Illegal option $1." 98 ;;
        esac
        shift $shift_count
    done

    # Debug messages
    debug "Command line arguments: $args"
    debug "Argument DEBUG=$DEBUG"
    debug "Argument DOCKER_PUSH_ENABLED=$DOCKER_PUSH_ENABLED"
    debug "Argument DOCKER_USER=$DOCKER_USER"
    debug "Argument OVERRIDE_TAG=$OVERRIDE_SC_TAG"
    debug "Argument OVERRIDE_POSTGRES_TAG=$OVERRIDE_POSTGRES_TAG"
    debug "shift_count=$shift_count"
}

### MAIN ###
read_args "$@"

DOCKER_PUSH_ENABLED=${DOCKER_PUSH_ENABLED:-$DFT_DOCKER_PUSH_ENABLED}

DOCKER_REPO=${CONTAINER_REGISTRY:-}
DOCKER_USER=${CONTAINER_USER:-pcm32}

ATLAS_SC_RELEASE=${ATLAS_SC_RELEASE:-master}
ATLAS_SC_REPO=${ATLAS_SC_REPO:-ebi-gene-expression-group/atlas}

# Set tags
TAG=${OVERRIDE_TAG:-latest}

# This is Jenkins specific.
if [[ -n ${CONTAINER_TAG_PREFIX:-} && -n ${BUILD_NUMBER:-} ]]; then
   TAG=${CONTAINER_TAG_PREFIX}.${BUILD_NUMBER}
fi

if [[ -n "${DOCKER_REPO}" ]]; then
   # Append slash, avoiding double slash
   DOCKER_REPO="${DOCKER_REPO%/}/"
fi

ATLAS_SC_BASE_BUILDER_TAG=$DOCKER_REPO$DOCKER_USER/atlas-sc-base:$TAG
ATLAS_SC_TAG=$DOCKER_REPO$DOCKER_USER/atlas-sc:$TAG

# if [[ -n "${OVERRIDE_POSTGRES_TAG:-}" ]]; then
#    POSTGRES_TAG="${OVERRIDE_POSTGRES_TAG}"
# else
#    PG_Dockerfile="container-postgres-sc/Dockerfile"
#
#    [[ -f "${PG_Dockerfile}" ]] || error "The Atlas-postgres Dockerfile is missing under container-postgres-sc." 99
#    POSTGRES_VERSION=$(grep FROM "${PG_Dockerfile}" | awk -F":" '{ print $2 }')
#
#    POSTGRES_TAG=$DOCKER_REPO$DOCKER_USER/atlas-sc-postgres:$POSTGRES_VERSION"_for_"$GALAXY_VER_FOR_POSTGRES
# fi

# Do work
docker build $NO_CACHE --build-arg ATLAS_SC_RELEASE=$ATLAS_SC_RELEASE -t $ATLAS_SC_BASE_BUILDER_TAG container-atlas-sc-base/

sed s+ATLAS_SC_BASE_BUILDER+$ATLAS_SC_BASE_BUILDER_TAG+ container-atlas-sc/Dockerfile > container-atlas-sc/Dockerfile-set-builder
docker build $NO_CACHE -t $ATLAS_SC_TAG -f container-atlas-sc/Dockerfile-set-builder container-atlas-sc/

if $DOCKER_PUSH_ENABLED; then
  docker push $ATLAS_SC_TAG
fi


log "Relevant containers:"
log "Atlas SC:          $ATLAS_SC_TAG"
log "Base builder:      $ATLAS_SC_BASE_BUILDER_TAG"
