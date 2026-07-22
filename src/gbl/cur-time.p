/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Текущее системное время сервера БД

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Используется при печати отчетов, при логировании процедур

Гарантируется, что количество секунд от начала дн
соответствует возвращаемой дате.

  ----------------------------------------------------------------------*/

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
define variable vss-description as character no-undo init "Процедура получения номера кода (бар-код, весовой код, ...)".


do:
  
  this-proc-hndl = this-procedure.
  
end.

{ gbl/cur-time.i  }