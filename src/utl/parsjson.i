&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function  gettegjson returns character 
(istr  as char,
 iteg  as char):
    define variable vpos as integer no-undo.
   istr = left-trim (istr,"~{") .
/*   istr = right-trim(istr,"~}").*/
   iteg = '"' + iteg + '"'  .
   vpos = index (istr,iteg) + 1.
   if vpos eq 1
   then
      return "".
   istr = trim(substring (istr,vpos + length(iteg))).
   if istr begins '"'
   then return trim(right-trim(entry(1,istr),"~}"),'"').
   else do:
      define variable vbeg as integer no-undo.
      define variable vbegpos as integer no-undo  init 1.
      define variable vend as integer no-undo.
      define variable vCol as integer no-undo.
      vbeg  = index (istr,"~{",vbegpos).
      vend  = index (istr,"~}",vbegpos).
      
      if vbeg < vend
      then do:
         vCol = 1.
         vbegpos = vbeg + 1.
         block-str:
         do while vCol > 0:
            vbeg  = index (istr,"~{",vbegpos).
            vend  = index (istr,"~}",vbegpos).
            
            if vbeg < vend
               and vbeg  ne 0
            then assign
               vbegpos = vbeg + 1
               vcol    = vcol + 1
            .
            else do:
               if vend eq 0
               then
                  leave block-str.
               assign
                  vbegpos = vend + 1
                  vcol    = vcol - 1
               .
            end.
         end.
         if vcol eq 0
         
         then do:
            istr = substring(istr,1,vbegpos - 1).
            return istr.
         end.
      end.
      else
      return istr.
   end. 
end.    