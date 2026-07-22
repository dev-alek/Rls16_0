block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : updateCliAttr.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : EShklyar
    Created     : Fri Apr 10 13:45:13 AST 2020
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 441f77397fde, 2803, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: ѕт июл 23 16:27:15 2021 +0300 $":U .
define variable vss-Workfile    as character no-undo init "$Workfile: updateCliAttr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/updateCliAttr.p $":U .
define variable vss-description as character no-undo init "”даление повтор€ющихс€ значений атрибута" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ utl/runpro.i }

define buffer buf_clients-attr for ub.clients-attr .
      define variable ii as integer no-undo .
      define variable jj as integer no-undo .
      define variable kk as integer no-undo .

for each buf_clients-attr exclusive-lock where buf_clients-attr.attr-code = {&attr-tank-farm-for}:
      if num-entries (buf_clients-attr.attr-value,",") > 1 then 
      do:
         kk = num-entries (buf_clients-attr.attr-value,",") .
         do ii = 1 to kk:
            jj = ii + 1 .
            if jj <= kk then 
            do:    
               if entry(ii,buf_clients-attr.attr-value,",") = entry(jj,buf_clients-attr.attr-value,",") then 
               do:
                  buf_clients-attr.attr-value = replace (buf_clients-attr.attr-value,(entry(ii + 1, buf_clients-attr.attr-value, ",") + ","),"") .  
                  if num-entries (buf_clients-attr.attr-value,",") < 2 then do:
                  release buf_clients-attr . 
                  leave .
                  end.
                  release buf_clients-attr .
               end.
            end.
         end.
      end.   
end.      