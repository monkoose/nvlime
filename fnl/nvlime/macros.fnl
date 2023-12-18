;; fennel-ls: macro-file

(fn notification [msg level]
  `(vim.notify ,(.. "nvlime: " msg) ,level))

(fn warn-msg [msg]
  (notification msg `vim.log.levels.WARN))

(fn info-msg [msg]
  (notification msg `vim.log.levels.INFO))

{: warn-msg
 : info-msg}
