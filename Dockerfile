## Dockerfile to make "docker-fix"
## This file makes a container image of FSL-FIX
## K. Nemoto 25 Mar 2021

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Change default sh from Dash to Bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install utilities
RUN apt update && apt install -y curl less libgl1-mesa-dev \
  python python-numpy r-base r-cran-devtools vim wget 

# Install R packages for FIX
COPY fix-r-packages.R /tmp/
RUN Rscript /tmp/fix-r-packages.R

# Install FSL and get rid of src directory afterwards
RUN cd /tmp && wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
  python fslinstaller.py -d /usr/local/fsl -V 6.0.4 && rm -rf /usr/local/fsl/src

ENV FSLDIR=/usr/local/fsl
ENV PATH=$PATH:$FSLDIR/bin
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLTCLSH=$FSLDIR/bin/fsltclsh
ENV FSLWISH=$FSLDIR/bin/fslwish


# Install FIX
RUN cd /tmp && wget http://www.fmrib.ox.ac.uk/~steve/ftp/fix.tar.gz && \
  tar xvzf fix.tar.gz && mv fix /usr/local && rm fix.tar.gz

ENV PATH=$PATH:/usr/local/fix

# Copy customized settings.sh
COPY settings.sh /usr/local/fix

# MATLAB MCR
RUN cd /tmp && wget https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip && \
 mkdir mcr && mv MCR_R2017b_glnxa64_installer.zip mcr && cd mcr && \
 unzip MCR_R2017b_glnxa64_installer.zip && \
 ./install -mode silent -agreeToLicense yes \
   -destinationFolder /usr/local/MATLAB/MCR/v93 && \
 cd /tmp && rm -rf mcr matlab*

# Install ROBEX
RUN cd /tmp && wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/ROBEXv12.linux64.tar.gz && \
  cd /usr/local && tar xvzf /tmp/ROBEXv12.linux64.tar.gz && chmod 755 ROBEX && cd ROBEX && \
  find -type f -exec chmod 644 {} \; && chmod 755 ROBEX runROBEX.sh dat ref_vols

ENV PATH=$PATH:/usr/local/ROBEX

# Install bc
RUN apt install bc

# Install scripts
COPY individual-melodic.sh /usr/local/bin

