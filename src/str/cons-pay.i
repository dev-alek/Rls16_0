/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает кол-во и суммы в учет. ценах по строчке накладной (doc-line)

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
/* Внутренняя процедура. Возвращает кол-во и суммы в учет. ценах по строчке накладной (doc-line)
    по КОНСИГНАЦИОННОМУ и по ВЫКУПНОМУ товару отдельно .
    В вызывающей пр-ме д.б. : определения 6 переменных */


procedure cons-pay:
def param buffer d-l for doc-line.
def output param cons-qnty as dec no-undo init 0.
def output param cons-base as dec no-undo init 0.
def output param cons-rubl as dec no-undo init 0.
def output param vik-qnty as dec no-undo init 0.
def output param vik-base as dec no-undo init 0.
def output param vik-rubl as dec no-undo init 0.


def buffer p-b for parts-bak.
def buffer t-d for trn-doc.

for each p-b where p-b.out-code = d-l.doc-code
                        and p-b.artic = d-l.artic
                        and p-b.prod-type = d-l.prod-type
                        and p-b.prod-code = d-l.prod-code
                        and p-b.obj-type = d-l.obj-type
                        and p-b.obj-code = d-l.obj-code no-lock:
    find t-d where t-d.doc-code = d-l.doc-code no-lock.
    if t-d.pay-code = g#cons-pay then
       assign
         cons-qnty = cons-qnty + p-b.qnty
         cons-base = cons-base + p-b.price-base * p-b.qnty
         cons-rubl = cons-rubl + p-b.price-rubl * p-b.qnty .
    else
       assign
         vik-qnty = vik-qnty + p-b.qnty
         vik-base = vik-base + p-b.price-base * p-b.qnty
         vik-rubl = vik-rubl + p-b.price-rubl * p-b.qnty.
end.
end procedure.