/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Приведение raw значение scales-gds.deadline к виду количество дней до истечения срока годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/27/06
Author: Bakhtadze Natalya
Creation date: 06/27/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ gbl/cur-time.i }

FUNCTION scl-gds-ld returns integer ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-raw-dead-line / 24  + 01/01/2000 - v-today
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = p-raw-dead-line.
return v-dead-line .
end.

FUNCTION scl-gds-ld2 returns integer ( input p-deadline as integer
                                     , input p-deaddate as date
                                     , input p-deadflag as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

if p-deadflag > 0 then do:
  if p-deaddate = ? then return 0.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-deaddate - v-today + 1
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = (if p-deadline = ? then 0 else p-deadline).
return v-dead-line .
end.


FUNCTION scl-gds-ld-date returns date ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

run cur-time in this-procedure ( output v-today, output v-time).
if p-sclin-ld > 0 then do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line / 24  + 01/01/2000 - 1
    .
  end.
  else  do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
else do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line  + v-today - 1
    .
  end.
  else do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
return v-dead-line-date.
end.


FUNCTION scl-gds-ld-parts returns integer ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return (v-last-date - 01/01/2000 + 1) * 24.
  end.
  else do:
    return 0.
  end.
end.
else do:
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return buf_goods.deadline.
  end.
  else return 0.
end.
END FUNCTION.

FUNCTION scl-gds-ld-parts-date returns date ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return v-last-date.
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-time).
    return v-today.
  end.
end.
else do:
  run cur-time in this-procedure ( output v-today, output v-time).
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return (v-today + buf_goods.deadline).
  end.
  else return v-today.
end.
END FUNCTION.


FUNCTION scl-gds-ld-to-raw returns integer ( input p-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).

if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  if p-dead-line = 0 then do:
    assign
    v-dead-line = 0
    .
  end.
  else do:
    assign
    v-dead-line = (v-today + p-dead-line - 01/01/2000) * 24
    .
  end.
end.
else v-dead-line = p-dead-line.
return v-dead-line.
end.

FUNCTION scl-gds-ld-to-date returns date ( input p-dead-line as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
return (v-today  + p-dead-line - 1).
end.


FUNCTION scl-gds-deadvalue returns character ( input p-deadline as integer
                                              ,input p-deaddate as date
                                              ,input p-deadflag as integer):
if p-deadflag = integer({&sc-gds-deadflag-days}) then return string((if p-deadline = ? then 0 else p-deadline)).
else return string(p-deaddate, "99/99/9999").
end function.


/* $Workfile$ e n d */