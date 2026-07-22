block-level on error undo, throw.
/*

Чистка УБД. Смена на объекте, персонал смены.

Автор: Ростовцев Александр
Дата создания: 15/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/15/25
*/

&scop Tables Смена на объекте с историей, ~
Персонал смены с историей
/*&scop Table shift-obj ~*/
/*c-shift-obj ~          */
/*shift-staff ~          */
/*c-shift-staff ~        */
/*shift-staff-attr ~     */
/*shift-obj-attr ~       */
/*obj-date ~             */
/*c-sht-hist             */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00169000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define variable v-fact-order               as decimal      no-undo.
define variable v-shift-end-fact-order     as decimal      no-undo.
define variable v-day-end-fact-order       as decimal      no-undo.

define buffer shift-obj        for ub.shift-obj.
define buffer shift-obj-attr   for ub.shift-obj-attr.
define buffer shift-staff      for ub.shift-staff.
define buffer c-shift-staff    for ub.c-shift-staff.
define buffer shift-staff-attr for ub.shift-staff-attr.
define buffer obj-date         for ub.obj-date.
define buffer c-sht-hist       for ub.c-sht-hist.

on delete of ub.shift-obj override do: end.
on delete of ub.obj-date  override do: end.
on delete of ub.shift-obj-attr  override do: end.
on delete of ub.shift-staff  override do: end.
on delete of ub.shift-staff-attr  override do: end.
on delete of ub.c-shift-staff  override do: end.
on delete of ub.c-sht-hist  override do: end.

run factord in this-procedure (
    input vardate-actual-docs - 1
  , input 0
  , input 1
  , input vardate-actual-docs - 1
  , input 1
  , input yes
  , output v-fact-order
  , output v-shift-end-fact-order
  , output v-day-end-fact-order
).

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each shift-obj exclusive-lock
     where shift-obj.obj-type     = buf_clients.obj-type
       and shift-obj.obj-code     = buf_clients.obj-code
       and shift-obj.shift-date  < vardate-actual-docs
       and shift-obj.status_ = {&sht-closed}
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    {cleandb/dellinkrec.i 
      c-shift-obj  
      "where c-shift-obj.obj-type   = shift-obj.obj-type
         and c-shift-obj.obj-code   = shift-obj.obj-code
         and c-shift-obj.shift-date = shift-obj.shift-date
         and c-shift-obj.shift-num  = shift-obj.shift-num"
    }
    delete shift-obj.
    vDeleted = vDeleted + 1.
  end.
  for each shift-staff exclusive-lock
     where shift-staff.obj-type    = buf_clients.obj-type
       and shift-staff.obj-code    = buf_clients.obj-code
       and shift-staff.shift-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete shift-staff.
    vDeleted = vDeleted + 1.
  end.
  for each c-shift-staff exclusive-lock
     where c-shift-staff.obj-type    = buf_clients.obj-type
       and c-shift-staff.obj-code    = buf_clients.obj-code
       and c-shift-staff.shift-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete c-shift-staff.
    vDeleted = vDeleted + 1.
  end.
  for each shift-staff-attr exclusive-lock
     where shift-staff-attr.obj-type    = buf_clients.obj-type
       and shift-staff-attr.obj-code    = buf_clients.obj-code
       and shift-staff-attr.shift-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete shift-staff-attr.
    vDeleted = vDeleted + 1.
  end.
  for each shift-obj-attr exclusive-lock
     where shift-obj-attr.obj-type    = buf_clients.obj-type
       and shift-obj-attr.obj-code    = buf_clients.obj-code
       and shift-obj-attr.shift-date < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete shift-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  for each obj-date exclusive-lock
     where obj-date.obj-type      = buf_clients.obj-type
       and obj-date.obj-code      = buf_clients.obj-code
       and obj-date.fact-order    <= v-shift-end-fact-order
       and obj-date.status_       = {&objdt-closed}
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete obj-date.
    vDeleted = vDeleted + 1.
  end.
  for each c-sht-hist exclusive-lock
     where c-sht-hist.obj-type    = buf_clients.obj-type
       and c-sht-hist.obj-code    = buf_clients.obj-code
       and c-sht-hist.shift-date  < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) 
  :
    delete c-sht-hist.
    vDeleted = vDeleted + 1.
  end.
end.

{cleandb/setresval.i}
return vResult.


procedure factord :

  define input  parameter p-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
  define input  parameter p-fact-time            as integer no-undo . /* фактическое время закрытия документа */
  define input  parameter p-fact-num             as integer no-undo . /* фактический номер закрытия документа */
  define input  parameter p-shift-date           as date    no-undo . /* дата начала смены для документа      */
  define input  parameter p-shift-num            as integer no-undo . /* номер смены для документа            */
  define input  parameter p-shift-on             as logical no-undo . /* на объекте включены смены            */
  define output parameter p-fact-order           as decimal no-undo . /* порядковый номер закрытия документа  */
  define output parameter p-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
  define output parameter p-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */

  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".

  if p-fact-date = ? then do:
    return error "Не указана фактическая дата" .
  end.

  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .

  if p-fact-num = ?
  or p-fact-num = 0 then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.

  if p-fact-num < 0 then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.

  if p-fact-num >= 100000000 then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.

  if p-shift-on = true then do:
    /* смены включены */
    /* должны быть заданы дата и номер смены */
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.

    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    /* смены выключены */
    /* присваиваем значения по умолчанию */
    assign
      p-shift-date = p-fact-date
      p-shift-num  = {&max-shift-num}
    .
  end.

  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.

  if p-shift-num < {&min-shift-num}
  or p-shift-num > {&max-shift-num} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * {&arh-delta}
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .

  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.

end procedure. /* factord */
