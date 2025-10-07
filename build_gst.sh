alias python=python3
alias pip=pip3
sudo apt-get install python3.13-venv -y
python3 -m venv ~/.venv
export PATH=~/.venv/bin:$PATH
sudo apt-get install ninja-build -y
python3 -m pip install meson
python3 -m pip install gitlint
python3 -m pip install pre-commit
export PATH=~/.local/bin:$PATH
git clone --recursive https://github.com/GStreamer/gstreamer.git
meson setup --default-library=static build
meson compile -C build
meson install -C build

