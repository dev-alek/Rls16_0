block-level on error undo, throw.
define input parameter  p-doc-code      like ub.doc-line.doc-code  no-undo .
define input parameter  p-obj-type      like ub.doc-line.obj-type  no-undo .
define input parameter  p-obj-code      like ub.doc-line.obj-code  no-undo .
define input parameter  p-artic         like ub.doc-line.artic     no-undo .
define input parameter  p-prod-type     like ub.doc-line.prod-type no-undo .
define input parameter  p-prod-code     like ub.doc-line.prod-code no-undo .
define output parameter p-same-price    as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Анализ строки накладной и партий".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6':u,p-doc-code,p-obj-type,p-obj-code,p-artic,p-prod-type,p-prod-code)
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
define variable l-first-part    as logical no-undo init true .
define variable v-price-cli     like ub.parts.price-cli  no-undo .
define variable v-price-base    like ub.parts.price-base no-undo .
define variable v-price-rubl    like ub.parts.price-rubl no-undo .
define variable l-same-price    as logical no-undo init true .
for each ub.parts no-lock
  where ub.parts.out-code  = p-doc-code
    and ub.parts.obj-type  = p-obj-type
    and ub.parts.obj-code  = p-obj-code
    and ub.parts.artic     = p-artic
    and ub.parts.prod-type = p-prod-type
    and ub.parts.prod-code = p-prod-code
on error undo, return error
:
  if l-first-part then do:
    assign
      l-first-part = false
    .
    assign
      v-price-cli  = ub.parts.price-cli
      v-price-base = ub.parts.price-base
      v-price-rubl = ub.parts.price-rubl
    .
  end.
  else do:
    if ub.parts.price-cli  <> v-price-cli
    or ub.parts.price-base <> v-price-base
    or ub.parts.price-rubl <> v-price-rubl
    then do:
      assign
        l-same-price   = false
      .
    end.
  end.
end.
assign
  p-same-price    = l-same-price
.
