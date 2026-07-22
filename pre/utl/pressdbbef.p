block-level on error undo, throw.
define input parameter iWrkDir as character no-undo.
define input parameter iTables as character no-undo.
define input parameter p-handle-callback     as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 20/01/2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pressdbbef.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pressdbbef.p $":U .
define variable vss-description as character no-undo init "Сжатие БД. Выгрузка списка таблиц базы.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define stream LogStream .
define variable ttd        as character no-undo .
define variable v-old-time as int64     no-undo .
PROCEDURE write-to-log :
  define input parameter p-msg-str   as character no-undo .
  define input parameter p-call-back as handle    no-undo .
  do
  on error undo, return error
  :
    output stream LogStream to "press_db.log" page-size 0 append.
    put stream LogStream unformatted p-msg-str .
    output stream LogStream close.
    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
    then do:
      run callback-write-to-log in p-call-back
        (input p-msg-str
        ) no-error .
    end.
  end.
END PROCEDURE.
FUNCTION format-etime RETURNS CHARACTER
(INPUT p-etime AS INT64  )
:
  if p-etime = ?
  then do:
    return "?????????????" .
  end.
  assign
    p-etime = p-etime / 1000
  .
  return
    string( p-etime, '->>>>>>>9')
    + ' '
    + string( p-etime, 'HH:MM:SS')
  .
END FUNCTION.
find first dst.sys-ctrl no-lock no-error.
if avail dst.sys-ctrl then
  return error 'Сжатие БД невозможно, т.к. база-приемник уже имеет данные.'.
define variable vFullTables as character no-undo.
define buffer old-user for ub._user.
define buffer new-user for dst._user.
define stream sToFile.
os-create-dir value(iWrkDir).
vFullTables = substitute("&1\&2",iWrkDir,iTables).
output stream sToFile to value(vFullTables).
if search(vFullTables) = ? then
  return error substitute("Не удалось открыть файл &1", vFullTables).
run write-to-log in this-procedure
   ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +
     chr(10) + "Формируем список таблиц для выгрузки." + chr(10)
   ,p-handle-callback
).
for each dst._file no-lock where
         not dst._file._file-name begins "_"
:
  put stream sToFile unformatted dst._file._file-name skip.
end.
output stream sToFile close.
run write-to-log in this-procedure
   ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +
     chr(10) + "Переносим пользователей." + chr(10)
   ,p-handle-callback
).
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  for each old-user no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    find first new-user no-lock
      where new-user._userid = old-user._userid
      no-error .
    if not available new-user then do:
      create new-user.
      buffer-copy old-user except _TenantId to new-user.
    end.
  end.
end.
