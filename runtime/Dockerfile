FROM google/golang

WORKDIR /gopath/src/app
ONBUILD ADD . /gopath/src/app/
ONBUILD RUN [ -d gopath ] && mv gopath/* /gopath/src/ && rmdir gopath || true
ONBUILD RUN find /gopath
ONBUILD RUN go get app

EXPOSE 8080
CMD []
ENTRYPOINT ["/gopath/bin/app"]
