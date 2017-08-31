#!/bin/sh

path=$(dirname "$0")
touch $path/run.log
ruby $path/get_stations.rb >> $path/run.log