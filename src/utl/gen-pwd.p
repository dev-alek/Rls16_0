
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запускалка браузера техпроливов

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

using utl.*.

block-level on error undo, throw.

define input parameter parParentProc as handle no-undo .

define variable mForm as class gpwdbrw no-undo.
define variable mForm2 as class gpwdbrw2 no-undo.
  /* --- для cmp/vssrevis.i --- */
    define variable vss-revision       as character no-undo init "$Revision$":U .
    define variable vss-author         as character no-undo init "$Author$":U .
    define variable vss-date           as character no-undo init "$Date$":U .
    define variable vss-workfile       as character no-undo init "$Workfile$":U .
    define variable vss-archive        as character no-undo init "$Archive$":U .
    define variable vss-description    as character no-undo init "Экранные триггеры промо-акций". 
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
if ibs.th.gbl.gbl-var:g#db-num ne 0 then
do:
   System.Windows.Forms.MessageBox:Show(
      "Пункт меню доступен только в ГБД.",
      "Внимание!",
      System.Windows.Forms.MessageBoxButtons:OK,
      System.Windows.Forms.MessageBoxIcon:Error).
   return.
end.

assign
   session:debug-alert = yes
   session:error-stack-trace = yes
.
{ gbl/getcntxt.i def }

{ cmp/library.i }
{ gbl/getcntxt.i get }
 define variable mOk as logical no-undo.
 { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj }
{ gbl/chk-actg.i
   v-cntxt-db-num
   v-cntxt-userid
   {&action-head-code-main}
   'actn_gen-pwd':U
   {&cntxt-firm}
   v-cntxt-host-code-obj
   '':U
   0
   0
   0
   0
   true
   mOK
 }
 if not mOk then
      return .
 gpwdbrw:parParentProc = parParentProc.  
define variable v-sys-key   as character         no-undo.

   { gbl/currsysk.i
      v-sys-key 
      no-error
   }                                                      
   if v-sys-key eq "SibintekTechProl"
   then do:
      mForm2 = new utl.gpwdbrw2().
      
      if valid-object(mForm2) then
          mForm2:Wait().
   end.       
   else do:
      mForm = new utl.gpwdbrw().
      
      if valid-object(mForm) then
          mForm:Wait().
   end.    
catch mErr as Progress.Lang.Error :
   
   System.Windows.Forms.MessageBox:Show(
      quoter(mErr:GetMessage(1)) + " " +
      quoter(mErr:GetMessage(2)) + " " + 
      quoter(mErr:GetMessage(3)) + " " + 
      quoter(mErr:CallStack),
      "Ошибка!",
      System.Windows.Forms.MessageBoxButtons:OK,
      System.Windows.Forms.MessageBoxIcon:Error).
   
end catch.

finally:
   mForm:DisposeForm().   
end finally.
