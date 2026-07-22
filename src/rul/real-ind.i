/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/03/07
Author: Bakhtadze Natalya
Creation date: 04/03/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION real-index returns integer(
                                    input p-source as character
                                   ,input p-target as character
                                   ,input p-starting as integer
                                   ,output p-sub-number as integer
                                   ):
define variable v-dopi as integer no-undo .
define variable v-starting as integer no-undo .
define variable v-subs as character no-undo .
v-starting = p-starting.
_do:
do while true:
  v-dopi = index(p-source, p-target, v-starting).
  if p-target  begins "&":U
  and v-dopi > 0  then do:
    if p-target = "&":U then do:
      v-subs = substring(p-source, v-dopi + 1, 1).
      if v-subs = "&":U
      and length(p-source) > v-dopi + 1
      then do:
        v-starting = v-dopi + 2.
      end.
      else do:
        if v-dopi > 1 then do:
          v-subs = substring(p-source, v-dopi - 1, 1).
          if v-subs = chr(123) then do:
             v-starting = v-dopi + 1.
          end.
          else do:
            leave _do.
          end.
        end.
        else do:
          leave _do.
        end.
      end.
    end.
    else  do: /*&1 &2 &3 и т.д.*/
      if v-dopi > 1 then do:
        v-subs = substring(p-source, v-dopi - 1, 1).
        if v-subs = "&":U
        and length(p-source) > v-dopi + 1
        then do:
          v-starting = v-dopi + 2.
        end.
        else do:
          leave _do.
        end.
      end.
      else do:
        leave _do.
      end.
    end.
  end.
  else leave _do.
end.
assign
p-sub-number = integer(substring(p-source, v-dopi + 1, 1)) no-error .
return v-dopi.
end.


/* $Workfile$ e n d */