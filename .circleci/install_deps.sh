#!/bin/sh

sbcl --disable-debugger --eval "(ql:quickload '(:fiveam :roswell))" --eval "(sb-ext:exit)"
