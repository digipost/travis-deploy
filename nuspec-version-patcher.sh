#Find current assembly version
# 1: Fetch version line from AssemblyInfo.cs.
# 2: Grep with regex to retrieve the assembly version number
# 3: Add -beta suffix if applicable
# 4: Patch the .nuspec file.
nuspecFile=$1

function stop_if_no_assembly_version_found {
	if [[ ${#lineWithVersionNumber} -eq "0" ]];then
		echo "Did not find assembly version with version patcher. Please check that patcher is installed correctly and that it can find the assembly version files. Exiting!" >&2 #Echo and send to stderr
		exit 1 # terminate and indicate error
	fi
}

echo "Took nuspec file name'${nuspecFile}' as input. Starting patching of version ..."

lineWithVersionNumber=$(cat SolutionItems/AssemblyInfo.cs | grep AssemblyVersion)

echo "Fetched line with current base version from AssemblyInfo.cs: '" + $lineWithVersionNumber + "'";

if [[ ${TRAVIS_BRANCH} == "master" ]];then
 	fullAssemblyVersion=$(echo $lineWithVersionNumber | egrep -o '([0-9].){3}([0-9])')  # Ex. 4.0.0.0 (Keep all parts if on master)
 	stop_if_no_assembly_version_found
	
	echo "Is on master branch and found full version number (Major.Minor.Patch.Build) to be ${fullAssemblyVersion}."
elif [[ ${TRAVIS_BRANCH} == "beta" ]];then
 	assemblyVersion=$(echo $lineWithVersionNumber | egrep -o '([0-9].){2}([0-9])') 		# Ex. 4.0.0   (Remove build number and replace it with travis build number)
	stop_if_no_assembly_version_found
	fullAssemblyVersion="${assemblyVersion}.${TRAVIS_BUILD_NUMBER}-beta"
	
	echo "Is on beta branch and parsed version without build number (Major.Minor.Patch) to be ${assemblyVersion}.\
 Appended TRAVIS_BUILD_NUMBER=$TRAVIS_BUILD_NUMBER and result is $fullAssemblyVersion. "
else
	echo "Is not on beta or master branch. No need to patch .nuspec file!"
fi

#Patch assembly version number in .nuspec
sed -i.originalfilebackup "s/VERSION_PLACEHOLDER/${fullAssemblyVersion}/g" $nuspecFile
