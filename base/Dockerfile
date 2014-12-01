FROM google/debian:wheezy

ENV GOLANG_VERSION  1.3.3

RUN apt-get update -y \ 
  && apt-get install --no-install-recommends -y -q curl build-essential ca-certificates git mercurial bzr \
  && mkdir /goroot \
  && curl https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1 \
  && mkdir /gopath

ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin
