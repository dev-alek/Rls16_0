block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
         iSAXWriter:insert-attribute("ctrl",   if Code-emc.status_ eq 0 then "ADD" else "DEL").
         iSAXWriter:insert-attribute("tsm",    "0").
         iSAXWriter:insert-attribute("code",    string(int(Code-emc.code))).
         iSAXWriter:write-data-element("EMRC_TypeName" , Code-emc.CodeName ) .
         iSAXWriter:end-element("EMRC_Type" ).
         vdate = iso-date(today - 93).
         find last code where Code.parent eq Code-emc.parent + chr(4) + Code-emc.code
                          and code.code < vdate
         no-lock no-error.
         if avail code
         then
            vdate = code.code.
         for each code where Code.parent eq Code-emc.parent + chr(4) + Code-emc.code
                         and code.code >= vdate
         on error undo, return error
         :
            define variable vcode as character no-undo.
            define variable vEMRCDate as character no-undo.
            vEMRCDate = Code.code + " 00:00:00".
            vcode = Code-emc.code.
            vi = vi + 1.
            iSAXWriter:start-element("EMRC_Value") .
            iSAXWriter:insert-attribute("ctrl",   if Code.status_ eq 0 then "ADD" else "DEL").
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
end procedure.
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
end procedure.
