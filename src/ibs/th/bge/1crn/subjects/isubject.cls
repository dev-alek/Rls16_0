/*

$Revision: 123aa31c12d3, 2868, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: isubject.cls $
$Archive: ibs/th/bge/1crn/subjects/isubject.cls $

инерфейс сущности 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.

interface ibs.th.bge.1crn.subjects.isubject:  
  
  define public property InitTag as character no-undo
    get.  
  
  method public void SetProp (inTag as char, inValue as char).
  
  method public void SetProp (inTag as char, inValue as longchar).
  
end interface.