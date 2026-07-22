block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: df_erwin.p $
$Archive: utl/df_erwin.p $

Создания файла определений для синхронизации с ERWIN

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Автор1: Перваков Михаил Сергеевич

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: df_erwin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/df_erwin.p $":U .
define variable vss-description as character no-undo init "Создания файла прав доступа, описаний и форматов полей для пакета смены версии".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable v-new-format as character no-undo .
define variable v-ok  as logical no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define stream slog .

FUNCTION escape-description RETURNS CHARACTER
( p-description as character )
:

  define variable v-new-description as character no-undo .

  assign
    v-new-description = replace(p-description, 'я', 'Я')
    v-new-description = replace(v-new-description, '"', '')
    v-new-description = replace(v-new-description, {&new-line}, ' ')
  .

  return v-new-description .

END FUNCTION.


do
on error undo, return error
:

  message
    "Создание файла описания базы для синхронизации с ERWin" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return . /* --->>>--- */
  end.

  define variable v-file-name as character no-undo .

  assign
    v-file-name = 'df_erwin.df':U
  .

  output stream slog to value(v-file-name) .

  define variable v-ind               as integer   no-undo .
  define variable v-table-description as character no-undo .
  define variable v-field-format      as character no-undo .
  define variable v-field-initial     as character no-undo .

  for each _File no-lock
    where _File._Hidden = false
  by _file._file-name
  on error undo, return error
  :

    assign
      v-table-description = _file._Desc
    .

    if v-table-description = ?
    or v-table-description = '':U
    then do:
      assign
        v-table-description = 'table_':U + _file._File-name
      .
    end.

    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input "Анализ таблицы " + _File._File-Name
        ).
    end.

    put stream slog unformatted
      'ADD TABLE "' + _File._File-Name + '"' + {&new-line}
      .
    put stream slog unformatted
      '  DESCRIPTION ' .
    export stream slog
        escape-description(v-table-description)
      .
    put stream slog unformatted
      {&new-line}
      .

    field-block:
    for each _Field of _File no-lock
      by _field._field-rpos
    on error undo, return error
    :
      define variable ind as integer no-undo .

      put stream slog unformatted
        'ADD FIELD "' + _Field._Field-Name + '" OF "' + _File._File-Name + '" AS '
        + _Field._Data-type
        + {&new-line}
        .
      if  _Field._Desc <> ?
      and _Field._Desc <> '':U
      then do:
        put stream slog unformatted
          '  DESCRIPTION ' .
        export stream slog
            escape-description(_Field._Desc)
          .
      end.

      assign
        v-field-format  = _Field._Format
        v-field-initial = _Field._Initial
      .

      if  _Field._Data-type = 'logical':U
      and v-field-format    <> ?
      and v-field-format    <> '':U
      and v-field-initial   <> ?
      and v-field-initial   <> '':U
      then do:
        if lookup(v-field-initial, 'yes,no':U) = 0
        then do:
          assign
            v-field-initial = (if lookup(v-field-initial, v-field-format) = 1
                               then 'yes':U
                               else 'no':U
                              )
          .
        end.
        if v-field-format <> 'yes/no':U
        then do:
          assign
            v-field-format = 'yes/no':U
          .
        end.
      end.

      if  _Field._Data-type = 'character':U
      then do:
        /* erwin не понимает initial "*" */
        if v-field-initial = '*'
        then do:
          assign
            v-field-initial = '':U
          .
        end.
      end.

      if _Field._Data-type = 'integer'
      or _Field._Data-type = 'decimal'
      then do:
        if index(_field._field-name, "db-num") > 0
        and _field._format = ">>>>9" then do:
          v-field-format = _field._format.
        end.
        else do:
          assign
            v-field-format = replace(v-field-format, {&comma-char}, '':U)
          .
          define variable v-format-sign-part   as character no-undo .
          define variable v-format-first-part  as character no-undo .
          define variable v-format-second-part as character no-undo .

          if substring(v-field-format, 1, 1) = '-':U
          then do:
            assign
              v-format-sign-part = substring(v-field-format, 1, 1)
              v-field-format     = substring(v-field-format, 2)
            .
          end.
          else do:
            assign
              v-format-sign-part = '':U
            .
          end.

          if num-entries(v-field-format, '.') > 1
          then do:
            assign
              v-format-first-part  = entry(1, v-field-format, '.')
              v-format-second-part = entry(2, v-field-format, '.')
            .
            assign
              v-format-first-part  = replace(v-format-first-part,  'z':U, '>':U)
              v-format-second-part = replace(v-format-second-part, 'z':U, '<':U)
            .
          end.
          else do:
            assign
              v-format-first-part  = v-field-format
              v-format-second-part = '':U
            .
          end.

          if length(v-format-first-part) > 0
          then do:
            define variable v-add-symbol            as integer   no-undo .
            define variable v-cycle-index           as integer   no-undo .
            define variable v-new-format-first-part as character no-undo .

            assign
              v-add-symbol = (3 - length(v-format-first-part) modulo 3) modulo 3
            .

            assign
              v-format-first-part = fill('_':U, v-add-symbol) + v-format-first-part
            .

            assign
              v-new-format-first-part = '':U
            .

            do v-cycle-index = 1 to (length(v-format-first-part) / 3)
            :
              assign
                v-new-format-first-part = v-new-format-first-part
                                        + (if v-new-format-first-part <> '':U
                                          then {&comma-char}
                                          else '':U
                                          )
                                        + substring(v-format-first-part
                                                  ,(v-cycle-index - 1) * 3 + 1
                                                  ,3
                                                  )
              .
            end.

            assign
              v-format-first-part = substring(v-new-format-first-part, v-add-symbol + 1)
            .
            assign
              v-field-format = v-format-sign-part
                            + v-format-first-part
                            + (if v-format-second-part <> '':U
                                then '.':U
                                else '':U
                              )
                            + v-format-second-part
            .
          end.
        end. /*else if index(_field._field-name, "db-num") > 0*/
      end. /*if _Field._Data-type = 'integer'*/



      if  v-field-format <> ?
      and v-field-format <> '':U
      then do:
        put stream slog unformatted
          '  FORMAT ' .
        export stream slog
            escape-description(v-field-format)
          .
      end.

      if v-field-initial <> ?
      then do:
        put stream slog unformatted
          '  INITIAL ' .
        export stream slog
            escape-description(v-field-initial)
          .
      end.
      else do:
        put stream slog unformatted
          '  INITIAL ?' + {&new-line} .
      end.


      define variable v-field-label        as character no-undo .
      define variable v-field-column-label as character no-undo .

      assign
        v-field-label        = _Field._Label
        v-field-column-label = _Field._Col-Label
      .
      if v-field-label = ?
      or v-field-label = '':U
      or v-field-label = _Field._Field-Name
      then do:
        assign
          v-field-label = 'label_':U + _Field._Field-Name
        .
      end.
      if v-field-column-label = ?
      or v-field-column-label = '':U
      then do:
        assign
          v-field-column-label = v-field-label
        .
      end.

      put stream slog unformatted
        '  LABEL ' .
      export stream slog
          escape-description(v-field-label)
        .
      put stream slog unformatted
        '  COLUMN-LABEL ' .
      export stream slog
          escape-description(v-field-column-label)
        .

      if _Field._Decimals <> ?
      then do:
        put stream slog unformatted
          '  DECIMALS ' + string(_Field._Decimals) + {&new-line}.
      end.
      if _Field._Order <> ?
      then do:
        put stream slog unformatted
          '  ORDER ' + string(_Field._Order) + {&new-line}.
      end.
      if _Field._Mandatory = true
      then do:
        put stream slog unformatted
          '  MANDATORY' + {&new-line}
          .
      end.
      put stream slog unformatted
        {&new-line}
      .
    end.

    find first _index of _file no-lock
      where recid(_index) = _File._Prime-index
      no-error .
    if available _index
    then do:
      run export_index in this-procedure .
    end.

    for each _index of _file no-lock
    on error undo, return error return-value
    :
      if recid(_index) <> _File._Prime-index
      then do:
        run export_index in this-procedure .
      end.
    end.

  end.

  run waitfram-hide in this-procedure .

  define variable v-file-length as integer   no-undo .

  /* формирование стандартного окончания df файла */
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
    "Завершено создание файла определений для синхронизации с ERWin" skip
    "Имя файла" v-file-name skip
    view-as alert-box information .
end.


procedure export_index :

  do
  on error undo, return error return-value
  :
      put stream slog unformatted
        'ADD INDEX "' + _Index._Index-name  + '" ON "' + _File._File-Name + '"' + {&new-line}
        .

      if _index._unique = true
      then do:
        put stream slog unformatted
          '  UNIQUE' + {&new-line}
          .
      end.
      if recid(_index) = _File._Prime-index
      then do:
        put stream slog unformatted
          '  PRIMARY' + {&new-line}
          .
      end.
      if _index._Wordidx <> ?
      then do:
        if _index._Wordidx = 1
        then do:
          put stream slog unformatted
            '  WORD' + {&new-line}
            .
        end.
        else do:
          message
            "Таблица" _File._File-Name skip
            "Индекс" _Index._Index-name skip
            "Неизвестное значение _index._Wordidx" _index._Wordidx skip
            view-as alert-box error .
        end.
      end.

      define buffer buf_field for _field .

      for each _index-field of _index
      ,first buf_field of _index-field
      :
        put stream slog unformatted
          '  INDEX-FIELD "' + buf_field._field-name + '" '
          + (IF _index-field._Ascending then 'ASCENDING' else 'DESCENDING')
          + {&new-line}
          .

      end.

      put stream slog unformatted
        {&new-line}
        .

  end.

end procedure. /* export_index */