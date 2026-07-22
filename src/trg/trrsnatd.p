block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов оснований (причин) создания документов

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create : Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.trn-rsn-attr.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление атрибутов оснований (причин) создания документов":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run nws/cmd-del.p ( input "trn-rsn-attr":U, input ( buffer ub.trn-rsn-attr :handle ), input "":U ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4",
                                   vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
  end.

  /* история */
  if g#news <> yes then do: /* Если история включена */
    /* создаем историю на удаление */
    find last ub.c-trn-reason no-lock where
              ub.c-trn-reason.reason-code = ub.trn-rsn-attr.reason-code no-error.
    if not available ub.c-trn-reason then do:
      find first ub.trn-reason no-lock where
                 ub.trn-reason.reason-code = ub.trn-rsn-attr.reason-code.
      create ub.c-trn-reason.
      buffer-copy ub.trn-reason to ub.c-trn-reason no-error.
      if error-status :error then do: undo, return error. end.
      assign ub.c-trn-reason.action             = integer( {&hn-delete} )
             ub.c-trn-reason.corr-date          = today
             ub.c-trn-reason.corr-time          = time
             ub.c-trn-reason.corr-user-name     = g#userid
             ub.c-trn-reason.corr-user-db-num   = g#db-num
             ub.c-trn-reason.chip-num           = next-value( s-corr-chip, {&db-name_schema} ) no-error.
      if error-status :error then do: undo, return error. end.
    end.

    create ub.c-trn-rsn-attr.
    buffer-copy ub.trn-rsn-attr to ub.c-trn-rsn-attr no-error.
    if error-status :error then do: undo, return error. end.
    assign ub.c-trn-rsn-attr.action             = integer( {&hn-update} )
           ub.c-trn-rsn-attr.corr-date          = ub.c-trn-reason.corr-date
           ub.c-trn-rsn-attr.corr-time          = ub.c-trn-reason.corr-time
           ub.c-trn-rsn-attr.corr-user-name     = ub.c-trn-reason.corr-user-name
           ub.c-trn-rsn-attr.corr-user-db-num   = ub.c-trn-reason.corr-user-db-num
           ub.c-trn-rsn-attr.chip-num           = ub.c-trn-reason.chip-num    no-error.
    if error-status :error then do: undo, return error. end.
  end. /* not g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_trn-rsn-attr}
        , input ( buffer ub.trn-rsn-attr:handle )
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