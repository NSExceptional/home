# A function that will enumerate all files in the current folder,
# looking for files with names that end in '_o' or '_c' before the extension,
# and deletes them. If another file with the same UUID prefix as the given
# file exists, with no other suffix before the extension.

dr_remove_c_files() {
    for file in *; do
        if [[ -f $file ]]; then
        
            # If the filename contains spaces
            if [[ $file == *" "* ]]; then
                # Check if the filename ends in " 1.ext" and if another file
                # without the trailing " 1" exists
                if [[ $file == *" 1."* ]]; then
                    local file_name_no_ext=${file%.*}
                    local file_ext=${file##*.}
                    local file_no_ext=${file_name_no_ext% *}
                    if ls $file_no_ext.$file_ext >/dev/null 2>&1; then
                        /bin/rm "$file"
                    else
                        echo "Skipping $file"
                    fi
                fi
                
                continue
            fi
            
            local file_name=$(basename $file)
            local file_name_no_ext=${file_name%.*}
            local file_ext=${file_name##*.}
            # Extracts the UUID prefix from the file name (before the first '_')
            local file_uuid=${file_name%%_*}
            # Extracts the suffix after the last '_' in the file name
            local file_suffix=${file_name_no_ext##*_}
        
            # If the file has a suffix of '_c' or '_o' before the extension
            if [[ $file_suffix == "c" || $file_suffix == "o" ]]; then
                # If a file with the same UUID prefix exists, i.e. UUID.any-ext
                if ls $file_uuid.* >/dev/null 2>&1; then
                    /bin/rm $file
                else
                    echo "Skipping $file"
                    # Print debug info
                    echo "UUID: $file_uuid"
                    echo "Suffix: $file_suffix"
                    echo "Extension: $file_ext"
                fi
            fi
        fi
    done
}
