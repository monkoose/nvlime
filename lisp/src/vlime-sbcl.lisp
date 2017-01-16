(in-package #:cl-user)

(defpackage #:vlime-sbcl
  (:use #:cl
        #:aio-sbcl
        #:vlime-protocl
        #:vlime-connection)
  (:export #:main
           #:main-threaded))

(in-package #:vlime-sbcl)


(defparameter +cr-lf+ (format nil "~c~c" #\return #\linefeed))
(defparameter +cr+ (format nil "~c" #\return))
(defparameter +lf+ (format nil "~c" #\linefeed))


(defun socket-error-cb (afd condition)
  (declare (ignore afd))
  (handler-case (error condition)
    (aio-error ()
      (let* ((afd (aio-error-afd condition))
             (conn (lookup-connection afd)))
        (aio-fd-close afd)
        (aio-fd-close (connection-socket (connection-peer conn)))
        (connection-close conn)
        (vom:debug "Connection count: ~s" (count-connections))))
    (error ()
      (vom:debug "Socket event: ~a" condition))))


(defun client-connect-cb (afd)
  (unless (lookup-connection afd)
    (make-connection :socket afd)
    (vom:debug "New connection from ~s" afd)
    (vom:debug "Connection count: ~s" (count-connections)))
  (aio-fd-disable-write-handle afd :clear-cb t))


(defun swank-read-cb (afd data)
  (let ((swank-conn (lookup-connection afd)))
    (multiple-value-bind (msg-list buffered)
                         (parse-swank-msg
                           data (connection-read-buffer swank-conn))
      (setf (connection-read-buffer swank-conn) buffered)
      (when msg-list
        (dolist (msg msg-list)
          (vom:debug "Message from SWANK: ~s" msg)
          (aio-fd-write (connection-socket (connection-peer swank-conn))
                        (babel:string-to-octets (msg-swank-to-client msg))))))))


(defun client-read-cb (afd data swank-host swank-port)
  (let ((client-conn (lookup-connection afd)))
    (multiple-value-bind (line-list buffered)
                         (parse-line
                           data (connection-read-buffer client-conn))
      (setf (connection-read-buffer client-conn) buffered)
      (when line-list
        (ensure-peer-connection
          client-conn
          #'(lambda ()
              (tcp-connect swank-host swank-port
                           :read-cb #'swank-read-cb
                           :error-cb #'socket-error-cb)))
        (dolist (line line-list)
          (vom:debug "Message from ~s: ~s" afd line)
          (when (and (string/= line +cr-lf+)
                     (string/= line +cr+)
                     (string/= line +lf+))
            (aio-fd-write (connection-socket (connection-peer client-conn))
                          (babel:string-to-octets (msg-client-to-swank line)))))))))


(defun main (host port swank-host swank-port)
  (vom:config t :debug)
  (setf vlime-connection:*connections* (make-hash-table))
  (setf aio-sbcl:*fd-map* (make-hash-table))
  (setf aio-sbcl:*static-buffer* (make-array 4096 :element-type '(unsigned-byte 8)))

  (let ((server (tcp-server
                  host port
                  :client-read-cb #'(lambda (afd data)
                                      (client-read-cb
                                        afd data
                                        swank-host swank-port))
                  :client-write-cb #'client-connect-cb
                  :client-error-cb #'socket-error-cb)))
    (vom:debug "Server created: ~s" server)
    server))


;; --------- Threaded blocking server implementation ---------


(defun server-listener (socket swank-host swank-port)
  (vom:debug "Server created: ~s" socket)
  (loop
    (let ((client-socket (sb-bsd-sockets:socket-accept socket)))
      (swank/backend:spawn
        #'(lambda ()
            (vlime-control-thread
              client-socket swank-host swank-port))))))


(defun vlime-control-thread (client-socket swank-host swank-port)
  (vom:debug "New client: ~s" client-socket)
  (let* ((read-buffer (make-array 4096 :element-type '(unsigned-byte 8)))
         (control-thread (swank/backend:current-thread))
         (swank-socket
           (make-instance 'sb-bsd-sockets:inet-socket
                          :type :stream :protocol :tcp)))
    (sb-bsd-sockets:socket-connect swank-socket swank-host swank-port)
    (labels ((read-loop (socket data-msg eof-msg)
               (loop
                 (multiple-value-bind
                     (data data-len peer-host peer-port)
                     (sb-bsd-sockets:socket-receive socket read-buffer nil)
                   (declare (ignore peer-host peer-port))
                   (if (or (not data) (not data-len) (<= data-len 0))
                     (swank/backend:send control-thread `(,eof-msg))
                     (swank/backend:send
                       control-thread `(,data-msg ,(subseq data 0 data-len)))))))
             (client-read-loop () (read-loop client-socket :client-data :client-eof))
             (swank-read-loop () (read-loop swank-socket :swank-data :swank-eof)))

      (let ((client-read-thread (swank/backend:spawn #'client-read-loop))
            (swank-read-thread (swank/backend:spawn #'swank-read-loop))
            (client-read-buffer #())
            (swank-read-buffer #()))
        (loop
          (let ((msg (swank/backend:receive)))
            (ecase (car msg)
              (:client-data
                (vom:debug "client-data msg")
                (multiple-value-bind (line-list buffered)
                                     (parse-line (nth 1 msg) client-read-buffer)
                  (setf client-read-buffer buffered)
                  (when line-list
                    (dolist (line line-list)
                      (vom:debug "Message from ~s: ~s" client-socket line)
                      (when (and (string/= line +cr-lf+)
                                 (string/= line +cr+)
                                 (string/= line +lf+))
                        (sb-bsd-sockets:socket-send
                          swank-socket
                          (babel:string-to-octets (msg-client-to-swank line))
                          nil))))))

              (:swank-data
                (vom:debug "swank-data msg")
                (multiple-value-bind (msg-list buffered)
                                     (parse-swank-msg (nth 1 msg) swank-read-buffer)
                  (setf swank-read-buffer buffered)
                  (when msg-list
                    (dolist (msg msg-list)
                      (vom:debug "Message from SWANK: ~s" msg)
                      (sb-bsd-sockets:socket-send
                        client-socket
                        (babel:string-to-octets (msg-swank-to-client msg))
                        nil)))))

              ((:exit :client-eof :swank-eof)
                (vom:debug "EOF: ~s" msg)
                (swank/backend:kill-thread swank-read-thread)
                (swank/backend:kill-thread client-read-thread)
                (sb-bsd-sockets:socket-close swank-socket)
                (sb-bsd-sockets:socket-close client-socket)
                (return-from vlime-control-thread)))))))))


(defun main-threaded (host port swank-host swank-port)
  (vom:config t :debug)
  (let ((server-socket
          (make-instance 'sb-bsd-sockets:inet-socket
                         :type :stream :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address server-socket) t)
    (sb-bsd-sockets:socket-bind server-socket host port)
    (sb-bsd-sockets:socket-listen server-socket 128)
    (swank/backend:spawn
      #'(lambda ()
          (server-listener server-socket swank-host swank-port)))))
