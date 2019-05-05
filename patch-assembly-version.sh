#!/usr/bin/env bash

buildPropertiesFile=$1
tag=$2

echo "Starting to patch version in '${buildPropertiesFile}'. Current tag is '${tag}' ..."

function stop_if_no_assembly_version_found {
    version=$1

	if [[ ${version} -eq "0" ]];then
		echo "Did not find assembly version with version patcher. Please check that patcher is installed correctly and that it can find the assembly version files. Exiting!" >&2 #Echo and send to stderr
		exit 1 # terminate and indicate error
	fi
}

function print_versions {
    assemblyVersion=$1
    nugetVersion=$2
    
    echo "======================================================================"
	echo " Assembly Version/.dll (AssemblyVersion): $assemblyVersion"
	echo " Nuget version (Version): $nugetVersion"
	echo "======================================================================"
}


if [ -z "$tag" ] # If no tag
then
    #Do no replacement - it does not matter what the version is, so just setting it for fun.
    echo "No tag found. Just setting some bogus versions ..."
    baseVersionFourTuple=1.0.0.0
    nugetVersion=1.0.0.0-norelease 
    
    print_versions "${baseVersionFourTuple}" "${nugetVersion}"
else
    echo "Found tag '${tag}'. Parsing ..."
    baseVersionFourTuple="$(echo ${tag} | grep --extended-regexp --only-matching '[0-9]+(\.[0-9]+){0,3}' | head -1)"
    nugetVersion="${tag}"

    print_versions "${baseVersionFourTuple}" "${nugetVersion}"
fi

if [ -z "$TRAVIS_BRANCH" ] # The two following cases are only different by gsed vs sed, please edit both at the same time
then 
    echo "Is not on build server. Running replacing version in '$buildPropertiesFile with command 'gsed' if available ..."
    command -v gsed >/dev/null 2>&1 || { echo >&2 "I require command 'gsed' but it's not installed. Please run 'brew install gnu-sed' for local use. We do this because sed on MacOS is crap."; exit 1; }
    
    gsed -i "s/<Version>0.0.0.0<\/Version>/\<Version>$nugetVersion<\/Version>/g" ${buildPropertiesFile}
    gsed -i "s/<AssemblyVersion>0.0.0.0<\/AssemblyVersion>/\<AssemblyVersion>$baseVersionFourTuple<\/AssemblyVersion>/g" ${buildPropertiesFile}
else
    echo "Is on build server. Running replacing version in '$buildPropertiesFile with command 'sed' ..."
    
    sed -i "s/<Version>0.0.0.0<\/Version>/\<Version>$nugetVersion<\/Version>/g" ${buildPropertiesFile}
    sed -i "s/<AssemblyVersion>0.0.0.0<\/AssemblyVersion>/\<AssemblyVersion>$baseVersionFourTuple<\/AssemblyVersion>/g" ${buildPropertiesFile}
fi

echo "Patched build properties file successfully: "
cat ${buildPropertiesFile}