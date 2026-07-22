/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение THheader файла OpenXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ str/xmllib.i }
{ bge/tmpcxmlh.i }

procedure getoxmlh :
define input parameter p-xml-file-name as character no-undo .
define input parameter p-pack-data     as memptr no-undo . 
define input parameter p-headerh as handle no-undo .
define input parameter p-delivery-method as integer no-undo .
define variable v-parse-status as integer no-undo .
define buffer buf_rec for temp_xmllib_rec.
define buffer buf_rec-fld for temp_xmllib_rec-fld.
define variable v-end-of-header as logical   no-undo .
define variable v-ii as integer   no-undo .
define variable v-root-name as character no-undo .

define buffer buf_temp_xmllib_rec for temp_xmllib_rec.


do
on error undo, return error return-value
:
  run xmllib-clear-parse-data in this-procedure.
  if valid-handle(p-headerh) then do:
  do v-ii = 1 to p-headerh:num-fields:
    run xmllib-add-rec-fld  in this-procedure (
                                                 input p-headerh:table
                                                ,input (p-headerh:buffer-field(v-ii):name)
                                              )  .
  end.
  end.
  case p-delivery-method:
    when integer({&esys-dm-oracle-retail}) then do:
      v-root-name = "Oracle_Retail".
      run xmllib-add-rec-fld  in this-procedure (
                                                    input v-root-name
                                                  ,input ""
                                                )  .
    end.
    when integer({&esys-dm-exite-edi}) then do:
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ORDER_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "STATUS__"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ORDRSP_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "DESADV_"
                                                  ,input ""
                                                )  .
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "RECADV_"
                                                  ,input ""
                                                )  .
    end.
    when integer({&esys-dm-contour-edi}) then do:
            run xmllib-add-rec-fld  in this-procedure (
                                                    input "statusReport"
                                                  ,input ""
                                                )  .
    end.
    when integer({&esys-dm-erp-1C-RN}) then do:
      v-root-name = "".
      run xmllib-add-rec-fld  in this-procedure (
                                                    input "ERPRN-GC"
                                                  ,input ""
                                                )  .
    end.
    otherwise do:
      v-root-name = "".
      run xmllib-add-rec-fld  in this-procedure (
                                                input v-root-name
                                               ,input ""
                                            )  .

    end.
  end case.
    
  run xmllib-parse-progressive ( input p-xml-file-name
                                ,input p-pack-data
                                ,input yes /*p-parse-first*/
                                ,input no /*p-first-error*/
                                ,output v-parse-status) no-error .
  repeat while not (error-status:error
                    or
                    v-parse-status = sax-complete
                    or available buf_temp_xmllib_rec

                    ):
    if valid-handle(p-headerh)  then do:
    find first buf_temp_xmllib_rec where
              buf_temp_xmllib_rec.recname = p-headerh:table
          and buf_temp_xmllib_rec.closed = yes no-error.
    end.
    else do:
      find first buf_temp_xmllib_rec no-error.
    end.
    error-status:error = no .
    run xmllib-parse-progressive ( input p-xml-file-name
                                  ,input p-pack-data
                                  ,input no /*p-parse-first*/
                                  ,input no /*p-first-error*/
                                  ,output v-parse-status) no-error .

  end.
end.

end procedure. /* getoxmlh */