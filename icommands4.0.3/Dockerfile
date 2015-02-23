FROM irods/icommands:4.0.3
MAINTAINER tedgin@iplantcollaborative.org

ADD ./bootstrap.sh bootstrap.sh
RUN chmod a+x bootstrap.sh

ENTRYPOINT [ "./bootstrap.sh" ]
