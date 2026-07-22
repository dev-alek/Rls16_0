/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Fact-order и остатки на дату

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 09/18/01
*/

/* Fact-order и остатки на дату
    r u n ostatok (
        input   x-store-code  ,
        input   x-store-type  ,
        input   x-tog-shift   ,
        input   x-date-start  ,
        input   x-date-end    ,
        input   {&arh-cost}   ,
        input   x-cat-id      ,
        input   xTog-obj      ,
        output  Quantity      ,
        output  Coast_R       ,
        output  Coast_V       ,
        output  VAT_R         ,
        output  VAT_V         ,
        output  Fact-order).

*/
/*------------------------------------------------------------------------------
  Purpose:  Найти Остатки на начало и конец и соответстенные FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ
  IF (NOT xTog-obj) если нужен по всем объектам из списка слитно
------------------------------------------------------------------------------*/
/* { cmp/obj-list.i }  список объектов нужен обязательно !!! */

PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.

def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.

def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.

&SCOP find-stk-tot   find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and ~
                            ub.stk-tot.obj-code = obj-list.obj-code and ~
                            ub.stk-tot.sum-type = x-sum-type and ~
                            ub.stk-tot.cat-id   = x-cat-id   and

&SCOP assign-fact-order   Assign ~
                          Quantity     = Quantity   + ub.stk-tot.fact-qnty ~
                          Coast_R      = Coast_R    + ub.stk-tot.sum-rubl ~
                          Coast_V      = Coast_V    + ub.stk-tot.sum-base ~
                          VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl ~
                          VAT_V        = VAT_V      + ub.stk-tot.VAT-base ~
                          Fact-order#  = ub.stk-tot.Fact-order.


   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
/* Определяем факт-ордер на начало периода */

 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
      /* календарные даты */
                       {&find-stk-tot}
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  {&assign-fact-order}
      End.

      Else  DO :
      /* смены */
          {&find-stk-tot}
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .

         If Available ub.stk-tot then  {&assign-fact-order}
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End. /* for each */
End. /* finish  -- на начало */


/* Факт- ордер на конец периода */
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
   /* календарные сутки */
       {&find-stk-tot}
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  {&assign-fact-order}
   END.

   Else DO:
   /* смены */
        {&find-stk-tot}
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.

            if Available ub.stk-tot THEN {&assign-fact-order}
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End. /* for each obj-list*/
End.   /* на конец */
/*
message x-date-start-t x-shift-start fact-order skip
        x-date-end     x-shift-end     .
  */
END PROCEDURE.
/* $Workfile$ e n d */