FROM google/golang

ONBUILD ADD . /app
ONBUILD RUN /app/build.sh

EXPOSE 8080
CMD []
ENTRYPOINT ["/app/_ah_exe"]
