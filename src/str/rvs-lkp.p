block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rvs-lkp.p $
$Archive: str/rvs-lkp.p $

Просмотр документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

define input parameter parparentproc as   handle              no-undo.
define input parameter parrvs-code   like ub.rvs-doc.rvs-code no-undo.

{ cmp/str-glbl.i }

define variable rvs-rec as recid no-undo.

define buffer bf_rvs-doc for ub.rvs-doc.

do on error undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ) :
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = parrvs-code no-error.
  if not available bf_rvs-doc then do:
    return error substitute( 'Не найдена сверка с номером "&1".', bf_rvs-doc.rvs-code ).
  end.
  run str/rvs-doc.w ( input        parparentproc
                , input        {&lookup}
                , input        bf_rvs-doc.rvs-type
                , input        yes
                , input-output rvs-rec ).
end.
