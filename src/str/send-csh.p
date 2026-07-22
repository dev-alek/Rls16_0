block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-csh.p $
$Archive: str/send-csh.p $

Пересылка кассиров на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
def input parameter i-obj-code like shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
define input parameter p-batch as logical no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-csh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-csh.p $":U .
define variable vss-description as character no-undo init "Пересылка кассиров на кассу".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ str/defc-csh.i SHARED }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }

define variable i-obj-code like ub.clients.obj-code no-undo.
define variable action     as   character no-undo init "U".
define variable p-batch as logical no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
action = entry(2, p-parameter, {&delim-par})
p-batch = (if entry(3, p-parameter, {&delim-par}) = "yes":U
                 then yes
                 else (if entry(3, p-parameter, {&delim-par}) = "no":U
                       then no
                       else ?)
                 )
no-error
.
if error-status:error  or p-batch = ?   then return error.




/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-6.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl6.i }

/*PROCEDURE SENDING.*/
{ str/cd-send6.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &1&2 информации о кассирах", {&shop}, i-obj-code)
                                          ).



RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке информации по кассирам на кассы  маг&1"
                         , i-obj-code
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