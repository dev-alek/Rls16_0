{ cmp/str-glbl.i }
{ def/funcmet.i  getstatus char }
   (iStatus as integer  ):
   define variable vStatus as character no-undo.   
   &glob status-code string(iStatus)
   vStatus = {&status-int-name} no-error.
   return vStatus. 
end.

{ def/funcmet.i getproceditEx character }
   (ibuffertt  as handle,
    iProcDefut as character):
   define variable oProc as character no-undo.
   define variable vparent     as character no-undo.
   define variable vcode       as character no-undo.
   define variable vLastdelim  as integer no-undo.
   define buffer code for code.
   if     ibuffertt::procedit ne ""
      and ibuffertt::procedit ne  ?
   then
      oProc = ibuffertt::procedit.
   else do:
      assign
         vLastdelim = r-index(ibuffertt::parent,{&delim-par})
         vparent    = if vLastdelim eq 0 then "" else substring(ibuffertt::parent,1,vLastdelim - 1)
         vcode      = if vLastdelim eq 0 then ibuffertt::parent else substring(ibuffertt::parent,vLastdelim + 1)
      .
      find first code where Code.parent eq vparent
                         and code.code  eq vcode
      no-lock no-error.
      block-code:       
      do while available code and code.code ne "":
         
         if     code.procedit ne ?
            and code.procedit ne ""
         then do:
            oProc = code.procedit.
            leave block-code.
         end.
         assign
            vLastdelim = r-index(Code.parent,{&delim-par})
            vparent    = if vLastdelim eq 0 then "" else substring(Code.parent,1,vLastdelim - 1)
            vcode      = if vLastdelim eq 0 then Code.parent else substring(Code.parent,vLastdelim + 1)
         .
         find first code where Code.parent eq vparent
                            and code.code  eq vcode
         no-lock no-error.
      end.
   end.
   if    oProc eq ""
      or oProc eq ?
   then
      oProc = iProcDefut.
   return oProc.  
end.   
    
{ def/funcmet.i getprocedit   character }
   (ibuffertt  as handle):
   return getproceditEx(ibuffertt,"").
end.
   
    