block-level on error undo, throw.
/*

$Revision: 47c30cad4995, 3593, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: gen-main.p $
$Archive: utl/gen-main.p $

Генерация файлов по структуре БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/01/03
Author: Dmitry Ukhanov
Creation date: 03/01/03

*/


define variable vss-revision    as character no-undo init "$Revision: 47c30cad4995, 3593, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-main.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-main.p $":U .
define variable vss-description as character no-undo init "Генерация файлов по структуре БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

  define temp-table temp_vss-dir no-undo
    field vsd-key   as integer
    field dir-name  as character
    field file-list as character

    index pi is primary unique
        vsd-key
  .
  define variable gen-dir         as character no-undo .
  define variable gen-file-list   as character no-undo .

  define variable v-work-dir      as character no-undo .
  define variable v-gen-file-name as character no-undo .

  define variable v-dir-name    as character    no-undo.
  define variable v-file-name   as character    no-undo.
  define variable v-vsd-key     as integer      no-undo.

  define stream OutStream.

  define variable v-ind         as integer no-undo .
  define variable v-num-entries as integer no-undo .

do
on error undo, return error
:
  assign
    file-info :file-name = ".":U
  .
  if file-info :full-pathname = ""
  or file-info :full-pathname = ?  then do:
    message
      "Рабочий каталог не найден"
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-work-dir = file-info :full-pathname + {&back-slash-char}
  .
  if     entry(1,propath) ne "."
     and entry(1,propath) ne file-info :full-pathname
  then
     gen-dir = entry(1,propath).
  else
     gen-dir = entry(2,propath) no-error.
  run gbl/d-prompt.w (
      'title=':u + "Введите имя директории" + '\':u
    + 'text1=':u + "Введите имя директории" + '\':u
    + 'text2=':u + "где будут созданы файлы по структуре БД" + '\':u
    + 'format=x(256)\':u
    + 'type=char\':u
    ,input-output gen-dir
    ).
  if return-value = 'false':u then do:
    return .
  end.

  if gen-dir = "" then do:
    assign
      gen-dir = v-work-dir
    .
  end.
  else do:
    assign
      file-info :file-name = gen-dir
    .
    if file-info :full-pathname = ""
    or file-info :full-pathname = ?  then do:
      message
        "Указаный каталог не найден" skip
        gen-dir
        view-as alert-box error .
      undo, return error .
    end.
    assign
      gen-dir = file-info :full-pathname + {&back-slash-char}
    .
  end.

  run utl/gen-tbln.p
    (input        gen-dir
    ,input-output gen-file-list
    ) .

  run utl/gen-imp.p
    (input        gen-dir
    ,input-output gen-file-list
    ) .

  assign
    v-gen-file-name = v-work-dir + "gen-file.txt":U
  .
  output stream OutStream to value( v-gen-file-name ) .
  put stream OutStream unformatted
    "Список файлов сгенерированых в каталоге" space(1) '"' gen-dir '"' skip
    today space(1) string( time, "HH:MM:SS":U ) skip(1)
  .
  assign
    v-num-entries = num-entries( gen-file-list, ",":U )
  .
  do v-ind = 1 to v-num-entries
  :
    put stream OutStream unformatted
      entry( v-ind, gen-file-list, ",":U ) skip
    .
  end.
  put stream OutStream
        skip(2)
  .

  do v-ind = 1 to v-num-entries
  :
    if num-entries( entry( v-ind, gen-file-list, ",":U ), "/":U ) = 2
    then do:
        assign
            v-dir-name = entry( 1, entry( v-ind, gen-file-list, ",":U ), "/":U )
            v-file-name = entry( 2, entry( v-ind, gen-file-list, ",":U ), "/":U )
        .
        find last temp_vss-dir
            where temp_vss-dir.dir-name = v-dir-name
        no-error.
        if not available temp_vss-dir
        then do:
            assign
                v-vsd-key = v-vsd-key + 1
            .
            create temp_vss-dir.
            assign
                temp_vss-dir.vsd-key   = v-vsd-key
                temp_vss-dir.dir-name  = v-dir-name
                temp_vss-dir.file-list = v-file-name
            .
        end.
        else do:
            if length( temp_vss-dir.file-list ) + 1 + length( v-file-name ) > 255
            then do:
                assign
                    v-vsd-key = v-vsd-key + 1
                .
                create temp_vss-dir.
                assign
                    temp_vss-dir.vsd-key   = v-vsd-key
                    temp_vss-dir.dir-name  = v-dir-name
                    temp_vss-dir.file-list = v-file-name
                .
            end.
            else do:
              assign
                  temp_vss-dir.file-list = substitute( "&1;&2", temp_vss-dir.file-list, v-file-name )
              .
            end.
        end.
    end.
  end.
  for each temp_vss-dir
  :
    put stream OutStream unformatted
        substitute( "&1Каталог VSS: &2&1--------------------------&1&3&1", {&new-line}, temp_vss-dir.dir-name, temp_vss-dir.file-list )
    .
  end.      /* for each temp_vss-dir */
  output stream OutStream close.

  assign
    file-info :file-name = v-gen-file-name
  .
  if file-info :full-pathname = ""
  or file-info :full-pathname = ?  then do:
    message
      "Файл gen-file.txt не найден"
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-gen-file-name = file-info :full-pathname
  .

  os-command no-wait value( substitute( "start &1", v-gen-file-name ) ).

  /*
  message
    "В каталоге" gen-dir "сгенерированы файлы:" skip
    gen-file-list skip(1)
    "Список сгенерированых файлов продублирован в файле:" skip
    v-work-dir + "gen-file.txt":U
    view-as alert-box information .
  */
end.