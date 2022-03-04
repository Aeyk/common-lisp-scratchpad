(ql:quickload '(:serapeum :closer-mop :uiop :rutils :named-readtables :cl-ppcre :lisp-binary))
(defpackage #:common-lisp-user
	(:use #:cl #:rutils #:closer-mop)	
	;; (:import-from #:flexi-streams :with-output-to-sequence :with-input-from-sequence)
	;; (:import-from #:lisp-binary :defbinary :write-binary :read-binary :read-bytes :write-bytes :bit-stream)	
	(:shadowing-import-from #:rutils :toggle-print-hash-table))
(in-package #:common-lisp-user)
(named-readtables:in-readtable rutils-readtable)
(toggle-print-hash-table)

(defparameter brainfuck-command-lookup-table
	#{
	#\> #'(lambda () (incf (fill-pointer ram)))
	#\< #'(lambda () (decf (fill-pointer ram)))
	#\+ #'(lambda () (incf (aref ram (max 0 (1- (fill-pointer ram))))))
	#\+ #'(lambda () (decf (aref ram (max 0 (1- (fill-pointer ram))))))
	#\. #'(lambda () (write-byte (aref ram (1- (fill-pointer ram))) *standard-output*))
	#\, #'(lambda () (read-byte *standard-output* nil :eof))
	#\[ ;; jump-if-data-pointer-zero
	#'(lambda () (if (zerop (fill-pointer ram))
									 (setf (fill-pointer ram) (search '(#\]) program))))
	#\] ;; jump-back-if-data-pointer-not-zero
	#'(lambda () (if (not (zerop (fill-pointer ram)))
									 (setf (fill-pointer ram) (search '(#\[)  program))))
	})
(defparameter ram (make-array #xFFFF :fill-pointer #x0 :initial-element 0))
(defparameter program (eval `(make-array (length hello-world) :fill-pointer (length hello-world)
																															:initial-contents
																															hello-world)))
(defun eval-brainfuck-instruction (instruction)
	(format t "~a: ~a~%" instruction (funcall (gethash instruction brainfuck-command-lookup-table))))
(defun read-brainfuck-program-from-string (string)
	(mapcar #'char string))

(loop :for instruction :across program
			:do (eval-brainfuck-instruction instruction))

(setf (fill-pointer ram) 100) 

(mapcar #'eval-brainfuck-instruction (coerce  (fill-pointer program) 'list))


(defparameter hello-world "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")


