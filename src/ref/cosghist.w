define input  parameter pid as int64 no-undo.
{ref/brwhist.i &buf_obj-hist = c-goods-attr-any }  

function get-subject returns character
  ( p-subject as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&scop hn-obj-hist-code p-subject
  return p-subject.   /* Function return value. */

end function.
 
procedure local-view-cange:
   define output parameter odescription as character no-undo.
   run obj-proc (output odescription).
   
         
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .
     if p-mode eq "one"
     then do:
        { gbl/fltopend.i
          &where-cond = " ~
          X_c-obj-hist.Bush                = 'operserv' ~
         and X_c-obj-hist.attr-code          = 'operservid' ~
         and X_c-obj-hist.attr-value         = string(pid)  "
          &dyn_where-cond = " substitute('  X_c-obj-hist.Bush                = &1operserv&1 ~
                                        and X_c-obj-hist.attr-code          = &1operservid&1 ~
         and X_c-obj-hist.attr-value         = &1&2&1 ', ~{&double-quote~}, pid)  "

          &use-ind    = " "
          &by         = "  " }
     end.
     else do:
     
{ gbl/fltopend.i
          &where-cond = " TRUE "
          
          &by         = "  " }
     end.
  return true.
end.

procedure obj-proc :
define output parameter p-description as character no-undo .

define variable v-mess as character no-undo.

do
on error undo, return error return-value
:
  
&scop fields-name-list "gds-code"
define variable v-label-param as character no-undo .
  v-label-param =
   "gds-code"     + {&delim-par} + "Код товара " + {&delim-par} + "" .


  run proc-full-temp-changes in this-procedure (
                                               input X_c-obj-hist.action = integer({&hn-create})
                                              ,input X_c-obj-hist.action = integer({&hn-delete})
                                              ,input  buffer X_c-obj-hist:handle
                                              ,input  {&table_goods-attr}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* cashbook-proc */

