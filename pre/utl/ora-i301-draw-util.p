block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-price-doc no-undo
field line-num as integer
field doc-date as date
field doc-num  as integer
field doc-num-ES as character
field doc-id   as character
field obj-type as character
field obj-code as integer
field cmnt     as character
index pi line-num doc-num
index pi2 doc-num
index pi3 doc-id
.
define temp-table temp-price-list no-undo
field line-num     as integer
field doc-num      as integer
field bar-code     as integer
field gds-code     as integer
field price-sale   as decimal
index pi  doc-num  line-num  bar-code
index pi2 bar-code
.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as class ibs.th.utl.method-for-draw-utility no-undo .
define input  parameter TABLE for  temp-price-doc bind.
define input  parameter TABLE for  temp-price-list bind.
define output parameter p-ok-doc as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт ДНЦ из временной таблицы".
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
run utl/ora-i301.p (parparentproc,
                this-procedure,
                input table temp-price-doc ,
                input table temp-price-list ,
                output p-ok-doc).
procedure pcall-log-file:
   define input  parameter iText as character  no-undo .
   p-log-handle:put-log(iText).
end procedure .
procedure write-log-and-file:
   define input  parameter iText as character  no-undo .
   p-log-handle:put-log(iText).
end procedure .
