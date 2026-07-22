/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок r-mattov.p

Автор: Демин Алексей Сергеевич
Дата создания: 09/17/07
Author: Alexey Demin
Creation date: 09/17/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if '{1}' = 'grp-goods' &Then

  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-grp-name, {&delim-grp} )  + {&delim-grp} .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.

  do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
    end.
    delete tt-grp-tree .
  end.

  assign old-lvel = lvel .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */

  run is-page .
/*  put stream outstream   Line format frmt skip .*/

  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-grp-name, {&delim-grp} )  + {&delim-grp} .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-grp-name, {&delim-grp} )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Группа " + tt-grp-tree.name ) .
    end.
  end.
&endif

&if '{1}' = 'post' &Then

  assign CurrGrpName = "" .
  do ind = 1 to lvel :
    assign CurrGrpName = CurrGrpName + entry ( ind, v-cgrp-name, {&delim-grp} )  + {&delim-grp} .
    find first tt-grp-tree where tt-grp-tree.full = CurrGrpName no-error .
    if not available tt-grp-tree then LEAVE.
  end.

  do ij = old-lvel to ind by -1 : /* удаляем старые заголовки из списка */
    find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
      run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
    end.
    delete tt-grp-tree .
  end.

  assign old-lvel = lvel .
  /* надо вставлять заголовки для всех нижестоящих и вставить их в список */
  run is-page .
/*  put stream outstream   Line format frmt skip .*/

  do ij = ind to lvel :
    create tt-grp-tree .
    if ij > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ij, v-cgrp-name, {&delim-grp} )  + {&delim-grp} .
    end.
    assign
      tt-grp-tree.num  = ij + 3
      tt-grp-tree.full = CurrGrpName
      tt-grp-tree.name = entry ( ij, v-cgrp-name, {&delim-grp} )
      tt-grp-tree.qnty1 = 0
      tt-grp-tree.qnty2 = 0
      tt-grp-tree.qnty3 = 0
    .
    if ij <= xvar-lavel-2 then do:
      assign ItogStr = "" .
      do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
      run PrintName ( ItogStr + "Гр. пост. " + tt-grp-tree.name ) .
    end.
  end.
&endif


/* $Workfile$ e n d */