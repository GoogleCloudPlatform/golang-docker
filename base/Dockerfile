# Dockerfile extending the generic Go image with application files for a
# single application.
FROM gcr.io/google_appengine/base

RUN apt-get update \
    && apt-get install -y \
       curl gcc git libc6-dev make \
       --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV GO_VERSION 1.5.1
ENV GO_TARFILE go${GO_VERSION}.linux-amd64.tar.gz
ENV GO_DOWNLOAD_URL https://golang.org/dl/${GO_TARFILE}
ENV GO_DOWNLOAD_SHA1 46eecd290d8803887dec718c691cc243f2175fe0
ENV GO_WRAPPER_COMMIT 6ea1f29b1fe7e6b0b8eb89493ed5e06bac454654

RUN curl -fsSLO "${GO_DOWNLOAD_URL}" \
	&& echo "${GO_DOWNLOAD_SHA1} ${GO_TARFILE}" | sha1sum -c - \
	&& tar -C /usr/local -xzf ${GO_TARFILE} \
	&& rm ${GO_TARFILE}

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go:/go/src/app/_gopath

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

RUN curl https://raw.githubusercontent.com/docker-library/golang/${GO_WRAPPER_COMMIT}/1.5/go-wrapper \
    -o /usr/local/bin/go-wrapper \
    && chmod 755 /usr/local/bin/go-wrapper

RUN ln -s /go/src/app /app
WORKDIR /go/src/app

CMD ["go-wrapper", "run"]
