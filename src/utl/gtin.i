&if defined (utl_gtin_i) eq 0
&then 
&glob utl_gtin_i yes
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i {1}}
{ gbl/xmlchar.i}
{ gbl/objsrv.i {1}}
{ gbl/attr-lib.i {1}}
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.

{&CommentStartNoClass}
method private logical IS-NeedMark
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function IS-NeedMark returns logical 
{utl\comment.i} */
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str 
                                 and buf_prod-bc-attr.attr-code eq {&mark}
     no-lock no-error. 
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.

{&CommentStartNoClass}
method private character repTegforDm
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function repTegforDm return char 
{utl\comment.i} */
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo. 
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
{&CommentStartNoClass}
method private character repSpecSimbforDm
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function repSpecSimbforDm return char 
{utl\comment.i} */ 
(iDM as char ):
    
    define variable oDM as character no-undo.
  {&CommentStartClass}
  run
  {utl\comment.i} */  
    xmlchar-decode(iDM, output oDM).
    
  return repTegforDm (oDM).
end.

{&CommentStartNoClass}
method private logical CheckGtin
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function CheckGtin return logical 
{utl\comment.i} */ 
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else 
      vGtin = no.
   return vgtin.
end.

{&CommentStartNoClass}
method private character repSpecSimbforXlm
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function repSpecSimbforXlm return char 
{utl\comment.i} */ 
(iDM as char ):
  
    iDM = replace(iDM,chr(29),"").
    return iDM.
        
end.

{&CommentStartNoClass}
method private character getGtinByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getGtinByDM return char 
{utl\comment.i} */ 
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"   
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
   
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7 
      then 
         vGtin = substring(vtxt,1,14).
      
       
       
      /*if     length(vGtin) > 14
         and length(vGtin) ne 18
         and length(vGtin) ne 20
      then 
         vGtin = ?.*/
   end.
     
  
   if not checkGtin(vGtin)
   then
      vGtin = "". 
   return vgtin.    
end.



{&CommentStartNoClass}
method private integer getGdsCodeByGtin
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getGdsCodeByGtin return int 
{utl\comment.i} */ 
(iGtin as char):
   
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.

{&CommentStartNoClass}
method private decimal getQntyCodeByGtin
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getQntyCodeByGtin return decimal  
{utl\comment.i} */ 
(iGtin as char):
   
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.

{&CommentStartNoClass}
method private integer getGdsCodeByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getGdsCodeByDM return int 
{utl\comment.i} */ 
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
    
end.

{&CommentStartNoClass}
method private logical ChekTypeMarkByGds
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ChekTypeMarkByGds return logical 
{utl\comment.i} */
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code 
                           and goods-attr.attr-code  = {&attr-mark-type}
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.                        
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp 
   /*       or goods-attr.attr-value = objsrv:Env:Marking:Types:stiki:NameProp 
          or goods-attr.attr-value = objsrv:Env:Marking:Types:NSJ  :NameProp
     */     .
   end.
   else 
      return no.
end.

{&CommentStartNoClass}
method private logical ChekTypeMarkByDm
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ChekTypeMarkByDm return logical 
{utl\comment.i} */
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
{&CommentStartNoClass}
method private logical ChekTypeMarkByGtin
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ChekTypeMarkByGtin return logical 
{utl\comment.i} */
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.

/*
КИ
+ 14 + 7 + 4               = 25 табачная (14 + 7 + 4) КИ
+ 2 + 14 + 2 + 13          = 31 Обувные товары,Шины,Духи,одежды,Велосипеды,Кресла-коляски,молочные ("01" + 14 + "21" +13)
+ 2 + 14 + 2 + 20          = 38 Фотокамеры
+ 2 + 14 + 2 + 13 + 2 + 6  = 39 молочные ( "01" + 14 + "21" + 13 + "17" + 6  )
+ 2 + 14 + 2 + 13 + 4 + 10 = 45 молочные

КИН
- 2 + 14 + 2 + 13          = 31 Духи,одежды ("01" + 14 + "21" +13)

КИГУ
- 2 + 14 + 2 + 13          = 31 молочные ("01" + 14 + "21" +13)
- 2 + 14 + 2 + 13 + 2 + 6  = 39 молочные ( "01" + 14 + "21" + 13 + "17" + 6  )
+ 2 + 14 + 2 + 13 + 4 + 8  = 43 молочные
+ 2 + 14 + 2 + 7 + 4 + 6   = 35 табачная
+ 2 + 14 + 2 + 7           = 25 табачная ("01" + 14 + "21" + 7)

КИТУ
+ 18 Обувные товары,Шины,Духи,одежды,Велосипеды,Кресла-коляски,Фотокамеры,молочные
+ 2 + 14 + 2 + 6 + 2 (до +20) = 26 - 46 табачная ("01"("02") + 14 + "11"("13") + 6 + 21 (до +20)
+ 20 табачная
*/

{&CommentStartNoClass}
method private character  GetNextElement
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetNextElement return character  
{utl\comment.i} */ 
  (input iAllTeg        as logical
  ,output oteg          as character 
  ,output otegval       as character
  ,input-output pstr    as character 
  /*,input        iLength as character*/ ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)". /* ,(8005),8005".*/
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006". /* ,000006,0006".*/
     
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)". 
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code. 
   
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
/*     else do:                                                                                                           */
/*        if mtypemark eq objsrv:Env:Marking:Types:milk:NameProp or mtypemark eq objsrv:Env:Marking:Types:milk-40:NameProp*/
/*        then do:                                                                                                        */
/*           entry (4,vlistleng) = "06".                                                                                  */
/*        end.                                                                                                            */
/*        else if mtypemark eq objsrv:Env:Marking:Types:tabak:NameProp                                                    */
/*             or mtypemark eq objsrv:Env:Marking:Types:stiki:NameProp                                                    */
/*             or mtypemark eq objsrv:Env:Marking:Types:NSJ  :NameProp                                                    */
/*        then do:                                                                                                        */
/*           entry ( 4,vlistleng) = "07".                                                                                 */
/*           entry (10,vlistleng) = "07".                                                                                 */
/*        end.                                                                                                            */
/*     end.                                                                                                               */
     if iAllTeg
     then 
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
     
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.

{&CommentStartNoClass}
method private character  GetCodeIdent
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetCodeIdent return character  
{utl\comment.i} */ 
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   
   for first marking no-lock where 
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     /* если марка есть в базе и это транспортная упаковка, */
     /* то КМ не определяем */
     return iDm.  
   end.
   
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins {&tech-mark-prefix}
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24 /* 2 + 14 + 2 + 6(пока минимум для молока)  */
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:      
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then 
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else 
         oCodeIdent = iDM.
   end.   
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
            
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then 
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.

end.

{&CommentStartNoClass}
method private character  GetTegCod
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetTegCod return character  
{utl\comment.i} */ 
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
       
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21" 
      then  
         oTeg = substring(icodeIdent,15,7).
   end.
   else do: 
      ChekTypeMarkByDm(icodeIdent).
      block-teg: 
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")" 
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.

end.

{&CommentStartNoClass}
method private logical isOAD
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function isOAD return logical 
{utl\comment.i} */ 
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.

{&CommentStartNoClass}
method private logical isMark
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function isMark return logical 
{utl\comment.i} */ 
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
   

{&CommentStartNoClass}
method private character  addBracketForCode
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function addBracketForCode return character  
{utl\comment.i} */ 
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   
   define buffer marking for ub.marking.
   
   find first marking no-lock where 
              marking.mark begins icodeIdent no-error.  
   
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.  
   else do: 
      if (  icodeIdent begins "01" 
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14)) 
         and substring (icodeIdent,17,2) eq "21"
      then do:      
         mMRCCode = yes. 
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
            
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.   
   return oTeg.

end.



{&CommentStartNoClass}
method private integer getlevelByCodId
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getlevelByCodId return int 
{utl\comment.i} */ 
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then 
      Vlevel = 4.
   else if vLength eq 21
   then 
      Vlevel = 1.
   else if vLength eq 25 /* табак */
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11" /*табак*/
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31 /* 2 + 14 + 2 + 7 + 4 + 6*/
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45    
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43 
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.   
   else 
      Vlevel = ?.
   return Vlevel. 
end.

/*
КИ
+ 14 + 7 + 4               = 25 табачная (14 + 7 + 4) КИ
+ 2 + 14 + 2 + 13          = 31 Обувные товары,Шины,Духи,одежды,Велосипеды,Кресла-коляски,молочные ("01" + 14 + "21" +13)
+ 2 + 14 + 2 + 20          = 38 Фотокамеры
+ 2 + 14 + 2 + 13 + 2 + 6  = 39 молочные ( "01" + 14 + "21" + 13 + "17" + 6  )
+ 2 + 14 + 2 + 13 + 4 + 10 = 45 молочные

КИН
- 2 + 14 + 2 + 13          = 31 Духи,одежды ("01" + 14 + "21" +13)

КИГУ
- 2 + 14 + 2 + 13          = 31 молочные ("01" + 14 + "21" +13)
- 2 + 14 + 2 + 13 + 2 + 6  = 39 молочные ( "01" + 14 + "21" + 13 + "17" + 6  )
+ 2 + 14 + 2 + 13 + 4 + 8  = 43 молочные
+ 2 + 14 + 2 + 7 + 4 + 6   = 35 табачная
+ 2 + 14 + 2 + 7           = 25 табачная ("01" + 14 + "21" + 7)

КИТУ
+ 18 Обувные товары,Шины,Духи,одежды,Велосипеды,Кресла-коляски,Фотокамеры,молочные
+ 2 + 14 + 2 + 6 + 2 (до +20) = 26 - 46 табачная ("01"("02") + 14 + "11"("13") + 6 + 21 (до +20)
+ 20 табачная
*/
{&CommentStartNoClass}
method private character  getLevelMotpBycodid
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getLevelMotpBycodid return character  
{utl\comment.i} */ 
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.

{&CommentStartNoClass}
method private character    getLevelUTDByLevelMotp
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getLevelUTDByLevelMotp return character    
{utl\comment.i} */ 
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.

{&CommentStartNoClass}
method private character  getLevelMotpByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getLevelMotpByDM return character  
{utl\comment.i} */ 
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.

{&CommentStartNoClass}
method private character  getLevelUTDByCodId
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getLevelUTDByCodId return character  
{utl\comment.i} */ 
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.

{&CommentStartNoClass}
method private character  getLevelUTDByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getLevelUTDByDM return character  
{utl\comment.i} */ 
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
{&CommentStartNoClass}
method private decimal getQntyUTDByCodId
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getQntyUTDByCodId return decimal    
{utl\comment.i} */ 
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then 
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.

{&CommentStartNoClass}
method private decimal getQntyUTDByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getQntyUTDByDM return decimal    
{utl\comment.i} */ 
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25 
      and length (iDm) ne 29 
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then   
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.

{&CommentStartNoClass}
method private decimal    getMRC4
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getMRC4 return decimal    
{utl\comment.i} */ 
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   
  /* if keycode(substring(iMRC,1,1)) eq keycode("A") /* онадеимся что пачка не стои больше 5120.00 руб */
   then*/ do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.

{&CommentStartNoClass}
method private decimal    getMRCByDM
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getMRCByDM return decimal    
{utl\comment.i} */ 
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4 
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
      
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.

{&CommentStartNoClass}
method private date    MoveDate
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function MoveDate return Date    
{utl\comment.i} */ 
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
     
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.               
end.


{&CommentStartNoClass}
method private logical    checkEMRC
(input  iDm as char,
 output vOk as logical):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.    
{utl\comment.i} */ 

   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code. 
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).      
      &scop proc-name gds-attr-value
      {&run_proc_attr-lib}
         (
          input   vgds-code
         ,input   {&attr-emrc-type}
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + {&delim-par} + v-value-emrc.
          find last code where Code.parent      eq vparent 
                           and Code.code        le vDateIso
                           and code.status_  eq {&bef-current-status-int}
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).   
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq {&bef-current-status-int} no-lock no-error.
              if available code
              then 
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq {&bef-current-status-int}
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:        
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq {&bef-current-status-int}
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  {&new-line},
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  {&new-line},
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.   
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
              
          end.
       end.
   end.
      
end.       
{&CommentStartNoClass}
method private character addGs2Mark
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function addGs2Mark return character    
{utl\comment.i} */ 
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
                                     
   if index(iMark,chr(29),1) > 0 
   then return iMark.              
                        
   if substring(iMark,26,4) = "8005" then
   do:   /* табак блок */
     vIdx = index(iMark,"93",26 + 4 + 5). /* по правилам надо бы 6, а не 5, но бывают кривые марки */
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
                      
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.                  
     end.                   
     else 
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.        
   end.
   else if substring(iMark,32,2) = "91" then
   do:  /* легпром, духи, обувь, шины, лекарства, велосипеды, кресла-коляски, консервы  */
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else 
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:  /* фото */
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else 
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:  /* молочная продукция */
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else 
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:  /* упак. вода, БАД, пиво, антисептики */
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
                                    
   return if vDM <> "" then vDm else iMark.
end.

&endif
