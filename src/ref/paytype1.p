block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: paytype1.p $
$Archive: ref/paytype1.p $

Процедура изменения/сохранения вида оплаты

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/05/09
Author: Dmitry Ukhanov
Creation date: 02/05/09

*/

define input-output parameter p-rid           as recid                  no-undo .
define input        parameter p-mode          as character              no-undo .
define input        parameter p-silent        as logical                no-undo .
define input        parameter p-pay-type-code like ub.pay-type.obj-code no-undo .
define input        parameter p-pay-type-name like ub.pay-type.obj-name no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: paytype1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/paytype1.p $":U .
define variable vss-description as character no-undo init "Процедура изменения/сохранения вида оплаты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_pay-type  for ub.pay-type .
  define buffer buf1_pay-type for ub.pay-type .

  define variable v-mess as character no-undo .

  if p-mode =  {&add-def}
    and p-pay-type-code = 0
  then do:
    assign
      v-mess = substitute( "Код оплаты не может быть 0." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else 'obj-code':U ).
  end.
  if p-pay-type-name = ""  then do:
    assign
      v-mess = substitute( "Наименование оплаты не может быть пустым." )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else 'obj-name':U ).
  end.

  find first buf1_pay-type no-lock
    where buf1_pay-type.obj-code = p-pay-type-code
      and recid( buf1_pay-type ) <> p-rid
    no-error .

  if available buf1_pay-type then do:
    assign
      v-mess = substitute( "Оплата с КОДОМ &1 уже существует!", p-pay-type-code )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else 'obj-code':U ).
  end.

  find first buf1_pay-type no-lock
    where buf1_pay-type.obj-name = p-pay-type-name
      and recid( buf1_pay-type ) <> p-rid
    no-error .

  if available buf1_pay-type then do:
    assign
      v-mess = substitute( 'Оплата с наименованием "&1" уже существует!', p-pay-type-name )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else 'obj-name':U ).
  end.

  if p-rid = ? then do:
    create buf_pay-type .
    assign
      p-rid = recid( buf_pay-type )
    .
  end.
  else do:
    find first buf_pay-type no-lock
      where recid( buf_pay-type ) = p-rid
      no-error .
    if not available buf_pay-type then do:
      assign
        v-mess = substitute( "Указанная оплата не найдена!" )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = yes then v-mess else '':U ).
    end.
  end.

  assign
    buf_pay-type.obj-code = p-pay-type-code
    buf_pay-type.obj-name = p-pay-type-name
    .
  release buf_pay-type no-error .
  if error-status :error then do:
    assign
      v-mess = substitute( "Ошибка при сохранении записи ВИД ОПЛАТЫ.&1&2&1&3", {&new-line}, error-status:get-message(1), return-value )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = yes then v-mess else '':U ).
  end.
end.

return '':U.

procedure err-mess:
  define input-output parameter p-mess as character no-undo.

  case p-silent:
    when true then do:
      assign
        p-mess = substitute("Сохранение изменений в карточке вида оплаты&1Код &2&1Оплата &3&1&4"
                          , {&new-line}
                          , p-pay-type-code
                          , p-pay-type-name
                          , p-mess
                          )
      .
    end.
    when false then do:
      message
        p-mess
        view-as alert-box error .
    end.
  end.
end procedure.