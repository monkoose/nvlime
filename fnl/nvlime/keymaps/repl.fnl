(local km (require "nvlime.keymaps"))
(local rm km.mappings.repl)
(local buffer (require "nvlime.buffer"))
(local presentations (require "nvlime.contrib.presentations"))
(local repl-win (require "nvlime.window.main.repl"))
(local ut (require "nvlime.utilities"))
(local {: nvim_buf_line_count}
       vim.api)

(local repl {})

;;; {any} LineNr -> ?{any}
(fn prev-or-current-coord [coords linenr]
  (when (> linenr 0)
    (let [coord (. coords linenr)]
      (if coord
          coord
          (prev-or-current-coord coords (- linenr 1))))))

;;; {any} LineNr Col -> ?{any}
(fn prev-coord [coords linenr col]
  (let [coord (prev-or-current-coord coords linenr)]
    (if (and coord (ut.in-coord-range? coord linenr col))
        (prev-or-current-coord
          coords (- (. coord :begin 1) 1))
        coord)))

;;; {any} LineNr LineNr -> ?{any}
(fn next-coord [coords linenr max-linenr]
  (let [lnr (+ linenr 1)]
    (when (>= max-linenr lnr)
      (let [coord (. coords lnr)]
        (if coord
            coord
            (next-coord coords lnr max-linenr))))))

(fn jump-to-coord [backward?]
  (let [[linenr col] (ut.get-win-cursor 0)
        jump (fn [coord]
               (if coord
                   (ut.set-win-cursor 0 [(. coord :begin 1)
                                         (. coord :begin 2)])
                   (ut.echo "No more presented objects.")))]
    (if backward?
        (jump (prev-coord presentations.coords linenr col))
        (let [max-linenr (nvim_buf_line_count 0)]
          (jump (next-coord presentations.coords
                            linenr max-linenr))))))

;;; {any} LineNr Col bool -> ?{any}
(fn find-coord [coords linenr col]
  (let [coord (prev-or-current-coord coords linenr)]
    (when (and coord (ut.in-coord-range? coord linenr col))
      coord)))

(fn do-cur-presentation [func]
  (if (not (vim.tbl_contains vim.b.nvlime_conn.cb_data.contribs
                             "SWANK-PRESENTATIONS"))
      (ut.echo-error "SWANK-PRESENTATIONS is not available.")
      (let [[linenr col] (ut.get-win-cursor 0)
            coord (find-coord presentations.coords linenr col true)]
        (if (and coord (= (. coord :type) "PRESENTATION"))
            (func coord)
            (ut.echo-warning "Not on a presented object.")))))

(fn yank-cur-presentation []
  (do-cur-presentation
    (fn [coord]
      (vim.fn.setreg "\""
                     (.. "(swank:lookup-presented-object "
                         (. coord :id) ")"))
      (ut.echo (.. "Presented object " (. coord :id) " yanked.")))))

(fn inspect-cur-presentation []
  (do-cur-presentation
    (fn [coord]
      ;; TODO: rewrite when `Conn` will be converted to fennel
      (buffer.vim-call!
        0 [(.. "call b:nvlime_conn.InspectPresentation("
               (. coord :id) ", v:true, "
               "{c, r -> c.ui.OnInspect(c, r, v:null, v:null)})")]))))

(fn repl.add []
  (km.buffer.normal rm.normal.interrupt
                    "<Cmd>call b:nvlime_conn.Interrupt({'name': 'REPL-THREAD', 'package': 'KEYWORD'})<CR>"
                    "nvlime: Interrupt the REPL thread")
  (km.buffer.normal rm.normal.clear
                    #(repl-win.clear)
                    "nvlime: Clear the REPL buffer")
  (km.buffer.normal rm.normal.inspect_result
                    inspect-cur-presentation
                    "nvlime: Insect the evaluation result under the cursor")
  (km.buffer.normal rm.normal.yank_result
                    yank-cur-presentation
                    "nvlime: Yank the evaluation result under the cursor")
  (km.buffer.normal rm.normal.next_result
                    #(jump-to-coord)
                    "nvlime: Move the cursor to the next presented object")
  (km.buffer.normal rm.normal.prev_result
                    #(jump-to-coord true)
                    "nvlime: Move the cursor to the next presented object"))

repl
