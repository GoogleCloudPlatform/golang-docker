FROM google/golang

WORKDIR /gopath/src/app
ONBUILD ADD . /gopath/src/app/
ONBUILD RUN go install app

EXPOSE 8080
CMD []
ENTRYPOINT ["/gopath/bin/app"]
