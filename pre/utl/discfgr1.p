block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-table-name as character no-undo .
define input parameter        p-pos-type   as character no-undo .
define input parameter        p-templ-rl-root as integer no-undo .
define input parameter        p-discnt-role as character no-undo .
define input parameter        p-time-templ-rl-root as integer no-undo .
define input parameter        p-self-nonunique as character no-undo .
define input parameter        p-nonunique as character no-undo .
define input parameter        p-has-glob as integer no-undo .
define input parameter        p-has-host as integer no-undo .
define input parameter        p-has-obj as integer no-undo .
define input parameter        p-link-prop as integer no-undo .
define input parameter        p-projection as character no-undo .
define input parameter        p-discnt-type as integer no-undo .
define input parameter        p-subject-type as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discfgr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/discfgr1.p $":U .
define variable vss-description as character no-undo init "Сохранение записи конфигурации правила скидки".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-discnt-role-list as character no-undo .
define variable v-mess as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_dis-cfg-rule
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first buf_dis-cfg-rule no-lock where
             buf_dis-cfg-rule.table-name = p-table-name
         and buf_dis-cfg-rule.pos-type = p-pos-type
         and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
         and buf_dis-cfg-rule.discnt-role = p-discnt-role
               no-error.
    if available buf_dis-cfg-rule then do:
      assign
      v-mess = "Уже существует такая запись конфигурации".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if not (p-table-name = 'dis-gds-rule':U
           or
           p-table-name = 'dis-cp-rule':U
           or
           p-table-name = 'dis-dc-rule':U
           or
           p-table-name = 'dis-dct-rule':U
           or
           p-table-name = 'dis-grp-rule':U
           or
           p-table-name = 'dis-thbj-rule':U
           or
           p-table-name = 'dis-some-rule':U
           ) then do:
      assign
      v-mess = substitute("Неверная таблица связи &1", p-table-name).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'table-name':U).
    end.
    if lookup(p-pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U) = 0 then do:
      assign
      v-mess = substitute("Неверное место исп скидки &1", p-pos-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'pos-type':U).
    end.
    if not can-find(first ub.dis-rule no-lock where
                        ub.dis-rule.rule-num = p-templ-rl-root)
    or p-templ-rl-root > 99999 then do:
      assign
      v-mess = substitute("Неверный шаблон скидки &1", p-templ-rl-root).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'templ-rl-root':U).
    end.
    if p-time-templ-rl-root <> 0
    and (not can-find(first ub.dis-time-rule no-lock where
                        ub.dis-time-rule.time-rule-num = p-time-templ-rl-root)
    or p-time-templ-rl-root > 99999) then do:
      assign
      v-mess = substitute("Неверный шаблон расписания &1", p-time-templ-rl-root).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'time-templ-rl-root':U).
    end.
    case p-table-name:
      when 'dis-gds-rule':U then do:
        assign
        v-discnt-role-list = 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u
        .
      end.
      when 'dis-cp-rule':U then do:
        assign
        v-discnt-role-list = 'simple-pay,qnty-pay':u
        .
      end.
      when 'dis-dc-rule':U then do:
        assign
        v-discnt-role-list = 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u
        .
      end.
      when 'dis-dct-rule':U then do:
        assign
        v-discnt-role-list = 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u
        .
      end.
      when 'dis-grp-rule':U then do:
        if p-self-nonunique = 'sum-grp':U then do:
          assign
          v-discnt-role-list = 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u
          .
        end.
        if p-self-nonunique = 'cli-grp':U then do:
          assign
          v-discnt-role-list = 'cli-grp-pcnt':u
          .
        end.
      end.
      when 'dis-some-rule':U then do:
      end.
      when 'dis-thbj-rule':U then do:
        assign
        v-discnt-role-list = 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u
        .
      end.
    end case.
    if lookup(p-discnt-role, v-discnt-role-list) = 0 then do:
      assign
      v-mess = substitute("Неверная роль скидки &1", p-discnt-role).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'discnt-role':U).
    end.
    if lookup(string(p-discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U) = 0 then do:
      assign
      v-mess = substitute("Неверный тип скидки &1", p-discnt-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'discnt-type':U).
    end.
    if lookup(string(p-subject-type), '0,1,2,3,4,5,7,8':U) = 0 then do:
      assign
      v-mess = substitute("Неверный объект воздействия скидки &1", p-subject-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'subject-type':U).
    end.
    create buf_dis-cfg-rule.
    assign
    buf_dis-cfg-rule.table-name = p-table-name
    buf_dis-cfg-rule.pos-type = p-pos-type
    buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
    buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-cfg-rule.self-nonunique = p-self-nonunique
    .
  end.
  if not (p-has-glob = 0
          or
          p-has-glob = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-glob &1", p-has-glob).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-glob':U).
  end.
  if not (p-has-host = 0
          or
          p-has-host = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-host &1", p-has-host).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-host':U).
  end.
  if not (p-has-obj = 0
          or
          p-has-obj = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-obj &1", p-has-obj).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-obj':U).
  end.
  if lookup(string(p-link-prop), '0,1,2,3,-2,-1':U) = 0 then do:
    assign
    v-mess = substitute("Неверный тип объекта приложения правила &1", p-link-prop).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'link-prop':U).
  end.
  if p-link-prop = 0
  and p-projection <> '':U then do:
    assign
    v-mess = substitute("Не надо задавать проекцию для прямого объекта приложения правила").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'projection':U).
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_dis-cfg-rule exclusive-lock where
             buf_dis-cfg-rule.table-name = p-table-name
         and buf_dis-cfg-rule.pos-type = p-pos-type
         and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
         and buf_dis-cfg-rule.self-nonunique = p-self-nonunique
         no-error.
    if buf_dis-cfg-rule.table-name <> p-table-name
    or buf_dis-cfg-rule.pos-type <> p-pos-type
    or buf_dis-cfg-rule.templ-rl-root <> p-templ-rl-root
    or buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root
    or buf_dis-cfg-rule.self-nonunique <> p-self-nonunique
    then do:
      assign
      v-mess = substitute("Для уже существующей записи конфигурации правил скидок невозможно изменение&1" +
                            "таблицы связи, места использования скидки, шаблона правила скидок, шаблона расписания и роли скидки&1" +
                            "старое значение таблицы связи, места использования скидки, шаблона  правила скидки, шаблона расписания, роли скидки, доп поля&1: &2, &3, &4, &5 и &6"
                              , chr(10)
                              , buf_dis-cfg-rule.table-name
                              , buf_dis-cfg-rule.pos-type
                              , buf_dis-cfg-rule.templ-rl-root
                              , buf_dis-cfg-rule.time-templ-rl-root
                              , buf_dis-cfg-rule.discnt-role
                              , buf_dis-cfg-rule.self-nonunique
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_dis-cfg-rule.has-glob = p-has-glob
  buf_dis-cfg-rule.has-host = p-has-host
  buf_dis-cfg-rule.has-obj = p-has-obj
  buf_dis-cfg-rule.nonunique = p-nonunique
  buf_dis-cfg-rule.discnt-role = p-discnt-role
  buf_dis-cfg-rule.link-prop = p-link-prop
  buf_dis-cfg-rule.projection = p-projection
  buf_dis-cfg-rule.discnt-type = p-discnt-type
  buf_dis-cfg-rule.subject-type = p-subject-type
  .
  p-rec = recid(buf_dis-cfg-rule).
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Запись конфигурации правил скидок:&1таблица связи &2&1" +
                         "Место использ. &3&1" +
                         "Шаблон правила &4&1" +
                         "Тип скидки &6&1" +
                         "Тип скидки &6&1"  +
                         "Шаблон расписания &5&1" +
                         "Уникальность &6&1&7"
                         ,chr(10)
                         ,p-table-name
                         ,p-pos-type
                         ,p-templ-rl-root
                         ,p-discnt-role
                         ,p-time-templ-rl-root
                         ,p-self-nonunique
                         ,p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
