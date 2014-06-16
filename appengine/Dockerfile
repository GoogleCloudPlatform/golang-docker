FROM google/golang

ONBUILD ADD . /app
ONBUILD RUN /app/_ah/build.sh

EXPOSE 8080
CMD []
WORKDIR /app
ENTRYPOINT ["/app/_ah/exe"]
