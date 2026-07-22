/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Шкляр Елена
Дата создания: 08/28/07
Author: Elena Shklyar
Creation date: 08/28/07


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.

    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input {&ggoattr-ban-sales-via-cd},
          output v-value,
          output v-type
        ).

       if v-value = "yes" then
          return true.
       else 
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input {&ggoattr-ban-sales-via-cd},
             output v-value,
             output v-type
             ).

          if v-value = "yes" then
             return true.        
          else 
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input {&ggoattr-ban-sales-via-cd},
                output v-value,
                output v-type
                ).

             if v-value = "yes" then
                return true.    
             else v-upper-code = lc_gds-grp.upper-code.    
          end .          
       end.   
      end.
    end.
    if v-value = "" or logical(v-value) = false then return false .
end.

FUNCTION check-ban-sales-via-cd-grp return logical ( input p-grp-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.

    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.

    v-upper-code = p-grp-code.
    
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input {&ggoattr-ban-sales-via-cd},
          output v-value,
          output v-type
        ).

       if v-value = "yes" then
          return true.
       else 
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input {&ggoattr-ban-sales-via-cd},
             output v-value,
             output v-type
             ).

          if v-value = "yes" then
             return true.        
          else 
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input {&ggoattr-ban-sales-via-cd},
                output v-value,
                output v-type
                ).

             if v-value = "yes" then
                return true.    
             else v-upper-code = lc_gds-grp.upper-code.    
          end .          
       end.   
      end.

end.