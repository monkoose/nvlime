(local window (require "nvlime.window"))
(local buffer (require "nvlime.buffer"))

(local server {})

(local +filetype+ (buffer.gen-filetype buffer.names.server))

;;; string -> [WinID BufNr]
(fn server.open [server-name]
  "Opens server window."
  (let [bufnr (buffer.create-nolisted
                (buffer.gen-name server-name)
                +filetype+)
        config {:height 18
                :width 100
                :noedit true
                :title (.. buffer.names.server " - " server-name)}]
    [(window.center.open bufnr [] config)
     bufnr]))

server
