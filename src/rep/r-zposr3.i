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


procedure Run0 :      /* no-classify */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "  Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("  Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 2).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.post-code) then run PrintName ( "Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("Всего по поставщику " + temp-gds.post-name, 1).
      end.
    end.
  end.
end procedure. /* Run0 */

procedure Run1 :      /* "grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "  Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds.grp-name, 2).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 3).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.grp-name)  then run PrintName ( "Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "  Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("  Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds.grp-name, 2).
      end.
    end.
  end.
end procedure. /* Run1 */



procedure Run11 :      /* "grp-goods":U   группы с уровня  */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name, no ) .
        { rep/r-zposr2.i "grp-goods" }
        if last-of(temp-gds.obj-code) then do:
          do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 2 ).
          if xSumsOnly = yes then  put stream outstream   Line format frmt skip .
        end.
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        { rep/r-zposr2.i "grp-goods" }
      end.
      do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure. /* Run11 */



procedure Run2 :     /* "prod":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.prod-code) then run PrintName ( "  Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("  Всего по производителю " + temp-gds.prod-name, 2).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 3).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.prod-code) then run PrintName ( "Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "  Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("  Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("Всего по производителю " + buf_clients.obj-name, 2).
      end.
    end.
  end.
end procedure. /* Run2 */

procedure Run3 :       /* "prod/grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.prod-code) then run PrintName ( "  Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "    Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "      Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("      Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("    Всего по группе " + temp-gds.grp-name, 2).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("  Всего по производителю " + temp-gds.prod-name, 3).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 4).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.prod-code) then run PrintName ( "Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "  Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds.grp-name, 2).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("Всего по производителю " + temp-gds.prod-name, 3).
      end.
    end.
  end.
end procedure. /* Run3 */


procedure Run4 :       /* "grp-goods/prod":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.grp-name
              by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "  Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.prod-code) then run PrintName ( "    Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "      Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("      Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("    Всего по производителю " + temp-gds.prod-name, 2).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds.grp-name, 3).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 4).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.grp-name
              by temp-gds.prod-type
              by temp-gds.prod-code
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.grp-name)  then run PrintName ( "Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.prod-code) then run PrintName ( "  Производитель " + temp-gds.prod-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.prod-code)  then Run PrintItog ("  Всего по производителю " + temp-gds.prod-name, 2).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds.grp-name, 3).
      end.
    end.
  end.
end procedure. /* Run4 */

procedure Run5 :     /* "post":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds.cgrp-name, 2).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 3).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "  Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("  Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds.cgrp-name, 2).
      end.
    end.
  end.
end procedure. /* Run5 */


procedure Run55 :      /* "post":U   группы с уровня  */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code) then run PrintName ( temp-gds.obj-name, no ) .
        { rep/r-zposr2.i "post" }
        if last-of(temp-gds.obj-code) then do:
          do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel-2 then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 2 ).
          if xSumsOnly = yes then  put stream outstream   Line format frmt skip .
        end.
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        { rep/r-zposr2.i "post"}
      end.
      do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel-2 then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.fact-qnty, tt-grp-tree.free-qnty, tt-grp-tree.zak-sum, tt-grp-tree.naz-sum, tt-grp-tree.wait-qnty ) .  /* вывод сумм */
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure. /* Run11 */


procedure Run6 :       /* "post/grp-goods":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.cgrp-name
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "    Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "      Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("      Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("    Всего по группе " + temp-gds.grp-name, 2).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds.cgrp-name, 3).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 4).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.cgrp-name
              by temp-gds.grp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "  Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds.grp-name, 2).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds.cgrp-name, 3).
      end.
    end.
  end.
end procedure. /* Run6 */


procedure Run7 :       /* "grp-goods/post":U */
  do on error undo, return error return-value :
    if tog-obj then do:
      for each temp-gds
        break by temp-gds.obj-type
              by temp-gds.obj-code
              by temp-gds.grp-name
              by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.obj-code)  then run PrintName ( temp-gds.obj-name, no ) .
        if first-of(temp-gds.grp-name)  then run PrintName ( "  Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.cgrp-name) then run PrintName ( "    Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "      Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("      Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("    Всего по гр. пост. " + temp-gds.cgrp-name, 2).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds.grp-name, 3).
        if last-of(temp-gds.obj-code)   then Run PrintItog ("Всего по объекту " + temp-gds.obj-name, 4).
      end.
    end.
    else do:
      for each temp-gds
        break by temp-gds.grp-name
              by temp-gds.cgrp-name
              by temp-gds.post-type
              by temp-gds.post-code
              by {&Sort-Pole} :
        if first-of(temp-gds.grp-name) then  run PrintName ( "Группа " + temp-gds.grp-name, no ) .
        if first-of(temp-gds.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds.cgrp-name, no ) .
        if first-of(temp-gds.post-code) then run PrintName ( "    Поставщик " + temp-gds.post-name, yes ) .
        run PrintLine        in this-procedure .
        if last-of(temp-gds.post-code)  then Run PrintItog ("    Всего по поставщику " + temp-gds.post-name, 1).
        if last-of(temp-gds.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds.cgrp-name, 2).
        if last-of(temp-gds.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds.grp-name, 3).
      end.
    end.
  end.
end procedure. /* Run7 */


/* $Workfile$ e n d */