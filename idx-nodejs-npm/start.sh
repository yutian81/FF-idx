#!/usr/bin/env bash

export $(grep -v '^#' .env | xargs) 2>/dev/null
npx nodejs-argo
