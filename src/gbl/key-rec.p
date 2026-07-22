block-level on error undo, throw.
/*

$Revision: f7ab46314d86, 1406, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:34 2018 +0300 $
$Workfile: key-rec.p $
$Archive: gbl/key-rec.p $



Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define output parameter this-proc-hndl as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: f7ab46314d86, 1406, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: key-rec.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/key-rec.p $":U .
define variable vss-description as character no-undo init "Удаление пользовательских параметров настройки интерфейса для всех окон".


do:
  
  this-proc-hndl = this-procedure.
  
end.

{ gbl/key-rec.i  }