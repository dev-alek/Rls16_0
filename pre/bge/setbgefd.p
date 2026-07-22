block-level on error undo, throw.
define input parameter p-table-name        as character    no-undo.
define input parameter p-host-code         as integer   no-undo.
define input parameter p-fin-doc-code      as integer    no-undo.
define input parameter p-corr-user-db-num  as integer no-undo .
define input parameter p-chip-num          as integer no-undo .
define input parameter p-cur-date          as date       no-undo.
define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: setbgefd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/setbgefd.p $":U .
define variable vss-description as character no-undo init "Устанавливает дату выгрузки в атрибут платежа".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6':u, p-table-name, p-host-code, p-fin-doc-code, p-corr-user-db-num, p-chip-num, p-cur-date)
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
do
on error undo, return error
:
define buffer buf_fin-doc  for ub.fin-doc.
define buffer buf_c-fin-doc     for ub.c-fin-doc.
case p-table-name:
  when "fin-doc":U  then do:
    find first buf_fin-doc exclusive-lock where
             buf_fin-doc.host-code = p-host-code
        AND  buf_fin-doc.fin-doc-code = p-fin-doc-code no-error .
      if available buf_fin-doc then assign
          buf_fin-doc.bge-date = p-cur-date
      .
   end.
   when "c-fin-doc":U then do:
    find first buf_c-fin-doc exclusive-lock where
             buf_c-fin-doc.host-code = p-host-code
        AND  buf_c-fin-doc.fin-doc-code = p-fin-doc-code
        AND  buf_c-fin-doc.corr-user-db-num = p-corr-user-db-num
        AND  buf_c-fin-doc.chip-num       = p-chip-num no-error.
      if available buf_c-fin-doc then assign
          buf_c-fin-doc.bge-date = p-cur-date
      .
   end.
  end case.
  if error-status:error then do:
    return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(32)  +  return-value ).
  end.
end.
