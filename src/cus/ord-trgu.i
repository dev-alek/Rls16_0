/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггера интерфейса в заказах

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/15/01 5:07

hold-doc-code-child = "no-hold" .
hold-doc-code-parent = "no-hold" .

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cus/ord-trg2.i MSD loc-date-ship loc-time-ship}
{ cus/ord-trg2.i MSD loc-time-ship paytype}
{ cus/ord-trg2.i MSD loc-service b-add}
/* триггера на agnt boss wrkr */
{ cus/ord-trg2.i trg wrkr agnt}
{ cus/ord-trg2.i trg agnt boss}
{ cus/ord-trg2.i trg boss paytype}


ON CHOOSE OF r-contract IN FRAME Dialog-Frame /* r-button */
DO:
 run r-contract-choose in this-procedure no-error .
 if error-status :error then return no-apply .
END.

ON CHOOSE OF r-paytype IN FRAME Dialog-Frame /* r-button */
DO:
   run r-paytype-CHOOSE in this-procedure .
end.

ON LEAVE OF paytype IN FRAME Dialog-Frame /* Код */
DO:
   run paytype-leave-proc in this-procedure .
end.


ON  return OF paytype IN FRAME Dialog-Frame /* Код */
DO:
    run apply-focus-next-entry in this-procedure  (input  PAYTYPE:handle ) .
    return no-apply .
END.

ON LEAVE OF loc-time-ship IN FRAME Dialog-Frame /* Код */
DO:
   run leave-loc-time-ship in this-procedure .
END.

ON  return OF loc-time-ship IN FRAME Dialog-Frame /* Код */
DO:
   run apply-focus-next-entry in this-procedure  (input  PAYTYPE:handle ) .
   return no-apply .
END.

ON VALUE-CHANGED of TOG-type IN FRAME {&frame-name} /* цикличный */
DO:
  run vg-TOG-type in this-procedure .
End.

ON LEAVE  OF loc-cli-type IN FRAME Dialog-Frame /* Код */
DO:
  run LEAVE-loc-cli-type in this-procedure.
END.

ON  RETURN OF loc-cli-type IN FRAME Dialog-Frame /* Код */
DO:
  run apply-focus-next-entry in this-procedure  (input  loc-cli-code :handle ) .
END.

ON LEAVE OF loc-cli-code IN FRAME Dialog-Frame /* Код */
DO:
  run LEAVE-loc-cli-code in this-procedure no-error .
  if error-status :error then do:
     apply "choose" to r-clients in frame {&frame-name} .
  end.
  if can-find (first ub.contract where ub.contract.cli-code = loc-cli-code and ub.contract.cli-type = loc-cli-type and ub.contract.host-code = v-cntxt-host-code-obj) then do:
    if loc-cli-code <> ? then do: 
      run r-contract-choose in this-procedure no-error .
      if error-status :error then return no-apply .
    end.
  end.
END.

ON  RETURN OF loc-cli-code IN FRAME Dialog-Frame /* Код */
DO:
  run apply-focus-next-entry in this-procedure  (input  loc-cli-code :handle ) .
  return no-apply .
END.

ON any-key OF loc-cli-code IN FRAME Dialog-Frame /* Код */
DO:
  v-fl = false .
END.

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
/*   message  'end-error' skip ERROR-STATUS:ERROR. */
  ERROR-STATUS:ERROR = false .
  return .
end.
/*------------------------------------------------------------------------------------------------------------------*/
/* быстрое заполнение формы */
ON MOUSE-SELECT-DBLCLICK OF loc-cli-code IN FRAME {&frame-name}
DO:
  apply "choose" to r-clients in frame {&frame-name}.
  apply "entry" to loc-date-ship  in frame {&frame-name}.
end.

ON MOUSE-SELECT-DBLCLICK OF paytype IN FRAME {&frame-name}
DO:
  apply "choose" to r-paytype in frame {&frame-name}.
  apply "entry" to wrkr  in frame {&frame-name}.
end.

ON CHOOSE OF r-clients IN FRAME Dialog-Frame /* r-cli */
DO:
  run r-clients-ch in this-procedure no-error  .
  if error-status :error then return no-apply.
  if can-find (first ub.contract where ub.contract.cli-code = loc-cli-code and ub.contract.cli-type = loc-cli-type and ub.contract.host-code = v-cntxt-host-code-obj) then do:
    if loc-cli-code <> ? then do: 
      run r-contract-choose in this-procedure no-error .
      if error-status :error then return no-apply .
    end.
  end.
END.

ON value-changed OF slt_type IN FRAME {&frame-name}
OR value-changed OF VAT_type IN FRAME {&frame-name} run val-ch-type in this-procedure (input self:name) no-error.

ON LEAVE, return OF loc-exch-rate  IN FRAME {&frame-name}
OR LEAVE, return OF loc-exch-scale IN FRAME {&frame-name}
OR LEAVE, return OF loc-base-rate  IN FRAME {&frame-name}
OR LEAVE, return OF loc-base-scale IN FRAME {&frame-name}
DO:
   run update-rate-doc in this-procedure no-error.
   if error-status:error then do:
      run disp-exch in this-procedure .
      return no-apply.
   end.
END.
ON RETURN, leave OF loc-exch-code IN FRAME {&frame-name}
DO:
   run choice-currency in this-procedure no-error.
   if error-status:error then return no-apply.
   run update-rate-doc in this-procedure no-error.
END.

ON CHOOSE OF r-currency IN FRAME {&frame-name}
DO:
run r-proc-currency in this-procedure no-error.
if error-status:error then return no-apply.
END.

ON CHOOSE OF r-acc IN FRAME {&frame-name}
DO:
 run r-acc-proc in this-procedure .
END.

ON LEAVE OF loc-base-rate  IN FRAME {&frame-name} OR
   LEAVE OF loc-base-scale IN FRAME {&frame-name} DO:
   run check-rate in this-procedure no-error.
   if error-status:error then return no-apply.
   run UI-on in this-procedure .
END.
/* ввод время*/
ON CURSOR-DOWN OF loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} loc-hour .
  loc-hour = loc-hour -  1.
  if loc-hour < 0 then return no-apply.
  display loc-hour with frame {&frame-name}.
END.

ON CURSOR-UP OF loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} loc-hour .
  loc-hour = loc-hour +  1.
  if loc-hour > 24 then return no-apply.
  display loc-hour with frame {&frame-name}.
END.

ON LEAVE OF loc-hour IN FRAME Dialog-Frame /* Время */
DO:
  assign frame {&frame-name} loc-hour .
   if loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

ON CURSOR-DOWN OF loc-min IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} loc-min .
  loc-min = loc-min -  1.
  if loc-min < 0 then return no-apply.
  display loc-min with frame {&frame-name}.
END.

ON CURSOR-UP OF loc-min IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} loc-min .
  loc-min = loc-min +  1.
  if loc-min > 59 then return no-apply.
  display loc-min with frame {&frame-name}.
END.

ON LEAVE OF loc-min IN FRAME Dialog-Frame
DO:
 run leave-loc-min in this-procedure   no-error .
     if error-status :error then return no-apply.
END.


procedure vg-TOG-type :
  Assign frame  {&frame-name}
  tog-type .
   If tog-type = 1  then Do:
      view    t          in   frame {&frame-name}
              cycle-day  in   frame {&frame-name} .
      display t cycle-day  with frame {&frame-name} .
      Enable  t cycle-day  with frame {&frame-name} .
      display t cycle-day  with frame {&frame-name} .
   End.
   Else DO: Hide  t  cycle-day  in frame {&frame-name}. End.
end procedure.

procedure leave-loc-min:
   assign frame {&frame-name} loc-min .
   if loc-min > 59 then do:
      message "Минуты должны быть  от 0 до 59 ! " .
      return error.
      end.
end procedure.


procedure leave-loc-time-ship :
  Assign frame {&frame-name} loc-time-ship .
    if integer(entry(1,loc-time-ship,":")) > 24 then
      DO:
          Message "Неправильно задано время !" view-as alert-box error .
          apply "entry" to loc-time-ship  in frame {&frame-name}.
      End.
    if integer(entry(2,loc-time-ship,":")) > 60 then
      DO:
          Message "Неправильно задано время !" view-as alert-box error .
          apply "entry" to loc-time-ship  in frame {&frame-name}.
      End.
end procedure.

/* $Workfile$ e n d */