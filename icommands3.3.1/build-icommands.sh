#!/bin/bash

function genresp ()
{
    echo "no"   # no advanced settings
    echo "no"   # no server
    echo "no"   # no GSI
    echo "no"   # no kerberos
    echo "no"   # NCCS auditing
    echo "yes"  # save configuration
    echo "yes"  # start build
}

genresp | ./irodssetup