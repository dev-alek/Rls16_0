block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 


Автор: Ростовцев Александр Михайлович
Дата создания: 31/07/23
Author: Rostovtsev Aleksandr
Creation date: 31/07/23 

*/


&scoped-define main-tbl c-marking
trigger procedure for delete of ub.{&main-tbl}.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo init "Тригер удаления {&main-tbl}". 
