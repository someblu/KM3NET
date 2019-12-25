FROM alpine:latest
WORKDIR /app
ADD http://mirrors.advancedhosters.com/apache/xerces/c/3/sources/xerces-c-3.2.2.tar.gz https://github.com/Geant4/geant4/archive/v9.6.2.tar.gz ./
#ADD http://physicslab.eap.gr/KM3NET/HOURS_KM3Sim.tgz ./

RUN apk update && apk upgrade
RUN apk add --virtual .build-deps \
    make cmake \
    gcc g++ libc-dev libstdc++ \
    musl-dbg musl-dev linux-headers \
    icu-dev expat-dev curl-dev

RUN tar -xzf xerces-c-3.2.2.tar.gz
RUN cd xerces-c-3.2.2 && mkdir build && cd build && cmake -Dnetwork-accessor=curl -Dtranscoder=icu -Dmessage-loader=icu -Dxmlch-type=uint16_t -Dmutex-manager=posix .. && make -j $(nproc) -w && make install

RUN tar -xzf geant4-9.6.2.tar.gz
RUN cd geant4-9.6.2/source/visualization/HepRep/src/ && mv gzipoutputstream.cc GZIPOutputStream.cc && mv zipoutputstream.cc ZipOutputStream.cc
RUN sed -i  "/^cmake_minimum_required/a cmake_policy(SET CMP0038 OLD)" geant4-9.6.2/CMakeLists.txt
RUN sed -i "s/__va_copy/__builtin_va_copy/" geant4-9.6.2/source/processes/hadronic/models/lend/src/statusMessageReporting.cc

RUN cd geant4-9.6.2 && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/app/geant4_install -DGEANT4_USE_SYSTEM_EXPAT=ON -DGEANT4_USE_GDML=ON -DGEANT4_INSTALL_DATA=OFF .. && make -j $(nproc) -w && make install

CMD ["/bin/ash"]
