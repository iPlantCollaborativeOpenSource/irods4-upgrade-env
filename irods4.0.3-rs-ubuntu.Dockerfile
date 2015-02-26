FROM ubuntu:12.04
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update
RUN apt-get upgrade --yes

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get install --yes libcurl4-gnutls-dev sudo wget

RUN wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-resource-4.0.3-64bit.deb

# install package dependencies to prevent Docker build from erring out
RUN apt-get install --yes \
                    $(dpkg --info irods-resource-4.0.3-64bit.deb \
                        | sed --quiet 's/^ Depends: //p' \
                        | sed 's/,//g')

RUN dpkg --install irods-resource-4.0.3-64bit.deb

COPY irods4.0.3-rs/get_icat_server_password.sh /var/lib/irods/packaging/get_icat_server_password.sh
RUN chmod a+x /var/lib/irods/packaging/get_icat_server_password.sh

COPY irods4.0.3-rs/bootstrap.sh bootstrap.sh
RUN chmod a+x bootstrap.sh

EXPOSE 1247 20000-20199

ENTRYPOINT [ "./bootstrap.sh" ]
