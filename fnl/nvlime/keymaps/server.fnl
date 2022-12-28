(local km (require "nvlime.keymaps"))
(local sm km.mappings.server)

(local server {})

(fn server.add []
  (km.buffer.normal sm.normal.connect
                    "<Cmd>call nvlime#server#ConnectToCurServer()<CR>"
                    "nvlime: Connect to this server")
  (km.buffer.normal sm.normal.stop
                    "<Cmd>call nvlime#server#StopCurServer()<CR>"
                    "nvlime: Stop this server"))

server
