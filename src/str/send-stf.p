block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-stf.p $
$Archive: str/send-stf.p $

Пересылка персонала - для АРМ ресторан

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает

/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter i-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
/*"U' "D" "R" - справочник*/
define input parameter p-batch as logical no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-stf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-stf.p $":U .
define variable vss-description as character no-undo init "Пересылка персонала - для АРМ ресторан".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable action as char no-undo.
define variable p-batch as logical no-undo .

{ bge/bgelib.i }
&glob xml-cd-doc-name 'data'
{ str/cd-xml.i }
{ str/defc-csh.i "SHARED" }
{ str/cdsnddef.i }

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action = entry(3, p-parameter, {&delim-par})
p-batch = (if entry(4, p-parameter, {&delim-par}) = "yes":U
                 then yes
                 else (if entry(4, p-parameter, {&delim-par}) = "no":U
                       then no
                       else ?)
                 )


no-error
.
if error-status:error or p-batch = ? then return error.


/*PROCEDURE putc-staff.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-32.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyc32.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen32.i }


RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке информации по персоналу на кассы  &1&2"
                         , p-obj-type
                         , p-obj-code

                        )
                                        ).
  assign
  v-view-log = yes
  .
end.

if p-batch then do:
  if v-view-log then
  run set-view-log in p-log-handle(yes).
end.
else do:
  if v-view-log then
  return error .
end.