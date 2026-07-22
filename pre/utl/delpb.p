block-level on error undo, throw.
define input  parameter p-doc-code as character no-undo .
FOR EACH BatchProcess exclusive-LOCK WHERE BP_Status <> 'd'
         and CharKey_One = p-doc-code
:
     assign     BP_Status = 'd' .
END.
