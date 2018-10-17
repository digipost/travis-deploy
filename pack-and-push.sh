#!/usr/bin/env bash

currentBranch=$1
apiKey=$2
projectRoot=$3
projectDirectories=$4

function fail_fast_if_one_fails(){
	set -e  
}

function unset_fail_fast_if_one_fails(){
	set +e  
}


function pack(){
    projectName=$1
    
    echo "Packing '$projectName' with output $projectRoot"
    dotnet pack $projectName --output $projectRoot/packed
}

function push(){
    fileName=$1    
  	dotnet nuget push $fileName --source https://api.nuget.org/v3/index.json --api-key $apiKey
}

echo "Will try to push nuget packages for branch '$currentBranch' with api-key '$apiKey' and root directory '$projectRoot' and project directories: '$projectDirectories'".

if [[ $TRAVIS_PULL_REQUEST != false ]];then
	echo "This is a pull-request build, skipping pack and deploy."
elif [[ $currentBranch == "beta" ]] || [[ $currentBranch == "master" ]];then
	echo "Is on beta or master branch, packing and deploying Nuget package ..."
	echo "Trying to pack from directory: $projectRoot."
	
    fail_fast_if_one_fails
           
    for project in $projectDirectories
    do
        pack $project
    done
    
    unset_fail_fast_if_one_fails    
    
    for entry in "$projectRoot/packed"/*
    do
        push $entry
    done
	
else
	echo "Is not on beta or master branch, skipping pack and deploy."
fi      