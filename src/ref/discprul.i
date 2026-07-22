/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/06
Author: Bakhtadze Natalya
Creation date: 12/13/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/disrules.i }
{ gbl/discfgru.i }
{ gbl/get-regf.i }

procedure discpru-name :
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
    p-label = substitute("Неизвестный шаблон правила скидки &1", p-templ-rl-root).
  end.


end.
end procedure.

function discpru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run discpru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.


function discpru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
&scoped-define dis-cp-rule-code p-discnt-role
return {&dis-cp-rule-name}.
end function.


procedure discpru-write :

  do
  on error undo, return error
  :

    define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
    define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
    define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
    define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .

    define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-cp-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-cp-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-cp-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .

    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-cp-rule for ub.dis-cp-rule .
    define buffer lock_dis-cp-rule for ub.dis-cp-rule .

    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .

    run discfgru-check in this-procedure (
                                          input {&table_dis-cp-rule}
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

&scop dis-cp-rule-code p-discnt-role
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,{&dis-cp-rule-name}
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
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не найдено правило скидки &8"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,{&dis-cp-rule-name}
                              ,{&new-line}
                              ,p-rule-num).


    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &8 - некорневое"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,{&dis-cp-rule-name}
                              ,{&new-line}
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code) then do:
      undo, return error (substitute("Тип платежа &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &8"
                              ,p-cdpay-code
                              ,p-curr-code
                              ,p-host-code
                              ,(p-obj-type + string(p-obj-code))
                              ,p-pos-type
                              ,{&dis-cp-rule-name}
                              ,{&new-line}
                              ,p-rule-num)
                          +
                          substitute("Правило скидки &1 определено для &1&2" +
                                     "а привязка к ДК для &3"
                                     ,get-region( buf_Dis-rule.host-code, buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,{&new-line}
                                     ,get-region( p-host-code, p-obj-type, p-obj-code)
                                     ))
                              .
    end.

    find first buf_dis-cp-rule exclusive-lock where
               buf_dis-cp-rule.cdpay-code  = p-cdpay-code
           AND buf_dis-cp-rule.curr-code  = p-curr-code
           AND buf_dis-cp-rule.obj-type  = p-obj-type
           AND buf_dis-cp-rule.host-code = p-host-code
           AND buf_dis-cp-rule.obj-code  = p-obj-code
           AND buf_dis-cp-rule.pos-type  = p-pos-type
           AND buf_dis-cp-rule.discnt-role = p-discnt-role
           and buf_dis-cp-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-cp-rule then do:
      create buf_dis-cp-rule .
      assign
      buf_dis-cp-rule.cdpay-code  = p-cdpay-code
      buf_dis-cp-rule.curr-code  = p-curr-code
      buf_dis-cp-rule.host-code  = p-host-code
      buf_dis-cp-rule.obj-type  = p-obj-type
      buf_dis-cp-rule.obj-code  = p-obj-code
      buf_dis-cp-rule.pos-type = p-pos-type
      buf_dis-cp-rule.discnt-role = v-discnt-role
      buf_dis-cp-rule.rule-num = p-rule-num
      buf_dis-cp-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-cp-rule.rule-num = p-rule-num
    buf_dis-cp-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-cp-rule.templ-rl-root = p-templ-rl-root
    buf_dis-cp-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-cp-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.

procedure discpru-delete :
define input parameter p-cdpay-code     like ub.dis-cp-rule.cdpay-code  no-undo .
define input parameter p-curr-code      like ub.dis-cp-rule.curr-code  no-undo .
define input parameter p-host-code      like ub.dis-cp-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-cp-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-cp-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-cp-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-cp-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
do
on error undo, return error
:

find first buf_dis-cp-rule exclusive-lock where
            buf_dis-cp-rule.cdpay-code  = p-cdpay-code
        AND buf_dis-cp-rule.curr-code  = p-curr-code
        AND buf_dis-cp-rule.obj-type  = p-obj-type
        AND buf_dis-cp-rule.host-code = p-host-code
        AND buf_dis-cp-rule.obj-code  = p-obj-code
        AND buf_dis-cp-rule.pos-type  = p-pos-type
        AND buf_dis-cp-rule.discnt-role = p-discnt-role
        and buf_dis-cp-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-cp-rule then do:
  return '':U.
end.
delete buf_dis-cp-rule no-error.
if error-status:error then do:
  run discpru-name in this-procedure
    (input  buf_dis-cp-rule.templ-rl-root        /* p-templ-rl-root           */
    ,output v-rule-label          /* p-label          */
    ) no-error .
&scop cd-type-code p-pos-type
  undo, return error substitute("Ошибка при удалении скидки по типу касс. платежа:&1" +
                               "скидка &2 (POS &3) на фирме &4 &5&6 для платежа&1&7&1&8"
                                ,{&new-line}
                                ,v-rule-label
                                ,p-pos-type
                                ,p-host-code
                                ,p-obj-type
                                ,p-obj-code
                                ,error-status:get-message(1)
                                ,return-value ).
end.
p-deleted = yes.
return '':U.
end. /*doe*/
end procedure.


&if "{1}" = "interface"  &then



procedure discpru-edit :
define input parameter p-mode as character no-undo .
define input parameter p-cdpay-code   like ub.dis-cp-rule.cdpay-code no-undo .
define input parameter p-curr-code   like ub.dis-cp-rule.curr-code no-undo .
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-cp-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-cp-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-cp-rule.pos-type no-undo .
define input parameter p-discnt-role    like ub.dis-cp-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-cp-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-cp-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-NONUNIQUE as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-nonunique as character no-undo .
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
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-cpdisc for temp-cpdisc.


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
  run discpru-name in this-procedure (
                                input p-templ-rl-root
                                ,output v-label) no-error.

if p-pos-type = ?
or p-pos-type = '':U then do:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
end.
else do:
  dflt-cd = p-pos-type.
end.
v-mode =  {&table_dis-cp-rule} + "=" + p-discnt-role + "=" + (if p-host-code = 0
                                                             then "global"
                                                             else (if p-obj-type = ''
                                                                  then "host"
                                                                  else "object")
                                                             ) .

run ref/dis-ruls.w (
            input {2}
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input "upper-rule-num-object":u  /*v-mode*/
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
      "Нельзя привязать к нему скидку на платеж"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = -1
                                                   then 0
                                                   else buf_dis-rule.time-templ-rl-root)
        and buf_dis-cfg-rule.table-name = {&table_dis-cp-rule}
        and buf_dis-cfg-rule.pos-type = dflt-cd no-error.
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
      find first buf_dis-cp-rule no-lock where
                 buf_dis-cp-rule.host-code = p-host-code
              and buf_dis-cp-rule.obj-type = p-obj-type
              and buf_dis-cp-rule.obj-code = p-obj-code
              and buf_dis-cp-rule.curr-code = p-curr-code
              and buf_dis-cp-rule.cdpay-code = p-cdpay-code
              and buf_dis-cp-rule.pos-type = p-pos-type
              and buf_dis-cp-rule.discnt-role = p-discnt-role
              and buf_dis-cp-rule.nonunique = v-nonunique no-error .
      if available buf_dis-cp-rule
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный тип платежа уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_temp-cpdisc no-lock where
                 buf_temp-cpdisc.host-code = p-host-code
              and buf_temp-cpdisc.obj-type = p-obj-type
              and buf_temp-cpdisc.obj-code = p-obj-code
              and buf_temp-cpdisc.cdpay-code = p-cdpay-code
              and buf_temp-cpdisc.curr-code = p-curr-code
              and buf_temp-cpdisc.pos-type = p-pos-type
              and buf_temp-cpdisc.discnt-role = p-discnt-role
              and buf_temp-cpdisc.nonunique = v-nonunique no-error .
      if available buf_temp-cpdisc
      and buf_temp-cpdisc.rule-num <> 0
      and p-mode <> {&update}
      then do:
        message
      "Скидка такого типа на данный тип платежа уже существует"
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

end procedure. /* discpru-edit */

&endif

/*interface*/