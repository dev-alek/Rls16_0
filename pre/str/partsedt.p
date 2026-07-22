block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_doc-line for ub.doc-line .
define input parameter  l-update     as logical no-undo .
define input parameter  l-reserv     as logical no-undo .
define input parameter  p-chg-qnty   as decimal no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: partsedt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/partsedt.p $":U .
def var vss-description as character no-undo init "Ручное редактирование партий строки документа".
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
if not available buf_doc-line then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Недоступна запись строка документа" skip
    view-as alert-box error .
  undo, return error .
end.
find first ub.goods no-lock
  where ub.goods.artic     = buf_doc-line.artic
    and ub.goods.prod-type = buf_doc-line.prod-type
    and ub.goods.prod-code = buf_doc-line.prod-code
  no-error .
if not available ub.goods then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Не найден товар" skip
    "Документ" buf_doc-line.doc-code skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    view-as alert-box error .
  undo, return error .
end.
define variable prt-rec as recid no-undo .
run str/parts-l.w
  (input parparentproc
  ,input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input ub.goods.gds-code
  ,input buf_doc-line.doc-code
  ,input  ( if l-update
            then 'ДОБАВЛЕНИЕ':U
            else 'ПРОСМОТР':U
          )
  ,input 'документ':U
    + (if l-reserv then "" else "," + 'без-резервирования':U )
    + (if p-chg-qnty = ? or p-chg-qnty = 0 then "" else "," + 'chg-qnty':U + "=" + string(p-chg-qnty) )
  ,input 'текущий':U
  ,input 'документ':U
  ,output prt-rec
  ) no-error .
define variable v-error-status-error as logical   no-undo .
assign
  v-error-status-error = error-status :error
.
if v-error-status-error then do:
  if  l-reserv = false
  and p-chg-qnty <> ?
  and p-chg-qnty <> 0
  then do:
    undo, return error .
  end.
end.
