block-level on error undo, throw.

on write of ub.thbj-attr override do: end.
on write of ub.place-attr override do: end.

define buffer buf_thbj-attr for ub.thbj-attr .

find first sys-ctrl no-lock no-error.
if not avail sys-ctrl
or sys-ctrl.db-num eq 0
then 
  return
.

for each buf_thbj-attr exclusive-lock where buf_thbj-attr.prop-code = "sec-fields" :
  if lookup("pasp-dens", buf_thbj-attr.property-value-character) > 0 then next .
  if trim(buf_thbj-attr.property-value-character) = ""
  then buf_thbj-attr.property-value-character = "pasp-dens" .
  else buf_thbj-attr.property-value-character = buf_thbj-attr.property-value-character + ",pasp-dens" .
end .

for each buf_thbj-attr exclusive-lock where buf_thbj-attr.prop-code = "temp-for-pomi" :
  buf_thbj-attr.property-value-integer = 1 .
end .

run utl/init-shift-period.p (input "all") .
