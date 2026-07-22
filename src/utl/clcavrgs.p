block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clcavrgs.p $
$Archive: utl/clcavrgs.p $

Утилита по пересчету веса по средней плотности

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

*/

define input parameter parrvs-code like ub.rvs-doc.rvs-code no-undo.


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clcavrgs.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/clcavrgs.p $":U .
define variable vss-description as character no-undo initial "Утилита по пересчету веса по средней плотности".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ trg/clcavrgs.i }


do
on error undo, return error return-value
:

  define buffer bf_rvs-doc  for ub.rvs-doc.
  define buffer bf_rvs-line for ub.rvs-line.

  find first bf_rvs-doc
    where bf_rvs-doc.rvs-code = parrvs-code no-error
    .
  if not available bf_rvs-doc
  then do:
    message
      "Ошибка входных параметров" skip
      view-as alert-box error .
    return error.
  end.

  run clcavrgd
    (input bf_rvs-doc.rvs-code
    ) no-error .
  if error-status :error then do:
    return error .
  end.
end.