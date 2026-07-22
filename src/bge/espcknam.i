/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/02/10
Author: Bakhtadze Natalya
Creation date: 04/02/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


function get-short-pack-name returns character ( input p-action as character
                                                ,input p-pack-num as integer
                                                ,input p-delivery-method as integer
                                                ,input p-custom-pack-name as character
                                                ,output p-custom-flag as logical
                                                ):
define variable v-short-pack-name as character no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_clients for ub.clients.
define variable v-int-point as character no-undo .
define variable v-type as character no-undo .

case p-delivery-method:
 when integer({&esys-dm-oracle-retail}) then do:
   find first buf_clients no-lock where
            buf_clients.db-num = g#db-num
         and buf_clients.obj-type = {&shop} no-error .
   if not available buf_clients then do:
    find first buf_clients no-lock where
              buf_clients.db-num = g#db-num
          and buf_clients.obj-type = {&stock} no-error .
   end.
   case p-action:
     when "put"
     or when "fput" then do:
        v-short-pack-name = (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "-" + "000" + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
     when "get"
     or when "fget" then do:
       v-short-pack-name = "000" + "-" +
                           (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
   end case.
   p-custom-flag = yes.
 end.
 when integer({&esys-dm-exite-edi}) then do:
    /*при входе в эту процедуру надо взять первый попавшийся из директории exch*/
   /*проверим что файл с таким timestamp больше чем закачанный*/
   if p-action = "get" then do:
     find first buf_esys-pck-rcvd  where
                buf_esys-pck-rcvd.espr-pack-num = p-pack-num - 1
            and buf_esys-pck-rcvd.esys-id = p-esys-id
            and buf_esys-pck-rcvd.db-num = p-db-num
            and buf_esys-pck-rcvd.espr-cr-db-num = g#db-num no-error.
     if available buf_esys-pck-rcvd
     and (p-custom-pack-name = ""
          or
          num-entries(p-custom-pack-name, "_") < 2
          or  (num-entries(buf_esys-pck-rcvd.custom-pack-name, "_") >= 2
               and entry(2, buf_esys-pck-rcvd.custom-pack-name, "_") >= entry(2, p-custom-pack-name, "_")
               )
          ) then do:
       /*надо сравнивать entry(2, sss, "_") потому что файлы имеют вид
       status_201008131434212.xml
       status_201008131434213.xml*/

       p-custom-flag = yes.
       return ''.
     end.
   end.
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.

 end. /*when integer({&esys-dm-exite-edi}) then do:*/
 when integer({&esys-dm-contour-edi}) then do:
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.
 end.
 when integer({&esys-dm-erp-1C-RN}) then do:
   case p-action:
     when "put"
     or when "fput" then do:
       run db-attr-value in this-procedure 
           (input g#db-num
           ,input {&attr-int-point}
           ,output v-int-point
           ,output v-type
           ) no-error .
       
       p-custom-flag = yes.
       v-short-pack-name = v-int-point + "_00000_" + string(p-pack-num) + "_"
                         + string(day(now), "99") + string(month(now), "99") + string(year(now), "9999")
                         + substring(string(TIME, "HH:MM:SS"), 1, 2)
                         + substring(string(TIME, "HH:MM:SS"), 4, 2)
                         + substring(string(TIME, "HH:MM:SS"), 7, 2)
                         + ".xml" .
     end.
     when "get"
     or when "fget" then do:
       p-custom-flag = yes.
       v-short-pack-name = p-custom-pack-name.
     end. 
   end case.   
 end.
 otherwise do:
   v-short-pack-name = "o":U + string( p-pack-num, "999999999":U ) + ".":U.
 end.
end case.
return v-short-pack-name.
end function.


/* $Workfile$ e n d */