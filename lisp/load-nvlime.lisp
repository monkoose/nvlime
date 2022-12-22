(in-package #:cl-user)
(when (not (find-package "NVLIME-LOADER"))
  (defpackage #:nvlime-loader
    (:use #:cl)))
(in-package #:nvlime-loader)


(require :asdf)

(defparameter *nvlime-home*
  (make-pathname :directory (pathname-directory *load-truename*)
                 :device (pathname-device *load-truename*)
                 ;; Issue #27: :HOST is needed for Windows XP (?) to build the correct path.
                 :host (pathname-host *load-truename*)))

(defun dyn-call (package sym &rest args)
  (apply (symbol-function (find-symbol sym package)) args))

(defun load-nvlime ()
  (let ((nvlime-src (merge-pathnames (parse-namestring "src/nvlime.lisp") *nvlime-home*)))
    (load nvlime-src)
    (asdf:initialize-source-registry
      `(:source-registry
         (:directory ,*nvlime-home*)
         :inherit-configuration))
    (dyn-call "NVLIME" "TRY-TO-LOAD" :nvlime)
    t))

(load-nvlime)
