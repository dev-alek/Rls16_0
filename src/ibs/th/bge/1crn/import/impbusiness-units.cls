/*

$Revision: 07b627212def, 1105, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: impbusiness-units.cls $
$Archive: ibs/th/bge/1crn/import/impbusiness-units.cls $

Класс ипорта данных business-units из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impbusiness-units implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
	
		
    define buffer buf_regions for regions.

    define variable objBusiness as class business-units no-undo.
    
    objBusiness = cast (subjectObj, business-units).


    on write  of ub.regions override 
      do: 
      end.
    on delete of ub.regions override 
      do: 
      end.

    do
      on error undo, return error
      :

      if objBusiness:del-f = 1 then 
      do:
        for each buf_regions exclusive-lock where 
          buf_regions.reg-code = integer (objBusiness:code_):
          delete buf_regions.
        end.
      end.
      else 
      do:
        find first buf_regions exclusive-lock where 
          buf_regions.reg-code = integer (objBusiness:code_) no-error .
        if AVAILABLE buf_regions then 
        do:
          assign
            buf_regions.reg-name = objBusiness:name_
            buf_regions.status_  = objBusiness:del-l
            .
        end.
        else 
        do:  
          create buf_regions.
          assign
            buf_regions.reg-code = integer (objBusiness:code_)
            buf_regions.reg-name = objBusiness:name_
            buf_regions.status_  = objBusiness:del-l
            .
        end.
      end.  
    end.
  end method.

end class.