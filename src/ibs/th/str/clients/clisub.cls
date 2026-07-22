/*

$Revision: fd21875b889d, 1394, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:33 2018 +0300 $
$Workfile: clisub.cls $
$Archive: ibs/th/str/clients/clisub.cls $

Сущность TH клиенты


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/


using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.str.clients.clisub:
  
  define property ObjType as character no-undo
    get.
    set.  

  define property ObjCode as integer no-undo
    get.
    set.

end class.