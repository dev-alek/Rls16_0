/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Промо-акции

Автор: Молотков Сергей
Дата создания: 21/06/18
Author: Molotkov Sergey
Creation date: 21/06/18

*/
 

block-level on error undo, throw.
/*session:system-alert-boxes = yes.
session:appl-alert-boxes = yes.
session:debug-alert = yes.*/
SESSION:ERROR-STACK-TRACE=YES.

define input  parameter parparentproc as handle no-undo .
define input  parameter iChange as logical  no-undo .
define output parameter oSubs   as class ibs.th.ref.promo.promoActionSubs no-undo .
  define variable v-listact-brw as class ibs.th.ref.promo.wListActions no-undo .
  
  v-listact-brw = new ibs.th.ref.promo.wListActions ( 
  ).
  //iChange = not iChange.
  v-listact-brw:parparentproc = parparentproc.
  v-listact-brw:Visual_Buttons(iChange). 
  wait-for  v-listact-brw:ShowDialog() .
  if iChange 
  then 
     oSubs = v-listact-brw:oPromoActionSubs.
  /*define variable vPromoTrg as class ibs.th.ref.promo.promo_trg no-undo .
vPromoTrg = new ibs.th.ref.promo.promo_trg () .

vPromoTrg:BrwPromoAction().
  */
  
define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message v-err-msg  view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg /*skip exProErrors:CallStack*/ view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg /*skip exAnyErrors:CallStack*/ view-as alert-box.
  end catch .
finally:
    SESSION:ERROR-STACK-TRACE=no. 
   if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
end finally.  
/*
finally:
    SESSION:ERROR-STACK-TRACE=no. 
    if valid-object(vPromoTrg) 
    then 
       delete object vPromoTrg no-error .
  end finally.
*/