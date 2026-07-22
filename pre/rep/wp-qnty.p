block-level on error undo, throw.
define input  parameter p-in-sum as decimal    no-undo.
define output parameter p-out-sum  as character  no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wp-qnty.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wp-qnty.p $":U .
define variable vss-description as character no-undo init "ѕечать числа словами".
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
do
on error undo, return error
:
    assign
        p-out-sum = "":U
    .
    run gbl/num-rus.p (
          input absolute( p-in-sum )
        , output p-out-sum
    ).
    assign
        p-out-sum = trim( caps( substring( p-out-sum, 1, 1 ) ) ) + substring( p-out-sum, 2 )
    .
    assign
        p-out-sum = ( if p-in-sum < 0 then "- ":U else "":U )
                    + trim( p-out-sum )
                    + ( if substring( string( absolute( p-in-sum ), "999999999999999.999":U ), 17, 3 )  <> "000":U
                        then ( " целых "
                                + substring( string( absolute( p-in-sum ), "999999999999999.999":U ), 17, 3 )
                                + " тыс€чных" )
                        else "":U  )
    .
end.
