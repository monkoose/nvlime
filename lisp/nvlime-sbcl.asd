;; vim: filetype=lisp
(asdf:defsystem #:nvlime-sbcl
  :description "Asynchronous Vim <-> Swank interface (SBCL backend)"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:nvlime
               #:sb-bsd-sockets
               #:sb-introspect
               #:vom)
  :components ((:module "src"
                :pathname "src"
                :components ((:file "nvlime-connection")
                             (:file "aio-sbcl")
                             (:file "nvlime-sbcl"
                              :depends-on ("nvlime-connection" "aio-sbcl")))))
  :in-order-to ((test-op (test-op #:nvlime-sbcl-test))))
