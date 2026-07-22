block-level on error undo, throw.
/*

$Revision: e47eaee10c88, 211, rls $
$Author: SShalanin $
$Date: Tue Jun 30 11:11:56 2015 +0400 $
$Workfile: mcr-exl.p $
$Archive: rep/mcr-exl.p $

Запуск отчетов с выводом в Excel

Автор: Шаланин Сергей Владимирович
Дата создания: 06/02/15
Author: Shalanin Sergey
Creation date: 06/02/15

*/

define variable vss-revision    as character no-undo init "$Revision: e47eaee10c88, 211, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:11:56 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mcr-exl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/mcr-exl.p $":U .
define variable vss-description as character no-undo init "Запуск отчета с выводом в excel".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: mcr-exl.p $ $Revision: e47eaee10c88, 211, rls $".

{ gbl/paramls.i  }

define input parameter  v-file-name as character no-undo .
define output parameter v-excel-name as character no-undo.
define stream  inStream  .
define variable v-count  as integer no-undo .

do
on error undo, return error return-value
:

  define variable v-param-code     as character no-undo .
  define variable v-param-sub-code as character no-undo .
  define variable v-param-value    as character no-undo .

  input stream instream from value (v-file-name) .
  repeat
  :
    assign
      v-count = v-count + 1
    .

    assign
      v-param-code     = ''
      v-param-sub-code = ''
      v-param-value    = ''
    .

    import stream instream
      v-param-code
      v-param-sub-code
      v-param-value
      .
    create temp-param .
    assign
      temp-param.param-code     = v-param-code
      temp-param.param-sub-code = v-param-sub-code
      temp-param.param-value    = v-param-value
    .
  end.
  input stream instream close .

  define variable v-ok as logical   no-undo .
    run rep/z-exl.p
      (input-output table temp-param,
      output v-excel-name
      ) .

  /* удаляем файлы отчета */
  os-delete value (v-file-name) .

  define buffer buf_temp-param for temp-param .
  for each buf_temp-param
    where buf_temp-param.param-code = "file"
  on error undo, return error
  :
    os-delete value(buf_temp-param.param-value) .

  end.
end.