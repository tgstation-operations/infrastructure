#!/usr/bin/env bash

SERVER=$(pwd | cut -d/ -f5) # Fetch the server name from it's instance folder name
export SERVER
