# Place ARIS.ipa in dist and run from root of project.
# Optional argument attaches postfix to build name.

expected_date=$(date "+%Y%m%d")
build_version=$(defaults read $(pwd)/Info.plist CFBundleShortVersionString)
build_date=$(defaults read $(pwd)/Info.plist CFBundleVersion)

# Compare and warn
if [ $expected_date != $build_date ]; then
	echo "Aborting! Build version set to $build_date, today is $expected_date. Please fix and recompile."
	exit 1
fi

# Add postfix
build_name=ARIS-$build_version.$build_date
if [[ $# -eq 1 ]]; then
	build_name=$build_name.$1
fi

# Template!
cp dist/ARIS.ipa dist/$build_name.ipa
cat dist/ARIS.plist.template |\
	sed "s/{{build_ipa}}/$build_name.ipa/g" |\
	sed "s/{{build_version}}/$build_version/g" \
	> dist/$build_name.plist

echo "Generated dist/$build_name.ipa and dist/$build_name.plist"
