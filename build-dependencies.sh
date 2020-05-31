dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Trash the existing Carthage checkouts
rm -rf "$dir/Carthage"

# Builds any dependencies through Carthage
carthage update --platform macos

# Delete the platforms that we don't need
rm -rf "$dir/Carthage/Build/iOS"
