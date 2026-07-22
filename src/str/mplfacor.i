/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Факт-ордер на сейчас для работы с МПЛ

Автор: Чернова Светлана Александровна
Дата создания: 07/18/06
Author: Svetlana Chernova
Creation date: 07/18/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }

procedure fact-order-mpl :

  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .

define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo . /* дата начала смены для документа */
define variable shift-num  as integer   no-undo . /* порядок смены для документа */
define variable shift-name as character no-undo . /* номер смены для документа */
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .

find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
/* ВРЕМЯ СЕРВЕРА */
      run factord in this-procedure
        (input  v-fact-date            /* p-fact-date            */
        ,input  v-fact-time            /* p-fact-time            */
        ,input  v-fact-time            /* p-fact-num     вместо номера документа время запроса  */
        ,input  ?                      /* p-shift-date           */
        ,input  ?                      /* p-shift-num            */
        ,input  false                  /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
/* Время объекта */
   /* ТЕКУЩИЕ дата и время на объекте */
      { gbl/objat.i
        p-obj-type
        p-obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error then return error "Неопределена дата на объекте " + return-value .

      if p-doc-date <> ? then do:
         /* Есть дата документа */
         /* 29/10/2007 решили что только по объекту */
         /*  v-fact-date = p-doc-date . */
         /* 25/04/2008 решили что нужна дата */
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .

      run factord in this-procedure
        (input  v-fact-date            /* p-fact-date            */
        ,input  v-fact-time            /* p-fact-time            */
        ,input  v-fact-time            /* p-fact-num     вместо номера документа время запроса  */
        ,input  shift-date             /* p-shift-date           */
        ,input  shift-num              /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
 /* 25/04/2008 решили что нужна дата */
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date            /* p-fact-date            */
        ,input  v-fact-time            /* p-fact-time            */
        ,input  v-fact-time            /* p-fact-num     вместо номера документа время запроса  */
        ,input  shift-date             /* p-shift-date           */
        ,input  shift-num              /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.

  end.

end procedure. /* fact-order-mpl */