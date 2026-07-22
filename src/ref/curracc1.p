block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: curracc1.p $
$Archive: ref/curracc1.p $

Создание/заведение курса валют ММВБ

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/10/09
Author: Dmitry Ukhanov
Creation date: 02/10/09

*/

define input-output parameter p-rid    as recid no-undo .
define input        parameter p-mode   as character no-undo .
define input        parameter p-silent as logical   no-undo .
define input        parameter p-curr-code   like ub.curr-accnt.curr-code  no-undo .
define input        parameter p-exch-date   like ub.curr-accnt.exch-date  no-undo .
define input        parameter p-exch-rate   like ub.curr-accnt.exch-rate  no-undo .
define input        parameter p-exch-scale  like ub.curr-accnt.exch-scale no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: curracc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/curracc1.p $":U .
define variable vss-description as character no-undo init "Создание/заведение курса валют ММВБ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_currency    for ub.currency .
  define buffer curr_curr-accnt for ub.curr-accnt .
  define buffer buf_curr-accnt  for ub.curr-accnt .

  define variable v-mess  as character no-undo .
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  if p-mode <> {&add-def}
    and p-mode <> {&update}
  then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр p-mode (&3).", vss-workfile, vss-revision, p-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.

  find first buf_currency exclusive-lock
    where buf_currency.curr-code = p-curr-code
    no-error .
  if not available buf_currency then do:
    assign
      v-mess = substitute( "&1 (&2). Валюта с кодом &3 не найдена.", vss-workfile, vss-revision, p-curr-code )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.

  if p-mode = {&add-def} then do:
    find first buf_curr-accnt exclusive-lock
      where buf_curr-accnt.curr-code = p-curr-code
        and buf_curr-accnt.exch-date = p-exch-date
      no-error .
    if available buf_curr-accnt then do:
      assign
        v-mess = substitute( "Уже задан курс &1 на &2.", buf_currency.curr-abbr, p-exch-date )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
    create curr_curr-accnt.
    assign
      curr_curr-accnt.curr-code = p-curr-code
      curr_curr-accnt.exch-date = p-exch-date
    .
  end.
  else do:
    find first curr_curr-accnt exclusive-lock
      where recid( curr_curr-accnt ) = p-rid
      no-error .
    if not available curr_curr-accnt then do:
      assign
        v-mess = substitute( "Не найден курс &2.&1Изменение невозможно.", {&new-line}, buf_currency.curr-abbr )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ).
  if curr_curr-accnt.exch-date < v-today
  then do:
    assign
      v-mess = substitute( "Разрешается редактировать курс начиная только с текущей даты!" )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.

  assign
    curr_curr-accnt.exch-rate  = p-exch-rate
    curr_curr-accnt.exch-scale = p-exch-scale
    p-rid                      = recid( curr_curr-accnt )
  .

  release curr_curr-accnt no-error .
  if error-status :error then do:
    assign
      v-mess = substitute( "&2 (&3). Ошибка при сохранении курса ММВБ.&1&4&1&5"
                         , {&new-line}
                         , vss-workfile
                         , vss-revision
                         , error-status:get-message(1)
                         , return-value
                         )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.

  return '':U.

end.

procedure err-mess:
  define input-output parameter p-mess as character no-undo.

  case p-silent:
    when yes then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке КУРСА ММВБ&1"
                          + "Код валюты &2&1"
                          + "Дата курса &3&1"
                          + "Курс валюты &4&1"
                          + "Масштаб &5&1"
                          + "&6"
                         , {&new-line}
                         , p-curr-code
                         , p-exch-date
                         , p-exch-rate
                         , p-exch-scale
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