(in-package #:cl-user)
(defpackage #:nvlime-loader
  (:use #:cl))
(in-package #:nvlime-loader)


(defparameter *nvlime-home*
  (make-pathname :directory (pathname-directory *load-truename*)
                 :device (pathname-device *load-truename*)
                 ;; Issue #27: :HOST is needed for Windows XP (?) to build the correct path.
                 :host (pathname-host *load-truename*)))

(let ((load-nvlime-src (merge-pathnames (parse-namestring "load-nvlime.lisp") *nvlime-home*)))
    (load load-nvlime-src))

(defun read-port ()
  (format t "Enter a port: ")
  (force-output)
  (multiple-value-list (eval (read))))

(defun run (port)
  (loop
    :until
    (restart-case
        (progn
          (nvlime:main :port port #+allegro :backend #+allegro :nvlime-patched t))
      (choose-different-port (p)
        :report "Choose a different port"
        :interactive read-port
        (setf port p)
        nil))))

(run 7002)
