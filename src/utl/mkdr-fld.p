block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mkdr-fld.p $
$Archive: utl/mkdr-fld.p $

Создание файла препроцессингов для регистров расчета правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mkdr-fld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mkdr-fld.p $":U .
define variable vss-description as character no-undo init "Создание файла препроцессингов для регистров расчета правил скидок".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }

define variable v-rus-num-lines as integer   no-undo .
define variable v-eng-num-lines as integer   no-undo .

define temp-table temp-definitions no-undo
  field temp-name as character
  field temp-rus-line as integer
  field temp-eng-line as integer

  index xpk is primary unique temp-name .

define stream sinp .
define stream sout .

do
on error undo, leave
on stop  undo, leave
:
  define variable v-ok as logical   no-undo .

  message
    "Создание файлов определений dr-flddf.i" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, leave .
  end.

  run waitfram-show in this-procedure
    (input "Создание файла определений cmp/dr-flddf.i"
    ) .

  run cmp/dr-flddf.p
    (input 'cmp'
    ,output v-rus-num-lines
    ) 'rus':U .

  run waitfram-show in this-procedure
    (input "Создание файла определений int/dr-flddf.i"
    ) .

  run cmp/dr-flddf.p
    (input 'int':U
    ,output v-eng-num-lines
    ) 'eng':U .

  run waitfram-show in this-procedure
    (input "Проверка файлов определений cmp/dr-flddf.i, int/dr-flddf.i"
    ) .

  define variable v-line     as character no-undo .
  define variable v-line-num as integer   no-undo .

  assign
    v-line-num = 0
  .

  input stream sinp from value('cmp/dr-flddf.i':U) .
  repeat
  :
    assign
      v-line     = '':U
      v-line-num = v-line-num + 1
    .
    import stream sinp unformatted
      v-line
      .
    if v-line begins '&glob'
    then do:
      find first temp-definitions
        where temp-definitions.temp-name = entry(2, v-line, ' ':U)
        no-error .
      if not available temp-definitions
      then do:
        create temp-definitions .
        assign
          temp-definitions.temp-name     = entry(2, v-line, ' ':U)
        .
      end.
      assign
        temp-definitions.temp-rus-line = v-line-num
      .
    end.
  end.
  input stream sinp close .

  assign
    v-line-num = 0
  .

  input stream sinp from value('int/dr-flddf.i':U) .
  repeat
  :
    assign
      v-line     = '':U
      v-line-num = v-line-num + 1
    .
    import stream sinp unformatted
      v-line
      .
    if v-line begins '&glob'
    then do:
      find first temp-definitions
        where temp-definitions.temp-name = entry(2, v-line, ' ':U)
        no-error .
      if not available temp-definitions
      then do:
        create temp-definitions .
        assign
          temp-definitions.temp-name     = entry(2, v-line, ' ':U)
        .
      end.
      assign
        temp-definitions.temp-eng-line = v-line-num
      .
    end.
  end.
  input stream sinp close .


  define variable v-clear-file  as logical   no-undo .
  define variable v-error-exist as logical   no-undo .

  assign
    v-clear-file = true
  .

  for each temp-definitions
    where temp-definitions.temp-rus-line = 0
       or temp-definitions.temp-eng-line = 0
  on error undo, return error return-value
  :
    assign
      v-error-exist = true
    .
    if v-clear-file = true
    then do:
      assign
        v-clear-file = false
      .
      output stream sout to value('dr-flddf_err.txt':U) .
      output stream sout close .
    end.

    output stream sout to value('dr-flddf_err.txt':U) append .
    export stream sout temp-definitions .
    output stream sout close .
  end.

  run waitfram-hide in this-procedure .

  if v-error-exist = true
  then do:
    message
      "Были обнаружены ошибки при создании файлов" skip
      "" skip
      "Создание файлов определений dr-flddf.i завершено" skip
      "Файл" 'cmp / dr-flddf.i':U skip
      "Строк в файле" v-rus-num-lines skip
      "Файл" 'int / dr-flddf.i':U skip
      "Строк в файле" v-eng-num-lines skip
      view-as alert-box error .

    run gbl/open_url.p
      (input search('.':u + '/':u + 'dr-flddf_err.txt':U)
      ) .
  end.
  else do:
    message
      "Создание файлов определений dr-flddf.i завершено" skip
      "Файл" 'cmp / dr-flddf.i':U skip
      "Строк в файле" v-rus-num-lines skip
      "Файл" 'int / dr-flddf.i':U skip
      "Строк в файле" v-eng-num-lines skip
      view-as alert-box information  .
  end.

end.

quit .