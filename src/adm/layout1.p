block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: layout1.p $
$Archive: adm/layout1.p $

Сохранение раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-layout-id as character no-undo .
define input parameter        p-layout-type as character no-undo .
define input parameter        p-device-type as character no-undo .
define input parameter        p-layout-name as character no-undo .
define input parameter        p-is-default as integer no-undo .
define input  parameter       p-des as character no-undo .
define temp-table tt-rule-by-call no-undo like ub.rule-by-call.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-by-call.
define temp-table tt-layout-elem-rule no-undo like ub.layout-elem-rule.
DEFINE INPUT PARAMETER TABLE FOR tt-layout-elem-rule.
define temp-table tt-rule-call-param no-undo like ub.rule-call-param.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-call-param.



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layout1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layout1.p $":U .
define variable vss-description as character no-undo init "Сохранение раскладки".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i }
{ trg/layouth.i }
define variable v-admin as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
define variable v-last-id-int as integer no-undo .
define variable v-layout-id as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rbc-uniq-key-rec as character no-undo .
define variable v-call#-id as integer no-undo .
define variable v-cmp as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_layout for ub.layout.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_layout-elem  for ub.layout-elem.
define buffer buf2_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule for ub.rule.
if lookup('admin', p-mode) > 0 then do:
  v-admin = yes.
  p-mode = trim(replace(p-mode, 'admin', ''), {&comma-char}).
end.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0
and (p-is-default = integer({&layout-default})
     or
     p-is-default = integer({&layout-mandatory}))

then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено в УБД редактировать дефолтные и обязательные раскладки"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_layout
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup(string(p-is-default), {&layout-kind-codes}) = 0 then do:
    assign
    v-mess = substitute("Неверное значение параметра p-is-default=&1", p-is-default).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'is-default':U).
  end.
  if p-layout-name = '' then do:
    assign
    v-mess = substitute("Не задано название раскладки").
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else 'layout-name':U).
  end.
  if p-mode = {&add-def} then do:
    if p-is-default = integer({&layout-ordinal}) then do:
      v-last-id-int = next-value(s-layout-id, {&db-name_schema}).
      if g#db-num = 0 then do:
        v-layout-id = substitute("&1", string(v-last-id-int)).
      end.
      else do:
        v-layout-id = substitute("&1-&2", string(v-last-id-int), g#db-num).
      end.
    end. /*if p-is-default = {&layout-ordinal} then do:*/
    else do:  /*для администрирования из IBS */
      if p-is-default = integer({&layout-mandatory}) then do:
        if can-find(first ub.layout no-lock where
                         ub.layout.layout-type = p-layout-type
                      and ub.layout.device-type = p-device-type) then do:
          assign
          v-mess = substitute("Уже существует обязательная раскладка с типом &1 для &2"
                             , p-layout-type
                             , p-device-type
                             ).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
     _do:
      do v-ii = 9 to 1 by -1:
        find last buf_layout no-lock where
               buf_layout.layout-id >= substitute("_1&1"
                                                   ,fill("0", v-ii - 1)
                                                   )
             and buf_layout.layout-id <= substitute("_&1"
                                                   ,fill("9", v-ii)
                                                   )
                 no-error.
        if available buf_layout then do:
          v-last-id-int = integer(left-trim(entry(1, buf_layout.layout-id), "_")).
          leave _do.
        end.
        else do:
          next _do.
        end.
      end.
      v-layout-id = substitute("_&1", string(v-last-id-int + 1)).
    end.
    find first buf_layout no-lock where
              buf_layout.layout-id = v-layout-id no-error .
    if available buf_layout then do:
      assign
      v-mess = substitute("Уже существует раскладка c id = &1", v-layout-id).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if lookup( entry(1, p-layout-type, "_") , {&layout-type-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный тип раскладки &1", p-layout-type).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else 'layout-type':U).
    end.
    case p-layout-type:
      WHEN {&th-pos-keyboard}  THEN DO:
        if lookup(p-device-type, {&th-pos-device-keyboard-list}) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else 'device-type':U).
        end.
      END.
      WHEN {&th-pos-screen}  THEN DO:
        if lookup(p-device-type, {&th-pos-device-screen-list}) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else 'device-type':U).
        end.
      END.
    end case.
    create buf_layout.
    assign
    buf_layout.layout-type = p-layout-type
    buf_layout.layout-id = v-layout-id
    buf_layout.device-type = p-device-type
    buf_layout.des = p-des
    .
  end.
  if p-mode = {&update} then do:
    v-layout-id = p-layout-id.
    find first buf_layout exclusive-lock where
              recid(buf_layout) = p-rec .
    if buf_layout.layout-type <> p-layout-type
    or buf_layout.device-type <> p-device-type
    or buf_layout.layout-id <> p-layout-id
    then do:
      assign
      v-mess = substitute("Для уже существующей расладки невозможно измененить тип раскладки, тип устройства, идентификатор раскладки&1"
                              , {&new-line}
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  run  layouth_create-layout_h  in this-procedure (
                                                  input p-mode
                                                 ,input v-layout-id
                                                 ,buffer buf_layout
                                                 ,output v-chip-num).
  assign
  buf_layout.is-default = p-is-default
  buf_layout.layout-name = p-layout-name
  p-rec = recid(buf_layout)
  .
  if p-is-default = integer({&layout-ordinal})
  or p-is-default = integer({&layout-default})
  then do:
    find first buf2_layout share-lock where
              buf2_layout.layout-type = p-layout-type
          and buf2_layout.device-type = p-device-type
          and buf2_layout.is-default = integer({&layout-mandatory}) no-error.
  end.
  for each buf_tt-layout-elem-rule:
    /*проверим корректность*/
    find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = {&wi-mode-IBS-TH-pos}
          and buf_wi-mode.mode-id = buf_tt-layout-elem-rule.mode-id no-error.
    if not available buf_wi-mode then do:
      v-mess = substitute("Не найден режим &1 для элемента раскладки &2"
                          , buf_tt-layout-elem-rule.mode-id
                          , buf_tt-layout-elem-rule.widget-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
     find first buf_layout-elem no-lock where
              buf_layout-elem.layout-type = p-layout-type
          and buf_layout-elem.device-type = p-device-type
          and buf_layout-elem.mode-id = buf_tt-layout-elem-rule.mode-id
          and buf_layout-elem.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
    if not available buf_layout-elem then do:
      v-mess = substitute("Не найден элемент раскладки &1 для режима &2"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_layout-elem.elem-type = integer({&lelem-type-nonprogrammable}) then do:
      v-mess = substitute("Элемент раскладки &1 для режима &2 является НЕПРОГРАММИРУЕМЫМ"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    /*а вдруг этот элемент теперь обязательный а у нас он занят чем-то другим*/
    if available buf2_layout then do:
      find first buf2_layout-elem-rule no-lock where
                buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
            and buf2_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
            and buf2_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
      if available buf2_layout-elem-rule
      and buf2_layout-elem-rule.rule_id <> buf_tt-layout-elem-rule.rule_id then do:
        find first buf_rule no-lock where buf_rule.rule_id = buf2_layout-elem-rule.rule_id no-error.
        v-mess = substitute("Элемент раскладки &1 для режима &2 является ОБЯЗАТЕЛЬНЫМ&3с привязанным к нему правилом &4"
                          , buf_tt-layout-elem-rule.widget-id
                          , buf_tt-layout-elem-rule.mode-id
                          , {&new-line}
                          , (if available buf_rule then buf_rule.name else string(buf2_layout-elem-rule.rule_id))
                                                    ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).

      end.
    end.

    find first buf_tt-rule-by-call where
              buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec no-error .
    if not available buf_tt-rule-by-call then do:
      /*но вообще не должно быть такого*/
      message
      substitute("Внутренняя ошибка - не найдена точка вызова для &1", buf_tt-layout-elem-rule.uniq-key-rec)
      view-as alert-box error .
      undo _main, return error .
    end.
    assign
    buf_tt-layout-elem-rule.layout-id = v-layout-id.
    run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                        ,input (buffer  buf_tt-layout-elem-rule:handle)
                                        ,output v-uniq-key-rec).
    for each buf_tt-rule-call-param where
            buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
        and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
        and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
        and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id:
      assign
      buf_tt-rule-call-param.call_id = v-uniq-key-rec.
    end.
    assign
    buf_tt-layout-elem-rule.uniq-key-rec = v-uniq-key-rec
    buf_tt-rule-by-call.call_id = v-uniq-key-rec
    .
  end.
  for each buf2_layout-elem-rule no-lock where
          buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
  on error  undo, return error:
    find first buf_tt-layout-elem-rule where
              buf_tt-layout-elem-rule.layout-id = v-layout-id
        and buf_tt-layout-elem-rule.mode-id = buf2_layout-elem-rule.mode-id
        and buf_tt-layout-elem-rule.widget-id = buf2_layout-elem-rule.widget-id no-error.
    if not available buf_tt-layout-elem-rule
    or buf_tt-layout-elem-rule.rule_id <> buf2_layout-elem-rule.rule_id then do:
      v-mess = substitute("Не найден ОБЯЗАТЕЛЬНЫЙ элемент раскладки &1 для режима &2"
                          , buf2_layout-elem-rule.mode-id
                          , buf2_layout-elem-rule.widget-id
                                                    ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    assign
    buf_tt-layout-elem-rule.is-mandatory = integer({&layout-elem-rule-mandatory})
    .
  end.
  for each buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.layout-id = v-layout-id
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_tt-rule-by-call where
              buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec.
     find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
          and buf_wi-mode.mode-id = buf_tt-layout-elem-rule.mode-id no-error.
     if not available buf_wi-mode then do:
       v-mess = substitute("Не найден режим работы &1", buf_tt-layout-elem-rule.mode-id).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
     end.
     find first buf_rule-by-call share-lock where
              buf_rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
          and buf_rule-by-call.codex_id = buf_wi-mode.codex_id
          and buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
          and buf_rule-by-call.order_id = 0 no-error.
     v-cmp = yes.
     if not available buf_rule-by-call then do:
       run rul/g-callid.p (
                           input (if p-is-default = integer({&layout-ordinal})
                                  then {&table_layout-elem-rule}
                                  else {&table_layout-elem-rule} + {&comma-char} + "minus")
                          ,input buf_tt-layout-elem-rule.uniq-key-rec
                          ,output v-call#-id).
       create buf_rule-by-call.
       assign
       buf_rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       buf_rule-by-call.call#_id = v-call#-id
       buf_rule-by-call.codex_id = buf_wi-mode.codex_id
       buf_rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
       buf_rule-by-call.order_id = 0
       .
       run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                          ,input (buffer  buf_rule-by-call:handle)
                                          ,output v-rbc-uniq-key-rec).
       buf_rule-by-call.uniq-key-rec = v-rbc-uniq-key-rec.
       v-cmp = no.
     end.
     else do:
       buffer-compare buf_rule-by-call to buf_tt-rule-by-call
       case-sensitive
       save result in v-cmp.
       v-call#-id = buf_rule-by-call.call#_id.
     end.
     if not v-cmp then do:
       buffer-copy buf_tt-rule-by-call
       except call_id call#_id codex_id ruleset_id uniq-key-rec
       to buf_rule-by-call.
     end.
     v-cmp = yes.
     find first buf_layout-elem-rule share-lock where
              buf_layout-elem-rule.layout-id = v-layout-id
          and buf_layout-elem-rule.mode-id = buf_tt-layout-elem-rule.mode-id
          and buf_layout-elem-rule.widget-id = buf_tt-layout-elem-rule.widget-id no-error.
     if not available buf_layout-elem-rule then do:
       create buf_layout-elem-rule.
       assign
       buf_layout-elem-rule.layout-id = v-layout-id
       v-cmp = no.
     end.
     else do:
        buffer-compare buf_layout-elem-rule to buf_tt-layout-elem-rule
        case-sensitive
        save result in v-cmp.
     end.
     if not v-cmp then do:
        run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                        input (if new(buf_layout-elem-rule)
                                                               then {&add-def}
                                                               else {&update})
                                                      ,input buf_tt-layout-elem-rule.layout-id
                                                      ,input buf_tt-layout-elem-rule.mode-id
                                                      ,input buf_tt-layout-elem-rule.widget-id
                                                      ,buffer buf_layout-elem-rule
                                                      ,input v-chip-num).
       buffer-copy buf_tt-layout-elem-rule
       except layout-id cr-db-num
       to buf_layout-elem-rule.
     end.
     for each buf_tt-rule-call-param where
              buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        v-cmp = yes.
        find first buf_rule-call-param share-lock where
              buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
          and buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index no-error.
      if not available(buf_rule-call-param) then do:
       create buf_rule-call-param.
       assign
       buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
       buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
       buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
       buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
       buf_rule-call-param.param-name = buf_tt-rule-call-param.param-name
       buf_rule-call-param.p-index = buf_tt-rule-call-param.p-index
       buf_rule-call-param.call#_id = v-call#-id
       v-cmp = no
       .
      end.
      else do:
         buffer-compare buf_rule-call-param to buf_tt-rule-call-param
         case-sensitive
         save result in v-cmp.
      end.
      if not v-cmp then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input (if new(buf_rule-call-param)
                                                               then {&add-def}
                                                               else {&update})
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_tt-rule-call-param.codex_id
                                                      ,input buf_tt-rule-call-param.ruleset_id
                                                      ,input buf_tt-rule-call-param.order_id
                                                      ,input buf_tt-rule-call-param.param-name
                                                      ,input buf_tt-rule-call-param.p-index
                                                      ,input buf_tt-rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        buffer-copy buf_tt-rule-call-param
        except call_id call#_id codex_id ruleset_id order_id param-name p-index
        to buf_rule-call-param.
      end.
    end. /*     for each buf_tt-rule-call-param where*/
     for each buf_rule-call-param where
              buf_rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_rule-call-param.order_id = buf_tt-rule-by-call.order_id
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        find first buf_tt-rule-call-param share-lock where
              buf_tt-rule-call-param.call_id = buf_tt-rule-by-call.call_id
          and buf_tt-rule-call-param.codex_id = buf_tt-rule-by-call.codex_id
          and buf_tt-rule-call-param.ruleset_id = buf_tt-rule-by-call.ruleset_id
          and buf_tt-rule-call-param.order_id = buf_tt-rule-by-call.order_id
          and buf_tt-rule-call-param.param-name = buf_rule-call-param.param-name
          and buf_tt-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
      if not available(buf_tt-rule-call-param) then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input {&deletion}
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).

        delete buf_rule-call-param.
      end.
    end. /*     for each buf_tt-rule-call-param where*/
  end. /*  for each buf_tt-layout-elem-rule where*/
  for each buf_layout-elem-rule share-lock where
          buf_layout-elem-rule.layout-id = v-layout-id
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
     find first buf_tt-layout-elem-rule where
              buf_tt-layout-elem-rule.layout-id = buf_layout-elem-rule.layout-id
          and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
          and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
    if not available buf_tt-layout-elem-rule then do:
      find first buf_rule-by-call share-lock where
                buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec no-error.
      for each buf_rule-call-param where
                buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input {&deletion}
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).

        delete buf_rule-call-param.
      end. /*for each buf_tt-rule-call-param where*/
      if available buf_rule-by-call then do:
        delete buf_rule-by-call.
      end.
      run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                      input {&deletion}
                                                    ,input buf_layout-elem-rule.layout-id
                                                    ,input buf_layout-elem-rule.mode-id
                                                    ,input buf_layout-elem-rule.widget-id
                                                    ,buffer buf_layout-elem-rule
                                                    ,input v-chip-num).

      delete buf_layout-elem-rule.
    end. /*if not available buf_tt-layout-elem-rule then do:*/
  end. /*  for each buf_layout-elem-rule share-lock where*/
  find first buf_layout-elem-rule no-lock where
           buf_layout-elem-rule.layout-id = buf_layout.layout-id
       and buf_layout-elem-rule.sts <> integer({&current-status-int}) no-error.
  if not available buf_layout-elem-rule
  and buf_layout.sts <> integer({&to-delete-status-int})
  then do:
    buf_layout.sts = integer({&current-status-int}).
  end.
  assign
  buf_layout.whole-send-news = 1
  .
  release buf_layout no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении шапки раскладки:&1&2&1&3"
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.

end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Раскладка: тип &1 id &2 для устройства &3:&4&5"
                         , p-layout-type
                         , p-layout-id
                         , p-device-type
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.