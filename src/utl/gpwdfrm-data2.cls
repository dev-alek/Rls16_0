/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс-прослойка для работы с БД формы gpwdfrm

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/
 
using Progress.Lang.*.
using utl.*.

block-level on error undo, throw.

class utl.gpwdfrm-data2: 
   
   { cmp/str-glbl.i class }
   
   method public "System.Collections.Generic.List<System.Object>" GetList(iSuppParent as char):
      def buffer code for ub.code.
      
      def var vItem as class net-item no-undo. 
      def var vList as class "System.Collections.Generic.List<System.Object>" no-undo.
      vList = new "System.Collections.Generic.List<System.Object>"().
      vItem = new net-item("",
                              "",
                              "").
      vList:Add(vItem).
      
      if iSuppParent eq ""
      then
         return vList.
      if(num-entries (iSuppParent,{&delim-par}) > 1 )
      then
         for each code where Code.parent = iSuppParent  no-lock by int(code.code):
            
            vItem = new net-item(Code.code,
                                 substitute ("&2&1&3",{&delim-par},iSuppParent,Code.code),
                                 Code.CodeName).
            vList:Add(vItem).
         end.
      else
         for each code where Code.parent = iSuppParent  no-lock :
            
            vItem = new net-item(Code.code,
                                 substitute ("&2&1&3",{&delim-par},iSuppParent,Code.code),
                                 Code.CodeName).
            vList:Add(vItem).
         end.
      
      return vList.

   end method.

   method public "System.Collections.Generic.List<System.Object>" GetUserList():
      
      def var vItem as class net-item no-undo. 
      def var vItems as class "System.Collections.Generic.List<System.Object>" no-undo.
      
      vItems = new "System.Collections.Generic.List<System.Object>"().
      
      return vItems.

   end method.

   method public net-item GetObj(iSurr as char):
      def buffer code for ub.code.

      define variable vNetItem as class net-item no-undo.

      vNetItem = new net-item().
      
      define variable vPos    as integer   no-undo.
      define variable vParent as character no-undo.
      define variable vCode   as character no-undo.
      vPos = r-index (isurr,{&delim-par}).
      if( vPos eq  0)
      then assign
         vParent = "cashobj"
         vCode   = iSurr.
      else assign
         vParent = substring (iSurr,1,vpos - 1)
         vCode   = substring (iSurr,vpos + 1).
      find first code where Code.parent eq vParent
                        and Code.code   eq vcode
      no-lock no-error.
      
      if avail code then
      do:
         assign
            vNetItem:DisplayName = code.code
            vNetItem:Value = iSurr
            vNetItem:Desctiption = Code.CodeName
         .

      end.
      else assign
            vNetItem:DisplayName = vcode
            vNetItem:Value       = vcode
         .

      return vNetItem.
      
   end.
   
   method public char GetUserLogin():
            
      define variable vUserLogin as char no-undo.
      define buffer buf_user-account for ub.user-account .
      
      vUserLogin = ibs.th.gbl.gbl-var:g#userid.

      return vUserLogin.
      
   end method.
   
   method public void ValidateForm(
      iComboBoxRegion as System.Windows.Forms.ComboBox,
      iComboBoxShop   as System.Windows.Forms.ComboBox,
      iComboBoxCash   as System.Windows.Forms.ComboBox):
      
      def buffer code for code.
      define variable vParent as character no-undo init "CashObj".
      define variable vCode as character no-undo.
      vCode = iComboBoxRegion:text.
      
      if not can-find(code where 
                      Code.parent = vParent
                  and Code.code   = vCode
                  no-lock) then
      do:
         iComboBoxRegion:Focus().
         undo, throw new ValidateError("Регион не найден в базе",-1).
      end.
      
      vParent = vParent + {&delim-par} + vCode.                  
      vCode = iComboBoxShop:text.
      if not can-find(code where 
                      Code.parent = vParent
                  and Code.code   = vCode
                  no-lock) then
      do:
         iComboBoxShop:Focus().
         undo, throw new ValidateError("Код магазина не найден в базе",-1).
      end.
      
      vParent = vParent + {&delim-par} + vCode.                  
      vCode = iComboBoxCash:text.
      if not can-find(code where 
                      Code.parent = vParent
                  and Code.code   = vCode
                  no-lock) then
      do:
         iComboBoxCash:Focus().
         undo, throw new ValidateError("Код кассы не найден в базе",-1).
      end.
   end method.
   
   method public char GetCli():
      def buffer bclients for clients.
      def var v-rid-list as char no-undo.
      def var vCli       as char no-undo.
      
      run ref/cli-all.w (gpwdbrw:parParentProc
                  ,input "b-sel"
                  ,input {&prs}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input "":U
                  ,output v-rid-list) no-error.
      
      if (v-rid-list <> "" or v-rid-list <> ?) and num-entries(v-rid-list) = 1 then
      do:    
                 
         for first bclients where 
             recid(bclients) = int64(v-rid-list) 
         no-lock:
            vCli = bclients.obj-name.
         end.
         
      end.      
      return vCli.
   end method.
   
end class.