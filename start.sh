#! /bin/bash
# Licensed under the Apache License, Version 2.0 (the "License"); you 
#  may not use this file except in compliance with the License. You may obtain 
#  a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless 
#  required by applicable law or agreed to in writing, software distributed 
#  under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES 
#  OR CONDITIONS OF ANY KIND, either express or implied. See the License for 
#  the specific language governing permissions and limitations under the License. 
#  See accompanying LICENSE file.

sudo apt-get update
sudo apt-get -y install openjdk-8-jdk

sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

MYBUCKET=$(curl http://metadata/computeMetadata/v1/instance/attributes/my-bucket -H "Metadata-Flavor: Google")

gsutil cp -r ${MYBUCKET}/sparky . 

wget -q https://storage.googleapis.com/cloud-debugger/compute-java/format_env_gce.sh
chmod +x format_env_gce.sh
CDBG_ARGS="$( sudo ./format_env_gce.sh --app_class_path=hellosparky-1.0-SNAPSHOT-jar-with-dependencies.jar )"

java ${CDBG_ARGS} -cp sparky/hellosparky-1.0-SNAPSHOT-jar-with-dependencies.jar com.example.hellosparky.App
