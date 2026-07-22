block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-rsn1.p $
$Archive: ref/trn-rsn1.p $

Сохранение основания (причины) создания документа

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/06/09
Author: Dmitry Ukhanov
Creation date: 02/06/09

*/
define input-output parameter p-rid         as recid     no-undo .
define input        parameter p-mode        as character no-undo .
define input        parameter p-silent      as logical   no-undo .
define input        parameter p-reason-code like ub.trn-reason.reason-code no-undo .
define input        parameter p-reason-name like ub.trn-reason.reason-name no-undo .
define input        parameter p-PS          like ub.trn-reason.PS          no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-rsn1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/trn-rsn1.p $":U .
define variable vss-description as character no-undo init "Сохранение основания (причины) создания документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_trn-reason      for ub.trn-reason .
  define buffer next_trn-reason     for ub.trn-reason .
  define buffer buf_trn-rsn-attr    for ub.trn-rsn-attr .
  define buffer buf_trn-reason-obj  for ub.trn-reason-obj .
  define buffer buf_trn-reason-host for ub.trn-reason-host .

  define variable v-mess as character no-undo .

  if p-mode <> {&add-def}
    and p-mode <> {&update}
    and p-mode <> {&deletion}
  then do:
    assign
      v-mess = substitute( "&1 (&2). Ошибка задания входных параметров. Неверный параметр p-mode (&3).", vss-workfile, vss-revision, p-mode )
    .
    run err-mess in this-procedure ( input-output v-mess ).
    undo main-block, return error (if p-silent = true then v-mess else '':U ).
  end.


  if p-mode = {&update}
    or p-mode = {&deletion}
  then do:
    find first buf_trn-reason exclusive-lock
      where recid( buf_trn-reason ) = p-rid
      no-error .
    if not available buf_trn-reason then do:
      assign
        v-mess = substitute( "Запись основания (причины) создания документа не найдена." )
      .
      run err-mess in this-procedure ( input-output v-mess ).
      undo main-block, return error (if p-silent = true then v-mess else '':U ).
    end.
  end.

  case p-mode :
    when {&update}
    or when {&add-def}
    then do:
      if p-reason-code <= 0 then do:
        assign
          v-mess = substitute( "Код основания должен быть больше нуля." )
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else 'reason-code':U ).
      end.

      find first next_trn-reason no-lock
        where next_trn-reason.reason-code = p-reason-code
          and recid( next_trn-reason ) <> p-rid
        no-error .
      if available next_trn-reason then do:
        find first buf_trn-rsn-attr no-lock
          where buf_trn-rsn-attr.reason-code = p-reason-code
            and buf_trn-rsn-attr.attr-code   = "del":U
          no-error .
        if available buf_trn-rsn-attr then do:
          assign
            v-mess = substitute("Уже было основание с кодом &2 и было удалено.&1Повторное заведение невозможно.", {&new-line}, p-reason-code)
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = true then v-mess else 'reason-code':U ).
        end.
        else do:
          assign
            v-mess = substitute("Уже есть основание с кодом &1.", p-reason-code)
          .
          run err-mess in this-procedure ( input-output v-mess ).
          undo main-block, return error (if p-silent = true then v-mess else 'reason-code':U ).
        end.
      end.

      if trim( p-reason-name ) = "":u then do:
        assign
          v-mess = substitute("Основание (причина) не может быть пустой.")
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else 'reason-name':U ).
      end.

      find first next_trn-reason no-lock
        where next_trn-reason.reason-name = p-reason-name
          and recid( next_trn-reason ) <> p-rid
        no-error .
      if available next_trn-reason then do:
        assign
          v-mess = substitute('Уже есть основание (причина) "&1" (код &2).', next_trn-reason.reason-name, next_trn-reason.reason-code)
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else 'reason-name':U ).
      end.

      if p-mode = {&add-def} then do:
        create buf_trn-reason .
        assign
          buf_trn-reason.reason-code = p-reason-code
          p-rid                      = recid( buf_trn-reason )
        .
      end.

      assign
        buf_trn-reason.reason-name = p-reason-name
        buf_trn-reason.PS          = p-PS
      .

      release buf_trn-reason no-error .
      if error-status:error then do:
        assign
          v-mess = substitute( "&2 (&3). Ошибка при сохранении записи основания (причины) создания документа.&1&4&1&5"
                                , {&new-line}
                                , vss-workfile
                                , vss-revision
                                , error-status:get-message(1)
                                , return-value )
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else '':U ).
      end.
    end.
    when {&deletion} then do:
      find first buf_trn-reason-obj no-lock
        where buf_trn-reason-obj.reason-code = buf_trn-reason.reason-code
        no-error.
      if available buf_trn-reason-obj then do:
        assign
          v-mess = substitute('Основание (причина) используется в настройках по умолчанию на объекте &2 &3.&1Удаление не возможно.'
                              , {&new-line}
                              , buf_trn-reason-obj.obj-type
                              , buf_trn-reason-obj.obj-code
                             )
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else '':U ).
      end.
      find first buf_trn-reason-host no-lock
        where buf_trn-reason-host.reason-code = buf_trn-reason.reason-code
        no-error.
      if available buf_trn-reason-host then do:
        assign
          v-mess = substitute('Основание (причина) используется в настройках по умолчанию на фирме &2.&1Удаление не возможно.'
                              , {&new-line}
                              , buf_trn-reason-host.host-code
                             )
        .
        run err-mess in this-procedure ( input-output v-mess ).
        undo main-block, return error (if p-silent = true then v-mess else '':U ).
      end.

      find first buf_trn-rsn-attr exclusive-lock
        where buf_trn-rsn-attr.reason-code = buf_trn-reason.reason-code
          and buf_trn-rsn-attr.attr-code   = "del":U
        no-error
        .
      if not available buf_trn-rsn-attr then do:
        create buf_trn-rsn-attr.
        assign
          buf_trn-rsn-attr.reason-code = buf_trn-reason.reason-code
          buf_trn-rsn-attr.attr-code   = "del":U
        .
      end.
      assign
        buf_trn-rsn-attr.attr-value   = "yes":U
      .
    end.
  end case.
end.

return '':U .


procedure err-mess:
  define input-output parameter p-mess as character no-undo.

  case p-silent:
    when true then do:
      assign
      p-mess = substitute("Сохранение изменений в карточке основания (причины) создания документа&1"
                          + "Код основания: &2&1"
                          + "Основание: &3&1"
                          + "&4"
                         , {&new-line}
                         , p-reason-code
                         , p-reason-name
                         , p-mess)
      .
    end.
    when false then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
end procedure.