block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: sibinek-soft $
$Date: 21/01/2026 $
$Workfile: pressdbload.p $
$Archive: utl/pressdbload.p $

Сжатие БД. Загрузка данных таблиц БД.

Автор: Ростовцев Александр
Дата создания: 21.01.2026
Author: Aleksandr Rostovtsev
Creation date: 21/01/2026

*/

/* Parameters Definitions ---                                           */


define input parameter iDumpDir as character no-undo.
define input parameter iDbRec   as character no-undo.
define input parameter p-handle-callback     as handle    no-undo . /* вопросительный знак или указатель на вызываемую процедуру */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 20/01/2026 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pressdbdump.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pressdbdump.p $":U .
define variable vss-description as character no-undo init "Сжатие БД. Выгрузка данных таблиц БД.".
{ cmp/str-glbl.i }
{ utl/cut-load.i &filename="press_db.log"}

define variable vNameFull  as character no-undo.
define variable vNameShort as character no-undo.
define variable vType      as character no-undo.
define variable vCmd       as character no-undo.
define variable vLetter    as character no-undo.
define variable vError     as integer   no-undo.
define stream sFromDir. 

input stream sFromDir from os-dir(".\" + iDumpDir). 

run write-to-log in this-procedure
   ( "Загружаем данные в новую БД." + {&new-line}
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
         " Загружаем таблицы " + vLetter + "*." + {&new-line}
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

/*  run write-to-log in this-procedure                                  */
/*     ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +    */
/*       " Перестраиваем индексы." + {&new-line}                        */
/*     ,p-handle-callback                                               */
/*  ).                                                                  */
/*vCmd = substitute(                                                    */
/*    "c:\dlc1172\bin\proutil &1 -C idxbuild all",                      */
/*    iDbRec).                                                          */
/*os-command silent value(vCmd).                                        */
/*vError = os-error.                                                    */
/*if vError <> 0 then                                                   */
/*  return error substitute("Ошибка перестроения индексов &1.", vError).*/
  