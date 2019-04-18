#!/bin/bash
docker build -t md3/devenv /home/ubuntu/md3-devenv-aws/devenv
docker run -p 80:80 md3/devenv
