block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tare02.p $
$Archive: ref/tare02.p $

Изменение статуса тары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/09
Author: Bakhtadze Natalya
Creation date: 09/30/09

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter par-recid as recid no-undo.
define input parameter p-silent as logical no-undo .
define input-output parameter p-stts like ub.tare.stts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tare02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/tare02.p $":U .
define variable vss-description as character no-undo init "Изменение статуса тары".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-tare for ub.tare.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-stts like ub.tare.stts no-undo .
define variable v-mess as character no-undo .

&scop status-code string(bf_tare.stts)

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  FIND FIRST bf-tare WHERE
            recid(bf-tare) = par-recid.
  varold-stts = bf-tare.stts.
  if p-stts = ? then do:
    CASE varold-stts:
      when integer({&current-status-int}) then do:
        assign
        p-stts = integer({&deleted-status-int}).
      end.
      when integer({&deleted-status-int}) then do:
        assign
        p-stts = integer({&current-status-int}).
      end.
    END CASE.
  end.

  CASE p-stts:
    WHEN integer({&current-status-int}) then do:
      if integer({&current-status-int}) = bf-tare.stts  then do:
  &scop status-code string(p-stts)
        v-mess = substitute("Запись уже имеет статус &1!", {&status-int-name}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent then v-mess else '':U).
      end.
      else do:
        if p-silent = no then do:
          message
          "Запись уже удалена - восстановить?"
          view-as alert-box QUestion buttons YEs-no update choice.
        end.
      end.
    end.
    WHEN integer({&deleted-status-int}) then do:
      if integer({&deleted-status-int}) = bf-tare.stts  then do:
        v-mess = substitute("Запись уже имеет статус &1!", {&status-int-name}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent then v-mess else '':U).
      end.
      else do:
        if p-silent = no then do:
          message
          "Удалить запись?"
          view-as alert-box QUestion buttons yes-no update choice.
        end.
      end.
    end.
  END CASE.
  if choice then
  assign
  bf-tare.stts = p-stts.
  release bf-tare no-error .
  if error-status:error then do:
    v-mess =  substitute("Ошибка при сохранении записи ТАРЫ&1&2&1&3"
                            , {&new-line}
                              ,error-status:get-message(1)
                              , return-value).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent then v-mess else '':U).
  end.
  p-stts = ?.
end.

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("Правило №&1&2&3"
                           , p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
