block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.c-varianty-delivery-gds-obj.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Òğèããåğ íà óäàëåíèå â òàáëèöå ÈÑÒÎĞÈß ÂÀĞÈÀÍÒÎÂ ÄÎÑÒÀÂÊÈ ÄËß ÒÎÂÀĞÀ ÍÀ ÎÁÚÅÊÒÅ".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7'
                                       , ub.c-varianty-delivery-gds-obj.gds-code
                                       , ub.c-varianty-delivery-gds-obj.obj-type
                                       , ub.c-varianty-delivery-gds-obj.obj-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-type-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-subj-code
                                       , ub.c-varianty-delivery-gds-obj.corr-user-db-num
                                       , ub.c-varianty-delivery-gds-obj.chip-num
                                        )
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
main-block :
do transaction
on error undo main-block, return error return-value
:
  message
  vss-workfile vss-revision vss-description skip
  "Íåëüçÿ óäàëÿòü çàïèñü ÈÑÒÎĞÈÈ ÂÀĞÈÀÍÒÎÂ ÄÎÑÒÀÂÊÈ ÄËß ÒÎÂÀĞÀ ÍÀ ÎÁÚÅÊÒÅ"
  view-as alert-box error .
  undo main-block, return error .
end.
