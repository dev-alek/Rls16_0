block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: layoute1.p $
$Archive: adm/layoute1.p $

Сохранение элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-layout-type as character no-undo .
define input parameter        p-device-type as character no-undo .
define input parameter        p-mode-id as character no-undo .
define input parameter        p-widget-id as character no-undo .
define input parameter        p-widget-type as character no-undo .
define input parameter        p-elem-type as integer no-undo .
define input parameter        p-des as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layoute1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layoute1.p $":U .
define variable vss-description as character no-undo init "Сохранение элемента  раскладки".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-mess as character no-undo .
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_layout for ub.layout.
define buffer buf_wi-mode for ub.wi-mode.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0
then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено в УБД редактировать элементы раскладок"
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_layout-elem
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_layout-elem no-lock where
              buf_layout-elem.layout-type = p-layout-type
          and buf_layout-elem.device-type = p-device-type
          and buf_layout-elem.mode-id = p-mode-id
          and buf_layout-elem.widget-id = p-widget-id  no-error .
    if available buf_layout-elem then do:
      assign
      v-mess = substitute("Уже существует элемент раскладки c типом = &1 для устройства &2 режима &3 с идентификатором &4", p-layout-type, p-device-type, p-mode-id, p-widget-id).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if lookup( entry(1, p-layout-type, "_") , {&layout-type-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный тип раскладки &1", p-layout-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    case p-layout-type:
      WHEN {&th-pos-keyboard}  THEN DO:
        if lookup(p-device-type, {&th-pos-device-keyboard-list}) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else '':U).
        end.
      END.
      WHEN {&th-pos-screen}  THEN DO:
        if lookup(p-device-type, {&th-pos-device-screen-list}) = 0 then do:
          assign
          v-mess = substitute("Неверный тип устройства &1 для раскладки &2"
                            , p-device-type
                            , p-layout-type).
          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else '':U).
        end.
      END.
    end case.
    create buf_layout-elem.
    assign
    buf_layout-elem.layout-type = p-layout-type
    buf_layout-elem.device-type = p-device-type
    buf_layout-elem.mode-id = p-mode-id
    buf_layout-elem.widget-id = p-widget-id
    .
  end.
  if p-layout-type = {&th-pos-keyboard}
  or p-layout-type = {&th-pos-screen} then do:
    find first buf_wi-mode no-lock where
              buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
          and buf_wi-mode.mode-id = p-mode-id no-error.
    if not available buf_wi-mode then do:
      assign
      v-mess = substitute("Неверный режим = &1", p-mode-id
                              , {&new-line}
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'mode-id':U).
    end.
  end.
  if lookup(p-widget-type, "BUTTON") = 0 then do:
      assign
      v-mess = substitute("Неверный тип элемента = &1", p-widget-type
                              , {&new-line}
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'widget-type':U).

  end.
  if lookup(string(p-elem-type), {&lelem-type-codes}) = 0 then do:
    assign
    v-mess = substitute("Неверный тип элемента = &1", p-elem-type
                            , {&new-line}
                            )
    .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'widget-type':U).
  end.
  if p-mode = {&update} then do:
    find first buf_layout-elem exclusive-lock where
              recid(buf_layout-elem) = p-rec .
    if buf_layout-elem.layout-type <> p-layout-type
    or buf_layout-elem.device-type <> p-device-type
    or buf_layout-elem.mode-id <> p-mode-id
    or buf_layout-elem.widget-id <> p-widget-id
    then do:
      assign
      v-mess = substitute("Для уже существующего элемента расладки невозможно измененить тип раскладки, тип устройства, режим, идентификатор элемента&1"
                              , {&new-line}
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-elem-type = integer({&lelem-type-nonprogrammable}) then do:
      for each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.mode-id = p-mode-id
          and buf_layout-elem-rule.widget-id = p-widget-id
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_layout share-lock where
                 buf_layout.layout-id = buf_layout-elem-rule.layout-id
             and buf_layout.layout-type = buf_layout-elem.layout-type
             and buf_layout.device-type = buf_layout-elem.device-type no-error.
        if available buf_layout
        and (buf_layout.is-default = integer({&layout-ordinal})
             or
             buf_layout.is-default = integer({&layout-default})
             )
        then do:
          assign
          v-mess = substitute("Элемент имеет тип НЕПРОГРАММИРУЕМЫЙ, но он фигурирует в раскладке &1&2Сохранение невозможно"
                                  , buf_layout-elem-rule.layout-id
                                  , {&new-line}
                                  )
          .
          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else 'elem-type':U).
        end.
      end. /*      for each buf_layout-elem-rule no-lock where*/
    end. /*if p-elem-type = integer({&lelem-type-nonprogrammable}) then do:*/
  end. /*if p-mode = {&update} then do:*/
  assign
  buf_layout-elem.des = p-des
  buf_layout-elem.widget-type = p-widget-type
  buf_layout-elem.elem-type = p-elem-type
  p-rec = recid(buf_layout-elem)
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Элемент раскладки: тип &1 для устройства &2 режим &3 идентификатор &4:&5&6"
                         , p-layout-type
                         , p-device-type
                         , p-mode-id
                         , p-widget-id
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