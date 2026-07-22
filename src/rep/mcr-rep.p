block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mcr-rep.p $
$Archive: rep/mcr-rep.p $

Состояние Запасов использование - запуск отчетов с выводом в Excel

Автор: Перваков Михаил Сергеевич
Дата создания: 07/18/02
Author: Mikhail Pervakov
Creation date: 07/18/02

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mcr-rep.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/mcr-rep.p $":U .
define variable vss-description as character no-undo init "запуска внешней сессии СОСТОЯНИЕ ЗАПАСА".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: mcr-rep.p $ $Revision: aea5316774be, 0, rls $".

{ gbl/paramls.i  }

define input parameter  v-file-name as character no-undo .

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
    run gbl/macroexl.p
      (input-output table temp-param
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