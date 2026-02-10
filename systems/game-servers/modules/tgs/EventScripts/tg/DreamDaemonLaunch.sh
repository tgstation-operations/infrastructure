#!/usr/bin/env bash

timeout 60 strace -p $1
