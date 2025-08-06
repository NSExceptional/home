### Theos and jailbreak development related utilities ###

# Cycript command wrapper
cy() {
    local init=/Users/tanner/.cyinit.cy
    touch $init
    cycript -p $1 $init > /dev/null
    cycript -p $1
}

undeb() {
    local deb=$1
    if [[ ! -e $deb ]]; then
        echo File does not exist.
        return
    fi
    
    ar -x $deb
    rm debian-binary
    rm control.tar*
    tar -xf data.tar*
    rm data.tar*
}

undebdylib() {
    local deb=$1
    if [[ ! -e $deb ]]; then
        echo File does not exist.
        return
    fi

    undeb $deb
    mv Library/MobileSubstrate/DynamicLibraries/* .
    rm -rf Library
}

alias make="cls; make"

# Alias for make package that uses Tweak.m (alternate uses .xmi)
#alias tmake="clear; clear; cp -v Tweak.m Tweak.xm; make package"
alias tmake="make package"
alias tmakef="make clean-packages; make package FINALPACKAGE=1 DEBUG=0"
alias mdo="make package install"
alias mcp="echo rm -rf packages/; rm -rf packages/"
alias mcl="/usr/bin/make clean; mcp"
alias idm="ideviceimagemounter"
# Alias for make install that cleans the project
alias tinstall="make install"
# Opens the THEOS include folder
alias tinclude="open $THEOS/include"
alias archs="lipo -archs"
alias thin="lipo -thin arm64"

alias iprcp="theoscp .profile ~/tweaks/profile.sh"
alias ipr="open -a Code ~/tweaks/profile.sh"
alias iprcpto="theoscpto ~/tweaks/profile.sh .profile"

loads() {
    otool -l $1 | grep "name /"
}

# idm() {
#     local path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/11.1/DeveloperDiskImage.dmg
#     sudo ideviceimagemounter $path $path.signature
# }

# Class dump helper
cdmp() {
    class-dump -FH $1
}

# Copy file from device
theoscp() {
    scp -P `theospt` root@$THEOS_DEVICE_IP:$1 $2
}
# Copy directory from device
theoscpr() {
    scp -P `theospt` -r root@$THEOS_DEVICE_IP:$1 $2
}
# Copy file to device
theoscpto() {
    dest=${@:$#} # last parameter 
    args="${*%${!#}}" # all except last
    # echo Files: $args
    # echo Destination: $dest
    scp -P `theospt` $args root@$THEOS_DEVICE_IP:"$dest"
}
# Copy directory to device
theoscprto() {
    dest=${@:$#} # last parameter 
    args="${*%${!#}}" # all except last
    scp -P `theospt` -r $args root@$THEOS_DEVICE_IP:"$dest"
}

# SSH into my device
sshme() {
    local flags="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=ERROR"
    ssh root@`theosip` -p `theospt` $flags $1
}

# alias issh="theosip Tanners-iPhone.local"
alias sshse="theosip iphonese.local; theospt 22"
alias sshx="theosip tanners-iphone-mini.local; theospt 22"
alias sshxx="theosip tanners-iphone-x.local; theospt 22"
alias sshusb="theosip localhost; theospt 2222"

sshfsme() {
    
    local name="iPhone"
    if [[ "$1" ]]; then
        name="$1"
    fi
    
    local icon=~/bash/SidebariPhoneFaceID.icns
    # local options=`-o volname=\"$name\" -o volicon=$icon` # -o noappledouble -o noapplexattr"
    sshfs -p `theospt` root@`theosip`:/ "/Volumes/$name" -o volname="$name" -o volicon=$icon
}

theoswho() {
    echo "root@`theosip` -p `theospt`"
}

theospt() {
    if [[ $1 ]]; then
        export THEOS_SSH_PORT=$1
        export THEOS_DEVICE_PORT=$1
        echo $1 > ~/.theospt
    else
        echo $THEOS_SSH_PORT
    fi
}

# Print or set the current ssh device IP. Writes it to a file for easy access in new windows.
# Usage: theosip [address]
theosip() {
    if [[ $1 ]]; then
        export THEOS_DEVICE_IP=$1
        export IPHONEIP=$1
        echo $1 > ~/.theosip
    else
        echo $THEOS_DEVICE_IP
    fi
}
_loadtheosip() {
    touch ~/.theosip
    touch ~/.theospt

    local ip=`cat ~/.theosip`
    if [[ "$ip" ]]; then
        export THEOS_DEVICE_IP=$ip
        export IPHONEIP=$ip
    fi
    local port=`cat ~/.theospt`
    if [[ "$port" ]]; then
        export THEOS_SSH_PORT=$port
        export THEOS_DEVICE_PORT=$port
    fi  
}
_loadtheosip

deb() {
    if [[ $1 ]]; then
        sshme "cd /var/mobile/debs; ls *$1*"
    else
        sshme "cd /var/mobile/debs; ls"
    fi
}

cpdeb() {
    for deb in `deb $1`; do
        theoscp /var/mobile/debs/$deb .
    done
}

# Creates a virtual network interface for my connected iPhone
sniff() {
    if [[ $# -eq 1 ]]; then
        if [[ $1 == "stop" ]]; then
            rvictl -x $my_6s_id
        else
            echo "Invalid option \'$1\'"
        fi
    else
        rvictl -x $my_6s_id
    fi
}

# Used to configure existing fresh projects
tnew() {
    # Is tweak dir?
    if [[ ! -e Tweak.xm ]] && [[ ! -e Tweak.x ]]; then
        echo "Tweak file missing"
        return
    fi
    
    # Variables
    TWEAKS=~/Repos/Tweaks
    name=`cat Makefile | grep TWEAK_NAME | awk '{ print $3 }'`
    process=`cat Makefile | grep install.exec | awk '{ print substr($4, 1, length($4)-1) }'`
    today=`date +'%Y-%m-%d'`
    year=`date +'%Y'`
    if [[ ! $process ]]; then
        process=`cat Makefile | grep INSTALL_TARGET_PROCESSES | awk '{ print substr($3, 1, length($3)) }'`
    fi

    echo "Tweak name: $name"

    # Copy files
    cp $TWEAKS/Interfaces_template.h ./Interfaces.h
    cp $TWEAKS/.gitignore ./.gitignore
    cp $TWEAKS/Makefile_template Makefile
    sed -i .bak "s/__TWEAK_NAME__/$name/g" Makefile
    if [[ $process ]]; then
        sed -i .bak "s/__PROCESS__/$process/g" Makefile
    else
        ghead -n -2 Makefile | sponge Makefile
    fi
    
    # Make Tweak.xm
    trash Tweak.x Tweak.xm > /dev/null 2>&1
    printf "//\\n" > Tweak.xm
    printf "//  Tweak.xm\\n" >> Tweak.xm
    printf "//  $name\\n" >> Tweak.xm
    printf "//\\n" >> Tweak.xm
    printf "//  Created by Tanner Bennett on $today\\n" >> Tweak.xm
    printf "//  Copyright © $year Tanner Bennett. All rights reserved.\\n" >> Tweak.xm
    printf "//\\n\\n" >> Tweak.xm
    printf "#import \"Interfaces.h\"\\n\\n\\n" >> Tweak.xm

    # Make Interfaces.h
    printf "//\\n" > Interfaces.h
    printf "//  Interfaces.h\\n" >> Interfaces.h
    printf "//  $name\\n" >> Interfaces.h
    printf "//\\n" >> Interfaces.h
    printf "//  Created by Tanner Bennett on $today\\n" >> Interfaces.h
    printf "//  Copyright © $year Tanner Bennett. All rights reserved.\\n" >> Interfaces.h
    printf "//\\n\\n" >> Interfaces.h
    cat $TWEAKS/Interfaces_template.h >> Interfaces.h
}

# Takes old bundle ID, new bundle ID, and relative path to bundle with Info.plist
_setbundleid() {
    local old=$1
    local bundleid=$2
    local bundle="$3"

    local orig=`defaults read "$bundle/Info.plist" CFBundleIdentifier`
    local modified=`echo $orig | sed s/$old/$bundleid/g`
    echo "$bundle/Info.plist -> [CFBundleIdentifier: \"$modified\"]"
    defaults write "$bundle/Info.plist" CFBundleIdentifier $modified
}

# Code sign an IPA
# Arguments: [-e entitlements -i identity -b newBundleID] <path to IPA>
csipa() {
    # Temp dir
    if [[ ! -d /tmp/csipa ]]; then
        mkdir /tmp/csipa
    fi

    local ipaPath=
    local entitlements=
    local identity="iPhone Developer: Tanner Bennett (JWB6AQ4N38)"
    local bundleid=

    # Get arguments
    while test $# -gt 0; do
        case "$1" in
            -h)
                echo "Usage: csipa [-e entitlements.xml] [-i identity] <path to IPA>"
                echo
                return
            ;;
            -b)
                shift
                bundleid=$1
                echo "New bundle ID: $bundleid"
                shift
            ;;
            -e)
                shift
                entitlements="$1"
                if [[ -e $entitlements ]]; then
                    echo "Using entitlements: $entitlements"
                    entitlements="--entitlements $1"
                else
                    echo "Entitlements: not a regular file"
                    echo
                    return
                fi
                shift
            ;;
            -i)
                shift
                identity="$1"
                echo "Using PP identity pattern: $identity"
                shift
            ;;
            *)
                ipaPath="`abs "$1"`"
                if [[ ! -e $ipaPath ]]; then
                    echo "Must specify a valid path to an IPA"
                    echo
                    return
                fi
                shift
            ;;
        esac
    done

    if [[ $ipaPath ]]; then
        local filename=`basename $ipaPath .ipa`
        local outdir="/private/tmp/csipa/$filename"

        # Make working directory, unzip
        mkdir "$outdir"
        if unzip "$ipaPath" -d "$outdir" &>/dev/null
        then
            # Get path to .app
            local appdir=`echo "$outdir/Payload"/*.app`
            if [[ ! -d "$appdir" ]]; then
                echo "Not a valid IPA"
                echo; rm -rf $outdir; return
            fi
            
            # Get path to binary
            local binary="$appdir"/`defaults read "$appdir/Info.plist" CFBundleExecutable`
            if [[ ! -e $binary ]]; then
                echo "Error: binary not found: $binary"
                echo; rm -rf $outdir; return
            fi

            # Change bundle ID for Info.plist and *.appex/Info.plist
            if [[ $bundleid ]]; then
                # Get original bundle ID
                local origbid=`defaults read "$appdir/Info.plist" CFBundleIdentifier`

                _setbundleid $origbid $bundleid "$appdir"
                for appex in `find "$appdir" -name "*.appex"`; do
                    _setbundleid $origbid $bundleid $appex
                done
            fi

            # Sign frameworks and other libraries
            find "$appdir" \( -name "*.framework" -or -name "*.dylib" -or -name "*.appex" \) -not -path "*.framework/*" -print0 | xargs -0 codesign -fs "$identity" $entitlements
            if [[ $? != 0 ]]; then
                error "Failed to sign fraomeworks or dylibs"
            fi

            # Sign .app (signs the binary)
            codesign -fs "$identity" $entitlements "$appdir"
            if [[ $? != 0 ]]; then
                error "Failed to sign $app"
            fi
            
            # Backup old IPA
            echo Backup: "$filename.ipa -> $filename.ipa.bak"
            mv "$ipaPath" "$ipaPath.bak"
            # Re-pack new IPA
            echo "Re-packing IPA..."
            cd "$outdir"
            zip -qr "$ipaPath" Payload/
            cd - > /dev/null
            rm -rf $outdir
            echo "Done."
        else
            echo "Error unzipping IPA. Try it yourself:"
            echo "unzip -t \"$ipaPath\""
            echo; rm -rf $outdir; return
        fi
    fi
}

# Add load commands to *.app/MyApp for dylibs in *.app/Frameworks
# Usage: ipadlt <binary name>
ipadlt() {
    local binary="$1"
    local SUBSTRATE_ORIG_PATH="/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate"
    local SUBSTRATE_ALT_ORIG_PATH="/usr/lib/libsubstrate.dylib"
    local SUBSTRATE_NEW_PATH="@rpath/CydiaSubstrate.framework/CydiaSubstrate"

    # Add new @rpath for Frameworks/
    # Doing this allows us to use @rpath/Tweak.dylib instead of
    # @executable_path/Frameworks/Tweak.dylib in the loop below
    install_name_tool -add_rpath "@executable_path/Frameworks" "$binary"

    # dy = Foo.dylib
    for dy in `/bin/ls Frameworks | grep .dylib`; do
        # If tweak uses Substrate, use @rpath/CydiaSubstrate instead of /Library/Frameworks/CydiaSubstrate…
        install_name_tool -change $SUBSTRATE_ORIG_PATH $SUBSTRATE_NEW_PATH "Frameworks/$dy"
        install_name_tool -change $SUBSTRATE_ALT_ORIG_PATH $SUBSTRATE_NEW_PATH "Frameworks/$dy"

        # Make app load tweak
        optool install -c load -p "@rpath/$dy" -t "$binary"
    done
}

# Add load commands to Snapchat.app/Snapchat for dylibs in Snapchat.app/Frameworks.
# Usage: ipadlt <binary path>
scdli() {
    local binary="$1"
    local frameworks=`dirname "$binary"`/Frameworks
    local SUBSTRATE_ORIG_PATH="/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate"
    local SUBSTRATE_ALT1_ORIG_PATH="/usr/lib/libsubstrate.dylib"
    local SUBSTRATE_ALT2_ORIG_PATH="@rpath/CydiaSubstrate.framework/CydiaSubstrate"
    local SUBSTRATE_NEW_PATH="@executable_path/Photon/CSub"

    # Add new @rpath for Frameworks/
    # Doing this allows us to use @rpath/Tweak.dylib instead of
    # @executable_path/Frameworks/Tweak.dylib in the loop below
    install_name_tool -add_rpath "@executable_path/Frameworks" "$binary"

    # dy = Foo.dylib
    for dy in `/bin/ls "$frameworks" | grep .dylib`; do
        # If tweak uses Substrate, use @executable_path/Photon/CSub instead of /Library/Frameworks/CydiaSubstrate…
        install_name_tool -change $SUBSTRATE_ORIG_PATH $SUBSTRATE_NEW_PATH "$frameworks/$dy"
        install_name_tool -change $SUBSTRATE_ALT1_ORIG_PATH $SUBSTRATE_NEW_PATH "$frameworks/$dy"
        install_name_tool -change $SUBSTRATE_ALT2_ORIG_PATH $SUBSTRATE_NEW_PATH "$frameworks/$dy"

        # Make app load tweak
        optool install -c load -p "@rpath/$dy" -t "$binary"
    done
}

# New instance creator (tweak)
nict() {
    local name="$1"
    local lowercase=`echo $name | awk '{ print tolower($1); }'`

    if [[ $name ]]; then
        cd ~/Repos/Tweaks
        nic.pl -t iphone/tweak -n $name
        mv $lowercase $name
        cd $name
        tnew
        # May not always exist
        /bin/rm Makefile.bak > /dev/null
        open .
    else
        echo "Missing tweak name."
    fi
}

# Rename tweak
# rntk() {
#     local name="$1"
#     if [[ ! $name ]]; then fi
# }

export XCODE_PLATFORMS_PATH="/Applications/Xcode.app/Contents/Developer/Platforms/"
export XCODE_IOS_SDK_PATH=$XCODE_PLATFORMS_PATH"iPhoneOS.platform/Developer/SDKs/"
export LOCAL_IOS_SDK_PATH="/Users/tantan/Library/Developer/Xcode/Platforms/"
export IOS_SDK_10_0=XCODE_IOS_SDK_PATH"iPhoneOS.sdk"
export IOS_SDK_9_0="iPhoneOS9.0.sdk"
export IOS_SDK_8_4="iPhoneOS8.4.sdk"

export SDK_FRAMEWORKS="/System/Library/Frameworks/"
export SDK_PRIVATE_FRAMEWORKS="/System/Library/PrivateFrameworks/"
export HEADERS="Headers/"
export SIMRUNTIME_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/"

lnsdks() {
    local localsdks=/Users/tanner/Library/Developer/Xcode/Platforms
    local xcodesdks=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs
    for folder in `ls $localsdks`; do
        ln -s $localsdks/$folder $xcodesdks
        echo "Linked $folder"
    done
}

jail() {
    mv "$1" ~/Repos/Tweaks/Apps/lib
}

