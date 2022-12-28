(import-macros {: return} "nvlime.init-macros")
(local buffer (require "nvlime.buffer"))
(local ut (require "nvlime.utilities"))
(local psl-buf (require "parsley.buffer"))
(local psl-win (require "parsley.window"))
(local options (require "nvlime.config"))

(local window {:cursor {} :center {}})

(local +scrollbar-bufname+ (buffer.gen-name "scrollbar"))
(var *focus-winid* 1000)

;;; [FileType] -> ?(true WinID)
(fn visible-ft? [filetypes]
  "Checks if any window in the current tabpage shows
  a buffer with any of specified `filetypes`."
  (each [_ winid (ipairs (vim.api.nvim_tabpage_list_wins 0))]
    (let [bufnr (vim.api.nvim_win_get_buf winid)
          buf-ft (psl-buf.filetype bufnr)]
      (each [_ ft (ipairs filetypes)]
        (when (= buf-ft ft)
          (return true winid))))))

;;; WinID {any} ->
(fn window.set-opts [winid opts]
  "Set window local options from the hash table where
  key - option name, value - option value."
  (each [opt val (pairs opts)]
    (vim.api.nvim_win_set_option winid opt val)))

;;; WinID ->
(fn window.set-minimal-style-options [winid]
  "Sets preconfigured window options."
  (window.set-opts
    winid {:wrap true
           :number false
           :relativenumber false
           :spell false
           :list false
           :signcolumn "no"}))

;;; integer integer integer -> (bool integer)
(fn window.find-horiz-pos [req-height scr-row scr-height]
  (let [border-len 3
        bot-height (- scr-height scr-row border-len)
        top-height (- scr-row border-len)
        bottom? (or (> bot-height req-height)
                    (> bot-height top-height))]
    (if bottom?
        (values true (math.min bot-height req-height))
        (values false (math.min top-height req-height)))))

;;; WinID (fn [{any}] {any}) {any} ?bool ->
(fn window.update-win-options [winid opts ?focus?]
  "Updates window options"
  (vim.api.nvim_win_set_cursor winid [1 0])
  (when (psl-win.floating? winid)
    (vim.api.nvim_win_set_config winid opts))
  (when ?focus?
    (vim.api.nvim_set_current_win winid)))

;;; WinID -> bool
(fn win-buf-nvlime-ft? [winid]
  "Checks if window with `winid` has buffer with
  one of nvlime filetypes."
  (let [pattern "nvlime_"]
    (string.find (psl-win.filetype winid) pattern)))

;;; WinID -> bool
(fn main-win? [winid]
  "Checks if window with `winid` is main plugin window."
  (each [_ ft (ipairs ["nvlime_repl"
                       "nvlime_sldb"
                       "nvlime_notes"])]
    (when (= (psl-win.filetype winid) ft)
      (return true))))

;;; (fn [WinID] bool) ->
(fn window.close-when [predicate]
  "Closes all windows in the current tabpage that meet the `predicate`."
  (each [_ winid (ipairs (vim.api.nvim_tabpage_list_wins 0))]
    (when (predicate winid)
      (vim.api.nvim_win_close winid true))))

;;; ->
(fn window.close_all []
  "Closes all plugin's windows."
  (window.close-when #(win-buf-nvlime-ft? $)))

;;; ->
(fn window.close_all_except_main []
  "Closes all plugin's windows except main ones."
  (window.close-when #(and (win-buf-nvlime-ft? $)
                           (not (main-win? $)))))

;;; -> ?WinID
(fn window.last-float []
  "Returns winid of the last opened floating window."
  (let [win-list (vim.api.nvim_tabpage_list_wins 0)]
    (table.sort win-list #(> $1 $2))
    (each [_ winid (ipairs win-list)]
      (when (and (psl-win.floating? winid)
                 (not (pcall
                        vim.api.nvim_win_get_var
                        winid "nvlime_scrollbar")))
        (return winid)))))

;;; -> ?WinID
(fn window.last-float-except-current []
  "Returns winid of the last opened floating window except
  if it is current window."
  (let [float-id (window.last-float)]
    (if (= float-id (vim.api.nvim_get_current_win))
        nil
        float-id)))

;;; -> ?WinID
(fn window.close_last_float []
  "Closes last opened floating window (unless it is current window)
  and returns its id. Returns nil if such window wasn't found."
  ;; Last opened window always has the highest winid.
  ;; 'nvim_tabpage_list_wins' isnot sorted, so it should be sorted first
  ;; or just get the maximum of the found winids.
  (let [last-float-winid (window.last-float-except-current)]
    (when last-float-winid
      (vim.api.nvim_win_close last-float-winid true)
      last-float-winid)))

;;; integer bool ->
(fn window.scroll_float [step reverse?]
  "Scrolls last opened floating window by `step` lines."
  (let [last-float-winid (window.last-float-except-current)]
    (when last-float-winid
      (let [wininfo (psl-win.get-info last-float-winid)
            old-scrolloff (vim.api.nvim_win_get_option
                            last-float-winid "scrolloff")
            set-float-cursor #(vim.api.nvim_win_set_cursor
                          last-float-winid [$1 0])]
        (vim.api.nvim_win_set_option last-float-winid "scrolloff" 0)
        (if reverse?
            (let [expected-line (- wininfo.topline step)]
              (if (< expected-line 1)
                  (set-float-cursor 1)
                  (set-float-cursor expected-line)))
            (let [expected-line (+ wininfo.botline step)
                  last-line (vim.api.nvim_buf_line_count
                              (vim.api.nvim_win_get_buf last-float-winid))]
              (if (> expected-line last-line)
                  (set-float-cursor last-line)
                  (set-float-cursor expected-line))))
        (vim.api.nvim_win_set_option last-float-winid "scrolloff" old-scrolloff))
      last-float-winid)))

;;; WinID BufNr string -> WinID
(fn window.split [winid bufnr cmd]
  "Splits window with `winid` with `cmd` command and
  sets buffer number of a new split window to `bufnr`.
  Returns new split window id."
  (let [bufhidden (vim.api.nvim_buf_get_option
                    bufnr "bufhidden")]
    (buffer.set-opts bufnr {:bufhidden "hide"})
    (vim.api.nvim_set_current_win winid)
    (vim.api.nvim_exec
      (.. cmd " " (vim.api.nvim_buf_get_name bufnr))
      false)
    (buffer.set-opts bufnr {:bufhidden bufhidden})
    (vim.api.nvim_get_current_win)))

;;; string -> ?WinID
(fn window.split_focus [cmd]
  "Splits focus window."
  (if (psl-win.visible? *focus-winid*)
      (window.split *focus-winid*
                    (vim.api.nvim_get_current_buf)
                    cmd)
      (ut.echo "Can't split this window.")))

;;; ========== SCROLLBAR ==========

;;; char -> BufNr
(fn create-scrollbar-buffer [icon]
  (match (psl-buf.exists? +scrollbar-bufname+)
    (true bufnr) bufnr
    _ (let [bufnr (buffer.create +scrollbar-bufname+)]
        (buffer.fill!
          bufnr (fcollect [_ 1 100] icon))
        bufnr)))

;;; {any} integer -> bool
(fn scrollbar-required? [wininfo content-height]
  (< wininfo.height content-height))

;;; {any} integer -> integer
(fn calc-scrollbar-height [wininfo content-height]
  (math.max
    (math.floor
      (* (/ wininfo.height content-height)
         wininfo.height))
    1))

;;; {any} integer integer -> integer
(fn calc-scrollbar-offset [wininfo buf-height scrollbar-height]
  (math.min
    (- wininfo.height scrollbar-height)
    (math.ceil (* (/ (- wininfo.topline 1)
                     buf-height)
                  wininfo.height))))

;;; TODO should be correct when lines are wrapped
;;; {any} integer -> WinID
(fn add-scrollbar [wininfo zindex]
  "Attaches scrollbar to window with `wininfo.winid`.
  Returns winid of the scrollbar."
  (var scrollbar-winid -1)
  (let [scrollbar-bufnr (create-scrollbar-buffer "▌")
        pattern (tostring wininfo.winid)
        close-scrollbar #(when (psl-win.visible? scrollbar-winid)
                           (vim.api.nvim_win_close scrollbar-winid true))
        callback
        #(let [info (psl-win.get-info wininfo.winid)
               content-height (vim.api.nvim_buf_line_count info.bufnr)]
           (if (and (psl-win.floating? info.winid)
                    (scrollbar-required? info content-height))
               (let [scrollbar-height (calc-scrollbar-height info content-height)
                     scrollbar-offset (calc-scrollbar-offset
                                        info content-height scrollbar-height)]
                 (if (psl-win.visible? scrollbar-winid)
                     (vim.api.nvim_win_set_config
                       scrollbar-winid
                       {:relative "win"
                        :win info.winid
                        :height scrollbar-height
                        :row scrollbar-offset
                        :col info.width})
                     (do
                       (set scrollbar-winid
                            (vim.api.nvim_open_win
                              scrollbar-bufnr false
                              {:relative "win"
                               :win info.winid
                               :width 1
                               :height scrollbar-height
                               :row scrollbar-offset
                               :col info.width
                               :focusable false
                               :zindex (+ zindex 1)
                               :style "minimal"}))
                       ;; set this var to prevent functions such as `last-float`
                       ;; consider scrollbar windows as floating windows
                       (window.set-opts scrollbar-winid
                                        {:winhighlight "Normal:FloatBorder"})
                       (vim.api.nvim_win_set_var
                         scrollbar-winid "nvlime_scrollbar" true))))
               (close-scrollbar)))]
    ;; Because plugin sets 'modified' option before changing content of
    ;; the plugin's buffers, then `BufModifiedSet` is enough instead of `TextChanged`.
    ;; Except for input windows, but they do not really need a scrollbar anyway
    (vim.api.nvim_create_autocmd
      "BufModifiedSet"
      {:buffer wininfo.bufnr
       :callback callback})
    (vim.api.nvim_create_autocmd
      "WinScrolled"
      {:pattern pattern
       :callback callback})
    (vim.api.nvim_create_autocmd
      "WinClosed"
      {:pattern pattern
       :nested true
       :callback #(do
                    (close-scrollbar)
                    ;; clear autocmds
                    (vim.api.nvim_clear_autocmds
                      {:event ["WinClosed" "WinScrolled"]
                       :pattern pattern })
                    (vim.api.nvim_clear_autocmds
                      {:event "BufModifiedSet"
                       :buffer wininfo.bufnr }))})
    ;; fix hiding scrollbar for `<C-w>H/L/K/J` keymaps
    (vim.api.nvim_create_autocmd
      "WinScrolled"
      {:pattern (tostring *focus-winid*)
       :callback #(when (psl-win.visible? wininfo.winid)
                    (callback))
       :once true})
    ;; defer required to fix wrong initial placement of the scrollbar
    ;; (my assumption it is because of `:relative "win"`)
    ;; timeout doesn't really matter that much 5 chosen just to add
    ;; a little time before showing it
    (vim.defer_fn #(callback) 5)
    scrollbar-winid))

;;; ========== FLOAT WINDOW ==========

;;; BufNr {any} bool bool (fn [WinID BufNr]) -> [WinID BufNr]
(fn window.open-float [bufnr opts close-on-leave? focus? ?callback]
  "Opens general floating window. Returns a list of the created
  window winid and bufnr of the attached buffer to it."
  (let [cur-winid (vim.api.nvim_get_current_win)]
    (when (not (psl-win.floating? cur-winid))
      (set *focus-winid* cur-winid))
    (let [zindex (match (window.last-float)
                   nil 42
                   id (+ (psl-win.get-zindex id) 2))
          winid (vim.api.nvim_open_win
                  bufnr focus?
                  (vim.tbl_extend
                    "keep" opts
                    {:style "minimal"
                     :border options.floating_window.border
                     :zindex zindex}))]
      (add-scrollbar (psl-win.get-info winid)
                     (psl-win.get-zindex winid))
      (when close-on-leave?
        (vim.api.nvim_create_autocmd
          "WinLeave"
          {:buffer bufnr
          :callback #(window.close-float winid)
          :nested true
          :once true}))
      (window.set-minimal-style-options winid)
      (when ?callback (?callback winid bufnr))
      winid)))

;;; WinID ->
(fn window.close-float [winid]
  "Closes the window with `winid` if it isn't already closed
  and it is floating window."
  (when (and (psl-win.visible? winid)
             (psl-win.floating? winid))
    (vim.api.nvim_win_close winid true)))

;;; ========== CURSOR WINDOW ==========

;;; {any} -> {any}
(fn window.cursor.calc-opts [config]
  (let [[scr-height scr-width] (psl-win.get-screen-size)
        [text-height text-width] (ut.calc-lines-size config.lines)
        width (math.min (- scr-width 4) text-width)
        [scr-row _] (psl-win.get-screen-pos)
        (bot? height) (window.find-horiz-pos
                        text-height scr-row scr-height)
        row (if bot? 1 0)]
    {:relative "cursor"
     :row row
     :col -1
     :width width
     :height height
     :anchor (if bot? "NW" "SW")
     :title (.. " " config.title " ")
     :title_pos "center"}))

;;; WinID ->
(fn window.cursor.callback [winid]
  (let [cur-bufnr (vim.api.nvim_get_current_buf)]
    (vim.api.nvim_create_autocmd
      ["CursorMoved" "InsertEnter"]
      {:buffer cur-bufnr
       :callback #(window.close-float winid)
       :nested true
       :once true})))

;;; string {any} -> [WinID BufNr]
(fn window.cursor.open [bufnr content config]
  "Opens new floating window at cursor position."
  (let [lines (ut.text->lines content)
        opts (window.cursor.calc-opts
               {:lines lines :title config.title})]
    (buffer.fill! bufnr lines)
    (match (psl-buf.visible? bufnr)
      (true winid) (do
                     (window.update-win-options
                       winid opts (psl-win.floating? winid))
                     winid)
      _ (match (visible-ft? config.similar)
          (true winid) (do
                         (vim.api.nvim_win_set_buf winid bufnr)
                         (window.update-win-options winid opts)
                         winid)
          _ (window.open-float
              bufnr opts true false #(window.cursor.callback $1))))))

;;; ========== CENTER WINDOW ==========

;;; integer integer integer integer -> integer
(fn calc-optimal-size [content-size min max gap]
  (math.min (math.abs (- max gap))
            (math.max content-size min)))

;;; integer integer integer -> integer
(fn window.center.calc-pos [max side gap]
  (* (- max side gap) 0.5))

;;; {any} -> {any}
(fn window.center.calc-opts [args]
  (let [[scr-height scr-width] (psl-win.get-screen-size)
        [text-height text-width] (ut.calc-lines-size args.lines)
        gap 6
        width (calc-optimal-size
                text-width args.width scr-width (+ gap 4))
        height (calc-optimal-size
                 text-height args.height scr-height gap)]
    {:relative "editor"
     :width width
     :height height
     :row (window.center.calc-pos scr-height height 3)
     :col (window.center.calc-pos scr-width width 3)
     :title (.. " " args.title " ")
     :title_pos "center"
     :focusable (not args.nofocusable)}))

;;; BufNr string {any} (fn [WinID BufNr]) -> WinID
(fn window.center.open [bufnr content config ?callback]
  "Opens new floating window at the center of the screen."
  (let [lines (ut.text->lines content)
        opts-table {:lines lines
                    :height config.height
                    :width config.width
                    :title config.title}
        opts (window.center.calc-opts opts-table)]
    (when (not config.noedit)
      (buffer.fill! bufnr lines))
    (match (psl-buf.visible? bufnr)
      (true winid) (do
                     (window.update-win-options
                       winid opts true)
                     winid)
      _ (let [winid (window.open-float
                      bufnr opts true true ?callback)]
          (vim.api.nvim_win_set_cursor winid [1 0])
          winid))))

window
