#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

# start npm install
handleEcho "The current branch is $CI_COMMIT_REF_NAME !"

folder=$(pwd)
env=$CI_COMMIT_REF_NAME
source=/data
single=$source/website
tangible=$single/$project
cache=$tangible/$env
cacheNodeModules=$cache/node_modules
package=$cache/package.json

function removeModules() {
	rm -rf $1/node_modules
}

function handleInstall() {
	if [ -f $1/package.json ]; then
		cp -f $1/package.json $2/package.json
		handleEcho "copy package.json success"
	fi

	if [ -f $1/package-lock.json ]; then
		cp -f $1/package-lock.json $2/package-lock.json
		handleEcho "copy package-lock.json success"
	fi

	if [ -f $1/.npmrc ]; then
		cp -f $1/.npmrc $2/.npmrc
		handleEcho "copy .npmrc success"
	fi

	removeModules $2

	cd $2 && npm ci
}

function handleModules() {
	ln -s $1/node_modules $2/node_modules
}

handleEcho "start npm install"

if [ -d $single ]; then
	handleEcho "$single exists."
else
	mkdir $single
	handleEcho "create folder $single."
fi

if [ -d $tangible ]; then
	handleEcho "$tangible exists."
else
	mkdir $tangible
	handleEcho "create folder $tangible."
fi

# 处理部分情况下，install 未成功安装，无 node_modules 的情况
if [ ! -d $cacheNodeModules ]; then
	echo "no cache node_modules, so remove cache dir"
	rm -rf $cache
fi

if [ -d $cache ]; then
	handleEcho "$cache exists."
else
	mkdir $cache
	handleEcho "create folder $cache."
fi

if [ -f $package ]; then
	handleEcho "$cache/package.json exists."
else
	handleInstall $folder $cache
	handleEcho "copy file and npm install."
fi

diff $folder/package.json $cache/package.json

if [ $? -eq 0 ]; then
	removeModules $folder
	handleModules $cache $folder
	handleEcho "soft link node_modules to $folder."
else
	handleInstall $folder $cache
	handleModules $cache $folder
	handleEcho "npm install and soft link node_modules to $folder."
fi

handleCallback "npm install success" "npm install error"
