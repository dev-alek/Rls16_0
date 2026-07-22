block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-rul2.p $
$Archive: ref/dis-rul2.p $

Изменение статуса правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define parameter buffer bf-dis-rule for ub.dis-rule.
define input parameter p-silent as logical no-undo .
define input parameter p-pos-type as character no-undo .
define input-output parameter par-sts like ub.dis-rule.sts no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса правил скидок".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/disrules.i "work" }
{ gbl/waitfram.i }

DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.dis-rule.sts no-undo .
define variable v-rule-num like ub.dis-rule.rule-num no-undo .
define variable v-mess as character no-undo .
define variable v-recid as recid no-undo .
define variable v-can as logical no-undo .

define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
_main:
do
on error undo, return error return-value
:
find current bf-dis-rule exclusive-lock.
if bf-dis-rule.lvl-num > 1
or bf-dis-rule.upper-rule-num > {&max-num-dr-template} then do:
  v-mess = substitute("Правило скидки №&1: невозможно изменить статус&2" +
                      "Менять статус можно только для неиспользуемых шаблонов скидок&2"  +
                      "и правил скидок уровня 1"
                      , bf-dis-rule.rule-num
                      ).
  if not p-silent then do:
    message
    v-mess
    view-as alert-box error .
  end.
  undo, return error (if p-silent then v-mess else '':U).
end.
varold-sts = bf-dis-rule.sts.
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
    if integer({&current-status-int}) = bf-dis-rule.sts  then do:
      if p-silent then do:
        return ''.
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
      else  do:
        message
        "Запись не используется - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-dis-rule.sts  then do:
      if p-silent then do:
        return ''.
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
        "Поставить статус НЕ ИСПОЛЬЗУЕТСЯ?" skip(0)
        (if bf-dis-rule.rule-num <= {&max-num-dr-template}
        then "Все правила скидок данного типа будут удалены!"
        else  '':U)
        view-as alert-box QUestion buttons yes-no update choice.
      end.
    end.
  end.
END CASE.
if choice then do:
  if bf-dis-rule.sts = integer({&current-status-int})
  and bf-dis-rule.rule-num <= {&max-num-dr-template}
  then do:
    /*если шаблон  - то стираем правила*/
      for each BUF_dis-rule where
              buf_dis-rule.upper-rule-num = bf-dis-rule.rule-num:
        v-rule-num = buf_dis-rule.rule-num.
        run ref/dis-rul3.p (
                        buffer buf_dis-rule
                       ,input no /*p-sts-mode */
                       ,input p-silent
                       ,output v-can
                       ) no-error .
      if error-status:error
      or not v-can
      then do:
          v-mess = substitute("Ошибка при удалении ПРАВИЛА СКИДОК №&1&2&3&2&4"
                              , buf_dis-rule.rule-num
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
    end. /*if bf-dis-rule.upper-rule-num <= {&max-num-dr-template} then do:*/
  end.
  else do:
    /*проверим возможность выключения*/
    CASE par-sts:
      when integer({&deleted-status-int}) then do:
        run ref/dis-rul3.p (
                       buffer bf-dis-rule
                      ,input yes
                      ,input yes /*p-silent*/
                      ,output v-can
                      ) no-error.
      end.
      when integer({&current-status-int}) then do:
        v-recid = recid(bf-dis-rule).
        v-can = yes.
        if p-pos-type = ''
        or p-pos-type = ? then do:
          run ref/dcr-pos.p (
                             input {&update}
                            ,input p-silent
                            ,input bf-dis-rule.templ-rl-root
                            ,input bf-dis-rule.host-code
                            ,input bf-dis-rule.obj-type
                            ,input bf-dis-rule.obj-code
                            ,input par-sts
                            ,input bf-dis-rule.rule-num
                            ,output p-pos-type) no-error.
          if error-status:error then do:
            v-mess = substitute("Ошибка при определении места действия ПРАВИЛА СКИДОК №&1&2&3&2&4"
                                    , v-rule-num
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
        run ref/dis-rul1.p (
                       input bf-dis-rule.rule-num /* p-rule-num */
                      ,input p-pos-type
                      ,input bf-dis-rule.templ-rl-root
                      ,input bf-dis-rule.templ-rl-root
                      ,input bf-dis-rule.des
                      ,input bf-dis-rule.dis-kat
                      ,input bf-dis-rule.discnt-type
                      ,input bf-dis-rule.doc-qnty
                      ,input bf-dis-rule.tot-sum
                      ,input bf-dis-rule.charkey_one
                      ,input bf-dis-rule.charkey_two
                      ,input bf-dis-rule.charkey_three
                      ,input bf-dis-rule.deckey_one
                      ,input bf-dis-rule.deckey_two
                      ,input bf-dis-rule.deckey_three
                      ,input bf-dis-rule.key#_one
                      ,input bf-dis-rule.key#_two
                      ,input bf-dis-rule.key#_three
                      ,input bf-dis-rule.subject-type
                      ,input bf-dis-rule.TIME-TEMPL-RL-ROOT
                      ,input bf-dis-rule.time-rule-num
                      ,input bf-dis-rule.upper-rule-num
                      ,input bf-dis-rule.value-type
                      ,input bf-dis-rule.host-code
                      ,INPUT bf-dis-rule.obj-type
                      ,INPUT bf-dis-rule.obj-code
                      ,INPUT bf-dis-rule.discnt-value
                      ,input table tt0-term_dis-rule
                      ,input-output v-recid
                      ,input {&update} + {&delim-par} + 'sts'
                      ,input yes /*p-silent*/
                      ) no-error.
      end.
    END CASE.
    if error-status:error
    or not v-can
    then do:
      v-mess = substitute("ПРАВИЛО СКИДОК №&1 не может быть выключено/выключено &2&3&2&4"
                            , bf-dis-rule.rule-num
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
  assign
  bf-dis-rule.sts = par-sts.
  v-rule-num = bf-dis-rule.rule-num.
  release bf-dis-rule no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении записи ПРАВИЛА СКИДОК №&1&2&3&2&4"
                             , v-rule-num
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
  if par-sts = integer({&deleted-status-int}) then do:
    for each buf_dis-thbj-rule exclusive-lock where
            buf_dis-thbj-rule.rule-num = v-rule-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_dis-thbj-rule.
    end.
  end.
end.
par-sts = ?.
end.