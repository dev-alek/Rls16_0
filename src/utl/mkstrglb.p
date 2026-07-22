/*

$Revision: 6cc672b19ae2, 2597, rls $
$Author: DRuban $
$Date: Ср сен 23 11:55:30 2020 +0300 $
$Workfile: mkstrglb.p $
$Archive: utl/mkstrglb.p $

Создание файла препроцессингов для системы

Автор: Перваков Михаил Сергеевич
Дата создания: 10/18/05
Author: Mikhail Pervakov
Creation date: 10/18/05

*/


define variable vss-revision    as character no-undo init "$Revision: 6cc672b19ae2, 2597, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Ср сен 23 11:55:30 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mkstrglb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mkstrglb.p $":U .
define variable vss-description as character no-undo init "Создание файла препроцессингов для системы".
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
  &if "iscompil" eq ""
  &then
  message
    "Создание файлов определений str-glbl.i" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, leave .
  end.
  &endif
  run waitfram-show in this-procedure
    (input "Создание файла определений cmp/str-glbl.i"
    ) .
  define variable mFileStr as character no-undo.  
  define variable mdir as character no-undo.
  define variable vi as integer no-undo.
  mFileStr = replace (search ("cmp/str-glbl.p"), "\","/").
  
  do vi = 1 to num-entries(mFileStr,"/") - 2:
     mdir = mdir + entry(vi,mFileStr,"/") + "/".
      
  end.
  
  run cmp/str-glbl.p
    (input mdir + 'cmp'
    ,output v-rus-num-lines
    ) 'rus':U .

  run waitfram-show in this-procedure
    (input "Создание файла определений int/cmp/str-glbl.i"
    ) .

  run cmp/str-glbl.p
    (input mdir + 'int/cmp':U
    ,output v-eng-num-lines
    ) 'eng':U .

  run waitfram-show in this-procedure
    (input "Проверка файлов определений cmp/str-glbl.i, int/cmp/str-glbl.i"
    ) .

  define variable v-line     as character no-undo .
  define variable v-line-num as integer   no-undo .

  assign
    v-line-num = 0
  .

  input stream sinp from value(search('cmp/str-glbl.i':U)) .
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
  v-rus-num-lines = v-line-num.  

  assign
    v-line-num = 0
  .

  if search("int/cmp/str-glbl.i") ne ?
  then do:
     input stream sinp from value(search('int/cmp/str-glbl.i':U)) .
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
  end.
  v-eng-num-lines = v-line-num.
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
      output stream sout to value('str-glbl_err.txt':U) .
      output stream sout close .
    end.

    output stream sout to value('str-glbl_err.txt':U) append .
    export stream sout temp-definitions .
    output stream sout close .
  end.

  run waitfram-hide in this-procedure .
  
  &if "iscompil" eq ""
  &then
  
  if v-error-exist = true
  then do:
    message
      "Были обнаружены ошибки при создании файлов" skip
      "" skip
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле" v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле" v-eng-num-lines skip
      view-as alert-box error .

    run gbl/open_url.p
      (input search('.':u + '/':u + 'str-glbl_err.txt':U)
      ) .
  end.
  else do:
    message
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле" v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле" v-eng-num-lines skip
      view-as alert-box information  .
  end.
  &else
  output to "error.log".
  if v-error-exist = true
  then do:
     put unformatted
      "Были обнаружены ошибки при создании файлов" skip
      "" skip
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле " v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле " v-eng-num-lines skip
    .
  end.
  else do:
     put unformatted
      "OK" skip
      "" skip
      "Создание файлов определений str-glbl.i завершено" skip
      "Файл" 'cmp/str-glbl.i':U skip
      "Строк в файле " v-rus-num-lines skip
      "Файл" 'int/cmp/str-glbl.i':U skip
      "Строк в файле " v-eng-num-lines skip
     .
  end.
  output close.
  &endif
end.

/* quit . */ 