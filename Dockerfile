FROM ubuntu:16.04

MAINTAINER Maintainer Thomas Kristensen
LABEL Description="ctf image" Version="0.2"

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/http:\/\//http:\/\/no./g' /etc/apt/sources.list \
    && rm -rf /var/lib/apt/lists/*

# Installing the 'apt-utils' package gets rid of the 'debconf: delaying package configuration, since apt-utils is not installed'
# error message when installing any other package with the apt package manager.
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg-reconfigure -u apt-utils

RUN apt-get update && apt-get install -y software-properties-common unattended-upgrades
RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt-get install -y \
    build-essential \
    curl \
    gdb \
    gdb-multiarch \
    gdbserver \
    git \
    libc6-arm64-cross \
    libc6-armhf-cross \
    libc6-dev-i386 \
    libc6-i386 \
    libffi-dev \
    libssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    python-dev \
    python-dev \
    python-pip \
    python2.7 \
    python3-pip \
    tmux \
    tree \
    virtualenvwrapper \
    wget \
    silversearcher-ag \
    unzip \
    cmake \
    net-tools

# Install Neovim
RUN add-apt-repository ppa:neovim-ppa/unstable
RUN apt-get update
RUN apt-get install -y neovim
RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
RUN update-alternatives --set vi /usr/bin/nvim
RUN update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
RUN update-alternatives --set vim /usr/bin/nvim
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
RUN update-alternatives --set editor /usr/bin/nvim
RUN pip install --upgrade pip
RUN pip install --upgrade neovim

# Install angr
RUN pip install --upgrade angr

# Install pwntools
RUN pip install --upgrade ipython
RUN pip install --upgrade pwntools

RUN mkdir /root/tools

# Install radare2
RUN cd /root/tools \
    && git clone https://github.com/radare/radare2 \
    && cd radare2 \
    && ./sys/install.sh \
    && make symstall \
    && cd /root/tools \
    && rm -rf radare2

# Install pwndbg
RUN cd /root/tools \
    && git clone https://github.com/zachriggle/pwndbg \
    && cd pwndbg \
    && sed 's/sudo//g' setup.sh > non_sudo_setup.sh \
    && chmod +x non_sudo_setup.sh \
    && ./non_sudo_setup.sh \
    && cd /root/tools \
    && rm -rf pwndbg

# Install qemu
RUN apt-get -y install qemu qemu-user qemu-user-static
RUN apt-get -y install 'binfmt*'
RUN apt-get -y install libc6-armhf-armel-cross
RUN apt-get -y install debian-keyring
RUN apt-get -y install debian-archive-keyring
RUN apt-get -m update; echo 0 # Always success from update
RUN apt-get -y install libc6-mipsel-cross
RUN apt-get -y install libc6-armel-cross libc6-dev-armel-cross
RUN apt-get -y install libc6-armhf-cross libc6-dev-armhf-cross
RUN apt-get -y install binutils-arm-linux-gnueabi
RUN apt-get -y install libncurses5-dev
RUN mkdir /etc/qemu-binfmt
RUN ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel
RUN ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
RUN apt-get update

# Install binwalk
RUN cd /root/tools \
    && git clone https://github.com/devttys0/binwalk \
    && cd binwalk \
    && python setup.py install \
    && apt-get -y install squashfs-tools \
    && cd /root/tools \
    && rm -rf binwalk

# Install firmware-mod-kit
RUN apt-get -y install git build-essential zlib1g-dev liblzma-dev python-magic \
    && cd /root/tools \
    && wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/firmware-mod-kit/fmk_099.tar.gz \
    && tar zxvf fmk_099.tar.gz \
    && rm fmk_099.tar.gz \
    && cd fmk/src \
    && ./configure \
    && make

# Install AFL with QEMU and clang-fast
RUN apt-get -y install clang llvm libtool-bin
RUN cd /root/tools \
    && wget http://lcamtuf.coredump.cx/afl/releases/afl-latest.tgz \
    && tar -xzvf afl-latest.tgz \
    && rm afl-latest.tgz \
    && wget http://llvm.org/releases/3.8.0/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz \
    && xz -d clang* \
    && tar xvf clang* \
    && cd clang* \
    && cd bin \
    && export PATH=$PWD:$PATH \
    && cd ../.. \
    && cd afl-* \
    && make \
    && cd llvm_mode \
    && make \
    && cd .. \
    && apt-get update \
    && apt-get -y install libtool automake bison libglib2.0-dev \
    && cd qemu* \
    && ./build_qemu_support.sh \
    && cd .. \
    && make install \
    && cd /root/tools \
    && rm -rf clang* afl*

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dev-i386

# Install apktool
RUN apt-get update \
    && apt-get install -y default-jre \
    && wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool \
    && wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.2.jar \
    && mv apktool_2.0.2.jar /bin/apktool.jar \
    && mv apktool /bin/ \
    && chmod 755 /bin/apktool \
    && chmod 755 /bin/apktool.jar

# Install Pillow
RUN apt-get -y build-dep python-imaging \
    && apt-get -y install libjpeg8 libjpeg62-dev libfreetype6 libfreetype6-dev \
    && pip install Pillow

# Install r2pipe
RUN pip install --upgrade r2pipe

# Install Frida
RUN pip install --upgrade frida

# Install ROPGadget
RUN cd /root/tools \
    && git clone https://github.com/JonathanSalwan/ROPgadget \
    && cd ROPgadget \
    && python setup.py install \
    && cd /root/tools \
    && rm -rf ROPgadget

# Install fzf
RUN cd /root/tools \
    && git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf \
    && /root/.fzf/install --all --key-bindings --completion

# Install libheap in GDB
RUN cd /root/tools \
    && apt-get install -y libc6-dbg \
    && git clone https://github.com/cloudburst/libheap \
    && cd libheap \
    && python setup.py install \
    && cd /root/tools \
    && rm -rf libheap \
    && echo "python from libheap import *" >> /root/.gdbinit

# Install ctf-tools
RUN apt-get install -y dsniff foremost texinfo subversion \
    pandoc libxml2-dev libxslt1-dev libcurl4-openssl-dev python-gmpy \
    tofrodos libsqlite3-dev libpcap-dev libgmp3-dev libevent-dev \
    autotools-dev
RUN cd /root/tools && git clone https://github.com/zardus/ctf-tools \
    && cd ctf-tools \
    && bin/manage-tools setup
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install subbrute
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install sqlmap
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install dirsearch
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install dirb
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install commix
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install burpsuite
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install exetractor
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install pdf-parser
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install peepdf
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install scrdec18
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install testdisk
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install cribdrag
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install foresight
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install featherduster
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install hashpump-partialhash
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install hash-identifier
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install littleblackbox
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install msieve
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install pemcrack
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install pkcrack
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install python-paddingoracle
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install reveng
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install sslsplit
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install xortool
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install yafu
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install elfkickers
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install xrop
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install evilize
RUN PATH=/root/tools/ctf-tools/bin:$PATH /root/tools/ctf-tools/bin/manage-tools install checksec

# Install XSSer
RUN pip install pycurl BeautifulSoup
RUN cd /root/tools \
    && wget http://xsser.03c8.net/xsser/xsser_1.7-1_amd64.deb \
    && dpkg -i xsser_1.7-1_amd64.deb \
    && rm -rf xsser*

# Install w3af
RUN pip install clamd==1.0.1 PyGithub==1.21.0 GitPython==0.3.2.RC1 pybloomfiltermmap==0.3.14 \
        esmre==0.3.1 phply==0.9.1 nltk==3.0.1 chardet==2.1.1 pdfminer==20140328 \
        futures==2.1.5 pyOpenSSL==0.15.1 scapy-real==2.2.0-dev guess-language==0.2 cluster==1.1.1b3 \
        msgpack-python==0.4.4 python-ntlm==1.0.1 halberd==0.2.4 darts.util.lru==0.5 \
        ndg-httpsclient==0.3.3 pyasn1==0.1.7 Jinja2==2.7.3 \
        vulndb==0.0.17 markdown==2.6.1 psutil==2.2.1 mitmproxy==0.12.1 \
        ruamel.ordereddict==0.4.8 Flask==0.10.1 PyYAML==3.11
RUN cd /root/tools \
    && git clone https://github.com/andresriancho/w3af.git \
    && cd w3af \
    && ./w3af_console ; true \
    && sed 's/sudo //g' -i /tmp/w3af_dependency_install.sh \
    && sed 's/apt-get/apt-get -y/g' -i /tmp/w3af_dependency_install.sh \
    && sed 's/pip install/pip install --upgrade/g' -i /tmp/w3af_dependency_install.sh \
    && /tmp/w3af_dependency_install.sh \
    && cd /root/tools \
    && rm -rf w3af

# Install decompile
COPY decompile /usr/bin/decompile
RUN chmod +x /usr/bin/decompile

# Install dotfiles
RUN cd /root \
    && git clone https://github.com/tkk2112/dotfiles.git \
    && cd dotfiles \
    && ./install.sh

# Setup ssh
RUN apt-get install -y openssh-server \
    && echo root:root | chpasswd \
    && sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && sed 's/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/' -i /etc/ssh/sshd_config \
    && mkdir -p /root/.ssh \
    && mkdir -p /var/run/sshd
COPY insecure_id_rsa.pub /root/.ssh/authorized_keys
EXPOSE 22

# Install steganography tools
RUN apt-get install -y steghide \
    pngtools \
    outguess \
    exif \
    exiv2 \
    imagemagick

# Install stegdetect/stegbreak
RUN apt-get install -y wamerican \
    && wget http://old-releases.ubuntu.com/ubuntu/pool/universe/s/stegdetect/stegdetect_0.6-6_amd64.deb \
    && dpkg -i stegdetect_0.6-6_amd64.deb \
    && rm -rf stegdetect*

# Install uncompyle2
RUN cd /root/tools \
    && git clone https://github.com/wibiti/uncompyle2.git \
    && cd uncompyle2 \
    && python setup.py install \
    && cd /root/tools \
    && rm -rf uncompyle2

# Install networking tools
RUN apt-get install -y nmap zmap masscan

# Install forensic tools
RUN apt-get install -y aircrack-ng samdump2 bkhive

# Install ophcrack
RUN apt-get install -y ophcrack

# Install John The Jumbo
RUN cd /root/tools \
    && git clone --depth 1 https://github.com/magnumripper/JohnTheRipper.git \
    && cd JohnTheRipper/src \
    && ./configure \
    && make -j2 install

# Clean up (commented until squash hits stable)
#RUN apt-get autoremove -y
#RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

# set locale
RUN unset DEBIAN_FRONTEND
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/usr/sbin/sshd", "-D"]