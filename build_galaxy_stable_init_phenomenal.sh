#!/bin/bash
set -x -e

ANSIBLE_REPO=galaxyproject/ansible-galaxy-extras
ANSIBLE_RELEASE=86a127ae3aaaea125c8faa0271471106f2a4f889

GALAXY_RELEASE=b7dc87e872c14878a929237b3cb6d8fe2c579e5d
GALAXY_REPO=phnmnl/galaxy

docker build --build-arg ANSIBLE_REPO=$ANSIBLE_REPO --build-arg ANSIBLE_RELEASE=$ANSIBLE_RELEASE -t gmauro/galaxy-base-pheno docker-galaxy-stable/compose/galaxy-base/
#docker push gmauro/galaxy-base-pheno

docker build --build-arg GALAXY_REPO=$GALAXY_REPO --build-arg GALAXY_RELEASE=$GALAXY_RELEASE -t gmauro/galaxy-init-pheno docker-galaxy-stable/compose/galaxy-init/
#docker push gmauro/galaxy-init-pheno

docker build -t gmauro/galaxy-init-pheno-flavoured -f Dockerfile_init .
#docker push gmauro/galaxy-init-pheno-flavoured

docker build -t gmauro/galaxy-stable-k8s docker-galaxy-stable/compose/galaxy-k8s/
#docker push gmauro/galaxy-stable-k8s
