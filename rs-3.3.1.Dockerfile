FROM irods_server
MAINTAINER tedgin@iplantcollaborative.org

COPY rs-3.3.1/bootstrap.sh /

ENTRYPOINT [ "/bootstrap.sh" ]
