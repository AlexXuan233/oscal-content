#!/bin/sh
set -e

component_definitions=$1
profiles=$2
catalogs=$3

TRESTLE_PREFIX="trestle://"
verified_files=()
# Test component definitions
for cd in $component_definitions; do
  # get profile path
  profile_path=$(jq -r '.["component-definition"].components[0]."control-implementations"[0].source' $cd)
  # remove trestle:// prefix
  profile_path=${profile_path#$TRESTLE_PREFIX}
  # get catalog path
  catalog_path=$(jq -r '.["profile"].imports[0].href' $profile_path)
  catalog_path=${catalog_path#$TRESTLE_PREFIX}
  echo "Testing $cd with $profile_path and $catalog_path"
  # get framework id
  framework_id=$(jq -r '.["component-definition"].components[0]."control-implementations"[0].props[] |
   select(.name="Framework_Short_Name").value' "$cd")
  # clean complyctl dir
  rm -f /usr/share/complytime/bundles/*
  rm -f /usr/share/complytime/controls/*
  # copy OSCAL contents to complyctl dir
  cp $cd /usr/share/complytime/bundles
  cp $profile_path $catalog_path /usr/share/complytime/controls
  # Update trestle path
  sed -i "s|trestle://$catalog_path|trestle://controls/catalog.json|" /usr/share/complytime/controls/profile.json
  sed -i "s|trestle://$profile_path|trestle://controls/profile.json|" /usr/share/complytime/bundles/component-definition.json
  complyctl list --plain

  verified_files+=("$cd" "$profile_path" "$catalog_path")
done

echo "${verified_files[@]}"

# Test profiles
for profile in $profiles; do
  echo "Testing $profile"
  catalog_path=$(jq -r '.["profile"].imports[0].href' $profile)
  catalog_path=${catalog_path#$TRESTLE_PREFIX}
  echo $catalog_path
  # TODO add test case
done

# Test catalogs
for catalog in $catalogs; do
  echo "Testing $catalog"
  # TODO add test case
done
