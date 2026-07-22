block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upg-clbp.p $
$Archive: upg/upg-clbp.p $

удаление всех записей BatchProcess с типом {&btpr-type-autoupg}

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: upg-clbp.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/upg-clbp.p $":U .
def var vss-description as character no-undo init "удаление всех записей BatchProcess с типом {&btpr-type-autoupg}".

{ cmp/str-glbl.i }

do
on error undo, return error
:
  define buffer buf_BatchProcess for BatchProcess.

  for each buf_BatchProcess
    where buf_BatchProcess.BP_Type = {&btpr-type-autoupg}
  on error undo, return error
  :
    delete buf_BatchProcess .
  end.

end.

/* $Workfile: upg-clbp.p $ end */