if [[ $TRAVIS_PULL_REQUEST != false ]];then
	echo "This is a pull-request build, skipping pack and deploy."
elif [[ $TRAVIS_BRANCH == "beta" ]] || [[ $TRAVIS_BRANCH == "master" ]];then
	echo "Is on beta or master branch, packing and deploying Nuget package ..."
	dotnet pack
	dotnet nuget push signature-api-client.nuspec --api-key $NUGET_API_KEY --source https://api.nuget.org/v3/index.json
else
	echo "Is not on beta or master branch, skipping pack and deploy."
fi