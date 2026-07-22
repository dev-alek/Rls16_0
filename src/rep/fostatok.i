/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Fact-order и остатки на дату ПО ФИН АРХИВАМ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/29/10
Author: Bakhtadze Natalya
Creation date: 04/29/10

*/

/* Fact-order и остатки на дату ПО ФИН АРХИВАМ
    r u n fostatok (
        input   p-host-code
        ,input   x-store-code
        ,input   x-store-type
        ,input   x-tog-shift
        ,input   x-date-start
        ,input   x-date-end
        ,input   X-shift-start
        ,input   X-shift-end
        ,input   xTog-obj
        ,input   p-curr-code

        ,output  sum
        ,output  Fact-order).

        по таблицам {&table_arh-fin-doc-schet-obj}   - для безнала
        по таблицам {&table_arh-fin-doc-schet-nal-obj} - для нала

*/
/*------------------------------------------------------------------------------
  Purpose:  Найти Остатки на начало и конец и соответстенные FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ
  IF (NOT xTog-obj) если нужен по всем объектам из списка слитно
------------------------------------------------------------------------------*/
/* { cmp/obj-list.i }  список объектов нужен обязательно !!! */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ trg/factord.i }
{ str/farh-def.i }

PROCEDURE fostatok :
define input parameter p-host-code   as integer no-undo .
define input parameter x-store-code  like ub.clients.obj-code    no-undo.
define input parameter x-store-type  like ub.clients.obj-type    no-undo.
define input parameter x-tog-shift   as   logical             no-undo.
define input parameter x-date-start  as date        no-undo.
define input parameter x-date-end    as date        no-undo.
define input parameter x-shift-start as integer     no-undo.
define input parameter x-shift-end   as integer     no-undo.
define input parameter xTog-obj   as logical no-undo.
define input parameter p-curr-code as integer no-undo .
define input parameter p-cashbookid as integer  no-undo .

define output parameter sum       as decimal   no-undo.
define output parameter Fact-order  as decimal  no-undo.


define variable Fact-order#   as decimal  no-undo.
define variable Fact-orderS   as character  no-undo.
define variable x-date-start-t  as date   no-undo.
define variable x-sum-type as character no-undo .

&if "{&arh-name}" = {&table_arh-fin-doc-schet-obj} &then
  if x-tog-shift then do:
    assign
    x-sum-type = {&arh-fin-doc-schet-obj-shift-obj}.
  end.
  else do:
    x-sum-type = {&arh-fin-doc-schet-obj-obj}.
  end.
&SCOP find-farh    ~{&arh-name~} no-lock where ~
    ~{&arh-name~}.obj-type = obj-list.obj-type ~
and ~{&arh-name~}.obj-code = obj-list.obj-code ~
and ~{&arh-name~}.cli-code          = p-host-code ~
and ~{&arh-name~}.cli-type          = {&cmp} ~
and ~{&arh-name~}.calc-curr-code    = p-curr-code ~
and ~{&arh-name~}.sum-type = x-sum-type and

&else
  &if "{&arh-name}" = {&table_arh-fin-doc-schet-nal-obj} &then
    if x-tog-shift then do:
      assign
      x-sum-type = {&arh-fin-doc-schet-nal-obj-shift-obj}.
    end.
    else do:
      x-sum-type = {&arh-fin-doc-schet-nal-obj-obj}.
    end.
&SCOP find-farh    ~{&arh-name~} no-lock where ~
    ~{&arh-name~}.obj-type = obj-list.obj-type ~
and ~{&arh-name~}.obj-code = obj-list.obj-code ~
and ~{&arh-name~}.cli-code          = p-host-code ~
and ~{&arh-name~}.cli-type          = {&cmp} ~
and ~{&arh-name~}.calc-curr-code    = p-curr-code ~
and ~{&arh-name~}.cashbookid    = p-cashbookid ~
and ~{&arh-name~}.curr-code    = p-curr-code ~
and ~{&arh-name~}.sum-type = x-sum-type and

  &else
    &message НЕВЕРНОЕ ЗНАЧЕНИЕ arh-name!!!
  &endif
&endif



&SCOP assign-fact-order   Assign~
                          sum     = ~{&arh-name~}.income - ~{&arh-name~}.expense~
                          Fact-order#  = {&arh-name}.Fact-order


Assign
Fact-order   = 0
sum     = 0
/* Определяем факт-ордер на начало периода */

x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
  Fact-order = 0 .
  For each obj-list no-lock
      WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type
              AND
              x-store-code = obj-list.obj-code))
  :
   fact-order# = 0.
   IF  x-TOG-Shift = False Then DO:
      /* календарные даты */
      find last {&find-farh}
          {&arh-name}.Fact-date <=  x-date-start
          USE-INDEX fact-date  no-error .
     if Available {&arh-name} THEN  do:
       {&assign-fact-order}.
     end.
   End. /*IF  x-TOG-Shift = False Then DO:*/
   Else  DO :
      /* смены */
      find last {&find-farh}
           ({&arh-name}.shift-date  = x-date-start-t and
            {&arh-name}.shift-num  < x-shift-start or
            {&arh-name}.shift-date  < x-date-start-t  )
            and {&arh-name}.shift-num  > 0
            USE-INDEX Shift-num no-error .
      if Available {&arh-name} THEN  do:
        {&assign-fact-order}.
      end.
    END. /*else IF  x-TOG-Shift = False Then DO:*/
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End. /* for each */
End. /* IF x-date-end = date('') then DO:  на начало */

/* Факт- ордер на конец периода */
Else DO:
  For each obj-list  no-lock WHERE
     (NOT xTog-obj
      OR
      (x-store-type = obj-list.obj-type
      AND
      x-store-code = obj-list.obj-code))
   :
   IF  x-TOG-Shift = False Then DO:
      /* календарные даты */
      find last {&find-farh}
            {&arh-name}.Fact-date <= x-date-end
            and {&arh-name}.shift-num = 0
            USE-INDEX fact-date no-error.
     if Available {&arh-name} THEN  do:
       {&assign-fact-order}.
     end.
   END. /*IF  x-TOG-Shift = False Then DO:*/
   Else DO:
      /* смены */
      find last {&find-farh}
            ({&arh-name}.shift-date  = x-date-end and
            {&arh-name}.shift-num  <= x-shift-end or
            {&arh-name}.shift-date  < x-date-end       ) and
            {&arh-name}.shift-num   > 0      use-index shift-num no-error.
      if Available {&arh-name} THEN  do:
        {&assign-fact-order}.
      end.
    End. /*else IF  x-TOG-Shift = False Then DO:*/
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End. /* for each obj-list*/
End.   /* на конец */
/*
message x-store-type x-store-code skip
x-date-start-t x-shift-start fact-order skip
x-date-end     x-shift-end     skip
sum
view-as alert-box .
  */
END PROCEDURE.
/* $Workfile$ e n d */