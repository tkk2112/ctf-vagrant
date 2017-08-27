#!/bin/bash -x

if [ "$EUID" -ne 0 ]; then
    HOMEDIR=/home/ubuntu
    run_sudo="sudo -H"
else
    run_sudo=
    HOMEDIR=/root
fi

cd $HOMEDIR
mkdir tools
cd tools

DEBIAN_FRONTEND=noninteractive
$run_sudo rm -rf /var/lib/apt/lists/*

# Installing the 'apt-utils' package gets rid of the 'debconf: delaying package configuration, since apt-utils is not installed'
# error message when installing any other package with the apt package manager.
$run_sudo apt-get update && $run_sudo apt-get install -y --no-install-recommends \
    apt-utils \
    && $run_sudo rm -rf /var/lib/apt/lists/*

$run_sudo dpkg-reconfigure -u apt-utils

$run_sudo apt-get update && $run_sudo apt-get upgrade -y -o Dpkg::Options::="--force-confold"
$run_sudo apt-get install -y \
    build-essential \
    curl \
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
    tmux \
    tree \
    virtualenvwrapper \
    wget \
    silversearcher-ag \
    unzip \
    cmake \
    net-tools \
    clang \
    llvm \
    libtool-bin \
    squashfs-tools \
    zlib1g-dev liblzma-dev python-magic \
    libtool automake bison libglib2.0-dev \
    steghide \
    pngtools \
    outguess \
    exif \
    exiv2 \
    imagemagick \
    wamerican \
    python-imaging \
    libjpeg8 libjpeg62-dev libfreetype6 libfreetype6-dev \
    dsniff foremost texinfo subversion \
    pandoc libxml2-dev libxslt1-dev libcurl4-openssl-dev python-gmpy \
    tofrodos libsqlite3-dev libpcap-dev libgmp3-dev libevent-dev \
    autotools-dev libreadline-dev libncurses5-dev \
    gdb \
    gdb-multiarch \
    gdbserver \
    nmap zmap masscan \
    aircrack-ng samdump2 bkhive \
    ophcrack

echo "export WORKON_HOME=~/.virtualenvs" >> $HOMEDIR/.bashrc
echo "export PROJECT_HOME=~/.vewdevel" >> $HOMEDIR/.bashrc
echo "export VIRTUALENVWRAPPER_SCRIPT=/usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> $HOMEDIR/.bashrc
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper_lazy.sh" >> $HOMEDIR/.bashrc

# Install pwndbg
cd $HOMEDIR/tools
git clone https://github.com/zachriggle/pwndbg
cd pwndbg
if [ "$EUID" -ne 0 ]; then
    ./setup.sh
else
    sed 's/sudo//g' setup.sh > non_sudo_setup.sh
    chmod +x non_sudo_setup.sh
    ./non_sudo_setup.sh
fi
cd $HOMEDIR/tools/pwndbg/capstone/bindings/python
$run_sudo /usr/bin/python -m pip install --target /usr/local/lib/python2.7/dist-packages .
cd $HOMEDIR/tools/pwndbg/unicorn/bindings/python
$run_sudo /usr/bin/python -m pip install --target /usr/local/lib/python2.7/dist-packages .

$run_sudo pip install --upgrade pip
$run_sudo pip install --upgrade ipython
$run_sudo pip install --upgrade angr
$run_sudo pip install --upgrade pwntools

# Install radare2
cd $HOMEDIR/tools \
    && git clone https://github.com/radare/radare2 \
    && cd radare2 \
    && ./sys/install.sh \
    && $run_sudo make symstall

# Install qemu
$run_sudo apt-get -y install qemu qemu-user qemu-user-static
$run_sudo apt-get -y install 'binfmt*'
$run_sudo apt-get -y install libc6-armhf-armel-cross
$run_sudo apt-get -y install debian-keyring
$run_sudo apt-get -y install debian-archive-keyring
$run_sudo apt-get -m update; echo 0 # Always success from update
$run_sudo apt-get -y install libc6-mipsel-cross
$run_sudo apt-get -y install libc6-armel-cross libc6-dev-armel-cross
$run_sudo apt-get -y install libc6-armhf-cross libc6-dev-armhf-cross
$run_sudo apt-get -y install binutils-arm-linux-gnueabi
$run_sudo apt-get -y install libncurses5-dev
$run_sudo mkdir /etc/qemu-binfmt
$run_sudo ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel
$run_sudo ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
$run_sudo apt-get update

# Install binwalk
cd $HOMEDIR/tools \
    && git clone https://github.com/devttys0/binwalk \
    && cd binwalk \
    && $run_sudo python setup.py install \

# Install firmware-mod-kit
cd $HOMEDIR/tools \
    && wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/firmware-mod-kit/fmk_099.tar.gz \
    && tar zxvf fmk_099.tar.gz \
    && rm fmk_099.tar.gz \
    && cd fmk/src \
    && ./configure \
    && make

# Install AFL with QEMU and clang-fast
cd $HOMEDIR/tools \
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
    && $run_sudo make install \
    && cd $HOMEDIR/tools \
    && rm -rf clang*

$run_sudo dpkg --add-architecture i386
$run_sudo apt-get update
$run_sudo apt-get -y install libc6:i386 libncurses5:i386 libstdc++6:i386 libc6-dev-i386

# Install apktool
$run_sudo apt-get update \
    && $run_sudo apt-get install -y default-jre \
    && wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool \
    && wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.2.jar \
    && $run_sudo mv apktool_2.0.2.jar /bin/apktool.jar \
    && $run_sudo mv apktool /bin/ \
    && $run_sudo chmod 755 /bin/apktool \
    && $run_sudo chmod 755 /bin/apktool.jar

# Install dotfiles
cd $HOMEDIR \
    && git clone https://github.com/tkk2112/dotfiles.git \
    && cd dotfiles \
    && ./install.sh


# Install stegdetect/stegbreak
wget http://old-releases.ubuntu.com/ubuntu/pool/universe/s/stegdetect/stegdetect_0.6-6_amd64.deb \
    && $run_sudo dpkg -i stegdetect_0.6-6_amd64.deb \
    && rm -rf stegdetect*

# Install John The Jumbo
cd $HOMEDIR/tools \
    && git clone --depth 1 https://github.com/magnumripper/JohnTheRipper.git \
    && cd JohnTheRipper/src \
    && ./configure \
    && $run_sudo make -j2 install

# Install Pillow
$run_sudo pip install Pillow

# Install r2pipe
$run_sudo pip install --upgrade r2pipe

# Install Frida
$run_sudo pip install --upgrade frida

# Install ctf-tools
cd $HOMEDIR/tools && git clone https://github.com/zardus/ctf-tools \
    && cd ctf-tools \
    && bin/manage-tools setup
$HOMEDIR/tools/ctf-tools/bin/manage-tools install subbrute
$HOMEDIR/tools/ctf-tools/bin/manage-tools install sqlmap
$HOMEDIR/tools/ctf-tools/bin/manage-tools install dirsearch
$HOMEDIR/tools/ctf-tools/bin/manage-tools install dirb
$HOMEDIR/tools/ctf-tools/bin/manage-tools install commix
$HOMEDIR/tools/ctf-tools/bin/manage-tools install burpsuite
$HOMEDIR/tools/ctf-tools/bin/manage-tools install exetractor
$HOMEDIR/tools/ctf-tools/bin/manage-tools install pdf-parser
$HOMEDIR/tools/ctf-tools/bin/manage-tools install peepdf
$HOMEDIR/tools/ctf-tools/bin/manage-tools install scrdec18
$HOMEDIR/tools/ctf-tools/bin/manage-tools install testdisk
$HOMEDIR/tools/ctf-tools/bin/manage-tools install cribdrag
$HOMEDIR/tools/ctf-tools/bin/manage-tools install foresight
$HOMEDIR/tools/ctf-tools/bin/manage-tools install featherduster
$HOMEDIR/tools/ctf-tools/bin/manage-tools install hashpump-partialhash
$HOMEDIR/tools/ctf-tools/bin/manage-tools install hash-identifier
$HOMEDIR/tools/ctf-tools/bin/manage-tools install littleblackbox
$HOMEDIR/tools/ctf-tools/bin/manage-tools install msieve
$HOMEDIR/tools/ctf-tools/bin/manage-tools install pemcrack
$HOMEDIR/tools/ctf-tools/bin/manage-tools install pkcrack
$HOMEDIR/tools/ctf-tools/bin/manage-tools install python-paddingoracle
$HOMEDIR/tools/ctf-tools/bin/manage-tools install reveng
$HOMEDIR/tools/ctf-tools/bin/manage-tools install sslsplit
$HOMEDIR/tools/ctf-tools/bin/manage-tools install xortool
$HOMEDIR/tools/ctf-tools/bin/manage-tools install yafu
$HOMEDIR/tools/ctf-tools/bin/manage-tools install elfkickers
$HOMEDIR/tools/ctf-tools/bin/manage-tools install xrop
$HOMEDIR/tools/ctf-tools/bin/manage-tools install evilize
$HOMEDIR/tools/ctf-tools/bin/manage-tools install checksec

# Install XSSer
$run_sudo pip install pycurl BeautifulSoup
cd $HOMEDIR/tools \
    && wget http://xsser.03c8.net/xsser/xsser_1.7-1_amd64.deb \
    && $run_sudo dpkg -i xsser_1.7-1_amd64.deb \
    && rm -rf xsser*

# Install w3af
$run_sudo pip install clamd==1.0.1 PyGithub==1.21.0 GitPython==0.3.2.RC1 pybloomfiltermmap==0.3.14 \
        esmre==0.3.1 phply==0.9.1 nltk==3.0.1 pdfminer==20140328 \
        pyOpenSSL==0.15.1 scapy-real==2.2.0-dev guess-language==0.2 cluster==1.1.1b3 \
        python-ntlm==1.0.1 halberd==0.2.4 darts.util.lru==0.5 \
        ndg-httpsclient==0.3.3 Jinja2==2.7.3 \
        vulndb==0.0.17 markdown==2.6.1 mitmproxy==0.12.1 \
        ruamel.ordereddict==0.4.8 Flask==0.10.1 PyYAML==3.11
cd $HOMEDIR/tools \
    && git clone https://github.com/andresriancho/w3af.git \
    && cd w3af \
    && ./w3af_console ; true \
    && sed 's/apt-get/apt-get -y/g' -i /tmp/w3af_dependency_install.sh \
    && sed 's/pip install/pip install --upgrade/g' -i /tmp/w3af_dependency_install.sh \
    && $run_sudo /tmp/w3af_dependency_install.sh

# Install uncompyle2
cd $HOMEDIR/tools \
    && git clone https://github.com/wibiti/uncompyle2.git \
    && cd uncompyle2 \
    && $run_sudo python setup.py install


# Install retdec decompiler
$run_sudo apt-get -y install python3-pip
$run_sudo pip3 install retdec-python
