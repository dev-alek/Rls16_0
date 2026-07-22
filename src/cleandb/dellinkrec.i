define buffer {1} for ub.{1}.
on delete of ub.{1} override do: end.

for each {1} exclusive-lock
    {2}
on error undo, return error
:
      delete {1} no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      
      vDeleted = vDeleted + 1.
end.
