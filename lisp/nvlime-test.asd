;; vim: filetype=lisp
(asdf:defsystem #:nvlime-test
  :description "Tests for nvlime"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:nvlime
               #:prove
               #+sbcl #:sb-cover)
  :defsystem-depends-on (#:prove-asdf)
  :components ((:module "test"
                :pathname "test"
                :components (#+sbcl (:file "test-with-coverage")
                             (:test-file "nvlime-protocol-test"))))
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run) :prove) c)))
