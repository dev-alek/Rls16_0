block-level on error undo, throw.
define input        parameter p-action         as   character    no-undo .
define input        parameter p-esys-id        like ub.ext-system.esys-id no-undo .
define input        parameter p-db-num         like ub.ext-system.db-num no-undo .
define input        parameter p-delivery-method as integer   no-undo .
define input        parameter oxml-exch-dir    as character no-undo .
define input        parameter oxml-heap-dir    as character no-undo .
define output       parameter p-source-dir     as   character    no-undo .
define output       parameter p-target-dir     as   character    no-undo .
define output       parameter p-temp-dir       as   character    no-undo .
define output       parameter p-log-file-name  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Формирование для ВС имён директорий для обмена файлами".
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
function esys-id-format returns character ( input p-esys-id as integer):
  return string(p-esys-id, "99999").
end.
FUNCTION nws-db-format returns character ( input p-db-num as integer):
  define variable v-nws-db-format as character no-undo .
  assign
    v-nws-db-format = string( p-db-num,  (if p-db-num > 999 then "99999":U else "999":U ) )
  .
  return v-nws-db-format.
END FUNCTION.
  define variable v-esysid-str as character no-undo .
  define variable v-dbnum-str  as character no-undo .
  define variable v-work-dir   as character no-undo .
  assign
    v-esysid-str = esys-id-format( p-esys-id )
    v-dbnum-str  = nws-db-format( ibs.th.gbl.gbl-var:g#db-num )
  .
  case p-action :
    when "get":U
    or
    when "fget":U
    then do:
      assign
        v-work-dir   = "ES" + v-esysid-str + "-":U + v-dbnum-str
        p-temp-dir   = oxml-exch-dir + chr(92) + v-work-dir + ".":U + v-esysid-str
        p-source-dir = oxml-exch-dir + chr(92) + v-work-dir
        p-target-dir = oxml-heap-dir + chr(92) + v-work-dir
        p-log-file-name  =  (if p-delivery-method = integer('3':U)
                            then (oxml-heap-dir + chr(92) + v-dbnum-str + "-":U + "ES" + v-esysid-str)
                            else (oxml-heap-dir + chr(92) + "actions.log")
                            )
      .
    end.
    when "put":U
    or
    when "fput"
    then do:
      assign
        v-work-dir   = v-dbnum-str + "-":U + "ES" + v-esysid-str
        p-temp-dir   = oxml-exch-dir + chr(92) + v-work-dir + ".":U + v-dbnum-str
        p-source-dir = oxml-heap-dir + chr(92) + v-work-dir
        p-target-dir = oxml-exch-dir + chr(92) + v-work-dir
        p-log-file-name  =  oxml-heap-dir + chr(92) + "actions.log"
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Не предусмотрена операция" p-action "для" vss-workfile
        view-as alert-box error.
      return error.
    end.
  end case.
