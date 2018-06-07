FROM ubuntu:16.04
MAINTAINER PhenoMeNal-H2020 Project <phenomenal-h2020-users@googlegroups.com>

LABEL Description="Galaxy 17.05-phenomenal for running inside Kubernetes."
LABEL software="Galaxy"
LABEL software.version="17.05-pheno"
LABEL version="1.2"

RUN apt-get -qq update && apt-get install --no-install-recommends -y apt-transport-https software-properties-common wget && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y mercurial python-psycopg2 sudo virtualenv \
    libyaml-dev libffi-dev libssl-dev \
    curl git python-pip python-gnuplot python-psutil apt-utils bzip2 \
    samtools && \
    pip install --upgrade pip && \
    apt-get purge -y software-properties-common && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add user biodocker with password biodocker
RUN groupadd fuse && \
    useradd --create-home --shell /bin/bash --user-group --uid 1000 --groups sudo,fuse biodocker && \
    echo `echo "biodocker\nbiodocker\n" | passwd biodocker`

RUN git clone --depth 1 --single-branch --branch release_17.05_plus_k8s_fs_support https://github.com/phnmnl/galaxy.git
WORKDIR galaxy
RUN echo "pykube==0.15.0" >> requirements.txt \
    && cp requirements.txt requirements.txt.original \
    && sed s/requests==2.8.1/requests==2.18.4/ requirements.txt.original > requirements.txt \
    && rm requirements.txt.original
COPY config/galaxy.ini config/galaxy.ini
COPY config/job_conf.xml config/job_conf.xml
COPY config/tool_conf.xml config/tool_conf.xml
COPY config/sanitize_whitelist.txt config/sanitize_whitelist.txt
COPY tools/phenomenal tools/phenomenal

RUN virtualenv .venv
RUN /bin/bash -c "source .venv/bin/activate && \
                  pip install 'pip>=8.1' && \
                  pip install -r requirements.txt \
                      --index-url https://wheels.galaxyproject.org/simple && \
                  deactivate"

# Galaxy runs on python < 3.5, so https://github.com/kelproject/pykube/issues/29 recommends
ENV PYKUBE_KUBERNETES_SERVICE_HOST kubernetes

COPY html/partners.png static/partners.png
COPY html/PhenoMeNal_logo.png static/PhenoMeNal_logo.png
COPY html/welcome.html static/welcome.html
COPY ansible ansible
COPY workflows workflows
COPY container-simple-checks.sh container-simple-checks.sh
COPY test_cmds.txt test_cmds.txt
RUN chmod u+x /galaxy/ansible/run_galaxy_config.sh

# Missing XCMS datatypes for w4m
COPY external-datatypes/rdata_xcms_datatype.py /galaxy/lib/galaxy/datatypes/
COPY external-datatypes/rdata_camera_datatype.py /galaxy/lib/galaxy/datatypes/
COPY external-datatypes/no_unzip_datatypes.py /galaxy/lib/galaxy/datatypes/
COPY external-datatypes/nmrml_datatype.py /galaxy/lib/galaxy/datatypes/
COPY config/datatypes_conf.xml config/datatypes_conf.xml

EXPOSE 8080

CMD ["./run.sh"]
