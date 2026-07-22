block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: logevent.p $
$Archive: gbl/logevent.p $

Модуль регистрации сообщений

Автор: Перваков Михаил Сергеевич
Дата создания: 01/31/01
Author: Mikhail Pervakov
Creation date: 01/31/01

*/


define input  parameter p-server-name as character no-undo .
define input  parameter p-event       as character no-undo .
define input  parameter p-parameters  as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: logevent.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/logevent.p $":U .
def var vss-description as character no-undo init "Модуль регистрации сообщений".
/*{ cmp/vssrevis.i }  -  сюда нельзя включать данный файл - будет бесконечная рекурсия */
{ cmp/str-glbl.i }

do
on error undo, return error return-value
:
  def var v-command-name as character no-undo .

  def var v-logger-name as character no-undo .

  if p-event = ? then do:
    assign
      p-event = ""
    .
  end.
  if p-parameters = ? then do:
    assign
      p-parameters = '?'
    .
  end.

  assign
    v-logger-name = search("logevent.exe":u)
  .

  if v-logger-name <> ? then do:
    assign
      v-command-name  = v-logger-name
                      + (if p-server-name <> "" then " -m " + p-server-name + " " else "")
                      + (if p-event <> "" then " -r " + p-event + " " else "")
                      + " " + {&double-quote} + trim(p-parameters) + {&double-quote}
    .

    os-command silent /*no-wait*/ value (
      v-command-name
      ).

  end.
end.