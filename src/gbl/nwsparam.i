/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица, которая будет использоваться в качестве параметра вызова процедур

Автор: Перваков Михаил Сергеевич
Дата создания: 02/27/02
Author: Mikhail Pervakov
Creation date: 02/27/02

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-nwsparam no-undo
  field param-code  as character
  field param-type  as character
  field param-value as character
  index xpk is primary param-code
.

&if "{1}"="proc" &then
  define input parameter p-action as character no-undo .
  define input parameter table for temp-nwsparam .
&endif


procedure nwsparam_clear :

  do
  on error undo, return error return-value
  :
    define buffer buf_temp-nwsparam for temp-nwsparam .

    for each buf_temp-nwsparam
    on error undo, return error return-value
    :
      delete buf_temp-nwsparam .
    end.
  end.

end procedure. /* nwsparam_clear */


procedure nwsparam_append :

  define input  parameter p-param-code  as character no-undo .
  define input  parameter p-param-type  as character no-undo .
  define input  parameter p-param-value as character no-undo .

  do
  on error undo, return error
  :
    define buffer buf_temp-nwsparam for temp-nwsparam .

    create buf_temp-nwsparam .
    assign
      buf_temp-nwsparam.param-code  = p-param-code
      buf_temp-nwsparam.param-type  = p-param-type
      buf_temp-nwsparam.param-value = p-param-value
    .
  end.
end procedure. /* nwsparam_append */


/* $Workfile$ e n d */