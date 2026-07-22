block-level on error undo, throw.
define input parameter par-run-names as character no-undo .
define input parameter Rs-list-method as character no-undo .
define input parameter Rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scnbfill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/scnbfill.p $":U .
define variable vss-description as character no-undo init "Формирование списка кодов с кол-вами по фильтру".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table scnblist no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table scnblist-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable dsp-rs as char format "x(50)" no-undo.
define variable lns-ignore as integer no-undo .
define variable glog as logical no-undo .
define variable v-prepare-string as character no-undo .
define query bb-fill for ub.bar-code, ub.goods.
def frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-names.
view frame abc.
disp dsp-rs with frame abc.
v-prepare-string = "for each ub.bar-code no-lock where true " +
                   p-filter-var  + ", first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code ".
glog = query bb-fill:handle:query-prepare(v-prepare-string) no-error.
if not glog
or error-status:error then do:
  message
  substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
             , chr(10)
             , error-status:get-message(1)
             , p-filter-var)
  view-as alert-box error .
  undo, return error .
end.
glog = query bb-fill:handle:query-open() no-error.
if not glog
or error-status:error then do:
  message
  substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
             , chr(10)
             , error-status:get-message(1)
             , p-filter-var)
  view-as alert-box error .
  undo, return error .
end.
REPEAT WITH FRAME abc:
  query bb-fill:handle:GET-NEXT().
  IF query bb-fill:handle:QUERY-OFF-END THEN LEAVE.
  process events.
  run ex-bbc in this-procedure (input rs-list-method
                               , input rs-status
                               , input line-mode
                               , input no
                               , input "":U
                               , input no
                               , buffer ub.bar-code
                               , buffer ub.prod-bc).
end.
glog = query bb-fill:handle:query-close() no-error.
hide frame abc.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-bbc :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-empty-scale as logical no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-is-loc-ean as logical no-undo .
define parameter buffer buf_bar-code for ub.bar-code.
define parameter buffer buf_prod-bc for ub.prod-bc.
define variable v-f-name like ub.gds-prt.f-name no-undo .
define buffer buf_gds-prt for ub.gds-prt.
if available buf_prod-bc then
p-b-str = buf_prod-bc.b-str.
if rs-list-method begins "single":U or
  (ub.goods.stts = 0  and rs-status <> 'удаленные':U) or
  (ub.goods.stts <> 0 and rs-status <> 'текущие':U) then do:
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    find first scnblist where scnblist.gds-code  = ub.goods.gds-code
                     and scnblist.b-code    = buf_bar-code.b-code
                     and scnblist.b-str     = p-b-str  no-error.
    if available scnblist then do:
      if line-mode = 'удаление':U then do:
        lns-cnt = lns-cnt + 1.
        delete scnblist.
      end.
      else do:
        if scnblist.to-del = ? then.
        else do:
          lns-cnt = lns-cnt + 1.
          scnblist.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U then do:
      if p-empty-scale then  do:
      end.
      else do:
        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = buf_bar-code.node-code no-error.
        if not available buf_gds-prt then v-f-name = "!!!Неизвестный признак шкалы".
        else v-f-name = buf_gds-prt.f-name.
      end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first scnblist
  where scnblist.gds-code = buf_bar-code.gds-code
    and scnblist.b-code   = buf_bar-code.b-code
    and scnblist.b-str    = p-b-str
  no-error .
if available scnblist then do:
  assign
    scnblist.to-del = no
  .
end.
else do:
  define variable v-last4 as integer no-undo .
  find last scnblist use-index oi no-error.
  if available scnblist then do:
    v-last4 = scnblist.order-num .
  end.
  else do:
    v-last4 = 0 .
  end.
  create scnblist .
  buffer-copy ub.goods to scnblist
  assign
    scnblist.to-del = no
    scnblist.order-num = v-last4 + 1
    scnblist.b-code = buf_bar-code.b-code
    scnblist.bc-cli-base-rate = buf_bar-code.cli-base-rate
    scnblist.bc-cr-db-num     = buf_bar-code.cr-db-num
    scnblist.in-code       = buf_bar-code.in-code
    scnblist.node-code     = buf_bar-code.node-code
    scnblist.part-code     = buf_bar-code.part-code
    scnblist.stts_         = buf_bar-code.stts_
    scnblist.bc-unit-cli   = buf_bar-code.unit-cli
    scnblist.b-str         = p-b-str
    scnblist.f-name        = v-f-name
    scnblist.loc-ean       = p-is-loc-ean
    .
    if available buf_prod-bc
    then
    assign
    scnblist.bc-on-type    = buf_prod-bc.bc-on-type
    scnblist.bc-on         = buf_prod-bc.bc-on
    scnblist.pbc-cr-db-num = buf_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (scnblist)
  .
end.
    end.
  disp "ЖДИТЕ...    Обработано кодов :" + string (lns-cnt) @ dsp-rs with frame abc.
end.
else
assign
lns-ignore = lns-ignore + 1
.
end.
