{ cmp/trg-def.i }

define variable v-user-login as character no-undo .
define variable v-user-id as character no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-date as date no-undo .
define variable v-free-id as character no-undo .

define variable v-value    as character no-undo .
define variable v-type     as character no-undo .

define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .

define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_schedule for ub.schedule .
define buffer buf_schedule-attr for ub.schedule-attr.
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_clients for ub.clients .
define buffer buf_db-attr for ub.db-attr .
define buffer buf_ruledict for ub.ruledict .


run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
if v-value = "no"
then do:
  return .
end .

find first buf_sys-ctrl no-lock no-error.
if not available buf_sys-ctrl
then do :
  return error return-value .
end .

/* При версии машины правил меньше 16_0.13 - ничего не делаем */
find first buf_ruledict no-lock where buf_ruledict.entry-id = 0  no-error.
if available buf_ruledict
then do :
  assign
    v-dopi1 = integer(entry(2, buf_ruledict.documentation,  "."))
    v-dopi2 = integer(entry(2, entry(1, buf_ruledict.documentation, "."), "_"))
  no-error .
  if not error-status:error
  then do :
    if v-dopi2 = 0
    then do :
      if v-dopi1 < 13
      then do :
        return .
      end .
    end .
  end .
end .

find first buf_db-attr no-lock where buf_db-attr.db-num = buf_sys-ctrl.db-num
                                 and buf_db-attr.attr-code = "schedule-sent"
                                 no-error .
if available buf_db-attr
and logical(buf_db-attr.attr-value)
then do :
  return .
end .

find first buf_clients no-lock where buf_clients.obj-type = 'маг'
                                 and buf_clients.db-num = buf_sys-ctrl.db-num
                                 no-error .
if not available buf_clients
then do :
  if buf_sys-ctrl.db-num = 0
  then do :
    return .
  end .
  return error "В базе данных не найден магазин" .
end .

v-shift-num = 0 .
v-shift-date = ? .
for first buf_shift-obj
    where buf_shift-obj.obj-type = buf_clients.obj-type
      and buf_shift-obj.obj-code = buf_clients.obj-code
      and buf_shift-obj.status_ = "тек"
    use-index stts :
  assign
    v-shift-date = buf_shift-obj.shift-date
    v-shift-num  = buf_shift-obj.shift-num
  .
end.
if v-shift-date = ? then v-shift-date = today .

for each buf_schedule no-lock where buf_schedule.cre-db-num = buf_clients.db-num :
  if buf_schedule.task-type = "autofree"
  then do :
    find first buf_schedule-attr no-lock     /* Ищем атрибут */
        where buf_schedule-attr.cre-db-num = buf_schedule.cre-db-num
          and buf_schedule-attr.task-type  = buf_schedule.task-type
          and buf_schedule-attr.task-num   = buf_schedule.task-num
          and buf_schedule-attr.attr-code  begins  ("schd-free-id" + chr(4))
    no-error .
    if available buf_schedule-attr then
    assign
    v-free-id = entry(2, buf_schedule-attr.attr-code, chr(4))
    no-error
    .
  end .
  run trg/userlog.p (
          input 'schedule'
        , input ("Первичная отправка в 1С расписания автозаданий на объекте " +
                buf_clients.obj-type + string(buf_clients.obj-code) + ";" + 
                buf_schedule.task-type + ";" +
                (if buf_schedule.task-type = "autofree" then v-free-id else "0") + ";" +
                  string(buf_schedule.task-num) + "|" +
                  (if buf_schedule.active then "1" else "0") + "|" +
                  buf_schedule.task-year + "|" +
                  buf_schedule.task-month + "|" +
                  buf_schedule.task-day + "|" +
                  buf_schedule.task-weekday + "|" +
                  buf_schedule.task-hour + "|" +
                  buf_schedule.task-minute +
                chr(3) +
                buf_clients.obj-type + chr(6) +
                string(buf_clients.obj-code) + chr(6) +
                string(v-shift-date) + chr(6) +
                string(v-shift-num) + chr(6) +
                buf_schedule.task-type + chr(6) +
                (if buf_schedule.task-type = "autofree" then v-free-id else "0") + chr(6) + 
                string(buf_schedule.task-num) + chr(6) +
                (if buf_schedule.active then "1" else "0") + chr(6) +
                buf_schedule.task-year + chr(6) +
                buf_schedule.task-month + chr(6) +
                buf_schedule.task-day + chr(6) +
                buf_schedule.task-weekday + chr(6) +
                buf_schedule.task-hour + chr(6) +
                buf_schedule.task-minute + chr(6) +
                "chg" + chr(6) +
                buf_schedule.db-num-char )
        , input ?
        , input ?
        , input ""
        ) no-error .
  if error-status:error
  then do :
    return error return-value .
  end .
end . /* for each buf_schedule */

create buf_db-attr .
assign
  buf_db-attr.db-num = buf_sys-ctrl.db-num
  buf_db-attr.attr-code = "schedule-sent"
  buf_db-attr.attr-value = string(yes)
.

return.

