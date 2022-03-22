#!/bin/sh

sbcl --disable-debugger --eval "(ql:quickload '(:fiveam))" --eval "(sb-ext:exit)"
