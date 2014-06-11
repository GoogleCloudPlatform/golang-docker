FROM google/golang

WORKDIR /gopath/src/app
ONBUILD ADD . /gopath/src/app/
ONBUILD ENV GOPATH /gopath/src/app/gopath:$GOPATH
ONBUILD RUN go get app

EXPOSE 8080
CMD []
ENTRYPOINT ["/gopath/bin/app"]
