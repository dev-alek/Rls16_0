block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
for each ub.gds-obj-attr no-lock where ub.gds-obj-attr.attr-code = "dt-seasons" and
  ub.gds-obj-attr.obj-code = v-cntxt-obj-code and
  ub.gds-obj-attr.obj-type = v-cntxt-obj-type:
  find first ub.goods-attr no-lock where ub.goods-attr.gds-code = ub.gds-obj-attr.gds-code and
    ub.goods-attr.attr-code = "fuel-type" and
    ub.goods-attr.attr-value = "diesel" no-error .
  find first ub.code no-lock where ub.code.parent = "DTseasons" and ub.code.code = ub.gds-obj-attr.attr-value no-error .
  if available (ub.goods-attr) and available (ub.code) then
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "DTSeasons",
      (buffer ub.gds-obj-attr:handle),
      ?,
      ?) no-error.
    if error-status:error
      then
    do:
      message return-value view-as alert-box.
    end.
  end.
end.
oOk = true.
