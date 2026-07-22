block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shft5r.p $
$Archive: rep/r-shft5r.p $

печать сменного отчета (ЮКОС лист 5 сбор данных - МЦ)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter pobj-type    like ub.shift-obj.obj-type   no-undo .
define input parameter pobj-code    like ub.shift-obj.obj-code   no-undo .
define input parameter pshift-date  like ub.shift-obj.shift-date no-undo .
define input parameter pshift-num   like ub.shift-obj.shift-num  no-undo .
DEFINE INPUT PARAMETER pshift-date1 like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num1  like ub.shift-obj.shift-num no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shft5r.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shft5r.p $":U .
define variable vss-description as character no-undo initial "печать сменного отчета (ЮКОС лист 5 сбор данных - МЦ)":U .

{ cmp/str-glbl.i       }
{ cmp/library.i        }
{ cmp/r-page1.i        }
{ rep/icm-5df.i shared }
{ str/wth-lib.i        }

define variable dopd1 as decimal no-undo .
define variable dopd2 as decimal no-undo .

for each t-5
:
  delete t-5 .
end.

for each ub.wth-obj no-lock where
         ub.wth-obj.obj-type = pobj-type and
         ub.wth-obj.obj-code = pobj-code
:
  find first ub.wealth no-lock where
             ub.wealth.wth-code = ub.wth-obj.wth-code no-error .
  create t-5.
  assign
    t-5.wth-code = ub.wth-obj.wth-code
    t-5.wth-name = ( if available ub.wealth then ub.wealth.wth-name else "НЕИЗВЕСТНАЯ МЦ" )
  .
  run wth-lib_full-inf-shift-inter(
    input pobj-type,
    input pobj-code,
    input wth-obj.wth-code,
    input pshift-date,
    input pshift-num,
    input pshift-date1,
    input pshift-num1
    , output t-5.stock-before
    , output t-5.stock-after
    , output dopd1
    , output t-5.income-cassa
    , output t-5.income-other
    , output dopd2
    , output t-5.incass-bank
    , output t-5.incass-other
    , output t-5.incass-cassa
    ) no-error .
end. /* for each ub.wth-obj */