;; vim: filetype=lisp
(asdf:defsystem #:nvlime
  :description "Asynchronous Vim <-> Swank interface"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:swank
               #:alexandria
               #:yason)
  :components ((:module "src"
                :pathname "src"
                :components ((:file "nvlime")
                             (:file "nvlime-protocol"))))
  :in-order-to ((test-op (test-op #:nvlime-test))))
