/*

$Revision: fd21875b889d, 1394, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:33 2018 +0300 $
$Workfile: gdssub.cls $
$Archive: ibs/th/str/gds/gdssub.cls $

Сущность TH товары


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

using Progress.Lang.*.
using ibs.th.str.mercury.*.

block-level on error undo, throw.

class ibs.th.str.gds.gdssub:
  
  define property GdsCode as integer no-undo
    get.
    set.  

  define property Artic as character no-undo
    get.
    set.

  define property ProdType as character no-undo
    get.
    set.

  define property ProdCode as integer no-undo
    get.
    set.
    
  define property gdsmercs as class gdsmercsubs no-undo
    get :
      if valid-object (gdsmercs)
      then do:
        return gdsmercs.
      end.
      else do:
        gdsmercs = new gdsmercsubs().
      end.
    end.
    set.

end class.