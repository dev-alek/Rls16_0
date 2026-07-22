block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: taxvali2.p $
$Archive: ref/taxvali2.p $

Изменение статуса значения ставки налога

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

define input parameter par-recid as recid no-undo.
define input parameter p-silent as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: taxvali2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/taxvali2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса значения ставки налога".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE is-found as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-mess as character no-undo .
DEFINE BUFFER bf_tax-rate-value for tax-rate-value.
DEFINE BUFFER buf_tax-rate-value for tax-rate-value.

FIND FIRST bf_tax-rate-value WHERE
           recid(bf_tax-rate-value) = par-recid No-ERROR.
if not avail bf_tax-rate-value then return error.
loc#log = no.

CASE bf_tax-rate-value.status_:
  when {&current-status} then do:
    if not p-silent then do:
      message "Вы действительно хотите выключить (логически) запись о значении ставки налога?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
    else do:
      loc#log = yes.
    end.
  end.
  when {&deleted-status} then do:
    if not p-silent then do:
      message "Запись о значении ставки налога уже (логически) выключена" skip
      "Восстановить?"
      view-as alert-box QUESTION buttons YES-NO
      update loc#log.
  end.
    else do:
      loc#log = yes.
    end.
  end.
  otherwise do:
      BELL.
      return error.
  end.
END CASE.

if not loc#log then return error.
/*а можно ли вообще удалять логически - проверим*/
/*нельзя удалить фирму если магазинам не на что будет ссылаться*/

do
on error undo, return error
:

if bf_tax-rate-value.status_ = {&current-status} then do:
  if bf_tax-rate-value.host-code > 0 and
     bf_tax-rate-value.obj-type = '':U and
     bf_tax-rate-value.obj-code = 0
      then do:
    if can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
                      buf_tax-rate-value.fact-order > bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type <> '':U and
                      buf_tax-rate-value.obj-code <> 0 and
                      buf_tax-rate-value.status_ = {&current-status})
       AND
       Not can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
                      buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = {&current-status}) then do:
      v-mess = substitute("Чтобы логически удалить значение ставки по фирме&1"  +
              "сначала удалите логически значения ставок по объектам данной фирмы с более поздней датой действия"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
  end. /*фирма*/
  if bf_tax-rate-value.host-code = 0 and
     bf_tax-rate-value.obj-type = '':U and
     bf_tax-rate-value.obj-code = 0
      then do:
    if can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code <> 0 AND
                      buf_tax-rate-value.fact-order > bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = {&current-status})
       AND
       Not can-find(first buf_tax-rate-value No-LOCK WHERE
                      buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                      buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                      buf_tax-rate-value.host-code = 0 AND
                      buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                      buf_tax-rate-value.obj-type = '':U and
                      buf_tax-rate-value.obj-code = 0 and
                      buf_tax-rate-value.status_ = {&current-status}) then do:
      v-mess = substitute("Чтобы логически удалить глобальное значение ставки&1" +
              "сначала удалите логически значения ставок по фирмам с более поздней датой действия"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    /*проверить что не остались товары с такой ставкой*/
    if not can-find (first buf_tax-rate-value No-LOCK WHERE
                           buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                           buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                           buf_tax-rate-value.status_ = {&current-status} AND
                           buf_tax-rate-value.host-code = 0 AND
                           buf_tax-rate-value.obj-type = '':U AND
                           buf_tax-rate-value.obj-code = 0 AND
                           buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                           recid(buf_tax-rate-value) <> recid(bf_tax-rate-value)) AND
      can-find( first ub.tax-rate-gds No-LOCK WHERE
                      ub.tax-rate-gds.tax-code = bf_tax-rate-value.tax-code AND
                      ub.tax-rate-gds.rate-code = bf_tax-rate-value.rate-code AND
                      ub.tax-rate-gds.fact-order <= bf_tax-rate-value.fact-order AND
                      ub.tax-rate-gds.fact-date <= v-today ) then do:
      /*это последняя значение ставки для кого-то*/
      v-mess = substitute("Нельзя удалить последнее значение ставки&1"  +
              "имеются товары с такой ставкой"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'salience':U).
    end.
  end. /*глобально*/
end.

if bf_tax-rate-value.status_ = {&current-status} then do:
  FIND FIRST buf_tax-rate-value No-LOCK WHERE
             buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
             buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
             buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
             buf_tax-rate-value.obj-type  = bf_tax-rate-value.obj-type AND
             buf_tax-rate-value.obj-code = bf_tax-rate-value.obj-code AND
             buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
             buf_tax-rate-value.status_ = {&current-status} AND
             recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
  if not avail buf_tax-rate-value then do:
    FIND FIRST buf_tax-rate-value No-LOCK WHERE
              buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
              buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
              buf_tax-rate-value.host-code = bf_tax-rate-value.host-code AND
              buf_tax-rate-value.obj-type  = "":U AND
              buf_tax-rate-value.obj-code = 0 AND
              buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
              buf_tax-rate-value.status_ = {&current-status} AND
              recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
    if not avail buf_tax-rate-value then dO:
      FIND FIRST buf_tax-rate-value No-LOCK WHERE
                buf_tax-rate-value.tax-code = bf_tax-rate-value.tax-code AND
                buf_tax-rate-value.rate-code = bf_tax-rate-value.rate-code AND
                buf_tax-rate-value.host-code = 0 AND
                buf_tax-rate-value.obj-type  = "":U AND
                buf_tax-rate-value.obj-code = 0 AND
                buf_tax-rate-value.fact-order <= bf_tax-rate-value.fact-order AND
                buf_tax-rate-value.status_ = {&current-status} AND
                recid(buf_tax-rate-value) <> recid(bf_tax-rate-value) No-ERROR.
      if avail buf_tax-rate-value then
      is-found = yes.
    end.
    else is-found = yes.
  end.
  else is-found = yes.

end.
if not is-found and bf_tax-rate-value.status_ = {&current-status} then do:
  if not p-silent then do:
  message "При логическом удалении данного значения ставки" SKIP
          "не останется ни одного действующего значения по данной ставке"
          "Вы все еще хотите удалить значение ставки?"
  view-as alert-box QUESTION buttons YES-NO update loc#log.
  if not loc#log then
  return error.
end.
end.



assign
bf_tax-rate-value.status_ = (if bf_tax-rate-value.status_ = {&deleted-status}
                            then {&current-status}
                            else {&deleted-status}).
release bf_tax-rate-value no-error .
if error-status:error then do:
  v-mess = substitute("Ошибка при сохранении записи ЗНАЧЕНИЕ СТАВКИ НАЛОГА&1&2&1&3"
           , {&new-line}
           ,  error-status:get-message(1)
           , return-value).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else 'salience':U).
end.

end. /*doe*/

procedure err-mess:
define input-output parameter p-mess as character no-undo.

  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Вкл/Выключ ЗНАЧЕНИЯ ставки налога&1"
                          + "Тип ставки &2&1"
                          + "Код ставки &3&1"
                          + "Код фирмы &4&1"
                          + "Объект &5 &6&1"
                          + "Дата включениия &7&1"
                          + "&8"
                         , {&new-line}
                         , buf_tax-rate-value.tax-code
                         , buf_tax-rate-value.rate-code
                         , buf_tax-rate-value.host-code
                         , buf_tax-rate-value.obj-type
                         , buf_tax-rate-value.obj-code
                         , buf_tax-rate-value.fact-date
                         , p-mess)
      .
    end.
    when no then do:
  message
      p-mess
  view-as alert-box error .
end.
  end.
end procedure.