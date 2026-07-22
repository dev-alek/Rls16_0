block-level on error undo, throw.
define stream inp.
if search("./propath.txt") ne ?
then do:
   input stream inp from value("./propath.txt").
   define variable vpropath as character no-undo.
   import stream inp unformatted vpropath  no-error.
   input stream inp close.
   if vpropath ne ""
   then
      propath = vpropath.
end.
run utl/proc-async.p.
   