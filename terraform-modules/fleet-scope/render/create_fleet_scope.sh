#!/bin/sh

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

github_org=${1}
github_user=${2}
github_email=${3}
github_token=${4}
fleet_scope_repo=${5}
fleet_scope=${6}
member_list=${7}
users=${8}

cd /workspace
random=$(echo $RANDOM | md5sum | head -c 20; echo)
local_fleet_scope_repo="${fleet_scope_repo}-${random}"
git config --global url."https://${github_user}:${github_token}@github.com".insteadOf "https://github.com"
git clone https://${github_user}:${github_token}@github.com/${github_org}/${fleet_scope_repo} ${local_fleet_scope_repo}
cd ${local_fleet_scope_repo}
#Adding TF file to dev
if [ -f env/dev/${fleet_scope}.tf ] ; then
  echo "scope file already exists. It's a NoOp."
else
  cp fleet-scope.tf.tpl env/dev/${fleet_scope}.tf
fi
#Adding TF file to staging
if [ -f env/staging/${fleet_scope}.tf ] ; then
  echo "scope file already exists. It's a NoOp."
else
  cp fleet-scope.tf.tpl env/staging/${fleet_scope}.tf
fi
#Adding TF file to prod
if [ -f env/prod/${fleet_scope}.tf ] ; then
  echo "scope file already exists. It's a NoOp."
else
  cp fleet-scope-prod.tf.tpl env/prod/${fleet_scope}.tf
fi
for i in $(echo $member_list | tr "," "\n")
do
  i='"'${i}'"'
  temp+="$i,"
done
member_list=$(echo ${temp} | sed 's/,$//g')
#Replaceing place holders in TF files
find env -type f -name ${fleet_scope}.tf -exec  sed -i "s/YOUR_FLEET_SCOPE/${fleet_scope}/g" {} +
find env -type f -name ${fleet_scope}.tf -exec  sed -i "s/MEMBERS_LIST/${member_list}/g" {} +
find env -type f -name ${fleet_scope}.tf -exec  sed -i "s/YOUR_USERS/${users}/g" {} +

git add .
git config --global user.name ${github_user}
git config --global user.email ${github_email}
git commit -m "Adding file for fleet scope and namespace ${namespace}."
git push origin

cd ../
rm -rf fleet_scope_repo-${random}