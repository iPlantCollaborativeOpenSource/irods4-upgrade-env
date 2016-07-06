#!/usr/bin/env python

import sys
import shlex
import urllib
import urllib2
import urlparse
import base64
import logging
import xml.dom.minidom

############################
# Config for local installation
#LOGFILE='/tmp/bisque_insert.log'
#BISQUE_HOST='http://bisque.ece.ucsb.edu'
#IRODS_HOST='irods://irods.ece.ucsb.edu'
#BISQUE_ADMIN_PASS='guessme'
LOGFILE='/home/irods/iRODS/server/log/bisque_insert.log'
BISQUE_HOST=''
IRODS_HOST=''
BISQUE_ADMIN_PASS=''
# End Config


logging.basicConfig(filename=LOGFILE, level=logging.INFO)
log = logging.getLogger('i2b')


def print_unknown_response(response):
    sys.stderr.write('Unknown response from Bisque: %s\n' % response)


def print_response(response):
    respDom = xml.dom.minidom.parseString(response)
    imageList = respDom.getElementsByTagName('image')
    if len(imageList) == 0 :
        tagList = respDom.getElementsByTagName('tag')
        if len(tagList) == 0:
            print_unknown_response(response)
        else:
            tag=tagList[0]
            errMsg = tagList[0].getAttribute('value')
            if len(errMsg) == 0 or tag.getAttribute('name') != 'error' :
                print_unknown_response(response)
            else:
                sys.stderr.write('%s\n' % errMsg)
                return 1
    else:
        image = imageList[0]
        uri = image.getAttribute('uri')
        resUniq = image.getAttribute('resource_uniq')
        if len(uri) == 0 or len(resUniq) == 0 :
            print_unknown_response(response)
            return 1
        else:
            print('%s %s' % (resUniq, uri))
    return 0


def main():
    log.debug( "insert2bisque received %s" % (sys.argv) )
    try:
        obj = sys.argv[1]
        user = sys.argv[2]
        permission = sys.argv[3]
        url = "%s/import/insert?%s" % (BISQUE_HOST, urllib.urlencode( { 'url': IRODS_HOST+obj, 'user': user, 'permission': permission}))
        request = urllib2.Request(url)
        request.add_header('authorization',  'Basic ' + base64.encodestring("admin:%s" % BISQUE_ADMIN_PASS ).strip())
        r = urllib2.urlopen(request)
        response = r.read()
        log.info( 'insert %s -> %s' % (url, response))
        return print_response(response)
    except Exception,e:
        log.exception( "exception occurred %s" % e )
        raise e


if __name__ == "__main__":
    if len(sys.argv) < 2:
        log.error ("usage: insert2bisque irods_path irods_user")
        sys.exit(1)
    sys.exit(main())

