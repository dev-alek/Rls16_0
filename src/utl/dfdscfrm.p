block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dfdscfrm.p $
$Archive: utl/dfdscfrm.p $

Создания файла прав доступа, описаний и форматов полей для пакета смены версии

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/09/07
Author: Dmitry Ukhanov
Creation date: 11/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания1: 10/03/01

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dfdscfrm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dfdscfrm.p $":U .
define variable vss-description as character no-undo init "Создания файла прав доступа, описаний и форматов полей для пакета смены версии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable v-new-format as character no-undo .
define variable l-ok  as logical no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define stream slog .

do
on error undo, return error
:

  message
    "Вы хотите сгенерировать файл прав доступа, описаний и форматов полей структуры БД   " skip
    "для пакета upgrade" skip
    view-as alert-box question buttons yes-no update l-ok .
  if l-ok <> true then do:
    return . /* --->>>--- */
  end.

  define variable v-file-name as character no-undo init "dfdscfrm.df" .

  output stream slog to value(v-file-name) .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  put stream slog unformatted
    '# Файл прав доступа, описаний и форматов полей для пакета upgrade' + {&new-line}
    '# Данный файл сгенерирован автоматически при помощи программы ' + vss-workfile + {&new-line}
/*    '#' + {&new-line}*/
/*    '# DECIMALS и MAX-WIDTH ДОБАВЛЕНЫ ИЗ-ЗА ТОГО, ЧТО ПРИ КОНВЕРТАЦИИ В 10-КУ ПОХОЖЕ ЛОМАЮТСЯ!!!' + {&new-line}*/
/*    '#' + {&new-line}*/
    '# Дата  ' + string(v-today, "99/99/9999") + {&new-line}
    '# Время ' + string(v-time, "hh:mm") + {&new-line}
    + {&new-line}
  .
  output stream slog close .

  define variable v-total as integer no-undo .
  define variable v-descrip as integer no-undo .

  define variable v-first-descr  as character no-undo .
  define variable v-second-descr as character no-undo .
  define variable v-third-descr  as character no-undo .

  for each _File no-lock
    where _File._Hidden = false
  by _file._file-name
  on error undo, return error
  :

    run waitfram-show in this-procedure
      (input "Анализ таблицы " + _File._File-Name
      ).

    output stream slog to value(v-file-name) append .
    put stream slog unformatted
      'UPDATE TABLE "' + _File._File-Name + '"' + {&new-line}
      + '  CAN-READ "!,*"' + {&new-line}
      + '  CAN-WRITE "!,!odbc,*"' + {&new-line}
      + '  CAN-CREATE "!,!odbc,*"' + {&new-line}
      + '  CAN-DELETE "!,!odbc,*"' + {&new-line}
      + '  CAN-DUMP "!odbc,*"' + {&new-line}
      + '  CAN-LOAD "!odbc,*"' + {&new-line}
      + {&new-line}
      .
    output stream slog close .

    field-block:
    for each _Field of _File no-lock
    on error undo, return error
    :
      define variable ind as integer no-undo .

      output stream slog to value(v-file-name) append .
      put stream slog unformatted
        'UPDATE FIELD "' + _Field._Field-Name + '" OF "' + _File._File-Name + '"' + {&new-line}
        .
      if ( trim( _Field._Desc ) <> "":U
           and _Field._Desc <> ?
         )
         or trim( _Field._Desc ) <> _Field._Desc
      then do:
        put stream slog unformatted
          '  DESCRIPTION ' .
        export stream slog
            _Field._Desc
          .
      end.
      else do:
        put stream slog unformatted
          '  DESCRIPTION ' .
        put stream slog unformatted
          '""'
          skip.
      end.
      put stream slog unformatted
        '  FORMAT ' .
      export stream slog
          _Field._Format
        .
      put stream slog unformatted
        '  DECIMALS ' .
      export stream slog
          _Field._Decimals
        .
      put stream slog unformatted
        '  MAX-WIDTH '
        .
      export stream slog
          _Field._Width
        .
/*      put stream slog unformatted*/
/*        '  POSITION '*/
/*        .*/
/*      export stream slog*/
/*          _Field._Field-rpos*/
/*        .*/

      put stream slog unformatted
        {&new-line}
      .
      output stream slog close .
    end.
  end.

  run waitfram-hide in this-procedure .

  define variable v-file-length as integer   no-undo .

  /* формирование стандартного окончания df файла */
  output stream slog to value(v-file-name) append .
  assign
    v-file-length = seek(slog)
  .
  put stream slog unformatted
    '.' + {&new-line}
    'PSC' + {&new-line}
    'codepage=' + session :stream {&new-line}
    '.' + {&new-line}
    STRING(v-file-length, "9999999999") + {&new-line}
  .
  output stream slog close .

  message
    "Создание файла прав доступа, описаний и форматов полей закончено" skip
    "Положите файл" v-file-name "в пакет upgrade" skip
    "" skip
    "ВНИМАНИЕ!!!  " skip
    "Файл должен быть последним в пакете upgrade текущей версии" skip
    "Но должен идти до первого файла пакета upgrade следующей версии" skip
    view-as alert-box information .


end.