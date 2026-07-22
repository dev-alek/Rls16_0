 
 /*------------------------------------------------------------------------
    File        : impprice-doc
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Fri Nov 03 14:06:26 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impprice-doc implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  { cmp/str-glbl.i }
  
  define property Msg as character no-undo
    get. 
    set.  

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
      
    define buffer buf_price-doc for ub.price-doc .  
    define buffer buf_goods for ub.goods.  
    
    define variable objPrice-doc as class price-doc-imp .
    
    objPrice-doc = cast (subjectObj, price-doc-imp) .
    
    run ref/imp-price-doc-1C-RN.p (input objPrice-doc) no-error .
    if error-status:error
    then do :
      Msg = return-value .
      return false.
    end.
      
    return true .
  end method.      
end class.