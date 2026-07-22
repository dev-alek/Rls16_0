block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aa3cb396dbbb, 2685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendpetrol.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendpetrol.p $":U .
define variable vss-description as character no-undo init "Отсылка данных по соответствию товаров/кошельков".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-obj-type as character no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.
define var choice as integer no-undo.
define var rid-list as char no-undo.
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .
assign
p-obj-type = entry(1, p-parameter, chr(4))
p-obj-code = integer(entry(2, p-parameter, chr(4)))
action     = entry(3, p-parameter, chr(4))
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           (ub.cash-desk.pos-type = 'IBM':U
            AND
            ub.cash-desk.obj-code = p-obj-code)
           OR
           (ub.cash-desk.pos-type = 'IBM-XML':U
           AND
           ub.cash-desk.obj-code = p-obj-code)
            No-error.
IF not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 данных по соответствию товаров/кошельков реализуется только для POS &2 или POS &3"
                          , (if action = "U" then "Передача" else "Удаление")
                          , 'IBM':U
                          , 'IBM-XML':U
                        )
                                        ).
  return.
end.
run gbl/d-askw.w (input "Выбор соответствий товаров/кошельков для пересылки",
   input ( (if action = "U"
   then "Переслать на кассу"
   else "Удалить из кассы" ) + chr(10) +
   "информацию о соответствии товаров/кошельков"
   ),
   input "|",
   input "Все|Отказ от пересылки",
   input "|",
   input 1,
   input 2,
   output choice).
if choice = 2 then return.
    run str/send-petrol.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input p-obj-code
                   ,input p-obj-type
                   ,input action
                   ,input 0
                  , input ""
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке данных по соответствию товаров/кошельков &1&2"
                         , p-obj-type, p-obj-code
                        )
                                        ).
end.
