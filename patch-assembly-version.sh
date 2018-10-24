#!/usr/bin/env bash

buildPropertiesFile=$1
currentBranch=$2
buildNumber=$3

echo "Starting to patch version in '${buildPropertiesFile}'. Is on branch '${currentBranch}' and build number is '${buildNumber}'"

function stop_if_no_assembly_version_found {
	if [[ ${#lineWithVersionNumber} -eq "0" ]];then
		echo "Did not find assembly version with version patcher. Please check that patcher is installed correctly and that it can find the assembly version files. Exiting!" >&2 #Echo and send to stderr
		exit 1 # terminate and indicate error
	fi
}

lineWithVersionNumber=$(cat ${buildPropertiesFile} | grep Version)

echo "Fetched line with current base version from AssemblyInfo.cs: ' ${lineWithVersionNumber} '";

if [[ ${currentBranch} == "master" ]];then
 	fullAssemblyVersion=$(echo ${lineWithVersionNumber} | egrep -o '([0-9].){3}([0-9])')  # Ex. 4.0.0.0 (Keep all parts if on master)
 	stop_if_no_assembly_version_found
	
	echo "Parsed full version number (Major.Minor.Patch.Build) to be ${fullAssemblyVersion}."
elif [[ ${currentBranch} == "beta" ]];then
 	assemblyVersion=$(echo ${lineWithVersionNumber} | egrep -o '([0-9].){2}([0-9])') 		# Ex. 4.0.0   (Remove build number and replace it with input build number)
	stop_if_no_assembly_version_found
	fullAssemblyVersion="${assemblyVersion}.${buildNumber}-beta"
	
	echo "Parsed version without build number (Major.Minor.Patch) to be '${assemblyVersion}'. Appended build number=$buildNumber and result is '$fullAssemblyVersion'. "
	
else
	echo "Is not on beta or master branch. No need to patch $buildPropertiesFile!"
	exit 0
fi

sed -i.backup "s/$assemblyVersion/$fullAssemblyVersion/g" $buildPropertiesFile

echo "Version patched successfully."