#!/bin/bash

function _cargo_usage() {
    echo "Cargo script helper"
    echo ""
    echo "./cargo.sh test   Run tests for Cargo"
}

function _cargo_install_pod() {
    echo "Install pods"
    pod install
}


function _cargo_test(){
    echo "Running tests"
    (cd `dirname $0`/..; xctool -workspace Cargo.xcworkspace -scheme Cargo build test -sdk iphonesimulator)
}

case "$1" in
    test)
        _cargo_install_pod
        _cargo_test
    ;;
    *)
        _cargo_usage
    ;;
esac
