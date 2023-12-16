(local window (require "nvlime.window"))
(local pwin (require "parsley.window"))
(local opts (require "nvlime.config"))
(local {: nvim_exec
        : nvim_win_set_buf
        : nvim_set_current_win
        : nvim_get_current_win
        : nvim_buf_get_name
        : nvim_win_get_buf
        : nvim_win_set_option}
       vim.api)

(local main-win-pos
       (case opts.main_window.position
         "top" "topleft"
         "left" "vertical topleft"
         "bottom" "botright"
         "right" "vertical botright"
         _ "vertical botright"))

;;; MainWin class
(local main-win
       {:pos main-win-pos
        :size opts.main_window.size
        :vert? (not= nil (and main-win-pos
                              (string.find
                                main-win-pos "^vertical")))})

;;; 
(fn main-win.new [cmd size opposite]
  (let [self (setmetatable {} {:__index main-win})
        vert? main-win.vert?]
    (tset self :id nil)
    (tset self :buffers [])
    (tset self :cmd (if vert? cmd (.. "vertical " cmd)))
    (tset self :size (when vert? size))
    (tset self :opposite opposite)
    self))

(let [sldb-height 0.65]
  (tset main-win :sldb (main-win.new "" sldb-height :repl))
  (tset main-win :repl (main-win.new "leftabove"
                                     (- 1 sldb-height) :sldb)))

(fn main-win.set-id [self winid]
  (tset self :id winid))

;;; MainWin ->
(fn main-win.set-options [self]
  (window.set-minimal-style-options self.id)
  (nvim_win_set_option self.id "foldcolumn" "1")
  (nvim_win_set_option
    self.id "winhighlight" "FoldColumn:Normal"))

;;; MainWin BufNr ->
(fn main-win.remove-buf [self bufnr]
  (each [i b (ipairs self.buffers)]
    (when (= b bufnr)
      (table.remove self.buffers i))))

;;; MainWin BufNr ->
(fn main-win.add-buf [self bufnr]
  (self:remove-buf bufnr)
  (table.insert self.buffers bufnr))

;;; MainWin ->
(fn main-win.update-opts [self]
  (let [winid (nvim_get_current_win)]
    (self:set-id winid)
    (self:add-buf (nvim_win_get_buf winid))
    (self:set-options)))

;;; MainWin BufNr ->
(fn main-win.split-opposite [self bufnr]
  (let [opposite (. main-win self.opposite)]
    (nvim_set_current_win opposite.id)
    (let [height (if (and self.size
                          (= (type self.size) "number"))
                     (math.floor
                       (* (pwin.get-height
                            opposite.id)
                         self.size))
                     "")]
      (nvim_exec
        (.. self.cmd " " height "split "
            (nvim_buf_get_name bufnr))
        false)
      (self:update-opts))))

;;; MainWin BufNr ->
(fn main-win.split [self bufnr]
  (let [bufname (nvim_buf_get_name bufnr)]
    (nvim_exec
      (.. main-win.pos " " main-win.size "split " bufname)
      false)
    (self:update-opts)))

;;; MainWin BufNr bool ->
(fn main-win.open-new [self bufnr focus?]
  (let [prev-winid (nvim_get_current_win)
        opposite (. main-win self.opposite)]
    (if (pwin.visible? opposite.id)
        (self:split-opposite bufnr)
        (self:split bufnr))
    (when (not focus?)
      (nvim_set_current_win prev-winid))))

;;; MainWin BufNr bool ->
(fn main-win.show-buf [self bufnr focus?]
  (when (not= (nvim_win_get_buf self.id) bufnr)
    (nvim_win_set_buf self.id bufnr)
    (self:add-buf bufnr))
  (when focus?
    (nvim_set_current_win self.id)))

;;; MainWin BufNr bool -> WinID
(fn main-win.open [self bufnr focus?]
  (if (pwin.visible? self.id)
      (self:show-buf bufnr focus?)
      (self:open-new bufnr focus?))
  self.id)

main-win
