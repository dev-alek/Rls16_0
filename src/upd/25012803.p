block-level on error undo, throw.
{ cmp/trg-def.i  }
define input  parameter parparentproc as handle no-undo.
define input  parameter iparam        as character no-undo.
define output parameter oOk           as logical no-undo.

function ChgV1 return logical
    (input p-obj-type as char,
     input p-obj-code as int):
     
    define variable vOk as logical no-undo.    
    define buffer thbj-attr for ub.thbj-attr.         
    
    do trans:  
        vOk = true.
        find first thbj-attr where thbj-attr.upper-prop-code eq {&attr-gisMT}
                             and thbj-attr.obj-type        eq p-obj-type
                             and thbj-attr.obj-code        eq p-obj-code
                             and thbj-attr.prop-code       eq {&attr-gisMT_OflineAdress}                           
        exclusive-lock no-wait no-error.
        if available thbj-attr then do:
           if R-INDEX(thbj-attr.property-value-character,"/v1") > 0
           then do:
              thbj-attr.property-value-character = substring(thbj-attr.property-value-character, 1, R-INDEX(thbj-attr.property-value-character,"/v1") ) + "v2" .
           end.   
        end.
        else if locked thbj-attr then vOk = false.
        
    end.
    return vOk.
end.

/* меняем текущую локальную секцию */
oOk = ChgV1({&db},g#db-num).
/* для ТБД меняем глобальную секцию */
if oOk and g#db-num = 0 then oOk = ChgV1("",g#db-num). 
