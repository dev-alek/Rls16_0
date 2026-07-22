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
define buffer cli_shops for ub.clients .
for each cli_shops no-lock where
             cli_shops.obj-type = 'маг':U and
             cli_shops.db-num = v-cntxt-db-num
:
   run str/diallog.w (
           input parparentproc
         , input this-procedure
         , input "str/send-all.p":U
         , input ( cli_shops.obj-type + chr(4) + string(cli_shops.obj-code) + chr(4) + 'D':U + chr(4) + 'emrcdel':U + chr(4) + 'Удаление справочника ЕМЦ':U)
         , input yes
         , input "":U
         , input substitute("Отсылка очистки справочника ЕМЦ")
     ) no-error.
    run str/diallog.w (
           input parparentproc
         , input this-procedure
         , input "str/send-all.p":U
         , input ( cli_shops.obj-type + chr(4) + string(cli_shops.obj-code) + chr(4) + 'U':U + chr(4) + 'emrc':U + chr(4) + 'Передача справочника ЕМЦ':U)
         , input yes
         , input "":U
         , input substitute("Отсылка справочника ЕМЦ")
     ) no-error.
end.
oOk = true.
