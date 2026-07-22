block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-tim2.p $
$Archive: ref/dis-tim2.p $

Изменение статуса расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/15/04
Author: Bakhtadze Natalya
Creation date: 09/15/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define parameter buffer bf-dis-time-rule for ub.dis-time-rule.
define input parameter p-silent as logical no-undo .
define input-output parameter par-sts like ub.dis-time-rule.sts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-tim2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-tim2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса расписаний".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/distruls.i "work" }


DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.dis-time-rule.sts no-undo .
define variable v-mess as character no-undo .
define variable v-time-rule-num like ub.dis-time-rule.time-rule-num no-undo .


_main:
do
on error undo, return error return-value
:
find current bf-dis-time-rule exclusive-lock.
if bf-dis-time-rule.lvl-num <> 0 then do:
  v-mess = substitute("РАСПИСАНИЕ №&1: невозможно изменить статус&2" +
                      "Менять статус можно только для неиспользуемых шаблонов расписаний&2"  +
                      "и расписаний уровня 1"
                      , bf-dis-time-rule.time-rule-num

                      ).
  if not p-silent then do:
    message
    v-mess
    view-as alert-box error .
  end.
  undo, return error (if p-silent then v-mess else '':U).

end.
varold-sts = bf-dis-time-rule.sts.
if par-sts = ? then do:
  CASE varold-sts:
    when integer({&current-status-int}) then do:
      assign
      par-sts = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int})
    or
    when integer({&non-root-status-int}) /*исправляем ляп fixdr.p*/
    then do:
      assign
      par-sts = integer({&current-status-int}).
    end.
  END CASE.
end.

CASE par-sts:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf-dis-time-rule.sts  then do:
      if p-silent then do:
        return .
      end.
      else do:
        message "Запись уже имеет статус ИСПОЛЬЗУЕТСЯ!"
        view-as alert-box ERROR.
        par-sts = ?.
        return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else do:
        message
        "Запись не используется - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-dis-time-rule.sts  then do:
      if p-silent then do:
        return .
      end.
      else do:
        message "Запись уже имеет статус НЕ ИСПОЛЬЗУЕТСЯ!"
        view-as alert-box ERROR.
        par-sts = ?.
        return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else do:
        message
        "Поставить статус НЕ ИСПОЛЬЗУЕТСЯ?" skip
        "Все расписания данного типа будут удалены!"
        view-as alert-box QUestion buttons yes-no update choice.
      end.
    end.
  end.
END CASE.
if choice then do:
  if bf-dis-time-rule.sts = integer({&current-status-int})
  then do:
    /*если шаблон  - то стираем правила*/
    if bf-dis-time-rule.time-rule-num <= {&max-num-dr-template} then do:
      for each BUF_dis-time-rule where
              buf_dis-time-rule.upper-time-rule-num = bf-dis-time-rule.time-rule-num:
        v-time-rule-num = buf_dis-time-rule.time-rule-num.
        run ref/dis-tim3.p (buffer buf_dis-time-rule
                       ,input no /*p-sts-mode */
                       ,input p-silent) no-error .
        if error-status:error then do:
          v-mess = substitute("Ошибка при удалении РАСПИСАНИЯ №&1&2&3&2&4"
                              , buf_dis-time-rule.time-rule-num
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value ).
          undo _main, return error (if p-silent then v-mess else '':U).
        end.
      end.
    end. /*if bf-dis-time-rule.upper-rule-num <= {&max-num-dr-template} then do:*/
  end.
  assign
  bf-dis-time-rule.sts = par-sts.
  v-time-rule-num = bf-dis-time-rule.time-rule-num.
  release bf-dis-time-rule no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении записи РАСПИСАНИЯ №&1&2&3&2&4"
                             , v-time-rule-num
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value ).
    if not p-silent then do:
      message
      v-mess
      view-as alert-box error .
    end.
    undo _main, return error (if p-silent then v-mess else '':U).
  end.
end.
par-sts = ?.
end.