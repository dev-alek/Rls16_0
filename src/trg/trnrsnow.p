block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись оснований (причин) создания документов на объектах по расширенным типам документов

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create: Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.trn-reason-obj NEW BUFFER Buf_New OLD BUFFER Buf_Old.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись оснований (причин) создания документов на объектах по расширенным типам документов":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#news <> yes then do:
    create ub.c-trn-reason-obj.
    buffer-copy Buf_Old except obj-type obj-code ext-doc-type hold-doc to ub.c-trn-reason-obj no-error.
    if error-status :error then do: undo Main-Block, return error. end.
    assign ub.c-trn-reason-obj.action       = integer( if new( Buf_New )                              then {&hn-create} else
                                            ( if Buf_New.obj-type     = Buf_Old.obj-type     and
                                                 Buf_New.obj-code     = Buf_Old.obj-code     and
                                                 Buf_New.ext-doc-type = Buf_Old.ext-doc-type and
                                                 Buf_New.hold-doc     = Buf_Old.hold-doc     then {&hn-update} else
                                                                                                  {&hn-rename} ) )
           ub.c-trn-reason-obj.obj-type            = ( if new( Buf_New ) then Buf_New.obj-type     else Buf_Old.obj-type     )
           ub.c-trn-reason-obj.obj-code            = ( if new( Buf_New ) then Buf_New.obj-code     else Buf_Old.obj-code     )
           ub.c-trn-reason-obj.ext-doc-type        = ( if new( Buf_New ) then Buf_New.ext-doc-type else Buf_Old.ext-doc-type )
           ub.c-trn-reason-obj.hold-doc            = ( if new( Buf_New ) then Buf_New.hold-doc     else Buf_Old.hold-doc     )
           ub.c-trn-reason-obj.corr-date           = today
           ub.c-trn-reason-obj.corr-time           = time
           ub.c-trn-reason-obj.corr-user-name      = g#userid
           ub.c-trn-reason-obj.corr-user-db-num    = g#db-num
           ub.c-trn-reason-obj.chip-num            = next-value( s-corr-chip, {&db-name_schema} ) no-error.
    if error-status :error then do: undo Main-Block, return error. end.
  end. /* g#news <> yes */

  run str/callnews.p ( input "trn-reason-obj", input ( buffer Buf_New :handle ) ) no-error.
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
        , input {&table_trn-reason-obj}
        , input ( buffer ub.trn-reason-obj:handle )
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