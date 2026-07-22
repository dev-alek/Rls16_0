block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dcardi02.p $
$Archive: ref/dcardi02.p $

Изменение статуса дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

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
define input parameter p-silent                       as logical no-undo .
define input parameter p-has-right-to-restore         as logical no-undo .
define input parameter p-mode2    as character no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input-output parameter par-status_ as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi02.p $":U .
define variable vss-description as character no-undo init "Изменение статуса дисконтной карты".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ trg/discardh.i }
{ gbl/cur-time.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-dis-card for ub.dis-card.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.dis-card.status_ no-undo .
define variable v-mess as character no-undo .
define variable v-dop-d-card as character no-undo .
define variable ii as integer no-undo .


define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card for ub.dis-card.

_main:
do
on error undo, return error return-value
:

FIND FIRST bf-dis-card exclusive-lock WHERE
           recid(bf-dis-card) = par-recid No-ERROR.


if not avail bf-dis-card then return error.
if bf-dis-card.status_ = {&nonused-status}
or bf-dis-card.status_ = {&chown-status} then do:
  v-mess = substitute("Нельзя изменять карту в статусе &1", bf-dis-card.status_).
  run err-mess in this-procedure ( input-output v-mess).
end.


varold-status_ = bf-dis-card.status_.
IF {&deleted-status} =  bf-dis-card.status_ then do:
    if par-status_ = {&deleted-status} then do:
       return.
    end.
    if not p-has-right-to-restore then do:
      v-mess = substitute("У Вас нет прав на изменение статуса удаленной карты!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    find first buf_dis-card no-lock where
              buf_dis-card.sourced-card = bf-dis-card.d-card no-error.
    if available buf_Dis-card then do:
      v-mess = substitute("К данной карте имеется перевыпущенная карта - восстановление запрещено").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
end.


CASE par-status_:
  WHEN {&current-status} then do:
    if {&current-status} = bf-dis-card.status_  then do:
      v-mess = substitute("Карта уже имеет статус ТЕКУЩИЙ!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    else do:
      assign
      v-dop-d-card = left-trim(bf-dis-card.d-card, "0") .
      DO II = 1  to (19 - length(v-dop-d-card)) + 1:
        if can-find(first ub.dis-card no-lock where
                        ub.dis-card.d-card = v-dop-d-card
                        and ub.dis-card.status_ <> {&deleted-status}
                        and ub.dis-card.d-card <> bf-dis-card.d-card
                        ) then do:
          assign
          v-mess = substitute("Уже есть глобальная НЕУДАЛЕННАЯ дисконтная карта&1 с номером &2 - совпадает с &3 с точностью до лидирующих нулей"
                      , (if bf-dis-card.emitent-host-code = 0
                        then "":U
                        else substitute(" на фирме &1", bf-dis-card.emitent-host-code))
                        ,v-dop-d-card
                        ,bf-dis-card.d-card
                        ).
          run err-mess in this-procedure ( input-output v-mess).
          par-status_ = "":U.
          undo _main, return error (if p-silent then v-mess else '':U).
        end.
        assign
        v-dop-d-card = "0" + v-dop-d-card
        .
      end.
      assign
       choice = yes.
    end.
  end.
  WHEN {&blocked-status} then do:
    if {&blocked-status} = bf-dis-card.status_   then do:
      v-mess = substitute("Карта уже блокирована!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    else do:
      if not p-silent then do:
        choice = FALSE .
        message "На блокированной карте не будут автоматически пересчитываться скидки." skip
                "Продолжить ?"
        view-as alert-box WARNING
        buttons OK-Cancel update choice .
      end.
      else do:
        choice = yes.
      end.
    end.
  end.
  WHEN {&deleted-status} then do:
   if not p-silent then do:
      choice = FALSE .
      message substitute("ВЫ уверены, что хотите удалить карту &1?&2"
                         , bf-dis-card.d-card
                         , {&new-line}
                        )
      view-as alert-box WARNING
      buttons OK-Cancel update choice .
    end.
    else do:
      choice = yes.
    end.
  end.
END CASE.
if not choice then do:
  v-mess = substitute("Отмена пользователем при изменении статуса ДИСКОНТНОЙ КАРТЫ").
  run err-mess( input-output v-mess).
  undo _main, return error (if p-silent then v-mess else '':U).
end.
if choice then do:
  run ref/dcardi01.p (
                 input parparentproc
                ,input this-procedure
                ,input ?
                ,input ? /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
                ,input no /*p-silent*/
                ,input-output par-recid
                ,input {&update}
                ,input p-mode2 /*par-mode2*/
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input bf-dis-card.d-card
                ,input bf-dis-card.emitent-host-code
                ,input bf-dis-card.cli-type
                ,input bf-dis-card.cli-code
                ,input par-status_ + {&delim-par} + string(if p-has-right-to-restore then yes else no)
                ,input bf-dis-card.type
                ,input bf-dis-card.d-pcnt
                ,input bf-dis-card.cash-d-pcnt
                ,input bf-dis-card.category
                ,input bf-dis-card.d-pcnt-method
                ,input bf-dis-card.credit-card
                ,input bf-dis-card.lim-kr
                ,input bf-dis-card.debet-card
                ,input bf-dis-card.staff-card
                ,input bf-dis-card.issue-date
                ,input bf-dis-card.issue-code
                ,input bf-dis-card.valid-from
                ,input bf-dis-card.valid-date
                ,input bf-dis-card.sourced-card
                ,input bf-dis-card.cli-message
                ,input bf-dis-card.mask-card
                ,input bf-dis-card.main-card
                ,input bf-dis-card.is-subsid
                ,INPUT no /*v-update-property*/
                ,INPUT table tt0-dis-card-property
                 ) no-error .

end.
if error-status:error then do:
  v-mess = substitute("Ошибка при удалении ДИСКОНТНОЙ КАРТЫ&1&2&3&4"
                           ,error-status:get-message(1)
                           , {&new-line}
                           ,return-value
                           ,{&new-line}).
  run err-mess in this-procedure ( input-output v-mess).
  undo _main, return error (if p-silent then v-mess else '':U).
end.
par-status_ = "".
end.

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("Карта №&1: эмитент: &2 тип: &3&4&5"
                           , bf-dis-card.d-card
                           , bf-dis-card.emitent-host-code
                           , bf-dis-card.type
                           , {&new-line}
                           , p-mess
                           ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.