/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Fact-order

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 09/18/01
*/

/* Fact-order
    run aht-ostatok (
        input   x-store-code  ,
        input   x-store-type  ,
        input   x-tog-shift   ,
        input   x-date-start  ,
        input   x-date-end    ,
        input   {&arh-cost}   ,
        input   xTog-obj      ,
        output  Fact-order).

*/
/*------------------------------------------------------------------------------
  Purpose:  Найти Остатки на начало и конец и соответстенные FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ
  IF (NOT xTog-obj) если нужен по всем объектам из списка слитно
------------------------------------------------------------------------------*/
/* { cmp/obj-list.i }  список объектов нужен обязательно !!! */
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE aht-ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.aht-stk.Fact-date   no-undo.
def input parameter x-date-end    like ub.aht-stk.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.aht-stk.stk-type    no-undo.
def input parameter xTog-obj   as log no-undo.

def output parameter Fact-order  like ub.aht-stk.Fact-order  no-undo.

def var              Fact-order#   like ub.aht-stk.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.

def var x-date-start-t  like ub.aht-stk.shift-date   no-undo.

&SCOP find-aht-stk   find last ub.aht-stk where ub.aht-stk.obj-type = obj-list.obj-type and~
                                             ub.aht-stk.obj-code = obj-list.obj-code and~
                                             ub.aht-stk.stk-type = x-sum-type

&SCOP assign-fact-order   Assign  Fact-order#  = ub.aht-stk.Fact-order .


    Assign
      Fact-order   = 0
     .
/* Определяем факт-ордер на начало периода */

 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   For each obj-list
       WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
              no-lock :
      IF  x-TOG-Shift = False Then DO:
      /* календарные даты */
                       {&find-aht-stk}
                            and ub.aht-stk.Fact-date <=  x-date-start
                            and ub.aht-stk.shift-num = 0
                            USE-INDEX obj-date no-lock no-error .
           if Available ub.aht-stk THEN  {&assign-fact-order}
      End.

      Else  DO :
      /* смены */
          {&find-aht-stk} and
            (ub.aht-stk.shift-date  = x-date-start-t and
            ub.aht-stk.shift-num  < x-shift-start or
            ub.aht-stk.shift-date  < x-date-start-t  )
            and ub.aht-stk.shift-num  > 0
            USE-INDEX obj-Shift no-lock no-error .

         If Available ub.aht-stk then  {&assign-fact-order}
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
       {&find-aht-stk} and
            ub.aht-stk.Fact-date <= x-date-end
            and ub.aht-stk.shift-num = 0
            USE-INDEX obj-date no-lock no-error.
       If Available ub.aht-stk then  {&assign-fact-order}
   END.

   Else DO:
   /* смены */
        {&find-aht-stk} and
            (ub.aht-stk.shift-date  = x-date-end and
            ub.aht-stk.shift-num  <= x-shift-end or
            ub.aht-stk.shift-date  < x-date-end       ) and
            ub.aht-stk.shift-num   > 0      use-index obj-Shift no-lock no-error.

            if Available ub.aht-stk THEN {&assign-fact-order}
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