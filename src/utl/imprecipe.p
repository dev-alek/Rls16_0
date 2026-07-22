block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: imprecipe.p $
$Archive: utl/imprecipe.p $

Запуск импорта рецептов

Автор: Гридчина Полина Дмитриевна
Дата создания: 02/03/12
Author: Gridchina Polina
Creation date: 02/03/12

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imprecipe.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imprecipe.p $":U .
define variable vss-description as character no-undo init "Запуск импорта рецептов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/gds-list.i gds-list def "NEW SHARED" } /*нужно для rum*/

run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input "thref" + {&delim-par} +
             /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
            'recipe-xml-file-import':U
          /* {&thref-proc_xml-file-import}  +  */
            /*{&delim-par} +  "recipe"  */
                 /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над рецептами") ) no-error .