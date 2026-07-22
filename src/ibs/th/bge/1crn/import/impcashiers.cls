/*

$Revision: f64b9a795962, 1118, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: impcashiers.cls $
$Archive: ibs/th/bge/1crn/import/impcashiers.cls $

Класс ипорта данных currency из 1С

Автор: Елена Шкляр
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.cur-time FROM PROPATH.
USING ibs.th.gbl.*.
block-level on error undo, throw.

/*block-level on error undo, throw.*/

class ibs.th.bge.1crn.import.impcashiers implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }

  define variable curtime as class cur-time no-undo .

  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
	
    
    define variable objCashiers as class cashiers no-undo.
    
    objCashiers = cast (subjectObj, cashiers) .
    
    run ref/imp-cashiers-1c-RN.p (input objCashiers) no-error .
    if error-status:error
      then 
    do :
      Msg = return-value .
      return false.
    end.
  end method.

end class.