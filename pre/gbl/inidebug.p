block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inidebug.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/inidebug.p $":U .
define variable vss-description as character no-undo init "".
define variable v-test as integer no-undo .
DEBUGGER:INITIATE().
DEBUGGER:VISIBLE = TRUE.
DEBUGGER:SET-BREAK().
assign
  v-test = v-test + 1
.
