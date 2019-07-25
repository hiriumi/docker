#!/usr/bin/env bash

LATEST_WAR_URL=http://mirrors.jenkins.io/war-stable/latest/jenkins.war
SHA256_URL=http://mirrors.jenkins.io/war-stable/latest/jenkins.war.sha256
OUTPUT_DIR=./out/
POM_PROPERTIES_PATH=META-INF/maven/org.jenkins-ci.main/jenkins-war/pom.properties
JENKINS_VERSION=""

echo "Downloading the latest Jenkins war file..."

if [[ -d "$OUTPUT_DIR" ]]; then
    rm -rf ${OUTPUT_DIR}
fi

echo "Creating temporal output directory..."
mkdir ${OUTPUT_DIR}

echo "Downloading jenkins.war and its sha256 checksum from the official site..."
pushd .
cd ${OUTPUT_DIR} && curl -L -O ${LATEST_WAR_URL} && curl -L -O ${SHA256_URL}
popd


echo "Extracting $POM_PROPERTIES_PATH..."
cd ${OUTPUT_DIR}
unzip -o jenkins.war ${POM_PROPERTIES_PATH}cen

echo "Detecting the jenkins.war version..."
while read line
do
    if [[ ${line} =~ version=.+ ]]; then
        JENKINS_VERSION=${line##*=}
        break
    fi
done  < <(cat ${POM_PROPERTIES_PATH})

if [[ -z "$JENKINS_VERSION" ]]; then
    echo "Jenkins version could not be detected."
    exit 1
fi
echo "Jenkins version $JENKINS_VERSION detected."

echo "Validing the check sum..."
check_sum_output=$(sha256sum --check jenkins.war.sha256)
echo $check_sum_output
if [[ ${check_sum_output} =~ .*OK.* ]]; then
    echo "Checksum has been validated."
else
    echo "File may be corrupted. Script is exiting prematurely."
    exit 1
fi

cd ..
echo "Building Jenkins master on the latest CentOS image..."
docker build -f Dockerfile -t centos-jenkins-master:${JENKINS_VERSION} --build-arg JENKINS_WAR_SRC="${OUTPUT_DIR}jenkins.war" .

