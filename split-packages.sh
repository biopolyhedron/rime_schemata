#!/bin/bash

. $(dirname "$0")/polyhedron-packages.conf

filename_mapping='
s/_/-/g;
s/^triungkoxsampheng.*$/middle-chinese/;
s/^zyenpheng.*$/middle-chinese/;
s/^中古三拼方案.*$/middle-chinese/;
s/^阿拉伯字母編碼.*$/arabic/
'

packages_dir='packages'

get_package() {
    local file=$(echo "$1" | sed "${filename_mapping}")
    local package
    for package in ${package_list[@]}; do
        package="${package#*/rime-}"
        if [[ $file =~ ^$package ]]; then
            echo $package
        fi
    done
}

cd $(dirname "$0")
for file in *; do
    package=$(get_package "${file}")
    if [[ -z "${package}" ]]; then
        echo "Skipped ${file}"
        continue
    fi
    target_dir="${packages_dir}/rime-${package}"
    mkdir -p "${target_dir}"
    cp "${file}" "${target_dir}"
done

self_account=lotem
upstream_account=biopolyhedron

for package_dir in "${packages_dir}"/*; do
    pushd "${package_dir}"
    git init && git add . && git commit -m 'initial upload'
    repo_url="https://github.com/${upstream_account}/$(basename "${package_dir}").git"
    echo "Uploading to new repository ${repo_url}"
    git remote add origin "${repo_url/${upstream_account}/${self_account}}"
    git remote add upstream "${repo_url}"
    git push -u origin master
    popd
done
