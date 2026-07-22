block-level on error undo, throw.
def output parameter p-ok as log no-undo.
{ cmp/trg-def.i }
if g#news or g#esys or g#auto then p-ok = yes.
