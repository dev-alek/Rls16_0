/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Метод возвращает можно ли добавить данный товар в спецификацию

Автор: Чернова Светлана Александровна
Дата создания: 10/09/08
Author: Svetlana Chernova
Creation date: 10/09/08

*/
/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
define output parameter this-proc-hndl as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Метод возвращает можно ли добавить данный товар в спецификацию".

{ cmp/str-glbl.i }

do:
  
  this-proc-hndl = this-procedure.
  
end.

{ ref/spegrpmt.i  }