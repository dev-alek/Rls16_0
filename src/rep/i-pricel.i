/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение ТТ признаками с бар-кодами с ценами и с количеством по gds-cod.

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 01/16/03 1:31

*/
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then


define temp-table temp-prt no-undo
field b-code     like  ub.bar-code.b-code
field prt-code   like  ub.prt-obj.prt-code
field fact-qnty  like  ub.prt-obj.fact-qnty
field free-qnty  like  ub.prt-obj.free-qnty
field price-sale like  ub.prt-obj.price-sale
index by-b-code b-code
index by-prt-code prt-code
.

&else

procedure make-temp-table :
 do
 on error undo, return error return-value
 :
define input parameter p-gds-code like ub.goods.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

define buffer l_goods for ub.goods       .
define buffer l_bar-code for ub.bar-code .
define buffer l_prt-obj  for ub.prt-obj  .

for each temp-prt : delete temp-prt. end.

find first  l_goods where l_goods.gds-code = p-gds-code no-lock .
for each l_bar-code where
        l_bar-code.gds-code    = p-gds-code and
        l_bar-code.in-code     = ""         and
        l_bar-code.part-code   = ""         and
        l_bar-code.unit-cli    = l_goods.unit-base   no-lock :

        create temp-prt .
        assign
          temp-prt.b-code     = l_bar-code.b-code
          temp-prt.prt-code   = l_bar-code.node-code
        .

     find first l_prt-obj  where
                l_prt-obj.artic     = l_goods.artic    and
                l_prt-obj.prod-code = l_goods.prod-code  and
                l_prt-obj.prod-type = l_goods.prod-type  and
                l_prt-obj.obj-code  = p-obj-code         and
                l_prt-obj.obj-type  = p-obj-type         and
                l_prt-obj.prt-code  = l_bar-code.node-code
                use-index pi NO-LOCK NO-ERROR .
        if available l_prt-obj then do:
            assign
              temp-prt.fact-qnty   = l_prt-obj.fact-qnty
              temp-prt.free-qnty   = l_prt-obj.free-qnty
              temp-prt.price-sale  = l_prt-obj.price-sale
            .
        end.
        else do:
          /* если нет на объекте то удаляем строку */
          delete temp-prt .
        end.
 end. /* for each */
 end. /* do */
end procedure. /* make-temp-table */

&endif