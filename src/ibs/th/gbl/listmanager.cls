/*

$Revision: b187afc25aab, 810, rls $
$Author: ASMorozov $
$Date: Mon Sep 26 12:45:42 2016 +0300 $
$Workfile: listmanager.cls $
$Archive: ibs/th/gbl/listmanager.cls $

Работа со списком данных произвольного количества элементов

Автор: Морозов Александр Сергеевич
Дата создания: 10/09/16
Author: Alexandr Morozov
Creation date: 10/09/16

*/

using ibs.th.gbl.*.
block-level on error undo, throw.

class ibs.th.gbl.listmanager :

  define variable ii as integer no-undo.

  method public void WriteElement (input-output list as character, inNameElement as character, inValue as character):

    def var isExistElem as log no-undo init false.
		def var element  as char no-undo.
		
    do ii = 1 to num-entries (list, chr(4)):
      element = entry (ii, list, chr(4)).
      if entry (1, element, chr(5)) = inNameElement
      then do:
        entry (2, element, chr(5)) = inValue.
        isExistElem = true.
        entry (ii, list, chr(4)) = element.
        return.
      end.
    end.
    
    if not isExistElem
    then do:
      list = list + chr(4) + inNameElement + chr(5) + inValue.
      list = left-trim (list, chr(4)).
    end.

  end method.

  method public character ReadElement (input inList as character, inNameElement as character):
    
    def var element  as char no-undo.

    do ii = 1 to num-entries (inList, chr(4)):
      
      element = entry (ii, inList, chr(4)).
      if entry (1, element, chr(5)) = inNameElement
      then do:
        return entry (2, element, chr(5)) .
      end.
    end.

    return ?.

  end method.

end class.