#!/bin/zsh

DIR="$( cd "$( dirname "$0"  )" && pwd  )"
PROJECT_DIR="$DIR/../.."

mkdir -p ~/.local/lib/wireshark/plugins
cp $PROJECT_DIR/pulsar/pulsar_dissector.lua ~/.local/lib/wireshark/plugins/pulsar_dissector.lua
cp $PROJECT_DIR/bookkeeper/bookkeeper_dissector.lua ~/.local/lib/wireshark/plugins/bookkeeper_dissector.lua