block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 441f77397fde, 2803, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: ѕт июл 23 16:27:15 2021 +0300 $":U .
define variable vss-Workfile    as character no-undo init "$Workfile: updateCliAttr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/updateCliAttr.p $":U .
define variable vss-description as character no-undo init "”даление повтор€ющихс€ значений атрибута" .
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
define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = encode(string(iKey * 13)) + string(index(encode(string(iKey)), "k"))
 .
   return.
end.
define buffer buf_clients-attr for ub.clients-attr .
      define variable ii as integer no-undo .
      define variable jj as integer no-undo .
      define variable kk as integer no-undo .
for each buf_clients-attr exclusive-lock where buf_clients-attr.attr-code = 'tank-farm-for':U:
      if num-entries (buf_clients-attr.attr-value,",") > 1 then
      do:
         kk = num-entries (buf_clients-attr.attr-value,",") .
         do ii = 1 to kk:
            jj = ii + 1 .
            if jj <= kk then
            do:
               if entry(ii,buf_clients-attr.attr-value,",") = entry(jj,buf_clients-attr.attr-value,",") then
               do:
                  buf_clients-attr.attr-value = replace (buf_clients-attr.attr-value,(entry(ii + 1, buf_clients-attr.attr-value, ",") + ","),"") .
                  if num-entries (buf_clients-attr.attr-value,",") < 2 then do:
                  release buf_clients-attr .
                  leave .
                  end.
                  release buf_clients-attr .
               end.
            end.
         end.
      end.
end.
