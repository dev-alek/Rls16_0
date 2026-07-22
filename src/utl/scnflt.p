block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scnflt.p $
$Archive: utl/scnflt.p $

Вызов внешней программы Сканер -> Файл сканера

Автор: Перваков Михаил Сергеевич
Дата создания: 08/27/03
Author: Mikhail Pervakov
Creation date: 08/27/03

*/


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scnflt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/scnflt.p $":U .
define variable vss-description as character no-undo initial "Вызов внешней программы Сканер -> Файл сканера".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }


do
on error undo, return error return-value
:

  define variable v-section      as character no-undo .
  define variable v-key          as character no-undo .
  define variable v-command-line as character no-undo .

  assign
    v-section = 'mob_scan':u
    v-key     = 'scan_com':u
  .

  get-key-value section v-section key v-key value v-command-line .
  if v-command-line = ?
  then do:
    define variable v-exefile as character no-undo .
    define variable v-inifile as character no-undo .

    run gbl/getexini.p
      (output v-exefile
      ,output v-inifile
      ) no-error .
    message
      "Не задана командная строка в *.ini файле" skip
      "*.ini файл" v-inifile skip
      "Секция" v-section skip
      "Ключ" v-key skip
      view-as alert-box error .
  end.
  else do:
    run waitfram-show in this-procedure
      (input substitute("Внешняя программа. Секция &1. Ключ &2. Командная строка &3"
                        ,v-section
                        ,v-key
                        ,v-command-line
                        )
      ) .

    os-command no-wait value (v-command-line) .

    run waitfram-hide in this-procedure .
  end.
end.