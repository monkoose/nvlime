(local km (require "nvlime.keymaps"))
(local im km.mappings.inspector)

(local inspector {})

(fn inspector.add []
  (km.buffer.normal im.normal.action
                    "<Cmd>call nvlime#ui#inspector#InspectorSelect()<CR>"
                    "nvlime: Activate the interactable field/button under the cursor")
  (km.buffer.normal im.normal.current.send
                    "<Cmd>call nvlime#ui#inspector#SendCurValueToREPL()<CR>"
                    "nvlime: Send the value of the field under the cursor to the REPL")
  (km.buffer.normal im.normal.current.source
                    "<Cmd>call nvlime#ui#inspector#FindSource('part')<CR>"
                    "nvlime: Open the source code for the value of the field under the cursor")
  (km.buffer.normal im.normal.inspected.send
                    "<Cmd>call nvlime#ui#inspector#SendCurInspecteeToREPL()<CR>"
                    "nvlime: Send the value being inspected to the REPL")
  (km.buffer.normal im.normal.inspected.source
                    "<Cmd>call nvlime#ui#inspector#FindSource('inspectee')<CR>"
                    "nvlime: Open the source code for the value being inspected")
  (km.buffer.normal im.normal.inspected.previous
                    "<Cmd>call nvlime#ui#inspector#InspectorPop()<CR>"
                    "nvlime: Return to the previous inspected object")
  (km.buffer.normal im.normal.inspected.next
                    "<Cmd>call nvlime#ui#inspector#InspectorNext()<CR>"
                    "nvlime: Move to the next inspected object")
  (km.buffer.normal im.normal.next_field
                    "<Cmd>call nvlime#ui#inspector#NextField(v:true)<CR>"
                    "nvlime: Select the next interactable field/button")
  (km.buffer.normal im.normal.prev_field
                    "<Cmd>call nvlime#ui#inspector#NextField(v:false)<CR>"
                    "nvlime: Select the previous interactable field/button")
  (km.buffer.normal im.normal.refresh
                    "<Cmd>call b:nvlime_conn.InspectorReinspect({c, r -> c.ui.OnInspect(c, r, v:null, v:null)})<CR>"
                    "nvlime: Refresh the inspector"))

inspector
