block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Генерация и отправка файла-ответа для 1С РН

Автор: Сливенко Сергей
Дата создания: 20/11/17
Author: Slivenko Sergey
Creation date: 20/11/17

Input:
    p-sender-id - (chr)
    p-pck-num   - (int) - номер пакета, тег <num>
    p-status_   - (int)
    p-error     - (chr) - текст ошибки, тег <error>
    p-esys-id

*/
define input parameter p-sender-id   as character no-undo .
define variable        v-receiver-id as character no-undo initial '00000' .
define input parameter p-pck-num as integer no-undo .
define input parameter p-status_ as integer no-undo .
define input parameter p-error   as character no-undo .
define input parameter p-esys-id like ub.ext-system-attr.esys-id    no-undo .
define input parameter p-cert-subj-name   as character no-undo .
define input parameter p-cert-issuer-name as character no-undo .
define input parameter p-sign-fileext     as character no-undo .
define input parameter p-cert-repository  as integer no-undo .
define input parameter p-pkcs             as class ibs.th.gbl.pkcs no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Генерация и отправка файла-ответа для 1С РН".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/esallatr.i  work }
{ bge/esysattr.i }
// { gbl/db-attr.i  }
{ bge/oxml-def.i }

function esys-id-format returns character ( input p-esys-id as integer):
  return string(p-esys-id, "99999").
end.

FUNCTION nws-db-format returns character ( input p-db-num as integer):
  define variable v-nws-db-format as character no-undo .
  assign
    v-nws-db-format = string( p-db-num,  (if p-db-num > 999 then "99999":U else "999":U ) )
  .
  return v-nws-db-format.
END FUNCTION.

define variable sw as handle no-undo.
// define variable v-sender-id as character no-undo .
define variable v-work-dir as character no-undo .
define variable v-filename as character no-undo .
define variable v-target-dir as character no-undo .
define variable v-target as character no-undo .
define variable v-source as character no-undo .
define variable v-file-no-ext as character no-undo .
define variable v-mess as character no-undo .
DEFINE VARIABLE v-now AS DATETIME NO-UNDO.


v-work-dir   = nws-db-format( ibs.th.gbl.gbl-var:g#db-num ) + "-":U + "ES" + esys-id-format( p-esys-id ) .
v-target-dir = oxml-exch-dir + {&back-slash-char} + v-work-dir .
assign
  file-info:file-name = v-target-dir
.
if file-info:file-type = ?
  or not ( file-info:file-type begins "D":U ) then do:
  os-create-dir value( v-target-dir ).
  if os-error <> 0 then do:
     run gbl/os-errnm.p ( input os-error
                         ,output v-mess) .
     undo, return error substitute("&1 Каталог &2 отсутствует, а создать его не удалось.&3&4"
                           ,vss-workfile
                           ,v-target-dir
                           ,{&new-line}
                           ,v-mess
                         ).
  end.
end.                                                 


v-now = now .
v-file-no-ext = "ack_" + p-sender-id + "_" + v-receiver-id + "_" + string(p-pck-num) + "_"
                          + string(day(v-now), "99") + string(month(v-now), "99") + string(year(v-now), "9999")
                          + replace (  string(TIME, "HH:MM:SS"),  ":",  "") . 
v-filename = v-target-dir + {&back-slash-char} + v-file-no-ext + ".xml" .           



define variable v-packdata as memptr no-undo .
define variable v-signdata as memptr no-undo .
define variable v-position as integer no-undo .
define variable v-sign-file as character no-undo .


  do : /* создать xml-пакет */
    create sax-writer sw.
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-packdata).
   
    sw:encoding = "UTF-8".
    sw:start-document () .
    
    sw:start-element ("GC-ERPRN-ACK") .
    
    
    sw:insert-attribute ("xmlns", "http://www.rosneft.ru/GasComplex/Retail") .
    sw:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
        sw:write-data-element ("num", string(p-pck-num)) .
        sw:write-data-element ("sender-id", p-sender-id) .
        sw:write-data-element ("reciever-id", v-receiver-id) .
        sw:write-data-element ("created-date", iso-date (v-now)) .
        sw:write-data-element ("status", string(p-status_)) .
        sw:write-data-element ("error", p-error) .
    sw:end-element ("GC-ERPRN-ACK") .

    sw:end-document () .
  end . /* end_of создать xml-пакет */
  
    COPY-LOB FROM OBJECT v-packdata TO FILE v-filename NO-CONVERT NO-ERROR .

    if valid-object (p-pkcs) then do on error undo, throw :
      define variable v-err-msg as character no-undo .
      v-err-msg = "" .
          
      v-signdata = p-pkcs:computeSign(v-packdata, p-cert-subj-name, p-cert-issuer-name, p-cert-repository) .
      // взять имя файла p-pack-file без расширения
      v-position = r-index(v-filename, ".") .
      v-sign-file = if v-position > 0 then substring(v-filename, 1, v-position - 1) else v-filename .
      v-sign-file = substitute("&1.&2", v-sign-file, p-sign-fileext) .
      COPY-LOB FROM OBJECT v-signdata TO FILE v-sign-file NO-CONVERT .

      catch exAppErrors as class Progress.Lang.AppError :
        v-err-msg = exAppErrors:ReturnValue .
        if v-err-msg > "" then . else do :
          v-err-msg = exAppErrors:GetMessage(1) . 
          if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
        end .
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
        v-err-msg = exProErrors:GetMessage(1) . 
        if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
        v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
      end catch .
      finally: 
        set-size(v-signdata) = 0 .
        if v-err-msg > "" then
          undo, return error v-err-msg .
      end finally.
    end . // end_of if_cert
    set-size(v-packdata) = 0 .

        
    os-command silent
            value( search('exe/pkzipc.exe':U) )
            value( "-add -path=none -span=700 ":U )
            value( v-target-dir + "\" + v-file-no-ext + ".zip"  )
            value( v-target-dir + "\" + v-file-no-ext + ".*"  )
          .
    os-delete value(v-filename) .
    if valid-object (p-pkcs) then os-delete value(v-sign-file) .
