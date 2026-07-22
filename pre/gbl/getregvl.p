block-level on error undo, throw.
define input parameter p-section0 as character no-undo .
define input parameter p-section1 as character no-undo .
define input parameter p-section2 as character no-undo .
define input parameter p-variable as character no-undo .
define output parameter p-found  as logical no-undo .
define output parameter p-value as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getregvl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getregvl.p $":U .
define variable vss-description as character no-undo init "".
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
define variable regValueNames as char format "x(25)" no-undo.
define variable regValue as char format "x(50)" extent 100 no-undo.
define variable i as int no-undo.
define variable k as int no-undo.
do
on error undo, return error
:
  load p-section1 base-key p-section0.
  use p-section1 .
  get-key-value section p-section2
  key ""
  value regValueNames.
  if regValueNames = ""
  or regValueNames = ?
  then do:
    unload p-section1.
    return .
  end.
  assign
  p-found = yes
  .
  do i = 1 to num-entries(regValueNames):
    get-key-value section p-section2
    key entry(i,regValueNames)
    value regValue[i].
    if entry(i,regValueNames) = p-variable then do:
      assign
      p-value = regValue[i]
      .
    end.
  end.
  unload p-section1 no-error.
end.
