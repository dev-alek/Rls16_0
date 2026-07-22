block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: sibinek-soft $
$Date: 20/01/2026 $
$Workfile: pressdbdump.p $
$Archive: utl/pressdbdump.p $

Сжатие БД. Выгрузка данных таблиц БД.

Автор: Ростовцев Александр
Дата создания: 20.01.2026
Author: Aleksandr Rostovtsev
Creation date: 20/01/2026

*/

/* Parameters Definitions ---                                           */


define input parameter iFileTables as character no-undo.
define input parameter iDbSrc      as character no-undo.
define input parameter p-handle-callback     as handle    no-undo . /* вопросительный знак или указатель на вызываемую процедуру */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 20/01/2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pressdbdump.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pressdbdump.p $":U .
define variable vss-description as character no-undo init "Сжатие БД. Выгрузка данных таблиц БД.".
{ cmp/str-glbl.i }
{ utl/cut-load.i &filename="press_db.log"}

define variable vTable   as character no-undo.
define variable vDumpDir as character no-undo.
define variable vCmd     as character no-undo.
define variable vLetter  as character no-undo.
define variable vError   as integer   no-undo.
define stream sFromFile. 

vDumpDir = substring(iFileTables, 1, r-index(iFileTables,"\") - 1).

input stream sFromFile from value(iFileTables). 

run write-to-log in this-procedure
   ( "Выгружаем данные таблиц БД в " + vDumpDir + "." + {&new-line}
   ,p-handle-callback
).


repeat:
  import stream sFromFile vTable.  

  if vLetter ne substring(vTable, 1, 1) then
  do:
    vLetter= substring(vTable, 1, 1).
    run write-to-log in this-procedure
       ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') + 
         " Выгружаем таблицы " + vLetter + "*." + {&new-line}
       ,p-handle-callback
    ).
  end.
  vCmd = substitute(
    "&4 &1 -C dump &2 &3",
    iDbSrc,
    vTable,
    vDumpDir,
    entry(1,search("proutil.bat"),".")).
  os-command silent value(vCmd).
  vError = os-error.
  if vError <> 0 then
    return error substitute("Таблица &1; Ошибка &2.", vTable, vError).
end.

input stream sFromFile close.
