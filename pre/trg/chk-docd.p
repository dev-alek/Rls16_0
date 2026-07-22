block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи chk-doc".
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
define variable v-is-update as logical no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_marking-chk for ub.marking-chk.
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
    if ub.chk-doc.out-code <> ? and not g#news then
    return error substitute("Чек &1 привязан к продаже &2 - удаление невозможно"
                            , ub.chk-doc.doc-code
                            , ub.chk-doc.out-code ).
    if ub.chk-doc.out-2-code <> ? and not g#news then
    return error substitute("Чек &1 привязан к док-ту &2 - удаление невозможно"
                            , ub.chk-doc.doc-code
                            , ub.chk-doc.out-2-code).
    if not g#news then
    run trg/chk-doch.p (
                    buffer ub.chk-doc
                  ,input no
                  ,input no
                  ,input yes
                  ,input-output v-chip-num
                  ,output v-is-update
                  ).
    for each buf_chk-gds where
           buf_chk-gds.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-gds.
    end.
    for each buf_marking-chk where
           buf_marking-chk.doc-code = ub.chk-doc.doc-code :
        delete buf_marking-chk.
    end.
    for each buf_chk-pay where
           buf_chk-pay.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-pay.
    end.
    for each buf_chk-discnt where
            buf_chk-discnt.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-discnt.
    end.
    for each buf_chk-discnt-attr where
            buf_chk-discnt-attr.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-discnt-attr.
    end.
    for each buf_chk-gds-pay where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-gds-pay.
    end.
    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input 'delete':U
          , input 'chk-doc':U
          , input ( buffer ub.chk-doc:handle )
      ) no-error.
      if error-status :error
      then do:
          undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                              , chr(10)
                              , vss-workfile
                              , return-value
                              , error-status :get-message ( 1 ) ).
      end.
    end.
       run bge\send1cerp.p (?,
                    this-procedure,
                    this-procedure,
                    "delChk-doc",
                    (buffer chk-doc:handle),
                    (buffer c-chk-doc:handle),
                    ?) no-error.
       if error-status:error
       then do:
          message return-value view-as alert-box.
       end.
  end.
