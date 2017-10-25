#!/bin/bash
#
# This is a library for Command: echo
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-26
#

#
# echo text
# $1: color
# $2: message text
function echo_text()
{
   echo -e "\033[${1} ${2} [\033[0m"
}


#
# echo infomation
function echoInfo()
{
   echo_text "34m" "$1"
}

#
# echo warning text
function echoWarn()
{
   echo_text "33m" "$1"
}


#
# echo OK text
function echoDone()
{
   echo_text "32m" "$1"
}


#
# echo error text
function echoError()
{
   echo_text "31m" "$1"
}

