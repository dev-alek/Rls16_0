block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-obfin.p $
$Archive: rep/g-obfin.p $

Оборот финансов с разбивкой по основаниям

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

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
      ,input 'rep/e-obfin.w'
      ,input "Оборот финансов с разбивкой по основаниям"
      ,input 2
      ,input "":U
      ,input ""
      ,input ""
      ,input ""
      ,input ("{&schet-yes},{&hide-schet-no-rubl},{&hide-schet-firm},{&hide-schet-all-firm},X-OWN-CMP,{&Arc-fin-yes}" + {&comma-char} +
             v-ed_date-param)
      ,input no).