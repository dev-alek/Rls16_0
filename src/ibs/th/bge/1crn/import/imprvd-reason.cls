/*

$Revision: d78a6c0019c8, 2862, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:08 2021 +0300 $
$Workfile: imprvd-reason.cls $
$Archive: ibs/th/bge/1crn/import/imprvd-reason.cls $

Класс импорта данных imposnovcorr из 1С

Автор: Шкляр Елена
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.imprvd-reason implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  { ref/extclass.i } 
   
  define buffer buf_ext-classif for ub.ext-classif .   
  
  define variable v-code as character no-undo .
   
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
	
    define variable ri           as recid no-undo .
    define variable objRvd-reason as class rvd-reason no-undo.
   
    objRvd-reason = cast (subjectObj, rvd-reason).
    
    if objRvd-reason:code_ = "" or objRvd-reason:code_ = ? then 
    do:
      Msg = "Основание/причина разрешения РВД не задано".
      return error Msg .
    end.
    if objRvd-reason:name_ = "" or objRvd-reason:name_ = ? then 
    do:
      Msg = "Основание/причина разрешения РВД с кодом " + objRvd-reason:code_ + ". Не задано наименование" .
      return error Msg .
    end.  

    
    if objRvd-reason:del-f = 0 then 
    do:    
      find first buf_ext-classif exclusive-lock where buf_ext-classif.CharKey_One = objRvd-reason:code_
                                                  and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                                  and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                                  no-error .
      if available buf_ext-classif
      then do:
        delete buf_ext-classif .
      end .
      create buf_ext-classif .
      assign
        buf_ext-classif.classif-subject = {&extclass_rvd-reason}
        buf_ext-classif.classif-name    = {&extclass_rvd-reason}
        buf_ext-classif.Key#_One        = 0
        buf_ext-classif.Key#_Two        = objRvd-reason:type_
        buf_ext-classif.key#_three      = 0
        buf_ext-classif.CharKey_One     = objRvd-reason:code_
        buf_ext-classif.charkey_two     = objRvd-reason:name_
        buf_ext-classif.charkey_three   = if objRvd-reason:description_ <> ? then objRvd-reason:description_ else ""
        buf_ext-classif.db-num          = 0
        buf_ext-classif.nonunique       = objRvd-reason:del-l
        buf_ext-classif.uniq-key-rec    = {&extclass_rvd-reason} + {&delim-key}
                                        + buf_ext-classif.charkey_one
      .
    end.
    else do:
      find first buf_ext-classif exclusive-lock where buf_ext-classif.CharKey_One = objRvd-reason:code_
                                                  and buf_ext-classif.classif-subject = {&extclass_rvd-reason} 
                                                  and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                                  no-error .
      if not available (buf_ext-classif) then 
      do:
        Msg = "Удаление основания/причины разрешения РВД с кодом " + objRvd-reason:code_ + " не возможно" .
        return error Msg.
      end.
      else 
        delete buf_ext-classif .
    end.
  end method.
end class.