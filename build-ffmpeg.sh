#!/bin/bash

set -euo pipefail

echo "/usr/local/lib" > /etc/ld.so.conf.d/libc.conf

export MAKEFLAGS="-j$[$(nproc) + 1]"
export SRC=/usr/local
export PKG_CONFIG_PATH=${SRC}/lib/pkgconfig

# ffmpeg
DIR=$(mktemp -d) && cd ${DIR} && \
              curl -L http://s3.eu-central-1.amazonaws.com/s3.fluxmedia.at/Blackmagic_DeckLink_SDK_10.4.3.zip -O && \
              unzip Blackmagic_DeckLink_SDK_10.4.3.zip && \
              ln -s Blackmagic\ DeckLink\ SDK\ ${DECKLINK_SDK_VERSION} blackmagic_decklink_sdk_${DECKLINK_SDK_VERSION} && \
              curl -s http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz | tar zxvf - -C . && \
              cd ffmpeg-${FFMPEG_VERSION} && \
              ln -s $(pwd) /tmp/ffmpeg-${FFMPEG_VERSION}
              ./configure --prefix="${SRC}" --extra-cflags="-I${SRC}/include" \
              --extra-ldflags="-L${SRC}/lib" --bindir="${SRC}/bin" \
              --extra-libs=-ldl --enable-version3 --enable-libfaac --enable-libmp3lame \
              --enable-libx264 --enable-libxvid --enable-gpl \
              --enable-postproc --enable-nonfree --enable-avresample --enable-libfdk_aac \
              --disable-debug --enable-small --enable-openssl --enable-libtheora \
              --enable-libx265 --enable-libopus --enable-libvorbis --enable-libvpx \
              --enable-decklink --extra-cflags="-I${DIR}/blackmagic_decklink_sdk_${DECKLINK_SDK_VERSION}/Linux/include" --extra-ldflags="-L${DIR}/blackmagic_decklink_sdk_${DECKLINK_SDK_VERSION}/Linux/include" && \
              make && \
              make install && \
              make distclean && \
              hash -r && \
              cd tools && \
              make qt-faststart && \
              cp qt-faststart ${SRC}/bin && \
              rm -rf ${DIR}

yum history -y undo last && yum clean all && rm -rf /var/lib/yum/*
