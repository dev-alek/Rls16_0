block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.trn-reason NEW BUFFER Buf_New OLD BUFFER Buf_Old.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись оснований (причин) создания документов":U.
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
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
    end.
  end.
  assign j-reason-code = ( if new( Buf_New ) then Buf_New.reason-code else Buf_Old.reason-code ).
  if g#news <> yes then do:
    create ub.c-trn-reason.
    buffer-copy Buf_Old except reason-code to ub.c-trn-reason no-error.
    if error-status :error then do: undo Main-Block, return error. end.
    assign ub.c-trn-reason.action      = integer( if new( Buf_New )                            then '1':U else
                                           ( if Buf_New.reason-code = Buf_Old.reason-code then '2':U else
                                                                                               '9':U ) )
           ub.c-trn-reason.reason-code         = j-reason-code
           ub.c-trn-reason.corr-date           = today
           ub.c-trn-reason.corr-time           = time
           ub.c-trn-reason.corr-user-name      = g#userid
           ub.c-trn-reason.corr-user-db-num    = g#db-num
           ub.c-trn-reason.chip-num            = next-value( s-corr-chip, ub ) no-error.
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
    end.
  end.
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
          input 'update':U
        , input 'trn-reason':U
        , input ( buffer ub.trn-reason:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
