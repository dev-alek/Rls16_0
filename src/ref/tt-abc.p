block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tt-abc.p $
$Archive: ref/tt-abc.p $

Процедура проставления ABC по временной таблице temp-tt

Автор: Чернова Светлана Александровна
Дата создания: 01/13/06
Author: Svetlana Chernova
Creation date: 01/13/06

*/

define temp-table temp-tt no-undo
field id        as recid    /* есть */
field summa     as decimal  /* есть */
field proc      as decimal
field proc-2    as decimal
field proc-acc1 as decimal
field proc-acc2 as decimal
field ABC-1     as character
field ABC       as character
index pi proc desc
index pi1 proc-acc1 desc
index pi2 proc-acc2 desc
index pi3 id
.

define temp-table  x-analysis        no-undo  like ub.abc-analysis.

define input         parameter table for    x-analysis.
define input-output  parameter table for    temp-tt.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tt-abc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/tt-abc.p $":U .
define variable vss-description as character no-undo init "Процедура проставления ABC по временной таблице temp-tt".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/thbjattr.i }
find first x-analysis no-error .

define variable v-A     as decimal   no-undo .
define variable v-B     as decimal   no-undo .
define variable first-A as logical   no-undo .
define variable first-B as logical   no-undo .

define variable v-c as decimal   no-undo .
define variable v-d as decimal   no-undo .
define variable first-c as logical   no-undo .
define variable first-d as logical   no-undo .
define variable v-e as decimal   no-undo .
define variable v-f as decimal   no-undo .
define variable first-e as logical   no-undo .
define variable first-f as logical   no-undo .

define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .

run waitfram-show ("Просчет АВС процентов...").

define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.


define variable v-pr1 as decimal   no-undo .
v-pr1 = 0 .

for each temp-tt :
   v-pr1 = v-pr1 + temp-tt.summa.
end.

for each temp-tt :
  temp-tt.proc = temp-tt.summa * 100 / v-pr1 .
end.


assign
  v-a = x-analysis.double-line-proc
  first-A = true
  .

define variable v-nak as decimal   no-undo .
v-nak = 0.


if x-analysis.abc-type = "2" then do:

/* ---1---- */
for each temp-tt
         break by temp-tt.proc desc :

    v-nak = v-nak + temp-tt.proc .
    temp-tt.proc-acc1 = v-nak .

    if v-nak <= v-A   then do:
       temp-tt.ABC-1 = "A" .
       first-A = true.
       next.
    end.

    if v-nak > v-A  then do:
       if first-A = true then
          assign
            first-A = false
            temp-tt.ABC-1 = "A"
          .
        else
          assign
            temp-tt.ABC-1 = "B"
          .
    end.
end.


/* -----2----- */
define variable v-80 as decimal   no-undo .

assign
  v-a = x-analysis.abc-a
  v-b = x-analysis.abc-b
  v-c = x-analysis.abc-c
  v-d = x-analysis.abc-d
  v-e = x-analysis.abc-e
  v-f = x-analysis.abc-f
  first-A = true
  first-B = true
  first-c = true
  first-d = true
  first-e = true
  first-f = true
  v-nak = 0
  v-80  = 0
  .

for each temp-tt  where temp-tt.ABC-1 = "A"
  :
  v-80 = v-80 + temp-tt.summa .
end.


for each temp-tt  where temp-tt.ABC-1 = "A"
    break by temp-tt.summa desc
    :
    temp-tt.proc-2 = temp-tt.summa * 100 / v-80 .
end.

define variable first-str as logical   no-undo .
first-str = true .

for each temp-tt  where temp-tt.ABC-1 = "A"
    break by temp-tt.proc-2 desc
    :

    v-nak = v-nak + temp-tt.proc-2 .
    temp-tt.proc-acc2  = v-nak .

    if first-str = true and v-nak > v-A then do:
       temp-tt.ABC = "A" .
       first-A = false .
       first-str = false .
       next.
    end.
    first-str = false .

    if v-nak <= v-A   then do:
       temp-tt.ABC = "A" .
       first-A = true.
       next.
    end.

    if v-nak > v-A  and v-nak <= v-B then do:
       if first-A = true then
          assign
            first-A = false
            temp-tt.abc = "A"
          .
        else
          assign
            temp-tt.abc = "B"
          .
    end.


    if v-nak > v-B  and v-nak <= v-C then do:
       if first-B = true then
          assign
            first-B = false
            temp-tt.abc = "B"
          .
          else
            assign
              temp-tt.abc = "C"
            .
    end.
    if v-nak >  v-c  and length(par-abc-type) = 3 then temp-tt.abc = "C" .

    if length(par-abc-type) >= 4 then do:
        if v-nak > v-c  and v-nak <= v-d then do:
          if first-c = true then
              assign
                first-c = false
                temp-tt.abc = "C"
              .
              else
                assign
                  temp-tt.abc = "D"
                .
        end.
        if v-nak >  v-d  and length(par-abc-type) = 4 then temp-tt.abc = "D" .
    end.
    if length(par-abc-type) >= 5 then do:
        if v-nak > v-d  and v-nak <= v-e then do:
          if first-d = true then
              assign
                first-d = false
                temp-tt.abc = "D"
              .
              else
                assign
                  temp-tt.abc = "E"
                .
        end.
        if v-nak >  v-e  and length(par-abc-type) = 5 then temp-tt.abc = "E" .
    end.
    if length(par-abc-type) >= 6 then do:
        if v-nak > v-e  and v-nak <= v-f then do:
          if first-e = true then
              assign
                first-e = false
                temp-tt.abc = "E"
              .
              else
                assign
                  temp-tt.abc = "F"
                .
        end.
        if v-nak >  v-f then do:
                assign
                  temp-tt.abc = "F"
                .

        end.
    end.
end.

/* ----3---- */

define variable LE-proc as decimal   no-undo .
define variable label-a as character no-undo .
define variable label-b as character no-undo .
case par-abc-type :
   when 'ABC':U
      then do:
      label-a  = "D"  .
      label-b  = "E"  .
      end.
   when 'ABCD':U
      then do:
      label-a = "E"  .
      label-b = "F"  .
      end.
   when 'ABCDE':U
      then do:
      label-a = "F"  .
      label-b = "G"  .
      end.
   when 'ABCDEF':U
      then do:
      label-a = "G"  .
      label-b = "H"  .
      end.
end case.

assign
  LE-proc = x-analysis.LE-proc
  .
for each temp-tt  where temp-tt.ABC-1 = "B"
    break by temp-tt.proc desc
    :

    if temp-tt.proc <= LE-proc   then do:
       temp-tt.abc = label-b .
    end.
    else temp-tt.abc = label-a .
end.
end.
else do:
/* SIMPL */
assign
  v-a = x-analysis.abc-a
  v-b = x-analysis.abc-b
  v-c = x-analysis.abc-c
  v-d = x-analysis.abc-d
  v-e = x-analysis.abc-e
  v-f = x-analysis.abc-f
  first-A = true
  first-B = true
  first-c = true
  first-d = true
  first-e = true
  first-f = true
  v-nak = 0
  v-80  = 0
  .

define variable first-str2 as logical   no-undo .
first-str2 = true .

for each temp-tt
    break by temp-tt.proc desc
    :

    v-nak = v-nak + temp-tt.proc .
    temp-tt.proc-acc1  = v-nak .

    if first-str2 = true  and v-nak > v-A then do:
       temp-tt.ABC = "A" .
       first-A = false .
       first-str2 = false  .
       next.
    end.
    first-str2 = false  .

    if v-nak <= v-A   then do:
       temp-tt.ABC = "A" .
       first-A = true.
       next.
    end.

    if v-nak > v-A  and v-nak <= v-B then do:
       if first-A = true then
          assign
            first-A = false
            temp-tt.abc = "A"
          .
        else
          assign
            temp-tt.abc = "B"
          .
    end.


    if v-nak > v-B  and v-nak <= v-C then do:
       if first-B = true then
          assign
            first-B = false
            temp-tt.abc = "B"
          .
          else
            assign
              temp-tt.abc = "C"
            .
    end.
    if v-nak >  v-c  and length(par-abc-type) = 3 then temp-tt.abc = "C" .

    if length(par-abc-type) >= 4 then do:
        if v-nak > v-c  and v-nak <= v-d then do:
          if first-c = true then
              assign
                first-c = false
                temp-tt.abc = "C"
              .
              else
                assign
                  temp-tt.abc = "D"
                .
        end.
        if v-nak >  v-d  and length(par-abc-type) = 4 then temp-tt.abc = "D" .
    end.
    if length(par-abc-type) >= 5 then do:
        if v-nak > v-d  and v-nak <= v-e then do:
          if first-d = true then
              assign
                first-d = false
                temp-tt.abc = "D"
              .
              else
                assign
                  temp-tt.abc = "E"
                .
        end.
        if v-nak >  v-e  and length(par-abc-type) = 5 then temp-tt.abc = "E" .
    end.
    if length(par-abc-type) >= 6 then do:
        if v-nak > v-e  and v-nak <= v-f then do:
          if first-e = true then
              assign
                first-e = false
                temp-tt.abc = "E"
              .
              else
                assign
                  temp-tt.abc = "F"
                .
        end.
        if v-nak >  v-f then do:
                assign
                  temp-tt.abc = "F"
                .

        end.
    end.
end.
end.
run waitfram-hide.
/*
for each temp-tt :
message
'summa       '  temp-tt.summa         skip
'proc        '  temp-tt.proc          skip
'proc-2      '  temp-tt.proc-2        skip
'proc-acc1   '  temp-tt.proc-acc1     skip
'proc-acc2   '  temp-tt.proc-acc2     skip
'ABC-1       '  temp-tt.ABC-1         skip
'ABC         '  temp-tt.ABC           .
end.
*/