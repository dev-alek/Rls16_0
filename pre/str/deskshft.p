block-level on error undo, throw.
using ibs.th.gbl.sys.*.
using ibs.th.str.marking.sts.*.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-silent as logical no-undo .
DEFINE INPUT PARAMETER p-obj-type like shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER p-shift-date like shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER p-shift-num like shift-obj.shift-num no-undo.
define input parameter p-shift-name like shift-obj.shift-name no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1df93d09bce7, 3420, rls $":u .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":u .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:31 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: deskshft.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/deskshft.p $":u .
define variable vss-description as character no-undo init "Проверка корректности закрытия смены на объекте с точки зрения кассы и продаж" .
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
define variable last-date like ub.chk-doc.chk-date no-undo.
define variable last-time like ub.chk-doc.chk-time no-undo.
define variable last-shift-date like ub.chk-doc.shift-date no-undo.
define variable last-shift-num like ub.chk-doc.shift-num no-undo.
define variable oldshift as logical no-undo.
define variable vreason as character no-undo.
define variable v-recid as recid no-undo.
define variable dflt-cd as character no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable varshift-name-num as character no-undo.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_shift-cash for ub.shift-cash.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_marking for ub.marking .
def var Marking as class mark no-undo .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define buffer buf_PromoAction for ub.PromoAction .
define variable rid-list as character no-undo .
disable triggers for load of buf_PromoAction .
for each buf_PromoAction exclusive-lock where buf_PromoAction.Status_ = 1 and
(buf_PromoAction.end-date < today or (buf_PromoAction.changeDate < today and
 buf_PromoAction.changeDate <> 01/01/1970)):
   buf_PromoAction.Status_ = 2 .
   rid-list = rid-list + chr(44) + string(recid(buf_PromoAction)) .
end.
if rid-list <> "" then do:
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/promosend.p":U
      , input ('IBM-XML':U + chr(4) + p-obj-type + chr(4) + string(p-obj-code) + chr(4) + 'D':U + chr(4) + rid-list )
      , input yes
      , input "":U
      , input substitute("Отсылка промоакций на кассы &1", 'IBM-XML':U)
  ) no-error.
  end.
do
on error undo, return error
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type0 as character no-undo .
define variable v-value-date0 as date no-undo .
define variable v-value-decimal0 as decimal no-undo .
define variable v-value-integer0 as INTEGER no-undo .
define variable v-value-logical0 AS LOGICAL no-undo .
define variable v-tth0 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date0
    ,output v-value-decimal0
    ,output v-value-integer0
    ,output v-value-logical0
    ,output v-param-type0
    ,INPUT-OUTPUT table-handle v-tth0
    )  .
delete object v-tth0 no-error.
end.
  run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/get-chkf.p':U
                , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) +
                string(0)  + chr(4) + string(0) + chr(4) + string(1))
                , input (if p-silent then yes else no)
                , input '':U
                , input 'Прием чеков с касс') no-error .
IF error-status:error then do:
    return error "Ошибка при получении почты с касс".
end.
assign
varshift-name-num = (if p-shift-num = integer(p-shift-name)
                     then p-shift-name
                     else p-shift-name + "(" + string(p-shift-num) + ")").
FOR EACH buf_chk-doc No-LOCK WHERE
        buf_chk-doc.obj-type = p-obj-type
    AND buf_chk-doc.obj-code = p-obj-code
    AND buf_chk-doc.shift-date = p-shift-date
    AND buf_chk-doc.shift-num = p-shift-num use-index shift:
  if buf_chk-doc.out-code = ? then do:
    vReason = substitute("Не все чеки по смене № &1 от &2 закачаны в продажу"
                        ,varshift-name-num
                        ,string(p-shift-date, "99/99/9999")
                        ).
    return error vreason.
  end.
END.
for each buf_chk-doc No-lock where
        buf_chk-doc.obj-type = p-obj-type
    AND buf_chk-doc.obj-code = p-obj-code
    AND buf_chk-doc.shift-date = p-shift-date
    AND buf_chk-doc.shift-num = 0:
  if buf_chk-doc.out-code = ?
  and buf_chk-doc.shift-name = p-shift-name
  then do:
    vReason = substitute("Не все чеки по смене № &1 от &2 закачаны в продажу&3имеются чеки с непроставленным порядковым номером смены"
                        ,varshift-name-num
                        ,string(p-shift-date, "99/99/9999")
                        ).
    return error vreason.
  end.
end.
