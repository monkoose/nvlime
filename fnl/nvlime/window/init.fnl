(local buffer (require "nvlime.buffer"))
(local ut (require "nvlime.utilities"))
(local psl-buf (require "parsley.buffer"))
(local psl-win (require "parsley.window"))
(local options (require "nvlime.config"))

;; TODO: after neovim 0.10 release
;; Change `nvim_buf_set_option` and `nvim_win_set_option` 
;; and the same get functions to `nvim_set_option_value`.
;; Change `nvim_exec` to `nvim_exec2`
(local {: nvim_buf_line_count
        : nvim_buf_get_name
        : nvim_win_set_option
        : nvim_win_get_option
        : nvim_win_get_buf
        : nvim_win_set_cursor
        : nvim_win_set_config
        : nvim_win_close
        : nvim_win_get_var
        : nvim_win_set_var
        : nvim_win_set_buf
        : nvim_get_current_buf
        : nvim_get_current_win
        : nvim_set_current_win
        : nvim_tabpage_list_wins
        : nvim_create_autocmd
        : nvim_clear_autocmds
        : nvim_exec
        : nvim_open_win}
       vim.api)

(local window {:cursor {} :center {}})

(local +scrollbar-bufname+ (buffer.gen-name "scrollbar"))
(var *focus-winid* 1000)

;;; [FileType] -> ?(true WinID)
(fn filetype-win [filetypes]
  "Returns first found window in which displayed buffer has
any of the listed `filetypes`. If there is no such window returns nil."
  (var found-winid nil)
  (each [_ winid (ipairs (nvim_tabpage_list_wins 0)) &until found-winid]
    (let [bufnr (nvim_win_get_buf winid)
          buf-ft (psl-buf.filetype bufnr)]
      (each [_ ft (ipairs filetypes) &until found-winid]
        (when (= buf-ft ft)
          (set found-winid winid)))))
  found-winid)

;;; WinID string any ->
(fn window.set-opt [winid opt value]
  "Set the window's local option."
  (nvim_win_set_option winid opt value))

;;; WinID {any} ->
(fn window.set-opts [winid opts]
  "Sets window's local options, `opts` is table with
option name as key and new value as it's value."
  (each [opt val (pairs opts)]
    (nvim_win_set_option winid opt val)))

;;; WinID ->
(fn window.set-minimal-style-options [winid]
  "Sets minimal style window options for the window 
with `winid`."
  (window.set-opts
    winid {:wrap true
           :number false
           :relativenumber false
           :spell false
           :list false
           :signcolumn "no"}))

;;; integer integer integer -> (bool integer)
(fn window.find-horiz-pos [req-height scr-row scr-height]
  "Finds where is more line space on the screen (top or bottom)
related to the screen row and the screen height. Returns (true height)
for bottom and (false height) for top."
  (let [border-len 3
        bot-height (- scr-height scr-row border-len)
        top-height (- scr-row border-len)
        bottom? (or (> bot-height req-height)
                    (> bot-height top-height))]
    (if bottom?
        (values true (math.min bot-height req-height))
        (values false (math.min top-height req-height)))))

;;; WinID {any} ?bool ->
(fn window.update-win-options [winid opts ?focus?]
  "Updates a floating window options with `opts` as in
vim.api.nvim_open_win(), then focus this window if required."
  (nvim_win_set_cursor winid [1 0])
  (when (psl-win.floating? winid)
    (nvim_win_set_config winid opts))
  (when ?focus?
    (nvim_set_current_win winid)))

(fn win-nvlime-ft? [winid]
  "Returns true if the window displays a buffer
with any of the nvlime's filetypes; otherwise, returns false."
  (let [pattern "nvlime_"]
    (not= nil
       (string.find (psl-win.filetype winid)
                    pattern))))

;;; WinID -> bool
(fn main-win? [winid]
  "Returns true if the window is the main plugin's window;
otherwise, returns false.
Main windows are repl, sldb and compiler notes."
  (let [win-ft (psl-win.filetype winid)]
    (var result false)
    (each [_ ft
           (ipairs ["nvlime_repl" "nvlime_sldb" "nvlime_notes"])
           &until result]
      (when (= win-ft ft)
        (set result true)))
    result))

;;; (fn [WinID] bool) ->
(fn window.close-when [predicate]
  "Closes all windows within the current tabpage that match the specified `predicate`.
Predicate accepts one argument - integer representing window id and returns boolean."
  (each [_ winid (ipairs (nvim_tabpage_list_wins 0))]
    (when (predicate winid)
      (nvim_win_close winid true))))

(fn window.close_all []
  "Closes all windows related to the plugin."
  (window.close-when #(win-nvlime-ft? $)))

(fn window.close_all_except_main []
  "Closes all windows associated with the plugin, excluding the main ones.
Main windows are repl, sldb and compiler notes."
  (window.close-when #(and (win-nvlime-ft? $)
                           (not (main-win? $)))))

;;; -> ?WinID
(fn window.last-float []
  "Returns winid of the last opened floating window, if no such
window is present returns nil."
  (let [win-list (nvim_tabpage_list_wins 0)]
    ;; Last opened window always has the highest winid.
    ;; 'nvim_tabpage_list_wins' isnot sorted, so it should be sorted first
    ;; or just get the maximum of the found winids.
    (table.sort win-list #(> $1 $2))
    (var result nil)
    (each [_ winid (ipairs win-list) &until result]
      (when (and (psl-win.floating? winid)
                 (not (pcall
                        nvim_win_get_var
                        winid "nvlime_scrollbar")))
        (set result winid)))
    result))

;;; -> ?WinID
(fn window.last-float-except-current []
  "Returns the window ID of the most recently opened floating window,
unless it is the current window. If no such window is present returns nil."
  (let [float-id (window.last-float)]
    (when (not= float-id (nvim_get_current_win))
        float-id)))

;;; -> ?WinID
(fn window.close_last_float []
  "Closes last opened floating window, unless it is the current window,
and returns its ID. Returns nil if such window wasn't found."
  (let [last-float-winid (window.last-float-except-current)]
    (when last-float-winid
      (nvim_win_close last-float-winid true)
      last-float-winid)))

;;; integer bool ->
(fn window.scroll_float [step reverse?]
  "Scrolls last opened floating window down by `step` lines.
If `reverse?` is provided and true, then scrolls upwards."
  (let [last-float-winid (window.last-float-except-current)]
    (when last-float-winid
      (let [wininfo (psl-win.get-info last-float-winid)
            old-scrolloff (nvim_win_get_option
                            last-float-winid "scrolloff")
            set-float-cursor #(nvim_win_set_cursor
                          last-float-winid [$1 0])]
        (window.set-opt last-float-winid "scrolloff" 0)
        (if reverse?
            (let [expected-line (- wininfo.topline step)]
              (if (< expected-line 1)
                  (set-float-cursor 1)
                  (set-float-cursor expected-line)))
            (let [expected-line (+ wininfo.botline step)
                  last-line (nvim_buf_line_count
                              (nvim_win_get_buf last-float-winid))]
              (if (> expected-line last-line)
                  (set-float-cursor last-line)
                  (set-float-cursor expected-line))))
        (window.set-opt last-float-winid "scrolloff" old-scrolloff))
      last-float-winid)))

;;; WinID BufNr string -> WinID
(fn window.split [winid bufnr cmd]
  "Splits the window using the specified neovim ex `cmd` and
changes new split window buffer to `bufnr`.
Returns winid of this new window."
  ;; TODO: add buffer.with-bufhidden macro
  (let [bufhidden (buffer.get-opt bufnr "bufhidden")]
    (buffer.set-opts bufnr {:bufhidden "hide"})
    (nvim_set_current_win winid)
    (nvim_exec
      (.. cmd " " (nvim_buf_get_name bufnr))
      false)
    (buffer.set-opts bufnr {:bufhidden bufhidden})
    (nvim_get_current_win)))

;;; string -> ?WinID
(fn window.split_focus [cmd]
  "Splits focus window."
  (if (psl-win.visible? *focus-winid*)
      (window.split *focus-winid*
                    (nvim_get_current_buf)
                    cmd)
      (ut.echo-warning "Can't split this window.")))

;;; ========== SCROLLBAR ==========

;;; char -> BufNr
(fn create-scrollbar-buffer [icon]
  "Creates buffer that will represent scrollbar.
It is filled with `icon` on the first columnt of it."
  (case (psl-buf.exists? +scrollbar-bufname+)
    (true bufnr) bufnr
    _ (let [bufnr (buffer.create +scrollbar-bufname+)]
        (buffer.fill!
          ;; TODO: convert magic number 100 to neovim window height
          ;; and update it on VimResized autocmd
          bufnr (fcollect [_ 1 100] icon))
        bufnr)))

;;; {any} integer -> bool
(fn scrollbar-required? [wininfo content-height]
  "Returns true if scrollbar should be added; otherwise, returns false."
  (< wininfo.height content-height))

;;; {any} integer -> integer
(fn calc-scrollbar-height [wininfo content-height]
  "Returns number of window rows as scrollbar height."
  (math.max
    (math.floor
      (* (/ wininfo.height content-height)
         wininfo.height))
    1))

;;; {any} integer integer -> integer
(fn calc-scrollbar-offset [wininfo buf-height scrollbar-height]
  "Returns number of rows from the top of the window at which
scrollbar window should be placed."
  (math.min
    (- wininfo.height scrollbar-height)
    (math.ceil (* (/ (- wininfo.topline 1)
                     buf-height)
                  wininfo.height))))

;;; TODO should be correct when lines are wrapped
;;; {any} integer -> WinID
(fn add-scrollbar [wininfo zindex]
  "Attaches scrollbar to the window with `wininfo.winid`.
Returns winid of the created scrollbar window."
  (var scrollbar-winid -1)
  (let [scrollbar-bufnr (create-scrollbar-buffer "▌")
        pattern (tostring wininfo.winid)
        close-scrollbar #(when (psl-win.visible? scrollbar-winid)
                           (nvim_win_close scrollbar-winid true))
        callback
        #(let [info (psl-win.get-info wininfo.winid)
               content-height (nvim_buf_line_count info.bufnr)]
           (if (and (psl-win.floating? info.winid)
                    (scrollbar-required? info content-height))
               (let [scrollbar-height (calc-scrollbar-height info
                                                             content-height)
                     scrollbar-offset (calc-scrollbar-offset info
                                                             content-height
                                                             scrollbar-height)
                     update-sb-window #(nvim_win_set_config
                                         scrollbar-winid
                                         {:relative "win"
                                          :win info.winid
                                          :height scrollbar-height
                                          :row scrollbar-offset
                                          :col info.width})
                     open-sb-window (fn []
                                      (set scrollbar-winid
                                           (nvim_open_win
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
                                      (window.set-opts scrollbar-winid
                                                       {:winhighlight "Normal:FloatBorder"})
                                      ;; set this var to prevent functions such as `last-float`
                                      ;; consider scrollbar windows as floating windows
                                      (nvim_win_set_var
                                        scrollbar-winid "nvlime_scrollbar" true))]
                 (if (psl-win.visible? scrollbar-winid)
                     (update-sb-window)
                     (open-sb-window)))
               (close-scrollbar)))]
    ;; Because plugin sets 'modified' option before changing content of
    ;; the plugin's buffers, then `BufModifiedSet` is enough instead of `TextChanged`.
    ;; Except for input windows, but they do not really need a scrollbar anyway
    (nvim_create_autocmd
      "BufModifiedSet"
      {:buffer wininfo.bufnr
       :callback callback})
    (nvim_create_autocmd
      "WinScrolled"
      {:pattern pattern
       :callback callback})
    (nvim_create_autocmd
      "WinClosed"
      {:pattern pattern
       :nested true
       :callback #(do
                    (close-scrollbar)
                    ;; clear autocmds
                    (nvim_clear_autocmds
                      {:event ["WinClosed" "WinScrolled"]
                       :pattern pattern })
                    (nvim_clear_autocmds
                      {:event "BufModifiedSet"
                       :buffer wininfo.bufnr }))})
    ;; fix hiding scrollbar for `<C-w>H/L/K/J` keymaps
    (nvim_create_autocmd
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
  "Opens general floating window. Returns a tuple with that window
window's id and buffer number of the attached buffer to it."
  (let [cur-winid (nvim_get_current_win)]
    (when (not (psl-win.floating? cur-winid))
      (set *focus-winid* cur-winid))
    (let [zindex (case (window.last-float)
                   nil 42
                   id (+ (psl-win.get-zindex id) 2))
          winid (nvim_open_win
                  bufnr focus?
                  (vim.tbl_extend
                    "keep" opts
                    {:style "minimal"
                     :border options.floating_window.border
                     :zindex zindex}))]
      (add-scrollbar (psl-win.get-info winid)
                     (psl-win.get-zindex winid))
      (when close-on-leave?
        (nvim_create_autocmd
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
  "Closes the window with `winid` if it opened and it is a floating window."
  (when (and (psl-win.visible? winid)
             (psl-win.floating? winid))
    (nvim_win_close winid true)))

;;; ========== CURSOR WINDOW ==========

;;; {any} -> {any}
(fn window.cursor.calc-opts [config]
  "Returns options table accepted by vim.api.nvim_open_win().
Config is {:lines [lines] :title string} table."
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
  "Callback to execute after opening the cursor window."
  (let [cur-bufnr (nvim_get_current_buf)]
    (nvim_create_autocmd
      ["CursorMoved" "InsertEnter"]
      {:buffer cur-bufnr
       :callback #(window.close-float winid)
       :nested true
       :once true})))

;;; BufNr string {any} -> [WinID BufNr]
(fn window.cursor.open [bufnr content config]
  "Opens new floating window at cursor position."
  (let [lines (ut.text->lines content)
        opts (window.cursor.calc-opts
               {:lines lines :title config.title})]
    (buffer.fill! bufnr lines)
    (case (psl-buf.visible? bufnr)
      (true winid) (do
                     (window.update-win-options
                       winid opts (psl-win.floating? winid))
                     winid)
      _ (case (filetype-win config.similar)
          (true winid) (do
                         (nvim_win_set_buf winid bufnr)
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
  "Returns options table accepted by vim.api.nvim_open_win()."
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
  "Opens new floating window at the center of the screen
and returns its window id."
  (let [lines (ut.text->lines content)
        opts-table {:lines lines
                    :height config.height
                    :width config.width
                    :title config.title}
        opts (window.center.calc-opts opts-table)]
    (when (not config.noedit)
      (buffer.fill! bufnr lines))
    (case (psl-buf.visible? bufnr)
      (true winid) (do
                     (window.update-win-options
                       winid opts true)
                     winid)
      _ (let [winid (window.open-float
                      bufnr opts true true ?callback)]
          (nvim_win_set_cursor winid [1 0])
          winid))))

window
