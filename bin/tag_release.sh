build_version=$(defaults read $(pwd)/Info.plist CFBundleShortVersionString)
build_date=$(defaults read $(pwd)/Info.plist CFBundleVersion)

git tag "release-${build_version}.${build_date}"
