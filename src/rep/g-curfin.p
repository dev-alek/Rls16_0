block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-curfin.p $
$Archive: rep/g-curfin.p $

Текущее состояние финансов

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
                  'X-DATE-ALONE' + {&delim-key} +
                  ("После закрытия банковской выписки" + {&delim-par} +
                  "finsttms" + {&delim-par} +
                  'ext-type-stat-end1' + {&delim-par} +
                  '':U)
.


run rep/d-report.w
    ( input parParentProc
      ,input 'rep/e-curfin.w'
      ,input "Текущее состояние финансов"
      ,input 1
      ,input "":U
      ,input ""
      ,input ""
      ,input ""
      ,input "{&schet-yes},{&hide-schet-all-firm},X-OWN-CMP" + {&comma-char} + v-ed_date-param
      ,input no).