#!/bin/bash -x

sudo locale-gen "en_US.UTF-8"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
echo "LANG=en_US.UTF-8" | sudo tee /etc/default/locale > /dev/null
echo "LC_ALL=en_US.UTF-8" | sudo tee --append /etc/default/locale > /dev/null

cd $HOME
mkdir tools
cd tools

DEBIAN_FRONTEND=noninteractive
sudo -H rm -rf /var/lib/apt/lists/*

# Installing the 'apt-utils' package gets rid of the 'debconf: delaying package configuration, since apt-utils is not installed'
# error message when installing any other package with the apt package manager.
sudo -H apt update && sudo -H apt install -y --no-install-recommends \
    apt-utils \
    && sudo -H rm -rf /var/lib/apt/lists/*

sudo -H dpkg-reconfigure -u apt-utils

sudo -H apt update && sudo -H apt upgrade -y -o Dpkg::Options::="--force-confold"
sudo -H apt install -y \
    aircrack-ng autoconf automake autotools-dev bison bkhive build-essential \
    clang cmake curl dos2unix dsniff exif exiv2 fcrackzip foremost g++ gcc gdb \
    gdb-multiarch gdbserver git imagemagick libc6-arm64-cross libc6-armhf-cross \
    libc6-dev-i386 libc6-i386 libcurl4-openssl-dev libevent-dev libffi-dev \
    libfreetype6 libfreetype6-dev libglib2.0-dev libgmp3-dev libjpeg62-dev \
    libjpeg8 liblzma-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev \
    libpcap-dev libreadline-dev libsqlite3-dev libssl-dev libtool libtool-bin \
    libxml2-dev libxslt1-dev llvm lsb-release masscan most nano net-tools nmap \
    ophcrack outguess pandoc pngtools python python-dev python-gmpy python-imaging \
    python-magic python-pip python3-pip python2.7 python3 samdump2 silversearcher-ag \
    socat squashfs-tools steghide subversion texinfo tmux tofrodos tree unzip \
    virtualenvwrapper wamerican wget zlib1g-dev zmap libgmp-dev libsqlite3-dev


# Install pwndbg
cd $HOME/tools
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh

sudo -H pip3 install --upgrade pip
sudo -H pip3 install --upgrade ipython
sudo -H pip install --upgrade angr
sudo -H pip3 install --upgrade pwntools

# Install radare2
cd $HOME/tools \
    && git clone https://github.com/radare/radare2 \
    && cd radare2 \
    && ./sys/install.sh \
    && sudo -H make symstall

# Install qemu
sudo -H apt install -y qemu qemu-user qemu-user-static
sudo -H apt install -y 'binfmt*'
sudo -H apt install -y libc6-armhf-armel-cross
sudo -H apt install -y debian-keyring
sudo -H apt install -y debian-archive-keyring
sudo -H apt update -m; echo 0 # Always success from update
sudo -H apt install -y libc6-mipsel-cross
sudo -H apt install -y libc6-armel-cross libc6-dev-armel-cross
sudo -H apt install -y libc6-armhf-cross libc6-dev-armhf-cross
sudo -H apt install -y binutils-arm-linux-gnueabi
sudo -H apt install -y libncurses5-dev
sudo -H mkdir /etc/qemu-binfmt
sudo -H ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel
sudo -H ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
sudo -H apt update

# Install binwalk
cd $HOME/tools \
    && git clone https://github.com/devttys0/binwalk \
    && cd binwalk \
    && sudo -H python3 setup.py install \

# Install firmware-mod-kit
cd $HOME/tools \
    && wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/firmware-mod-kit/fmk_099.tar.gz \
    && tar zxvf fmk_099.tar.gz \
    && rm fmk_099.tar.gz \
    && cd fmk/src \
    && ./configure \
    && make

# Install AFL with QEMU and clang-fast
cd $HOME/tools \
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
    && cd qemu* \
    && ./build_qemu_support.sh \
    && cd .. \
    && sudo -H make install \
    && cd $HOME/tools \
    && rm -rf clang*

sudo -H dpkg --add-architecture i386
sudo -H apt update
sudo -H apt install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dev-i386

# Install apktool
sudo -H apt update \
    && sudo -H apt install -y default-jre \
    && wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool \
    && wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.2.jar \
    && sudo -H mv apktool_2.0.2.jar /bin/apktool.jar \
    && sudo -H mv apktool /bin/ \
    && sudo -H chmod 755 /bin/apktool \
    && sudo -H chmod 755 /bin/apktool.jar

# Install dotfiles
cd $HOME \
    && git clone https://github.com/tkk2112/dotfiles.git \
    && cd dotfiles \
    && ./install.sh

hash -r

# Install stegdetect/stegbreak
wget http://old-releases.ubuntu.com/ubuntu/pool/universe/s/stegdetect/stegdetect_0.6-6_amd64.deb \
    && sudo -H dpkg -i stegdetect_0.6-6_amd64.deb \
    && rm -rf stegdetect*

# Install John The Jumbo
cd $HOME/tools \
    && git clone --depth 1 https://github.com/magnumripper/JohnTheRipper.git \
    && cd JohnTheRipper/src \
    && ./configure \
    && sudo -H make -j2 install

# Install Pillow
sudo -H pip3 install --upgrade Pillow

# Install r2pipe
sudo -H pip3 install --upgrade r2pipe

# Install Frida
sudo -H pip3 install --upgrade frida

# Install ctf-tools
echo "export PATH=\$PATH:~/tools/ctf-tools/bin" >> $HOME/.bashrc
export PATH=$PATH:~/tools/ctf-tools/bin
cd $HOME/tools && git clone https://github.com/zardus/ctf-tools \
    && cd ctf-tools \
    && bin/manage-tools setup

$HOME/tools/ctf-tools/bin/manage-tools install subbrute
$HOME/tools/ctf-tools/bin/manage-tools install sqlmap
$HOME/tools/ctf-tools/bin/manage-tools install dirsearch
$HOME/tools/ctf-tools/bin/manage-tools install dirb
$HOME/tools/ctf-tools/bin/manage-tools install commix
$HOME/tools/ctf-tools/bin/manage-tools install burpsuite
$HOME/tools/ctf-tools/bin/manage-tools install exetractor
$HOME/tools/ctf-tools/bin/manage-tools install pdf-parser
$HOME/tools/ctf-tools/bin/manage-tools install peepdf
$HOME/tools/ctf-tools/bin/manage-tools install scrdec18
$HOME/tools/ctf-tools/bin/manage-tools install testdisk
$HOME/tools/ctf-tools/bin/manage-tools install cribdrag
$HOME/tools/ctf-tools/bin/manage-tools install foresight
$HOME/tools/ctf-tools/bin/manage-tools install featherduster
$HOME/tools/ctf-tools/bin/manage-tools install hashpump-partialhash
$HOME/tools/ctf-tools/bin/manage-tools install hash-identifier
$HOME/tools/ctf-tools/bin/manage-tools install littleblackbox
$HOME/tools/ctf-tools/bin/manage-tools install msieve
$HOME/tools/ctf-tools/bin/manage-tools install pemcrack
$HOME/tools/ctf-tools/bin/manage-tools install pkcrack
$HOME/tools/ctf-tools/bin/manage-tools install python-paddingoracle
$HOME/tools/ctf-tools/bin/manage-tools install reveng
$HOME/tools/ctf-tools/bin/manage-tools install sslsplit
$HOME/tools/ctf-tools/bin/manage-tools install xortool
$HOME/tools/ctf-tools/bin/manage-tools install yafu
$HOME/tools/ctf-tools/bin/manage-tools install elfkickers
$HOME/tools/ctf-tools/bin/manage-tools install xrop
$HOME/tools/ctf-tools/bin/manage-tools install evilize
$HOME/tools/ctf-tools/bin/manage-tools install checksec

# Install XSSer
sudo -H pip install --upgrade pycurl BeautifulSoup
cd $HOME/tools \
    && wget https://xsser.03c8.net/xsser/xsser_1.7-1_amd64.deb \
    && sudo -H dpkg -i xsser_1.7-1_amd64.deb \
    && rm -rf xsser*

# Install uncompyle2
cd $HOME/tools \
    && git clone https://github.com/wibiti/uncompyle2.git \
    && cd uncompyle2 \
    && sudo -H python setup.py install

sudo -H pip3 install --upgrade gmpy
sudo -H pip3 install --upgrade gmpy2
sudo -H pip3 install --upgrade numpy

# Install retdec decompiler
sudo -H pip3 install retdec-python

