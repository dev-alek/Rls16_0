/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/29/10
Author: Bakhtadze Natalya
Creation date: 04/29/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if lookup("print-plain-text", "{1}") > 0 &then

{ gbl/prn-lib.i }


procedure reprumpr_print-plain-text :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo . /*надо заполнять только при печати по расписанию*/
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define variable v-err-status as integer no-undo .
define variable v-err-mess as character no-undo .
v-file-name = p-dir-name + (if p-subdir-name <> ''
                            then (p-subdir-name + {&slash-char})
                            else '') +
              p-custom-name.

run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
os-copy
value(v-report-name)
value(v-file-name)
.
assign
v-err-status = os-error
.
if v-err-status <> 0 then do:
  run gbl/os-errnm.p ( input v-err-status
                      ,output v-err-mess).
  return error v-err-mess.
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input {&output-type-plain-text}
                                                ,input v-file-name
                                                ,input string(p-disable-option) + {&delim-par} + string(p-font-number) /*disabledoption + font name*/
                                                ).
end.
end procedure. /* reprumpr_print-plain-text */
&endif

&if lookup("print-printer", "{1}") > 0 &then

{ gbl/prn-lib.i }

procedure reprumpr_print-printer :
define input parameter p-font-number as integer no-undo .
define input parameter p-flags as integer no-undo .
define variable v-quest-print as logical no-undo .
define variable lok as logical no-undo .
define variable v-report-name as character no-undo .
run get-quest-print in parparentproc ( output v-quest-print) .
if not v-quest-print then do:
  &scop my-message "Печатаем на принтер..."
  {&display-message}.
  run prn-lib-get-report-name  in this-procedure (
                                                    input parParentProc
                                                   ,output v-report-name
                                                  ).

  /* Output to Printer */
  run adecomm/_osprint.p
    (input  ?                                       /* p_Window     */
    ,input  v-report-name                           /* p_PrintFile  */
    ,input  p-font-number                           /* p_FontNumber */
    ,input  p-flags                                  /* p_PrintFlags */
    ,input  0                                       /* p_PageSize   */
    ,input  0                                       /* p_PageCount  */
    ,output lok                                     /* p_Printed    */
    ).
  if not lok then do:
  end.
end. /*if not v-quest-print then do*/
end procedure. /* reprumpr_print-printer */
&endif

&if lookup("print-xls", "{1}") > 0 &then

{ gbl/prn-lib.i }

procedure reprumpr_print-xls :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo . /*надо заполнять только при печати по расписанию*/
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .

define variable v-file-name as character no-undo .
define variable v-report-name as character no-undo .
define buffer buf_sheetf for sheetf.
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                 ,output v-report-name
                                                ).
v-file-name = p-dir-name +
             (if p-subdir-name <> ''
             then (p-subdir-name + {&slash-char})
             else '') +
             p-custom-name.
find first buf_sheetf where
         buf_sheetf.sheet-num = 1.
assign
buf_sheetf.file-name = v-file-name
buf_sheetf.silent-save = yes
.
release buf_sheetf.
run rep/runexcel.p ( input (v-report-name + ".txt")) no-error.
if error-status:error then do:
  return error return-value .
end.
else do:
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input {&output-type-excel}
                                                ,input v-file-name
                                                ,input string(p-disable-option) + {&delim-par} + string(p-font-number) /*disabledoption + font name*/
                                                ).
end.
end procedure. /* reprumpr_print-xls */
&endif

&if lookup("print-xlt", "{1}") > 0 &then

{ gbl/prn-lib.i }
define stream temp-stream.
{ rep/prnexldl.i }

define stream reprumpr_in.

procedure reprumpr_print-xlt :
define input parameter p-dir-name as character no-undo .
define input parameter p-subdir-name as character no-undo .
define input parameter p-custom-name as character no-undo .
define input parameter p-disable-option as integer no-undo .
define input parameter p-font-number as integer no-undo .



define buffer buf_temp-param for temp-param .
define variable v-report-num            as integer no-undo .
define variable v-filename              as character    no-undo .
define variable v-obj-dir               as character    no-undo .
define variable v-report-filename       as character    no-undo .
define variable v-home-dir-filename     as character    no-undo .
define variable v-error-num             as integer      no-undo .
define variable v-template-file-name    as character    no-undo .
define variable v-vb-file-name          as character    no-undo .
define variable v-data-header-filename  as character    no-undo .
define variable v-data-filename         as character    no-undo .
define variable v-excel-file-name       as character    no-undo .
define variable v-err-message           as character    no-undo .
define variable v-os-err-str            as character    no-undo .
define variable v-report-dir            as character    no-undo .


do for buf_temp-param
on error undo, return error return-value
:
assign
  v-report-dir  = trim( replace( p-dir-name, '/' , '\' ) , '\' )
.
/*  run get-report-num  in parparentproc (*/
/*                                                  output v-report-num*/
/*                                                ).*/
  assign
  v-report-num = g#report-num
  v-obj-dir           = v-report-dir + {&slash-char} +
                        (if p-subdir-name <> '' then (p-subdir-name + {&slash-char}) else '')
  v-filename          = string( session:temp-directory ) + {&DF_Name} + string( v-report-num )
  v-excel-file-name   = string( session:temp-directory ) + {&DF_Name} + string( v-report-num ) + ".xls"
  v-home-dir-filename = v-obj-dir +  p-custom-name
  .
  os-delete value( v-filename + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( v-report-num ) + ".txl" )
    value( v-filename + ".txl" )
  .
  assign
    v-filename = search( v-filename + ".txl" )
  .
  if v-filename = "" or v-filename = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл &1 для формирования Excel-файла по объекту p-custom-name"
                                                , string( session:temp-directory ) + {&DF_Name} + string( v-report-num )
                                                )
    .
    return error v-err-message.
  end.

  input stream reprumpr_in from value( v-filename ).
  import stream reprumpr_in v-template-file-name   no-error .
  import stream reprumpr_in v-vb-file-name         no-error .
  import stream reprumpr_in v-data-header-filename no-error .
  import stream reprumpr_in v-data-filename        no-error .
  input stream reprumpr_in close.
  if search( v-template-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден шаблон Excel для вывода данных.&2Указан файл шаблона:&1&2&2"
                                                , v-template-file-name
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.
  if search( v-vb-file-name ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден текст программы заполнения шаблона Excel.&3Файл шаблона:&1&3Указан файл программы:&2&3&3"
                                                , v-template-file-name
                                                , v-vb-file-name
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.
  if v-data-header-filename <> "":U
  and search( v-data-header-filename ) = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл шапки.&3Файл шаблона:&1&3Указан файл шапки:&2&3&3"
                                                , v-template-file-name
                                                , v-data-header-filename
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.
  if v-data-filename <> "":U
  and search( v-data-filename )   = ?
  then do:
    assign
      v-err-message = v-err-message + substitute( "Не найден файл строк данных.&3Файл шаблона:&1&3Указан файл строк данных:&2&3&3"
                                                , v-template-file-name
                                                , v-data-filename
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.

  create buf_temp-param.
  assign
    v-template-file-name = search( v-template-file-name )
    file-info :file-name = v-template-file-name
    v-template-file-name = file-info :full-pathname
    v-vb-file-name       = search( v-vb-file-name )
    file-info :file-name = v-vb-file-name
    v-vb-file-name       = file-info :full-pathname
  .

  if v-template-file-name = ? or v-template-file-name = "":U
  then do:
    RETURN error substitute("Не найден шаблон &1", v-template-file-name).
  end.
  run paramls-write in this-procedure ( input {&paramls-template}
                                      , input {&paramls-template-file-name}
                                      , input v-template-file-name
                                      ).
  run paramls-write in this-procedure ( input {&paramls-template}
                                      , input {&paramls-vb-file-name}
                                      , input v-vb-file-name
                                      ).
  run paramls-write in this-procedure ( input {&paramls-data}
                                      , input {&paramls-data-header-filename}
                                      , input v-data-header-filename
                                      ).
  run paramls-write in this-procedure ( input {&paramls-data}
                                      , input {&paramls-data-filename}
                                      , input v-data-filename
                                      ).
  run paramls-write in this-procedure ( input {&paramls-saveas}
                                      , input {&paramls-excel-file-name}
                                      , input v-excel-file-name
                                      ).
  run paramls-write in this-procedure ( input {&paramls-file}
                                      , input {&paramls-file-no-open}
                                      , input "yes":U
                                      ).

  run gbl/macroxlt.p ( input-output table buf_temp-param ) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "&1&2&3&4Ошибка создания файла Excel.&4&5&4&6&4&7&4&8&4&4"
                                                , vss-workfile
                                                , vss-revision
                                                , vss-description
                                                , {&new-line}
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , trim(error-status :get-message(2))
                                                , trim(error-status :get-message(3))
                                                )
    .
    return error v-err-message.
  end.
  run prnexldl_clear in this-procedure ( input v-filename) no-error.
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-filename
                                                , return-value
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.

  run gbl/dir-cre.p ( input v-obj-dir ) no-error  .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка создания директории &1: &2&4&3&4&4"
                                                , v-filename
                                                , return-value
                                                , trim(error-status :get-message(1))
                                                , {&new-line}
                                                )
    .
  end.

  run gbl/del-file.p ( input v-home-dir-filename ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка удаления файла &1: &2 &3&3"
                                                , v-home-dir-filename
                                                , return-value
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.

  run gbl/ren-file.p ( input v-excel-file-name
                  , input v-home-dir-filename
                  ) no-error .
  if error-status :error
  then do:
    assign
      v-err-message = v-err-message + substitute( "Ошибка перемещения файла &1 -> &2: &3&4&4"
                                                , v-excel-file-name
                                                , v-home-dir-filename
                                                , return-value
                                                , {&new-line}
                                                )
    .
    return error v-err-message.
  end.
  run cb_fill-report-destination in p-parent-handle (  input p-rdbh
                                                ,input p-report-id
                                                ,input {&output-type-excel}
                                                ,input v-home-dir-filename
                                                ,input string(p-disable-option) + {&delim-par} + string(p-font-number) /*disabledoption + font name*/
                                                ).

end.
end procedure. /* reprumpr_print-xlt */
&endif

/* $Workfile$ e n d */