/*

$Revision: eebbd9e2b4b7, 2528, test $
$Author: SSlivenko $
$Date: �� ��� 04 12:57:18 2020 +0300 $
$Workfile: unitsubs.cls $
$Archive: ibs/th/str/mercury/unitsubs.cls $

Коллекция Сущностей TH ВСД


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

using Progress.Lang.*.
using ibs.th.gbl.collection.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.

class ibs.th.str.mercury.unitsubs inherits asubjects: 
  
  define property UnitObjCurr as class unitsub no-undo
    get:
      return cast (SubjectObjCurr, unitsub).
    end.

end class.
