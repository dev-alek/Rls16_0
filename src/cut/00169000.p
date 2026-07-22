block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00169000.p $
$Archive: cut/00169000.p $

Файл пирога обрезания. Относится к категории 169.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
shift-obj
c-shift-obj
shift-attr
c-shift-attr
shift-obj-attr
shift-staff
c-shift-staff
shift-staff-attr
obj-date
c-sht-hist

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00169000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00169000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 169.".
{ cmp/str-glbl.i }
{ utl/tt-objs.i  }


define temp-table temp_obj no-undo
    field obj-type as character
    field obj-code as integer
.


on WRITE of dst.shift-obj override do: end.
on WRITE of dst.c-shift-obj override do: end.
on WRITE of dst.obj-date  override do: end.
on WRITE of dst.shift-attr  override do: end.
on WRITE of dst.c-shift-attr  override do: end.
on WRITE of dst.shift-obj-attr  override do: end.
on WRITE of dst.shift-staff  override do: end.
on WRITE of dst.shift-staff-attr  override do: end.
on WRITE of dst.c-shift-staff  override do: end.
on WRITE of dst.c-sht-hist  override do: end.


define buffer old-shift-obj     for src.shift-obj.
define buffer new-shift-obj     for dst.shift-obj.
define buffer old-c-shift-obj     for src.c-shift-obj.
define buffer new-c-shift-obj     for dst.c-shift-obj.
define buffer old-shift-attr     for src.shift-attr.
define buffer new-shift-attr     for dst.shift-attr.
define buffer old-c-shift-attr     for src.c-shift-attr.
define buffer new-c-shift-attr     for dst.c-shift-attr.
define buffer old-shift-obj-attr     for src.shift-obj-attr.
define buffer new-shift-obj-attr     for dst.shift-obj-attr.
define buffer old-shift-staff   for src.shift-staff.
define buffer new-shift-staff   for dst.shift-staff.
define buffer old-c-shift-staff   for src.c-shift-staff.
define buffer new-c-shift-staff   for dst.c-shift-staff.
define buffer old-shift-staff-attr   for src.shift-staff-attr.
define buffer new-shift-staff-attr   for dst.shift-staff-attr.
define buffer buf_old_obj-date  for src.obj-date.
define buffer buf_new_obj-date  for dst.obj-date.
define buffer old-c-sht-hist   for src.c-sht-hist.
define buffer new-c-sht-hist   for dst.c-sht-hist.


define buffer new-clients   for dst.clients.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }

define variable v-fact-order               as decimal      no-undo.
define variable v-shift-end-fact-order     as decimal      no-undo.
define variable v-day-end-fact-order       as decimal      no-undo.

RUN init-temphost in this-procedure .
if vardate-actual-docs <> ?
then do:
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
    for each temp_obj
    :
        find first tt-objs
             where tt-objs.obj-type = temp_obj.obj-type
               and tt-objs.obj-code = temp_obj.obj-code
        no-error.
        if vartype-cut = 0
        or ( vartype-cut = 1 and available tt-objs )
        then do:
            for each old-shift-obj no-lock
               where old-shift-obj.obj-type     = temp_obj.obj-type
                 and old-shift-obj.obj-code     = temp_obj.obj-code
                 and old-shift-obj.fact-order   > v-shift-end-fact-order
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-obj.obj-type
                 and new-clients.obj-code = old-shift-obj.obj-code
            :
                create new-shift-obj.
                buffer-copy old-shift-obj to new-shift-obj.
            end.
            for each old-c-shift-obj no-lock
               where old-c-shift-obj.obj-type     = temp_obj.obj-type
                 and old-c-shift-obj.obj-code     = temp_obj.obj-code
                 and old-c-shift-obj.fact-order   > v-shift-end-fact-order
             , first new-clients no-lock
               where new-clients.obj-type = old-c-shift-obj.obj-type
                 and new-clients.obj-code = old-c-shift-obj.obj-code
            :
                create new-c-shift-obj.
                buffer-copy old-c-shift-obj to new-c-shift-obj.
            end.
            for each old-shift-staff no-lock
               where old-shift-staff.obj-type    = temp_obj.obj-type
                 and old-shift-staff.obj-code    = temp_obj.obj-code
                 and old-shift-staff.shift-date >= vardate-actual-docs
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-staff.obj-type
                 and new-clients.obj-code = old-shift-staff.obj-code
            :
                create new-shift-staff.
                buffer-copy old-shift-staff to new-shift-staff.
            end.
            for each old-c-shift-staff no-lock
               where old-c-shift-staff.obj-type    = temp_obj.obj-type
                 and old-c-shift-staff.obj-code    = temp_obj.obj-code
                 and old-c-shift-staff.shift-date >= vardate-actual-docs
             , first new-clients no-lock
               where new-clients.obj-type = old-c-shift-staff.obj-type
                 and new-clients.obj-code = old-c-shift-staff.obj-code
            :
                create new-c-shift-staff.
                buffer-copy old-c-shift-staff to new-c-shift-staff.
            end.
            for each old-shift-staff-attr no-lock
               where old-shift-staff-attr.obj-type    = temp_obj.obj-type
                 and old-shift-staff-attr.obj-code    = temp_obj.obj-code
                 and old-shift-staff-attr.shift-date >= vardate-actual-docs
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-staff-attr.obj-type
                 and new-clients.obj-code = old-shift-staff-attr.obj-code
            :
                create new-shift-staff-attr.
                buffer-copy old-shift-staff-attr to new-shift-staff-attr.
            end.
            for each old-shift-obj-attr no-lock
               where old-shift-obj-attr.obj-type    = temp_obj.obj-type
                 and old-shift-obj-attr.obj-code    = temp_obj.obj-code
                 and old-shift-obj-attr.shift-date >= vardate-actual-docs
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-obj-attr.obj-type
                 and new-clients.obj-code = old-shift-obj-attr.obj-code
            :
                create new-shift-obj-attr.
                buffer-copy old-shift-obj-attr to new-shift-obj-attr.
            end.
            for each buf_old_obj-date no-lock
               where buf_old_obj-date.obj-type      = temp_obj.obj-type
                 and buf_old_obj-date.obj-code      = temp_obj.obj-code
                 and buf_old_obj-date.fact-order    > v-shift-end-fact-order
            on error undo, return error
            :
                create buf_new_obj-date.
                buffer-copy buf_old_obj-date to buf_new_obj-date.
            end.        /* for each buf_old_obj-date */
            for each old-c-sht-hist no-lock
               where old-c-sht-hist.obj-type    = temp_obj.obj-type
                 and old-c-sht-hist.obj-code    = temp_obj.obj-code
                 and old-c-sht-hist.shift-date >= vardate-actual-docs
             , first new-clients no-lock
               where new-clients.obj-type = old-c-sht-hist.obj-type
                 and new-clients.obj-code = old-c-sht-hist.obj-code
            :
                create new-c-sht-hist.
                buffer-copy old-c-sht-hist to new-c-sht-hist.
            end.

        end.
        else do:
            for each old-shift-obj no-lock
               where old-shift-obj.obj-type     = temp_obj.obj-type
                 and old-shift-obj.obj-code     = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-obj.obj-type
                 and new-clients.obj-code = old-shift-obj.obj-code
            :
                create new-shift-obj.
                buffer-copy old-shift-obj to new-shift-obj.
            end.
            for each old-c-shift-obj no-lock
               where old-c-shift-obj.obj-type     = temp_obj.obj-type
                 and old-c-shift-obj.obj-code     = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-c-shift-obj.obj-type
                 and new-clients.obj-code = old-c-shift-obj.obj-code
            :
                create new-c-shift-obj.
                buffer-copy old-c-shift-obj to new-c-shift-obj.
            end.
            for each old-shift-staff no-lock
               where old-shift-staff.obj-type = temp_obj.obj-type
                 and old-shift-staff.obj-code = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-staff.obj-type
                 and new-clients.obj-code = old-shift-staff.obj-code
            :
                create new-shift-staff.
                buffer-copy old-shift-staff to new-shift-staff.
            end.
            for each old-shift-staff-attr no-lock
               where old-shift-staff-attr.obj-type = temp_obj.obj-type
                 and old-shift-staff-attr.obj-code = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-staff-attr.obj-type
                 and new-clients.obj-code = old-shift-staff-attr.obj-code
            :
                create new-shift-staff-attr.
                buffer-copy old-shift-staff-attr to new-shift-staff-attr.
            end.
            for each old-c-shift-staff no-lock
               where old-c-shift-staff.obj-type = temp_obj.obj-type
                 and old-c-shift-staff.obj-code = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-c-shift-staff.obj-type
                 and new-clients.obj-code = old-c-shift-staff.obj-code
            :
                create new-c-shift-staff.
                buffer-copy old-c-shift-staff to new-c-shift-staff.
            end.
            for each old-shift-obj-attr no-lock
               where old-shift-obj-attr.obj-type = temp_obj.obj-type
                 and old-shift-obj-attr.obj-code = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-shift-obj-attr.obj-type
                 and new-clients.obj-code = old-shift-obj-attr.obj-code
            :
                create new-shift-obj-attr.
                buffer-copy old-shift-obj-attr to new-shift-obj-attr.
            end.
            for each old-c-sht-hist no-lock
               where old-c-sht-hist.obj-type = temp_obj.obj-type
                 and old-c-sht-hist.obj-code = temp_obj.obj-code
             , first new-clients no-lock
               where new-clients.obj-type = old-c-sht-hist.obj-type
                 and new-clients.obj-code = old-c-sht-hist.obj-code
            :
                create new-c-sht-hist.
                buffer-copy old-c-sht-hist to new-c-sht-hist.
            end.
            for each buf_old_obj-date no-lock
               where buf_old_obj-date.obj-type      = temp_obj.obj-type
                 and buf_old_obj-date.obj-code      = temp_obj.obj-code
            on error undo, return error
            :
                create buf_new_obj-date.
                buffer-copy buf_old_obj-date to buf_new_obj-date.
            end.        /* for each buf_old_obj-date */
        end.
    end.
end.        /* if vardate-actual-docs <> ? */
for each temp_obj
on error undo, return error
:
    find first buf_new_obj-date no-lock
         where buf_new_obj-date.obj-type = temp_obj.obj-type
           and buf_new_obj-date.obj-code = temp_obj.obj-code
           and buf_new_obj-date.status_  = {&objdt-current}
    no-error.
    if not available buf_new_obj-date
    then do:
        find first buf_old_obj-date no-lock
             where buf_old_obj-date.obj-type = temp_obj.obj-type
               and buf_old_obj-date.obj-code = temp_obj.obj-code
               and buf_old_obj-date.status_  = {&objdt-current}
        no-error.
        if available buf_old_obj-date
        then do:
            create buf_new_obj-date.
            buffer-copy buf_old_obj-date to buf_new_obj-date.
        end.
    end.
end.        /* for each temp_obj */
output stream str-gen close.
return "Произведен экспорт таблиц: shift-obj c-shift-obj shift-attr c-shift-attr shift-obj-attr shift-staff c-shift-staff shift-staff-attr obj-date c-sht-hist.".
end.


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


/*==========================================================================*/
procedure init-temphost :

  define buffer buf_store   for dst.store .
  define buffer buf_shop    for dst.shop .
  define buffer buf_clients for dst.clients .

  define buffer buf_temp_obj  for temp_obj .
do
on error undo, return error
:
        for each buf_store
        on error undo, return error
        :
            find first buf_clients no-lock
                 where buf_clients.obj-type = {&stock}
                   and buf_clients.obj-code = buf_store.obj-code
             no-error .
             if not available buf_clients
             then do:
                message
                    "Ошибка при поиске клиента" skip
                    "Клиент" {&stock} buf_store.obj-code skip
                view-as alert-box error .
                undo, return error .
            end.
            create buf_temp_obj.
            assign
                buf_temp_obj.obj-type  = {&stock}
                buf_temp_obj.obj-code  = buf_store.obj-code
            .
        end.
        for each buf_shop
        on error undo, return error
        :
            find first buf_clients no-lock
                 where buf_clients.obj-type = {&shop}
                   and buf_clients.obj-code = buf_shop.obj-code
            no-error .
            if not available buf_clients
            then do:
                message
                    "Ошибка при поиске клиента" skip
                    "Клиент" {&shop} buf_shop.obj-code skip
                view-as alert-box error .
                undo, return error .
            end.
            create buf_temp_obj.
            assign
                buf_temp_obj.obj-type  = {&shop}
                buf_temp_obj.obj-code  = buf_shop.obj-code
            .
        end.
end.
end procedure. /* init-temphost */