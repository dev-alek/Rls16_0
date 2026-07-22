 
 /*------------------------------------------------------------------------
    File        : send1cerpsub
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Sat Jan 07 09:45:08 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.collection.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.export.send1cerpsub abstract 
   inherits   ibs.th.gbl.sys.objth  
   implements ibs.th.bge.1crn.subjects.iexpsubject:
   { cmp/str-glbl.i class}
   define public property parparentproc as handle no-undo
   get.
   private set.
   
   define property parent-handle as handle    no-undo
   get.
   private set.
   
   define property log-handle    as handle    no-undo
   get.
   private set.
   
   define property processType   as character no-undo
   get.
   private set.
   
   define property oldbh         as handle    no-undo
   get.
   private set.
   
   define property newbh         as handle    no-undo
   get.
   private set.
   
   define property params        as class paramCol  no-undo
   get.
   private set.

   method public void setContext (input  i-parparentproc   as handle,
                                  input  i-parent-handle   as handle,
                                  input  i-log-handle      as handle,
                                   input  i-process         as character,
                                   input  i-oldbh           as handle,
                                   input  i-newbh           as handle,
                                   input  i-params          as paramCol
   ):
      assign
         parparentproc = i-parparentproc
         parent-handle = i-parent-handle
         log-handle    = i-log-handle
         processType   = i-process
         oldbh         = i-oldbh
         newbh         = i-newbh
         params        = i-params
      .
      CheckParam() no-error.
      if error-status:error
      then
         return error return-value.
   end.
   
   method abstract public void CrContentToSW (hSaxWriter as handle).
   method abstract public void CheckParam    ().
   /* метод setSubjectId - обязатеьный                                                                 */
   /* устанавливает sendTableName - имя таблицы и sendOldRowid,sendNewRowid - rowid выгружаемых записи */

   define property Msg as character no-undo
   get:
      return trim (Msg, {&new-line}).
   end.
   protected set (inArg as char):
      Msg = Msg + {&new-line} + inArg.
   end.
    
   define abstract property InitSecTag as character no-undo
   get.
      
   define abstract property sendTableName  as character  no-undo
     get.
   
   define public property sendOldRowid as rowid  no-undo
     get.
     set.

   define public property sendNewRowid as rowid  no-undo
     get.
     set.
   
   constructor protected send1cerpsub (  ):
      super ().
   end constructor.

   destructor public send1cerpsub ( ):
   end destructor.
   
end class.