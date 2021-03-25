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
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && python fslinstaller.py -d /usr/local/fsl -V 6.0.4 && rm -rf /usr/local/fsl/src

ENV FSLDIR=/usr/local/fsl
ENV PATH=$PATH:$FSLDIR/bin
ENV LD_LIBRARY_PATH=$FSLDIR/lib
ENV FSLOUTPUTTYPE=NIFTI_GZ

# Install FIX
RUN cd /tmp && wget http://www.fmrib.ox.ac.uk/~steve/ftp/fix.tar.gz && tar xvzf fix.tar.gz && mv fix /usr/local && rm fix.tar.gz

# MATLAB MCR
RUN cd /tmp && wget https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip && \
 mkdir mcr && mv MCR_R2017b_glnxa64_installer.zip mcr && cd mcr && \
 unzip MCR_R2017b_glnxa64_installer.zip && \
 ./install -mode silent -agreeToLicense yes \
   -destinationFolder /usr/local/MATLAB/MCR/v93 && \
 cd /tmp && rm -rf mcr

# Copy customized settings.sh
COPY settings.sh /usr/local/fix

