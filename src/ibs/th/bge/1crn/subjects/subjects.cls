/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

реализация абстрактного класс на основе коллекций для ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.asubjects from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.subjects inherits asubjects: 
  
  define property InitTag as character no-undo
    get. 
    private set.
  
  constructor subjects (inInitTag as char):
    InitTag = inInitTag.
  end.
  
  

end class.