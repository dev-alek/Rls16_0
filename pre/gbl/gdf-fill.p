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
define variable vss-workfile    as character no-undo init "$Workfile: gdf-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/gdf-fill.p $":U .
define variable vss-description as character no-undo init "Формирование списка товаров по фильтру".
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
define shared temp-table gds-list-flt no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-flt-hist no-undo
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
define query gds-fill for ub.clients, ub.goods, ub.gds-prt.
def frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-names.
view frame abc.
disp dsp-rs with frame abc.
v-prepare-string = "for each clients, each goods where clients.obj-type = goods.prod-type and clients.obj-code = goods.prod-code " +
                   p-filter-var  +
                   ", first gds-prt where gds-prt.upper-code = goods.prt-root".
glog = query gds-fill:handle:query-prepare(v-prepare-string) no-error.
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
glog = query gds-fill:handle:query-open() no-error.
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
  query gds-fill:handle:GET-NEXT().
  IF query gds-fill:handle:QUERY-OFF-END THEN LEAVE.
  process events.
  run ex-gds in this-procedure ( buffer goods, input rs-list-method, input rs-status, input line-mode).
end.
glog = query gds-fill:handle:query-close() no-error.
hide frame abc.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-gds :
    define parameter buffer buf_goods for ub.goods.
    define input parameter rs-list-method as character no-undo .
    define input parameter rs-status as character no-undo .
    define input parameter line-mode as character no-undo .
    if rs-list-method = "single":U or
        (buf_goods.stts = 0  and rs-status <> 'удаленные':U) or
        (buf_goods.stts <> 0 and rs-status <> 'текущие':U) then
    do:
        if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then
        do:
            if rs-list-method = "tsd":U then
            do:
                for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and
                    ub.code.status_ = 0 and ub.Code.code = string(buf_goods.gds-code):
                    find first gds-list-flt where gds-list-flt.artic = buf_goods.artic
                        and gds-list-flt.prod-type = buf_goods.prod-type
                        and gds-list-flt.prod-code = buf_goods.prod-code no-error.
                    if available gds-list-flt then
                    do:
                        if line-mode = 'удаление':U then
                        do:
                            lns-cnt = lns-cnt + 1.
                            delete gds-list-flt.
                        end.
                        else
                        do:
                            if gds-list-flt.to-del = ? then.
                            else
                            do:
                                lns-cnt = lns-cnt + 1.
                                gds-list-flt.to-del = ?.
                            end.
                        end.
                    end.
                end.
            end.
            else
            do:
                find first gds-list-flt where gds-list-flt.artic = buf_goods.artic
                    and gds-list-flt.prod-type = buf_goods.prod-type
                    and gds-list-flt.prod-code = buf_goods.prod-code no-error.
                if available gds-list-flt then
                do:
                    if line-mode = 'удаление':U then
                    do:
                        lns-cnt = lns-cnt + 1.
                        delete gds-list-flt.
                    end.
                    else
                    do:
                        if gds-list-flt.to-del = ? then.
                        else
                        do:
                            lns-cnt = lns-cnt + 1.
                            gds-list-flt.to-del = ?.
                        end.
                    end.
                end.
            end.
        end.
        else
            if line-mode = 'ДОБАВЛЕНИЕ':U then
            do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list-flt
  where gds-list-flt.prod-type = buf_goods.prod-type
    and gds-list-flt.prod-code = buf_goods.prod-code
    and gds-list-flt.artic     = buf_goods.artic
  no-error .
if available gds-list-flt then do:
  assign
    gds-list-flt.to-del = no
  .
end.
else do:
  define variable v-last4 as integer no-undo .
  find last gds-list-flt use-index oi no-error.
  if available gds-list-flt then do:
    v-last4 = gds-list-flt.order-num .
  end.
  else do:
    v-last4 = 0 .
  end.
  create gds-list-flt .
  buffer-copy buf_goods to gds-list-flt
  assign
    gds-list-flt.to-del = no
    gds-list-flt.order-num = v-last4 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list-flt)
  .
end.
                if rs-list-method = "tsd":U  then
                do:
                    for first ub.Code no-lock where ub.Code.parent = "TiketPrint" and
                        ub.code.status_ = 0 and ub.Code.code = string(buf_goods.gds-code):
                        find first gds-list-flt where gds-list-flt.gds-code = buf_goods.gds-code no-error.
                        if available gds-list-flt then
                        do:
                            gds-list-flt.qnty = decimal(ub.Code.CodeValue) .
                        end.
                    end.
                end.
            end.
            disp "ЖДИТЕ...    Обработано товаров :" + string (lns-cnt) @ dsp-rs with frame abc.
    end.
    else
        assign
            lns-ignore = lns-ignore + 1
            .
end.
