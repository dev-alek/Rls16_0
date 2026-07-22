
{ utl/crc32.i }
{cmp/str-glbl.i }
define temp-table tt-code like code.
function getCashparamHash returns character ():
    define variable exp as ibs.th.bge.xmlimpexp no-undo.
    define variable hQuery   as handle  no-undo .
    define buffer Buf_code for tt-code.
    define buffer     code for    code.
    FOR EACH code where code.parent begins 'cash-param'
                    and num-entries(code.parent,{&delim-par}) eq 4
    no-lock:
       create Buf_code.
       buffer-copy code except export_ nwsgbd procview procedit to Buf_code.
    end.
    create query hQuery.
    hQuery:set-buffers(buffer Buf_code :HANDLE). 
    hQuery:query-prepare("FOR EACH Buf_code").
    hQuery:query-open ().
   
    exp = new ibs.th.bge.xmlimpexp (). 
    exp:updatetableforxml(hQuery).
    delete object hQuery.
    FOR EACH buf_code:
       delete buf_code.
    end.
    define variable vxmlCode as character  no-undo.
    define variable v-md5-signature as character no-undo.
    exp:xmldom-save  ( "cashparammd5.xml" ).
    vxmlCode = search("cashparammd5.xml").
    run gbl/md5.p (
          input  vxmlCode
         ,output v-md5-signature /* p-md5-signature */
         ) .
    os-delete value (vxmlCode).
/*    exp:xmldom-save("memptr", output vxmlCode).*/
    delete object exp.
    return {utl/chekmd5.i v-md5-signature } .
end.


function getCashParamHashDb returns character (idb as int):
   define buffer code for ub.code.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   no-lock no-error.
   return if available code then Code.CodeValue else ?.        
end.

procedure saveCashParHash:
   define input  parameter iDb as integer no-undo.
   define buffer code for ub.code.
   
   find first code where code.parent eq "" 
                     and code.code   eq "CashParamHash"
   no-lock no-error.
   if not available code
   then do:
      create code.
      assign
         Code.parent   = ""
         Code.code     = "CashParamHash"
         Code.CodeName = "Конрольная сумма Эталонных параметров для кассы"
      .
   end.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   exclusive-lock no-error.
   if not available code
   then do:
      create Code.
      assign
         code.parent = "CashParamHash"
         code.code   =  string(idb)
         Code.nwsubd = yes
      .
   end.
   Code.CodeName  = string(now).
   Code.CodeValue = getCashparamHash().
end.   