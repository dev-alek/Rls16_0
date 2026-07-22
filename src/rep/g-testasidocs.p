block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита проверки целостности свободной зоны марок

Автор: Шкляр Елена
Дата создания: 07/30/08
Author: Shklyar Elena
Creation date: 07/30/08

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчёт под документам проверки корректности работы АСИ".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-testasidocs.w'
    , input "Результаты проверки корректности работы АСИ в резервуаре":U
    , input 4 
    , input "":U
    , input "{&o-all},{&o-currency},{&o-choice}"
    , input ""
    , input ""
    , input ""
    , input no
    ).