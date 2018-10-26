#!/usr/bin/env bash

buildPropertiesFile=$1
currentBranch=$2
buildNumber=$3

echo "Starting to patch version in '${buildPropertiesFile}'. Is on branch '${currentBranch}' and build number is '${buildNumber}' ..."

function stop_if_no_assembly_version_found {
    version=$1

	if [[ ${version} -eq "0" ]];then
		echo "Did not find assembly version with version patcher. Please check that patcher is installed correctly and that it can find the assembly version files. Exiting!" >&2 #Echo and send to stderr
		exit 1 # terminate and indicate error
	fi
}

function print_versions {
    baseVersion=$1
    assemblyVersion=$2
    nugetVersion=$3

    echo "======================================================================"
	echo " Base version before patching: $baseVersion"
	echo " Assembly Version/.dll (AssemblyVersion): $assemblyVersion"
	echo " Nuget version (Version): $nugetVersion"
	echo "======================================================================"
}

lineWithVersionNumber=$(cat ${buildPropertiesFile} | grep -m1 Version)

echo "Fetched line with current base version from AssemblyInfo.cs: ' ${lineWithVersionNumber} '";

baseVersionThreeTuple=$(echo ${lineWithVersionNumber} | egrep -o '([0-9].){2}([0-9])') 		# Ex. 4.0.0   (Remove build number and replace it with input build number)
baseVersionFourTuple=$(echo ${lineWithVersionNumber} | egrep -o '([0-9].){3}([0-9])')       # Ex. 4.0.0.0 (Keep all parts if on master)

if [[ ${currentBranch} == "master" ]];then
 	assemblyVersion=${baseVersionFourTuple} 
 	nugetVersion=${assemblyVersion}
 	
# 	stop_if_no_assembly_version_found ${assemblyVersion}
 	
 	print_versions ${baseVersionFourTuple} ${assemblyVersion} ${nugetVersion}
 	
	
	echo "Parsed full version number (Major.Minor.Patch.Build) to be ${assemblyVersion}."
elif [[ ${currentBranch} == "beta" ]];then
	
	assemblyVersion="${baseVersionThreeTuple}.${buildNumber}"
	nugetVersion="${baseVersionThreeTuple}.${buildNumber}-beta"
	
#	stop_if_no_assembly_version_found $assemblyVersion

 	print_versions ${baseVersionThreeTuple} ${assemblyVersion} ${nugetVersion}

else
	echo "Is not on beta or master branch. No need to patch $buildPropertiesFile!"
	exit 0
fi

sed -i.backup "s/\<Version\>$baseVersionFourTuple\<\/Version\>/\<Version\>$nugetVersion\<\/Version\>/g" ${buildPropertiesFile}
sed -i.backup "s/\<AssemblyVersion\>$baseVersionFourTuple\<\/AssemblyVersion\>/\<AssemblyVersion\>$assemblyVersion\<\/AssemblyVersion\>/g" ${buildPropertiesFile}
rm -r *.backup

echo "Version patched successfully."

echo " Patched build properties file: "

cat $buildPropertiesFile

