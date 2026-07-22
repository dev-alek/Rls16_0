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

class utl.gpwdfrm-data: 
   
   { cmp/str-glbl.i class }
   

   method public "System.Collections.Generic.List<System.Object>" GetShopList():
      
      def buffer b-clients for clients.
      
      def var vItem as class net-item no-undo. 
      def var vShopList as class "System.Collections.Generic.List<System.Object>" no-undo.
       
      vShopList = new "System.Collections.Generic.List<System.Object>"().
      
      for each b-clients where b-clients.obj-type = {&shop} no-lock:
         
         vItem = new net-item(string(b-clients.obj-code),
                              b-clients.obj-type + "," + string(b-clients.obj-code),
                              b-clients.obj-name).
         vShopList:Add(vItem).
      end.
      
      return vShopList.

   end method.

   method public "System.Collections.Generic.List<System.Object>" GetCashDeskList(iShopSurr as char):
      
      def buffer b-clients for clients.
      def buffer b-cash-desk for cash-desk.
      
      def var vItem as class net-item no-undo. 
      def var vItems as class "System.Collections.Generic.List<System.Object>" no-undo.
      
      vItems = new "System.Collections.Generic.List<System.Object>"().
      
      find first b-clients where 
                 b-clients.obj-type = entry(1,iShopSurr)
             and b-clients.obj-code = int(entry(2,iShopSurr)) 
      no-lock no-error.
      
      if avail b-clients then
      do:
         for each b-cash-desk where 
                  b-cash-desk.obj-code = b-clients.obj-code 
          and not b-cash-desk.is-del
         no-lock
         by b-cash-desk.cash-num:
            vItem = new net-item(string(b-cash-desk.cash-num),
                                 string(b-cash-desk.db-num) + "," +
                                 string(b-cash-desk.obj-code) + "," +
                                 string(b-cash-desk.pos-type) + "," +
                                 string(b-cash-desk.cash-num)).
            vItems:Add(vItem).
         end.
      end.
      
      
      return vItems.

   end method.

   method public "System.Collections.Generic.List<System.Object>" GetUserList():
      
      def var vItem as class net-item no-undo. 
      def var vItems as class "System.Collections.Generic.List<System.Object>" no-undo.
      
      vItems = new "System.Collections.Generic.List<System.Object>"().
      
      return vItems.

   end method.

   method public net-item GetCashDesk(iSurr as char):
            
      def buffer b-cash-desk for cash-desk.
      
      define variable vNetItem as class net-item no-undo.
      
      vNetItem = new net-item().
      
      find first b-cash-desk where 
                 b-cash-desk.db-num   = int64(entry(1,iSurr))
             and b-cash-desk.obj-code = int64(entry(2,iSurr))
             and b-cash-desk.pos-type = entry(3,iSurr)
             and b-cash-desk.cash-num = int64(entry(4,iSurr))
      no-lock no-error.
      
      if avail b-cash-desk then 
      do:
         assign
            vNetItem:DisplayName = string(b-cash-desk.cash-num)
            vNetItem:Value = iSurr
         .
         
      end.
         
      return vNetItem.
      
   end method.

   method public net-item GetShop(iSurr as char):
            
      def buffer b-clients for clients.
      
      define variable vNetItem as class net-item no-undo.
      
      vNetItem = new net-item().
      
      find first b-clients where 
                 b-clients.obj-type = entry(1,iSurr)
             and b-clients.obj-code = int(entry(2,iSurr)) 
      no-lock no-error.
      
      if avail b-clients then 
      do:
         assign
            vNetItem:DisplayName = string(b-clients.obj-code)
            vNetItem:Value = iSurr
            vNetItem:Desctiption = b-clients.obj-name
         .
         
      end.
         
      return vNetItem.
      
   end method.

   method public char GetShopSurrogate(iShop as char):
            
      def buffer b-clients for clients.
      
      define variable vSurr as character no-undo.
      
      for first b-clients where 
                 b-clients.obj-type = {&shop}
             and b-clients.obj-code = int64(iShop) 
      no-lock:
         vSurr = b-clients.obj-type + "," + string(b-clients.obj-code).
      end.
      
      return vSurr.
      
   end method.

   method public char GetUserLogin():
            
      define variable vUserLogin as char no-undo.
      define buffer buf_user-account for ub.user-account .
      
      vUserLogin = ibs.th.gbl.gbl-var:g#userid.

/*      for first buf_user-account
          where buf_user-account.user-id = vUserLogin
      no-lock:
      
         assign
            vUserLogin = substitute('&1: &2 &3 &4':U
                                    ,vUserLogin
                                    ,buf_user-account.last-name
                                    ,buf_user-account.first-name
                                    ,buf_user-account.second-name
                                    )
         .
      end. */


      return vUserLogin.
      
   end method.
   
   method public void ValidateShop(
      iShop as char, 
      iComboBox as System.Windows.Forms.ComboBox):
      
      def var vShop as int64 no-undo.
      
      def buffer b-clients for clients.
      
      assign
         vShop = int64(iShop) 
      no-error.
      
      if error-status:error 
      or vShop <= 0 then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Неверное значение магазина",-1).
      end.
      
      if not can-find(b-clients where 
                      b-clients.obj-type = {&shop}
                  and b-clients.obj-code = vShop
                  no-lock) then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Код магазина не найден в базе",-1).
      end.                  
      
   end method.
   
   method public void ValidateCashDesk(
      iShopSurr as char, 
      iCashNum  as char,
      iComboBox as System.Windows.Forms.ComboBox):
      
      def var vCashNum as int64 no-undo.
      
      def buffer b-clients   for clients.
      def buffer b-cash-desk for cash-desk.
      
      if num-entries(iShopSurr) <> 2 then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Ошибка с выбором магазина",-1).
      end.
         
      assign
         vCashNum = int64(iCashNum) 
      no-error.
      
      if error-status:error 
      or vCashNum < 0 then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Неверное значение магазина при выборе кассы",-1).
      end.
      
      find first b-clients where 
                 b-clients.obj-type = entry(1,iShopSurr)
             and b-clients.obj-code = int64(entry(2,iShopSurr))
      no-lock no-error.
      
      if not avail b-clients then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Магазин не найден в базе",-1).
      end.
      
      if not can-find(first b-cash-desk where 
                            b-cash-desk.obj-code = b-clients.obj-code
                        and b-cash-desk.cash-num = vCashNum no-lock) then
      do:
         if valid-object(iComboBox) then iComboBox:Focus().
         undo, throw new ValidateError("Нет такой кассы",-1).
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
   
   method public char TransChar(iChar as char):
      define variable vChar as character no-undo.
      
      if length(iChar) = 4 then 
         vChar = substitute("&1:&2",substring(iChar,1,2),substring(iChar,3,4)).
      else
         vChar = iChar.
      return vChar.              
   end method.
      
end class.