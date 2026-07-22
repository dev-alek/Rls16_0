block-level on error undo, throw.
define input  parameter p-doc like ub.ord-doc.doc-code no-undo .
define output parameter p-db  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-db.p $":U .
define variable vss-description as character no-undo init "Список номеров БД по по поставкам".
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
define variable  p-db1  as character no-undo .
define variable  p-db2  as character no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer b_clients  for ub.clients .
define buffer c_clients  for ub.clients .
main-block :
do on error undo main-block, return error
:
p-db  = "" .
p-db1 = "0".
p-db2 = "0" .
find first buf_ord-doc no-lock where  buf_ord-doc.doc-code  = p-doc  .
      find first b_clients  no-lock where  b_clients.obj-type = buf_ord-doc.obj-type and
                                           b_clients.obj-code = buf_ord-doc.obj-code  .
      if available b_clients then
                    p-db1 = string(b_clients.db-num) .
                    else
                    p-db1 = "0" .
          find first c_clients  no-lock where  c_clients.obj-type = buf_ord-doc.cli-type and
                                               c_clients.obj-code = buf_ord-doc.cli-code  .
          if available c_clients then
              p-db2 = string(c_clients.db-num) .
              else
              p-db2 = "0" .
  if g#db-num = 0 then do:
    case buf_ord-doc.status_ :
      when 'запрос':U then do:
         p-db = p-db2 .
      end.
      when 'разрешено':U then do:
         p-db = p-db1 .
      end.
      when 'отгружено':U then do:
         p-db = p-db1 .
      end.
      when 'факт':U then do:
         p-db = p-db2 .
      end.
    end case.
  end.
  else do:
    p-db = "0" .
  end.
  if g#db-num = integer(p-db) then p-db = "".
 end.
