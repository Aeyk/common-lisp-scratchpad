(defsystem "backend-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Malik Kennedy"
  :license ""
  :depends-on ("backend"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "backend"))))
  :description "Test system for backend"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
