block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-balcnt.p $
$Archive: rep/g-balcnt.p $

Баланс фин.обязательств и выплат по контрагенту за период

Автор: Демин Алексей Сергеевич
Дата создания: 03/24/06
Author: Alexey Demin
Creation date: 03/24/06

*/
define input  parameter parParentProc as handle    no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

define variable v-ed_date-param as character no-undo .

assign
v-ed_date-param = 'ED_DATE-REF=' +
                  'X-DATE-START' + {&delim-key} +
                  ("С начала банковской выписки" + {&delim-par} +
                  "finsttms" + {&delim-par} +
                  'ext-type-stat-start' + {&delim-par} +
                   '':U) +
                   ';' +
                  ('X-DATE-END' + {&delim-key} + "По конец банковской выписки" + {&delim-par} +
                  "finsttms" + {&delim-par} +
                  'ext-type-stat-end' + {&delim-par} +
                  '':U)
.


run rep/d-report.w
    ( input parParentProc
      ,input 'rep/e-balcnt.w'
      ,input "Баланс фин.обязательств и выплат по контрагенту"
      ,input 2
      ,input "":U
      ,input ""
      ,input ""
      ,input "{&v-rubl},{&v-base}"
      ,input "{&customer-yes},{&Arc-fin-yes}" + {&comma-char} + v-ed_date-param
      ,input no).