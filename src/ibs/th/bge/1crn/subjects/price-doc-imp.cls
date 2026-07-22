 
 /*------------------------------------------------------------------------
    File        : price-doc-imp
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Fri Nov 03 13:27:25 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.price-doc_gds-sale from propath.
using ibs.th.bge.1crn.subjects.price-doc-imp from propath.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.price-doc-imp inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property doc-num     as character    no-undo get. 
    private set.
  define property doc-id     as character    no-undo get. 
    private set.
  define property doc-num-ES  as character    no-undo get. 
    private set.
  define property doc-date    as character    no-undo get. 
    private set.
  define property doc-status  as character    no-undo get. 
    private set.
  define property status-date as datetime-tz  no-undo get. 
    private set.
  define property cr-gs       as integer      no-undo get. 
    private set.
  define property cmnt        as character    no-undo get. 
    private set.
  define property gds-sale    as subjects no-undo get. 
    private set.
   
  define override property InitTag as character no-undo init "price-doc"
    get.
  
  constructor public price-doc-imp ():
    InitListTag = "gds-sale".
  end constructor.
  
  method override protected void SetPropProtected (inTag as char, inValue as char) :
     case inTag:      
      when "doc-num" then 
        do:
          assign 
            doc-num-ES = inValue .
        end.
      when "doc-id" then 
        do:
          assign 
            doc-id = inValue .
        end.
      when "doc-num-gs" then 
        do:
          assign 
            doc-num = inValue .
        end.  
      when "cr-gs" then 
        do:
          assign 
            cr-gs = integer (inValue).
        end.
      when "doc-date" then 
        do:
          assign 
            doc-date = inValue.
        end.
      when "doc-status" then 
        do:
          assign 
            doc-status = inValue.
        end.
      when "status-date" then 
        do:
          assign 
            status-date = datetime-tz(inValue).
        end.
      when "cmnt" then 
        do:
          assign 
            cmnt = inValue.
        end.
    end case.
  end method.

  method override protected void SetPropProtected(SubsObj as subjects):

    case SubsObj:InitTag:   
      when "gds-sale" then
        do:
          gds-sale = SubsObj.            
        end.
    end case.

  end.

  
  method override protected void CheckData ():
    def var v-str as char no-undo.
    
/*    assign                                             */
/*      v-str = "code" when code_ = ?                    */
/*      v-str = v-str + ",grp-code" when grp-code = ?    */
/*      v-str = v-str + ",name" when name_ = ?           */
/*      v-str = v-str + ",label-name" when label-name = ?*/
/*      v-str = v-str + ",chk-name" when label-name = ?  */
/*    .                                                  */
/*    v-str = trim (v-str, ",").                         */
    
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  
  end method .
  
  method override protected void ClearSub():
    assign
        doc-num      = ?
        doc-id       = ?
        doc-num-ES   = ?
        doc-date     = ?
        doc-status   = ?
        status-date  = ?
        cr-gs        = ?
        cmnt         = ?
    .    
    delete object gds-sale no-error.
  end method .
    
end class.