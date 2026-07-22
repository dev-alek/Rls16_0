/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение курса базовой ваюты для объекта

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/


procedure proc-cur-rate :

  do
  on error undo, return error return-value
  :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter Rubl_Coeff as decimal   no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
run cur-time in this-procedure ( output v-today, output v-time).


        FIND LAST ub.curr-accnt WHERE ub.curr-accnt.curr-code = v-base-code
                                                 AND ub.curr-accnt.exch-date <= v-today
                                                 NO-LOCK NO-ERROR .
        FIND LAST ub.curr-shop WHERE ub.curr-shop.curr-code = v-base-code
                                                 AND ub.curr-shop.obj-code = p-obj-code
                                                 AND ub.curr-shop.obj-type = p-obj-type
                                                 USE-INDEX pi NO-LOCK NO-ERROR .

        if p-obj-type = {&shop} then
            do:
                if not available ub.curr-shop then
                    do:
                        bell.
                        message "Нет ни одного МАГАЗИННОГО курса базовой валюты к {&abbr_rublyam}.".
                        Rubl_Coeff = 1.
                    end.
                else
                    Rubl_Coeff = ub.curr-shop.exch-rate / ub.curr-shop.exch-scale.
            end.
        else
            do:
                if not available ub.curr-accnt then
                    do:
                        bell.
                        message "Нет ни одного курса ММВБ базовой валюты к {&abbr_rublyam}.".
                        return.
                    end.
                else
                    Rubl_Coeff = ub.curr-accnt.exch-rate / ub.curr-accnt.exch-scale.
            end.

  end.

end procedure. /* proc-cur-rate */