block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.trn-reason-host NEW BUFFER Buf_New OLD BUFFER Buf_Old.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись оснований (причин) создания документов на фирмах по расширенным типам документов":U.
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
Main-Block:
do transaction on error   undo Main-Block, leave Main-Block
               on end-key undo Main-Block, leave Main-Block :
  if g#news <> yes then do:
    create ub.c-trn-reason-host.
    buffer-copy Buf_Old except host-code ext-doc-type hold-doc to ub.c-trn-reason-host no-error.
    if error-status :error then do: undo Main-Block, return error. end.
    assign ub.c-trn-reason-host.action  = integer( if new( Buf_New )                              then '1':U else
                                            ( if Buf_New.host-code    = Buf_Old.host-code    and
                                                 Buf_New.ext-doc-type = Buf_Old.ext-doc-type and
                                                 Buf_New.hold-doc     = Buf_Old.hold-doc     then '2':U else
                                                                                                  '9':U ) )
           ub.c-trn-reason-host.host-code          = ( if new( Buf_New ) then Buf_New.host-code    else Buf_Old.host-code    )
           ub.c-trn-reason-host.ext-doc-type       = ( if new( Buf_New ) then Buf_New.ext-doc-type else Buf_Old.ext-doc-type )
           ub.c-trn-reason-host.hold-doc           = ( if new( Buf_New ) then Buf_New.hold-doc     else Buf_Old.hold-doc     )
           ub.c-trn-reason-host.corr-date          = today
           ub.c-trn-reason-host.corr-time          = time
           ub.c-trn-reason-host.corr-user-name     = g#userid
           ub.c-trn-reason-host.corr-user-db-num   = g#db-num
           ub.c-trn-reason-host.chip-num           = next-value( s-corr-chip, ub ) no-error.
    if error-status :error then do: undo Main-Block, return error. end.
  end.
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
end.
