#! /bin/bash

# Location of the script
__ScriptDirectory=

# VsDbg Meta Version. It could be something like 'latest', 'vs2017u1', 'vs2017u5', or a fully specified version.
__VsDbgMetaVersion=

# Install directory of the vsdbg relative to the script.
__InstallLocation=

# When SkipDownloads is set to true, no access to internet is made.
__SkipDownloads=false

# Launches VsDbg after downloading/upgrading.
__LaunchVsDbg=false

# Mode used to launch vsdbg.
__VsDbgMode=

# Removes existing installation of VsDbg in the Install Location.
__RemoveExistingOnUpgrade=false

# Internal, fully specified version of the VsDbg. Computed when the meta version is used.
__VsDbgVersion=

__ExactVsDbgVersionUsed=false

# RuntimeID of dotnet
__RuntimeID=

# Gets the script directory
get_script_directory()
{
    pushd $(dirname "$0") > /dev/null 2>&1
    __ScriptDirectory=$(pwd)
    popd > /dev/null 2>&1
}

print_help()
{
    echo 'GetVsDbg.sh [-ush] -v V [-l L] [-r R] [-d M]'
    echo ''
    echo 'This script downloads and configures vsdbg, the Cross Platform .NET Debugger'
    echo '-u    Deletes the existing installation directory of the debugger before installing the current version.'
    echo '-s    Skips any steps which requires downloading from the internet.'
    echo '-d M  Launches debugger after the script completion. Where M is the mode, "mi" or "vscode"'
    echo '-h    Prints usage information.'
    echo '-v V  Version V can be "latest" or a version number such as 15.0.25930.0'
    echo '-l L  Location L where the debugger should be installed. Can be absolute or relative'
    echo '-r R  Debugger for the RuntimeID will be installed'
}

get_dotnet_runtime_id()
{
    if [[ "$(uname)" == "Darwin" ]]; then
        __RuntimeID=osx.10.11-x64
    else
        __RuntimeID=linux-x64
    fi
}

remap_runtime_id()
{
    legacyLinuxRuntimeIds=( "debian.8-x64" "rhel.7.2-x64" "centos.7-x64" "fedora.23-x64" "opensuse.13.2-x64" "ubuntu.14.04-x64" "ubuntu.16.04-x64" "ubuntu.16.10-x64" "fedora.24-x64" "opensuse.42.1-x64" )
    for id in ${legacyLinuxRuntimeIds[@]}
    do
        if [ "$__RuntimeID" == "$id" ]; then
            __RuntimeID=linux-x64
            return
        fi
    done
}

# Parses and populates the arguments
parse_and_get_arguments()
{
    while getopts "v:l:r:d:suh" opt; do
        case $opt in
            v)
                __VsDbgMetaVersion=$OPTARG;
                ;;
            l)
                __InstallLocation=$OPTARG
                ;;
            u)
                __RemoveExistingOnUpgrade=true
                ;;
            s)
                __SkipDownloads=true
                ;;
            d)
                __LaunchVsDbg=true
                __VsDbgMode=$OPTARG
                ;;
            r)
                __RuntimeID=$OPTARG
                ;;
            h)
                print_help
                exit 1
                ;;
            \?)
                echo "Error: Invalid Option: -$OPTARG"
                print_help
                exit 1;
                ;;
            :)
                echo "Error: Option expected for -$OPTARG"
                print_help
                exit 1
                ;;
        esac
    done
}

# Prints the arguments to stdout for the benefit of the user and does a quick sanity check.
print_and_verify_arguments()
{
    echo "Using arguments"
    echo "    Version                    : '$__VsDbgMetaVersion'"
    echo "    Location                   : '$__InstallLocation'"
    echo "    SkipDownloads              : '$__SkipDownloads'"
    echo "    LaunchVsDbgAfter           : '$__LaunchVsDbg'"
    if [ "$__LaunchVsDbg" = true ]; then
        echo "        VsDbgMode              : '$__VsDbgMode'"
    fi
    echo "    RemoveExistingOnUpgrade    : '$__RemoveExistingOnUpgrade'"

    if [ -z $__VsDbgMetaVersion ]; then
        echo "Error: Version is not an optional parameter"
        exit 1
    fi

    if [[ $__VsDbgMetaVersion = \-* ]]; then
        echo "Error: Version should not start with hyphen"
        exit 1
    fi

    if [[ $__InstallLocation = \-* ]]; then
        echo "Error: Location should not start with hyphen"
        exit 1
    fi

    if [ "$__RemoveExistingOnUpgrade" = true ]; then
        if [ "$__InstallLocation" = "$__ScriptDirectory" ]; then
            echo "Error: Cannot remove the directory which has the running script. InstallLocation: $__InstallLocation, ScriptDirectory: $__ScriptDirectory"
            exit 1
        fi
    fi
}

# Prepares installation directory.
prepare_install_location()
{
    if [ -z $__InstallLocation ]; then
        echo "Error: Install location is not set"
        exit 1
    fi

    if [ -f "$__InstallLocation" ]; then
        echo "Error: Path '$__InstallLocation' points to a regular file and not a directory"
        exit 1
    elif [ ! -d "$__InstallLocation" ]; then
        echo 'Info: Creating install directory'
        mkdir -p $__InstallLocation
        if [ "$?" -ne 0 ]; then
            echo "Error: Unable to create install directory: '$__InstallLocation'"
            exit 1
        fi
    fi
}

# Converts relative location of the installation directory to absolute location.
convert_install_path_to_absolute()
{
    if [ -z $__InstallLocation ]; then
        __InstallLocation=$(pwd)
    else
        if [ ! -d $__InstallLocation ]; then
            prepare_install_location
        fi

        pushd $__InstallLocation > /dev/null 2>&1
        __InstallLocation=$(pwd)
        popd > /dev/null 2>&1
    fi
}

# Computes the VSDBG version
set_vsdbg_version()
{
    # This case statement is done on the lower case version of version_string
    # Add new version constants here
    # 'latest' version may be updated
    # all other version contstants i.e. 'vs2017u1' or 'vs2017u5' may not be updated after they are finalized
    version_string="$(echo $1 | awk '{print tolower($0)}')"
    case $version_string in
        latest)
            __VsDbgVersion=15.1.11011.1
            ;;
        vs2017u1)
            __VsDbgVersion="15.1.10630.1"
            ;;
        vs2017u5)
            __VsDbgVersion=15.1.11011.1
            ;;
        *)
            simpleVersionRegex="^[0-9].*"
            if ! [[ "$1" =~ $simpleVersionRegex ]]; then
                echo "Error: '$1' does not look like a valid version number."
                exit 1
            fi
            __VsDbgVersion=$1
            __ExactVsDbgVersionUsed=true
            ;;
    esac
}

# Removes installation directory if remove option is specified.
process_removal()
{
    if [ "$__RemoveExistingOnUpgrade" = true ]; then

        if [ "$__InstallLocation" = "$HOME" ]; then
            echo "Error: Cannot remove home ( $HOME ) directory."
            exit 1
        fi

        echo "Info: Attempting to remove '$__InstallLocation'"

        if [ -d $__InstallLocation ]; then
            wcOutput=$(lsof $__InstallLocation/vsdbg | wc -l)

            if [ "$wcOutput" -gt 0 ]; then
                echo "Error: vsdbg is being used in location '$__InstallLocation'"
                exit 1
            fi

            rm -rf $__InstallLocation
            if [ "$?" -ne 0 ]; then
                echo "Error: files could not be removed from '$__InstallLocation'"
                exit 1
            fi
        fi
        echo "Info: Removed directory '$__InstallLocation'"
    fi
}

# Checks if the existing copy is the latest version.
check_latest()
{
    __SuccessFile="$__InstallLocation/success.txt"
    if [ -f "$__SuccessFile" ]; then
        __LastInstalled=$(cat "$__SuccessFile")
        echo "Info: Last installed version of vsdbg is '$__LastInstalled'"
        if [ "$__VsDbgVersion" = "$__LastInstalled" ]; then
            __SkipDownloads=true
            echo "Info: VsDbg is upto date"
        else
            process_removal
        fi
    else
        echo "Info: Previous installation at "$__InstallLocation" not found"
    fi
}

download_and_extract()
{
    vsdbgZip="vsdbg-${__RuntimeID}.zip"
    target="$(echo ${__VsDbgVersion} | tr '.' '-')"
    url="$(echo https://vsdebugger.azureedge.net/vsdbg-${target}/${vsdbgZip})"

    echo "Downloading ${url}"
    if ! hash unzip 2>/dev/null; then
        echo "unzip command not found. Install unzip for this script to work."
        exit 1
    fi

    if hash wget 2>/dev/null; then
        wget -q $url -O $vsdbgZip
    elif hash curl 2>/dev/null; then
        curl -s $url -o $vsdbgZip
    else
        echo "Install curl or wget. It is needed to download vsdbg."
        exit 1
    fi

    if [ $? -ne  0 ]; then
        echo "Could not download ${url}"
        exit 1;
    fi

    unzip -o -q $vsdbgZip

    if [ $? -ne  0 ]; then
        echo "Failed to unzip vsdbg"
        exit 1;
    fi

    chmod +x ./vsdbg
    rm $vsdbgZip
}

get_script_directory

if [ -z "$1" ]; then
    print_help
    echo "Error: Missing arguments for GetVsDbg.sh"
    exit 1
else
    parse_and_get_arguments $@
fi

convert_install_path_to_absolute
print_and_verify_arguments
set_vsdbg_version "$__VsDbgMetaVersion"
echo "Info: Using vsdbg version '$__VsDbgVersion'"

check_latest

if [ "$__SkipDownloads" = true ]; then
    echo "Info: Skipping downloads"
else
    prepare_install_location
    pushd $__InstallLocation > /dev/null 2>&1
    if [ "$?" -ne 0 ]; then
        echo "Error: Unable to cd to install directory '$__InstallLocation'"
        exit 1
    fi

    # For the rest of this script we can assume the working directory is the install path

    if [ -z $__RuntimeID ]; then
        get_dotnet_runtime_id
    elif [ "$__ExactVsDbgVersionUsed" == "false" ]; then
        # Remap the old distro-specific runtime ids unless the caller specified an exact build number.
        # We don't do this in the exact build number case so that old builds can be used.
        remap_runtime_id
    fi

    echo "Info: Using Runtime ID '$__RuntimeID'"
    download_and_extract

    echo "$__VsDbgVersion" > success.txt
    popd > /dev/null 2>&1

    echo "Info: Successfully installed vsdbg at '$__InstallLocation'"
fi


if [ "$__LaunchVsDbg" = true ]; then
    # Note: The following echo is a token to indicate the vsdbg is getting launched.
    # If you were to change or remove this echo make the necessary changes in the MIEngine
    echo "Info: Launching vsdbg"
    "$__InstallLocation/vsdbg" "--interpreter=$__VsDbgMode"
    exit $?
fi

exit 0

