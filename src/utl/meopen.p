block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: meopen.p $
$Archive: utl/meopen.p $

Открыть файл на основании строки запуска меню

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/14/06

*/

define input  parameter p-item-id        as character no-undo .
define input  parameter p-item-procedure as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: meopen.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/meopen.p $":U .
define variable vss-description as character no-undo init "Открыть файл на основании строки запуска меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-search-file-name    as character no-undo .
define variable v-line-number         as integer   no-undo .
define variable v-output-file-name    as character no-undo .
define variable v-grep-line           as character no-undo .
define variable v-command-line-option as character no-undo .
define variable v-full-path           as character no-undo .
define variable v-path                as character no-undo .
define variable v-file-name           as character no-undo .
define variable v-file-name-no-ext    as character no-undo .
define variable v-file-name-ext       as character no-undo .
define variable v-command-line        as character no-undo .
define variable v-grep-file-name      as character no-undo .

do
on error undo, return error return-value
:
  run open-file-in-me in this-procedure
    (input  'cmp/menu.txt':U
    ,input  p-item-id
    ) .

  if p-item-procedure begins 'int,':U
  then do:
    run open-file-in-me in this-procedure
      (input  'gbl/dm-menu.p':U
      ,input  p-item-procedure
      ) .
  end.
  else do:
    run open-file-in-me in this-procedure
      (input  search(entry(2, p-item-procedure, {&comma-char}))
      ,input  '':U
      ) .
  end.
end.


procedure open-file-in-me :

  define input  parameter p-file-name     as character no-undo .
  define input  parameter p-search-string as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      file-info :file-name = search(p-file-name)
      v-search-file-name = file-info :full-pathname
    .
    if  p-search-string <> ?
    and p-search-string <> '':U
    then do:
      assign
        file-info :file-name = search('exe/grep.bat':U)
        v-grep-file-name = file-info :full-pathname
      .
      run gbl/filename.p
        (input  v-grep-file-name
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) .

      run gbl/_tmpfile.p
        (input  '':U
        ,input  '':U
        ,output v-output-file-name
        ) .
      output to value(v-output-file-name) .
      output close .
      assign
        file-info :file-name = v-output-file-name
        v-output-file-name = file-info :full-pathname
      .

      assign
        v-command-line = substitute ("&1 &2 &3 &4 &5"
                                  ,v-grep-file-name
                                  ,v-path
                                  ,entry(2, p-item-procedure, {&comma-char})
                                  ,v-search-file-name
                                  ,v-output-file-name
                                  )
      .
      os-command value(v-command-line) .
      input from value(v-output-file-name) .
      import unformatted v-grep-line .
      input close .
      os-delete value(v-output-file-name) .

      assign
        v-line-number = integer(entry(1, v-grep-line, ':':u))
      .
      assign
        v-command-line-option = substitute(' /L&1':U
                                          ,v-line-number
                                          )
      .
    end.
    else do:
      assign
        v-command-line-option = '':U
      .
    end.

    run gbl/_tmpfile.p
      (input  '':U
      ,input  'bat':U
      ,output v-output-file-name
      ) .

    output to value(v-output-file-name) .
    put unformatted substitute("C:\MEW8.0\MEW32.exe -SNWORK15_0 &1&2"
                                ,v-search-file-name
                                ,v-command-line-option
                                ) + {&new-line} .
    put unformatted 'exit' + {&new-line} .
    output close .

    assign
      file-info :file-name = v-output-file-name
      v-output-file-name = file-info :full-pathname
    .

    os-command value(v-output-file-name) .

    os-delete value(v-output-file-name) .

  end.

end procedure. /* open-file-in-me */