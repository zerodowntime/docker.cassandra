#!/bin/sh

nodetool info | grep -i 'Native Transport' | grep -i true > /dev/null
