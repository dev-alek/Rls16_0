block-level on error undo, throw.
define input  parameter  p-doc-code as character no-undo .
on write of ub.trn-doc         override do: end.
find first ub.trn-doc exclusive-lock
     where ub.trn-doc.doc-code = p-doc-code no-error .
     if error-status :error then do:
         message
           error-status :get-message(1) skip
           return-value skip
           ""
           view-as alert-box error
         .
         return .
     end.
  assign
    ub.trn-doc.hold-doc-code-child = "no-hold"
    ub.trn-doc.hold-doc-code-parent = "no-hold"
  .
 message 'все' view-as alert-box information .
