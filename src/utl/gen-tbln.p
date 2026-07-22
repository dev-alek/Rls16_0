block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gen-tbln.p $
$Archive: utl/gen-tbln.p $

Автоматическое создание файла определений имен таблиц

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input         parameter gen-dir       as character no-undo .
define input-output  parameter gen-file-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-tbln.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-tbln.p $":U .
define variable vss-description as character no-undo init "Генерация include-файлов по имени таблицы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define temp-table tt-file no-undo
field pre-prefix as character
field pre-def as character
field file-label as character
field line-num as integer
index pi is unique primary line-num
index imain pre-def.

do
on error undo, return error
:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define variable tn      as character no-undo.
  define variable tn-f    as character no-undo .
  define variable v-line-num as integer no-undo .

  define stream NameStream.

  define frame ddd
    fl as character format "x(14)"  label "Таблица" at row 1.5  col 17 colon-aligned
    with view-as dialog-box side-labels three-d
    title "Генерация файлов " + program-name(1)
  .

  { utl/gencredr.i gen-dir cmp }

  view frame ddd.

  assign
    gen-file-list = gen-file-list + "," + "cmp/tbl-name.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tbl-name.i" ).

  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + {&new-line}
    + {&new-line}
    + '$':U + 'Revision: ':U + '$':U + {&new-line}
    + '$':U + 'Author: ':U + '$':U + {&new-line}
    + '$':U + 'Date: ':U + '$':U + {&new-line}
    + '$':U + 'Workfile: ':U + '$':U + {&new-line}
    + '$':U + 'Archive: ':U + '$':U + {&new-line}
    + {&new-line}
    + "Глобальные определения имен таблиц" + {&new-line}
    + {&new-line}
    + 'Автор: Перваков Михаил Сергеевич':U + {&new-line}
    + 'Дата создания: 04/05/06':U + {&new-line}
    + 'Author: Mikhail Pervakov':U + {&new-line}
    + 'Creation date: 04/05/06':U + {&new-line}
    + {&new-line}
    + "Файл автоматически создается процедурой " + program-name(1) + {&new-line}
    + {&new-line}
    + '*/':U + {&new-line}
    + {&new-line}
  .
  for each {&db-name_schema}._File no-lock
    where {&db-name_schema}._File._Hidden = false
  by {&db-name_schema}._File._File-Name
  :
    assign
      tn = {&db-name_schema}._file._file-name
    .
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob table_" + tn + " '" + tn + "':U"
      + {&new-line}
      .
  end.

  put stream NameStream unformatted
    {&std-vss-tail}
    + {&new-line}
  .

  OUTPUT STREAM NameStream close.

  assign
    gen-file-list = gen-file-list + "," + "cmp/tblbname.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tblbname.i" ).

  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + {&new-line}
    + {&new-line}
    + '$':U + 'Revision: ':U + '$':U + {&new-line}
    + '$':U + 'Author: ':U + '$':U + {&new-line}
    + '$':U + 'Date: ':U + '$':U + {&new-line}
    + '$':U + 'Workfile: ':U + '$':U + {&new-line}
    + '$':U + 'Archive: ':U + '$':U + {&new-line}
    + {&new-line}
    + "Глобальные определения имен таблиц" + {&new-line}
    + {&new-line}
    + 'Автор: Бахтадзе Наталья Викторовна':U + {&new-line}
    + 'Дата создания: 01/29/07':U + {&new-line}
    + 'Author: Bakhtadze Natalya':U + {&new-line}
    + 'Creation date: 01/29/07':U + {&new-line}
    + {&new-line}
    + "Файл автоматически создается процедурой " + program-name(1) + {&new-line}
    + {&new-line}
    + '*/':U + {&new-line}
    + {&new-line}
  .
  for each {&db-name_schema}._File no-lock
    where {&db-name_schema}._File._Hidden = false
  by {&db-name_schema}._File._File-Name
  :
    assign
      tn = {&db-name_schema}._file._file-name
    .
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob bef-table_" + tn + " " + tn
      + {&new-line}
      .
  end.

  put stream NameStream unformatted
    {&std-vss-tail}
    + {&new-line}
  .

  OUTPUT STREAM NameStream close.

  /*считаем названия таблиц, переопределенных пользователем*/
  define variable v-path                    as character                no-undo .
  DEFINE VARIABLE v-full-path               as character                no-undo .
  DEFINE VARIABLE v-file-name               as character                no-undo .
  DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
  DEFINE VARIABLE v-file-name-ext           as character                no-undo .
  run gbl/filename.p (
                  input 'cmp/tbluname.i'
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.

  input stream Namestream from value(v-full-path) .
  repeat:
    create tt-file.
     assign tt-file.line-num = v-line-num + 1
     v-line-num = v-line-num + 1.
    import stream namestream tt-file except line-num.
    assign
    tt-file.file-label = trim(tt-file.file-label, {&single-quote})
    tt-file.file-label = trim(tt-file.file-label, {&double-quote})
    tt-file.file-label = trim(tt-file.file-label, {&single-quote})
    .
  end.

  input stream Namestream close.

  assign
    gen-file-list = gen-file-list + "," + "cmp/tblfname.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tblfname.i" ).

  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + {&new-line}
    + {&new-line}
    + '$':U + 'Revision: ':U + '$':U + {&new-line}
    + '$':U + 'Author: ':U + '$':U + {&new-line}
    + '$':U + 'Date: ':U + '$':U + {&new-line}
    + '$':U + 'Workfile: ':U + '$':U + {&new-line}
    + '$':U + 'Archive: ':U + '$':U + {&new-line}
    + {&new-line}
    + "Глобальные определения имен таблиц" + {&new-line}
    + {&new-line}
    + 'Автор: Бахтадзе Наталья Викторовна':U + {&new-line}
    + 'Дата создания: 01/29/07':U + {&new-line}
    + 'Author: Bakhtadze Natalya':U + {&new-line}
    + 'Creation date: 01/29/07':U + {&new-line}
    + {&new-line}
    + "Файл автоматически создается процедурой " + program-name(1) + {&new-line}
    + {&new-line}
    + '*/':U + {&new-line}
    + {&new-line}
  .

  for each {&db-name_schema}._File no-lock
    where {&db-name_schema}._File._Hidden = false
  by {&db-name_schema}._File._File-Name
  :
    assign
      tn = {&db-name_schema}._file._file-name
    .
    find first tt-file no-lock where
          tt-file.pre-prefix = "&glob"
      and tt-file.pre-def = ("table_" + tn + "-full") no-error.
    if not available tt-file then do:
      if {&db-name_schema}._file._file-label = ?
      or {&db-name_schema}._file._file-label = '':U
      then do:
        assign
        tn-f = {&db-name_schema}._file._file-name.
      end.
      else do:
        assign
        tn-f = {&db-name_schema}._file._file-label.
      end.
    end.
    else do:
      assign
      tn-f = tt-file.file-label.
    end.
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob bef-table_" + tn + "-full " + tn-f
      + {&new-line}
      .
    put stream NameStream unformatted "&glob table_" + tn + "-full '~{&bef-table_" + tn + "-full~}':U"
      + {&new-line}
      .

  end.

  put stream NameStream unformatted
    {&std-vss-tail}
    + {&new-line}
  .

  OUTPUT STREAM NameStream close.



  hide frame ddd no-pause.
end.
RETURN.