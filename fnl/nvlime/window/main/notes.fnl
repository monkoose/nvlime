(local buffer (require "nvlime.buffer"))
(local sldb (. (require "nvlime.window.main") :sldb))
(local psl (require "parsley"))
(local {: nvim_create_autocmd
        : nvim_win_get_buf
        : nvim_create_augroup}
       vim.api)

(local notes {})

(local +name+ "notes")
(local +filetype+ (buffer.gen-filetype +name+))

;;; BufNr ->
(fn remove-notes [bufnr]
  (sldb:remove-buf bufnr)
  (when (and (= (nvim_win_get_buf sldb.id) bufnr)
             (not (psl.empty? sldb.buffers)))
    ;; defer_fn requires to fix main windows resizing.
    ;; It happends because calculation of the height of a new window
    ;; happens before old one really closed (thats how `WinClosed` works).
    ;; It adds some visual flickering so maybe there is a better way to fix it
    (vim.defer_fn
      #(sldb:open-new (. sldb.buffers (length sldb.buffers)) true)
      0)))

;;; WinID BufNr ->
(fn win-callback [winid bufnr]
  (let [group (nvim_create_augroup +filetype+ {})]
    (nvim_create_autocmd "WinClosed"
      {:group group
       :pattern (tostring winid)
       :nested true
       :callback #(remove-notes bufnr)})))

;;; -> [WinID BufNr]
(fn notes.open [config]
  "Opens compiler notes window."
  (let [bufnr (buffer.create-nolisted
                (buffer.gen-name
                   config.conn-name (.. "compiler-" +name+))
                +filetype+)]
    (let [winid (sldb:open bufnr true)]
      (win-callback winid bufnr)
      [winid bufnr])))

notes
