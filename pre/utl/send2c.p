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
define  shared stream vProtTest.
define  shared variable testId as rowid no-undo.
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
    then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
    then run str/lib-trn4.p persistent no-error .
// define temp-table tt-trn like ub.shift-obj .
define buffer buf_shift-obj for ub.shift-obj .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-sht-date as date no-undo .
define variable v-sht-num  as integer no-undo .
define button btnOk auto-go label "Ok" .
define button btnCancel auto-endkey label "Cancel".
if testId ne ? then
do:
  find first buf_shift-obj where rowid(buf_shift-obj) = testId no-lock no-error.
  if not avail buf_shift-obj then return.
end.
else
do:
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
end.
if not available (buf_shift-obj) then do:
    message substitute("Отсутствует смена №&1 от &2 в магазине &3",
                       v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
    return.
end.
// buffer-copy trn-doc except trn-doc.status_ to tt-trn  assign tt-trn.status_ = "накл".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_shift':U
  ,input  buffer buf_shift-obj:handle
  ,input  buffer buf_shift-obj:handle
  ,input ''
  ,input ''
  ) no-error .
if error-status:error then do :
  message "Ошибка маршрутизации записи в машину правил" skip return-value skip error-status:get-message(1) view-as alert-box.
end.
else do:
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
  if testId <> ? then
    put stream vProtTest unformatted
      substitute("Cмена №&1 от &2 в магазине &3 отправлена",
                 buf_shift-obj.shift-num, buf_shift-obj.shift-date, buf_shift-obj.obj-code)
      skip.
  else
    message substitute("Cмена №&1 от &2 в магазине &3 отправлена",
                     v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
end.
