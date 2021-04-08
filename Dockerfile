## Dockerfile to make "docker-fix"
## This file makes a container image of FSL-FIX
## FSL 6.0.4
## FIX 1.0.6.15
## K. Nemoto 27 Mar 2021

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

## General
# Change default sh from Dash to Bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Install utilities, python, and R
# libgl1-mesa-dev is needed for fslpython
# python-numpy is needed for FSL
RUN apt-get update && apt-get install -y --no-install-recommends \
  bc less libgl1-mesa-dev vim wget python python-numpy

RUN apt-get install -y r-base r-cran-devtools


## R packages for FIX
# sources: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIX/UserGuide
# Install R packages for FIX
COPY fix-r-packages.R /tmp/
RUN Rscript /tmp/fix-r-packages.R && rm /tmp/fix-r-packages.R


## ROBEX (good for skull stripping)
# Install ROBEX
RUN cd /tmp && wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/ROBEXv12.linux64.tar.gz && \
  cd /usr/local && tar xvzf /tmp/ROBEXv12.linux64.tar.gz && chmod 755 ROBEX && cd ROBEX && \
  find -type f -exec chmod 644 {} \; && chmod 755 ROBEX runROBEX.sh dat ref_vols && \
  rm /tmp/ROBEXv12.linux64.tar.gz
ENV PATH=$PATH:/usr/local/ROBEX


## FSL
# Install FSL, get rid of src directory, and set environment variables
RUN cd /tmp && wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
  python fslinstaller.py -d /usr/local/fsl -V 6.0.4 && rm -rf /usr/local/fsl/src

ENV FSLDIR=/usr/local/fsl
ENV PATH=$PATH:$FSLDIR/bin
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLTCLSH=$FSLDIR/bin/fsltclsh
ENV FSLWISH=$FSLDIR/bin/fslwish


## FIX
# Install FIX
RUN cd /tmp && wget http://www.fmrib.ox.ac.uk/~steve/ftp/fix.tar.gz && \
  tar xvzf fix.tar.gz && mv fix /usr/local && rm fix.tar.gz
ENV PATH=$PATH:/usr/local/fix

# Copy customized settings.sh for fix
COPY settings.sh /usr/local/fix


## Octave
# source: README under fix
# Install Octave
RUN apt-get install -y \
  octave octave-statistics octave-signal && \
  echo "pkg load statistics signal" >> /usr/share/octave/site/m/startup/octaverc


#RUN apt-get install -y \
#  octave octave-io octave-statistics octave-specfun \
#  octave-general octave-control octave-signal && \
#  echo "pkg load io statistics specfun general control signal" >> /usr/share/octave/site/m/startup/octaverc

# modification of FIX m-files for Octave
# source: https://www.jiscmail.ac.uk/cgi-bin/wa-jisc.exe?A2=FSL;992d17bb.2012
RUN sed -i 's/median/nanmedian/g' /usr/local/fix/fix_1a_extract_features.m && \
    sed -i 's/median/nanmedian/g' /usr/local/fix/featureclusterdist.m && \
    sed -i 's/corrcoef/corr/g' /usr/local/fix/featuretsjump.m && \
    sed -i 's/corrcoef/corr/g' /usr/local/fix/featuresagmasks.m && \
    sed -i 's/corrcoef/corr/g' /usr/local/fix/featuremotioncorrelation.m

## Main script
COPY individual-fix.sh /usr/local/bin


## USER is needed for feat
# User brain
ARG UID=1000
RUN useradd -m -u ${UID} brain && echo "brain:lin4neuro" | chpasswd && adduser brain sudo
USER brain
ENV USER=brain

