block-level on error undo, throw.
/*

$Revision: f4eb1c45dbd4, 240, rls $
$Author: ASMorozov $
$Date: Mon Aug 31 16:26:51 2015 +0400 $
$Workfile: AdapteeProcGdsbcode.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcGdsbcode.p $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

define input parameter p-gds-code as integer no-undo.
define input parameter p-node-code as integer no-undo.
define output parameter p-main-b-code as integer no-undo.

{ cmp/library.i  }

{ gbl/gdsbcode.i p-gds-code ? p-main-b-code NO-ERROR }
  if error-status:error then return "":U.