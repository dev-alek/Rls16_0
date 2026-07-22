 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отсылки данных по соответствию товаров/кошельков

Автор: Шкляр Елена
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i  }
{ ref/extclass.i }

procedure putc-petrol :
   define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
   define input parameter p-version like ub.cash-desk.version no-undo .
   define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
   define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
   define input parameter recid-list as character no-undo .
   define input parameter p-is-del as character no-undo .

   define buffer buf_code for ub.code.
   
   do
      on error undo, return error
      :
       
      run bgelib-tag-open in this-procedure ( input 2, input "FuelCodeInfo", input substitute("ctrl='&2' code='&1'", "*", "DEL":u)).
      run bgelib-tag-close in this-procedure ( input 2, input "FuelCodeInfo").

      if p-is-del = "U"  then 
      do:
        for each buf_code no-lock where 
                 buf_code.parent = "FuelCodeInfo":
            run bgelib-tag-open in this-procedure ( input 2, input "FuelCodeInfo"
              , input substitute("ctrl='&2' code='&1'", buf_code.code, "ADD":u)).
            run bgelib-tag-put in this-procedure ( input 3, input "FCIExtCode", input buf_code.CodeValue, input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "FCIExtId", "0", input 1 ).
            run bgelib-tag-put in this-procedure ( input 3, input "FCIExtName", input "РН-КАРТ", input 1 ).
            run bgelib-tag-close in this-procedure ( input 2, input "FuelCodeInfo").    
        end.
     end.
   end.
end procedure. /* putc-par */

/* $Workfile$ e n d */
