/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "name" &then
  &if "{1}" = "gob-doc" &then
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-{1} where {&w-cond} and
    can-find (ub.goods where ub.goods.artic          = l-{1}.artic
                                  and ub.goods.prod-type = l-{1}.prod-type
                                  and ub.goods.prod-code = l-{1}.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-{1}) then contin = no.
    end.
  else do:
    find first l-{1} where {&w-cond} and
    can-find (ub.goods where ub.goods.artic          = l-{1}.artic
                                  and ub.goods.prod-type = l-{1}.prod-type
                                  and ub.goods.prod-code = l-{1}.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
  &else
  if last-event:label = "Ctrl-J" or contin then do:
    find next l-{1} where {&w-cond}
                              and l-{1}.gds-name begins loc-name no-lock no-error.
    if avail(l-{1}) then contin = no.
  end.
  else do:
    find first l-{1} where {&w-cond}
                              and l-{1}.gds-name begins loc-name no-lock no-error.
        contin = no.
  end.
  &endif
&endif
&if "{2}" = "art+" &then
&if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
&scop stat-cond AND (if g-stat = {&all} then true else (if g-stat = {&current} then (l-{1}.stts = 0) else (l-{1}.stts = 1)))
&endif
find first l-{1} where {&w-cond} {&stat-cond}
                                  and l-{1}.artic begins (loc-art + last-event:label) no-lock no-error.
&endif
&if "{2}" = "art-" &then
&if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
&scop stat-cond AND (if g-stat = {&all} then true else (if g-stat = {&current} then (l-{1}.stts = 0)else (l-{1}.stts = 1)))
&endif
find first l-{1} where {&w-cond} {&stat-cond}
                                  and l-{1}.artic begins loc-art no-lock no-error.
&endif


/* $workfile: cli-zakz.i $ e n d */