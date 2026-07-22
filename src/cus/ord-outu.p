block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-outu.p $
$Archive: cus/ord-outu.p $

толкач для процедуры корректировки внутреннего расходного - приходного запроса

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

*/
define input parameter parparentproc   as   handle no-undo.
define input parameter par-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-outu.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-outu.p $":U .
define variable vss-description as character no-undo init "толкач для процедуры корректировки внутреннего расходного - приходного запроса   ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }

define new shared buffer t-doc for ub.trn-doc .
define new shared query br-docs for t-doc scrolling.
define variable varnext-prev as logical no-undo.
define variable varline-rec  as recid   no-undo.
find first t-doc no-lock where recid(t-doc ) = par-recid no-error .
if available t-doc then do:
    run str/out-doc.w
    (input parparentproc,
      input-output par-recid,
      input {&update},
      input ?,
      input ?,
      input ?,
      input-output varnext-prev,
      input t-doc.ext-doc-type,
      input ?,
      input-output varline-rec,
      input ?,
      input ?,
      input {&inquiry}).
end.