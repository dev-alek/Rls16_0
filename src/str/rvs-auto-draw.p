block-level on error undo, throw.
/*

$Revision: 7b0cc5f31b3c, 1617, rls $
$Author: SSlivenko $
$Date: Tue Nov 06 04:41:38 2018 +0300 $
$Workfile: rvs-auto-draw.p $
$Archive: str/rvs-auto-draw.p $

Автоматическое создание контрольной сверки
АВТОМАТИЧЕСКИЙ ОПРОС ТРК ОТКЛЮЧЕН, ТАК КАК КОЛОНКИ ВСТАЮТ ЕСЛИ ОПРОС ИДЕТ ВО ВРЕМЯ НАЛИВА

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/06
Author: Dmitry Ukhanov
Creation date: 11/29/06

Автор1: Булгаков Андрей Николаевич
Дата создания1: 11/28/05

*/

define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 7b0cc5f31b3c, 1617, rls $":U.
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U.
define variable vss-date        as character no-undo initial "$Date: Tue Nov 06 04:41:38 2018 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: rvs-auto-draw.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/rvs-auto-draw.p $":U.
define variable vss-description as character no-undo initial "Автоматическое создание контрольной сверки":U.

{ cmp/vssrevis.i }
{ adm/auto-def.i new }

run adm/autoinit.p ("","").
subscribe   to "RvsParam" anywhere run-procedure "ParamRvs".
subscribe   to "getObjList" anywhere run-procedure "ObjList".
run str/rvs-auto.p (iUtil:parparentproc,this-procedure,this-procedure,ibs.th.gbl.gbl-var:g#db-num,?,?,ibs.th.gbl.gbl-var:g#db-num).
unsubscribe to "getObjList".
unsubscribe to "RvsParam".

procedure ObjList:
   define output parameter oAnswer as char no-undo.
   oAnswer = substitute("&1*&2",iUtil:Obj-type,iUtil:Obj-code).
end procedure. 
procedure ParamRvs:
   define output parameter oAnswer as char no-undo.
   // нулевая сверка 
   oAnswer = "yes".
end procedure.