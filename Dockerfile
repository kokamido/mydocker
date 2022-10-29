FROM nvidia/cuda:11.5.1-cudnn8-devel-ubuntu20.04
VOLUME /workspace

ARG passw

RUN groupadd sshgroup && \
useradd -ms /bin/bash -g sshgroup alexandr.pankratov && \
usermod -aG sudo alexandr.pankratov
RUN bash -c 'echo alexandr.pankratov:${passw} | chpasswd'


ARG DEBIAN_FRONTEND=noninteractive

RUN apt-key del 7fa2af80
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt update
RUN apt install openssh-server sudo -y && \
apt install net-tools && \
apt install htop && \
apt install -y build-essential && \
apt-get install -y wget && \ 
apt-get clean && \
rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
/bin/bash ~/miniconda.sh -b -p /opt/conda

ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda update conda
RUN conda install -y pytorch torchvision torchaudio pytorch-cuda=11.6 -c pytorch -c nvidia

RUN mkdir -p /home/alexandr.pankratov/.ssh

COPY docker_key.pub /home/alexandr.pankratov/.ssh/authorized_keys
RUN chown alexandr.pankratov:sshgroup /home/alexandr.pankratov/.ssh/authorized_keys && chmod 600 /home/alexandr.pankratov/.ssh/authorized_keys

RUN service ssh start
CMD ["/usr/sbin/sshd","-D"]

EXPOSE 22
EXPOSE 32000
EXPOSE 32001
EXPOSE 32002
EXPOSE 32003
EXPOSE 32004
EXPOSE 32005

ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]