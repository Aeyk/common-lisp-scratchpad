(load "/etc/default/quicklisp")
(ql:quickload '(:ningle :jonathan :clack :rutils :uiop :cffi))
(in-package :rtl-user)
(named-readtables:in-readtable rutils-readtable)
(in-package :cl-user)


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
(setf (ningle:route *app* "/actor")
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

(setf (ningle:route *app* "/.well-known/")
			#'(lambda (params)
					(setf (lack.response:response-headers ningle:*response*)
								(append (lack.response:response-headers ningle:*response*)
												(list :content-type "application/json")))
								(JONATHAN.ENCODE:TO-JSON
								 (list
									:|links|
									:|.well-known|
									#h(:|type| "application/activity+json"
											:|href| "http://localhost:5000/.well-known")))))

(setf (ningle:route *app* "/.well-known/web-finger")
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
