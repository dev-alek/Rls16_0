/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок r-zpostr.p

Автор: Демин Алексей Сергеевич
Дата создания: 01/13/06
Author: Alexey Demin
Creation date: 01/13/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if '{1}' = 'grp-goods' &Then

if first-of(temp-gds.grp-name) then do:
  assign
    lvel = num-entries( right-trim(temp-gds.grp-name, {&delim-grp}), {&delim-grp} )
  .
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, temp-gds.grp-name, {&delim-grp} )  + {&delim-grp} .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.

  do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
    end.
    delete tt-grp-tree .
  end.

  assign old-lvel = lvel .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */

  run is-page .
  put stream outstream   Line format frmt skip .

  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, temp-gds.grp-name, {&delim-grp} )  + {&delim-grp} .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, temp-gds.grp-name, {&delim-grp} )
      tt-grp-tree.fact-qnty = 0
      tt-grp-tree.free-qnty = 0
      tt-grp-tree.zak-sum   = 0
      tt-grp-tree.naz-sum   = 0
      tt-grp-tree.wait-qnty = 0
    .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Группа " + tt-grp-tree.name, no ) .
    end.
  end.
end.
&endif

&if '{1}' = 'post' &Then

if first-of(temp-gds.cgrp-name) then do:
  assign
    lvel = num-entries( right-trim(temp-gds.cgrp-name, {&delim-grp}), {&delim-grp} )
  .
  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, temp-gds.cgrp-name, {&delim-grp} )  + {&delim-grp} .
    find first tt-grp-tree
      where tt-grp-tree.full = CurrGrpName
    no-error .
    if not available tt-grp-tree then LEAVE.
  end.

  do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
    end.
    delete tt-grp-tree .
  end.

  assign old-lvel = lvel .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
  run is-page .
  put stream outstream   Line format frmt skip .

  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, temp-gds.cgrp-name, {&delim-grp} )  + {&delim-grp} .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, temp-gds.cgrp-name, {&delim-grp} )
      tt-grp-tree.fact-qnty = 0
      tt-grp-tree.free-qnty = 0
      tt-grp-tree.zak-sum   = 0
      tt-grp-tree.naz-sum   = 0
      tt-grp-tree.wait-qnty = 0
    .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Гр. пост. " + tt-grp-tree.name, no ) .
    end.
  end.
end.
&endif


if first-of(temp-gds.post-code) then run PrintName ( ItogStr + "  Поставщик " + temp-gds.post-name, yes ) .
run PrintLine        in this-procedure .
if last-of(temp-gds.post-code)  then Run PrintItog ( ItogStr + "  Всего по поставщику " + temp-gds.post-name, 1).

for each tt-grp-tree :
  assign
    tt-grp-tree.fact-qnty = tt-grp-tree.fact-qnty + temp-gds.fact-qnty
    tt-grp-tree.free-qnty = tt-grp-tree.free-qnty + temp-gds.free-qnty
    tt-grp-tree.zak-sum   = tt-grp-tree.zak-sum   + temp-gds.zak-sum
    tt-grp-tree.naz-sum   = tt-grp-tree.naz-sum   + temp-gds.naz-sum
    tt-grp-tree.wait-qnty = tt-grp-tree.wait-qnty + temp-gds.wait-qnty
  .
end.

/* $Workfile$ e n d */