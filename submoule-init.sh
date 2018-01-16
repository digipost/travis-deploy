# Handle git submodules manually because we want https instead of ssh
sed -i 's/git@github.com:/https:\/\/github.com\//' .gitmodules
git submodule update --init --recursive