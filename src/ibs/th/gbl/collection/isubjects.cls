/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

интерфейс коллекции

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.

block-level on error undo, throw.

interface ibs.th.gbl.collection.isubjects: 
  
  define property iCounter as integer no-undo
    get.

  define property SubjectObjCurr as Progress.Lang.Object no-undo
    get.

  method public void Add (subObj as Progress.Lang.Object).
  method public void Delete (iNum as int).
  method public integer Get (iNum as int).

end interface.