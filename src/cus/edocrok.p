block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: edocrok.p $
$Archive: cus/edocrok.p $

Процедура ПРИЕМа ответов и прописания статусов EDOC-nn

Автор: Чернова Светлана Александровна
Дата создания: 10/02/08
Author: Svetlana Chernova
Creation date: 10/02/08

*/

define input  parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: edocrok.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/edocrok.p $":U .
define variable vss-description as character no-undo init "Процедура приема ответов и прописания статусов EDOC-nn".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i }

{ gbl/key-rec.i  }

define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_trn-doc for ub.trn-doc.
message
"Прием документов по электронному документообороту проводится автоматически подсистемой OXML" skip
"Обновите список заказов нажатием клавиши F5, чтобы увидеть изменения состояния заказов"
view-as alert-box .

