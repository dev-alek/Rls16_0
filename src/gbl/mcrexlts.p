block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mcrexlts.p $
$Archive: gbl/mcrexlts.p $

Программа пример запуска внешней сессии

Автор: Перваков Михаил Сергеевич
Дата создания: 07/18/02
Author: Mikhail Pervakov
Creation date: 07/18/02

Основное использование - запуск отчетов с выводом в Excel

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mcrexlts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/mcrexlts.p $":U .
define variable vss-description as character no-undo init "Программа пример запуска внешней сессии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/paramls.i  }
{ gbl/waitfram.i }

define stream slog .

define variable v-row       as integer   no-undo .
define variable v-col       as integer   no-undo .
define variable v-ind       as integer   no-undo .
define variable v-file-name as character no-undo .

do
on error undo, return error return-value
:

  run paramls-clear in this-procedure
    .

  run waitfram-show in this-procedure
    (input "Создание отчета"
    ) .

  run paramls-write in this-procedure
    (input 'rowsgroup-enable':u
    ,input '':u
    ,input 'yes':u
    ) .

  do v-ind = 1 to 2
  :
    run waitfram-show in this-procedure
      (input substitute("Создание отчета. Страница &1", v-ind)
      ) .

    /* создаем временный файл */
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .

    /* выводим в него отчет */
    output stream slog to value(v-file-name) .

    define variable v-max-row as integer   no-undo .
    define variable v-max-col as integer   no-undo .

    assign
      v-max-row = 100
      v-max-col = 100
    .

    do v-row = 1 to v-max-row
    :
      /* вывести данные в ячейку */
      put stream slog unformatted substitute('formula(&3,"r&1c&2")'
        ,v-row /* v-row */
        ,1     /* v-col */
        ,'"Строка ""' + string(v-row) + '"""'
        )
        + {&new-line} .

    end.

    put stream slog unformatted substitute('formula(&3,"r&1c&2")'
      ,1 /* v-row */
      ,1 /* v-col */
      ,'"608E"'
      )
      + {&new-line} .

    put stream slog unformatted substitute('formula(&3,"r&1c&2")'
      ,2 /* v-row */
      ,1 /* v-col */
      ,'"12.02"'
      )
      + {&new-line} .

    do v-row = 1 to v-max-row
    :
      do v-col = 2 to v-max-col
      :
        /* вывести данные в ячейку */
        put stream slog unformatted substitute('formula(&3,"r&1c&2")'
          ,v-row
          ,v-col
          ,string(v-row * v-col + v-ind / 10)
          )
          + {&new-line} .
        define variable v-cell-type as integer   no-undo .
        assign
          v-cell-type = (v-col + v-row) modulo 3
        .
        /* отформатировать ячейку */
        if v-cell-type <> 0 then do:
          /* выбрать ячейку */
          put stream slog unformatted substitute('select("r&1c&2")'
            ,v-row
            ,v-col
            ) + {&new-line} .
          if v-cell-type = 1 then do:
            /* выделить текст полужирным */
            put stream slog unformatted 'format.font(,10,true)' + {&new-line} .
          end.
          else do:
            /* выделить текст курсивом */
            put stream slog unformatted 'format.font(,12,,true)' + {&new-line} .
            /* заполнить серым */
            put stream slog unformatted 'patterns(1,,40,true)' + {&new-line} .
          end.
        end.
      end.
    end.

    /* пример вывода текстового файла */
    put stream slog unformatted 'select("r5c5")' + {&new-line} .
    put stream slog unformatted 'format.number("@")' + {&new-line} .
    put stream slog unformatted substitute('formula(&3,"r&1c&2")'
      ,5
      ,5
      ,'"12.02"'
      )
      + {&new-line} .


    run paramls-write in this-procedure
      (input 'rowsgroup':u
      ,input string(v-ind) + ',':u + '000000001':u
      ,input '5:15':u
      ) .

    run paramls-write in this-procedure
      (input 'rowsgroup':u
      ,input string(v-ind) + ',':u + '000000002':u
      ,input '2:18':u
      ) .

    put stream slog unformatted 'select("r1c1")' + {&new-line} .
    output stream slog close .

    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
  end.

  define variable v-excel-file-name as character no-undo .
  define variable v-read-password   as character no-undo .
  define variable v-write-password  as character no-undo .

  /* вы можете явно задать имя файла - тогда оно не будет заправшиваться */
/*  assign*/
/*    v-excel-file-name = 'c:\work11_1\test1.xls':u*/
/*  .*/

  /* можно задать пароль на чтение и на запись файла */
  assign
/*    v-read-password  = 'read'*/
/*    v-write-password = 'write'*/
  .

  run paramls-write in this-procedure
    (input "saveas"
    ,input "excel-file-name"
    ,input v-excel-file-name
    ) .

  run paramls-write in this-procedure
    (input "charcol"
    ,input ""
    ,input "1,2"
    ) .

  run paramls-write in this-procedure
    (input "saveas"
    ,input "read-password"
    ,input v-read-password
    ) .

  run paramls-write in this-procedure
    (input "saveas"
    ,input "write-password"
    ,input v-write-password
    ) .

  run waitfram-hide in this-procedure .

  run gbl/macroexl.p
    (input-output table temp-param
    ) .

  /* удаляем файлы отчета */
  define buffer buf_temp-param for temp-param .
  for each buf_temp-param
    where buf_temp-param.param-code = "file"
  on error undo, return error
  :
    os-delete value(buf_temp-param.param-value) .
  end.
end.