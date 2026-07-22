block-level on error undo, throw.
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
if not available (buf_shift-obj) then do:
    message substitute("Отсутствует смена №&1 от &2 в магазине &3",
                       v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
    return.
end.
if buf_shift-obj.status_ <> 'зкр':U
then do :
  message substitute("Смена №&1 от &2 в магазине &3 не закрыта. Укажите закрытую смену.",
                     v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
  return.
end .
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
else do:
  if testId <> ? then
    put stream vProtTest unformatted
      substitute("Контрольная плотность НП по cмене №&1 от &2 в магазине &3 отправлена",
                 buf_shift-obj.shift-num, buf_shift-obj.shift-date, buf_shift-obj.obj-code)
      skip.
  else
    message substitute("Контрольная плотность НП по Cмене №&1 от &2 в магазине &3 отправлена",
                     v-sht-num, v-sht-date, v-obj-code) view-as alert-box.
end.
