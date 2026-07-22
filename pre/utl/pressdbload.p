block-level on error undo, throw.
define input parameter iDumpDir as character no-undo.
define input parameter iDbRec   as character no-undo.
define input parameter p-handle-callback     as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 20/01/2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pressdbdump.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pressdbdump.p $":U .
define variable vss-description as character no-undo init "Сжатие БД. Выгрузка данных таблиц БД.".
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
define variable vNameFull  as character no-undo.
define variable vNameShort as character no-undo.
define variable vType      as character no-undo.
define variable vCmd       as character no-undo.
define variable vLetter    as character no-undo.
define variable vError     as integer   no-undo.
define stream sFromDir.
input stream sFromDir from os-dir(".\" + iDumpDir).
run write-to-log in this-procedure
   ( "Загружаем данные в новую БД." + chr(10)
   ,p-handle-callback
).
repeat:
  import stream sFromDir vNameShort vNameFull vType.
  if vType <> "F" or entry(2,vNameShort,".") <> "bd" then
    next.
  if vLetter ne substring(vNameShort, 1, 1) then
  do:
    vLetter= substring(vNameShort, 1, 1).
    run write-to-log in this-procedure
       ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +
         " Загружаем таблицы " + vLetter + "*." + chr(10)
       ,p-handle-callback
    ).
  end.
  vCmd = substitute(
    "&3 &1 -C load &2 build indexes",
    iDbRec,
    vNameFull,
    entry(1,search("proutil.bat"),".")).
  os-command silent value(vCmd).
  vError = os-error.
  if vError <> 0 then
    return error substitute("Таблица &1; Ошибка &2.", entry(1,vNameShort,"."), vError).
end.
input stream sFromDir close.
