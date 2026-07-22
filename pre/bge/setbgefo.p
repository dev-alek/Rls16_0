block-level on error undo, throw.
on write of ub.fin-ob-attr override do: end.
define input parameter p-table-name        as character    no-undo.
define input parameter p-host-code         as integer   no-undo.
define input parameter p-doc-code          as character no-undo .
define input parameter p-corr-user-db-num  as integer no-undo .
define input parameter p-chip-num          as integer no-undo .
define input parameter p-cur-date          as date       no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: setbgefo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/setbgefo.p $":U .
define variable vss-description as character no-undo init "Устанавливает дату выгрузки в атрибут ФО".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6':u, p-table-name, p-host-code, p-doc-code, p-corr-user-db-num, p-chip-num, p-cur-date)
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
procedure create-fin-ob-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-ob-attr.host-code  no-undo .
define input parameter p-doc-code      like ub.fin-ob-attr.doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-ob-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-ob-attr.attr-value no-undo .
define buffer buf_fin-ob-attr for ub.fin-ob-attr.
find first buf_fin-ob-attr  exclusive-lock  where
  buf_fin-ob-attr.attr-code    = p-attr-code    and
  buf_fin-ob-attr.host-code    = p-host-code    and
  buf_fin-ob-attr.doc-code     = p-doc-code  no-error .
  if not available  buf_fin-ob-attr then do:
      create buf_fin-ob-attr.
      assign
        buf_fin-ob-attr.attr-code    = p-attr-code
        buf_fin-ob-attr.attr-value   = p-attr-value
        buf_fin-ob-attr.host-code    = p-host-code
        buf_fin-ob-attr.doc-code     = p-doc-code
      .
  end.
  else do:
        buf_fin-ob-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure view-fin-ob-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-ob-attr.host-code    no-undo .
define input  parameter p-doc-code     like ub.fin-ob-attr.doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-ob-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-ob-attr.attr-value   no-undo .
define buffer buf_fin-ob-attr for ub.fin-ob-attr.
find first buf_fin-ob-attr no-lock where
  buf_fin-ob-attr.attr-code    = p-attr-code    and
  buf_fin-ob-attr.doc-code      = p-doc-code      no-error .
  if available  buf_fin-ob-attr then do:
      assign
        p-attr-value = buf_fin-ob-attr.attr-value
      .
  end.
  else do:
        p-attr-value = ? .
  end.
 end.
end procedure.
do
on error undo, return error
:
define buffer buf_fin-ob-attr  for ub.fin-ob-attr.
case p-table-name:
  when "fin-ob":U  then do:
    run create-fin-ob-attr  in this-procedure (
                                                 input p-host-code
                                                ,input p-doc-code
                                                ,input 'bge-date':U
                                                ,input string(p-cur-date, "99/99/9999")
                                              ) no-error .
   end.
  end case.
  if error-status:error then do:
    return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description + chr(32)  +  return-value ).
  end.
end.
