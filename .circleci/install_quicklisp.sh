#!/bin/sh

curl -O https://beta.quicklisp.org/quicklisp.lisp
curl -O https://beta.quicklisp.org/quicklisp.lisp.asc
gpg --verify ./.circleci/quicklisp.lisp.asc quicklisp.lisp
ls; pwd; echo $PATH
sbcl --disable-debugger --eval "(load \"quicklisp.lisp\")"  --eval "(quicklisp-quickstart:install)"      --eval "(ql-util:without-prompting (ql:add-to-init-file))"   --eval "(ql-util:without-prompting (ql:update-all-dists))" --eval "(sb-ext:exit)"

