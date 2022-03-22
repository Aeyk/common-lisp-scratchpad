#!/bin/BASH

sbcl --disable-debugger --eval "(ql:quickload '(:fiveam))" --eval "(sb-ext:exit)"
