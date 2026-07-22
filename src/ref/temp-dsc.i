/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица хранения шаблонов скидок различных сущностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06


1 - new shared , shared , "":U
2  - имя таблицы с которой работаем
3 - текущий host
4 - текущий объект
5 - текцущий объект

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-disc no-undo
field rule-num as integer
field host-code as integer
field obj-type as character
field obj-code as integer
field templ-rl-root as integer
field time-templ-rl-root as integer
field discnt-role as character
field nonunique as character
field cfg-nonunique as character
field pos-type as character
field action as logical
field label_ as character
index pi is  unique primary
pos-type discnt-role nonunique host-code obj-type obj-code action ASCENDING
index action
action
index ipos
pos-type discnt-role
.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure temp-dsc-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
define input  parameter p-pos-type  as character  no-undo .
define input  parameter p-templ-rl-root as integer  no-undo .
define input  parameter p-time-templ-rl-root as integer no-undo .
define input  parameter p-discnt-role  as character  no-undo .
define input  parameter p-cfg-nonunique as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-0mode as character no-undo .
define input  parameter p-mode      as character no-undo .
define input  parameter p-rec as recid no-undo .
define output parameter p-rule-num    as integer no-undo .
define output parameter p-nonunique   as character no-undo .

define buffer buf_temp-disc for temp-disc .
define variable v-discnt-role as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-setted         as logical   no-undo .
define variable choice as integer no-undo .

do
on error undo, return error
:
  case {2}:
    when {&table_dis-gds-rule}
    then do:
      run discfgru-check  in this-procedure (
                                               input {&table_dis-gds-rule}
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when {&table_dis-dc-rule} then do:
      run discfgru-check  in this-procedure (
                                               input {&table_dis-dc-rule}
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    when {&table_dis-cp-rule} then do:
      run discfgru-check  in this-procedure (
                                               input {&table_dis-cp-rule}
                                              ,input p-templ-rl-root
                                              ,input p-time-templ-rl-root
                                              ,input p-pos-type
                                              ,output v-discnt-role) no-error.
    end.
    otherwise do:
      undo, return error .
    end.
  end case.
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  if p-mode = "change":U
  then do:
    if p-rec <> ? then do:
      find first buf_temp-disc no-lock where
            recid(buf_temp-disc) = p-rec
        no-error .
    end.
    else do:
      find first buf_temp-disc no-lock where
                buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.nonunique  = p-nonunique
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
        no-error .
    end.
    if avail buf_temp-disc then do:
      assign
      v-rule-num =  buf_temp-disc.rule-num
      v-nonunique = buf_temp-disc.nonunique
      v-templ-rl-root = buf_temp-disc.templ-rl-root
      v-time-templ-rl-root = buf_temp-disc.time-templ-rl-root
      .
    end.
  end.
  CASE {2}:
&if "{2}" = "{&table_dis-gds-rule}" &then
    when {&table_dis-gds-rule} then do:
      if p-0mode = {&deletion} then do:
      run gbl/d-askw.w (   input "Вопрос"
                          ,input "Вы хотите удалить скидки на товарах"
                          ,input "|"
                          ,input "Конкретная|Все ТАКИЕ|Отмена"
                          ,input "по одному КОНКРЕТНОМУ правилу|СКИДКИ НА ТОВАР ЭТОГО ТИПА ПО ЭТОМУ ШАБЛОНУ И ТИПУ РАСПИСАНИЯ|Ничего не делать"
                          ,input 1
                          ,input 3
                          ,output choice).
    end.
    else do:
      choice = 1.
    end.
    if choice = 3
    then do:
      undo, return "not-set".
    end.
    if choice = 2 then do:
       v-rule-num = ?.
       v-setted = yes.
     end.
     else do:
      run disgdsru-edit in this-procedure (
                                   input {&update}
                                  ,input 0
                                  ,input p-obj-type
                                  ,input p-obj-code
                                  ,INPUT p-pos-type
                                  ,input p-discnt-role
                                  ,input p-templ-rl-root
                                  ,input p-time-templ-rl-root
                                  ,input p-cfg-nonunique
                                  ,input 1 /*p-check*/
                                  ,input-output v-rule-num
                                  ,input-output v-nonunique
                                  ,output v-setted ) no-error.
      if error-status :error then do:
&scop dis-gds-rule-code p-discnt-role
        undo, return error substitute("Ошибка при получения значения скидки товара на объекте:&1" +
                                      "место использ. &2 тип скидки &3"
                                      , {&new-line}
                                      , p-pos-type
                                      , {&dis-gds-rule-name}).
      end.
    end.
    end.
&endif
&if "{2}" = "{&table_dis-dc-rule}" &then
    when {&table_dis-dc-rule} then do:
      run disdcrul-edit in this-procedure (
                                   input {&update}
                                  ,input '':U
                                  ,input p-host-code
                                  ,input p-obj-type
                                  ,input p-obj-code
                                  ,INPUT p-pos-type
                                  ,input p-discnt-role
                                  ,input p-templ-rl-root
                                  ,input p-time-templ-rl-root
                                  ,input p-cfg-nonunique
                                  ,input 1 /*p-check*/
                                  ,input-output v-rule-num
                                  ,input-output v-nonunique
                                  ,output v-setted ) no-error.
      if error-status :error then do:
&scop dis-dc-rule-code p-discnt-role
        undo, return error substitute("Ошибка при получения значения скидки по отдельной ДК:&1" +
                                      "место использ. &2 тип скидки &3"
                                      , {&new-line}
                                      , p-pos-type
                                      , {&dis-dc-rule-name}).
      end.
    end.
&endif
&if "{2}" = "{&table_dis-cp-rule}" &then
    when {&table_dis-cp-rule} then do:
      if p-0mode = {&deletion} then do:
        run gbl/d-askw.w (   input "Вопрос"
                            ,input "Вы хотите удалить скидки"
                            ,input "|"
                            ,input "Конкретная|Все ТАКИЕ|Отмена"
                            ,input "по одному КОНКРЕТНОМУ правилу|СКИДКИ НА ПЛАТЕЖ ЭТОГО ТИПА ПО ЭТОМУ ШАБЛОНУ|Ничего не делать"
                            ,input 1
                            ,input 3
                            ,output choice).
    end.
    else do:
      choice = 1.
    end.
    if choice = 3
    then do:
      undo, return "not-set".
    end.
    if choice = 2 then do:
       v-rule-num = ?.
       v-setted = yes.
     end.
     else do:
      run discpru-edit in this-procedure (
                                       input {&update}
                                      ,input 0 /*p-cdpay-code*/
                                      ,input 0 /*p-curr-code*/
                                      ,input p-host-code
                                      ,input p-obj-type
                                      ,input p-obj-code
                                      ,INPUT p-pos-type
                                      ,input p-discnt-role
                                      ,input p-templ-rl-root
                                      ,input p-time-templ-rl-root
                                      ,input p-cfg-nonunique
                                      ,input 1 /*p-check*/
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
        if error-status :error then do:
&scop dis-cp-rule-code p-discnt-role
        undo, return error substitute("Ошибка при получения значения скидки по платежу:&1" +
                                      "место использ. &2 тип скидки &3"
                                      , {&new-line}
                                      , p-pos-type
                                      , {&dis-cp-rule-name}).
        end.
      end.
    end.
&endif
  END CASE.
  if v-setted = no then do:
    return "not-set":U.
  end.
  p-rule-num = v-rule-num.
  p-nonunique = v-nonunique.
end. /*doe*/

end procedure.


procedure temp-dsc-write :

  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-pos-type as character  no-undo .
    define input parameter p-templ-rl-root as integer  no-undo .
    define input parameter p-time-templ-rl-root as integer  no-undo .
    define input parameter p-discnt-role as character  no-undo .
    define input parameter p-cfg-nonunique as character no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-rule-num  as integer no-undo .
    define input parameter p-action   like temp-disc.action no-undo .
    define input-output parameter p-rec as recid no-undo .
    define buffer buf_temp-disc for temp-disc .
    define variable v-discnt-role as character no-undo .
    define variable varhost-code like ub.clients.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .
    define var loc#log as logical no-undo.
    define variable loc-action as logical no-undo.
    define variable v-nonunique as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule.

    case {2}:
      when {&table_dis-gds-rule}
      then do:
        run discfgru-check  in this-procedure (
                                                input {&table_dis-gds-rule}
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when {&table_dis-dc-rule}
      then do:
        run discfgru-check  in this-procedure (
                                                input {&table_dis-dc-rule}
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when {&table_dis-cp-rule}
      then do:
        run discfgru-check  in this-procedure (
                                                input {&table_dis-cp-rule}
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-cfg-nonunique <> '':U
    and p-rule-num <> 0
    and p-rule-num <> ?
    then do:
      find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
      if not available buf_dis-rule then do:
        undo, return error substitute("Не найдено правило скидок &1", p-rule-num).
      end.
      assign
      v-nonunique = (if p-cfg-nonunique = '':U
                    then '':U
                    else (if p-cfg-nonunique begins "@"
                          then left-trim(p-cfg-nonunique, "@")
                          else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value)
                          ))
      .
    end.
    if p-rec <> ? then do:
      find first buf_temp-disc exclusive-lock where
                recid(buf_temp-disc) = p-rec no-error .
    end.
    else do:
      find first buf_temp-disc exclusive-lock where
                buf_temp-disc.pos-type = p-pos-type
              and buf_temp-disc.discnt-role = p-discnt-role
              and buf_temp-disc.host-code = p-host-code
              and buf_temp-disc.obj-type = p-obj-type
              and buf_temp-disc.obj-code = p-obj-code
              and buf_temp-disc.nonunique = v-nonunique
              no-error .
    end.
    if not available buf_temp-disc then do:
      create buf_temp-disc .
      assign
      buf_temp-disc.host-code = p-host-code
      buf_temp-disc.obj-type = p-obj-type
      buf_temp-disc.obj-code = p-obj-code
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.action = p-action
      buf_temp-disc.pos-type = p-pos-type
      buf_temp-disc.discnt-role = p-discnt-role
      buf_temp-disc.cfg-nonunique = p-cfg-nonunique
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error
      .
    end.
    ELSE do:
      if p-add then do:
         message
         substitute("Такая скидка уже добавлена&1"
                    ,{&new-line}
                )
         view-as alert-box error .
        undo, return error "not-set" .
      end.
      ASSIGN
      buf_temp-disc.rule-num = p-rule-num
      buf_temp-disc.nonunique = v-nonunique
      buf_temp-disc.time-templ-rl-root = p-time-templ-rl-root
      buf_temp-disc.templ-rl-root = p-templ-rl-root
      p-rec = recid(buf_temp-disc)
      no-error.
    end.
  end.

end procedure.


procedure temp-dsc-exist :
define input parameter p-pos-type as character  no-undo .
define input parameter p-templ-rl-root as integer  no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-discnt-role as character  no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define output parameter p-exist    as logical no-undo .
define output parameter p-action as logical no-undo .

define variable v-discnt-role as character no-undo .
define buffer buf_temp-disc for temp-disc .


  do
  on error undo, return error
  :

    case {2}:
      when {&table_dis-gds-rule} then do:
        run discfgru-check  in this-procedure (
                                                input {&table_dis-gds-rule}
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      when {&table_dis-dc-rule} then do:
        run discfgru-check  in this-procedure (
                                                input {&table_dis-dc-rule}
                                               ,input p-templ-rl-root
                                               ,input p-time-templ-rl-root
                                               ,input p-pos-type
                                               ,output v-discnt-role) no-error.
      end.
      otherwise do:
        undo, return error .
      end.
    end case.

    if error-status :error
    then do:
      undo, return error return-value .
    end.

    find first buf_temp-disc no-lock where
               buf_temp-disc.pos-type = p-pos-type
            and buf_temp-disc.discnt-role = p-discnt-role
            and buf_temp-disc.host-code = p-host-code
            and buf_temp-disc.obj-type = p-obj-type
            and buf_temp-disc.obj-code = p-obj-code
            and buf_temp-disc.nonunique = p-nonunique no-error .
    if available buf_temp-disc then do:
      P-EXIST = YES.
      p-action = buf_temp-disc.action.
    end.
  end.

end procedure.

procedure temp-dsc-delete :
define input parameter p-pos-type as character  no-undo .
define input parameter p-discnt-role as character no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-host-code  as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-action as logical no-undo .
define output parameter p-deleted  as logical no-undo .

define buffer buf_temp-disc for temp-disc .

  do
  on error undo, return error :

    case {2}:
      when {&table_dis-gds-rule}
      then do:
        error-status:error = no.
      end.
      when {&table_dis-dc-rule}
      then do:
        error-status:error = no.
      end.
      when {&table_dis-cp-rule}
      then do:
        error-status:error = no.
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.

    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-disc exclusive-lock where
               buf_temp-disc.pos-type = p-pos-type
           and buf_temp-disc.discnt-role = p-discnt-role
           and buf_temp-disc.host-code = p-host-code
           and buf_temp-disc.obj-type = p-obj-type
           and buf_temp-disc.obj-code = p-obj-code
           and buf_temp-disc.nonunique = p-nonunique
           and buf_temp-disc.action = p-action
           no-error .
    if not available buf_temp-disc then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-disc.
       P-DELETED = YES.
    END.
  end.
end procedure.


/* $Workfile$ e n d */