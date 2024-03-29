;; vim: filetype=lisp
(asdf:defsystem #:nvlime-sbcl-test
  :description "Tests for nvlime-sbcl"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:nvlime-sbcl
               #:prove
               #:sb-cover)
  :defsystem-depends-on (#:prove-asdf)
  :components ((:module "test"
                :pathname "test"
                :components ((:file "test-with-coverage")
                             (:test-file "aio-sbcl-test"))))
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run) :prove) c)))
