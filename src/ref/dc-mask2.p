block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dc-mask2.p $
$Archive: ref/dc-mask2.p $

Изменение статуса маски дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/17/04
Author: Bakhtadze Natalya
Creation date: 04/17/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter par-recid as recid no-undo.
define input-output parameter par-stts like ub.dis-card-mask.stts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dc-mask2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dc-mask2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса маски дисконтной карты".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/chdctmsk.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-dis-card-mask for ub.dis-card-mask.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-stts like ub.dis-card-mask.stts no-undo .
define variable v-check-by-mask  as character no-undo .
define variable v-type as character no-undo .
define variable v-ok as logical no-undo .
define variable v-stts-char as character no-undo .
define variable dc-ri as recid no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_Dis-card-mask for ub.dis-card-mask.
define buffer buf_dis-card-type for ub.dis-card-type .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.



_main:
do
on error undo, return error return-value
:

FIND FIRST bf-dis-card-mask WHERE
           recid(bf-dis-card-mask) = par-recid.
varold-stts = bf-dis-card-mask.stts.
if par-stts = ? then do:
  CASE varold-stts:
    when integer({&current-status-int}) then do:
      assign
      par-stts = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int}) then do:
      assign
      par-stts = integer({&current-status-int}).
    end.
  END CASE.
end.

CASE par-stts:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf-dis-card-mask.stts  then do:
      message "Запись уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      par-stts = ?.
      return error.
    end.
    else do:
      message
      "Запись уже удалена - восстановить?"
      view-as alert-box QUestion buttons YEs-no update choice.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-dis-card-mask.stts  then do:
      message "Запись уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      par-stts = ?.
      return error.
    end.
    else do:
      message
      "Удалить запись?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if par-stts = integer({&current-status-int}) then do:
  find first buf_dis-card-type share-lock where
            buf_dis-card-type.emitent-host-code = bf-dis-card-mask.emitent-host-code
        and buf_dis-card-type.type = bf-dis-card-mask.type
        and buf_dis-card-type.host-code = 0
        and buf_dis-card-type.obj-type = '':U
        and buf_dis-card-type.obj-code = 0 .
  if buf_dis-card-type.check-by-mask = 1 then do:
    run check-mask-correct-ho-join in this-procedure (
                                                input bf-dis-card-mask.emitent-host-code
                                                ,input bf-dis-card-mask.type
                                                ,input bf-dis-card-mask.mask
                                                ,input bf-dis-card-mask.host-code
                                                ,input bf-dis-card-mask.obj-type
                                                ,input bf-dis-card-mask.obj-code
                                                ,output v-ok
                                                            ) no-error .
    if error-status:error then do:
       message
       substitute("Нельзя восстановить маску:&1&2 &3"
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value
                              ).
       undo, return error .
    end.
    if not v-ok  then do:
      message
      substitute("Нельзя восстановить маску &1:&2&3"
                             , bf-dis-card-mask.mask
                             , {&new-line}
                             , return-value
                             )
      view-as alert-box error .
      undo, return error .
    end.
  end.
end.

assign
bf-dis-card-mask.stts = par-stts.
if bf-dis-card-mask.cli-code <> 0 then do:
  find first buf_dis-card no-lock where
            buf_dis-card.d-card = bf-dis-card-mask.mask  no-error .
  if available buf_dis-card then do:
    for each buf_dis-card-mask no-lock where
            buf_Dis-card-mask.mask = bf-dis-card-mask.mask:
      if recid(buf_dis-card-mask) = recid(bf-dis-card-mask) then next.
      if varold-stts = integer({&deleted-status-int})
      and buf_dis-card-mask.stts <> integer({&current-status-int}) then next.
      if varold-stts = integer({&current-status-int})
      and buf_dis-card-mask.stts <> integer({&current-status-int}) then next.
      leave.
    end.
    if not available buf_dis-card-mask then do:
      /*нет никакой другой карты-маски которая имеет такуж же маску*/
      CASE par-stts:
        when integer({&deleted-status-int}) then do:
          v-stts-char = {&deleted-status}.
        end.
        when integer({&current-status-int}) then do:
          v-stts-char = {&current-status}.
        end.
      END CASE.
      assign
      v-stts-char = v-stts-char + {&delim-par} + string(yes)
      dc-ri = recid(buf_dis-card).
      run ref/dcardi01.p (
                     input parparentproc
                    ,input this-procedure
                    ,input ?
                    ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                    ,input ?    /*p-silent*/
                    ,input-output dc-ri
                    ,input {&update}
                    ,input '':U /*par-mode2*/
                    ,input "":U /*p-curr-obj-type*/
                    ,input 0    /*p-curr-obj-code*/
                    ,input bf-dis-card-mask.mask
                    ,input bf-dis-card-mask.emitent-host-code
                    ,input bf-dis-card-mask.cli-type
                    ,input bf-dis-card-mask.cli-code
                    ,input v-stts-char
                    ,input bf-dis-card-mask.type
                    ,input buf_dis-card.d-pcnt
                    ,input buf_dis-card.cash-d-pcnt
                    ,input buf_dis-card.category
                    ,input buf_dis-card.d-pcnt-method
                    ,input buf_dis-card.credit-card
                    ,input buf_dis-card.lim-kr
                    ,input buf_dis-card.debet-card
                    ,input buf_dis-card.staff-card
                    ,input buf_dis-card.issue-date
                    ,input buf_dis-card.issue-code
                    ,input buf_dis-card.valid-from
                    ,input buf_dis-card.valid-date
                    ,input buf_dis-card.sourced-card
                    ,input buf_dis-card.cli-message
                    ,input yes /*mask-card*/
                    ,input buf_Dis-card.main-card
                    ,input buf_Dis-card.is-subsid
                    ,INPUT no /*p-update-property*/
                    ,INPUT table tt0-dis-card-property
                      ) no-error.
      if error-status:error then do:
        message
        "Ошибка при сохранении записи КАРТЫ-МАСКИ" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo _main, return error.
      end.
    end. /*if not available buf_dis-card-mask*/
  end. /*add-def dis-card*/
end.

release bf-dis-card-mask no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи МАСКА ДИСКОНТНОЙ КАРТЫ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.

par-stts = ?.
end.