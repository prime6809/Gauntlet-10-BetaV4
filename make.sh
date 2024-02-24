#!/bin/bash

if [ ! -f ./ucc-bin ]
then
	echo "please run this from the UT System directory"
	exit 0
fi 

if [ -f Gauntlet-10-BetaV4.u ]
then
	mv Gauntlet-10-BetaV4.u Gauntlet-10-BetaV4.u.old
fi 

./ucc-bin make ini=../Gauntlet-10-BetaV4/make.ini -nohomedir
