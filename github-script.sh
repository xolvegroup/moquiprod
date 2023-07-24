#!/bin/bash
#set -x

rm -rf moquiprod
echo "download from repository"
##git clone https://github.com/xolvegroup/moquiprod.git moquiprod && cd moquiprod
./gradlew getComponent -Pcomponent=HiveMind
./gradlew downloadOpenSearch
cd runtime/component
git clone git@github.com:xolvegroup/xolve-theme.git
git clone https://github.com/xolvegroup/WorkManagement.git
git clone https://github.com/xolvegroup/Sales.git
cd runtime/lib/
wget https://jdbc.postgresql.org/download/postgresql-42.2.9.jar
cd ../..
./gradlew build
./gradlew load
./gradlew addRuntime
echo "Path for current"
pwd
ls -lart
#unzip moqui-plus-runtime.war /docker/simple/
#cd docker/simple
if unzip -q ../moqui/moqui-plus-runtime.war; then
    echo "downloaded and build successfully"
else
    echo "compile/build failed"
    exit
fi
echo "building image...."
docker build -t moquiprod/moquiprod .
docker tag xolvegroup/moquiprod xolvegroup/moquiprod:$DATE
echo "push image to hub.docker.com/repository/docker/xolvegroup/moquiprod"
if docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN ; then
    if docker push xolvegroup/moquiprod ; then
        cd ..
        rm -rf moqui; rm -rf buildImage
        docker rmi -f $(docker images -q)
        echo "image pushed to docker hub"
        exit
    fi
fi
echo "something went wrong?"
