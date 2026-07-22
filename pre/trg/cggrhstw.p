block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-grp-hist.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на главную запись истории ГРУПП ТОВАРОВ".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7'
                           ,  ub.c-gds-grp-hist.node-code
                           , ub.c-gds-grp-hist.corr-user-db-num
                           , ub.c-gds-grp-hist.chip-num
                           , ub.c-gds-grp-hist.host-code
                           , ub.c-gds-grp-hist.obj-type
                           , ub.c-gds-grp-hist.obj-code
                           , ub.c-gds-grp-hist.subject
                           )
    .
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
on write of ub.c-gds-grp-hist override do: end.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ub.c-gds-grp-hist.subject = 'gds-grp':U
  and (ub.c-gds-grp-hist.corr-user-db-num = 0
      or
      ub.c-gds-grp-hist.corr-user-db-num = g#db-num)
  and ub.c-gds-grp-hist.node-code <> 0
  then do:
    find last buf_c-gds-grp-hist where
          buf_c-gds-grp-hist.node-code = 0
      AND buf_c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-hist.corr-user-db-num
      AND buf_c-gds-grp-hist.host-code = 0
      AND buf_c-gds-grp-hist.obj-type = '':U
      AND buf_c-gds-grp-hist.obj-code = 0
      AND buf_c-gds-grp-hist.subject = ub.c-gds-grp-hist.subject no-error.
    if not available buf_c-gds-grp-hist then do:
      create buf_c-gds-grp-hist.
      assign
      buf_c-gds-grp-hist.host-code = 0
      buf_c-gds-grp-hist.obj-type = '':U
      buf_c-gds-grp-hist.obj-code = 0
      buf_c-gds-grp-hist.subject = ub.c-gds-grp-hist.subject
      .
    end.
    buffer-copy
    ub.c-gds-grp-hist
    except
    node-code
    host-code
    obj-type
    obj-code
    to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code = 0
    .
  end.
  if
  not g#news
  then do:
    run str/callnews.p
      (input "c-gds-grp-hist"
      ,input (buffer ub.c-gds-grp-hist:handle)
      ).
 end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-gds-grp-hist':U
        , input ( buffer ub.c-gds-grp-hist:handle )
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
