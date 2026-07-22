block-level on error undo, throw.
/*

$Revision: f4eb1c45dbd4, 240, rls $
$Author: ASMorozov $
$Date: Mon Aug 31 16:26:51 2015 +0400 $
$Workfile: AdapteeProcBcrcnz.p $
$Archive: ibs/th/skt/Adapters/AdapteeProcBcrcnz.p $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

define input parameter objType as character no-undo.
define input parameter objCode as integer no-undo.
define input parameter barCode as character no-undo.

define parameter buffer buf_bar-code  for ub.bar-code.
define parameter buffer buf_prod-bc   for ub.prod-bc.
define parameter buffer buf_place     for ub.place.

define variable parresult  as character no-undo.
define variable partype-bc as character no-undo.
define variable parweight  as decimal   no-undo.

{ str/libbcrcn.i }

{ str/bc-rcnz.i
  ?
  barCode
  ?
  objType
  objCode
  no
  no
  ?
  ?
  parresult
  partype-bc
  parweight
  buf_bar-code
  buf_prod-bc
  buf_place
  no-error
}