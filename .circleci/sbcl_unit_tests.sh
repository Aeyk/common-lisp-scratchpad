#!/usr/bin/env -S sbcl --script
(load "~/.sbclrc")
(ql:quickload '(:fiveam))

(in-package :cl-user)
(defpackage system-test
  (:use :cl
        :fiveam))

(in-package :system-test)

(test simple-maths
      (is (= 3 (+ 1 1))
          "Maths should work, right? ~a. Another parameter is: ~S" t :foo))

(run!)
