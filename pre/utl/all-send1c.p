block-level on error undo, throw.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then run str/trdcalib.p persistent no-error .
define buffer buf_shift-obj for ub.shift-obj .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-sht-date as date      no-undo .
define variable v-sht-num  as integer   no-undo .
define variable varvalue   as character no-undo .
define variable vartype    as character no-undo .
define button btnOk auto-go label "Ok" .
define button btnCancel auto-endkey label "Cancel".
define temp-table tt-shift like ub.shift-obj .
define temp-table tt-trn like ub.trn-doc.
define temp-table tt-price-doc like ub.price-doc.
define temp-table tt-rvs like ub.rvs-doc.
define temp-table tt-fbr like ub.fbr-doc.
define temp-table tt-fin like ub.fin-doc.
define temp-table tt-utd like ub.utd .
DEFINE FRAME frame1
    skip
    v-obj-code format ">>>>>>>>9"  label "Код магазина"
    skip    space(2) v-sht-date format "99/99/9999" label "Дата смены"
    space(2) v-sht-num                      label "Порядок смены"
    skip(1) space(2) btnOk
    space(2) btnCancel
    with
    side-labels
    default-button btnOk
    cancel-button btnCancel
    view-as dialog-box
    title "Введите номер код магазина, дату и номер смены"
    .
update v-obj-code v-sht-date v-sht-num btnOk btnCancel with frame frame1.
find first buf_shift-obj no-lock
    where buf_shift-obj.obj-type = 'маг'
    and buf_shift-obj.obj-code = v-obj-code
    and buf_shift-obj.shift-date = v-sht-date
    and buf_shift-obj.shift-num  = v-sht-num no-error .
if not available (buf_shift-obj) then
do:
    message substitute("Отсутствует смена №&1 от &2 в магазине &3",
        v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
    return.
end.
buffer-copy buf_shift-obj except buf_shift-obj.status_ to tt-shift  assign tt-shift.status_ = "накл".
for each ub.trn-doc no-lock where ub.trn-doc.obj-type = buf_shift-obj.obj-type
    and ub.trn-doc.obj-code = buf_shift-obj.obj-code
    and ub.trn-doc.shift-date = buf_shift-obj.shift-date
    and ub.trn-doc.shift-num = buf_shift-obj.shift-num :
    buffer-copy ub.trn-doc except ub.trn-doc.status_ to tt-trn  assign
        tt-trn.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_trn-doc':U
  ,input  buffer tt-trn:handle
  ,input  buffer ub.trn-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
then do:
  message return-value view-as alert-box.
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue = "yes" then
  do:
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer ub.trn-doc:handle),
      ?,
      ?) no-error.
    if error-status:error
      then
    do:
      message return-value view-as alert-box.
    end.
  end.
for each tt-trn:
    delete tt-trn .
end.
end.
for each ub.price-doc no-lock where ub.price-doc.obj-code = buf_shift-obj.obj-code and
    ub.price-doc.obj-type = buf_shift-obj.obj-type and
    ub.price-doc.shift-date = buf_shift-obj.shift-date and
    ub.price-doc.shift-num = buf_shift-obj.shift-num :
    buffer-copy ub.price-doc except ub.price-doc.status_ to tt-price-doc  assign
        tt-price-doc.status_ = "приказ".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_price-doc':U
  ,input  buffer tt-price-doc:handle
  ,input  buffer ub.price-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
    then
do:
    message return-value view-as alert-box.
end.
for each tt-price-doc:
    delete tt-price-doc .
end.
end.
for each ub.rvs-doc no-lock where ub.rvs-doc.obj-code = buf_shift-obj.obj-code and
    ub.rvs-doc.obj-type = buf_shift-obj.obj-type and
    ub.rvs-doc.shift-date = buf_shift-obj.shift-date and
    ub.rvs-doc.shift-num = buf_shift-obj.shift-num:
    buffer-copy rvs-doc except rvs-doc.status_ to tt-rvs  assign
        tt-rvs.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_rvs-doc':U
  ,input  buffer tt-rvs:handle
  ,input  buffer ub.rvs-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
    then
do:
    message return-value view-as alert-box.
end.
for each tt-rvs:
    delete tt-rvs .
end.
end.
for each ub.fbr-doc no-lock where ub.fbr-doc.obj-code = buf_shift-obj.obj-code and
    ub.fbr-doc.obj-type = buf_shift-obj.obj-type and
    ub.fbr-doc.shift-date = buf_shift-obj.shift-date and
    ub.fbr-doc.shift-num = buf_shift-obj.shift-num:
    buffer-copy fbr-doc except fbr-doc.status_ to tt-fbr  assign
        tt-fbr.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_fbr-doc':U
  ,input  buffer tt-fbr:handle
  ,input  buffer ub.fbr-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
    then
do:
    message return-value view-as alert-box.
end.
for each tt-fbr:
    delete tt-fbr .
end.
end.
for each ub.fin-doc no-lock where ub.fin-doc.obj-code = buf_shift-obj.obj-code and
    ub.fin-doc.obj-type = buf_shift-obj.obj-type and
    ub.fin-doc.shift-date = buf_shift-obj.shift-date and
    ub.fin-doc.shift-num = buf_shift-obj.shift-num:
    buffer-copy fin-doc except fin-doc.status_ to tt-fin  assign
        tt-fin.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_fin-doc':U
  ,input  buffer tt-fin:handle
  ,input  buffer ub.fin-doc:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error
    then
do:
    message return-value view-as alert-box.
end.
for each tt-fin:
    delete tt-fin .
end.
end.
run str/prep1C-shift-period.p (input ?,
                               input buf_shift-obj.obj-type,
                               input buf_shift-obj.obj-code,
                               input buf_shift-obj.shift-date,
                               input buf_shift-obj.shift-num)
                               no-error .
if error-status:error
then do:
  message return-value view-as alert-box.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_shift':U
  ,input  buffer tt-shift:handle
  ,input  buffer buf_shift-obj:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error then
do :
    message "Ошибка маршрутизации записи в машину правил" skip return-value skip error-status:get-message(1) view-as alert-box.
end.
else
do:
    define buffer buf_reportShift for ub.reportShift .
    find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = buf_shift-obj.shift-date and
        buf_reportShift.shift-num = buf_shift-obj.shift-num and buf_reportShift.obj-code = buf_shift-obj.obj-code and
        buf_reportShift.obj-type = buf_shift-obj.obj-type and buf_reportShift.report-type = 1 no-error .
    if available (buf_reportShift) then
    do:
        run bge\send1cerp.p (parparentproc,
            this-procedure,
            this-procedure,
            "reportShift",
            (buffer buf_reportShift:handle),
            ?,
            ?) no-error.
        if  error-status:error then
        do:
            message return-value
                view-as alert-box.
            return .
        end.
    end.
    message substitute("Cмена №&1 от &2 в магазине &3 отправлена",
        v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
end.
