/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Шкляр Елена
Дата создания: 04/10/06
Author: Shklyar Elena
Creation date: 04/10/06


  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
define output parameter this-proc-hndl as handle no-undo.

  { cmp/str-glbl.i }

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека работы с атрибутами типов кассовых платежей".


do:
  
  this-proc-hndl = this-procedure.
  
end.

{ ref/cp-attr.i  }