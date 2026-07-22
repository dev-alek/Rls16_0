block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clc-wast.p $
$Archive: str/clc-wast.p $

Расчет естественной убыли

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/03/02



*/

define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clc-wast.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/clc-wast.p $":U .
define variable vss-description as character no-undo initial "Расчет естественной убыли":U .

{ cmp/str-glbl.i }
{ gbl/waitfram.i noprocess }
{ str/lib-rwds.i }

define buffer bf_trn-doc for ub.trn-doc.

do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
  if error-status :error then do: return error substitute( 'Не найден документ с номером "&1".', pardoc-code ). end.
  { str/ccwstsum.i bf_trn-doc.doc-code
               "this-procedure :handle"
               tt-wast-line             no-error }
  if error-status :error then do:
    return error substitute( 'Ошибка &1 &2 при расчете естественной убыли по документу "&3".'
                           , return-value
                           , error-status :get-message( 1 )
                           , bf_trn-doc.doc-code ).
  end.
end. /* on error */