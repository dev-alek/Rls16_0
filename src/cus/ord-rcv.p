block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-rcv.p $
$Archive: cus/ord-rcv.p $

Вызов поставок

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/21/01
*/

  define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
  define variable vss-author      as character no-undo init "$Author: expertek $":U .
  define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  define variable vss-workfile    as character no-undo init "$Workfile: ord-rcv.p $":U .
  define variable vss-archive     as character no-undo init "$Archive: cus/ord-rcv.p $":U .
  define variable vss-description as character no-undo init "Вызов поставок".
 { cmp/vssrevis.i }
 { cmp/trg-def.i  }
 { cmp/showinf.i  }
 { gbl/getcntxt.i def }

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-place as character no-undo .  /* Тип поставка */
define input parameter p-type as character no-undo .       /* Тип поставка */
define input parameter p-status as character no-undo . /* статус поставка */
define variable v-list as character no-undo .
{ gbl/getcntxt.i get }

run cus/all-rcv.w
(    parParentProc
    , v-cntxt-host-code-obj
    , (If p-type   = "all":U then ? else p-type    )  /* type */
    , (if p-status = "all":U then ? else p-status  )  /* status */
    , ?
    , p-place
    , output v-list
    ) .

RETURN.