block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на корректировку шапки документа доп расходов

Автор: Чернова Светлана Александровна
Дата создания: 04/03/07
Author: Svetlana Chernova
Creation date: 04/03/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.add-doc.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на корректировку шапки документа доп расходов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable s-date as date      no-undo . /* дата начала смены для документа */
define variable s-num  as integer   no-undo . /* порядок смены для документа */
define variable s-name as character no-undo . /* номер смены для документа */


do
on error undo, return error
:
  if not g#news
  then do:

    { gbl/curdburt.i
      ub.add-doc.user-db-num
      ub.add-doc.user-name
      ub.add-doc.sys-date
      ub.add-doc.sys-time
      ub.add-doc.sys-time-int
    }
    if new ub.add-doc then do:
        assign
          ub.add-doc.cr-db-num = g#db-num
          ub.add-doc.creid     = g#userid
          ub.add-doc.doc-type  = {&income}
          ub.add-doc.real-date-create = ub.add-doc.sys-date
          ub.add-doc.real-time-create = ub.add-doc.sys-time-int
        .
     end.
  end.
  if ub.add-doc.status_ = {&fact} and not g#news then do:
      run cur-time in this-procedure (output l-date , output l-time) no-error .

      ub.add-doc.fact-time  = l-time .
      run gbl/factdate.p ( input        ub.add-doc.obj-type  ,
                           input        ub.add-doc.obj-code   ,
                           input-output ub.add-doc.fact-date ,
                           input-output ub.add-doc.fact-time ,
                           input-output s-date  ,
                           input-output s-num ,
                           input-output s-name,
                           input        yes     ).
      assign
        ub.add-doc.shift-date = s-date
        ub.add-doc.shift-num  = s-num
        ub.add-doc.shift-name = s-name
        .
      if ub.add-doc.fact-num =  0 or ub.add-doc.fact-num = ?  then do:
      /* определяем порядковый номер */
      assign
        ub.add-doc.fact-num = next-value (s-trn-fact, {&db-name_schema})
      .
      end.

      /* определяем fact-order */
      if ub.add-doc.fact-order =  0 or ub.add-doc.fact-order = ?  then do:
      define variable v-fact-order           as decimal no-undo .
      define variable v-shift-end-fact-order as decimal no-undo .
      define variable v-day-end-fact-order   as decimal no-undo .
      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        ub.add-doc.obj-type
        ub.add-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "ДопРасход" ub.add-doc.doc-code skip
          "Объект" ub.add-doc.obj-type ub.add-doc.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo , return error .
      end.

      run factord in this-procedure
        (input  ub.add-doc.fact-date   /* p-fact-date            */
        ,input  ub.add-doc.fact-time   /* p-fact-time            */
        ,input  ub.add-doc.fact-num    /* p-fact-num             */
        ,input  ub.add-doc.shift-date  /* p-shift-date           */
        ,input  ub.add-doc.shift-num   /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера складского документа" skip
          "ДопРасход" ub.add-doc.doc-code skip
          "fact-date"               ub.add-doc.fact-date   skip
          "fact-time"               ub.add-doc.fact-time   skip
          "fact-num"                ub.add-doc.fact-num    skip
          "shift-date"              ub.add-doc.shift-date  skip
          "shift-num"               ub.add-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      assign
        ub.add-doc.fact-order = v-fact-order
      .
      end.
   end.

  if not g#news and ub.add-doc.status_ <> {&g___new} then do:
      run str/callnews.p
        (input "add-doc"
        ,input (buffer ub.add-doc:handle)
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать add-doc для отправки в новости" skip
          "Документ" ub.add-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo , return error return-value .
      end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_add-doc}
        , input ( buffer ub.add-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
  end.
end.