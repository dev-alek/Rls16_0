define input  parameter idb as int64 no-undo.
define input  parameter ifile-name as char  no-undo.
define input  parameter ikey as char  no-undo.
define input  parameter icode as char  no-undo.
{ref/brwhist.i &buf_obj-hist = c-counter }  

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
              X_c-obj-hist.db             = idb ~
          and X_c-obj-hist.file-name      = ifile-name ~
          and X_c-obj-hist.key            = ikey ~
          and X_c-obj-hist.code           = icode  "
         &dyn_where-cond = " substitute('  X_c-obj-hist.db             = &1 ~
                                       and X_c-obj-hist.file-name      = &2 ~
                                       and X_c-obj-hist.key            = &3 ~
                                       and X_c-obj-hist.code           = &4  ', idb, ifile-name, ikey, icode)  "

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
  
&scop fields-name-list "name,CountValue,Rule,sysInfo"
define variable v-label-param as character no-undo .
  v-label-param =
   "name"         + {&delim-par} + "Наименование счетчика " + {&delim-par} + "" + {&delim-flf}
 + "CountValue"   + {&delim-par} + "Наименование"           + {&delim-par} + "" + {&delim-flf}
 + "Rule"         + {&delim-par} + "Правила"                + {&delim-par} + "" + {&delim-flf}
 + "sysInfo"      + {&delim-par} + "Системная информация"   + {&delim-par} + "" .


  run proc-full-temp-changes in this-procedure (
                                               input X_c-obj-hist.action = integer({&hn-create})
                                              ,input X_c-obj-hist.action = integer({&hn-delete})
                                              ,input  buffer X_c-obj-hist:handle
                                              ,input  {&table_counter}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* obj-proc */

