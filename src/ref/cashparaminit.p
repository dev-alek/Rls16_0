block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 28 янв. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 28 янв. 2023 г.

*/
using ibs.th.gbl.*.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ gbl/cd-attr.i}
define variable Types      as ibs.th.str.cash.CashDevice no-undo.
Types = new ibs.th.str.cash.CashDevice().
 do:
   define variable objType    as ibs.th.gbl.propmap no-undo.
   
   define buffer cashcode for ub.code .
   define buffer cashobj  for ub.code .
   define buffer cashgrp  for ub.code .
   define buffer cashkey  for ub.code .
   find first cashcode where cashcode.parent eq ""
                         and cashcode.code   eq "cash-param"
      exclusive-lock no-error.
   if not available cashcode
   then do:   
      create cashcode.
      assign
          cashcode.parent   = ""
          cashcode.code     = "Cash-param"
      .
   end.
   
   assign
       cashcode.Codename = "Справочник параметров кассы"
       cashcode.nwsgbd   = yes
       cashcode.export_  = yes
       cashcode.procview = "ibs/th/ref/code/cashparams.p"
   .
   define variable v-ii as integer no-undo.
   do v-ii = 1 to Types:mapType:GetItem(v-ii):
      objType = Types:CurrProp.
      find first cashcode where cashcode.parent eq "cash-param"
                            and cashcode.code   eq string(objType:KeyInt)
      exclusive-lock no-error.
      if not available cashcode
      then do:
         create cashcode.
         assign
           cashcode.parent  = "cash-param"
           cashcode.code    = string(objType:KeyInt)
         .
      end.
      assign
         cashcode.nwsgbd  = yes
         cashcode.export_ = yes
      .
      cashcode.CodeName = objType:Label_.
      find first cashobj where cashobj.parent    = cashcode.parent + {&delim-par} + cashcode.code
                           and cashobj.code      = "1"
      exclusive-lock no-error.
      if not available cashobj
      then do:
         create cashobj.
         assign
           cashobj.parent    = cashcode.parent + {&delim-par} + cashcode.code
           cashobj.code      = "1"
         .
      end.
      assign
        cashobj.CodeName  = "Параметры"
        cashobj.nwsgbd    = yes
        cashobj.export_   = yes
        cashobj.procview     = "ref/cashparamg.w"
      .
      find first cashobj where cashobj.parent    = cashcode.parent + {&delim-par} + cashcode.code
                           and cashobj.code      = "2"
      exclusive-lock no-error.
      if not available cashobj
      then do:
         create cashobj.
         assign
           cashobj.parent    = cashcode.parent + {&delim-par} + cashcode.code
           cashobj.code      = "2"
         .
         
      end.
      assign
        cashobj.CodeName  = "Клавиатура"
        cashobj.nwsgbd    = yes
        cashobj.export_   = yes
        cashobj.procview     = "ref/cashparkey.w"
      .
      for each cashkey where cashkey.parent eq "CashFunKey"
      no-lock:
         find first cashgrp where cashgrp.parent    = cashobj.parent + {&delim-par} + cashobj.code
                              and cashgrp.code      = cashkey.code
         exclusive-lock no-error.
         if not available cashgrp
         then do: 
            create cashgrp.
            assign
               cashgrp.parent    = cashobj.parent + {&delim-par} + cashobj.code
               cashgrp.code      = cashkey.code
            .
         end.
         assign
            cashgrp.nwsgbd    = yes
            cashgrp.export_   = yes
            cashgrp.procview     = "ref/codeparam.w"
         .
      end.
   end.
   
end.
 do:
   define buffer cash-desk for ub.cash-desk.
   for each cash-desk where cash-desk.db-num   eq g#db-num  
                        and cash-desk.pos-type eq {&cd-type-Autotank}   
   exclusive-lock:
      
      define variable v-attr-value as character no-undo .
      define variable v-attr-type  as character no-undo .
      define variable v-device-kind as integer no-undo.
      define variable v-date as date no-undo.
      define variable v-decimal as decimal no-undo.
      define variable v-logical as logical no-undo.
      define variable v-dop as character no-undo.
/*      run cd-attr-value in this-procedure                                                             */
/*                                                                                                      */
/*        ( input cash-desk.db-num                                                                      */
/*         ,input cash-desk.obj-code                                                                    */
/*         ,input cash-desk.pos-type                                                                    */
/*         ,input cash-desk.cash-num                                                                    */
/*         ,input  (if cash-desk.pos-type = {&cd-type-ibm-xml}                                          */
/*                                                           then {&cda-IBM-XML_operative}              */
/*                                                           else {&cda-AUTOTANK_operative})            */
/*         ,input  (if cash-desk.pos-type = {&cd-type-ibm-xml}                                          */
/*                                                           then {&cda-IBM-XML_operative_device-kind}  */
/*                                                           else {&cda-AUTOTANK_operative_device-kind})*/
/*         ,output v-attr-value                                                                         */
/*         ,output v-date                                                                               */
/*         ,output v-decimal                                                                            */
/*         ,output v-device-kind                                                                        */
/*         ,output v-logical                                                                            */
/*         ,output v-dop                                                                                */
/*         ) no-error.                                                                                  */
      
      if cash-desk.device-kind = 0
      then do:
         define variable mport as integer  no-undo.
         assign 
         mport = ?
         mport = integer(entry(2
                               ,entry(4
                                      ,entry(2, cash-desk.addr-path, {&delim-par})
                                      ,".":U)
                              , ":"
                              )
                        ) no-error.
         if    mport eq ?
            or mport eq 0
            or mport eq 8000
         then
            v-device-kind = Types:Tanker:KeyIntDB.
         else
            v-device-kind = Types:TankerIntegr:KeyIntDB.
            cash-desk.device-kind = v-device-kind .
/*         run cd-attr-write in this-procedure (     cash-desk.db-num                                   */
/*                                                  ,cash-desk.obj-code                                 */
/*                                                  ,cash-desk.pos-type                                 */
/*                                                  ,cash-desk.cash-num                                 */
/*                                                  ,input  (if cash-desk.pos-type = {&cd-type-ibm-xml} */
/*                                                           then {&cda-IBM-XML_operative}              */
/*                                                           else {&cda-AUTOTANK_operative})            */
/*                                                  ,input (if cash-desk.pos-type = {&cd-type-ibm-xml}  */
/*                                                           then {&cda-IBM-XML_operative_device-kind}  */
/*                                                           else {&cda-AUTOTANK_operative_device-kind})*/
/*                                                  ,input v-attr-value                                 */
/*                                                  ,input v-date /*p-date*/                            */
/*                                                  ,input v-decimal /*p-decimal*/                      */
/*                                                  ,input v-device-kind /*p-integer*/                  */
/*                                                  ,input v-logical /*p-logical*/                      */
/*                                                  ) no-error.                                         */
         
      end.
   end.
end.
delete object Types.