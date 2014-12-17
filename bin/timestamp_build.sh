# Place ARIS.ipa in dist and run from root of project.

expected_date=$(date "+%Y%m%d")
build_version=$(defaults read $(pwd)/Info.plist CFBundleShortVersionString)
build_date=$(defaults read $(pwd)/Info.plist CFBundleVersion)

# compare and warn

build_name=ARIS-$build_version.$build_date
cp dist/ARIS.ipa dist/$build_name.ipa
cat dist/ARIS.plist.template |\
	sed "s/{{build_ipa}}/$build_name.ipa/g" |\
	sed "s/{{build_version}}/$build_version/g" \
	> dist/$build_name.plist
