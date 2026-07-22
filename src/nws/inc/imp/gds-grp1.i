/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием gds-grp-obj-attr

Автор: Чернова Светлана Александровна
Дата создания: 03/20/07
Author: Svetlana Chernova
Creation date: 03/20/07

tb-gds-grp-obj-attr   /*в БД */
wt-gds-grp-obj-attr  /* в пакете */

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer bf_clients for ub.clients .
define variable v-obj-code as integer no-undo .
 /* проверим что кустом не ходит*/
  if l-counter <> 0 then do:
  return error vss-workfile + {&space-char}
              + vss-revision + {&space-char}
              + vss-description + {&new-line}                           
              + "Ошибка обработки записи" + {&space-char}
              + {&table_gds-grp-obj-attr} + {&new-line}
              + "Есть привязанные записи, а обработка идет для одной".
  end.

    if wt-gds-grp-obj-attr.attr-code <> {&ggoattr-QntyAssMat}  then do:
    if not available tb-gds-grp-obj-attr then do:
      create tb-gds-grp-obj-attr.
      assign compare-log = no.
    end.
    else do:
      buffer-compare tb-gds-grp-obj-attr TO wt-gds-grp-obj-attr case-sensitive save result in compare-log no-error.
    end.
    if not compare-log then do:
      buffer-copy wt-gds-grp-obj-attr TO tb-gds-grp-obj-attr.
      if   (    tb-gds-grp-obj-attr.attr-code  = {&ggoattr-ban-sales-via-cd} 
            and tb-gds-grp-obj-attr.attr-value = "yes")
         or tb-gds-grp-obj-attr.attr-code = {&ggoattr-emrc-type} 
      then do:
         for each ub.goods no-lock where ub.goods.grp-code = tb-gds-grp-obj-attr.node-code:
             run fill-g-list in  p-imp-handle  ( input ub.goods.gds-code, input tb-gds-grp-obj-attr.obj-type, input tb-gds-grp-obj-attr.obj-code).
         end.
          
      end.
    end.
  end.
/* $Workfile$ e n d */