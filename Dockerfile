FROM archlinux:base-devel

ENV \
  UID="1000" \
  GID="1000" \
  UNAME="patovala" \
  SHELL="/bin/zsh" \
  CLR_ICU_VERSION_OVERRIDE=71.1

RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
  && sudo locale-gen \
  && sudo pacman -Sy --noprogressbar --noconfirm --needed archlinux-keyring \
  && sudo pacman -Scc \
  && sudo rm -Rf /etc/pacman.d/gnupg \
  && sudo pacman-key --init \
  && sudo pacman-key --populate archlinux

RUN pacman -Syu --noprogressbar --noconfirm --needed \
  cmake clang unzip ninja git curl wget openssh zsh reflector \
  && useradd -m -s "${SHELL}" "${UNAME}" \
  && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && sudo reflector -p https -c us --score 20 --connection-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist \
  && wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
  -o /usr/share/ca-certificates/trust-source/rds-combined-ca-bundle.pem \
  && update-ca-trust

USER patovala
WORKDIR /home/patovala/

RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -si --noprogressbar --noconfirm \
  && cd .. \
  && rm -Rf yay

# Base pacakages for neovim and terminal
RUN yay -Syu --noprogressbar --noconfirm --needed \
  python3 python-pip nodejs-lts-gallium npm clang \
  eslint_d prettier stylua git-delta github-cli \
  tmux bat fzf fd ripgrep kitty-terminfo \
  neovim neovim-remote nvim-packer-git \
  oh-my-zsh-git spaceship-prompt zsh-autosuggestions \
  ncdu glances nnn-nerd jq zoxide-git \
  && sudo pip --disable-pip-version-check install pynvim \
  && sudo npm install -g neovim wip \
  && yay -Scc --noprogressbar --noconfirm

RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
  && sudo locale-gen

RUN LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) -y
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo "PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH" >> /home/patovala/.zshrc
RUN echo "echo \"Hi! don't forget to run :PackerSync the first time you start this container\"" >> /home/patovala/.zshrc
COPY config.lua /home/patovala/.config/lvim/config.lua


ENV TZ="America/Guayaquil"
ENV TERM="xterm-256color"
