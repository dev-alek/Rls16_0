/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок r-mattov.p

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/07
Author: Alexey Demin
Creation date: 09/13/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


procedure Run0 :      /* no-classify */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time
        break by temp-gds-time.dt by temp-gds-time.tm by {&Sort-Pole1} :
        if first-of(temp-gds-time.tm) then run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.tm)  then Run PrintItog ("Всего ", 1).
      end.
    end.
    else do:
      for each temp-gds break by {&Sort-Pole} :
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
      end.
    end.
  end.
end procedure. /* Run0 */

procedure Run1 :      /* "grp-goods":U */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time  break by temp-gds-time.dt by temp-gds-time.tm  by temp-gds-time.grp-name  by {&Sort-Pole1} :
        if first-of(temp-gds-time.tm) then  run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        if first-of(temp-gds-time.grp-name)  then run PrintName ( "  Группа " + temp-gds-time.grp-name ) .
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-time.grp-name, 1).
        if last-of(temp-gds-time.tm)  then Run PrintItog ("Всего ", 2).
      end.
    end.
    else do:
      for each temp-gds break by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.grp-name)  then run PrintName ( "Группа " + temp-gds.grp-name ) .
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
        if last-of(temp-gds.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds.grp-name, 1).
      end.
    end.
  end.
end procedure. /* Run1 */



procedure Run11 :      /* "grp-goods":U   группы с уровня  */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time
        break by temp-gds-time.dt
              by temp-gds-time.tm
              by temp-gds-time.grp-name
              by {&Sort-Pole1} :
        if first-of(temp-gds-time.tm) then  run PrintTime ( string(temp-gds-time.dt,"99/99/99") + " " + string(temp-gds-time.tm,"99") + ".00" ) .
        if first-of(temp-gds-time.grp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-time.grp-name, {&delim-grp}), {&delim-grp} )
            v-grp-name = temp-gds-time.grp-name
          .
          { rep/r-mattv3.i "grp-goods" }
        end.
        run PrintLine  in this-procedure ( temp-gds-time.qnty1, temp-gds-time.qnty2, temp-gds-time.min-qnty, temp-gds-time.artic, temp-gds-time.gds-name, temp-gds-time.unit-base) .
        if last-of(temp-gds-time.tm) then do:
          do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          Run PrintItog ("Всего ", 1).
        end.
      end.
    end.
    else do:
      for each temp-gds  break by temp-gds.grp-name by {&Sort-Pole} :
        if first-of(temp-gds.grp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds.grp-name, {&delim-grp}), {&delim-grp} )
            v-grp-name = temp-gds.grp-name
          .
          { rep/r-mattv3.i "grp-goods" }
        end.
        run PrintLine  in this-procedure ( temp-gds.qnty1, temp-gds.qnty2, temp-gds.min-qnty, temp-gds.artic, temp-gds.gds-name, temp-gds.unit-base) .
      end.
      do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по группе " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure. /* Run11 */



procedure Run5 :     /* "post":U */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by {&Sort-Pole3} :
        if first-of(temp-gds-time-post.tm) then  run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 2).
        if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 3).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by {&Sort-Pole2} :
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "  Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("  Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds-post.cgrp-name, 2).
      end.
    end.
  end.
end procedure. /* Run5 */


procedure Run55 :      /* "post":U   группы с уровня  */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by {&Sort-Pole3} :
        if first-of(temp-gds-time-post.tm) then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-time-post.cgrp-name, {&delim-grp}), {&delim-grp} )
            v-cgrp-name = temp-gds-time-post.cgrp-name
          .
          { rep/r-mattv3.i "post" }
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.tm) then do:
          do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            if ij <= xvar-lavel-2 then do:
              assign ItogStr = "" .
              do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
              assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
              run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
          if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 1).
        end.
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by {&Sort-Pole2} :
        if first-of(temp-gds-post.cgrp-name) then do:
          assign
            lvel = num-entries( right-trim(temp-gds-post.cgrp-name, {&delim-grp}), {&delim-grp} )
            v-cgrp-name = temp-gds-post.cgrp-name
          .
          { rep/r-mattv3.i "post" }
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
      end.
      do ij = old-lvel to 1 by -1 : /* удаляем старые заголовки из списка */
        find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
        if ij <= xvar-lavel-2 then do:
          assign ItogStr = "" .
          do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
          assign ItogStr = ItogStr + "Всего по гр. пост. " + tt-grp-tree.name .
          run PrintItogGroup in this-procedure ( ItogStr, tt-grp-tree.qnty1, tt-grp-tree.qnty2, tt-grp-tree.qnty3 ) .  /* вывод сумм */
        end.
        delete tt-grp-tree .
      end.
    end.
  end.
end procedure. /* Run11 */


procedure Run6 :       /* "post/grp-goods":U */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.grp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by {&Sort-Pole3} :
        if first-of(temp-gds-time-post.tm)        then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.grp-name)  then run PrintName ( "    Группа " + temp-gds-time-post.grp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "      Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("      Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.grp-name)   then Run PrintItog ("    Всего по группе " + temp-gds-time-post.grp-name, 2).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 3).
        if last-of(temp-gds-time-post.tm)    then Run PrintItog ("Всего ", 4).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.cgrp-name
              by temp-gds-post.grp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by {&Sort-Pole2} :
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.grp-name)  then run PrintName ( "  Группа " + temp-gds-post.grp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-post.grp-name, 2).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("Всего по гр. пост. " + temp-gds-post.cgrp-name, 3).
      end.
    end.
  end.
end procedure. /* Run6 */


procedure Run7 :       /* "grp-goods/post":U */
  do on error undo, return error return-value :
    if  p-Rad-Inter = 1  then do:
      for each temp-gds-time-post
        break by temp-gds-time-post.dt
              by temp-gds-time-post.tm
              by temp-gds-time-post.grp-name
              by temp-gds-time-post.cgrp-name
              by temp-gds-time-post.post-type
              by temp-gds-time-post.post-code
              by {&Sort-Pole3} :
        if first-of(temp-gds-time-post.tm)        then run PrintTime ( string(temp-gds-time-post.dt,"99/99/99") + " " + string(temp-gds-time-post.tm,"99") + ".00" ) .
        if first-of(temp-gds-time-post.grp-name)  then run PrintName ( "  Группа " + temp-gds-time-post.grp-name ) .
        if first-of(temp-gds-time-post.cgrp-name) then run PrintName ( "    Гр. пост. " + temp-gds-time-post.cgrp-name ) .
        if first-of(temp-gds-time-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-time-post.post-type and buf_clients.obj-code = temp-gds-time-post.post-code no-error .
          run PrintName ( "      Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-time-post.qnty1, temp-gds-time-post.qnty2, temp-gds-time-post.min-qnty, temp-gds-time-post.artic, temp-gds-time-post.gds-name, temp-gds-time-post.unit-base) .
        if last-of(temp-gds-time-post.post-code)  then Run PrintItog ("      Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-time-post.cgrp-name)  then Run PrintItog ("    Всего по гр. пост. " + temp-gds-time-post.cgrp-name, 2).
        if last-of(temp-gds-time-post.grp-name)   then Run PrintItog ("  Всего по группе " + temp-gds-time-post.grp-name, 3).
        if last-of(temp-gds-time-post.tm)  then Run PrintItog ("Всего ", 4).
      end.
    end.
    else do:
      for each temp-gds-post
        break by temp-gds-post.grp-name
              by temp-gds-post.cgrp-name
              by temp-gds-post.post-type
              by temp-gds-post.post-code
              by {&Sort-Pole2} :
        if first-of(temp-gds-post.grp-name) then  run PrintName ( "Группа " + temp-gds-post.grp-name ) .
        if first-of(temp-gds-post.cgrp-name) then run PrintName ( "  Гр. пост. " + temp-gds-post.cgrp-name ) .
        if first-of(temp-gds-post.post-code) then do:
          find first buf_clients no-lock where buf_clients.obj-type = temp-gds-post.post-type and buf_clients.obj-code = temp-gds-post.post-code no-error .
          run PrintName ( "    Поставщик " + buf_clients.obj-name ) .
        end.
        run PrintLine  in this-procedure ( temp-gds-post.qnty1, temp-gds-post.qnty2, temp-gds-post.min-qnty, temp-gds-post.artic, temp-gds-post.gds-name, temp-gds-post.unit-base) .
        if last-of(temp-gds-post.post-code)  then Run PrintItog ("    Всего по поставщику " + buf_clients.obj-name, 1).
        if last-of(temp-gds-post.cgrp-name)  then Run PrintItog ("  Всего по гр. пост. " + temp-gds-post.cgrp-name, 2).
        if last-of(temp-gds-post.grp-name)   then Run PrintItog ("Всего по группе " + temp-gds-post.grp-name, 3).
      end.
    end.
  end.
end procedure. /* Run7 */


/* $Workfile$ e n d */