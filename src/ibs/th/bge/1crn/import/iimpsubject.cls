 
/*------------------------------------------------------------------------
   File        : iimpsubject
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : asmorozov
   Created     : Fri Oct 13 21:04:54 MSK 2017
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


interface ibs.th.bge.1crn.import.iimpsubject: 

  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ).

end interface.