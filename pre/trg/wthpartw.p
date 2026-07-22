block-level on error undo, throw.
 TRIGGER PROCEDURE FOR WRITE OF ub.wth-parts NEW BUFFER Buf-New OLD BUFFER Buf-Old.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись партий номинала МЦ".
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
      p-vss-parameters = substitute('&1|&2|&3|&4'
                          ,buf-new.out-code
                          ,buf-new.wth-code
                          ,buf-new.w-p-code
                          ,buf-new.par-code
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
 define buffer buf-lin for ub.wth-line.
 define buffer buf-doc for ub.wth-doc.
 define variable v-mess     as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  IF NOT g#news  THEN DO:
     FIND FIRST buf-doc NO-LOCK WHERE
               buf-doc.doc-code = (if lookup(Buf-New.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 then buf-new.doc-code   else buf-new.out-code)
                NO-ERROR.
    IF NOT AVAIL buf-doc and lookup(Buf-New.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0   THEN DO:
      UNDO Main-Block, RETURN ERROR "Не найден документ движения МЦ с номером " + (if lookup(Buf-New.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 then buf-new.doc-code   else buf-new.out-code) .
    END.
    if new(buf-new) and lookup(Buf-New.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
    and buf-doc.status_ <> 'накл':U     then do:
      assign
      v-mess = substitute("&1 &2 &3&4" +
                          "Невозможно добавлять по документу МЦ в статусе &5&4Документ &6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,chr(10)
                          ,buf-doc.status_
                          ,buf-new.out-code).
            if not g#news then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo Main-block, return error v-mess.
    end.
  END.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'arh-wth-cli-doc':U
        , input ( buffer ub.arh-wth-cli-doc:handle )
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
