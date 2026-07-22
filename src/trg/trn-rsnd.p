block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление оснований (причин) создания документов

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create: Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.trn-reason.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление оснований (причин) создания документов":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_rsn-attr for ub.trn-rsn-attr.
define buffer buf_trn-doc  for ub.trn-doc.
define buffer buf_rsn-host for ub.trn-reason-host.
define buffer buf_rsn-obj  for ub.trn-reason-obj.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_trn-doc no-lock where
             buf_trn-doc.reason-code = ub.trn-reason.reason-code no-error.
  if available buf_trn-doc then do:
    undo, return error substitute(
      '&1. Обоснование (причина) создания документов &2 "&3" используется в документах (&4)',
      vss-workfile, ub.trn-reason.reason-code, ub.trn-reason.reason-name, buf_trn-doc.doc-code ).
  end.
  find first buf_rsn-obj no-lock where
             buf_rsn-obj.reason-code = ub.trn-reason.reason-code no-error.
  if available buf_rsn-obj then do:
    undo, return error substitute(
      '&1. Обоснование (причина) создания документов &2 "&3" используется в настройках по умолчанию на объекте &4 &5',
      vss-workfile, ub.trn-reason.reason-code, ub.trn-reason.reason-name, buf_rsn-obj.obj-type, buf_rsn-obj.obj-code ).
  end.
  find first buf_rsn-host no-lock where
             buf_rsn-host.reason-code = ub.trn-reason.reason-code no-error.
  if available buf_rsn-host then do:
    undo, return error substitute(
      '&1. Обоснование (причина) создания документов &2 "&3" используется в настройках по умолчанию на фирме &4',
      vss-workfile, ub.trn-reason.reason-code, ub.trn-reason.reason-name, buf_rsn-host.host-code ).
  end.

  run nws/cmd-del.p ( input "trn-reason":U, input ( buffer ub.trn-reason :handle ), input "":U ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4",
                                   vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
  end.

  /* история */
  if g#news <> yes then do: /* Если история включена */
    /* создаем историю на удаление */
    create ub.c-trn-reason.
    buffer-copy ub.trn-reason to ub.c-trn-reason no-error.
    if error-status :error then do: undo, return error. end.
    assign ub.c-trn-reason.action           = integer( {&hn-delete} )
           ub.c-trn-reason.corr-date        = today
           ub.c-trn-reason.corr-time        = time
           ub.c-trn-reason.corr-user-name   = g#userid
           ub.c-trn-reason.corr-user-db-num = g#db-num
           ub.c-trn-reason.chip-num         = next-value( s-corr-chip, {&db-name_schema} ) no-error.
    if error-status :error then do: undo, return error. end.
  end. /* not g#news */

  for each buf_rsn-attr no-lock where
           buf_rsn-attr.reason-code = ub.trn-reason.reason-code :
    find first ub.trn-rsn-attr exclusive-lock where
        recid( ub.trn-rsn-attr ) = recid( buf_rsn-attr ).

    run nws/cmd-del.p ( input "trn-rsn-attr":U, input ( buffer ub.trn-rsn-attr :handle ), input "":U ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4",
                                     vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
    end.

    /* история */
    if g#news <> yes then do: /* Если история включена */
      create ub.c-trn-rsn-attr.
      buffer-copy ub.trn-rsn-attr to ub.c-trn-rsn-attr no-error.
      if error-status :error then do: undo, return error. end.
      assign ub.c-trn-rsn-attr.action           = ub.c-trn-reason.action
             ub.c-trn-rsn-attr.corr-date        = ub.c-trn-reason.corr-date
             ub.c-trn-rsn-attr.corr-time        = ub.c-trn-reason.corr-time
             ub.c-trn-rsn-attr.corr-user-name   = ub.c-trn-reason.corr-user-name
             ub.c-trn-rsn-attr.corr-user-db-num = ub.c-trn-reason.corr-user-db-num
             ub.c-trn-rsn-attr.chip-num         = ub.c-trn-reason.chip-num no-error.
      if error-status :error then do: undo, return error. end.
    end. /* not g#news */

    delete ub.trn-rsn-attr.
  end. /* for each buf_rsn-attr */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_trn-reason}
        , input ( buffer ub.trn-reason:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.