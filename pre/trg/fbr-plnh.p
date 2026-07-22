block-level on error undo, throw.
define parameter buffer oldb for ub.fbr-pln.
define parameter buffer newb for ub.fbr-pln.
do
on error undo, return error
:
end.
