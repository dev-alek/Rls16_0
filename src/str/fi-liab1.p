block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fi-liab1.p $
$Archive: str/fi-liab1.p $

финансовые обязательства

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 10/17/03 3:59


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fi-liab1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fi-liab1.p $":U .
define variable vss-description as character no-undo init "финансовые обязательства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i  }
define input parameter parParentProc  as widget-handle no-undo.
define input parameter number-menu as integer no-undo .
define input parameter par-host-code like ub.clients.obj-code no-undo.
define variable  bttns      as character no-undo.
define variable  par-mode   as character no-undo.
define variable  pardoc-rec as recid     no-undo.
define variable  rid-list   as character no-undo. /* список recid'ов выбранных */
define variable  p-doc-type as character no-undo.
define variable  p-status_  as character no-undo.
define variable  p-char     as character no-undo init "".

bttns    = "b-del,b-add,b-chg,b-lkp,b-exec-fo"   .

case number-menu :

  when 0 then do: /* все по фирме */
     par-mode = {&company}       .
     p-doc-type = ? .
     p-status_  = ? .
  end.


  when 1 then do:       /*Все приходные*/
     bttns    =  bttns   + ",no-B-PFO" .
     par-mode   = "doc-type":U .
     p-doc-type = {&income} .
     p-status_  = ? .
  end.
  when 11 then do:       /*приходные новые */
     bttns    =  bttns   + ",no-B-PFO" .
     par-mode   = "status":U .
     p-doc-type = {&income} .
     p-status_  = {&fin-new} .
  end.
  when 12 then do:       /*приходные fact */
     bttns    = "b-lkp,b-exec-fo,no-B-PFO"   .
     par-mode   = "status":U .
     p-doc-type = {&income} .
     p-status_  = {&fin-fact} .
  end.
  when 13 then do:       /*приходные автоматические */
     bttns    = "b-del,b-chg,b-exec-fo,no-B-PFO"   .
     par-mode   = "status":U .
     p-doc-type = {&income} .
     p-status_  = {&fin-gen} .
  end.
  when 14 then do:       /*Просроченные приходные*/
     bttns    =  bttns   + ",no-B-PFO" .
     par-mode   = "doc-type":U .
     p-doc-type = {&income} .
     p-status_  = ? .
     p-char = string(today).
  end.

  when 2 then do:       /*Все расходные*/
  par-mode   = "doc-type":U .
     p-doc-type = {&expense} .
     p-status_  = ? .
  end.
  when 21 then do:       /*расх новые */
     par-mode   = "status":U .
     p-doc-type = {&expense} .
     p-status_  = {&fin-new} .
  end.
  when 210 then do:       /*расх сгенеренные */
     bttns    = "b-del,b-chg,b-exec-fo"   .
     par-mode   = "status":U .
     p-doc-type = {&expense} .
     p-status_  = {&fin-gen} .
  end.

  when 22 then do:       /*расх fact */
  bttns    = "b-lkp,b-exec-fo"   .
     par-mode   = "status":U .
     p-doc-type = {&expense} .
     p-status_  = {&fin-fact} .
  end.
  when 3 then do:       /* пред фин об */
  par-mode   = "doc-type":U .
     p-doc-type = {&expense} .
     p-status_  = ? .

run str/fin-pob.w
(   input parParentProc ,
    input bttns        ,
    input par-mode     ,
    input pardoc-rec   ,
    input par-host-code,
    input p-doc-type   ,
    input p-status_    ,
    input ""           ,
    output rid-list    ) no-error  .
if error-status :error then do:
message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове fin-liab" skip
        error-status :get-message(1)
        view-as alert-box error .
        return error .
        end.
        return .
  end.

end case.

run str/fin-liab.w
(   input parParentProc ,
    input bttns        ,
    input par-mode     ,
    input pardoc-rec   ,
    input par-host-code,
    input p-doc-type   ,
    input p-status_    ,
    input p-char       ,
    output rid-list    ) no-error  .
if error-status :error then do:
message vss-workfile vss-revision vss-description skip
        "Ошибка при вызове fin-liab" skip
        error-status :get-message(1)
        view-as alert-box error .
return error .
end.