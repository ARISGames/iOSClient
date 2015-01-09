# Makefile for the ARIS Client
#
# Timestamps builds & Deploys to the prod servers. (Make sure they are in your ssh config)
#
# Some output is supressed, just remove the @ or dev/null redirects if troubleshooting.
#
OK_COLOR=\033[0;32m
INFO_COLOR=\033[1;36m
CLEAR=\033[m\017

help:
	@echo "Aris Client"
	@echo ""
	@echo "Targets:"
	@echo "   simulate: build and run ios-sim launcher "
	@echo "       copy: push ipas to aris"
	@echo "  timestamp: rename dist/ARIS.ipa to version"
	@echo "             add POSTFIX=xyz for multiple versions on the same date."
	@echo "             ie: make timestamp POSTFIX=2"
	@echo "      clean: remove all created ipa/plist from dist."
	@echo ""
	@echo "make [all|copy|timestamp|clean]"

COPY_FILES=dist/ARIS-*.ipa dist/ARIS-*.plist
COPY_DESTINATION=/var/www/html/clients/

copy:
	@echo "Copying to server 1."
	@scp $(COPY_FILES) aris-prod1:$(COPY_DESTINATION)
	@echo "   $(OK_COLOR)(Done)$(CLEAR)"
	@echo "Copying to server 2."
	@scp $(COPY_FILES) aris-prod2:$(COPY_DESTINATION)
	@echo "   $(OK_COLOR)(Done)$(CLEAR)"
	@echo "Copying to server 3."
	@scp $(COPY_FILES) aris-prod3:$(COPY_DESTINATION)
	@echo "   $(OK_COLOR)(Done)$(CLEAR)"

timestamp:
	@echo "Generating timestamped .ipa/.plist"
	@bin/timestamp_build.sh $(POSTFIX)
	@echo "   $(OK_COLOR)(Done)$(CLEAR)"

clean:
	@echo "Removing dist/ARIS-*.plist/ipa"
	@rm dist/ARIS-*.plist dist/ARIS-*.ipa

ARIS_OUTPUT_DIR=./build

simbuild:
	xcodebuild build -workspace ARIS.xcworkspace -scheme ARIS -sdk iphonesimulator8.1 -destination platform='iOS Simulator',OS='8.1',name='aris 6 dev two' CONFIGURATION_BUILD_DIR=$(ARIS_OUTPUT_DIR)

phonebuild:
	xcodebuild build -workspace ARIS.xcworkspace -scheme ARIS -sdk iphoneos8.1 -destination platform='iOS',name='iPod touch 8'

simrun:
	# $BUILD_PRODUCTS_DIR
	ios-sim launch $(ARIS_OUTPUT_DIR)/ARIS.app --devicetypeid "com.apple.CoreSimulator.SimDeviceType.iPhone-6, 8.1" --exit

simulate: simbuild simrun

all: timestamp copy clean
