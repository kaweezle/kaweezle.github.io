#!/usr/bin/env sh

set -e

echo "::group::Setup"

cd $GITHUB_WORKSPACE

if [[ -z "$INPUT_PROJECTS" ]]; then
    echo "No Projects!"
    exit 1
fi

if  [[ -z "$INPUT_SIGNATURE_KEY_NAME" ]]; then
    echo "No signature key name given!"
    exit 1
fi

if  [[ -z "$INPUT_SIGNATURE_KEY" ]]; then
    echo "No signature key given!"
    exit 1
else
    signature_file="/root/$INPUT_SIGNATURE_KEY_NAME"
    printf "$INPUT_SIGNATURE_KEY" > "$signature_file"
fi

if [[ -z "$INPUT_DESTINATION" ]]; then
    echo "No destination given!"
    exit 1
fi


project_count=$(echo $INPUT_PROJECTS | wc -w)
rm -rf "$INPUT_DESTINATION"
mkdir -p "$INPUT_DESTINATION"
mkdir -p /apks


echo "Creating repo in $INPUT_DESTINATION from $project_count projects..."

echo "::endgroup::"


echo "::group::Fetching APKs"


cd /apks
for project in $INPUT_PROJECTS; do
    echo ""
    echo "=> Processing $project..."
    base_url="https://github.com/$project"
    project_name=$(echo $project | cut -d '/' -f 2)
    last_release=$(curl -Ls -o /dev/null -w %{url_effective} $base_url/releases/latest | sed -e 's#^.*/tag/##g')
    download_base_url="$base_url/releases/download/$last_release"
    echo "Last release for $project is $last_release"
    curl -sL "$download_base_url/SHA256SUMS" | grep '.apk$' | while read apk_checksum apk_name; do
        echo "Downloading apk $apk_name (checksum $apk_checksum)..."
        curl -sLO "$download_base_url/$apk_name"
        received_sha=$(sha256sum $apk_name | cut -d' ' -f 1)
        if [[ $received_sha != $apk_checksum ]]; then
            echo "Bad checksum for $apk_name. Expected $apk_checksum, got $received_sha"
            exit 1
        fi
    done
done

files=$(ls -1 2>/dev/null)
files_count=$(echo "$files" | wc -l)
if [[ "$files_count" -eq 0 ]]; then
    echo "No APKs downloaded"
    exit 1
fi

archs=$(ls -1 2>/dev/null | sed -E 's/^.*\.(.*)\.apk$/\1/g' | sort -u)
archs_count=$(echo "$archs" | wc -l)
if [[ "$archs_count" -eq 0 ]]; then
    echo "No architectures found in APK files: $files"
    exit 1
fi

echo "Donwloaded $files_count APKs, $archs_count architectures..."

echo "::endgroup::"


echo "::group::Creating repo in $INPUT_DESTINATION"
cd $GITHUB_WORKSPACE

rm -rf $INPUT_DESTINATION
mkdir -p $INPUT_DESTINATION

for arch in $archs; do
    arch_directory="${INPUT_DESTINATION}/$arch"
    echo "Creating directory $arch_directory"
    mkdir -p "$arch_directory"
done

for file in $(echo "$files"); do
    file_basename=$(basename "$file")
    file_arch=$(echo "$file_basename" | sed -E 's/^.*\.(.*)\.apk$/\1/g')
    destination_filename=$(echo "$file_basename" | sed -E 's/^(.*)\.[^.]*\.apk$/\1.apk/g')
    echo "Copying ${file} to ${INPUT_DESTINATION}/${file_arch}/${destination_filename}..."
    cp -f "/apks/${file}" "${INPUT_DESTINATION}/${file_arch}/${destination_filename}"
done

echo "::endgroup::"


echo "::group::Creating indexes"

for arch in $archs; do
    arch_directory="${INPUT_DESTINATION}/$arch"
    index_file="${arch_directory}/APKINDEX.tar.gz"
    apk index -o "${index_file}" "${arch_directory}"/*.apk 2>/dev/null
    abuild-sign -k "${signature_file}" "${index_file}"
done

echo "::endgroup::"


