(local buffer (require "nvlime.buffer"))
(local main (require "nvlime.window.main"))
(local presentations (require "nvlime.contrib.presentations"))

(local repl {})

(local +filetype+ (buffer.gen-filetype buffer.names.repl))

;;; Conn -> [string]
(fn repl-banner [conn]
  (let [data (. conn :cb_data)
        banner (.. "SWANK "
                   (if data.version
                       (.. "version " data.version ", ")
                       "")
                   (if data.pid
                       (.. "pid " data.pid ", "))
                   "remote " data.remote_host ":" data.remote_port)
        border (string.rep "=" (length banner))]
    [banner border ""]))

;;; BufNr ->
(fn clear-repl* [bufnr conn]
  (buffer.set-vars
    bufnr {:nvlime_repl_coords []})
  (buffer.fill! bufnr (repl-banner conn))
  (vim.api.nvim_buf_clear_namespace
    bufnr presentations.namespace 0 -1))

;;; BufNr {any} ->
(fn buf-callback [bufnr]
  (buffer.set-opts bufnr {:filetype +filetype+})
  (let [conn (buffer.get-conn-var! bufnr)]
    (when conn
      (clear-repl* bufnr conn))))

;;; string {any} -> [WinID BufNr]
(fn repl.open [content config]
  (let [bufnr (buffer.create-if-not-exists
                (buffer.gen-repl-name config.conn-name)
                false
                #(buf-callback $))]
    [(main.repl:open bufnr config.focus?) bufnr]))

;;; ->
(fn repl.clear []
  (let [cur-bufnr (vim.api.nvim_get_current_buf)
        conn (buffer.get-conn-var! cur-bufnr)]
    (when conn
      (let [[_ bufnr] (repl.open
                        "" {:conn-name conn.cb_data.name})]
        (clear-repl* bufnr conn)
        (vim.api.nvim_win_set_cursor main.repl.id [3 0])))))

repl
