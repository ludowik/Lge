echo version = \'$(date)\' > engine/version.lua
echo zip -u -1 -r build/lge.love . -x *.git* *.DS_Store* lge.love __archive/\\*
makelove --version
makelove --config build/makelove.toml
