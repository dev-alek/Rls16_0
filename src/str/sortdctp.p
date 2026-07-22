block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sortdctp.p $
$Archive: str/sortdctp.p $

Сортировка recid документов в порядке знаков количеств

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/30/01
Author: Bakhtadze Natalya
Creation date: 08/30/01

*/

DEFINE INPUT-OUTPUT PARAMETER prid-list as character no-undo.
define input parameter p-del-docs as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sortdctp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sortdctp.p $":U .
define variable vss-description as character no-undo init "Сортировка recid документов в порядке знаков количеств ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ cmp/doc-list.i doc-list def " " }

DEFINE VARIABLE ii as integer no-undo.

case p-del-docs:
  when no then do:
DO ii = 1 to num-entries(prid-list):
  FIND FIRST ub.trn-doc No-LOCK WHERE
             recid(ub.trn-doc) = integer(entry(ii, prid-list)) No-ERROR.
  if not avail ub.trn-doc then NEXT.
  create doc-list.
  assign
  doc-list.sel-order = ii
  doc-list.doc-code = string(recid(ub.trn-doc))
  doc-list.znak = if can-do ({&expense_write-off}, ub.trn-doc.doc-type) then -1 else 1
  .
END.
  end.
  when yes then do:
    DO ii = 1 to num-entries(prid-list):
      FIND FIRST ub.c-trn-doc No-LOCK WHERE
                recid(ub.c-trn-doc) = integer(entry(ii, prid-list)) No-ERROR.
      if not avail ub.c-trn-doc then NEXT.
      create doc-list.
      assign
      doc-list.sel-order = ii
      doc-list.doc-code = string(recid(ub.c-trn-doc))
      doc-list.znak = if can-do ({&expense_write-off}, ub.c-trn-doc.doc-type) then -1 else 1
      .
    END.
  end.
end case.

prid-list = "".

FOR EACH doc-list use-index xpk:
  assign
  prid-list = prid-list + (if prid-list = "" then "" else {&comma-char}) +
              doc-list.doc-code.
end.

