block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-dinsch.p $
$Archive: rep/g-dinsch.p $

Динамика финансового движения"

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
                  'code-schet-start' + {&delim-par} +
                  '':U) +
                   ';' +
                  ('X-DATE-END' + {&delim-key} + "По конец банковской выписки" + {&delim-par} +
                  "finsttms" + {&delim-par} +
                  'code-schet-end' + {&delim-par} +
                  '':U)
.

run rep/d-report.w
    ( input parParentProc
      ,input 'rep/e-dinsch.w'
      ,input "Динамика финансового движения"
      ,input 2
      ,input "":U
      ,input ""
      ,input ""
      ,input ""
      ,input ("{&schet-yes},{&hide-schet-all-firm},{&hide-schet-firm},{&hide-schet-choice},{&hide-schet-rubl},{&hide-schet-no-rubl},{&hide-schet-choice-val},{&Arc-fin-yes}" +
             {&comma-char} + v-ed_date-param)
      ,input no).