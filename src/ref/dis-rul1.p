block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-rul1.p $
$Archive: ref/dis-rul1.p $

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/04
Author: Bakhtadze Natalya
Creation date: 09/02/04

Сохранение изменений в правилах скидок

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter  p-rule-num          like ub.dis-rule.rule-num          no-undo .
define input parameter  p-pos-type          as character no-undo .
define input parameter  p-rl-root           like ub.dis-rule.rl-root           no-undo .
define input parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
define input parameter  p-des               like ub.dis-rule.des               no-undo .
define input parameter  p-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define input parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define input parameter  p-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define input parameter  p-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define input parameter  p-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define input parameter  p-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define input parameter  p-charkey_three     like ub.dis-rule.charkey_three     no-undo .
define input parameter  p-deckey_one        like ub.dis-rule.deckey_one       no-undo .
define input parameter  p-deckey_two        like ub.dis-rule.deckey_two       no-undo .
define input parameter  p-deckey_three      like ub.dis-rule.deckey_three     no-undo .
define input parameter  p-key#_one          like ub.dis-rule.key#_one          no-undo .
define input parameter  p-key#_two          like ub.dis-rule.key#_two          no-undo .
define input parameter  p-key#_three        like ub.dis-rule.key#_three        no-undo .
define input parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
define input parameter  p-time-templ-rl-root like ub.dis-rule.time-templ-rl-root  no-undo .
define input parameter  p-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define input parameter  p-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define input parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
define input parameter  p-host-code         like ub.dis-rule.host-code         no-undo .
DEFINE INPUT PARAMETER  p-obj-type          LIKE ub.dis-rule.obj-type          NO-UNDO.
DEFINE INPUT PARAMETER  p-obj-code          LIKE ub.dis-rule.obj-code          NO-UNDO.
DEFINE INPUT PARAMETER  p-discnt-value      LIKE ub.dis-rule.discnt-value      NO-UNDO.

define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-term_dis-rule.

define input-output parameter p-recid as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-silent                       as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в правилах скидок".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/disrules.i "work" }
{ trg/new-bcod.i }
{ ref/gtregion.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-hostcode like ub.sysconf.host-code no-undo .
define variable  v-new-rule-num      like ub.dis-rule.rule-num          no-undo .
define variable  v-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
/*
define variable  v-dis-kat           like ub.dis-rule.dis-kat           no-undo .*/
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
/*
define variable  v-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
*/
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo . /* виден в броусе */
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo . /* еще чего - нибудь */
define variable  v-dub               as logical no-undo .
define variable  v-region            as character no-undo .
define variable  v-entry             as character no-undo .
define variable ii as integer no-undo .
define variable iib as integer no-undo extent 14.
define variable jj as integer no-undo .
define variable v-curr-field as character no-undo .
/*extent 8 эжто с запасом используется пока 10*/
define variable v-tree-field as logical no-undo extent 14.
define variable v-num-rec as integer no-undo extent 14.
define variable v-num-rec-sign as character no-undo extent 14.
define variable v-uniq-field as logical no-undo extent 14.
define variable v-down-limit as character no-undo extent 14.
define variable v-up-limit as character no-undo extent 14.
define variable v-dv-up-limit as character no-undo .
define variable v-dv-down-limit as character no-undo .
define variable v-des-len-up-limit as character no-undo .
define variable v-dis-gds-rule as integer no-undo init ?.
define variable v-dis-thbj-rule as integer no-undo init ?.
define variable v-dis-dc-rule as integer no-undo init ?.
define variable v-dis-dct-rule as integer no-undo init ?.
define variable v-dis-cp-rule as integer no-undo init ?.
define variable v-dis-gds-rule-log as logical no-undo.
define variable v-dis-thbj-rule-log as logical no-undo.
define variable v-dis-dc-rule-log as logical no-undo.
define variable v-dis-dct-rule-log as logical no-undo.
define variable v-dis-cp-rule-log as logical no-undo.
define variable v-gds-grp-log as logical   no-undo .
define variable v-dis-some-rule-log as logical   no-undo .
define variable v-field-label as character no-undo .

define variable v-found as logical no-undo .
define variable v-sts-mode as logical no-undo .
define variable v-ret-mess as character no-undo .
define variable v-dop as character no-undo .
define variable v-value-option-list as character no-undo .
define variable v-run-cn as logical no-undo .
define variable v-discnt-role as character no-undo .
define variable v-nonunique as character no-undo .
define variable v-nonunique2 as character no-undo .
define variable v-term-time-templ-rl-root as integer no-undo .

define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_sysconf  for ub.sysconf.
DEFINE BUFFER buf_clients-obj FOR ub.clients.
define buffer buf_db for ub.db .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer dub_dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer dub_tt-dis-rule  for tt0-term_dis-rule.
define temp-table temp-dis-rule no-undo like ub.dis-rule.
define buffer check_dis-rule for temp-dis-rule.
define buffer buf_price-list-type for ub.price-list-type.

&scop check-fields  "dis-kat,doc-qnty,tot-sum,time-rule-num,discnt-value,charkey_one,charkey_two,charkey_three,~
deckey_one,deckey_two,deckey_three,key#_one,key#_two,key#_three"
&scop dis-kat 1
&scop doc-qnty 2
&scop tot-sum 3
&scop time-rule-num 4
&scop discnt-value 5
&scop charkey_one 6
&scop charkey_two 7
&scop charkey_three 8
&scop deckey_one 9
&scop deckey_two 10
&scop deckey_three 11
&scop key#_one 12
&scop key#_two 13
&scop key_#three 14



if p-mode <> {&add-def}
AND p-mode <> {&update}
AND p-mode <> ({&update} + {&delim-par} + 'sts':U)
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
if p-mode = ({&update} + {&delim-par} + 'sts':U) then do:
  assign
  v-sts-mode = yes
  p-mode = {&update}
  .
end.

if p-host-code <> 0 then do:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code no-error .
  if not available buf_sysconf then do:
    run err-mess in this-procedure ( substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "host-code":U).
  end.
end.

if p-obj-type <> "":U
or p-obj-code <> 0 then do:
  find first buf_clients-obj no-lock where
            buf_clients-obj.obj-type = p-obj-type
        AND buf_clients-obj.obj-code = p-obj-code no-error .
  if not available buf_clients-obj
  or (p-obj-type <> {&shop} and p-obj-type <> {&stock})
  then do:
    run err-mess in this-procedure ( substitute("Не найден объект &1&2", p-obj-type, p-obj-code), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
  if buf_clients-obj.host-code <> p-host-code then do:
    run err-mess in this-procedure ( substitute("Объект &1&2 принадлежит фирме &3, а правило скидки принадлежит фирме &4"
                  , p-obj-type, p-obj-code, buf_clients-obj.host-code , p-host-code), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
end.

if g#db-num <> 0
and (p-host-code = 0
or   p-obj-type = "":U
or   p-obj-code = 0)
then do:
  run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в УБД:&1" +
                           "номер текущей БД &2"
                           , {&new-line}
                           , g#db-num), output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "host-code":U).
end.


run dr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-discnt-type
    ,output v-subject-type
    ,output v-value-type
    ,output v-level-1
    ,output v-level-2
    ,output v-global
    ,output v-host
    ,output v-object
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
if error-status:error then do:
    run err-mess in this-procedure ( substitute("Неверный номер шаблона для скидки: &1&2&3&2&4"
                               , p-templ-rl-root
                               , {&new-line}
                               , error-status:get-message(1)
                               ,return-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
end.

run disrules-fill-properties in this-procedure ( input p-templ-rl-root).

for each buf_dis-cfg-rule no-lock where
        buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
    and buf_dis-cfg-rule.table-name > '':U
        :
  if buf_dis-cfg-rule.table-name = {&table_dis-gds-rule} then do:
    v-dis-gds-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-thbj-rule} then do:
    v-dis-thbj-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-dc-rule} then do:
    v-dis-dc-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-dct-rule} then do:
    v-dis-dct-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-cp-rule} then do:
    v-dis-cp-rule-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-grp-rule}
  and buf_dis-cfg-rule.self-nonunique = {&table_gds-grp}
  then do:
    v-gds-grp-log = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-some-rule}
  then do:
    v-dis-some-rule-log = yes.
  end.

end.

/*разберем свойства  */

do jj = 1 to num-entries({&check-fields}):
  assign
  v-curr-field = entry(jj, {&check-fields})
  .
  find first buf_temp-drt-prop where
            buf_temp-drt-prop.upper-prop-code = '':U
        and buf_temp-drt-prop.prop-code = v-curr-field + "=uniq"
        and logical(buf_temp-drt-prop.property-value) = yes
          no-error .
  if available buf_temp-drt-prop then do:
    assign
    v-uniq-field[jj] = yes
    .
  end. /*if buf_temp-drt-prop.prop-code =  */
end. /*do jj*/

if p-pos-type = "" then do:
  define variable dflt-cd as character no-undo .
  { gbl/dflt-cd.i p-obj-type p-obj-code p-pos-type }
end.
for each buf_temp-drt-prop where
        buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
    and buf_temp-drt-prop.upper-prop-code = p-pos-type:
  case buf_temp-drt-prop.prop-code:
    when "discnt-value<=" then do:
      v-dv-up-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value>=" then do:
      v-dv-down-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value=" then do:
      v-dv-up-limit = buf_temp-drt-prop.property-value.
      v-dv-down-limit = buf_temp-drt-prop.property-value.
    end.
    when "des-len<=" then do:
      v-des-len-up-limit = buf_temp-drt-prop.property-value.
    end.
    when "discnt-value=radio" then do:
      v-dop = buf_temp-drt-prop.property-value.
      do ii = 1 to num-entries(v-dop):
        if ii modulo 2 = 0 then
        assign
        v-value-option-list = v-value-option-list + {&comma-char} + entry(ii, v-dop)
        .
      end.
      v-value-option-list = trim(v-value-option-list).
    end.
    otherwise do:
      do jj = 1 to num-entries({&check-fields}):
        assign
        v-curr-field = entry(jj, {&check-fields})
        .
        if buf_temp-drt-prop.prop-code = v-curr-field + "=uniq" then do:
          assign
          v-uniq-field[jj] = yes
          .
        end. /*if buf_temp-drt-prop.prop-code =  */
        if buf_temp-drt-prop.prop-code =  (v-curr-field + ">=":U) then do:
          assign
          v-down-limit[jj] = buf_temp-drt-prop.property-value
        /*  trim(v-entry, v-curr-field + ">=":U) */
          .
        end.
        if buf_temp-drt-prop.prop-code = (v-curr-field + "<=":U) then do:
          assign
          v-up-limit[jj] = buf_temp-drt-prop.property-value
          /* trim(v-entry, v-curr-field + "<=":U)  */
          .
        end.
      end. /*do jj*/
    end.
  end case.
end. /*for each buf_temp-drt-prop*/


/*
if p-mode = {&update}
and not v-sts-mode
and (p-host-code = 0
or   p-obj-type = "":U
or   p-obj-code = 0)
then do:
  /*проверим что есть УБД*/
  find first buf_db no-lock where
            buf_db.db-num > 0 no-error.
  if available buf_db then do:
    run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в системе с УБД"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.
end.
*/

if p-obj-code > 0 then do:
  { gbl/objdbnum.i p-obj-type p-obj-code v-db-num }
  if (v-db-num <> g#db-num and g#db-num > 0) then do:
    run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ на объекте в чужой УБД:&1" +
                            "номер текущей БД &2, номер БД для &3&34 &5"
                            , {&new-line}
                            , g#db-num
                            , p-obj-type
                            , p-obj-code
                            , v-db-num
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
  if (p-mode = {&update} and v-db-num <> g#db-num and g#db-num > 0) then do:
    run err-mess in this-procedure ( substitute("Нельзя изменять запись ПРАВИЛА СКИДКИ на объекте в чужой БД:&1" +
                            "номер текущей БД &2, номер БД для &3&4: &5"
                            , {&new-line}
                            , g#db-num
                            , p-obj-type
                            , p-obj-code
                            , v-db-num
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "obj-code":U).
  end.
end.
if p-mode = {&update} then do:
  /*если система без УБД или объект текущей БД проверим что нет таких dis-thbj-rule*/
  run waitfram-show in this-procedure ( "Ждите .. Проводится проверка возможности изменения правила" ).
  if v-dis-thbj-rule-log then do:
    _dis-thbj-rule:
    for each buf_dis-thbj-rule no-lock where
          buf_dis-thbj-rule.rule-num = p-rule-num:
      /*сюда свалимся для тех dis-cfg-rule которые через link-prop = 0 или link-prop = 3*/
      assign
      v-found = yes
      .
      leave _dis-thbj-rule.
    end.
    define variable v-can as logical   no-undo .
    if v-found
    then do:
      find first buf_temp-drt-prop no-lock where
      buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "can-update"
      and buf_temp-drt-prop.prop-code = "can" no-error.
      if available buf_temp-drt-prop
      and integer(buf_temp-drt-prop.property-value) > 0 then do:
        if integer(buf_temp-drt-prop.property-value) >= 2 then do:
          v-found = no.
        end.
        if integer(buf_temp-drt-prop.property-value) < 2 then do:
          find first buf_temp-drt-prop no-lock where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
          and buf_temp-drt-prop.upper-prop-code = "can-update"
          and buf_temp-drt-prop.prop-code = "can-message" no-error.
          if available buf_temp-drt-prop then do:
            message
            buf_temp-drt-prop.property-value
            view-as alert-box question buttons yes-no update v-can.
            if v-can then do:
              v-found = no.
            end.
          end.
        end.
      end. /*if available buf_temp-drt-prop*/
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана ОБЩАЯ СКИДКА  НА ОБЪЕКТЕ: &2&3"
                              , {&new-line}
                              , buf_dis-thbj-rule.obj-type
                              , buf_dis-thbj-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-dct-rule-log then do:
    _dis-dct-rule:
    for each buf_dis-dct-rule no-lock where
          buf_dis-dct-rule.rule-num = p-rule-num:
      assign
      v-found = yes
      .
      leave _dis-dct-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-dct-rule-code buf_dis-dct-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана СКИДКА по типу ДК: тип ДК &2 эмитент &3 тип скидки &4 фирма &5 объект &6&7"
                              , {&new-line}
                              , buf_dis-dct-rule.type
                              , buf_dis-dct-rule.emitent-host-code
                              , {&dis-dct-rule-name}
                              , buf_dis-dct-rule.host-code
                              , buf_dis-dct-rule.obj-type
                              , buf_dis-dct-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end. /*if v-dis-dct-tule <> '':U then do:*/

  if v-dis-cp-rule-log then do:
    _dis-cp-rule:
    for each buf_dis-cp-rule no-lock where
          buf_dis-cp-rule.rule-num = p-rule-num:
      assign
      v-found = yes
      .
      leave _dis-cp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-cp-rule-code buf_dis-cp-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять запись ПРАВИЛА СКИДКИ&1" +
                              "с ней связана СКИДКА ТИПА КАССОВОГО ПЛАТЕЖА: ПЛАТЕЖ &2 ВАЛЮТА &3 тип скидки &4 фирма &5 объект &6&7"
                              , {&new-line}
                              , buf_dis-cp-rule.cdpay-code
                              , buf_dis-cp-rule.curr-code
                              , {&dis-cp-rule-name}
                              , buf_dis-cp-rule.host-code
                              , buf_dis-cp-rule.obj-type
                              , buf_dis-cp-rule.obj-code
                              )
                              , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end. /*if v-dis-cp-rule <> '':U then do:*/

  run waitfram-hide in this-procedure .
end.


  &scop discnt-type-code  string(p-discnt-type)

  if {&discnt-type-name} = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип скидки: &1", p-discnt-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "discnt-type":U).

  end.

  &scop discnt-target-code string(p-subject-type)

  if {&discnt-target-name} = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип объекта приложения скидки: &1", p-subject-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "subject-type":U).
  end.

  &scop discnt-v-code string(p-value-type)

  if {&discnt-v-name} = "":U then do:
    run err-mess in this-procedure ( substitute("Неверный тип значения скидки: &1", p-value-type), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "value-type":U).
  end.

  find first buf_dis-rule no-lock where
          buf_dis-rule.rule-num = p-upper-rule-num no-error .
  if not available buf_dis-rule then do:
    run err-mess in this-procedure ( substitute("Неверный номер шаблона правила-скидки: &1", p-upper-rule-num), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "upper-rule-num":U).
  end.

  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root no-error.
  if not available buf_dis-cfg-rule then do:
    run err-mess in this-procedure ( substitute("Неверный тип шаблона расписания &1 для ПРАВИЛА СКИДКИ", p-time-templ-rl-root), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.

  if p-mode = {&add-def} then do:
    find first buf_dis-cfg-rule no-lock where
            buF_dis-cfg-rule.templ-rl-root = p-templ-rl-root
          and buF_dis-cfg-rule.pos-type = p-pos-type
          no-error .
    if not available buf_Dis-cfg-rule
    or p-pos-type = '':U
    then do:
      run err-mess in this-procedure ( substitute("Неприменимо правило скидки такого типа &1 для типа касс &2"
                                                  , v-des
                                                  , p-pos-type), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.

  if p-time-rule-num <> 0 then do:
    find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = p-time-rule-num no-error .
    if not available buf_dis-time-rule then do:
      run err-mess in this-procedure ( substitute("Неверный номер расписания для скидки: &1", p-time-rule-num), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "time-rule-num":U).
    end.
  end.
  else do:
    v-found = no.
    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and (if p-pos-type = ? then yes else buF_dis-cfg-rule.pos-type = p-pos-type):
       if buf_dis-cfg-rule.time-templ-rl-root <= 0 then do:
         v-found = yes.
       end.
    end.
    if not v-found
    and lookup("time-rule-num", v-level-1) > 0
    then do:
      run err-mess in this-procedure ( substitute("Не задано расписание для скидки"), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "time-rule-num":U).
    end.
  end.


  if p-rule-num <=  {&max-num-dr-template} then do:
      run err-mess in this-procedure ( substitute("Неверный номер правила для скидки: &1, значения меньшие &2 зарезервированы", p-rule-num, {&max-num-dr-template}), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.

  assign
  v-rule-num = p-upper-rule-num
  .
if (lookup("time-rule-num", v-level-1) = 0
    and
    lookup("time-rule-num", v-level-2) = 0
    and
    0 <> p-time-rule-num) then do:
  p-time-rule-num = 0.
end.
if lookup("dis-kat", v-level-1) = 0
    and
    lookup("dis-kat", v-level-2) = 0 then do:
  p-dis-kat = -1.
end.
if lookup("doc-qnty", v-level-1) = 0
    and
    lookup("doc-qnty", v-level-2) = 0 then do:
  p-doc-qnty = -1.
end.
if lookup("tot-sum", v-level-1) = 0
    and
    lookup("tot-sum", v-level-2) = 0 then do:
  p-tot-sum = -1.
end.
if lookup("key#_one", v-level-1) = 0
    and
    lookup("key#_one", v-level-2) = 0 then do:
  p-key#_one = ?.
end.
if lookup("key#_two", v-level-1) = 0
    and
    lookup("key#_two", v-level-2) = 0 then do:
  p-key#_two = ?.
end.
if lookup("key#_three", v-level-1) = 0
    and
    lookup("key#_three", v-level-2) = 0 then do:
  p-key#_three = ?.
end.
if lookup("deckey_one", v-level-1) = 0
    and
    lookup("deckey_one", v-level-2) = 0 then do:
  p-deckey_one = ?.
end.
if lookup("deckey_two", v-level-1) = 0
    and
    lookup("deckey_two", v-level-2) = 0 then do:
  p-deckey_two = ?.
end.
if lookup("deckey_three", v-level-1) = 0
    and
    lookup("deckey_three", v-level-2) = 0 then do:
  p-deckey_three = ?.
end.
if lookup("charkey_one", v-level-1) = 0
    and
    lookup("charkey_one", v-level-2) = 0 then do:
  p-charkey_one = '':U.
end.
if lookup("charkey_two", v-level-1) = 0
    and
    lookup("charkey_two", v-level-2) = 0 then do:
  p-charkey_two = '':U.
end.
if lookup("charkey_three", v-level-1) = 0
    and
    lookup("charkey_three", v-level-2) = 0 then do:
  p-charkey_three = '':U.
end.
if (v-discnt-type <> p-discnt-type)
or v-subject-type <> p-subject-type
/*or (v-time-rule-num = - 1 and v-time-rule-num <> p-time-rule-num)*/
or (v-value-type <> p-value-type )
or (v-global = 0 and p-host-code = 0)
or (v-host  = 0 and p-host-code <> 0 and p-obj-code = 0)
or (v-object = 0 and p-obj-code <> 0)
then do:
    run err-mess in this-procedure ( substitute("Несоответствуют друг другу параметры шаблона &1 и задаваемые параметры правила скидки"
                                    , p-templ-rl-root), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "templ-rl-root":U).
end.
if v-output-display = no then do:
  run err-mess in this-procedure ( substitute("Нельзя добавить правило скидки по неиспользуемому шаблону: &1", p-templ-rl-root), output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "templ-rl-root":U).
end.

if v-value-type = integer({&discnt-v-pcnt}) then do:
  if p-discnt-value > 0
  and p-discnt-value > 100 then do:
    run err-mess in this-procedure ( substitute("Значение процентной скидки не может быть больше 100%: &1", p-discnt-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
end.
if v-value-type = integer({&discnt-v-FP}) then do:
  if p-discnt-value < 0
  then do:
    run err-mess in this-procedure ( substitute("Значение ФЦ не может быть < 0: &1", p-discnt-value), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
end.
if v-value-type = integer({&discnt-v-pdf-pcnt})
or v-value-type = integer({&discnt-v-pdf-abs})
or v-value-type = integer({&discnt-v-pdf-FP}) then do:
  find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = integer(entry(1, p-charkey_one, "-"))
        and buf_price-list-type.plt-db-num = integer(entry(2, p-charkey_one, "-")) no-error.
  if not available buf_price-list-type
  or buf_price-list-type.stts <> integer({&pdf-new}) then do:
    run err-mess in this-procedure ( substitute("ТПЛ &1 (БД &2) не существует или удален"
                                              ,entry(1, p-charkey_one, "-")
                                              ,entry(2, p-charkey_one, "-")
                                              ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "charkey_one":U).
  end.
end.

if v-value-type = integer({&discnt-v-radio-integer}) then do:
  if lookup(string(p-discnt-value), v-value-option-list) = 0 then do:
    run err-mess in this-procedure ( substitute("Значение может принимать только значения &1", v-value-option-list), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "discnt-value":U).
  end.
end.


create check_dis-rule.
assign
check_dis-rule.dis-kat = p-dis-kat
check_dis-rule.doc-qnty = p-doc-qnty
check_dis-rule.tot-sum = p-tot-sum
check_dis-rule.discnt-value = p-discnt-value
check_dis-rule.charkey_one = p-charkey_one
check_dis-rule.charkey_two = p-charkey_two
check_dis-rule.charkey_three = p-charkey_three
check_dis-rule.deckey_one = p-deckey_one
check_dis-rule.deckey_two = p-deckey_two
check_dis-rule.deckey_three = p-deckey_three
check_dis-rule.key#_one = p-key#_one
check_dis-rule.key#_two = p-key#_two
check_dis-rule.key#_three = p-key#_three
.

do jj = 1 to num-entries({&check-fields}):
  assign
  v-curr-field = entry(jj, {&check-fields})
  .

  if v-down-limit[jj] <> "":u then do:

    if decimal(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)  < decimal(v-down-limit[jj]) then do:
      /*получим значением лейбл*/
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input v-curr-field
                                                       , output v-field-label).
      run err-mess in this-procedure ( substitute("Значение &1 не может быть меньше &2"
                                                , v-field-label
                                                , v-down-limit[jj]), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U ).
    end.
    v-down-limit[jj] = "":u.
  end.
  if v-up-limit[jj] <> "":u then do:


    if decimal(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)  > decimal(v-up-limit[jj]) then do:
       /*получим значением лейбл*/
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input v-curr-field
                                                       , output v-field-label).
      run err-mess in this-procedure ( substitute("Значение &1 не может быть больше &2"
                  , v-field-label
                  , v-up-limit[jj]), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    v-up-limit[jj] = "":u.
  end.
end. /*do jj = 1 to num-entries({&check-fields}):*/

if v-dis-thbj-rule-log then do:
  for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
      and buf_dis-cfg-rule.pos-type = p-pos-type
      and buf_dis-cfg-rule.table-name = {&table_dis-thbj-rule}
  :
    if  buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}) then do:
      assign
      v-discnt-role = buf_dis-cfg-rule.discnt-role.
      do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
        assign
        v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
        .
        assign
        v-nonunique = v-nonunique + (if v-nonunique = '':u then '':U else {&delim-par}) +
                      string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value).

      end.
      find first buf_dis-thbj-rule no-lock where
            buF_dis-thbj-rule.host-code = p-host-code
        and buF_dis-thbj-rule.obj-type = p-obj-type
        and buF_dis-thbj-rule.obj-code = p-obj-code
        and buF_dis-thbj-rule.pos-type = p-pos-type
        and buF_dis-thbj-rule.discnt-role = v-discnt-role
        and buf_dis-thbj-rule.nonunique = v-nonunique no-error .
      if available buf_dis-thbj-rule
      and buf_dis-thbj-rule.rule-num <> p-rule-num
      then  do:
        run err-mess in this-procedure (
        substitute("Уже есть правило скидки &1 с той же областью действия &2:&3" +
                  "(правило &4 с типом &5)&3" +
                  "для такой скидки можно определить только одно такое правило "
                   , v-des
                   , v-region
                   ,{&new-line}
                   ,buf_dis-thbj-rule.rule-num
                   ,buf_Dis-thbj-rule.templ-rl-root
                   )
                 , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U).
      end.
    end.
  end.
end.
assign
v-region = gtregion(p-host-code, p-obj-type, p-obj-code, no)
.

_dub:
for each dub_dis-rule no-lock where
        dub_dis-rule.upper-rule-num = p-upper-rule-num
    AND dub_dis-rule.host-code      = p-host-code
    AND dub_dis-rule.obj-type       = p-obj-type
    AND dub_dis-rule.obj-code       = p-obj-code
    and dub_dis-rule.sts            = integer({&current-status-int})
    :
  if p-mode = {&update}
  and  dub_dis-rule.rule-num = p-rule-num then next.
  do jj = 1 to num-entries({&check-fields}):
    assign
    v-curr-field = entry(jj, {&check-fields})
    .

    if v-uniq-field[jj] then do:
      if buffer dub_dis-rule:buffer-field(v-curr-field):buffer-value = buffer check_dis-rule:buffer-field(v-curr-field):buffer-value then do:
        assign
        v-dub = yes
        .

        /*получим значением лейбл*/
        run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                        , input v-curr-field
                                                        , output v-field-label).
        run err-mess in this-procedure ( substitute("Уже есть правило скидки с той же областью действия &3"
                                                    , v-field-label
                                                    , string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value)
                                                    , v-region)
                                                    , output v-ret-mess).
        LEAVE _dub.
      end. /*if buffer dub_dis-rule:buf*/
    end. /*if v-uniq-field[jj] then do: */
  end. /*do jj = 1 to num-entries({&check-fields}):*/
end. /*for each dub_dis-rule no-lock where*/
if v-dub then do:
  undo, return error (if p-silent then v-ret-mess else "rule-num":U).
end.


if v-tree = '':U then do:
  if v-dv-up-limit <> '':U
  and p-discnt-value > decimal(v-dv-up-limit) then do:
      run err-mess in this-procedure ( substitute("Значение скидки не может быть больше &1"
                                                  , v-dv-up-limit)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
  end.
  if v-dv-down-limit <> '':U
  and p-discnt-value > decimal(v-dv-up-limit) then do:
      run err-mess in this-procedure ( substitute("Значение скидки не может быть меньше &1"
                                                  , v-dv-down-limit)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
  end.
end.
if v-des-len-up-limit <> '':U
and length(p-des) > integer(v-des-len-up-limit) then do:
  run err-mess in this-procedure ( substitute("Описание скидки не может быть длиннее &1 знаков"
                                              , v-des-len-up-limit)
                                  , output v-ret-mess).
  undo, return error (if p-silent then v-ret-mess else "":U) .
end.



if v-tree <> "":U then do:
  /*разберем v-tree*/
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
            and buf_temp-drt-prop.upper-prop-code = p-pos-type
            and buf_temp-drt-prop.prop-code begins v-curr-field:
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec==":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = "==":U
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec<=":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = "<=":U
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "-num-rec>=":U) then do:
            assign
            v-num-rec[jj] = integer(buf_temp-drt-prop.property-value)
            v-num-rec-sign[jj] = ">=":U
            .
          end.
          if buf_temp-drt-prop.prop-code = (v-curr-field + ">=":U) then do:
            assign
            v-down-limit[jj] = buf_temp-drt-prop.property-value
            .
          end.
          if buf_temp-drt-prop.prop-code =  (v-curr-field + "<=":U) then do:
            assign
            v-up-limit[jj] = buf_temp-drt-prop.property-value
            .
          end.
        end. /*for each buf_temp-drt-prop where*/
      end. /*if v-entry = v-curr-field */
    end. /*do jj*/
  end. /*do ii*/


define variable v-entry-entry as character no-undo .
define variable v-entry-record as character no-undo .
define variable v-entry-name as character no-undo .
define variable v-name-name as character no-undo .
define variable v-entry-list as character no-undo .
define variable nn as integer no-undo .


 _dub:
  for each tt0-term_dis-rule no-lock where
          tt0-term_dis-rule.upper-rule-num = (if p-mode = {&add-def} then p-templ-rl-root else p-rule-num):
    v-entry-record = '':U.
    v-entry-name = '':U.
    do nn = 1 to num-entries(v-tree):
      assign
      v-entry-entry = string(buffer tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value)
      .
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                       , input entry(nn, v-tree)
                                                       , output v-field-label).
      v-name-name = substitute("&1 = &2", v-field-label, buffer tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value).
      assign
      v-entry-record = v-entry-record +
                (if v-entry-record = '':U then "" else {&delim-par}) + v-entry-entry
      v-entry-name = v-entry-name +
                (if v-entry-name = '':U then "" else {&delim-par}) + v-name-name
                .
    end. /*    do nn = 1 to num-entries(v-tree):*/
    if lookup(v-entry-record, v-entry-list, {&delim-key}) > 0 then do:
      assign
      v-dub = yes
      .
      run err-mess in this-procedure (  substitute("Более одного подправила: &1", v-entry-name)
                                      , output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    v-entry-list = v-entry-list + (if v-entry-list = '':U then "" else {&delim-key}) + v-entry-record.
  end.

  for each tt0-term_dis-rule no-lock where
          tt0-term_dis-rule.upper-rule-num = (if p-mode = {&add-def} then p-templ-rl-root else p-rule-num):

    if tt0-term_dis-rule.value-type = integer({&discnt-v-pcnt}) then do:
      if tt0-term_dis-rule.discnt-value > 0
      and tt0-term_dis-rule.discnt-value > 100 then do:
        run err-mess in this-procedure ( substitute("Значение процентной скидки не может быть больше 100%: &1", tt0-term_dis-rule.discnt-value), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "rule-num":U).
      end.
    end.
    if tt0-term_dis-rule.value-type = integer({&discnt-v-FP}) then do:
      if tt0-term_dis-rule.discnt-value < 0
      then do:
        run err-mess in this-procedure ( substitute("Значение ФЦ не может быть < 0: &1", tt0-term_dis-rule.discnt-value), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "rule-num":U).
      end.
      if tt0-term_dis-rule.value-type = integer({&discnt-v-pdf-pcnt})
      or tt0-term_dis-rule.value-type = integer({&discnt-v-pdf-abs})
      or tt0-term_dis-rule.value-type = integer({&discnt-v-pdf-FP}) then do:
        find first buf_price-list-type no-lock where
                  buf_price-list-type.plt-id = integer(entry(1, tt0-term_dis-rule.charkey_one, "-"))
              and buf_price-list-type.plt-db-num = integer(entry(2, tt0-term_dis-rule.charkey_one, "-")) no-error.
        if not available buf_price-list-type
        or buf_price-list-type.stts <> integer({&pdf-new}) then do:
          run err-mess in this-procedure ( substitute("ТПЛ &1 (БД &2) не существует или удален"
                                                    ,entry(1, tt0-term_dis-rule.charkey_one, "-")
                                                    ,entry(2, tt0-term_dis-rule.charkey_one, "-")
                                                    ), output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U).
        end.
      end.

    end.

    if tt0-term_dis-rule.value-type = integer({&discnt-v-radio-integer}) then do:
      if lookup(string(tt0-term_dis-rule.discnt-value), v-value-option-list) = 0 then do:
        run err-mess in this-procedure ( substitute("Значение может принимать только значения &1", v-value-option-list), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "discnt-value":U).
      end.
    end.

    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.table-name > '':U
    on error undo, return error error-status:get-message(1) :
      if buf_dis-cfg-rule.projection = '':U then next.
      v-entry-name = '':U  .
       run check-projection in this-procedure ( buffer tt0-term_dis-rule
                                               ,input buf_Dis-cfg-rule.table-name
                                               ,input buf_dis-cfg-rule.projection
                                               ,output v-entry-name
                                               ) no-error.
       if error-status:error then do:
          run err-mess in this-procedure (  substitute("Неверные сслылки в правиле: &1", v-entry-name)
                                          , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
       end.
    end. /*for each buf_dis-cfg-rule no-lock where*/
    if v-dv-up-limit <> '':U
    and tt0-term_dis-rule.discnt-value > decimal(v-dv-up-limit) then do:
        run err-mess in this-procedure ( substitute("Значение скидки не может быть больше &1"
                                                   , v-dv-up-limit)
                                        , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U) .
    end.
    if v-dv-down-limit <> '':U
    and tt0-term_dis-rule.discnt-value > decimal(v-dv-up-limit) then do:
        run err-mess in this-procedure ( substitute("Значение скидки не может быть меньше &1"
                                                    , v-dv-down-limit)
                                       , output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U) .
    end.

    _JJ:
    do jj = 1 to num-entries({&check-fields}):
      assign
      v-curr-field = entry(jj, {&check-fields})
      .
      if v-tree-field[jj]  = no
      and not can-find(first temp-drt-prop no-lock where
                            temp-drt-prop.templ-rl-root = p-templ-rl-root
                        and temp-drt-prop.upper-prop-code = "Level2_UsingFields":U
                        and temp-drt-prop.prop-code = v-curr-field) then do:
        next _jj.
      end.
      run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                      , input v-curr-field
                                                      , output v-field-label).



      if v-down-limit[jj] <> "":u then do:
        if decimal(buffer tt0-term_dis-rule:buffer-field(v-curr-field):buffer-value)  < decimal(v-down-limit[jj]) then do:
          run err-mess(substitute("Значение &1 не может быть меньше &2"
                                  , v-field-label
                                  , v-down-limit[jj])
                                  , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
        end.
      end.
      if v-up-limit[jj] <> "":u then do:
        if decimal(buffer tt0-term_dis-rule:buffer-field(v-curr-field):buffer-value)  > decimal(v-up-limit[jj]) then do:
          run err-mess in this-procedure ( substitute("Значение &1 не может быть больше &2"
                                                    , v-field-label
                                                    , v-up-limit[jj])
                                          , output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U) .
        end.
      end.
    end.
    assign
    iib[1] = 0
    iib[2] = 0
    iib[3] = 0
    iib[4] = 0
    iib[5] = 0
    iib[6] = 0
    iib[7] = 0
    iib[8] = 0
    iib[9] = 0
    iib[10] = 0
    iib[11] = 0
    iib[12] = 0
    iib[13] = 0
    iib[14] = 0
    .

    _dub-tt:
    for each dub_tt-dis-rule no-lock where
            dub_tt-dis-rule.upper-rule-num = tt0-term_dis-rule.upper-rule-num
    break
    by dub_tt-dis-rule.rule-num:

      _JJ:
      do jj = 1 to num-entries({&check-fields}):
        assign
        v-curr-field = entry(jj, {&check-fields})
        .
        if v-tree-field[jj]  = no
        and not can-find(first temp-drt-prop no-lock where
                            temp-drt-prop.templ-rl-root = p-templ-rl-root
                        and temp-drt-prop.upper-prop-code = "Level2_UsingFields":U
                        and temp-drt-prop.prop-code = v-curr-field) then do:
          next _jj.
        end.
        run disrules-override-labels-2 in this-procedure ( input p-templ-rl-root
                                                        ,input v-curr-field
                                                        ,output v-field-label).
        assign
        iib[jj] = iib[jj] + 1
        .
        if v-num-rec[jj] > 0 then do:
          CASE v-num-rec-sign[jj]:
            when "<=":U then do:
              if iib[jj] > v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 не может быть больше &1"
                                              , v-num-rec[jj]
                                              , v-field-label)
                                              , output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
            when ">=":U then do:
              if last(dub_tt-dis-rule.rule-num) and
              iib[jj] < v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 не может быть меньше &1"
                                                            ,v-num-rec[jj]
                                                            ,v-field-label)
                                                            ,output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
            when "==":U then do:
              if last(dub_tt-dis-rule.rule-num) and
              iib[jj] <> v-num-rec[jj] then do:
                assign
                v-dub = yes
                .
                run err-mess in this-procedure ( input substitute("Количество правил детализированных &2 должно быть равно &1"
                                                            , v-num-rec[jj]
                                                            , v-field-label)
                                                            , output v-ret-mess).
                undo, return error (if p-silent then v-ret-mess else "":U).
              end.
            end.
          END CASE.
        end.
      end. /*do jj = 1 to num-entries({&check-fields}):*/
    end. /*for each dub_tt-dis-rule no-lock where */
  end. /*for each tt0-term_dis-rule no-lock where*/
  if v-dub then do:
    undo, return error "rule-num":U.
  end.
end. /*v-tree <> "":U*/



_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-new-rule-num) no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при попытке создания номера правила скидки: &1", return-value ), output v-ret-mess).
      undo _main, return error (if p-silent then v-ret-mess else '':U).
    end.
    create ub.dis-rule.
    assign
    ub.dis-rule.rule-num = v-new-rule-num
    p-recid = recid(ub.dis-rule)
    .
  end.
  else do:
    FIND FIRST ub.dis-rule where
              recid(ub.dis-rule) = p-recid No-ERROR.
    if not available ub.dis-rule then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПРАВИЛО СКИДКИ - p-recid" string(p-recid)
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.dis-rule.sts = integer({&to-delete-status-int}) then do:
&Scop used-status-code STRING(ub.dis-rule.sts)
      message
      "Правило находится в статусе" {&used-status-int-name}  skip
      "ИЗМЕНЕНИЕ ЗАПРЕЩЕНО" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.dis-rule.rule-num <> p-rule-num
    or ub.dis-rule.host-code <> p-host-code
    or ub.dis-rule.obj-type <> p-obj-type
    or ub.dis-rule.obj-code <> p-obj-code
    or ub.dis-rule.time-templ-rl-root <> p-time-templ-rl-root
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "номер правила и/или привязку к объекту и фирме" skip
      "и тип привязанного расписания"
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  if v-sts-mode then do:
    v-rule-num = p-rule-num.
  end.
  else do:
  assign
  ub.dis-rule.des               = p-des
  ub.dis-rule.dis-kat           = p-dis-kat
  ub.dis-rule.discnt-type       = p-discnt-type
  ub.dis-rule.doc-qnty          = p-doc-qnty
  ub.dis-rule.tot-sum           = p-tot-sum
  ub.dis-rule.sts               = (if p-mode = {&add-def} then integer({&current-status-int}) else ub.dis-rule.sts)
  ub.dis-rule.subject-type      = p-subject-type
  ub.dis-rule.time-rule-num     = p-time-rule-num
  ub.dis-rule.time-templ-rl-root = (if available buf_dis-time-rule
                                    then buf_dis-time-rule.templ-rl-root
                                    else 0)
  ub.dis-rule.upper-rule-num    = p-upper-rule-num
  ub.dis-rule.value-type        = p-value-type
  ub.dis-rule.discnt-value      = p-discnt-value
  ub.dis-rule.host-code         = p-host-code
  ub.dis-rule.obj-type          = p-obj-type
  ub.dis-rule.obj-code          = p-obj-code
  ub.dis-rule.root              = yes
  ub.dis-rule.lvl-num           = 1
  ub.dis-rule.is-term           = (v-tree = "":U)
  ub.dis-rule.uniq-field        = v-tree
  ub.dis-rule.other-inf         = v-other
  ub.dis-rule.rl-root           = ub.dis-rule.rule-num
  ub.dis-rule.templ-rl-root     = p-upper-rule-num
  ub.dis-rule.key#_one          = p-key#_one
  ub.dis-rule.key#_two          = p-key#_two
  ub.dis-rule.key#_three        = p-key#_three
  ub.dis-rule.charkey_one       = p-charkey_one
  ub.dis-rule.charkey_two       = p-charkey_two
  ub.dis-rule.charkey_three     = p-charkey_three
  ub.dis-rule.deckey_one        = p-deckey_one
  ub.dis-rule.deckey_two        = p-deckey_two
  ub.dis-rule.deckey_three      = p-deckey_three
  v-rule-num                    = ub.dis-rule.rule-num
  .
  release ub.dis-rule no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( substitute("Ошибка при сохранении записи ПРАВИЛО СКИДКИ с номером &1: &2: &3"
                            , v-rule-num
                            , ERROR-STATUS:GET-message(1)
                            , return-value
                            ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
 end.
 end.
 if (p-mode = {&add-def}
 or v-sts-mode = yes)
 and can-find(first ub.dis-cfg-rule no-lock where
                    ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
                and ub.dis-cfg-rule.table-name = {&table_dis-thbj-rule})

 then do:
   v-nonunique = '':U.
   for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root  = p-templ-rl-root
        and buf_dis-cfg-rule.table-name = {&table_dis-thbj-rule}
        and buf_dis-cfg-rule.pos-type = p-pos-type
        and ((p-time-templ-rl-root = 0 and lookup("time-rule-num", v-level-2) > 0)
            or buf_Dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
            )
   on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
   on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
   on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
   :
    if buf_dis-cfg-rule.link-prop = integer({&dr-appl-object}) then do:
      do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
        assign
        v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
        .
        assign
        v-nonunique = (if v-nonunique = '':u then '':U else {&delim-par}) +
                    string(buffer check_dis-rule:buffer-field(v-curr-field):buffer-value).
      end.
      create buf_dis-thbj-rule.
      assign
      buf_dis-thbj-rule.host-code = p-host-code
      buf_dis-thbj-rule.obj-type = p-obj-type
      buf_dis-thbj-rule.obj-code = p-obj-code
      buf_dis-thbj-rule.pos-type = p-pos-type
      buf_dis-thbj-rule.discnt-role = buf_Dis-cfg-rule.discnt-role
      buf_dis-thbj-rule.templ-rl-root = p-templ-rl-root
      buf_dis-thbj-rule.nonunique = v-nonunique
      buf_dis-thbj-rule.rule-num = v-rule-num
      buf_dis-thbj-rule.rl-root = v-rule-num
      buf_Dis-thbj-rule.time-templ-rl-root = p-time-templ-rl-root
      .
      define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
      define buffer buf2_dis-rule for ub.dis-rule.
      v-nonunique2 = '':U.
      for each buf2_dis-cfg-rule no-lock where
              buf2_dis-cfg-rule.table-name = {&table_dis-thbj-rule}
          and buf2_dis-cfg-rule.pos-type = p-pos-type
          and buf2_dis-cfg-rule.link-prop = integer({&dr-rule-ref-object})
          and buf2_dis-cfg-rule.discnt-role = buf_dis-cfg-rule.discnt-role,
      first buf2_dis-rule no-lock where
                  buf2_dis-rule.rule-num = p-key#_one
             and buf2_dis-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
             and (buf2_dis-rule.time-templ-rl-root = buf2_dis-cfg-rule.time-templ-rl-root
                  or
                  buf2_dis-rule.time-templ-rl-root = 0 and buf2_dis-rule.is-term = no
                 )
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        if not (buf2_dis-rule.obj-type = p-obj-type
                and
                buf2_dis-rule.obj-code = p-obj-code) then do:
          run err-mess in this-procedure ( substitute("Правило скидки &1, которое является значением правила изменяемого/сохраняемого правила скидки &2&7" +
                                                      "должно быть привязано к &3&4, а не к &5&6"
                                                      , buf2_dis-rule.rule-num
                                                      , v-rule-num
                                                      , (if p-obj-type = "" then "Глобально" else p-obj-type)
                                                      , p-obj-code
                                                      , (if buf2_dis-rule.obj-type = ""  then "Глобально" else buf2_dis-rule.obj-type)
                                                      , buf2_dis-rule.obj-code
                                                      ), output v-ret-mess).
          undo, return error (if p-silent then v-ret-mess else "":U).
        end.
        do jj = 1 to num-entries(buf2_dis-cfg-rule.nonunique):
          assign
          v-curr-field = entry(jj, buf2_dis-cfg-rule.nonunique)
          .
          assign
          v-nonunique2 = (if v-nonunique2 = '':u then '':U else {&delim-par}) +
                      string(buffer buf2_dis-rule:buffer-field(v-curr-field):buffer-value).
        end.
        create buf_dis-thbj-rule.
        assign
        buf_dis-thbj-rule.host-code = p-host-code
        buf_dis-thbj-rule.obj-type = p-obj-type
        buf_dis-thbj-rule.obj-code = p-obj-code
        buf_dis-thbj-rule.pos-type = p-pos-type
        buf_dis-thbj-rule.discnt-role = buf2_Dis-cfg-rule.discnt-role
        buf_dis-thbj-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
        buf_dis-thbj-rule.nonunique = v-nonunique2
        buf_dis-thbj-rule.rule-num = buf2_dis-rule.rule-num
        buf_dis-thbj-rule.rl-root = buf2_dis-rule.rl-root
        buf_Dis-thbj-rule.time-templ-rl-root = buf2_dis-rule.time-templ-rl-root
        .
      end. /*for each buf2_dis-cfg-rule no-lock where*/
      leave.
     end. /*if buf_dis-cfg-rule.link-prop = integer({&dr-appl-object}) then do:*/
   end. /*for each buf_dis-cfg-rule no-lock where*/
 end. /*if p-mode = {&add-def}*/
 if v-sts-mode then return.
 if p-mode <> {&add-def} then do:
  for each term_dis-rule where
          term_dis-rule.upper-rule-num = v-rule-num
   on error undo _main, return error error-status:get-message(1) :
    find first tt0-term_dis-rule no-lock where
                tt0-term_dis-rule.upper-rule-num = v-rule-num
            AND tt0-term_dis-rule.rule-num = term_dis-rule.rule-num no-error .
    if not available tt0-term_dis-rule then do:
      /*удаляем сслыки и условия содержащиесмя в ветках*/
      for each buf_dis-cfg-rule no-lock where
            buf_Dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf_Dis-cfg-rule.pos-type = p-pos-type
        and buf_Dis-cfg-rule.time-templ-rl-root = term_dis-rule.time-templ-rl-root
        on error undo _main, return error error-status:get-message(1) :
        if buf_dis-cfg-rule.link-prop <> integer({&dr-appl-object})
        and buf_dis-cfg-rule.link-prop <> integer({&dr-rule-ref-object})
        then do:
          /*пишем сслыки и условия содержащиесмя в ветках*/
          run delete-from-projection in this-procedure ( input term_dis-rule.rule-num
                                                        ,buffer buf_dis-cfg-rule
                                                        ).
        end.
      end.
      v-run-cn = yes.
      delete term_dis-rule no-error .
      if error-status:error then do:
        run err-mess in this-procedure ( substitute("Ошибка при попытке удаления правила скидки: &1 (детализация к правилу &2): &3 ", tt0-term_dis-rule.rule-num, v-rule-num, return-value ), output v-ret-mess).
        undo _main, return error (if p-silent then v-ret-mess else '':U).
      end.
    end.
  end.
 end.
 for each tt0-term_dis-rule
 on error undo _main, return error error-status:get-message(1)
 :
    find first term_dis-rule where
                term_dis-rule.upper-rule-num = v-rule-num
            AND term_dis-rule.rule-num       = tt0-term_dis-rule.rule-num
            no-error .
    if not available term_dis-rule then do:
      v-run-cn = yes.
      run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-new-rule-num) no-error .
      if error-status:error then do:
      end.
      create term_dis-rule.
      assign
      term_dis-rule.upper-rule-num = v-rule-num
      term_dis-rule.rule-num       = v-new-rule-num
      term_dis-rule.rl-root        = v-rule-num
      .
    end.
    buffer-copy tt0-term_dis-rule except rule-num upper-rule-num root is-term lvl-num uniq-field rl-root
    doc-qnty tot-sum dis-kat time-rule-num
    charkey_one
    charkey_two
    charkey_three
    deckey_one
    deckey_two
    deckey_three
    key#_one
    key#_two
    key#_three
    to term_dis-rule
    assign
    term_dis-rule.doc-qnty = (if lookup("doc-qnty", v-level-2) = 0
                              then (if lookup("doc-qnty", v-level-1) = 0
                                    then -1
                                    else p-doc-qnty)
                              else tt0-term_dis-rule.doc-qnty)
    term_dis-rule.tot-sum = (if lookup("tot-sum", v-level-2) = 0
                             then (if lookup("tot-sum", v-level-1) = 0
                                   then -1
                                   else p-tot-sum)
                             else tt0-term_dis-rule.tot-sum)
    term_dis-rule.dis-kat = (if lookup("dis-kat", v-level-2) = 0
                             then (if lookup("dis-kat", v-level-1) = 0
                                   then p-dis-kat
                                   else -1)
                             else tt0-term_dis-rule.dis-kat)
    term_dis-rule.charkey_one = (if lookup("charkey_one", v-level-2) = 0
                                 then (if lookup("charkey_one", v-level-1) = 0
                                       then ?
                                       else p-charkey_one)
                                 else tt0-term_dis-rule.charkey_one)
    term_dis-rule.charkey_two = (if lookup("charkey_two", v-level-2) = 0
                                 then (if lookup("charkey_two", v-level-1) = 0
                                      then ?
                                      else p-charkey_two)
                                 else tt0-term_dis-rule.charkey_two)
    term_dis-rule.charkey_three = (if lookup("charkey_three", v-level-2) = 0
                                   then (if lookup("charkey_three", v-level-1) = 0
                                         then ?
                                         else p-charkey_three)
                                   else tt0-term_dis-rule.charkey_three)
    term_dis-rule.deckey_one = (if lookup("deckey_one", v-level-2) = 0
                                 then (if lookup("deckey_one", v-level-1) = 0
                                       then ?
                                       else p-deckey_one)
                                 else tt0-term_dis-rule.deckey_one)
    term_dis-rule.deckey_two = (if lookup("deckey_two", v-level-2) = 0
                                 then (if lookup("deckey_two", v-level-1) = 0
                                       then ?
                                       else p-deckey_two)
                                 else tt0-term_dis-rule.deckey_two)
    term_dis-rule.deckey_three = (if lookup("deckey_three", v-level-2) = 0
                                   then (if lookup("deckey_three", v-level-1) = 0
                                         then ?
                                         else p-deckey_three)
                                   else tt0-term_dis-rule.deckey_three)
    term_dis-rule.key#_one = (if lookup("key#_one", v-level-2) = 0
                              then (if lookup("key#_one", v-level-1) = 0
                                    then ?
                                    else p-key#_one)
                              else tt0-term_dis-rule.key#_one)
    term_dis-rule.key#_two = (if lookup("key#_two", v-level-2) = 0
                              then (if lookup("key#_two", v-level-1) = 0
                                    then ?
                                    else p-key#_two)
                              else tt0-term_dis-rule.key#_two)
    term_dis-rule.key#_three = (if lookup("key#_three", v-level-2) = 0
                                then (if lookup("key#_three", v-level-1) = 0
                                      then ?
                                      else p-key#_three)
                                else tt0-term_dis-rule.key#_three)
    term_dis-rule.time-rule-num = (if lookup("time-rule-num", v-level-2) = 0
                                   then (if lookup("time-rule-num", v-level-1) = 0
                                         then -1
                                         else p-time-rule-num)
                                   else tt0-term_dis-rule.time-rule-num)
    term_dis-rule.time-templ-rl-root = (if lookup("time-rule-num", v-level-2) = 0
                                        then (if lookup("time-rule-num", v-level-1) = 0
                                              then 0
                                              else p-time-templ-rl-root)
                                        else tt0-term_dis-rule.time-templ-rl-root)
    v-term-time-templ-rl-root       = term_dis-rule.time-templ-rl-root
    term_dis-rule.root              = no
    term_dis-rule.lvl-num           = 2
    term_dis-rule.is-term           = yes
    term_dis-rule.uniq-field        = v-tree
    term_dis-rule.other-inf         = v-other
    .
    release term_dis-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при попытке сохранения правила скидки: &1 (детализация к правилу &2): &3 ", v-new-rule-num, v-rule-num, return-value ), output v-ret-mess).
      undo _main, return error (if p-silent then v-ret-mess else '':U).
    end.
    v-run-cn = yes.
    for each buf_dis-cfg-rule no-lock where
           buf_Dis-cfg-rule.templ-rl-root = p-templ-rl-root
      and buf_Dis-cfg-rule.pos-type = p-pos-type
      and buf_Dis-cfg-rule.time-templ-rl-root = v-term-time-templ-rl-root
      on error undo _main, return error error-status:get-message(1) :
       if buf_dis-cfg-rule.link-prop <> integer({&dr-appl-object})
       and buf_dis-cfg-rule.link-prop <> integer({&dr-rule-ref-object})
       and p-mode = {&add-def}
       then do:
         /*пишем сслыки и условия содержащиесмя в ветках*/
         run create-from-projection in this-procedure ( input v-new-rule-num
                                                       ,buffer buf_dis-cfg-rule
                                                       ).
       end.
    end.
  end.
  if v-run-cn then do:
    find first ub.dis-rule no-lock where
              ub.dis-rule.rule-num = v-rule-num .
    run str/callnews.p
        (input {&table_dis-rule}
        ,input (buffer ub.dis-rule:handle)
        ).
  end.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      p-ret-mess =
      substitute("ПРАВИЛО СКИДКИ &1: &2&3"
                , (if p-mode = {&update} then string(p-rule-num) else p-des)
                , {&new-line}
                , p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.

procedure check-projection :
define parameter buffer buf_tt0-term_dis-rule for tt0-term_dis-rule.
define input parameter p-table-name as character no-undo .
define input parameter p-projection as character no-undo .
define output parameter p-reason as character no-undo .

define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-ii as integer no-undo .
do
on error undo, return error
:
   v-uniq-key-rec = p-table-name.
   do v-ii = 1 to num-entries(p-projection):
     assign
     v-uniq-key-rec = v-uniq-key-rec + {&delim-key} +
                      string(buffer buf_tt0-term_dis-rule:buffer-field(entry(2, entry(v-ii, p-projection), "=":U)):buffer-value)
     .
   end.
   /*надо найти запись по v-uniq-key-rec*/
   run gen-row-keyr in this-procedure (
                                         input  v-uniq-key-rec
                                        ,input  ? /*p-key-handle  */
                                        ,input  "Ub"
                                        ,input  ? /*p-tt-handle   */
                                        ,input  no-lock
                                        ,output v-tbl-row
                                        ,output v-tbl-name   ) no-error.
   if not error-status:error then do:
     return '':U.
   end.
&scop dis-cfg-rule-table-code p-table-name
   assign
   p-reason = substitute("&1", {&dis-cfg-rule-table-name})
   .
end.

end procedure. /* check-projection */


procedure disrules-override-labels-2 :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
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
      when "dis-kat" then do:
        p-label = "Категория".
      end.
      when "tot-sum" then do:
        p-label = "Сумма".
      end.
      when "doc-qnty" then do:
        p-label = "Кол-во".
      end.
      when "time-rule-num" then do:
        p-label = "Расписание".
      end.
      when "value-type" then do:
        p-label = "Тип".
      end.
    end case.
  end.

  end. /*doe*/

end procedure. /* disrules-override-labels-2 */

procedure create-from-projection :
define input  parameter p-link-rule-num as integer   no-undo .
define parameter buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define variable buf_h as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable glog as logical   no-undo .

do
on error undo, return error return-value
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-link-rule-num.
  create buffer buf_h for table buf_dis-cfg-rule.table-name.
  assign
  glog = buf_h:buffer-copy(buffer buf_dis-rule:handle) no-error.
  if not glog then do:
    delete widget buf_h.
    undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , {&new-line}
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h:buffer-field("pos-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("pos-type"):buffer-value
  .
  if buf_dis-cfg-rule.self-nonunique <>'':U then do:
    assign
    buf_h:buffer-field("classif-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("self-nonunique"):buffer-value
    .
  end.
  if buf_dis-cfg-rule.nonunique <> '':U then do:
    assign
    buf_h:buffer-field("nonunique"):buffer-value = string(buffer buf_Dis-rule:handle:buffer-field(buf_dis-cfg-rule.nonunique):buffer-value)
    .
  end.
  assign
  buf_h:buffer-field("discnt-role"):buffer-value = buffer buf_Dis-cfg-rule:handle:buffer-field("discnt-role"):buffer-value
  .
  do v-ii = 1 to num-entries(buf_dis-cfg-rule.projection):
     v-dop = entry(v-ii, buf_dis-cfg-rule.projection).
     assign
     buf_h:buffer-field(entry(1, v-dop, "=":U)):buffer-value = buffer buf_dis-rule:buffer-field(entry(2, v-dop, "=":U)):buffer-value
     no-error
     .
     if error-status :error then do:
        delete widget buf_h.
        undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                      ,buf_dis-cfg-rule.table-name
                                      , {&new-line}
                                      , error-status:get-message(1)).
     end.
  end.
  assign
  glog = buf_h:buffer-release no-error .
  if not glog then do:
    delete widget buf_h.
    undo, return error substitute("Ошибка сохранения связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  ,{&new-line}
                                  ,error-status:get-message(1)).

  end.
  delete widget buf_h.
end.

end procedure. /* create-form-projection */

procedure delete-from-projection :
define input  parameter p-link-rule-num as integer   no-undo .
define parameter buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define variable buf_h as handle no-undo .
define variable buf_h2 as handle no-undo .
define variable t_h as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable glog as logical   no-undo .
define variable v-keys as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .

do
on error undo, return error return-value
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-link-rule-num.
  create temp-table t_h.

assign
t_h:undo = no
glog = false
.
  assign
  glog = t_h:create-like(buf_dis-cfg-rule.table-name ) no-error
  .
  if glog <> true then do:
    delete object t_h.
    undo, return error substitute("Ошибка создания врем.таблицы при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , {&new-line}
                                  , error-status:get-message(1)).

  end.
  glog = no.
  assign
  glog = t_h:temp-table-prepare( substitute("temp_&1", buf_dis-cfg-rule.table-name )) no-error
  .
  if glog <> true then do:
    delete object t_h.
    undo, return error substitute("Ошибка создания врем.таблицы при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , {&new-line}
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h = t_h:default-buffer-handle
  .
  assign
  glog = buf_h:buffer-copy(buffer buf_dis-rule:handle) no-error.
  if not glog then do:
    delete widget t_h.
    undo, return error substitute("Ошибка копирования при удалении связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  , {&new-line}
                                  , error-status:get-message(1)).
  end.
  assign
  buf_h:buffer-field("pos-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("pos-type"):buffer-value
  .
  if buf_dis-cfg-rule.self-nonunique <>'':U then do:
    assign
    buf_h:buffer-field("classif-type"):buffer-value = buffer buf_dis-cfg-rule:buffer-field("self-nonunique"):buffer-value
    .
  end.
  if buf_dis-cfg-rule.nonunique <> '':U then do:
    assign
    buf_h:buffer-field("nonunique"):buffer-value = string(buffer buf_Dis-rule:handle:buffer-field(buf_dis-cfg-rule.nonunique):buffer-value)
    .
  end.
  assign
  buf_h:buffer-field("discnt-role"):buffer-value = buffer buf_Dis-cfg-rule:handle:buffer-field("discnt-role"):buffer-value
  .
  do v-ii = 1 to num-entries(buf_dis-cfg-rule.projection):
     v-dop = entry(v-ii, buf_dis-cfg-rule.projection).
     assign
     buf_h:buffer-field(entry(1, v-dop, "=":U)):buffer-value = buffer buf_dis-rule:buffer-field(entry(2, v-dop, "=":U)):buffer-value
     no-error
     .
     if error-status :error then do:
        delete widget t_h.
        undo, return error substitute("Ошибка копирования при связи правила с &1&2&3"
                                      ,buf_dis-cfg-rule.table-name
                                      , {&new-line}
                                      , error-status:get-message(1)).
     end.
  end.
  v-keys = buf_h:keys.
  v-uniq-key-rec = buf_dis-cfg-rule.table-name .
  do v-ii = 1 to num-entries(v-keys):
    v-uniq-key-rec = v-uniq-key-rec + {&delim-key} + string(buf_h:buffer-field(entry(v-ii, v-keys)):buffer-value).
  end.
  v-uniq-key-rec = trim(v-uniq-key-rec, {&delim-key}).
  run gen-row-keyr in this-procedure (
   input  v-uniq-key-rec
  ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input "ub"
  ,input ?  /* p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input exclusive-lock
  ,output v-tbl-row
  ,output v-tbl-name).
  create buffer buf_h2 for table buf_dis-cfg-rule.table-name.

  glog = buf_h2:find-by-rowid( v-tbl-row).
  assign
  glog = buf_h2:buffer-delete no-error .
  if not glog then do:
    delete widget t_h.
    undo, return error substitute("Ошибка удаления связи правила с &1&2&3"
                                  ,buf_dis-cfg-rule.table-name
                                  ,{&new-line}
                                  ,error-status:get-message(1)).

  end.
  delete widget t_h.
  delete widget buf_h2.
end.

end procedure. /* delete-from-projection */