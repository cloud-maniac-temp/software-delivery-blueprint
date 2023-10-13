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

git_org=${1}
git_user=${2}
git_email=${3}
fleet_scope_repo=${4}
namespace=${5}
member_list=${6}
users=${7}

random=$(echo $RANDOM | md5sum | head -c 20; echo)
git clone -b main https://${git_user}:${TF_VAR_github_token}@github.com/${git_org}/${fleet_scope_repo} fleet_scope_repo-${random}
cd fleet_scope_repo-${random}

git checkout dev
if [ -f ./dev/${scope}.tf ] ; then
  "echo scope file already exists. It's a NoOp."
  exit 0
else
  cp render/fleet-scope.tf.tpl ./dev/${scope}.tf
fi

find ./dev -type f -name ${scope}.tf -exec  sed -i "s/YOUR_NAMESPACE/${namespace}/g" {} +
find ./dev -type f -name ${scope}.tf -exec  sed -i "s/MEMBERS_LIST/${member_list}/g" {} +
find ./dev -type f -name ${scope}.tf -exec  sed -i "s/YOUR_USERS/${users}/g" {} +

git add .
git config --global user.name ${git_user}
git config --global user.email ${git_email}
git commit -m "Adding file for fleet scope and namespace ${namespace}."
git push origin

cd ../
rm -rf fleet_scope_repo-${random}
