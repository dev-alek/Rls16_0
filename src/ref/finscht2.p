block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finscht2.p $
$Archive: ref/finscht2.p $

Изменение статуса банквоского счета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter p-recid as recid no-undo.
define input parameter p-silent as logical no-undo .
define input parameter p-check-option as character no-undo .
define input-output parameter p-status_ as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finscht2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finscht2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса БАНКОВСКОГО СЧЕТА".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/clntattr.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf_fin-schet for ub.fin-schet.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.fin-schet.status_ no-undo .
define variable v-err-mess as character no-undo .
define variable v1-mainholder as character no-undo .
define variable v2-mainholder as character no-undo .
define variable v1type as character no-undo .
define variable v2type as character no-undo .
define variable v-dop1 as character no-undo .


define buffer buf-db_fin-schet for ub.fin-schet.

do
on error undo, return error
:

FIND FIRST bf_fin-schet WHERE
           recid(bf_fin-schet) = p-recid No-ERROR.

if not avail bf_fin-schet then return error.

varold-status_ = bf_fin-schet.status_.
if p-status_ = ?
or p-status_ = "":U
then do:
  CASE varold-status_:
    when {&current-status} then do:
      assign
      p-status_ = {&deleted-status}.
    end.
    when {&deleted-status} then do:
      assign
      p-status_ = {&current-status}.
    end.
  END CASE.
end.

_main:
do
on error undo, return error
:

CASE p-status_:
  WHEN {&current-status} then do:
    if {&current-status} = bf_fin-schet.status_  then do:
      if not p-silent then do:
      p-status_ = "".
        v-err-mess = substitute("БАНКОВСКИЙ СЧЕТ уже имеет статус ТЕКУЩИЙ!").
        run err-mess in this-procedure ( input-output v-err-mess ).
        undo _main, return error (if p-silent then v-err-mess else "status_").
      end.
    end.
    else do:
      if not p-silent then do:
      message
      "Восстановить удаленный счет?"
      view-as alert-box question buttons yES-NO  update choice.
      end.
      else do:
        choice = yes.
      end.
      if choice then do:
        /*проверим*/
        if p-check-option <> "no-check" then do:
          for each buf-db_fin-schet where buf-db_fin-schet.host-code = bf_fin-schet.host-code and
                                            buf-db_fin-schet.r-schet   = bf_fin-schet.r-schet   and
                                            buf-db_fin-schet.code-bank = bf_fin-schet.code-bank and
                                            buf-db_fin-schet.status_   = {&current-status}
                                      :
            if buf-db_fin-schet.code-schet   = bf_fin-schet.code-schet    then next.
            run clntattr-value in this-procedure (
                                                    input bf_fin-schet.cli-type
                                                  ,input bf_fin-schet.cli-code
                                                  ,input {&attr-main-accholder}
                                                  ,output v1-mainholder
                                                  ,output v1type) no-error.
            run clntattr-value in this-procedure (
                                                    input buf-db_fin-schet.cli-type
                                                  ,input buf-db_fin-schet.cli-code
                                                  ,input {&attr-main-accholder}
                                                  ,output v2-mainholder
                                                  ,output v2type) no-error.

            if v1-mainholder = v2-mainholder
            and v1-mainholder <> '':U
            and v2-mainholder <> '':U
            and buf-db_Fin-schet.dop1 <> bf_fin-schet.dop1
            and buf-db_Fin-schet.dop1 <> '':U
            and bf_fin-schet.dop1 <> '':U
            then next.
            leave.
          end.
          if available buf-db_fin-schet then do:
            v-err-mess = substitute("Уже есть расчетный счет &1 по фирме &2 в том же банке.&3" +
                                          "Вн.номер счета: &4"
                                          , bf_fin-schet.r-schet
                                          , bf_fin-schet.host-code
                                          , {&new-line}
                                          ,buf-db_fin-schet.code-schet).
            undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
          end.
        end. /*if p-check-option <> "no-check" then do:*/
      assign
      bf_fin-schet.status_ = {&current-status} .
      end. /*if choice then do:*/
      else do:
        undo _main, return error .
      end.
    end.
  end.
  WHEN {&deleted-status} then do:
    choice = FALSE .
    if not p-silent then do:
    message "Удалить банковский счет, Вы уверены?" skip
    view-as alert-box WARNING
    buttons OK-Cancel update choice .
    end.
    else do:
      choice = yes.
    end.
    /*здесь надо вставлять проверки!!!!!!!*/
    if choice then  do:
      bf_fin-schet.status_ = {&deleted-status} .
    end.
    else do:
      undo _main, return error .
    end.
  end.
END CASE.
release bf_fin-schet no-error .
if error-status:error then do:
  v-err-mess = substitute("Ошибка при сохранении записи БАНКОВСКИЙ СЧЕТ&1&2&1&3"
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value ).
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo _main, return error (if p-silent then v-err-mess else '').
end.
p-status_ = "".
end.

end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Счет вн.№ &1: фирма: &2:&3&4"
                         , bf_fin-schet.code-schet
                         , bf_fin-schet.host-code
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
