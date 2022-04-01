(load "/etc/default/quicklisp")
(ql:quickload '(:ningle :jonathan :clack :rutils :uiop :cffi :dexador))
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
(defvar my-keys (make-rsa-key-pair "mksybr"))
(defvar *app* (make-instance 'ningle:app))
(defvar port 5000)

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
									:|id| "http://social.mksybr.com/mksybr"
									:|type| "Person"
									:|preferredUsername| "mksybr"
									:|inbox| "http://social.mksybr.com/inbox"
									:|publicKey|
									#h( :|id| "http://social.mksybr.com/actor#main-key"
											:|owner| "http://social.mksybr.com/actor#main-key")
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
									:|links|
									#h(:|.well-known| "http://social.mksybr.com/.well-known"
											:|webfinger|  "http://social.mksybr.com/.well-known/web-finger")))))

(setf (ningle:route *app* "/.well-known/web-finger")
			#'(lambda (params)
					(setf (lack.response:response-headers ningle:*response*)
								(append (lack.response:response-headers ningle:*response*)
												(list :content-type "application/json")))
								(JONATHAN.ENCODE:TO-JSON
								 (list
									:|subject| "acct:mksybr@social.mksybr.com"
									:|links| #h(:|rel| "self"
															 :|type| "application/activity+json"
															 :|href| "http://social.mksybr.com/actor")))))


(defun deliver-json ()
	(JONATHAN.ENCODE:TO-JSON
	 (list :|@context| "https://www.w3.org/ns/activitystreams"
				 :|id| "http://social.mksybr.com/mksybr/hello-world"
				 :|type| "Create"
				 :|actor| "http://social.mksybr.com/actor"
				 :|object|
				 #h(  :|inReplyTo| "https://mastodon.social/@Gargron/100254678717223630"
							 :|id| "http://social.mksybr.com/mksybr/create-hello-world"
							 :|type| "Note"
							 :|published| (iso8601-now)
							 :|attributedTo| "http://social.mksybr.com/actor"
							 :|content| "More Automated Spam. Thanks for the sacrifice."
							:|to| "https://www.w3.org/ns/activitystreams#Public"))))

(defvar *app-handler* (clack:clackup *app* :port port))
(clack:stop *app-handler*)

(defun iso8601-now ()
	(let ((*standard-output* (make-string-output-stream)))
		(uiop:run-program "date +'%FT%R:%SZ'" :output *standard-output*)
		(string-trim '(#\Newline) (get-output-stream-string *standard-output*))))



(defun sign (private-key message)
	(let* ((echo (uiop:launch-program (uiop:strcat "echo " message) :output :stream))
				 (sign (uiop:launch-program
								(uiop:strcat (uiop:strcat "openssl dgst -sha256 -sign ") private-key)
								:input (uiop:process-info-output echo)
								:output :stream))
				 (encode (uiop:launch-program
									"openssl enc -base64"
									:input (uiop:process-info-output sign)
									:output :stream)))
		(alexandria:read-stream-content-into-string
		 (uiop:process-info-output encode))))

(sign "mksybr/private.pem" (uiop:strcat "(request-target): post /inbox
host: mastodon.social
date: " (iso8601-now)))


;; signed_string = "(request-target): post /inbox\nhost: mastodon.social\ndate: #{date}"
;; Signature: keyId="https://my-example.com/actor#main-key",headers="(request-target) host date",signature="..."
;; signature     = Base64.strict_encode64(keypair.sign(OpenSSL::Digest::SHA256.new, signed_string))
;; header        = 'keyId="https://my-example.com/actor",headers="(request-target) host date",signature="' + signature + '"'

(defvar signature (sign "mksybr/private.pem"
												(uiop:strcat "(request-target): post /inbox
host: mastodon.social
date: " (iso8601-now))))
(defvar header (uiop:strcat "keyId=\"http://social.mksybr.com/actor\",headers=\"(request-target) host date\",signature=\"" signature "\""))
;; (dex:post "https://mastodon.social/inbox" :headers '(("Host"  . "mastodon.social")
;; 																										 ("Date" . (iso8601-now))
;; 																										 ("Signature" . header))
;; 																					:content `(("Body" . ,(deliver-json))))
