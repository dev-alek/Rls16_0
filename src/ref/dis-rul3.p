block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-rul3.p $
$Archive: ref/dis-rul3.p $

Физическое удаление правила скидок и провекра возможности выключени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/15/04
Author: Bakhtadze Natalya
Creation date: 09/15/04

*/

define parameter buffer buf_dis-rule for ub.dis-rule .
define input parameter p-sts-mode as logical no-undo .
/*p-sts-mode no - физическое удаление записи*/
/*p-sts-mode yes - проверка возможности ЛОГИЧЕСКОГО удаления записи*/
define input parameter p-silent                       as logical no-undo .
define output parameter p-can                         as logical no-undo .
/*возможно удалить запист*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul3.p $":U .
define variable vss-description as character no-undo init "Физическое удаление правила скидок и проверка возможности выключения".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/disrules.i "work" }
{ gbl/waitfram.i }

define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo . /* виден в броусе */
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo . /* еще чего - нибудь */
define variable  v-entry             as character no-undo .
define variable  ii as integer no-undo .
define variable v-dis-gds-rule-log as logical   no-undo .
define variable v-dis-dc-rule-log as logical   no-undo .
define variable v-dis-dct-rule-log as logical   no-undo .
define variable v-dis-grp-rule-log as logical   no-undo .
define variable v-dis-cp-rule-log as logical   no-undo .
define variable v-dis-some-rule-log as logical   no-undo .
define variable v-dis-thbj-rule-log as logical no-undo .
define variable v-found as logical no-undo .
define variable v-db-num like ub.db.db-num  no-undo .
define variable v-ret-mess as character no-undo .
define buffer buf_clients-obj for ub.clients.
define buffer buf_db for ub.db.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-some-rule for ub.dis-some-rule.
define buffer buf2_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.

do
on error undo, return error return-value
:

  if buf_dis-rule.rule-num <= {&max-num-dr-template}
  and not p-sts-mode
  then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять запись ШАБЛОНОВ СКИДОК"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
  if buf_dis-rule.upper-rule-num > {&max-num-dr-template} then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять или выключать детализированную запись ПРАВИЛА СКИДОК"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.

  if
  g#db-num <> 0
  and not g#news
  and (buf_dis-rule.host-code = 0
  or   buf_dis-rule.obj-type = "":U
  or   buf_dis-rule.obj-code = 0)
  then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять или выключать глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в УБД:&1" +
                            "номер текущей БД &2"
                             , {&new-line}
                             , g#db-num), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "host-code":U).
  end.

  run dr-code  in this-procedure (
      input  buf_dis-rule.templ-rl-root
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
      run err-mess in this-procedure ( substitute("Неверный номер шаблона для скидки: &1, &2", buf_Dis-rule.templ-rl-root, return-value), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.

  /*разберем v-other  */
  do ii = 1 to num-entries(v-other, ";":U):
    assign
    v-entry = entry(ii, v-other, ";")
    .
    assign
    v-dis-gds-rule-log = (v-entry =  {&table_dis-gds-rule})
    v-dis-cp-rule-log = (v-entry = {&table_dis-cp-rule})
    v-dis-dc-rule-log = (v-entry = {&table_dis-dc-rule})
    v-dis-dct-rule-log = (v-entry = {&table_dis-dct-rule})
    v-dis-grp-rule-log = (v-entry = {&table_dis-grp-rule})
    v-dis-some-rule-log = (v-entry = {&table_dis-some-rule})
    v-dis-thbj-rule-log = (v-entry = {&table_dis-thbj-rule})
    .
  end. /*do ii*/

  if buf_dis-rule.obj-code > 0 then do:
    { gbl/objdbnum.i buf_dis-rule.obj-type buf_dis-rule.obj-code v-db-num }
    if (v-db-num <> g#db-num and g#db-num > 0) then do:
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ на объекте в чужой УБД: ~
                              номер текущей БД &1, номер БД для &2&3: &4"
                              , g#db-num
                              , buf_dis-rule.obj-type
                              , buf_dis-rule.obj-code
                              , v-db-num
                              ), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "obj-code":U).
    end.
  end.

  /*проверим что есть УБД*/
  if not p-sts-mode
  then do:
    if buf_dis-rule.obj-code = 0
    and buf_dis-rule.obj-type = "":U then do:
      find first buf_db no-lock where
                buf_db.db-num > 0 no-error.
      if available buf_db then do:
        if buf_dis-rule.sts <> integer({&to-delete-status-int}) then do:
          run err-mess in this-procedure ( substitute("Нельзя удалять глобальную запись ПРАВИЛА СКИДКИ в системе с УБД"), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U).
      end.
    end.
  end.
  end.
  /*если система без УБД или объект текущей БД проверим что нет таких связок*/
  run waitfram-show in this-procedure ( "Ждите .. Проводится проверка возможности удаления/выключения правила" ).
  if v-dis-thbj-rule-log then do:
    _dis-thbj-rule:
    for each buf_dis-thbj-rule no-lock where
         buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-thbj-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-thbj-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
          and (buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-thbj-rule.time-templ-rl-root
              or
              (buf_dis-rule.is-term = no and lookup("time-rule-num", v-level-2) > 0)
              )
          and buf_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop > integer({&dr-appl-object}):
      assign
      v-found = yes
      .
      leave _dis-thbj-rule.
    end.
    define variable v-can as logical   no-undo .
    define buffer buf_drt-prop for ub.drt-prop.
    if v-found
    then do:
      find first buf_drt-prop no-lock where
      buf_drt-prop.templ-rl-root = buf_dis-rule.templ-rl-root
      and buf_drt-prop.upper-prop-code = "can-update"
      and buf_drt-prop.prop-code = "can" no-error.
      if available buf_drt-prop
      and integer(buf_drt-prop.property-value) > 0 then do:
        if integer(buf_drt-prop.property-value) >= 2 then do:
          v-found = no.
        end.
        if integer(buf_drt-prop.property-value) < 2 then do:
          find first buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = buf_dis-rule.templ-rl-root
          and buf_drt-prop.upper-prop-code = "can-update"
          and buf_drt-prop.prop-code = "can-message" no-error.
          if available buf_drt-prop
          and not p-silent
          then do:
            message
            buf_drt-prop.property-value
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
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ: &1" +
                              "с ней связана ОБЩАЯ СКИДКА НА ОБЪЕКТЕ: &2&3"
                              , {&new-line}
                              , buf_dis-thbj-rule.obj-type
                              , buf_dis-thbj-rule.obj-code
                              )
                               , output v-ret-mess
                              ).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-gds-rule-log then do:
    _dis-gds-rule:
    for each buf_dis-gds-rule no-lock where
         buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-gds-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-gds-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-gds-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}):
      assign
      v-found = yes
      .
      leave _dis-gds-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ: &1" +
                              "с ней связана СКИДКА ТОВАРА НА ОБЪЕКТЕ: &2&3 товар &4"
                              , {&new-line}
                              , buf_dis-gds-rule.obj-type
                              , buf_dis-gds-rule.obj-code
                              , buf_dis-gds-rule.gds-code
                              )
                               , output v-ret-mess
                              ).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-cp-rule-log then do:
    _dis-cp-rule:
    for each buf_dis-cp-rule no-lock where
           buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-cp-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-cp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-cp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-cp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-cp-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}):
      assign
      v-found = yes
      .
      leave _dis-cp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-cp-rule-code buf_dis-cp-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
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
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-dc-rule-log then do:
    _dis-dc-rule:
    for each buf_dis-dc-rule no-lock where
           buf_dis-dc-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-dc-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dc-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dc-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}):

      assign
      v-found = yes
      .
      leave _dis-dc-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-dc-rule-code buf_dis-dc-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА ДК: ДК &2 тип скидки &3 &4 фирма &5 объект &6&7"
                              , {&new-line}
                              , buf_dis-dc-rule.d-card
                              , {&dis-dc-rule-name}
                              , buf_dis-dc-rule.host-code
                              , buf_dis-dc-rule.obj-type
                              , buf_dis-dc-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end. /* if v-dis-dc-rule-log*/
  if v-dis-dct-rule-log then do:
    _dis-dct-rule:
    for each buf_dis-dct-rule no-lock where
           buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-dct-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dct-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dct-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dct-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dct-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}):

      assign
      v-found = yes
      .
      leave _dis-dct-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-dct-rule-code buf_dis-dct-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА ТИПА ДК: эмитент &2 тип &3 тип скидки &4 &5 фирма &6 объект &7&8"
                              , {&new-line}
                              , buf_dis-dct-rule.emitent-host-code
                              , buf_dis-dct-rule.type
                              , {&dis-dct-rule-name}
                              , buf_dis-dct-rule.host-code
                              , buf_dis-dct-rule.obj-type
                              , buf_dis-dct-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end. /*if v-dis-dct-rule-log then do:*/
  if v-dis-grp-rule-log then do:
    _dis-grp-rule:
    for each buf_dis-grp-rule no-lock where
           buf_dis-grp-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-grp-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-grp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-grp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-grp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-grp-rule.discnt-role
          and buf_Dis-cfg-rule.self-nonunique = buf_Dis-grp-rule.classif-type
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object}):
      assign
      v-found = yes
      .
      leave _dis-grp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
&scop dis-ggr-rule-code buf_dis-grp-rule.discnt-role
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА НА ГРУППУ: группа &2 тип скидки &3 &4 фирма &5 объект &6&7"
                              , {&new-line}
                              , buf_dis-grp-rule.node-code
                              , {&dis-ggr-rule-name}
                              , buf_dis-grp-rule.host-code
                              , buf_dis-grp-rule.obj-type
                              , buf_dis-grp-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end. /*if v-dis-grp-rule-log then do:*/



  run waitfram-hide in this-procedure .
  if p-sts-mode then do:
     p-can = yes.
     return.
  end.
  for each buf2_dis-rule where
          buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
  on error undo, return error :
    if v-dis-gds-rule-log then do:
      for each buf_dis-gds-rule share-lock where
              buf_dis-gds-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-gds-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-gds-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-gds-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})
      on error undo, return error :
        delete buf_dis-gds-rule.
      end.
    end.
    if v-dis-cp-rule-log then do:
      for each buf_dis-cp-rule share-lock where
              buf_dis-cp-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-cp-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-cp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-cp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-cp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-cp-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})
      on error undo, return error :
        delete buf_dis-cp-rule.
      end.
    end.
    if v-dis-dc-rule-log then do:
      for each buf_dis-dc-rule share-lock where
              buf_dis-dc-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-dc-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dc-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dc-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})
      on error undo, return error :
        delete buf_dis-dc-rule.
      end.
    end.
    if v-dis-dct-rule-log then do:
      for each buf_dis-dct-rule share-lock where
              buf_dis-dct-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-dct-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dct-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dct-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dct-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dct-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})

      on error undo, return error :
        delete buf_dis-dct-rule.
      end.
    end.
    if v-dis-grp-rule-log then do:
      for each buf_dis-grp-rule share-lock where
              buf_dis-grp-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = {&table_dis-grp-rule}
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-grp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-grp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-grp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-grp-rule.discnt-role
          and buf_Dis-cfg-rule.self-nonunique = buf_Dis-grp-rule.classif-type
          and buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})
      on error undo, return error :
        delete buf_dis-grp-rule.
      end.
    end.
    if v-dis-some-rule-log then do:
      for each buf_dis-some-rule share-lock where
              buf_dis-some-rule.rule-num = buf2_dis-rule.rule-num
      on error undo, return error :
        delete buf_dis-some-rule.
      end.
    end.
    delete buf2_dis-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при удалении ПРАВИЛА СКИДКИ №&1: &2 &3", buf2_dis-rule.rule-num, error-status:get-message(1), return-value  ), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  for each buf_dis-thbj-rule exclusive-lock where
          buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num,
  first buf_dis-cfg-rule no-lock where
      buf_Dis-cfg-rule.table-name = {&table_dis-thbj-rule}
  and buf_Dis-cfg-rule.templ-rl-root = buf_dis-thbj-rule.templ-rl-root
  and buf_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
  and (buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-thbj-rule.time-templ-rl-root
      or (buf_dis-thbj-rule.time-templ-rl-root = 0
          and
          lookup("time-rule-num", v-level-2) > 0))
  and buf_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
  on error  undo,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_Dis-cfg-rule.link-prop = integer({&dr-appl-object})
    then do:
      define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
      define buffer buf2_dis-thbj-rule for ub.dis-thbj-rule.
      for each buf2_dis-cfg-rule no-lock where
          buf2_Dis-cfg-rule.table-name = {&table_dis-thbj-rule}
      and buf2_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
      and buf2_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
      and buf2_Dis-cfg-rule.link-prop = integer({&dr-rule-ref-object}),
         each buf2_dis-thbj-rule where
             buf2_dis-thbj-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
         and buf2_dis-thbj-rule.pos-type = buf2_dis-cfg-rule.pos-type
         and buf2_dis-thbj-rule.discnt-role = buf2_dis-cfg-rule.discnt-role
         and buf2_dis-thbj-rule.rule-num = buf_dis-rule.key#_one
      on error  undo,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf2_dis-thbj-rule.
      end.
      delete buf_dis-thbj-rule.
    end.
  end.
  for each buf2_dis-rule where
          buf2_dis-rule.rl-root = buf_dis-rule.rule-num
  on error undo, return error
  on stop undo, return error :
    if buf2_dis-rule.rule-num = buf_dis-rule.rule-num then next.
    delete buf2_dis-rule.
  end.
  delete buf_dis-rule no-error.
  if error-status:error then do:
    run err-mess in this-procedure ( substitute("Ошибка при удалении ПРАВИЛА СКИДКИ №&1: &2 &3", buf_dis-rule.rule-num, error-status:get-message(1), return-value  ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.

end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      p-ret-mess = substitute("ПРАВИЛО СКИДКИ №&1:&2&3", buf_dis-rule.rule-num, {&new-line}, p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.