 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отслыки справочника оснований чеков коррекций

Автор: Шкляр Елена
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ cmp/str-glbl.i  }

procedure putc :
define input  parameter iSAXWriter as handle no-undo .
define input  parameter i-action   as character  no-undo .
define input  parameter i-value    as character  no-undo .
define output parameter oOK       as logical no-undo.
define buffer code for ub.code.
define buffer code-emc for ub.code.
define variable vi as integer no-undo.
  define variable vDate  as character no-undo.
  if i-action ne "U"
  then do:
     run putc-emrcdel(iSAXWriter).
  end.
  else do:                
     for each code-emc where Code-emc.parent = "EMC"  
     on error undo, return error
     : 
         iSAXWriter:start-element("EMRC_Type") .
         iSAXWriter:insert-attribute("ctrl",   if Code-emc.status_ eq {&bef-current-status-int} then "ADD" else "DEL").
         iSAXWriter:insert-attribute("tsm",    "0").
         iSAXWriter:insert-attribute("code",    string(int(Code-emc.code))).
   
         iSAXWriter:write-data-element("EMRC_TypeName" , Code-emc.CodeName ) .
         iSAXWriter:end-element("EMRC_Type" ).
      
         vdate = iso-date(today - 93).
         find last code where Code.parent eq Code-emc.parent + {&delim-par} + Code-emc.code 
                          and code.code < vdate
         no-lock no-error.
         if avail code
         then
            vdate = code.code.
         for each code where Code.parent eq Code-emc.parent + {&delim-par} + Code-emc.code 
                         and code.code >= vdate 
         on error undo, return error
         : 
            define variable vcode as character no-undo.
            define variable vEMRCDate as character no-undo.
       /*  vEMRCDate =  trim(string( ( (date(Code.misc1) - date( "01/01/1970" ) )* 24 * 3600 + 1 ), ">>>>>>>>>9" )). */
            vEMRCDate = Code.code + " 00:00:00".
            vcode = Code-emc.code.
            vi = vi + 1.
            iSAXWriter:start-element("EMRC_Value") .
            iSAXWriter:insert-attribute("ctrl",   if Code.status_ eq {&bef-current-status-int} then "ADD" else "DEL").
            iSAXWriter:insert-attribute("tsm",    "0").
            iSAXWriter:insert-attribute("code",    string(vi)).
   
            iSAXWriter:write-data-element("EMRC_ValueType" , trim(string(dec(vcode),">>>>9.9")) ) .
            iSAXWriter:write-data-element("EMRC_ValueData" , vEMRCDate).
            iSAXWriter:write-data-element("EMRC_ValuePrice" , Code.CodeValue).
            iSAXWriter:end-element("EMRC_Value" ).
         end. 
      end.
   end.
   oOK = true.
end procedure. /* putc-par */

procedure putc-emrcdel :
define input parameter iSAXWriter as handle no-undo .
   iSAXWriter:start-element("EMRC_Type") .
      iSAXWriter:insert-attribute("ctrl",   "DEL").
      iSAXWriter:insert-attribute("tsm",    "0").
      iSAXWriter:insert-attribute("code",    "*").
   iSAXWriter:end-element("EMRC_Type" ).
   
   iSAXWriter:start-element("EMRC_Value") .
      iSAXWriter:insert-attribute("ctrl",   "DEL").
      iSAXWriter:insert-attribute("tsm",    "0").
      iSAXWriter:insert-attribute("code",    "*").
   iSAXWriter:end-element("EMRC_Value" ).
end procedure. /* putc-par */

/* $Workfile$ e n d */