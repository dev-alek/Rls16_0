block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: runexcel.p $
$Archive: rep/runexcel.p $

Запуск дополнительной сессии для вывода в Excel

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

define input parameter tempfile as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: runexcel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/runexcel.p $":U .
define variable vss-description as character no-undo init "Вывод в Excel с запуском дополнительной сессии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }


define variable tempfile-frm as character no-undo .
define variable tempfile-t-t as character no-undo .
define variable res          as character no-undo .
define variable v-cmdln      as character no-undo .
define variable v-exefile    as character no-undo .
define variable v-inifile    as character no-undo .
define variable err-file     as character no-undo .
define variable v-silent     as logical no-undo .
define variable v-mess       as character no-undo .
define buffer buf_sheetf for sheetf.

define stream forformat .

do
on error undo, return error return-value
:
  if make-excel
  then do:
    find first buf_sheetf where
             buf_sheetf.sheet-num = 1.
    if buf_sheetf.silent-save then do:
      v-silent = yes.
    end.
    if not make-excel-com
    then do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .

      run gbl/filename.p
        (input  tempfile
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .

      assign
        tempfile-frm = v-path + '/':u + v-file-name-no-ext + '.':U + 'frm':U
        tempfile-t-t = v-path + '\':u + v-file-name-no-ext + '.':U + 't-t':U
      .

      IF SEARCH(tempfile-t-t) <> ?
      then do:
      /* найдена временная таблица  и значит запускакм через макрос */
         run rep/mcr-rep.p
           (input tempfile-t-t
           ) .

         os-delete  value( tempfile-t-t ) .
         os-delete  value( tempfile  ) .

         define variable err-status as integer   no-undo .
         err-status = OS-ERROR.
         IF err-status <> 0 THEN  return "disable-button":U.
                            else  return.
      end.
      output stream forformat to value(tempfile-frm) .
      for each sheetf no-lock
      on error undo, return error
      :
        export stream forformat sheetf .
      end.
      output stream forformat close.

      /* определяются имена выполняемого файла и *.ini файла */
      run gbl/getexini.p
        (output v-exefile
        ,output v-inifile
        ) no-error .
      if error-status :error
      then do:
        v-mess = substitute("&1 &2 &3&4" +
                            "Ошибка при определении имени выполняемого файла и *.ini файла&4" +
                            "&5&4&6&4"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}
                              ,error-status :get-message(1)
                              ,return-value
                              ).
        if not v-silent then do:
        message
          v-mess
          view-as alert-box error .
        undo, return error .
      end.
        else do:
          undo, return error v-mess.
        end.
      end.

      run gbl/_tmpfile.p ("", "", output err-file) .

      /* формирование командной строки для запуска дополнительной сессии */
      assign
        err-file = err-file + ".err":u
        v-cmdln  = v-exefile
                 + {&space-char} + "-ininame":u + {&space-char} + v-inifile
                 + {&space-char} + "-p":U + {&space-char} + "rep/extexcel.p":u
                 + {&space-char} + "-param":U + {&space-char} + {&double-quote}
                 + tempfile + {&comma-char}
                 + err-file + {&comma-char}
                 + string(make-excel) + {&comma-char}
                 + string(make-excel-com) + {&comma-char}
                 + tempfile-frm + {&double-quote}
      .

      run waitfram-show in this-procedure
        (input "Выполнение команды" + {&space-char} + v-cmdln
        ).

      /* запуск второй сессии с ожиданием завершения */
      run gbl/syn3.p
        (input v-cmdln
        ,input err-file
        ,input "Ждите! Идет форматирование файла..."
        ,output res
        ) no-error .

      run waitfram-hide in this-procedure .
      if res <> '0'
      then do:
        v-mess = substitute("Не  удалось  вывести  файл  в   EXCEL"). /*пробелы не стирать!!!*/
        if not v-silent then do:
          message
          v-mess
        view-as alert-box error.
        undo, return error .
      end.
        else do:
          undo, return error v-mess.
        end.
      end.
    end.
    else do:
      /* если есть открытый ехсел com */
      assign
        ch#ExcelApplication:Interactive    = true
        ch#ExcelApplication:ScreenUpdating = true
        ch#ExcelApplication:Visible        = true
      .
      run ClearExcel.
      output Stream  ForExcel close.

      os-delete  value( string( tempfile ) ) .
    end.
  end. /* if make-excel */

  return .

end.


procedure ClearExcel :

  do
  on error undo, return error
  :
    run waitfram-hide in this-procedure .
    output Stream  ForExcel close.
    { cmp/relescom.i ch#WorkSheet }
    { cmp/relescom.i ch#Workbook }
    assign
      ch#ExcelApplication:Interactive    = true
      ch#ExcelApplication:ScreenUpdating = true
      ch#ExcelApplication:Visible        = true
    .
    { cmp/relescom.i ch#ExcelApplication }
    process events .
  end.

end procedure. /* ClearExcel */