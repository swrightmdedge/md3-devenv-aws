#!/bin/bash
docker build -t md3/devenv devenv
docker run -p 80:80 devenv
