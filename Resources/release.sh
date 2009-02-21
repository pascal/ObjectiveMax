#!/bin/sh

cp -rv ../ ../../ObjectiveMax-Release
cd ../../ObjectiveMax-Release

pwd

rm -rfv .svn
rm -rfv */.svn
rm -rfv */*/.svn
rm -rfv */*/*/.svn
rm -rfv */*/*/*/.svn
rm -rfv */*/*/*/*/.svn

rm -rfv */build
rm -rfv */*/build

rm -rfv Documentation/html/*.map
rm -rfv Documentation/html/*.md5

rm -rfv c74support

