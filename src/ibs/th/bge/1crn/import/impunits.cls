/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных units из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.impunits implements ibs.th.bge.1crn.import.iimpsubject:
  
  { cmp/str-glbl.i class }
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
		
    define variable v-rec    as recid     no-undo .
    define variable v-mode   as character no-undo .    
		
    define variable objUnits as class     units no-undo.
    define variable v-type   as character no-undo.
    objUnits = cast (subjectObj, units).

    case objUnits:type_:
      when 1 then 
        do:
          v-type = "шту".
      end.
      when 2 then 
        do:
          v-type = "вес".
        end.
      when 3 then 
        do:
          v-type = "дро".
        end.
      when 4 then 
        do:
          v-type = "топ" + {&comma-char} + {&divisional}.
        end.      
    end case.  
		
/*    if objUnits:del-f = 1 then                                                        */
/*    do:                                                                               */
/*      /*проверять не используется ли данные где-то в другом месте - не сделано*/      */
/*		                                                                                      */
/*      find first ub.units where ub.units.OKEI = integer(objUnits:okei-code) no-error .*/
/*      if AVAILABLE ub.units then                                                      */
/*      do:                                                                             */
/*        delete ub.units .                                                             */
/*      end.  		                                                                        */
/*    end.                                                                              */
/*    else                                                                              */
/*    do:                                                                               */
      find first ub.units where ub.units.unit-name = objUnits:name_ no-error .
      if AVAILABLE ub.units then 
      do:
        assign
          v-rec  = recid(ub.units) 
          v-mode = {&update}
          .
      end.                                
      else 
      do:		
        assign
          v-rec  = ? 
          v-mode = {&add-def}
          .
      end.

      run ref/units01.p (
        input-output v-rec
        ,input v-mode
        ,input integer(objUnits:okei-code)
        ,input objUnits:full-name
        ,input v-type 
        ,input objUnits:name_
        ) no-error.
      if error-status:error then 
      do:
        Msg = return-value.
        return false.
      end.
      find first ub.units where ub.units.unit-name = objUnits:name_ no-error .
      if AVAILABLE ub.units then 
      do:
      ub.units.stts = objUnits:del-l .
      end.
      return true.

/*    end.*/
  end method.

end class.