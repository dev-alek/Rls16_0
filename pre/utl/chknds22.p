define output parameter oRun as logical no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_code for ub.code.
define buffer buf_sys-ctrl for ub.sys-ctrl.
find first buf_sys-ctrl no-lock.
if buf_sys-ctrl.db-num = 0 then
do:
  oRun = no.
end.
else
do:
  oRun = not can-find(first buf_code where
                            buf_code.parent = substitute("RunUtils&1&2",chr(4), buf_sys-ctrl.db-num)
                        and buf_code.code = "nds22").
end.
