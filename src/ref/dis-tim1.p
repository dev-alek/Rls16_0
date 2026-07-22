block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-tim1.p $
$Archive: ref/dis-tim1.p $

Сохранение изменений в расписаниях

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/15/04
Author: Bakhtadze Natalya
Creation date: 09/15/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter  p-time-rule-num     like ub.dis-time-rule.time-rule-num          no-undo .
define input parameter  p-rl-root           like ub.dis-time-rule.rl-root           no-undo .
define input parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
define input parameter  p-des               like ub.dis-time-rule.des               no-undo .
define input parameter  p-date-from         like ub.dis-time-rule.date-from no-undo .
define input parameter  p-date-to           like ub.dis-time-rule.date-to no-undo .
define input parameter  p-time-from         like ub.dis-time-rule.time-from no-undo .
define input parameter  p-time-to           like ub.dis-time-rule.time-to no-undo .
define input parameter  p-month-day         like ub.dis-time-rule.month-day no-undo .
define input parameter  p-week-day-0        like ub.dis-time-rule.week-day-0 no-undo .
define input parameter  p-week-day-1        like ub.dis-time-rule.week-day-1 no-undo .
define input parameter  p-week-day-2        like ub.dis-time-rule.week-day-2 no-undo .
define input parameter  p-week-day-3        like ub.dis-time-rule.week-day-3 no-undo .
define input parameter  p-week-day-4        like ub.dis-time-rule.week-day-4 no-undo .
define input parameter  p-week-day-5        like ub.dis-time-rule.week-day-5 no-undo .
define input parameter  p-week-day-6        like ub.dis-time-rule.week-day-6 no-undo .
define input parameter  p-week-day-7        like ub.dis-time-rule.week-day-7 no-undo .
define input parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .

define temp-table tt0-term_dis-time-rule no-undo like ub.dis-time-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-term_dis-time-rule.

define input-output parameter p-recid as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-tim1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-tim1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в расписаниях".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/distruls.i "work" }
{ gbl/disrules.i "work" }
{ trg/new-bcod.i }
{ ref/gtregion.i }
{ gbl/waitfram.i }


define variable v-db-num like ub.db.db-num no-undo .
define variable v-dr-code as character no-undo .
define variable  v-new-time-rule-num      like ub.dis-time-rule.time-rule-num          no-undo .
define variable  v-time-rule-num          like ub.dis-time-rule.time-rule-num          no-undo .
define variable  v-des               like ub.dis-time-rule.des               no-undo .
define variable  v-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable  v-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable  vt-level-1 as character no-undo .
define variable  vt-level-2 as character no-undo .
define variable  v-output-display    as logical   no-undo . /* виден в броусе */
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo . /* еще чего - нибудь */
define variable  v-dub               as logical no-undo .
define variable  v-entry             as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-curr-field as character no-undo .
define variable v-curr-field1 as character no-undo .
define variable v-curr-field2 as character no-undo .
define variable v-tree-field as logical no-undo extent 18.
define variable v-num-rec as integer no-undo extent 18.
define variable v-num-rec-sign as character no-undo extent 18.
define variable v-uniq-field as logical no-undo extent 18.
define variable v-gds-obj-attr as character no-undo .
define variable v-found as logical no-undo .
define variable v-str as character no-undo .
define variable v-changes as logical no-undo .
define variable v-run-cn as logical no-undo .
define variable v-field-label as character no-undo .

define buffer buf_temp-drt-prop for ub.drt-prop.
define buffer buf_sysconf  for ub.sysconf.
DEFINE BUFFER buf_clients-obj FOR ub.clients.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_db for ub.db .
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer dub_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer dub_tt-dis-time-rule  for tt0-term_dis-time-rule.
define temp-table temp-dis-time-rule no-undo like ub.dis-time-rule.
define buffer check_dis-time-rule for temp-dis-time-rule.


&scop check-fields  "time-from,time-to,date-from,date-to,week-day-0,week-day-1,week-day-2,week-day-3,week-day-4,week-day-5,"  + ~
                    "week-day-6,week-day-7,month-day,week-day-a,week-day-b,week-day-c,time-period,date-period"
&scop time-from 1
&scop time-to   2
&scop date-from 3
&scop date-to    4
&scop week-day-0 5
&scop week-day-1 6
&scop week-day-2 7
&scop week-day-3 8
&scop week-day-4 9
&scop week-day-5 10
&scop week-day-6 11
&scop week-day-7 12
&scop month-day  13
&scop week-day-a 14
&scop week-day-b 15
&scop week-day-c 16
&scop time-period 17
&scop date-period 18

FUNCTION get-week-day-num RETURNS integer (buffer buf_tt-dis-time-rule for tt0-term_dis-time-rule, input p-mode as character):
define variable v-correct as integer no-undo .
assign
v-correct = (if buf_tt-dis-time-rule.week-day-0 <> ? and p-mode = "week-day-a"
            then (if buf_tt-dis-time-rule.week-day-0
                  then (if p-mode = "week-day-c"
                        then 128
                        else 0)
                  else 1
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-1 <> ?
            then (if buf_tt-dis-time-rule.week-day-1
                  then 1
                  else 0)
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-2 <> ?
            then (if buf_tt-dis-time-rule.week-day-2
                  then (if p-mode = "week-day-c"
                        then  2
                        else 0)
                  else 0
                 )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-3 <> ?
            then (if buf_tt-dis-time-rule.week-day-3
                  then (if p-mode = "week-day-c"
                        then  4
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-4 <> ?
            then (if buf_tt-dis-time-rule.week-day-4
                  then (if p-mode = "week-day-c"
                        then  8
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-5 <> ?
            then (if buf_tt-dis-time-rule.week-day-5
                  then (if p-mode = "week-day-c"
                        then  16
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-6 <> ?
            then (if buf_tt-dis-time-rule.week-day-6
                  then (if p-mode = "week-day-c"
                        then  32
                        else 0)
                  else 0
                  )
            else 0)     +
            (if buf_tt-dis-time-rule.week-day-7 <> ?
            then (if buf_tt-dis-time-rule.week-day-7
                  then (if p-mode = "week-day-c"
                        then  64
                        else 0)
                  else 0
                  )
            else 0)
.
if v-correct <> 1 then return ?.
if buf_tt-dis-time-rule.week-day-0 <> ?
and p-mode = "week-day-a" then return 0.
if buf_tt-dis-time-rule.week-day-1 <> ?
then return 1.
if buf_tt-dis-time-rule.week-day-2 <> ?
then return 2.
if buf_tt-dis-time-rule.week-day-3 <> ?
then return 3.
if buf_tt-dis-time-rule.week-day-4 <> ?
then return 4.
if buf_tt-dis-time-rule.week-day-5 <> ?
then return 5.
if buf_tt-dis-time-rule.week-day-6 <> ?
then return 6.
if buf_tt-dis-time-rule.week-day-7 <> ?
then return 7.
END.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.


run dtr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-upper-time-rule-num
    ,output v-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
if error-status:error then do:
    run err-mess in this-procedure (substitute("Неверный номер шаблона для расписания: &1, &2", p-templ-rl-root, return-value)).
    undo, return error "time-rule-num":U.
end.
run disrules-fill-properties in this-procedure ( input p-templ-rl-root).

/*пока таких нет*/
do jj = 1 to num-entries({&check-fields}):
  assign
  v-curr-field = entry(jj, {&check-fields})
  .
  find first buf_temp-drt-prop where
      buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
  and buf_temp-drt-prop.upper-prop-code = "":U
  and buf_temp-drt-prop.prop-code = v-curr-field + "=uniq" no-error .
  if available buf_temp-drt-prop then do:
    assign
    v-uniq-field[jj] = yes
    .
  end. /*if buf_temp-drt-prop.prop-code =  */
end. /*do jj*/


if p-mode = {&update}
then do:
  /*проверим что есть УБД*/
  find first buf_db no-lock where
            buf_db.db-num > 0 no-error.
  if available buf_db then do:
    run check-changes(
                         input p-time-rule-num
                        ,output v-changes) no-error .
    if error-status:error
    or v-changes then do:
      run err-mess  in this-procedure (substitute("Т.к. в Системе имеются Удаленные БД,то можно менять только описания РАСПИСАНИЯ")).
      undo, return error "":U.
    end.
  end.
  /*если система без УБД или объект текущей БД проверим что нет таких gds-obj-attr*/
  run waitfram-show in this-procedure ("Ждите .. Проводится проверка возможности изменения правила" ).
    _dis-rule:
  for each buf_dis-rule no-lock where
          buf_dis-rule.time-rule-num = p-time-rule-num:
    assign
    v-found = (yes AND v-changes)
    .
    leave _dis-rule.
  end.
end.

if v-found then do:
  run waitfram-hide in this-procedure .
  run err-mess in this-procedure (substitute("Нельзя изменять запись РАСПИСАНИЯ: &1 ~
                          с ней связано ПРАВИЛО СКИДОК №&2 &3"
                          , {&new-line}
                          , buf_dis-rule.rule-num
                          , buf_dis-rule.des
                          )).
  undo, return error "":U.
end.

run waitfram-hide in this-procedure .


&scop discnt-v-code string(p-value-type)

&SCOPED-DEFINE dtr-t-code ENTRY(ii, p-value-type)
DO ii = 1 TO NUM-ENTRIES(p-value-type):
   ASSIGN
   v-str =  {&dtr-t-name} NO-ERROR.
   if error-status:error then do:
    run err-mess in this-procedure (substitute("Неверный тип расписания: &1", p-value-type)).
    undo, return error "value-type":U.
   end.
END.

find first buf_dis-time-rule no-lock where
        buf_dis-time-rule.time-rule-num = p-upper-time-rule-num no-error .
if not available buf_dis-time-rule then do:
  run err-mess in this-procedure (substitute("Неверный номер корневого расписания: &1", p-upper-time-rule-num)).
  undo, return error "upper-time-rule-num":U.
end.

if p-time-rule-num <=  {&max-num-dr-template} then do:
    run err-mess in this-procedure (substitute("Неверный номер расписания: &1, значения меньшие &2 зарезервированы", p-time-rule-num, {&max-num-dr-template})).
    undo, return error "time-rule-num":U.
end.

assign
v-time-rule-num = p-upper-time-rule-num
.
if lookup("time-from", vt-level-1) = 0
and lookup("time-from", vt-level-2) = 0  then do:
  p-time-from = -1.
end.
if lookup("time-to", vt-level-1) = 0
and lookup("time-to", vt-level-2) = 0  then do:
  p-time-to = -1.
end.
if lookup("date-from", vt-level-1) = 0
and lookup("date-from", vt-level-2) = 0  then do:
  p-date-from = 12/31/1989.
end.
if lookup("date-to", vt-level-1) = 0
and lookup("date-to", vt-level-2) = 0  then do:
  p-date-to = 12/31/1989.
end.
if lookup("week-day-0", vt-level-1) = 0
and lookup("week-day-0", vt-level-2) = 0  then do:
  p-week-day-0 = ?.
end.
if lookup("week-day-1", vt-level-1) = 0
and lookup("week-day-1", vt-level-2) = 0  then do:
  p-week-day-1 = ?.
end.
if lookup("week-day-2", vt-level-1) = 0
and lookup("week-day-2", vt-level-2) = 0  then do:
  p-week-day-2 = ?.
end.
if lookup("week-day-3", vt-level-1) = 0
and lookup("week-day-3", vt-level-2) = 0  then do:
  p-week-day-3 = ?.
end.
if lookup("week-day-4", vt-level-1) = 0
and lookup("week-day-4", vt-level-2) = 0  then do:
  p-week-day-4 = ?.
end.
if lookup("week-day-5", vt-level-1) = 0
and lookup("week-day-5", vt-level-2) = 0  then do:
  p-week-day-5 = ?.
end.
if lookup("week-day-6", vt-level-1) = 0
and lookup("week-day-6", vt-level-2) = 0  then do:
  p-week-day-6 = ?.
end.
if lookup("week-day-7", vt-level-1) = 0
and lookup("week-day-7", vt-level-2) = 0  then do:
  p-week-day-7 = ?.
end.
if lookup("month-day", vt-level-1) = 0
and lookup("month-day", vt-level-2) = 0  then do:
  p-month-day = -1.
end.
if (v-value-type <> p-value-type )
then do:
    run err-mess in this-procedure (substitute("Неверный номер шаблона для расписания: &1, несоответствуют друг друг параметры шаблона и параметры правила скидки", p-templ-rl-root, return-value)).
    undo, return error "templ-rl-root":U.
end.
if v-output-display = no then do:
  run err-mess in this-procedure (substitute("Нельзя добавить расписание по неиспользуемому шаблону: &1", p-templ-rl-root)).
  undo, return error "templ-rl-root":U.
end.
if p-month-day <> -1
and (p-month-day > 31 or p-month-day < -1 ) then do:
  run err-mess in this-procedure (substitute("Значение номера дня месяца не может быть больше 31: &1", p-month-day)).
  undo, return error "month-day":U.
end.
if p-time-from <>  -1 then do:
  assign
  v-str = string(p-time-from, "hh:mm") no-error .
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение начала периода времени неверное: &1", p-time-from)).
     undo, return error "time-from":U.
  end.
end.
if p-time-to <>  -1 then do:
  assign
  v-str = string(p-time-to, "hh:mm") no-error .
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение конца периода времени неверное: &1", p-time-to)).
     undo, return error "time-to":U.
  end.
  if p-time-from > p-time-to
  then do:
    run err-mess in this-procedure (substitute("Значение конца периода времени &1 не может быть меньше значения начала периода времени &2"
                                    , string(p-time-to, "HH:mm")
                                    , string(p-time-from, "HH:MM"))).
    undo, return error "time-from":U.
  end.
end.
if p-date-from < 12/31/1989
or p-date-from = ?
then do:
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение начала периода дат неверное: &1", string(p-date-from, "99/99/9999"))).
     undo, return error "date-from":U.
  end.
end.
if p-date-to < 12/31/1989
or p-date-to = ?
then do:
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Значение конца периода дат неверное: &1", string(p-date-to, "99/99/9999"))).
     undo, return error "date-to":U.
  end.
end.
if p-date-to < p-date-from
and lookup("date-from", vt-level-1) > 0
and lookup("date-to", vt-level-1) > 0
then do:
  run err-mess in this-procedure ( substitute("Значение конца периода дат &1 не может быть меньше значения начала периода дат &2"
                                  , string(p-date-to, "99/99/9999")
                                  , string(p-date-from, "99/99/9999"))).
  undo, return error "date-from":U.
end.

if p-mode = {&add-def} then do:
  if can-find(first temp-drt-prop where
                   temp-drt-prop.templ-rl-root = p-templ-rl-root
              and  temp-drt-prop.upper-prop-code = '':U
              and temp-drt-prop.prop-code = "uniq"
              and logical(temp-drt-prop.property-value) = yes)
                     then do:
    find first dub_dis-time-rule no-lock where
          dub_dis-time-rule.upper-time-rule-num = p-upper-time-rule-num no-error .
    if available dub_dis-time-rule then do:
      assign
      v-dub = yes
      .
      run err-mess in this-procedure (substitute("Уже есть расписание такого типа &1: для данного типа можно определить только одно такое расписание ", v-des)).
    end.
  end.
  create check_dis-time-rule.
  assign
  check_dis-time-rule.date-from = p-date-from
  check_dis-time-rule.date-to = p-date-to
  check_dis-time-rule.time-from = p-time-from
  check_dis-time-rule.time-to = p-time-to
  check_dis-time-rule.week-day-0 = p-week-day-0
  check_dis-time-rule.week-day-1 = p-week-day-1
  check_dis-time-rule.week-day-2 = p-week-day-2
  check_dis-time-rule.week-day-3 = p-week-day-3
  check_dis-time-rule.week-day-4 = p-week-day-4
  check_dis-time-rule.week-day-5 = p-week-day-5
  check_dis-time-rule.week-day-6 = p-week-day-6
  check_dis-time-rule.week-day-7 = p-week-day-7
  check_dis-time-rule.month-day = p-month-day
  .

  _dub:
  for each dub_dis-time-rule no-lock where
          dub_dis-time-rule.upper-time-rule-num = p-upper-time-rule-num:
    do jj = 1 to num-entries({&check-fields}):
      assign
      v-curr-field = entry(jj, {&check-fields})
      .
      if lookup(v-curr-field, vt-level-1) > 0
      and v-uniq-field[jj] then do:
        if buffer dub_dis-time-rule:buffer-field(v-curr-field) = buffer check_dis-time-rule:buffer-field(v-curr-field)  then do:                ~
          assign
          v-dub = yes
          .
          /*получим значением лейбл*/
          run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                          , input v-curr-field
                                                          , output v-field-label).
          LEAVE _dub.                                                                                ~
        end.                                                                                         ~
      end.
    end.
  end. /*for each dub_dis-time-rule no-lock where*/
  if v-dub then do:
    undo, return error "rule-num":U.
  end.
end. /*if p-mode = {&add-def} then do:*/

if v-tree <> "":U then do:
  /*разберем v-tree*/
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root:
    do ii = 1 to num-entries(v-tree):
      assign
      v-entry = entry(ii, v-tree)
      .
      do jj = 1 to num-entries({&check-fields}):
        assign
        v-curr-field = entry(jj, {&check-fields})
        .
        if v-entry = v-curr-field then do:
          assign
          v-tree-field[jj] = yes
          .
          for each buf_temp-drt-prop where
                  buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
              and buf_temp-drt-prop.upper-prop-code = buf_Dis-cfg-rule.pos-type
              and buf_temp-drt-prop.prop-code begins v-curr-field:
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec==":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = "=":U
              .
            end.
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec<=":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = "<":U
              .
            end.
            if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec>=":U) then do:
              assign
              v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
              v-num-rec-sign[jj] = ">":U
              .
            end.
          end. /*for each buf_temp-drt-prop where*/
        end. /*if v-entry = v-curr-field */
      end. /*do jj*/
    end. /*do ii*/
  end. /*for each buf_dis-cfg-rule*/

  for each tt0-term_dis-time-rule no-lock where
          tt0-term_dis-time-rule.upper-time-rule-num = (if p-mode = {&add-def} then 0 else p-time-rule-num):

    if tt0-term_dis-time-rule.month-day <> -1
    and (tt0-term_dis-time-rule.month-day > 31 or tt0-term_dis-time-rule.month-day < -1 ) then do:
      run err-mess in this-procedure (substitute("Значение номера дня месяца не может быть больше 31: &1", tt0-term_dis-time-rule.month-day)).
      undo, return error "month-day":U.
    end.
    if tt0-term_dis-time-rule.time-from <>  -1 then do:
      assign
      v-str = string(tt0-term_dis-time-rule.time-from, "hh:mm") no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение начала периода времени неверное: &1"
                                                  , tt0-term_dis-time-rule.time-from)).
        undo, return error "time-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.time-to <>  -1 then do:
      assign
      v-str = string(tt0-term_dis-time-rule.time-to, "hh:mm") no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение конца периода времени неверное: &1", tt0-term_dis-time-rule.time-to)).
        undo, return error "time-to":U.
      end.
      if tt0-term_dis-time-rule.time-from > tt0-term_dis-time-rule.time-to
      and (not (tt0-term_dis-time-rule.date-from <> 12/31/1989
          and tt0-term_dis-time-rule.date-to <> 12/31/1989 )
          OR
          tt0-term_dis-time-rule.date-from = tt0-term_dis-time-rule.date-to)
      then do:
        run err-mess in this-procedure (substitute("Значение конца периода времени &1 не может быть меньше значения начала периода времени &2"
                                                  , string(tt0-term_dis-time-rule.time-to, "HH:mm")
                                                  , string(tt0-term_dis-time-rule.time-from, "HH:MM"))).
        undo, return error "time-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-from < 12/31/1989 then do:
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение начала периода дат неверное: &1", string(tt0-term_dis-time-rule.date-from, "99/99/9999"))).
        undo, return error "date-from":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-to < 12/31/1989 then do:
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Значение конца периода дат неверное: &1", string(tt0-term_dis-time-rule.date-to, "99/99/9999"))).
        undo, return error "date-to":U.
      end.
    end.
    if tt0-term_dis-time-rule.date-to <> 12/31/1989
    and tt0-term_dis-time-rule.date-to < tt0-term_dis-time-rule.date-from then do:
      run err-mess in this-procedure (substitute("Значение конца периода дат &1 не может быть меньше значения начала периода дат &2"
                                                , string(tt0-term_dis-time-rule.date-to, "99/99/9999")
                                                , string(tt0-term_dis-time-rule.date-from, "99/99/9999"))).
      undo, return error "date-from":U.
    end.

    _dub-tt:
    for each dub_tt-dis-time-rule no-lock where
            dub_tt-dis-time-rule.upper-time-rule-num = tt0-term_dis-time-rule.upper-time-rule-num:
      assign                                                                                         ~
      ii = 0.                                                                                        ~

      do jj = 1 to num-entries({&check-fields}):
        assign
        v-curr-field = entry(jj, {&check-fields})
        .
        if lookup(v-curr-field, vt-level-2) > 0 then do:
          assign
          ii = ii + 1
          .
          if v-uniq-field[jj] then do:
            if buffer dub_tt-dis-time-rule:buffer-field(v-curr-field):buffer-value =  buffer tt0-term_dis-time-rule:buffer-field(v-curr-field):buffer-value
            and recid(dub_tt-dis-time-rule) <> recid(tt0-term_dis-time-rule) then do:
              assign
              v-dub = yes.
              /*получим значением лейбл*/
              run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                              , input v-curr-field
                                                              , output v-field-label).

              run err-mess in this-procedure (substitute("Не могут быть два детализированных правила скидки &1 &2"
                                                  , v-field-label
                                                  , string(buffer tt0-term_dis-time-rule:buffer-field(v-curr-field):buffer-value))).
              LEAVE _dub-tt.
            end.
          end. /*if v-uniq-field[jj] then do:*/
          if v-num-rec[jj] > 0 then do:
            CASE v-num-rec-sign[jj]:
              when "<=":U then do:
                if ii >= v-num-rec[jj] then do:
                  assign
                  v-dub = yes
                  .
                  /*получим значением лейбл*/
                  run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                                  , input v-curr-field
                                                                  , output v-field-label).
                  run err-mess in this-procedure (substitute("Не могут быть больше &1 правила скидки, детализированных по &2"
                                                  , v-num-rec[jj]
                                                  , v-field-label)).
                  LEAVE _dub-tt.
                end.
              end.
            END CASE.
          end. /*if v-num-rec[jj] > 0 then do:                                        */
        end. /*if lookup(v-curr-field, vt-level-2) > 0 then do:*/
      end. /*      do jj = 1 to num-entries({&check-fields}):*/
      /*
      do jj = 1 to num-entries({&check-fields-par}):
        v-curr-field = entry(jj, {&check-fields-par}).
        if lookup(v-curr-field, v-tree) > 0 then do:
          case v-curr-field:
            when "date-period" then do:
              v-curr-field1 = "date-from".
              v-curr-field2 = "date-to".
            end.
            when "time-period" then do:
              v-curr-field1 = "time-from".
              v-curr-field2 = "time-to".
            end.
          end case.
          assign
          ii = ii + 1
          .
          if (
             (buffer dub_tt-dis-time-rule:buffer-field(v-curr-field1):buffer-value <=
              buffer tt0-term_dis-time-rule:buffer-field(v-curr-field2):buffer-value
              and
              buffer dub_tt-dis-time-rule:buffer-field(v-curr-field1):buffer-value >=
              buffer tt0-term_dis-time-rule:buffer-field(v-curr-field1):buffer-value)
          or
            (buffer dub_tt-dis-time-rule:buffer-field(v-curr-field2):buffer-value >=
             buffer tt0-term_dis-time-rule:buffer-field(v-curr-field1):buffer-value
          and
             buffer dub_tt-dis-time-rule:buffer-field(v-curr-field2):buffer-value >=
             buffer tt0-term_dis-time-rule:buffer-field(v-curr-field2):buffer-value)
          or
            (buffer dub_tt-dis-time-rule:buffer-field(v-curr-field2):buffer-value >=
             buffer tt0-term_dis-time-rule:buffer-field(v-curr-field1):buffer-value
             and
             buffer dub_tt-dis-time-rule:buffer-field(v-curr-field1):buffer-value <=
             buffer tt0-term_dis-time-rule:buffer-field(v-curr-field1):buffer-value)
           )
          and recid(dub_tt-dis-time-rule) <> recid(tt0-term_dis-time-rule) then do:
            assign
            v-dub = yes
            .
            run distruls-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                            , input v-curr-field
                                                            , output v-field-label).

            run err-mess in this-procedure (substitute("Не могут быть два детализированных правила скидки для пересекающихся периодов &1"
                                          , v-field-label)).
            LEAVE _dub-tt.
          end.
          if v-num-rec[jj] > 0 then do:
            CASE v-num-rec-sign[jj]:
              when "<=":U then do:
                if ii >= v-num-rec[jj] then do:
                  assign
                  v-dub = yes
                  .
                  run err-mess in this-procedure (substitute("Не могут быть больше &1 правила скидки, детализированных по периодам &2"
                                      , v-num-rec[jj]
                                      , v-field-label)).
                  LEAVE _dub-tt.
                end.
              end.
            END CASE. /*CASE v-num-rec-sign[jj]:                                           */
          end.  /*if v-num-rec[jj] > 0 then do:                                        ~*/
        end. /*if lookup(v-curr-field, v-tree) > 0 then do:*/
      end. /*      do jj = 1 to num-entries({&check-fields-par}):*/
      */
      /*  todo
&scop check-tree-branch-week-day ~
      assign                                                                                         ~
      ii = 0.                                                                                        ~
      if v-tree-field[~{&~{&check-field-name~}~}]  then do:                                          ~
        assign                                                                                       ~
        ii = ii + 1                                                                                  ~
        .                                                                                            ~
        if ~{&check-function-name~}(buffer tt0-term_dis-time-rule, '~{&check-field-name~}') = ~{&check-function-name~}(buffer dub_tt-dis-time-rule, '~{&check-field-name~}' ) ~
        and recid(dub_tt-dis-time-rule) <> recid(tt0-term_dis-time-rule) then do:                              ~                                                       ~
          assign                                                                                     ~
          v-dub = yes                                                                                ~
          .                                                                                          ~
          run err-mess in this-procedure (substitute("Не могут быть два детализированных правила скидки &1", ~{&check-message~})). ~
          LEAVE _dub-tt.                                                                             ~
        end.                                                                                         ~
        if ~{&check-function-name~}(buffer tt0-term_dis-time-rule, '~{&check-field-name~}') = ? then do:  ~
          run err-mess in this-procedure (substitute("Неверно заданы дни недели в детализированном правиле скидки по &1", ~{&check-message~})). ~
          LEAVE _dub-tt.                                                                             ~
        end.                                                                                              ~
        if v-num-rec[~{&~{&check-field-name~}~}] > 0 then do:                                        ~
          CASE v-num-rec-sign[~{&~{&check-field-name~}~}]:                                           ~
            when "<=":U then do:                                                                     ~
              if ii >= v-num-rec[~{&~{&check-field-name~}~}] then do:                                ~
                assign                                                                               ~
                v-dub = yes                                                                          ~
                .                                                                                    ~
                run err-mess in this-procedure (substitute("Не могут быть больше &1 правила скидки, детализированных по &2", v-num-rec[~{&~{&check-field-name~}~}], ~{&check-message-2~})). ~
                LEAVE _dub-tt. ~                                                                     ~
              end. ~                                                                                 ~
            end. ~                                                                                   ~
          END CASE.                                                                                  ~
        end. ~
      end


      */


    end. /*for each dub_tt-dis-time-rule no-lock where */
  end. /*for each tt0-term_dis-time-rule no-lock where*/
  if v-dub then do:
    undo, return error "time-rule-num":U.
  end.
end. /*v-tree <> "":U*/



_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-new-time-rule-num) no-error .
    if error-status:error then do:
      run err-mess in this-procedure (substitute("Ошибка при попытке создания номера расписания: &1", return-value )).
      undo _main, return error .
    end.
    create ub.dis-time-rule.
    assign
    ub.dis-time-rule.time-rule-num = v-new-time-rule-num
    p-recid = recid(ub.dis-time-rule)
    .
  end.
  else do:
    FIND FIRST ub.dis-time-rule where
              recid(ub.dis-time-rule) = p-recid No-ERROR.
    if not available ub.dis-time-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись РАСПИСАНИЕ - p-recid" string(p-recid)
      view-as alert-box error .
      undo, return error '':u.
    end.
  end.
  assign
  ub.dis-time-rule.des               = p-des
  ub.dis-time-rule.sts               = (if p-mode = {&add-def} then integer({&current-status-int}) else ub.dis-time-rule.sts)
  ub.dis-time-rule.upper-time-rule-num    = p-upper-time-rule-num
  ub.dis-time-rule.value-type        = p-value-type
  ub.dis-time-rule.date-from         = p-date-from
  ub.dis-time-rule.date-to           = p-date-to
  ub.dis-time-rule.time-from         = p-time-from
  ub.dis-time-rule.time-to           = p-time-to
  ub.dis-time-rule.month-day         = p-month-day
  ub.dis-time-rule.week-day-0        = p-week-day-0
  ub.dis-time-rule.week-day-1        = p-week-day-1
  ub.dis-time-rule.week-day-2        = p-week-day-2
  ub.dis-time-rule.week-day-3        = p-week-day-3
  ub.dis-time-rule.week-day-4        = p-week-day-4
  ub.dis-time-rule.week-day-5        = p-week-day-5
  ub.dis-time-rule.week-day-6        = p-week-day-6
  ub.dis-time-rule.week-day-7        = p-week-day-7
  ub.dis-time-rule.root              = yes
  ub.dis-time-rule.lvl-num           = 1
  ub.dis-time-rule.is-term           = (v-tree = "":U)
  ub.dis-time-rule.uniq-field        = v-tree
  ub.dis-time-rule.other-inf         = v-other
  ub.dis-time-rule.rl-root           = ub.dis-time-rule.time-rule-num
  ub.dis-time-rule.templ-rl-root     = p-upper-time-rule-num
  v-time-rule-num                    = ub.dis-time-rule.time-rule-num
  .
  release ub.dis-time-rule no-error.
  if error-status:error then do:
     run err-mess in this-procedure (substitute("Ошибка при сохранении записи РАСПИСАНИЕ с номером &1: &2: &3"
                            , v-time-rule-num
                            , ERROR-STATUS:GET-message(1)
                            , return-value
                            )).
    undo, return error "":U.
 end.

 if p-mode <> {&add-def} then do:
  for each term_dis-time-rule where
          term_dis-time-rule.upper-time-rule-num = v-time-rule-num:
    find first tt0-term_dis-time-rule no-lock where
                tt0-term_dis-time-rule.upper-time-rule-num = v-time-rule-num
            AND tt0-term_dis-time-rule.time-rule-num = term_dis-time-rule.time-rule-num no-error .
    if not available tt0-term_dis-time-rule then do:
      delete term_dis-time-rule no-error .
      if error-status:error then do:
        run err-mess in this-procedure (substitute("Ошибка при попытке удаления расписания: &1 (детализация к расписанию &2): &3 ", tt0-term_dis-time-rule.time-rule-num, v-time-rule-num, return-value )).
        undo _main, return error .
      end.
    end.
  end.
 end.
 for each tt0-term_dis-time-rule :
    find first term_dis-time-rule where
                term_dis-time-rule.upper-time-rule-num = v-time-rule-num
            AND term_dis-time-rule.time-rule-num       = tt0-term_dis-time-rule.time-rule-num
            no-error .
    if not available term_dis-time-rule then do:

      run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-new-time-rule-num) no-error .
      if error-status:error then do:
      end.
      create term_dis-time-rule.
      assign
      term_dis-time-rule.upper-time-rule-num = v-time-rule-num
      term_dis-time-rule.time-rule-num       = v-new-time-rule-num
      term_dis-time-rule.rl-root        = v-time-rule-num
      .
      v-run-cn = yes.
    end.
    buffer-copy tt0-term_dis-time-rule except time-rule-num upper-time-rule-num root is-term lvl-num uniq-field
    time-from time-to date-from date-to month-day
    week-day-0 week-day-1 week-day-2 week-day-3 week-day-4 week-day-5 week-day-6 week-day-7
    to term_dis-time-rule
    assign
    term_dis-time-rule.time-from = (if lookup("time-from", vt-level-2) = 0
                                    then -1
                                    else tt0-term_dis-time-rule.time-from)
    term_dis-time-rule.time-to = (if lookup("time-to", vt-level-2) = 0
                                  then -1
                                  else tt0-term_dis-time-rule.time-to)
    term_dis-time-rule.date-from = (if lookup("date-from", vt-level-2) = 0
                                    then 12/31/1989
                                    else tt0-term_dis-time-rule.date-from)
    term_dis-time-rule.date-to = (if lookup("date-to", vt-level-2) = 0
                                   then 12/31/1989
                                   else tt0-term_dis-time-rule.date-to)
    term_dis-time-rule.week-day-0 = (if lookup("week-day-0", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-0)
    term_dis-time-rule.week-day-1 = (if lookup("week-day-1", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-1)
    term_dis-time-rule.week-day-2 = (if lookup("week-day-2", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-2)
    term_dis-time-rule.week-day-3 = (if lookup("week-day-3", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-3)
    term_dis-time-rule.week-day-4 = (if lookup("week-day-4", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-4)
    term_dis-time-rule.week-day-5 = (if lookup("week-day-5", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-5)
    term_dis-time-rule.week-day-6 = (if lookup("week-day-6", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-6)
    term_dis-time-rule.week-day-7 = (if lookup("week-day-7", vt-level-2) = 0
                                     then ?
                                     else tt0-term_dis-time-rule.week-day-7)
    term_dis-time-rule.month-day = (if lookup("month-day", vt-level-2) = 0
                                    then -1
                                    else tt0-term_dis-time-rule.month-day)
    term_dis-time-rule.root              = no
    term_dis-time-rule.lvl-num           = 2
    term_dis-time-rule.is-term           = yes
    term_dis-time-rule.uniq-field        = v-tree
    term_dis-time-rule.other-inf         = v-other
    .
    release term_dis-time-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure (substitute("Ошибка при попытке сохранения расписания: &1 (детализация к правилу &2): &3 ", v-new-time-rule-num, v-time-rule-num, return-value )).
      undo _main, return error .
    end.
  end.
 if v-run-cn then do:
    find first ub.dis-time-rule no-lock where
              ub.dis-time-rule.time-rule-num = v-time-rule-num .
    run str/callnews.p
        (input {&table_dis-time-rule}
        ,input (buffer ub.dis-time-rule:handle)
        ).
  end.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("ПРАВИЛО СКИДКИ &1: ", (if p-mode = {&update} then string(p-time-rule-num) else p-des) ) + {&new-line} + p-mess.
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.

procedure check-changes :
define input parameter p-time-rule-num like ub.dis-time-rule.time-rule-num no-undo .
define output parameter p-changes as logical no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.

  do
  on error undo, return error
  :
    find first buf_dis-time-rule where buf_dis-time-rule.time-rule-num = p-time-rule-num.
    assign
    p-changes = (buf_dis-time-rule.value-type        <> p-value-type)
                or
                (buf_dis-time-rule.date-from         <> p-date-from )
                or
                (buf_dis-time-rule.date-to           <> p-date-to   )
                or
                (buf_dis-time-rule.time-from         <> p-time-from )
                or
                (buf_dis-time-rule.time-to           <> p-time-to   )
                or
                (buf_dis-time-rule.month-day         <> p-month-day )
                or
                (buf_dis-time-rule.week-day-0        <> p-week-day-0)
                or
                (buf_dis-time-rule.week-day-1        <> p-week-day-1)
                or
                (buf_dis-time-rule.week-day-2        <> p-week-day-2)
                or
                (buf_dis-time-rule.week-day-3        <> p-week-day-3)
                or
                (buf_dis-time-rule.week-day-4        <> p-week-day-4)
                or
                (buf_dis-time-rule.week-day-5        <> p-week-day-5)
                or
                (buf_dis-time-rule.week-day-6        <> p-week-day-6)
                or
                (buf_dis-time-rule.week-day-7        <> p-week-day-7)
  .


  end.

end procedure. /* check-changes */

procedure distruls-override-labels-2 :
define input parameter p-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
define input parameter p-field-name as character no-undo .
define output parameter p-label as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.


do
on error undo, return error
:
  for each buf_temp-drt-prop no-lock where
                  buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
              and buf_temp-drt-prop.prop-code = "Label":U
              aND buf_temp-drt-prop.UPPER-prop-code = p-field-name
              :
    assign
    p-label = buf_temp-drt-prop.property-value
    .
    leave.
  end. /*for each */
  if p-label = '':U then do:
    case p-field-name:
      when "date-from" then do:
        p-label = "Дата с".
      end.
      when "date-to" then do:
        p-label = "Дата по".
      end.
      when "time-from" then do:
        p-label = "Время с".
      end.
      when "time-to" then do:
        p-label = "Время по".
      end.
      when "week-day-0" then do:
        p-label = "Все дни недели".
      end.
      when "week-day-1" then do:
        p-label = "Понедельник".
      end.
      when "week-day-2" then do:
        p-label = "Вторник".
      end.
      when "week-day-3" then do:
        p-label = "Среда".
      end.
      when "week-day-4" then do:
        p-label = "Четверг".
      end.
      when "week-day-5" then do:
        p-label = "Пятница".
      end.
      when "week-day-6" then do:
        p-label = "Суббота".
      end.
      when "week-day-7" then do:
        p-label = "Восресенье".
      end.
      when "month-day" then do:
        p-label = "День месяца".
      end.
      when "time-period" then do:
        p-label = "Период времени суток".
      end.
      when "date-period" then do:
        p-label = "Период дат".
      end.
    end case.
  end.

  end. /*doe*/

end procedure. /* distruls-override-labels-2 */