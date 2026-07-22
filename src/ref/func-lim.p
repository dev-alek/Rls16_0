block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: func-lim.p $
$Archive: ref/func-lim.p $

Проведение отсечения по %

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 05/19/05
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: func-lim.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/func-lim.p $":U .
define variable vss-description as character no-undo init "Проведение отсечения по %".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ ref/def-abct.i }
{ gbl/waitfram.i }
{ gbl/thbjattr.i }
define temp-table temp-goods2  no-undo like temp-goods .
define temp-table  x-analysis  no-undo  like ub.abc-analysis.


define input   parameter table for    x-analysis.
define input   parameter table for    temp-goods.
define output  parameter table for    temp-goods2.

run waitfram-show ("Отсечение по проценту...").

/* Определим процентное соотношения товаров */


find first x-analysis no-error .
if error-status :error then
  message vss-workfile vss-revision vss-description skip
  error-status :get-message(1) view-as alert-box error .

define variable LE-proc as decimal   no-undo .
define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.


define variable label-a as character no-undo .
define variable label-b as character no-undo .
case par-abc-type :
   when 'ABC':U
      then do:
      label-a  = "D"  .
      label-b  = "E"  .
      end.
   when 'ABCD':U
      then do:
      label-a = "E"  .
      label-b = "F"  .
      end.
   when 'ABCDE':U
      then do:
      label-a = "F"  .
      label-b = "G"  .
      end.
   when 'ABCDEF':U
      then do:
      label-a = "G"  .
      label-b = "H"  .
      end.
end case.

assign
  LE-proc = x-analysis.LE-proc
  .

for each temp-goods  where  temp-goods.crit = 'B' break by temp-goods.crit-pr desc :
    find first temp-goods2 where temp-goods2.gds-code = temp-goods.gds-code no-error .
    if not available temp-goods2 then do:
       create temp-goods2 .
       BUFFER-COPY temp-goods TO temp-goods2 .
    end.
    if temp-goods.crit-pr <= LE-proc   then do:
       temp-goods2.crit = label-b .
    end.
    else temp-goods2.crit = label-a .
end.
run waitfram-hide.