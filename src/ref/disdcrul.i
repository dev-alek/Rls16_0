/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/06
Author: Bakhtadze Natalya
Creation date: 12/28/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/disrules.i }
{ gbl/discfgru.i }
{ gbl/get-regf.i }

procedure disdcrul-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :

  define input  parameter p-templ-rl-root  as integer no-undo . /* код атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.

  if available buf_dis-rule then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.


end.
end procedure.

function disdcrul-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdcrul-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.


function disdcrul-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
&scoped-define dis-dc-rule-code p-discnt-role
return {&dis-dc-rule-name}.
end function.


procedure disdcrul-write :

  do
  on error undo, return error
  :

    define input parameter p-d-card         like ub.dis-dc-rule.d-card     no-undo .
    define input parameter p-host-code      like ub.dis-dc-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dc-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dc-rule.obj-code   no-undo .
    define input parameter p-pos-type       like ub.dis-dc-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dc-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dc-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dc-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dc-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-dc-rule.nonunique   no-undo .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-dc-rule for ub.dis-dc-rule .
    define buffer lock_dis-dc-rule for ub.dis-dc-rule .

    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .

    run discfgru-check in this-procedure (
                                          input {&table_dis-dc-rule}
                                         ,input p-templ-rl-root   /* p-templ-rl-root   */
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type        /**/
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:

&scop dis-gds-rule-code p-discnt-role
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-templ-rl-root
                              ,p-rule-num).


    end.
    if p-pos-type = ? then do:
      { gbl/dflt-cd.i p-obj-type p-obj-code p-pos-type }
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7не найдено правило скидки &8"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-rule-num).

    end.
    if not (p-host-code = buf_dis-rule.host-code
        and p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    then do:
      undo, return error (substitute("ДК &1 Фирма &2 &3&4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-d-card
                              ,p-host-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              )
                          +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к ДК для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,{&new-line}
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-dc-rule exclusive-lock where
               buf_dis-dc-rule.d-card  = p-d-card
           AND buf_dis-dc-rule.obj-type  = p-obj-type
           AND buf_dis-dc-rule.host-code = p-host-code
           AND buf_dis-dc-rule.obj-code  = p-obj-code
           AND buf_dis-dc-rule.pos-type  = p-pos-type
           AND buf_dis-dc-rule.discnt-role = p-discnt-role
           and buf_dis-dc-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-dc-rule then do:
      create buf_dis-dc-rule .
      assign
      buf_dis-dc-rule.d-card  = p-d-card
      buf_dis-dc-rule.host-code  = p-host-code
      buf_dis-dc-rule.obj-type  = p-obj-type
      buf_dis-dc-rule.obj-code  = p-obj-code
      buf_dis-dc-rule.pos-type = p-pos-type
      buf_dis-dc-rule.discnt-role = v-discnt-role
      buf_dis-dc-rule.rule-num = p-rule-num
      buf_dis-dc-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-dc-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dc-rule.rule-num = p-rule-num
    buf_dis-dc-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dc-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dc-rule.nonunique = p-nonunique
    no-error.
  end.

end procedure.

&if "{1}" = "interface"  &then

procedure disdcrul-edit :
define input parameter p-mode as character no-undo .
define input parameter p-d-card   like ub.dis-dc-rule.d-card no-undo .
define input parameter p-host-code like ub.dis-dc-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-dc-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-dc-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-dc-rule.pos-type no-undo .
define input parameter p-discnt-role like ub.dis-dc-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-dc-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-dc-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-nonunique as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-NONUNIQUE like ub.dis-cfg-rule.NONUNIQUE no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-value as character no-undo .
define variable v-sts as integer no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-cd-dr-correct  as logical no-undo .
define variable jj as integer no-undo .
define variable conf-par as character no-undo .
define variable conf-attr as character no-undo .
define variable par-type as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-cd-list as character no-undo .
define variable v-is-time-rule as logical no-undo .
define variable v-label as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-mode as character no-undo .

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_{3} for {3}.

assign
v-rule-num = p-rule-num.
v-sts = integer({&current-status-int}).
if v-rule-num <> 0
and v-rule-num <> ?
then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num no-error .
  if error-status:error then do:
    message
    "Ошибка при поиске правила с номером" v-rule-num
    view-as alert-box error .
    return .
  end.
  assign
  v-rid-list = string(recid(buf_dis-rule))
  .
end.
run disdcrul-name in this-procedure (
                              input p-templ-rl-root
                              ,output v-label) no-error.

if p-pos-type = ?
or p-pos-type = '':U then do:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
end.
else do:
  dflt-cd = p-pos-type.
end.
v-mode =  ({&table_dis-dc-rule} + "=" + p-discnt-role).
run ref/dis-ruls.w (
            input {2}
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input v-mode
            ,input p-templ-rl-root
            ,input p-time-templ-rl-root
            ,input 0
            ,input-output v-sts
            ,input-output v-rid-list ) no-error .


do
on error undo, return error return-value
:

  if v-rid-list <> "":U then do:
    find first buf_dis-rule exclusive-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-wait no-error .
    if not available buf_dis-rule
    then do:
      message
      "Ошибка при поиске правила с recid" v-rid-list
      view-as alert-box error .
      return .
    end.
    if buf_dis-rule.sts <> integer({&used-status-int}) then do:
&scop used-status-code string(buf_dis-rule.sts)
      message
      "Правило скидки имеет статус" {&used-status-int-name} skip
      "Нельзя привязать к нему скидку на ДК"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
             buf_dis-cfg-rule.templ-rl-root =  buf_dis-rule.templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = 0
                                                    then 0
                                                    else buf_dis-rule.time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = dflt-cd
        and buf_Dis-cfg-rule.table-name = {&table_dis-dc-rule}
        no-error.
    if available buf_dis-cfg-rule then do:
      assign
      v-cd-dr-correct = yes
      .
    end.
    if not v-cd-dr-correct
    then do:
      message
      substitute("Правило скидки &1 неприменимо для касс &2.&3" +
                "(АРМ АДМИНИСТРАТОР-Магазины(Фирмы)-Параметры-Общие опции коммуникации с кассами)"
                ,buf_dis-rule.rule-num
                ,dflt-cd
                ,{&new-line}
                )
      view-as alert-box error .
      undo, return error .
    end.
    assign
    v-nonunique = if p-cfg-nonunique = '':U
                  then '':U
                  else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value).
    if p-check = 0
    or p-check = 2
    then do:
      find first buf_dis-dc-rule no-lock where
                  buf_dis-dc-rule.obj-type = p-obj-type
              and buf_dis-dc-rule.obj-code = p-obj-code
              and buf_dis-dc-rule.host-code = p-host-code
              and buf_dis-dc-rule.d-card = p-d-card
              and buf_dis-dc-rule.pos-type = p-pos-type
              and buf_dis-dc-rule.discnt-role = p-discnt-role
              and buf_dis-dc-rule.nonunique = v-nonunique no-error .
      if available buf_dis-dc-rule
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данную ДК уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_{3} no-lock where
                  buf_{3}.obj-type = p-obj-type
              and buf_{3}.obj-code = p-obj-code
              and buf_{3}.host-code = p-host-code
              &if "{3}" = "temp-disc" &then
              &else
              and buf_{3}.d-card = p-d-card
              &endif
              and buf_{3}.pos-type = p-pos-type
              and buf_{3}.templ-rl-root = p-templ-rl-root
              and buf_{3}.nonunique = v-nonunique no-error .
      if available buf_{3}
      and buf_{3}.rule-num <> 0
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данную ДК уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-rule-num <> buf_dis-rule.rule-num then do:
      assign
      p-setted = yes
      p-rule-num = buf_dis-rule.rule-num
      p-nonunique = v-nonunique
      .
    end.
  end.
end. /*doe*/

end procedure. /* disdcrul-edit */
&endif

/*interface*/