#!/bin/sh

timeout 60 strace -p $1
