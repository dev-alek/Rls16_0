{ str/utd-attr.i {1} }
{ gbl/attr-lib.i {1} }
{ utl/gtin.i {1} }
{ str/utd-err.i {1} }
&if "{1}" = "class"
&then

method public logical CheckMarkUtd
&else
function CheckMarkUtd return logical 
&endif
 (input idb-num  as integer, 
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
   
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.

&if "{1}" = "class"
&then
method public logical CheckNotMarkUtd
&else
function CheckNotMarkUtd return logical 
&endif
 (input idb-num  as integer, 
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
 
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
&if "{1}" = "class"
&then
method public logical CheckMarkUtdLine
&else
function CheckMarkUtdLine return logical 
&endif
 (input idb-num  as integer, 
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 
 define variable v-par-type as character no-undo.
/* define variable vgdsNoMark as logical no-undo.*/
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
 
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
               &scop proc-name gds-attr-value
                {&run_proc_attr-lib}
                    ( utd-lines.gds-code,
                      {&attr-mark-type},
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).  
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
                  
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
                  
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
               
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
            
         end.
         
      end.
   end.
         
   return vMarking or vArtic.
end.

&if "{1}" = "class"
&then
method public logical getMarkUtdLine
&else
function getMarkUtdLine return logical 
&endif
 (input  idb-num  as integer, 
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
 
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking 
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)  
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.            

&if "{1}" = "class"
&then
method public logical CheckMarking
&else
function CheckMarking return logical 
&endif
 (input idb-num as integer, 
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
  
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:  
         for each utd-marking-lines 
                  where utd-marking-lines.db-num  = utd-lines.db-num 
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.    
      end.  
   end.
   return vCrErr.
end.

&if "{1}" = "class"
&then
method public logical CheckMarkForType
&else
function CheckMarkForType return logical 
&endif
 (input idb-num   as integer, 
  input idoc-id   as integer):
    
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
  
   
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
   
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
                    
      for each utd-marking-lines 
                  where utd-marking-lines.db-num  = utd-lines.db-num 
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
                        
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
            
            
         end.
         else do:
            
         end.
      end.
   end.
end.

&if "{1}" = "class"
&then
method public logical WeighedProd
&else
function WeighedProd return logical 
&endif
   ( input p-gds-code as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  Весовой товар
   ------------------------------------------------------------------------------*/
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   &scop proc-name gds-attr-value
        {&run_proc_attr-lib}
            ( p-gds-code,
              {&attr-weighed-gds},
               output v-par-val,
               output v-par-type
            ).
  
   return logical(v-par-val).   /* Function return value. */

end.

&if "{1}" = "class"
&then
method public logical WghProdVariable
&else
function WghProdVariable return logical 
&endif
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  Товар с переменным весом
   ------------------------------------------------------------------------------*/
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   &scop proc-name gds-attr-value
   {&run_proc_attr-lib}
        ( p-gds-code,
          {&attr-weighed-gds},
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:                
        {&run_proc_attr-lib}
            ( p-gds-code,
              {&attr-mark-type},
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code). 
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)  
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.   
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.

&if "{1}" = "class"
&then
method public decimal MarkWeight
&else
function MarkWeight return decimal 
&endif
   ( input p-mark as character) :
              
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   
   vMarkWeight = 0.   
   if p-mark <> "" and p-mark <> ?
   then do:                    
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark 
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark 
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).    
   end.
   
   return vMarkWeight.
end.                 