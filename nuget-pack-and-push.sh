#!/usr/bin/env bash

nuspecFile=$1
currentBranch=$2
apiKey=$3

echo "Will try to push nuget package based on .nuspec file '$nuspecFile' from branch '$currentBranch' with api-key '$apiKey'"

if [[ false != false ]];then
	echo "This is a pull-request build, skipping pack and deploy."
elif [[ $currentBranch == "beta" ]] || [[ $currentBranch == "master" ]];then
	echo "Is on beta or master branch, packing and deploying Nuget package ..."
	nuget pack $nuspecFile
	dotnet nuget push ../ --source https://api.nuget.org/v3/index.json --api-key $apiKey
else
	echo "Is not on beta or master branch, skipping pack and deploy."
fi