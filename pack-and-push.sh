#!/usr/bin/env bash

tag=$1; shift
apiKey=$1; shift
projectRoot=$1; shift
projectDirectories=( "$@" )

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

echo "Will try to push nuget packages for tag '$tag' with api-key '$apiKey' and root directory '$projectRoot' and project directories:"
printf "%s\n" "${projectDirectories[@]}"
echo ""
echo "Trying to pack from $projectRoot ..."

fail_fast_if_one_fails
       
for project in ${projectDirectories[*]}
do
    pack $project
done

unset_fail_fast_if_one_fails    

echo "... and deploying Nuget packages ..."

for entry in "$projectRoot/packed"/*
do
    push $entry
done
