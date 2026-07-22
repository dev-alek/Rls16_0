block-level on error undo, throw.
define input parameter p-msg   as character no-undo.
define input parameter p-title as character no-undo.
define variable m-file-name      as character no-undo.
define variable m-full-proc-name as character no-undo.
define variable m-msg            as character no-undo.
m-msg = replace(p-msg, "~"", "'").
m-msg = replace(m-msg, "~n", " ").
m-msg = substitute('MsgBox "&1", ,"&2"', m-msg, p-title).
m-file-name = string(guid(generate-uuid)) + ".vbs".
output to value (m-file-name).
put unformatted m-msg.
output close.
file-info:file-name = (m-file-name).
os-command no-wait value (file-info:full-pathname).
