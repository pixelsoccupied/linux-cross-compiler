FROM centos
RUN yum group install "Development Tools" -y
RUN yum -y install rsync
COPY --from=golang /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"
