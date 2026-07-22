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

procedure disdctru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :

  define input  parameter p-templ-rl-root  as integer no-undo . /* код атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.

  if available buf_dis-rule then do:
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.


end.
end procedure.

function disdctru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disdctru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.


function disdctru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
&scoped-define  dis-dct-rule-code p-discnt-role
return {&dis-dct-rule-name}.
end function.


procedure disdctru-write :

  do
  on error undo, return error
  :

    define input parameter p-type           like ub.dis-dct-rule.type       no-undo .
    define input parameter p-emitent-host-code      like ub.dis-dct-rule.emitent-host-code  no-undo .
    define input parameter p-host-code      like ub.dis-dct-rule.host-code  no-undo .
    define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .

    define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-dct-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-dct-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-dct-rule.rule-num    no-undo .
    define input parameter p-NONUNIQUE as character no-undo .

    define buffer buf_dis-dct-rule for ub.dis-dct-rule .
    define buffer lock_dis-dct-rule for ub.dis-dct-rule .
    define buffer buf_dis-rule for ub.dis-rule.

    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .

    run discfgru-check in this-procedure (
                                          input {&table_dis-dct-rule}
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

&scop dis-dct-rule-code p-discnt-role
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не может быть по шаблону &8 и расписанию &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,{&dis-dct-rule-name}
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
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7не найдено правило скидки &9"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,{&dis-dct-rule-name}
                              ,{&new-line}
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Тип ДК &1 код валюты &2 фирма &3 &4 место использ. &5 скидка типа &6&7правило скидки &9 - некорневое"
                              ,p-type
                              ,p-emitent-host-code
                              ,p-host-code
                              ,p-obj-type + string(p-obj-code)
                              ,p-pos-type
                              ,{&dis-dct-rule-name}
                              ,{&new-line}
                              ,p-templ-rl-root
                              ,p-rule-num).

    end.
    find first buf_dis-dct-rule exclusive-lock where
               buf_dis-dct-rule.type  = p-type
           AND buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
           AND buf_dis-dct-rule.obj-type  = p-obj-type
           AND buf_dis-dct-rule.host-code = p-host-code
           AND buf_dis-dct-rule.obj-code  = p-obj-code
           AND buf_dis-dct-rule.pos-type  = p-pos-type
           AND buf_dis-dct-rule.discnt-role = p-discnt-role  no-error .
    if not available buf_dis-dct-rule then do:
      create buf_dis-dct-rule .
      assign
      buf_dis-dct-rule.type  = p-type
      buf_dis-dct-rule.emitent-host-code  = p-emitent-host-code
      buf_dis-dct-rule.host-code  = p-host-code
      buf_dis-dct-rule.obj-type  = p-obj-type
      buf_dis-dct-rule.obj-code  = p-obj-code
      buf_dis-dct-rule.pos-type = p-pos-type
      buf_dis-dct-rule.discnt-role = v-discnt-role
      buf_dis-dct-rule.rule-num = p-rule-num no-error
      .
    end.
    ELSE
    ASSIGN
    buf_dis-dct-rule.rule-num = p-rule-num
    buf_dis-dct-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-dct-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-dct-rule.templ-rl-root = p-templ-rl-root
    buf_dis-dct-rule.nonunique = p-nonunique
    no-error.
  end.

end procedure.

procedure disdctru-delete :
define input parameter p-cdpay-code     like ub.dis-dct-rule.emitent-host-code no-undo .
define input parameter p-curr-code      like ub.dis-dct-rule.type no-undo .
define input parameter p-host-code      like ub.dis-dct-rule.host-code   no-undo .
define input parameter p-obj-type       like ub.dis-dct-rule.obj-type   no-undo .
define input parameter p-obj-code       like ub.dis-dct-rule.obj-code   no-undo .
define input parameter p-pos-type       like ub.dis-dct-rule.pos-type   no-undo .
define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
define input parameter p-nonunique      like ub.dis-dct-rule.nonunique   no-undo .
define output parameter p-deleted       as logical no-undo .
define variable v-rule-label as character no-undo .
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
do
on error undo, return error
:

find first buf_dis-dct-rule exclusive-lock where
            buf_dis-dct-rule.emitent-host-code  = p-host-code
        AND buf_dis-dct-rule.type  = p-type
        AND buf_dis-dct-rule.obj-type  = p-obj-type
        AND buf_dis-dct-rule.host-code = p-host-code
        AND buf_dis-dct-rule.obj-code  = p-obj-code
        AND buf_dis-dct-rule.pos-type  = p-pos-type
        AND buf_dis-dct-rule.discnt-role = p-discnt-role
        and buf_dis-dct-rule.nonunique = p-nonunique
        no-error .
if not available buf_dis-dct-rule then do:
  return '':U.
end.
delete buf_dis-dct-rule no-error.
if error-status:error then do:
  run disdctru-name in this-procedure
    (input  buf_dis-dct-rule.templ-rl-root        /* p-templ-rl-root           */
    ,output v-rule-label          /* p-label          */
    ) no-error .
&scop cd-type-code p-pos-type
  undo, return error substitute("Ошибка при удалении скидки по типу ДК:&1" +
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

procedure disdctru-edit :
define input parameter p-mode as character no-undo .
define input parameter p-type   like ub.dis-dct-rule.type no-undo .
define input parameter p-emitent-host-code like ub.dis-dct-rule.emitent-host-code no-undo .
define input parameter p-host-code like ub.dis-dct-rule.host-code no-undo .
define input parameter p-obj-type like ub.dis-dct-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-dct-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-dct-rule.pos-type no-undo .
define input parameter p-discnt-role    like ub.dis-dct-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-dct-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-dct-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-NONUNIQUE as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-NONUNIQUE like ub.dis-dct-rule.NONUNIQUE no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-value as character no-undo .
define variable v-sts as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
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
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_temp-odisc for temp-odisc.


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
  run disdctru-name in this-procedure (
                                input p-templ-rl-root
                                ,output v-label) no-error.

if p-pos-type = ?
or p-pos-type = '':U then do:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
end.
else do:
  dflt-cd = p-pos-type.
end.

run ref/dis-ruls.w (
            input {2}
            ,input p-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input (if p-obj-code > 0
                    then "upper-rule-num-object"
                    else ( if p-host-code > 0
                           then "upper-rule-num-host"
                           else "upper-rule-num-global"
                         )
                   )
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
      "Нельзя привязать к нему скидку на тип ДК"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = 0
                                                   then 0
                                                   else buf_dis-rule.time-templ-rl-root)
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
    v-nonunique = if p-cfg-nonunique = '':U
                  then '':U
                  else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value).
    if p-check = 0
    or p-check = 2
    then do:
      find first buf_dis-dct-rule no-lock where
                 buf_dis-dct-rule.host-code = p-host-code
              and buf_dis-dct-rule.obj-type = p-obj-type
              and buf_dis-dct-rule.obj-code = p-obj-code
              and buf_dis-dct-rule.type = p-type
              and buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
              and buf_dis-dct-rule.pos-type = p-pos-type
              and buf_dis-dct-rule.discnt-role = p-discnt-role
              and buf_dis-dct-rule.nonunique = v-nonunique no-error .
      if available buf_dis-dct-rule
      then do:
        if p-mode = {&add-def} then do:
          message
          "Скидка такого типа на данный тип ДК уже существует"
          view-as alert-box error .
          return error.
        end.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_temp-odisc no-lock where
                 buf_temp-odisc.host-code = p-host-code
              and buf_temp-odisc.obj-type = p-obj-type
              and buf_temp-odisc.obj-code = p-obj-code
              and buf_temp-odisc.type = p-type
              and buf_temp-odisc.emitent-host-code = p-emitent-host-code
              and buf_temp-odisc.pos-type = p-pos-type
              and buf_temp-odisc.discnt-role = p-discnt-role
              and buf_temp-odisc.nonunique = v-nonunique no-error .
      if available buf_temp-odisc
      and buf_temp-odisc.rule-num <> 0
      then do:
        if p-mode = {&add-def} then do:
          message
        "Скидка такого типа на данный тип ДК уже существует"
          view-as alert-box error .
          return error.
        end.
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

end procedure. /* disdctru-edit */

&endif

/*interface*/