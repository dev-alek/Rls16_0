block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись оснований (причин) создания документов

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create: Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.trn-reason NEW BUFFER Buf_New OLD BUFFER Buf_Old.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись оснований (причин) создания документов":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable j-reason-code like ub.trn-reason.reason-code no-undo.

define buffer buf_rsn-attr for ub.trn-rsn-attr.

  if Buf_New.reason-code <> Buf_Old.reason-code and Buf_New.reason-code <> ? and Buf_New.reason-code <> 0 and
                                                    Buf_Old.reason-code <> ? and Buf_Old.reason-code <> 0 then do:
    for each buf_rsn-attr no-lock where
             buf_rsn-attr.reason-code = Buf_Old.reason-code :
      find first ub.trn-rsn-attr exclusive-lock where
          recid( ub.trn-rsn-attr ) = recid( buf_rsn-attr ).
      assign buf_rsn-attr.reason-code = Buf_New.reason-code.
      find first ub.trn-rsn-attr        no-lock where
          recid( ub.trn-rsn-attr ) = recid( buf_rsn-attr ).

      run str/callnews.p ( input "trn-rsn-attr", input ( buffer ub.trn-rsn-attr :handle ) ) no-error.
      if error-status :error then do:
        if error-status :get-message( 1 ) <> "":U then do:
          message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                  "Ошибка при вызове процедуры callnews.p" skip
                  error-status :get-message( 1 ) skip
                  return-value skip
          view-as alert-box error.
        end.
        undo Main-Block, return error return-value.
      end.
    end. /* for each buf_rsn-attr */
  end. /* Buf_New.reason-code <> Buf_Old.reason-code */

  assign j-reason-code = ( if new( Buf_New ) then Buf_New.reason-code else Buf_Old.reason-code ).
  if g#news <> yes then do:
    create ub.c-trn-reason.
    buffer-copy Buf_Old except reason-code to ub.c-trn-reason no-error.
    if error-status :error then do: undo Main-Block, return error. end.
    assign ub.c-trn-reason.action      = integer( if new( Buf_New )                            then {&hn-create} else
                                           ( if Buf_New.reason-code = Buf_Old.reason-code then {&hn-update} else
                                                                                               {&hn-rename} ) )
           ub.c-trn-reason.reason-code         = j-reason-code
           ub.c-trn-reason.corr-date           = today
           ub.c-trn-reason.corr-time           = time
           ub.c-trn-reason.corr-user-name      = g#userid
           ub.c-trn-reason.corr-user-db-num    = g#db-num
           ub.c-trn-reason.chip-num            = next-value( s-corr-chip, {&db-name_schema} ) no-error.
    if error-status :error then do: undo Main-Block, return error. end.

    for each buf_rsn-attr no-lock where
             buf_rsn-attr.reason-code = j-reason-code :
      find first ub.trn-rsn-attr exclusive-lock where
          recid( ub.trn-rsn-attr ) = recid( buf_rsn-attr ).
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
    end. /* for each buf_rsn-attr */
  end. /* g#news <> yes */

  run str/callnews.p ( input "trn-reason", input ( buffer Buf_New :handle ) ) no-error.
  if error-status :error then do:
    if error-status :get-message( 1 ) <> "":U then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Ошибка при вызове процедуры callnews.p" skip
              error-status :get-message( 1 ) skip
              return-value skip
      view-as alert-box error.
    end.
    undo Main-Block, return error return-value.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_trn-reason}
        , input ( buffer ub.trn-reason:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.