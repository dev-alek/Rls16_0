block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prt-edit.p $
$Archive: str/prt-edit.p $

Вызов редактирования признака в расходной накладной

Автор: Чернова Светлана Александровна
Дата создания: 07/23/04
Author: Svetlana Chernova
Creation date: 07/23/04

Автор1: Перваков Михаил Сергеевич

*/

define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-node-code   as integer   no-undo .
define input  parameter p-mode        as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prt-edit.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/prt-edit.p $":U .
define variable vss-description as character no-undo initial "Вызов редактирования признака в расходной накладной".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,parparentproc,p-doc-code,p-gds-code,p-node-code,p-mode)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }

define buffer buf_gds-prt  for ub.gds-prt .
define buffer buf_goods    for ub.goods .
define buffer buf_doc-line for ub.doc-line .

do
on error undo, return error return-value
:

  find first buf_gds-prt no-lock
    where buf_gds-prt.node-code = p-node-code
    no-error .
  if not available buf_gds-prt
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define new shared buffer t-doc for trn-doc .

  find first t-doc exclusive-lock
    where t-doc.doc-code = p-doc-code
    .

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .

  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = p-doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    .

  run str/out-prt.w
    (input parparentproc
    ,input recid(t-doc)
    ,input recid(buf_doc-line)
    ,input recid(buf_goods)
    ,input p-mode
    ,input recid(buf_gds-prt)
    ,input {&g#term}
    ) no-error.

end.