(let [{: build} (require "hotpot.api.make")]
  (build "./"
         "fnl/(.+)" (fn [p {: join-path}]
                      (when (not (string.find p "macros%.fnl$"))
                        (join-path "./lua" p)))
         "(after/.+)" #$))
