(load "/etc/default/quicklisp")
(ql:quickload '(:ningle :jonathan :clack :rutils :uiop :cffi))
(in-package :rtl-user)
(named-readtables:in-readtable rutils-readtable)
(in-package :cl-user)

(defpackage :cffi-user
    (:use :common-lisp :cffi :cffi-grovel))
(in-package :cffi-user)

(load-foreign-library "/usr/lib/engines-1.1/afalg.so")
(load-foreign-library "/usr/lib/engines-1.1/capi.so")
(load-foreign-library "/usr/lib/engines-1.1/padlock.so")
(load-foreign-library "/usr/lib/libcrypto.so")
(load-foreign-library "/usr/lib/libcrypto.so.1.1")
(load-foreign-library "/usr/lib/libssl.so")
(load-foreign-library "/usr/lib/libssl.so.1.1")

(cffi:foreign-funcall "SSL_load_error_strings" :void)
(cffi:foreign-funcall "ERR_load_BIO_strings" :void)
(cffi:foreign-funcall "OpenSSL_add_all_algorithms" :void)
;; (defparameter ssl-engine
;; 	(cffi:foreign-funcall "ENGINE_new" :pointer))

;; (cffi:foreign-funcall "ENGINE_load_builtin_engines" :pointer)
;; (cffi:foreign-funcall "ENGINE_init" :pointer)
;; (cffi:foreign-funcall "ENGINE_set_default_RSA" :pointer)
;; (cffi:foreign-funcall "ENGINE_finish")
(setf ctx
	(cffi:foreign-funcall "EVP_PKEY_CTX_new_id" :int 6 :pointer (CFFI-SYS:NULL-POINTER) :pointer))
(cffi:foreign-funcall "EVP_PKEY_keygen_init" :pointer ctx :pointer)
;; # define EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, bits) \
;;         RSA_pkey_ctx_ctrl(ctx, EVP_PKEY_OP_KEYGEN, \
;;                           EVP_PKEY_CTRL_RSA_KEYGEN_BITS, bits, NULL)
;; # define EVP_PKEY_OP_KEYGEN              (1<<2)
;; # define EVP_PKEY_ALG_CTRL               0x1000
;; # define EVP_PKEY_CTRL_RSA_KEYGEN_BITS   (EVP_PKEY_ALG_CTRL + 3)
(cffi:foreign-funcall "RSA_pkey_ctx_ctrl" :pointer ctx :int (ash 1 2) :int (+ #x1003 3) :int 4096 :pointer)
(cffi:foreign-funcall "EVP_PKEY_keygen" :pointer ctx :pointer (CFFI-SYS:NULL-POINTER) :pointer)
(defvar bio)
(setq bio (cffi:foreign-funcall "EVP_PKEY_CTX_get_app_data" :pointer ctx :pointer))
(setq p (cffi:foreign-funcall "EVP_PKEY_CTX_get_keygen_info" :pointer ctx :pointer))
(cffi:foreign-funcall "BIO_write" :pointer ctx :pointer (foreign-string-alloc "*") :int 1 :pointer)

(setf *evp-pkey-rsa* 6)


(defun make-private-rsa-key (filename)
	(uiop:run-program (uiop:strcat "openssl  genpkey -algorithm RSA -out " filename)))

(defun make-public-rsa-key (private-key-filename public-key-filename)
	(uiop:run-program (uiop:strcat "openssl rsa -in " private-key-filename
																 " -outform PEM -pubout -out "
																 public-key-filename)))

(defun make-rsa-key-pair (username)
	(let ((private-key-filename (uiop:strcat username "/private.pem"))
				(public-key-filename (uiop:strcat username "/" username ".pem")))
		(ensure-directories-exist (uiop:strcat  username "/"))
		(make-private-rsa-key private-key-filename)
		(make-public-rsa-key private-key-filename public-key-filename)))

(make-rsa-key-pair "mksybr")

(defvar *app* (make-instance 'ningle:app))
(defvar port 5000)
(defvar url (rtl:strjoin "" `("http://localhost:" ,port "/")))
(defvar name "mksybr")
(setf (ning(defun private-key ()
	(let ((pkey (cffi:foreign-funcall "EVP_PKEY_new" :pointer)y))))
le:route *app* "/")
			#'(lambda (params)
					(setf (lack.response:response-headers ningle:*response*)
								(append (lack.response:response-headers ningle:*response*)
												(list :content-type "application/json")))
								(JONATHAN.ENCODE:TO-JSON
								 (list
									:|@context|
									#("https://www.w3.org/ns/activitystreams"
										"https://w3id.org/security/v1")
									:|id| "http://localhost:5000/mksybr"
									:|type| "Person"
									:|preferredUsername| "mksybr"
									:|inbox| "http://locahost:5000/inbox"
									:|publicKey|
									#h(:|id| "http://locahost:5000/actor#main-key"
											:|owner| "http://locahost:5000/actor#main-key")
									:|publicKeyPem| (rtl:read-file "mksybr/mksybr.pem")))))


(setf (ningle:route *app* "/inbox" :method :POST)
      #'(lambda (params)
					))

(setf (ningle:route *app* "/.well-known")
			#'(lambda (params)
					(setf (lack.response:response-headers ningle:*response*)
								(append (lack.response:response-headers ningle:*response*)
												(list :content-type "application/json")))
								(JONATHAN.ENCODE:TO-JSON
								 (list
									:|subject| "acct:mksybr@localhost:5000"
									:|links| #h(:|rel| "self"
															 :|type| "application/activity+json"
															 :|href| "http://localhost:5000/actor")))))


(setf (ningle:route *app* "/actor" :method :POST)
      #'(lambda (params)
         ))


(defvar *app-handler* (clack:clackup *app* :port port))
(clack:stop *app-handler*)
