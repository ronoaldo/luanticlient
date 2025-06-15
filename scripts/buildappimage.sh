#!/bin/bash
set -e

# Base build directory
WORKSPACE="$(readlink -f "$(dirname "$0")/..")"
export WORKSPACE

# Version -> branch calculation
export VERSION=${VERSION:dev}
export BRANCH=master
case $VERSION in
    [0-9].[0-9].[0-9]-[0-9]|[0-9].[0-9][0-9].[0-9]-[0-9]|[0-9].[0-9].[0-9][0-9]-[0-9]|[0-9].[0-9][0-9].[0-9][0-9]-[0-9])
        export BRANCH=${VERSION%%-*}
        echo "Version ${VERSION} detected as stable build, with increment. Using tag ${BRANCH}."
    ;;
    [0-9].[0-9].[0-9]|[0-9].[0-9][0-9].[0-9]|[0-9].[0-9].[0-9][0-9]|[0-9].[0-9][0-9].[0-9][0-9])
        export BRANCH=${VERSION}
        echo "Version ${VERSION} detected as stable build. Using tag ${BRANCH}."
    ;;
    *rc*|*beta*)
        echo "Version ${VERSION} detected as release candidate build. Using branch master."
    ;;
    *)
        echo "Version detected as a development build. Using branch master."
    ;;
esac

# Defaults (from master branch build)
export BINARY_NAME="luanti" # New name is now the default
export MINETEST_VERSION="${BRANCH}" # Version equals the branch
export MINETEST_GAME_VERSION="none" # No longer ships with the Minetest Game by default
export MINETEST_IRRLICHT_VERSION="none" # No longer requires Irrlicht from external repo
# Special cases setup for backwards compatibility versions
# and to pin releases and be able to rebuild older versions.
case ${BRANCH} in
    5.5.0)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt4
        export MINETEST_GAME_VERSION=5.5.0
        export BINARY_NAME="minetest"
    ;;
    5.5.1)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt5
        export MINETEST_GAME_VERSION=5.5.1
        export BINARY_NAME="minetest"
    ;;
    5.6.0)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt7
        export MINETEST_GAME_VERSION=5.6.0
        export BINARY_NAME="minetest"
    ;;
    5.6.1)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt8
        export MINETEST_GAME_VERSION=5.6.1
        export BINARY_NAME="minetest"
    ;;
    5.7.0)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt10
        export MINETEST_GAME_VERSION=5.7.0
        export BINARY_NAME="minetest"
    ;;
    5.8.0)
        export MINETEST_IRRLICHT_VERSION=1.9.0mt13
        export MINETEST_GAME_VERSION=5.7.0
        export BINARY_NAME="minetest"
    ;;
    # 5.9.0+ has bundled irrlicht and we now have rolling release of minetest_game
    5.9.0)
        export MINETEST_GAME_VERSION=master
        export BINARY_NAME="minetest"
    ;;
    5.9.1)
        export MINETEST_GAME_VERSION=master
        export BINARY_NAME="minetest"
    ;;
    # 5.10.0+ was renamed to Luanti and from here on
    # we no longer bundle Minetest Game
    5.10.0|5.11.0|5.12.0) ;;
    master|main) ;;
esac

install_linuxdeploy() {
    pushd /opt
	PKG_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20250213-2/linuxdeploy-x86_64.AppImage"
    curl -sSL --fail "$PKG_URL" > linuxdeploy 
    chmod +x linuxdeploy 
    ./linuxdeploy --appimage-extract
    mv squashfs-root linuxdeploy.AppDir
    ln -s /opt/linuxdeploy.AppDir/AppRun /usr/bin/linuxdeploy
    linuxdeploy --version
    popd
}

git_clone() {
    git clone "$1" "$2"
    git -C "$2" checkout "$3"
    rm -rf "${2}/.git"
}

download_sources() {
    mkdir -p /tmp/work/build
    
    pushd /tmp/work
    git_clone https://github.com/minetest/minetest.git      ./minetest                     "${MINETEST_VERSION}"
    if [ "${MINETEST_GAME_VERSION}" != "none" ]; then
        git_clone https://github.com/minetest/minetest_game.git ./minetest/games/minetest_game "${MINETEST_GAME_VERSION}"
    fi
    if [ "${MINETEST_IRRLICHT_VERSION}" != "none" ]; then
        git_clone https://github.com/minetest/irrlicht      ./minetest/lib/irrlichtmt      "${MINETEST_IRRLICHT_VERSION}"
    fi
    popd
}

install_build_dependencies() {
    apt-get update
    # appimage requirements
    apt-get install file gpg gtk-update-icon-cache curl git -yq
    # Luanti requirements
    apt-get install \
        g++ make libc6-dev cmake libpng-dev libjpeg-dev libgl1-mesa-dev \
        libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev \
        libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev \
        libzstd-dev libluajit-5.1-dev gettext libsdl2-dev -yq
    apt-get clean
}

build() {
    # Build Luanti
    pushd /tmp/work/build
    cmake /tmp/work/minetest \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DBUILD_SERVER=FALSE \
        -DBUILD_CLIENT=TRUE \
        -DBUILD_UNITTESTS=FALSE \
        -DVERSION_EXTRA=unofficial
    #shellcheck disable=2046
    make -j$(nproc)
    popd
}

bundle_appimage() {
    pushd /tmp/work/build
    make install DESTDIR=AppDir
	if [ -d ../minetest/games/minetest_game ] ; then
    	mkdir -p AppDir/usr/share/${BINARY_NAME}/games/minetest_game/
        cp -r ../minetest/games/minetest_game/* AppDir/usr/share/${BINARY_NAME}/games/minetest_game/
    fi
	linuxdeploy --appdir AppDir --output appimage
    mkdir -p "$WORKSPACE/build"
    mv ./*.AppImage* "$WORKSPACE/build"
    chmod a+x "$WORKSPACE"/build/*.AppImage
    popd
}

myuid=$(id -u)
if [ x"$myuid" != x"0" ]; then
    echo "You need to run this as root"
    exit 1
fi

echo
echo "*** Building ${BINARY_NAME} ${VERSION} ***"
echo "- Branch: ${BRANCH}; Luanti Version: ${MINETEST_VERSION}"
echo "- Minetest Game Version: ${MINETEST_GAME_VERSION}; Irrlicht: ${MINETEST_IRRLICHT_VERSION}"
echo

install_build_dependencies
install_linuxdeploy
download_sources
build
bundle_appimage
