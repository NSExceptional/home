# Managing Cydia repos

rphelp() {
    echo "Repo commands:"
    echo "  rpdepict deb [depiction-path [changelog-path]]"
    echo "                  Generate depiction files and output fields"
    echo ""
    echo "  rpcpdeb deb     Copy a deb to the repo"
    echo "  rpcpdebs        Copy all debs in ./ to the repo"
    echo "  rpbuild         Rebuild the repo's package list"
    echo "  rppush          Push the repo"
    echo "  myrepo          List or change repo directory"
}

rpcpdeb() {
    if [[ ! -d "$MY_REPO" ]]; then
        echo "Choose a repo with the myrepo command."
    elif [[ ! -e "$1" ]]; then
        echo "Error: file '$1' does not exist"
    else
        echo Copying `basename "$1"` to `myrepo`/debs
        cp "$1" `myrepo`/debs
    fi
}

rpcpdebs() {
    if [[ ! -d "$MY_REPO" ]]; then
        echo "Choose a repo with the myrepo command."
    else
        echo Copying the following debs to `myrepo`/debs:
        for deb in `find . -name "*.deb"`; do
            echo "    "`basename "$deb"`
            cp "$deb" `myrepo`/debs
        done
    fi
}

rpbuild() {
    if [[ ! -d "$MY_REPO" ]]; then
        echo "Choose a repo with the myrepo command."
    else
        echo "Rebuilding repo..."
        cd `myrepo`
        rm -rf Packages.bz2
        dpkg-scanpackages -m ./debs > Packages
        bzip2 -k Packages
        git diff Packages
        git status
        cd -
        echo "Done."
    fi
}

rppush() {
    local message="Update packages"
    if [[ "$1" ]]; then
        message="$1"
    fi

    if [[ ! -d "$MY_REPO" ]]; then
        echo "Choose a repo with the myrepo command."
    else
        cd `myrepo`
        git status
        git add -A;
        git commit -m "$message"
        git push
        cd -
    fi
}

myrepo() {
    if [[ $1 ]]; then
        if [[ $2 == "-f" ]]; then
            export MY_REPO="$1"
        else
            export MY_REPO="/Users/tanner/Repos/$1"
        fi
        echo $MY_REPO > ~/.myrepo
    else
        echo $MY_REPO
    fi
}

_loadmyrepo() {
    touch ~/.myrepo
    local repo=`cat ~/.myrepo`
    if [[ "$repo" ]]; then
        export MY_REPO="$repo"
    fi
}
_loadmyrepo

rpdepict() {
    local deb="$1"
    local depictionPath="$2"
    local changelogPath="$3"
    # alias jo="jo -p"

    local usage="Usage: rpdepict package.deb [depiction-file [changelog-file]]"

    if [[ ! -d "$MY_REPO" ]]; then
        echo "Choose a repo with the myrepo command."
        echo $usage
    elif [[ ! "$deb" ]]; then
        echo "Missing argument: deb"
        echo $usage
    elif [[ ! -e "$deb" ]]; then
        echo "Error: file '$deb' does not exist"
    elif [[ "$depictionPath" ]] && [[ ! -e "$depictionPath" ]]; then
        echo "Error: file '$depictionPath' does not exist"
    elif [[ "$changelogPath" ]] && [[ ! -e "$changelogPath" ]]; then
        echo "Error: file '$changelogPath' does not exist"
    else
        local name=`dpkg-deb -f "$deb" Name`
        local package=`dpkg-deb -f "$deb" Package`
        local version=`dpkg-deb -f "$deb" Version`
        local predeps=`dpkg-deb -f "$deb" Pre-Depends`
        local depends=`dpkg-deb -f "$deb" Depends`
        predeps=`echo "$predeps" | sed -E 's/firmware \(([<>=0-9\. ]+)\)/iOS \1/'`

        local depiction
        local changelog
        local sileoDepict
        local sileoDepictCls=DepictionLabelView

        # Grab depiction
        if [[ "$depictionPath" ]]; then
            depiction=`cat $depictionPath`
            sileoDepict="text=$depiction"

            # Check for Sileo markdown depiction
            if [[ -e "$depictionPath".md ]]; then
                sileoDepictCls="DepictionMarkdownView"
                sileoDepict="markdown="`cat "$depictionPath".md`
            fi
        else
            # Use package description if depiction not provided
            depiction=`dpkg-deb -f "$deb" Description`
            sileoDepict="text=$depiction"
        fi

        # Grab changelog
        if [[ "$changelogPath" ]]; then
            changelog=`cat $changelogPath`
        fi

        echo "Depiction: https://`basename $(myrepo)`/package.html?package=$package"
        echo "SileoDepiction: https://`basename $(myrepo)`/depictions/$package.sileo.json"

        # Emit plain JSON depiction for my HTML depictions
        jo package="$package" name="$name" \
            depiction="$depiction" changelog="$changelog" \
            depends="$depends" pre-depends="$predeps" \
        > `myrepo`/depictions/"$package.json"
        
        # Generate Sileo depiction tab, either with markdown or without
        local compatability
        local dependencies
        if [[ "$predeps" ]]; then
            compatability="views[]=$(jo class=DepictionTableTextView title=Compatability text="$predeps")"
        fi
        if [[ "$depends" ]]; then
            dependencies="views[]=$(jo class=DepictionTableTextView title=Dependencies text="$depends")"
        fi
        local depictionTab=$(jo \
            tabname=Description class=DepictionStackView \
            views[]="$(jo class=$sileoDepictCls "$sileoDepict")" \
            views[]="$(jo class=DepictionSeparatorView)" \
            views[]="$(jo class=DepictionTableTextView title=Version text=$version)" \
            "$compatability" "$dependencies" \
        )

        # Generate sileo tabs list of [depiction, changelog?]
        local tabs
        if [[ "$changelog" ]]; then
            tabs=$(jo -a "$depictionTab" \
                $(jo tabname=Changelog class=DepictionStackView \
                    views[]="$(jo class=DepictionLabelView text="$changelog")" \
                )
            )
        else
            tabs=`jo -a "$depictionTab"`
        fi

        # Finally emit sileo depiction
        jo class=DepictionTabView minVersion="0.1" tabs="$tabs" > `myrepo`/depictions/"$package.sileo.json"
    fi
}
