FROM ubuntu:16.04
LABEL description="VNC server + Google Chrome + ruby"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:brightbox/ruby-ng \
  && apt-get update \
  && echo DEBIAN_FRONTEND is needed: https://askubuntu.com/questions/876240/how-to-automate-setting-up-of-keyboard-configuration-package \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xfce4-goodies xdotool ruby2.5 ruby2.5-dev build-essential wget

RUN ( \
    cd $(mktemp -d) \
    && wget -O tigervnc.deb https://bintray.com/tigervnc/stable/download_file?file_path=ubuntu-16.04LTS%2Famd64%2Ftigervncserver_1.7.0-1ubuntu1_amd64.deb \
    && (dpkg -i tigervnc.deb || echo ignore error) \
    && apt-get install -f -y \
  ) \
  && ( \
    cd $(mktemp -d) \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && (dpkg -i google-chrome*.deb || echo ignore error) \
    && apt --fix-broken install -y \
  ) \
  && gem install bundler \
  && rm -rf /tmp/*

RUN ( \
    echo close xfce4 first prompt \
    && export DISPLAY=:1.0 \
    && /usr/bin/tigervncserver -SecurityTypes None \
    && sleep 10 \
    && xdotool windowactivate $(xdotool search --onlyvisible --classname "Migrate") \
    && xdotool key Return \
    && /usr/bin/tigervncserver -kill :1 \
  )

RUN ( \
    echo close Chrome first prompt \
    && export DISPLAY=:1.0 \
    && /usr/bin/tigervncserver -SecurityTypes None \
    && sleep 10 \
    && (timeout 10 google-chrome --no-sandbox || echo killed by timeout command) \
    && /usr/bin/tigervncserver -kill :1 \
  )

