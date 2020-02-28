FROM circleci/ruby:2.6-buster-node

RUN sudo apt-get update
RUN sudo apt-get install -y libicu-dev libidn11-dev libprotobuf-dev protobuf-compiler ffmpeg
RUN sudo wget http://ftp.au.debian.org/debian/pool/main/i/icu/libicu57_57.1-6+deb9u3_amd64.deb
RUN sudo dpkg -i libicu57_57.1-6+deb9u3_amd64.deb
RUN sudo wget http://ftp.au.debian.org/debian/pool/main/p/protobuf/libprotobuf10_3.0.0-9_amd64.deb
RUN sudo dpkg -i libprotobuf10_3.0.0-9_amd64.deb
