#!/usr/bin/env python

import sys
import shlex
import urllib
import urllib2
import urlparse
import base64
import logging
import xml.dom.minidom


def format_request(bisqueHost, bisquePassword, irodsUrl, user, permission):
    query = urllib.urlencode({'url': irodsUrl, 'user': user, 'permission': permission})
    url = "%s/import/insert?%s" % (bisqueHost, query)
    request = urllib2.Request(url)
    authorization = 'Basic ' + base64.encodestring("admin:%s" % bisquePassword).strip()
    request.add_header('authorization', authorization)
    return request


def make_logger(logFile):
    logging.basicConfig(filename=logFile, level=logging.INFO)
    return logging.getLogger('insert2Bisque')


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
    bisqueHost = sys.argv[1]
    bisquePassword = sys.argv[2]
    irodsHost = sys.argv[3]
    obj = sys.argv[4]
    user = sys.argv[5]
    permission = sys.argv[6]
    logFile = sys.argv[7]

    log = make_logger(logFile)

    try:
        request = format_request(bisqueHost, bisquePassword, irodsHost + obj, user, permission)
        response = urllib2.urlopen(request).read()
        log.info('insert %s -> %s' % (request.get_full_url(), response))
        return print_response(response)
    except Exception,e:
        log.exception( "exception occurred %s" % e )
        raise e


if __name__ == "__main__":
    if len(sys.argv) < 8:
        sys.stderr.write(
                "usage: insert2bisque bisque_host bisque_password irods_host irods_path " + 
                "irods_user permission log_file\n"
                )
        sys.exit(1)
    sys.exit(main())

