function fLabel returns character :
   return if p-mode eq "one"  then "История по Заказу " + string({&Param_2}) + " по ДБ " + string({&Param_1}) else "История по Заказам".
end.

{str/utd-err.i}
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
   define output parameter oDescription as character no-undo.
   if X_c-obj-hist.subject eq "order-doc"
   then
      run order-doc-proc in this-procedure no-error.
   else if X_c-obj-hist.subject eq "order-doc-attr"
   then
      run order-doc-attr-proc in this-procedure no-error.
   else if X_c-obj-hist.subject eq "order-line"
   then
      run order-line-proc in this-procedure no-error.
   else if X_c-obj-hist.subject eq "order-line-attr"
   then
      run order-line-attr-proc in this-procedure no-error.
   if error-status:error then
     message return-value view-as alert-box.
   
end procedure.
  
function local-open-br returns logical 
(  p-open-query     as logical    ,
  p-find-next       as logical    ,
  p-find-condition as character ):
     define variable sort-column-phrase as character no-undo .
     define variable l-query-was-opened as logical no-undo .
     
   for each X_c-obj-hist :
      delete X_c-obj-hist.
   end.
   if p-mode eq "one"
   then do:
      if p-chip-num eq ?
      then do:
         for each {&buf_obj-hist} where {&buf_obj-hist}.db-num   = {&Param_1}  
                                    and {&buf_obj-hist}.doc-code = {&Param_2}
                                    and {&buf_obj-hist}.corr-user-db-num = v-corr-user-db-num
         no-lock:
            create X_c-obj-hist.
            buffer-copy {&buf_obj-hist} to X_c-obj-hist.
            if {&buf_obj-hist}.subject <> "order-doc" and 
               {&buf_obj-hist}.subject <> "*" then
            do:
              run getRecordsByChipNum in this-procedure ((buffer X_c-obj-hist:handle), {&buf_obj-hist}.subject).
            end.
         end.
      end.
      else do:
         for each {&buf_obj-hist} where 
                  {&buf_obj-hist}.db-num           = {&Param_1}  
              and {&buf_obj-hist}.doc-code         = {&Param_2}
              and {&buf_obj-hist}.corr-user-db-num = v-corr-user-db-num
              and {&buf_obj-hist}.chip-num         = p-chip-num  
             no-lock:
           run getRecordsByChipNum in this-procedure (?, "order-doc").
           run getRecordsByChipNum in this-procedure (?, "order-doc-attr").
           run getRecordsByChipNum in this-procedure (?, "order-line").
           run getRecordsByChipNum in this-procedure (?, "order-line-attr").
         end.
      end.
   end.
   
     
{ gbl/fltopend.i
          &where-cond = " TRUE "
          &by         = " by X_c-obj-hist.chip-num  " }
  
  return true.
end.

procedure getRecordsByChipNum:
  define input parameter iXObjHist as handle no-undo. /* X_c-obj-hist */
  define input parameter iTable as character no-undo.
  
  define variable vXObjHist   as handle    no-undo.  
  define variable vHistTable  as character no-undo.  
  define variable vQuery      as handle    no-undo.
  define variable vEachWhere  as character no-undo .
  define variable vBufSubj    as handle    no-undo.
    
  vHistTable = substitute("c-&1",iTable).
  CREATE BUFFER vBufSubj FOR TABLE vHistTable.
  vEachWhere  = substitute(
    "for each &1 where &1.db-num = &2 and &1.doc-code = &3 and &1.corr-user-db-num = &4 and &1.chip-num = &5"
    ,vHistTable
    ,{&buf_obj-hist}.db-num
    ,{&buf_obj-hist}.doc-code
    ,{&buf_obj-hist}.corr-user-db-num
    ,{&buf_obj-hist}.chip-num)
  .
/*run gbl/inidebug.p.*/
  create query vQuery.
  vQuery:set-buffers(vBufSubj).
  vQuery:query-prepare(vEachWhere).
  vQuery:query-open.

  vQuery:get-first(no-lock).
  do while not vQuery:query-off-end:
    if iXObjHist = ? then do:
      create buffer vXObjHist for table "X_c-obj-hist".  
      vXObjHist:buffer-copy(buffer {&buf_obj-hist}:handle).
    end.
    else vXObjHist = iXObjHist.
    vXObjHist:buffer-copy(vQuery:get-buffer-handle()).
    vXObjHist:buffer-field("subject"):buffer-value = iTable.
    vQuery:get-next(no-lock).
  end.
  vQuery:QUERY-CLOSE(). 
  DELETE OBJECT vQuery.
end procedure.

procedure order-doc-proc :
  &glob table order-doc
  { ref/cord_table-proc.i &exclude="" &method="sts,getStsOrder" &label=""}
end procedure.

procedure order-doc-attr-proc :
  &glob table order-doc-attr
  {ref/cord_table-proc.i
    &exclude="db-num,doc-code"
    &label=""
    &method=""
  }
end.

procedure order-line-proc :
  &glob table order-line
  {ref/cord_table-proc.i
    &exclude="db-num,doc-code"
    &label=""
    &method=""
  }
end procedure.

procedure order-line-attr-proc :
  &glob table order-line-attr
  {ref/cord_table-proc.i
    &exclude="db-num,doc-code"
    &label=""
    &method=""
  }
end.

function  getStsOrder returns character (iSts as int ):
   
   return orderStatus:GetLabel(iSts).
   
end.
