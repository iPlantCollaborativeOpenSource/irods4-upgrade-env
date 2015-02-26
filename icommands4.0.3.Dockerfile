FROM irods/icommands:4.0.3
MAINTAINER tedgin@iplantcollaborative.org

COPY icommands4.0.3/bootstrap.sh bootstrap.sh
RUN chmod a+x bootstrap.sh

ENTRYPOINT [ "./bootstrap.sh" ]
