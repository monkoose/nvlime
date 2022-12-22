;; vim: filetype=lisp
(asdf:defsystem #:nvlime-usocket
  :description "Asynchronous Vim <-> Swank interface (usocket backend)"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:nvlime
               #:usocket
               #:vom)
  :components ((:module "src"
                :pathname "src"
                :components ((:file "nvlime-usocket"))))
  :in-order-to ((test-op (test-op #:nvlime-test))))
