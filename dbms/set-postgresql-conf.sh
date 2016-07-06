#! /bin/bash

# Customize postgresql.conf

sed --in-place '/standard_conforming_strings/d' "$PGDATA"/postgresql.conf
printf 'standard_conforming_strings = off' >> "$PGDATA"/postgresql.conf
