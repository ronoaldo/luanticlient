# Minetest client AppImage builds (unofficial)

[Ler em português](./README.pt-BR.md)

Based on Debian 11, this project builds AppImages to help you test recent
development builds as well as easily download and run
[Minetest](https://www.minetest.net) in any Linux distro by providing it  with
bundled dependencies.

Tested on:

* Debian 11
* Debian 12
* Ubuntu 22.04
* Ubuntu 24.04

Probably will not work on:

* Ubuntu 18.04 - Use the images produced by the Gitlab CI

## Why?

This project was created because the official Minetest AppImages are built using
the Ubuntu Bionic base and for some obscure reason, it won't launch on either
Debian 11 or Ubuntu 22.04.

This project uses a Debian 11 base, and the produced AppImages work on both
Debian and Ubuntu most recent releases.

## How to use them?

[AppImage](https://appimage.org/) format is a simple way to distribute Linux
programs to users in any distribution. It includes a portable runtime, and it
bundles the application dependencies so it should run on your machine without
modifications.

To start using the AppImage, just download it from the
[Releases](https://github.com/ronoaldo/minetestclient/releases) page on Github,
make it executable either using your file manager GUI or the command line with
`chmod +x Minetest*.AppImage`, then execute it as `./Minetest*.AppImage` or from
the file manager GUI with a single/double click.

### Missing FUSE

If you have an error starting the AppImage complaining about FUSE (it happened
to me while testing on Ubuntu 22.04), just install the `libfuse2` package:

    sudo apt-get install libfuse2 -yq

Note: this should not happen as of 5.12.0 and later versions, as we switched
to building the AppImage versions with `linuxdeploy` with now utilizes a better
system with an static libfuse implementation.

## Portable home folder

Want to test the release candidate without breaking your worlds? No problem!
You can have a portable alternative Home directory to test this one out!

To use this feature, you just create a folder with the same name of the program,
and a `.home` suffix. For instance, the program
`Minetest-5.6.0-rc1_x86_64.AppImage` will use the
`Minetest-5.6.0-rc1_x86_65.AppImage.home` folder as a home directory if it
exists. 

One simple way to get started is from the terminal by using the
`--appimage-portable-home` command line flag:

    ./Minetest*.AppImage --appimage-portable-home

## Better desktop integration

You can also install the companion program `appimagelauncher` that will help you
better integrate the test builds with your system. On Debian and derivatives,
you can to so by installing it form `apt`:

    sudo apt install appimagelauncher -yq
