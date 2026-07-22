block-level on error undo, throw.
/*

$Revision: f4eb1c45dbd4, 240, rls $
$Author: ASMorozov $
$Date: Mon Aug 31 16:26:51 2015 +0400 $
$Workfile: AdapteeProcProdbcat.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcProdbcat.p $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

define parameter buffer buf_prod-bc for ub.prod-bc.
define output parameter l-is-petrol-code as logical no-undo.

{ cmp/library.i  }

{ gbl/prodbcat.i buf_prod-bc 'petrolium=request' l-is-petrol-code NO-ERROR }