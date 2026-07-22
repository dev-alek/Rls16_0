 
 /*------------------------------------------------------------------------
    File        : price-doc_gds-sale
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Fri Nov 03 13:58:05 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.price-doc_gds-sale inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    
  define property gds-code      as character    no-undo get. private set.
  define property price-sale    as character    no-undo get. private set.  
  
  define override property InitTag as character no-undo init "gds-sale"
    get.
    
  method override protected void SetPropProtected (inTag as char, inValue as char) :
     case inTag:     
      when "gds-code" then 
        do:
          assign 
            gds-code = inValue .
        end.
      when "price-sale" then 
        do:
          assign 
            price-sale = inValue.
        end.
    end case.
  end method.
  
  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str = "gds-code" when gds-code = ?
      v-str = v-str + ",price-sale" when price-sale = ?
    .
    v-str = trim (v-str, ",").
    
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  
  end method .
      
  method override protected void ClearSub():
    assign
        gds-code = ?
        price-sale = ?
    .    
  end method .   

end class.