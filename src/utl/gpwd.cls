/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс, в котором генерируется пароль для техпролива

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

block-level on error undo, throw.

&scop num_digits 100000000
 
class utl.gpwd:
   
   /* генерация одноразового пароля */
   method public int64 gen-pwd(
      iObjNum as int64,
      iCashDesk as int64,
      iDate as date,
      iTimeBeg as char,
      iTimeEnd as char):
      
      def var vPass as char no-undo.
      def var vPass64 as int64 no-undo.
      
      def var vCryptoCode as char no-undo.
      def var vCryptoCode64 as int64 no-undo.

      assign
         vPass = this-object:get-char(iTimeBeg)
         vPass = substitute("&1&2",vPass,this-object:get-char(iTimeEnd))
         vPass = vPass + "1"
         vCryptoCode64 = this-object:generateCryptoCode(iObjNum, iCashDesk, iDate)
         vCryptoCode = string(vCryptoCode64)
         vPass = vPass + substring(vCryptoCode,length(vCryptoCode) - 2)
         vPass64 = int64(vPass)
         vPass64 = utl.math:ixor(vPass64  ,int64(vCryptoCode64 * 3 ) modulo {&num_digits})
      .

      return vPass64.
   end method.

   method public int64 generateCryptoCode(
      iObjNum as int64,
      iCashDesk as int64,
      iDate as date):
      
      def var vDate as char no-undo.
      def var vRes as int64 no-undo.
      def var vKey as int64 no-undo.
      
      assign
         vDate = string(iDate,"99/99/9999")
         vDate = replace(vDate,"/","")
         vRes = (int64(vDate) * iObjNum / iCashDesk)
         vRes = utl.math:ixor(int64(vRes * 2),vRes)
         vKey = vRes modulo {&num_digits} 
      .
      
      return vKey.
      
   end method.
   
   method public char get-char(iStr as char):
      
      def var vRet as char no-undo.
      
      case iStr:
         when "00:00" then vRet = "01".
         when "00:30" then vRet = "02".
         when "01:00" then vRet = "03".
         when "01:30" then vRet = "04".
         when "02:00" then vRet = "05".
         when "02:30" then vRet = "06".
         when "03:00" then vRet = "07".
         when "03:30" then vRet = "08".
         when "04:00" then vRet = "09".
         
         when "04:30" then vRet = "10".
         when "05:00" then vRet = "11".
         when "05:30" then vRet = "12".
         when "06:00" then vRet = "13".
         when "06:30" then vRet = "14".
         when "07:00" then vRet = "15".
         when "07:30" then vRet = "16".
         when "08:00" then vRet = "17".
         when "08:30" then vRet = "18".
         when "09:00" then vRet = "19".
        
         when "09:30" then vRet  = "20".
         when "10:00" then vRet = "21".
         when "10:30" then vRet = "22".
         when "11:00" then vRet = "23".
         when "11:30" then vRet = "24".
         when "12:00" then vRet = "25".
         when "12:30" then vRet = "26".
         when "13:00" then vRet = "27".
         when "13:30" then vRet = "28".
         when "14:00" then vRet = "29".
         
         when "14:30" then vRet = "30".
         when "15:00" then vRet = "31".
         when "15:30" then vRet = "32".
         when "16:00" then vRet = "33".
         when "16:30" then vRet = "34".
         when "17:00" then vRet = "35".
         when "17:30" then vRet = "36".
         when "18:00" then vRet = "37".
         when "18:30" then vRet = "38".
         when "19:00" then vRet = "39".
         
         when "19:30" then vRet = "40".
         when "20:00" then vRet = "41".
         when "20:30" then vRet = "42".
         when "21:00" then vRet = "43".
         when "21:30" then vRet = "44".
         when "22:00" then vRet = "45".
         when "22:30" then vRet = "46".
         when "23:00" then vRet = "47".
         when "23:30" then vRet = "48".
         
      end case.
      
      return vRet.
      
   end method.
    
end class.