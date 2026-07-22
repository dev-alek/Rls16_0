block-level on error undo, throw.
{ gbl/sys-time.i }
define output parameter OPID               as int64 no-undo.
define output parameter oComputerName      as character no-undo.
define output parameter oComputerLoginName as character no-undo.
run sys-time_get-comp-user-name in this-procedure
    (output oComputerName
    ,output oComputerLoginName
    ,output OPID
    ) .