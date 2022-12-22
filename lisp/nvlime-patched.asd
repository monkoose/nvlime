;; vim: filetype=lisp
(asdf:defsystem #:nvlime-patched
  :description "Asynchronous Vim <-> Swank interface (patched Swank)"
  :author "Kay Z. <l04m33@gmail.com>"
  :license "MIT"
  :version "0.4.0"
  :depends-on (#:nvlime)
  :components ((:module "src"
                :pathname "src"
                :components ((:file "nvlime-patched"))))
  :in-order-to ((test-op (test-op #:nvlime-test))))
