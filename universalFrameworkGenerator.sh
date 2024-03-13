
######################################
# Xcode Helpers
######################################

xcode() {
    CMD="xcodebuild"
    echo "Building with command: $CMD $*"
    xcodebuild "$@"
}

xc() {
    # Logs xcodebuild output in realtime
    : "${NSUnbufferedIO:=YES}"
    args=()
    xcode "$@" "${args[@]}"
}

build_combined() {
    local projectName="Segment"
    local scheme="$1"
    local module_name="$2"
    local os="$3"
    local simulator="$4"
    local scope_suffix="$5"
    local version_suffix="$6"
    local config="$CONFIGURATION"
    local os_name="ios"

    # Derive build paths
    local build_products_path="DerivedData/$projectName/Build/Products"
    local product_name="$module_name.framework"
    local os_path="$build_products_path/$config-$os$scope_suffix/$product_name"
    local simulator_path="$build_products_path/$config-$simulator$scope_suffix/$product_name"
    local out_path="build/$os_name$scope_suffix$version_suffix"
    local xcframework_path="$out_path/$module_name.xcframework"

    # Build for each platform
    xc -scheme "$scheme" -configuration "$config" -sdk "$os" build -UseModernBuildSystem=NO
    xc -scheme "$scheme" -configuration "$config" -sdk "$simulator" build ONLY_ACTIVE_ARCH=NO -UseModernBuildSystem=NO

    # Create the xcframework
    rm -rf "$xcframework_path"
    xcodebuild -create-xcframework -allow-internal-distribution -output "$xcframework_path" \
        -framework "$os_path" -framework "$simulator_path"
}

######################################
# Variables
######################################

COMMAND="$1"

# Use Debug config if command ends with -debug, otherwise default to Release
case "$COMMAND" in
    *-debug)
        COMMAND="${COMMAND%-debug}"
        CONFIGURATION="Release"
        ;;
esac
export CONFIGURATION=${CONFIGURATION:-Release}

######################################
# Commands
######################################

case "$COMMAND" in

    ######################################
    # Building
    ######################################

    "Segment")
        build_combined Segment Segment iphoneos iphonesimulator
        exit 0
        ;;
        
    "xcframework")
        # Build all of the requested frameworks

        # Assemble them into xcframeworks
        rm -rf build/*.xcframework
        find DerivedData/Segment/Build/Products -name 'Segment.framework' \
            | sed 's/.*/-framework &/' \
            | xargs xcodebuild -create-xcframework -allow-internal-distribution -output build/Segment.xcframework
        exit 0
        ;;
esac
