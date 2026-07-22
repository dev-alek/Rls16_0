
{&CommentStartNoClass}
method public integer AddOADLine
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function AddOADLine returns integer  
{utl\comment.i} */
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iGtin    as char,
 iQnty    as int,
 isite    as character ):
    
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define variable vnewMark as character no-undo.
    define variable vQnty    as integer   no-undo.
    
    vnewMark = "02" + iGtin + "37" + string(iQnty).
    find first utd-marking-lines where utd-marking-lines.mark       = vnewMark
                                   and utd-marking-lines.db-num     = idb-num     
                                   and utd-marking-lines.doc-id     = idoc-id 
                                   and utd-marking-lines.Linenum    = iLinenum        
    exclusive-lock no-error.
    if available utd-marking-lines 
    then do:
       delete utd-marking-lines.
       vQnty = AddOADLine(idb-num, idoc-id, iLinenum, iGtin, iQnty * 2 ,isite ).
    end.
    else do:
       create utd-marking-lines.
       assign
          utd-marking-lines.mark      = vnewMark
          utd-marking-lines.db-num    = idb-num     
          utd-marking-lines.doc-id    = idoc-id 
          utd-marking-lines.Linenum   = iLinenum
          utd-marking-lines.site      = isite
          utd-marking-lines.doc-level = 1
          utd-marking-lines.gds-code  = ?        
       .
       vQnty = iQnty.
    end.
    return vQnty.
 end.


{&CommentStartNoClass}
method public recid addMarkforUtd
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function addMarkforUtd returns recid 
{utl\comment.i} */
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iMark as character  ,
 isite   as character,
 iUtdType as character    ):
    define buffer     marking            for ub.marking.
    define buffer     marking-attr       for ub.marking-attr.
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define variable vMRC  as decimal no-undo.
    define variable vQnty as decimal no-undo.
   define variable vRec as recid no-undo.
   if     imark ne "-"
      and imark ne ""
      and imark ne ?
   then do:
      imark = repTegforDm(imark).
      vQnty = getQntyUTDByCodId(imark) .
      find first utd-marking-lines where utd-marking-lines.mark       = imark
                                     and utd-marking-lines.db-num     = idb-num     
                                     and utd-marking-lines.doc-id     = idoc-id 
                                     and utd-marking-lines.Linenum    = iLinenum        
      exclusive-lock no-error.
      if not available utd-marking-lines
      then do:
         create utd-marking-lines.
         assign
            utd-marking-lines.mark      = imark
            utd-marking-lines.db-num    = idb-num     
            utd-marking-lines.doc-id    = idoc-id 
            utd-marking-lines.Linenum   = iLinenum
            utd-marking-lines.site      = isite
            utd-marking-lines.doc-level = 1
            utd-marking-lines.gds-code  = ?        
         .
         
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.mark      = imark
            utd-marking-lines-attr.db-num    = idb-num     
            utd-marking-lines-attr.doc-id    = idoc-id 
            utd-marking-lines-attr.Linenum   = iLinenum
            utd-marking-lines-attr.attr-code = "box-qnty"
            utd-marking-lines-attr.attr-value = string(vQnty)
         .
         vRec = recid(utd-marking-lines).
         release utd-marking-lines-attr.
         release utd-marking-lines. 
      end.
      else do:
         if    (    isite eq "-"
            and utd-marking-lines.site eq "+")
         or (    isite eq "+"
            and utd-marking-lines.site eq "-")
         then 
            delete utd-marking-lines.
         else if isOAD (imark)
         then do:
            vQnty = AddOADLine(idb-num, idoc-id, iLinenum, GetTegCod(imark,"02"), int(vQnty) ,isite ).
         
            create utd-marking-lines-attr.
            assign
               utd-marking-lines-attr.mark      = imark
               utd-marking-lines-attr.db-num    = idb-num     
               utd-marking-lines-attr.doc-id    = idoc-id 
               utd-marking-lines-attr.Linenum   = iLinenum
               utd-marking-lines-attr.attr-code = "box-qnty"
               utd-marking-lines-attr.attr-value = string(vQnty)
            .
         end.
         vRec = recid(utd-marking-lines).
         release utd-marking-lines.
      end.
      if isMark (imark)
      then do:                               
         find first marking where marking.mark eq iMark exclusive-lock no-error.
         if not available marking
         then do:
            create marking.
            marking.mark = iMark.
            marking.gds-code = ?.
            marking.unit     = getLevelUTDByCodId(marking.mark) .
         end.
         assign
           marking.unit-ext   = if marking.unit-ext = "" or marking.unit-ext = ? then
                                   getLevelMotpByCodId(marking.mark)
                                else marking.unit-ext
           marking.box-qnty   = vQnty
           marking.unit       = if marking.unit-ext = "LEVEL2" then "КИТУ" else getLevelUTDByCodId(marking.mark)
         .
/*         marking.unit-ext = utd-lines.UnitCode .*/
         /* BTS-1134: не понятно, зачем статус марки с "Ошибка" меняется на ? */
         if       /*marking.sts = objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
            or*/ (     iUtdType eq "UniversalTransferDocument"
                  and marking.sts = objSrv:Env:marking:Sts:Mark:NotAvailable:KeyIntDB)
         then
            marking.sts = ?.
/* BTS-2503                                                                */                              
/*         vMRC =  getMRCByDM (iMark).                                     */
/*         if     vMRC ne 0                                                */
/*            and vMRC ne ?                                                */
/*         then do:                                                        */
/*            find first marking-attr where marking-attr.mark      =  iMark*/
/*                                      and marking-attr.attr-code = "MRC" */
/*            no-lock no-error.                                            */
/*            if not available marking-attr                                */
/*            then do:                                                     */
/*               create marking-attr.                                      */
/*               assign                                                    */
/*                  marking-attr.mark =  iMark                             */
/*                  marking-attr.attr-code = "MRC"                         */
/*                  marking-attr.attr-value = string(vMRC)                 */
/*               .                                                         */
/*            end.                                                         */
/*            release marking-attr no-error.                               */
/*         end.                                                            */
      end.
      
   end.
   return vRec.
end.

{&CommentStartNoClass}
method public logical isSaleMarkInUpak
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function isSaleMarkInUpak returns logical  
{utl\comment.i} */
(iMark    as char ):
    
   define buffer buf_marking       for ub.marking.
   
   for each buf_marking no-lock where
            buf_marking.mark-parent = iMark
   :
     if can-do(objSrv:Env:marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or 
        can-do(objSrv:Env:marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) then
       return true.
     if isSaleMarkInUpak(buf_marking.mark) then
       return true.  
   end.
   return false.
 end.

 {&CommentStartNoClass}
method public logical setStatusUpak
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function setStatusUpak returns logical  
{utl\comment.i} */
(iDbNum   as integer ,
 iDocId   as integer ,
 iLineNum as integer ,
 iMark    as char ,
 iSts     as integer):
    
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_marking           for ub.marking.

   for each buf_marking exclusive-lock where
            buf_marking.mark-parent = iMark,
      first buf_utd-marking-lines exclusive-lock where
            buf_utd-marking-lines.doc-id  = iDocId
        and buf_utd-marking-lines.db-num  = iDbNum
        and buf_utd-marking-lines.lineNum = iLineNum           
        and buf_utd-marking-lines.mark = buf_marking.mark
   :
     setStatusUpak(iDbNum, iDocId, iLineNum, buf_marking.mark, iSts). 
   end.
   for first buf_utd-marking-lines exclusive-lock where
             buf_utd-marking-lines.doc-id  = iDocId
         and buf_utd-marking-lines.db-num  = iDbNum
         and buf_utd-marking-lines.lineNum = iLineNum           
         and buf_utd-marking-lines.mark = iMark,
       first buf_marking exclusive-lock where
             buf_marking.mark = buf_utd-marking-lines.mark 
   :
     if  buf_marking.sts <> objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
     then do:
       assign
         buf_utd-marking-lines.sts = iSts
         buf_marking.sts           = iSts
       .
     end.
   end.
   return true.
end.
 