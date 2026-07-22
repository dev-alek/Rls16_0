block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: p-actua.p $
$Archive: rep/p-actua.p $

запускалка actuate

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 02/14/03 2:57

*/
define input parameter parparentproc as widget-handle no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: p-actua.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/p-actua.p $":U .
def var vss-description as character no-undo init "запускалка actuate" .
{ cmp/vssrevis.i }
{ rep/par-actu.i }
{ cmp/trg-def.i }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }
{ rep/par-actu.i proc }
define variable exp-name as character no-undo .

define  stream str-export.


  /* создается временный командный файл для выполнения команды */

  run gbl/_tmpfile.p ( "t", ".par", output exp-name) .

/*  message "параметры запуска в файле " exp-name
  .
   */
{ gbl/getcntxt.i get }
 for each  param-to-export : delete  param-to-export. end.
{ rep/par-std.i }
{ rep/par-actu.i run-proc
 "'report-type'"
 "''"
 "'character'"
 "'a'"
 "'тип отчета a= вызов из режима заказные программы'"
}

/* Оставим только те которые нас просят */
for each  param-to-export :
    if  lookup( param-to-export.param-code , "base-key,firm-name,report-type,v-cntxt-obj-code,v-cntxt-obj-type,db-connect" ) = 0 then   delete  param-to-export.
 end.


  OUTPUT STREAM str-export TO  VALUE(exp-name).

      for each param-to-export :
        EXPORT STREAM str-export param-to-export .
      end.

  OUTPUT STREAM str-export CLOSE.

define variable res as integer no-undo .
define variable name-exe as character no-undo .

  assign
    file-info:file-name = "exe/run-act.bat".
    name-exe = file-info:full-pathname
  no-error .
  if error-status :error then return error .

run gbl/syn.p ( input name-exe , input  exp-name , input  "Запуск " + name-exe , output res ).
if  res > 0 then do:
  message  "Ошибка  при выполнении команды в ОС "  res .

end.



/* $Workfile: p-actua.p $ e n d */