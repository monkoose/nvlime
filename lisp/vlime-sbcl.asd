;; vim: filetype=lisp
(asdf:defsystem #:vlime-sbcl
  :description "Asynchronous Vim <-> Swank interface (SBCL backend)"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :depends-on (#:sb-bsd-sockets
               #:sb-introspect
               #:yason
               #:swank
               #:vom)
  :components ((:module "src"
                :pathname "src"
                :components ((:file "vlime-protocol")
                             (:file "vlime-connection")
                             (:file "aio-sbcl")
                             (:file "vlime-sbcl" :depends-on ("vlime-protocol" "aio-sbcl")))))
  :in-order-to ((test-op (test-op #:vlime-test))))