/*
Инклюд функций работы с marking

Автор: Александр Ростовцев
Дата создания: 09.12.2024

*/

{ str/trdcalib.i }

/* Функция возвращает новый статус марки при удалении строки товара документа или всего документа */
function stsMarkWhenDeleteGoods returns integer
    (input iDocCode as character,
     input iMark as character):
        
  define variable vValue as character no-undo.      
  define variable vType as character no-undo.      
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-marking for ub.c-marking.
  
  if iDocCode <> ? then
  do:
      find first buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = iDocCode no-error.
      if avail buf_trn-doc then
      do:
         { str/tdat-val.i
           buf_trn-doc.doc-code
           {&trdcattr-is-return}
           vValue
           vType
           no-error
         }
         if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} or
            buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or
            vValue = "yes" then
         do: /* если СПИСАНИЕ, РАСХОД ВНЕШ ВОЗВРАТ, то проверим предыдущий статус марки */
           find last buf_c-marking no-lock where
                     buf_c-marking.mark = iMark
                use-index pi-2 no-error.
           if avail buf_c-marking and
                   (buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB) then
             return buf_c-marking.sts .
         end. 
      end.
  end.
  return objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
end function.
