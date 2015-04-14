FROM debian
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update
RUN apt-get install --yes socat

CMD socat TCP4-LISTEN:1247,fork,reuseaddr TCP4-LISTEN:1248,fork,reuseaddr

EXPOSE 1247 1248

