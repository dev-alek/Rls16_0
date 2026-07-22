block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись оснований (причин) создания документов на фирмах по расширенным типам документов

Автор: Чернова Светлана Александровна
Дата создания: 01/17/07
Author: Svetlana Chernova
Creation date: 01/17/07

create: Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.trn-reason-host NEW BUFFER Buf_New OLD BUFFER Buf_Old.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись оснований (причин) создания документов на фирмах по расширенным типам документов":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-Block:
do transaction on error   undo Main-Block, leave Main-Block
               on end-key undo Main-Block, leave Main-Block :
  if g#news <> yes then do:
    create ub.c-trn-reason-host.
    buffer-copy Buf_Old except host-code ext-doc-type hold-doc to ub.c-trn-reason-host no-error.
    if error-status :error then do: undo Main-Block, return error. end.
    assign ub.c-trn-reason-host.action  = integer( if new( Buf_New )                              then {&hn-create} else
                                            ( if Buf_New.host-code    = Buf_Old.host-code    and
                                                 Buf_New.ext-doc-type = Buf_Old.ext-doc-type and
                                                 Buf_New.hold-doc     = Buf_Old.hold-doc     then {&hn-update} else
                                                                                                  {&hn-rename} ) )
           ub.c-trn-reason-host.host-code          = ( if new( Buf_New ) then Buf_New.host-code    else Buf_Old.host-code    )
           ub.c-trn-reason-host.ext-doc-type       = ( if new( Buf_New ) then Buf_New.ext-doc-type else Buf_Old.ext-doc-type )
           ub.c-trn-reason-host.hold-doc           = ( if new( Buf_New ) then Buf_New.hold-doc     else Buf_Old.hold-doc     )
           ub.c-trn-reason-host.corr-date          = today
           ub.c-trn-reason-host.corr-time          = time
           ub.c-trn-reason-host.corr-user-name     = g#userid
           ub.c-trn-reason-host.corr-user-db-num   = g#db-num
           ub.c-trn-reason-host.chip-num           = next-value( s-corr-chip, {&db-name_schema} ) no-error.
    if error-status :error then do: undo Main-Block, return error. end.
  end. /* g#news <> yes */

  run str/callnews.p ( input "trn-reason-host", input ( buffer Buf_New :handle ) ) no-error.
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
end. /* Main-Block */