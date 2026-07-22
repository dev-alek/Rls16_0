/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/14/10
Author: Bakhtadze Natalya
Creation date: 01/14/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ ref/extclass.i }
{ gbl/key-rec.i }

procedure dtlpbcod_need-part-b-code  :
define input parameter p-gds-code as integer no-undo .
define input parameter p-esys-id-list as character no-undo .
define output parameter p-need as logical no-undo .

define variable v-ii as integer no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define variable l-cash-parts as logical no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .

define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.


do
on error undo, return error
:

  find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code.
  do v-ii = 1 to num-entries(p-esys-id-list, {&delim-nws}):

    for each buf_ext-classif no-lock where
        buf_ext-classif.classif-name = {&extclass_clients_esys}
    and buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.db-num = 0
    and buf_ext-classif.key#_one = integer(entry(v-ii, p-esys-id-list, {&delim-nws})):
      v-obj-uniq-key-rec  =  buf_Ext-classif.uniq-key-rec.
      /*получим объект*/
      run gen-row-keyr  in this-procedure (
                                             input  v-obj-uniq-key-rec
                                            ,input  ? /* буфер записи которую будем искать. если ищем по key-rec то ? */
                                            ,input  "ub"
                                            ,input  ? /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                            ,input  NO-LOCK
                                            ,output v-tbl-row
                                            ,output v-tbl-name
                                            ) .
      find first buf_clients no-lock where
                rowid(buf_clients) = v-tbl-row .
      { gbl/gdsobjat.i
        buf_clients.obj-type
        buf_clients.obj-code
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        "'cash-parts=request'"
        l-cash-parts
        no-error
      }
       if l-cash-parts then do:
         p-need = yes.
         return .
       end.
    end.
  end.
end.

end procedure. /* need-part-b-code  */



/* $Workfile$ e n d */
