block-level on error undo, throw.
/*

$Revision: 0913db48c0a8, 1234, rls $
$Author: SSlivenko $
$Date: Mon Feb 26 19:29:32 2018 +0300 $
$Workfile: s-g-pack.p $
$Archive: nws/s-g-pack.p $

отправка и прием пакета новостей (файла)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input parameter p0-action     as character no-undo .
define input parameter p0-arch-type  as character no-undo .
define input parameter p0-file-name  as character no-undo .
define input parameter p0-source-dir as character no-undo .
define input parameter p0-target-dir as character no-undo .
define input parameter p0-temp-dir   as character no-undo .

def var vss-revision    as character no-undo init "$Revision: 0913db48c0a8, 1234, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Mon Feb 26 19:29:32 2018 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: s-g-pack.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/s-g-pack.p $":U .
def var vss-description as character no-undo init "отправка и прием пакета новостей (файла)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }

&scop condition-upd-file ~{&cur-file-name~} BEGINS "RC_":U or ~{&cur-file-name~} BEGINS "update_":U or ~{&cur-file-name~} BEGINS "UFO-":U

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define stream FLStream.

  define variable v-filename         as character no-undo .
  define variable v-fullfilename     as character no-undo .
  define variable v-filetype         as character no-undo .

  /* если каталога temp-dir нет, то создадим его */
  assign
    file-info:file-name = p0-temp-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U )
  then do:
    os-create-dir value( p0-temp-dir ).
    if os-error <> 0 then do:
      return error substitute( "&1. Каталог &2 отсутствует, а создать его не удалось.", vss-workfile, p0-temp-dir ).
    end.
  end.

  if p0-file-name <> ? then do:
    run file-s-g ( input p0-action
                  ,input p0-arch-type
                  ,input p0-file-name
                  ,input p0-source-dir
                  ,input p0-target-dir
                  ,input p0-temp-dir
                 ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  else do:
    input stream FLStream from os-dir ( p0-source-dir ) .
    repeat
    on error  undo, return error substitute( "&1 (repeat). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (repeat). stop", vss-workfile )
    :
      import stream FLStream v-filename v-fullfilename v-filetype.

      if v-filetype begins "F"
        and num-entries( v-filename, "." ) > 1
      then do:
        assign
          file-info:file-name = v-fullfilename
        .

        if lookup(entry( num-entries( v-filename, "." ), v-filename, "." ), "$$$") = 0
          and file-info:file-type MATCHES "*W*":U /* проверка на атрибут read-only */
          and file-info:file-type MATCHES "*R*":U /* проверка на возможность чтения файла */
          and not ( file-info:file-type MATCHES "*H*":U )
        then do:
          run file-s-g ( input p0-action
                        ,input p0-arch-type
                        ,input v-filename
                        ,input p0-source-dir
                        ,input p0-target-dir
                        ,input p0-temp-dir
                      ) no-error.
          if error-status :error then do:
            return error return-value.
          end.
        end.
      end.
    END.
    input stream FLStream close.

  end.

  return .

end.

procedure file-s-g :
  define input parameter p-action     as character no-undo .
  define input parameter p-arch-type  as character no-undo .
  define input parameter p-file-name  as character no-undo .
  define input parameter p-source-dir as character no-undo .
  define input parameter p-target-dir as character no-undo .
  define input parameter p-temp-dir   as character no-undo .
  do
  on error  undo, return error substitute( "&1 (file-s-g). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (file-s-g). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (file-s-g). endkey", vss-workfile )
  :
    define variable v-arch-type        as character no-undo .
    define variable v-arh-name         as character no-undo .

    define variable v-file-source      as character no-undo .
    define variable v-file-source-arj  as character no-undo .
    define variable v-file-temp        as character no-undo .
    define variable v-file-target      as character no-undo .
    define variable v-file-hash        as character no-undo .

    define variable v-file-name-no-ext as character no-undo .
    define variable v-ext-name         as character no-undo .

    define variable v-err-mess         as character no-undo .

    &scop cur-file-name p-file-name
    if {&condition-upd-file} then do:
      assign
        p-arch-type = "":U
      .
    end.

    if r-index( p-file-name, '.':u) > 0 then do:
      assign
        v-file-name-no-ext = substring( p-file-name, 1, r-index( p-file-name, '.':u) - 1 )
        v-ext-name         = entry( num-entries( p-file-name, "." ), p-file-name, "." )
      .
    end.
    else do:
      assign
        v-file-name-no-ext = p-file-name
        v-ext-name         = "":U
      .
    end.

    assign
      v-file-source     = p-source-dir + {&back-slash-char} + p-file-name
      v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name
      v-file-target     = p-target-dir + {&back-slash-char} + p-file-name
    .

    /* проверим наличие исходного файла */
    assign
      file-info:file-name = v-file-source
    .
    if file-info:file-type = ?
      or not ( file-info:file-type begins "F":U )
    then do:
      return error substitute( "&1. Исходный файл &2 не найден.", vss-workfile, v-file-source ).
    end.

    run gbl/md5.p(v-file-source, output v-file-hash).
    run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", v-file-source,  v-file-hash) ) .

    if p-action = "put":U then do:
      if p-arch-type <> "":U then do:
        case p-arch-type :
          when "7zip":U then do:
            assign
              v-arh-name = search( "exe/7z.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/7za.exe":U )
              .
            end.
          end.
          when "arj":U then do:
            assign
              v-arh-name = search( "exe/arj32.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/arj.exe":U )
              .
            end.
          end.
        end case.

        if v-arh-name = ? then do:
          return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
        end.
        run write-to-log( substitute( "Отправка файла &1 (&2)", v-file-source, v-arh-name ) ).
        assign
          v-file-source-arj = p-source-dir + {&back-slash-char} + v-file-name-no-ext
          v-file-temp       = p-temp-dir   + {&back-slash-char} + v-file-name-no-ext
          v-file-target     = p-target-dir + {&back-slash-char} + v-file-name-no-ext
        .
        case p-arch-type :
          when "7zip":U then do:
            assign
              v-file-source-arj = v-file-source-arj + ".zip":U
              v-file-temp       = v-file-temp       + ".zip":U
              v-file-target     = v-file-target     + ".zip":U
            .
            os-command silent
              value( substitute( "&1 a -tzip -y &2 &3":U, v-arh-name, v-file-source-arj, v-file-source ) )
            .
          end.
          when "arj":U then do:
            assign
              v-file-source-arj = v-file-source-arj + ".arj":U
              v-file-temp       = v-file-temp       + ".arj":U
              v-file-target     = v-file-target     + ".arj":U
            .
            os-command silent
              value( substitute( "&1 a -e -y &2 &3":U, v-arh-name, v-file-source-arj, v-file-source ) )
            .
          end.
        end case.
      end.
      else do:
        run write-to-log( substitute( "Отправка файла &1 (copy)", v-file-source ) ).
        assign
          v-file-source-arj = v-file-source
        .
      end.
      run del-file in this-procedure
        ( input v-file-temp
        ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      os-copy
        value( v-file-source-arj )
        value( v-file-temp )
        .
      if os-error <> 0 then do:
        run adm/os-err.p
          ( output v-err-mess
          ).
        return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, {&new-line}, v-err-mess ) .
      end.
      if p-arch-type <> "":U then do:
        run del-file in this-procedure
          ( input v-file-source-arj
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.

      run ren-file in this-procedure
        ( input v-file-temp
        , input v-file-target
        ) no-error .
      if error-status :error then do:
        assign
          v-err-mess = return-value
        .
        run del-file in this-procedure
          ( input v-file-temp
          ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = v-err-mess + {&new-line} + return-value
          .
        end.
        return error v-err-mess .
      end.
    end.
    else do:
      &scop cur-file-name p-file-name
      if {&condition-upd-file} then do:
        run write-to-log( substitute( "Прием и обработка пакетов update", v-file-source ) ) .
        run adm/upd-rc.p
          ( input p-source-dir
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка приема и(или) обработки пакетов update!&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
        end.
      end.
      else do:
        if v-ext-name = "zip":U then do:
          assign
            v-arch-type = "7zip":U
            v-arh-name  = search( "exe/7z.exe":U )
          .
          if v-arh-name = ? then do:
            assign
              v-arh-name = search( "exe/7za.exe":U )
            .
          end.
        end.
        else do:
          if lookup( v-ext-name, "arj") <> 0 then do:
            assign
              v-arch-type = "arj":U
              v-arh-name  = search( "exe/arj32.exe":U )
            .
            if v-arh-name = ? then do:
              assign
                v-arh-name = search( "exe/arj.exe":U )
              .
            end.
          end.
          else do:
            assign
              v-arch-type = "":U
              v-arh-name  = "copy":U
            .
          end.
        end.
        if v-arch-type <> "":U
          and v-arh-name = ?
        then do:
          return error substitute( "&1. Программа архиватор не найдена для файла с расширением &2!", vss-workfile, v-ext-name ).
        end.

        run write-to-log( substitute( "Прием файла &1 (&2)", v-file-source, v-arh-name ) ) .

        run ren-file in this-procedure
          ( input v-file-source
          , input v-file-temp
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.

        run del-file in this-procedure
          ( input v-file-target
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        os-copy
          value( v-file-temp )
          value( v-file-target )
          .
        if os-error <> 0 then do:
          run adm/os-err.p
            ( output v-err-mess
            ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, {&new-line}, v-err-mess ).
        end.
        run del-file in this-procedure
          ( input v-file-temp
          ) no-error .
        if error-status :error then do:
          return error return-value .
        end.

        if v-arch-type <> "":U then do:
          case v-arch-type :
            when "7zip":U then do:
              os-command silent
                value( substitute( "&1 e -y &2 -o&3":U, v-arh-name, v-file-target, p-target-dir ) )
              .
            end.
            when "arj":U then do:
              os-command silent
                value( substitute( "&1 e -y &2 &3":U, v-arh-name, v-file-target, p-target-dir ) )
              .
            end.
          end case.

          run del-file in this-procedure
            ( input v-file-target
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure. /* file */

procedure del-file :
  define input parameter p-del-file-name as character no-undo .
  do
  on error  undo, return error substitute( "&1 (del-file). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (del-file). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (del-file). endkey", vss-workfile )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    define variable v-str      as character no-undo .

    assign
      file-info:file-name = p-del-file-name
    .
    if file-info:file-type <> ? then do:
      if file-info:file-type begins "F":U then do:
        assign
          v-str = "файл"
        .
      end.
      else do:
        if file-info:file-type begins "D":U then do:
          assign
            v-str = "каталог"
          .
        end.
        else do:
          assign
            v-str = "не знаю что"
          .
        end.
      end.

      bl1:
      do v-ind = 1 to 60 :
        os-delete value( p-del-file-name ).
        assign
          v-err-code = os-error
          file-info:file-name = p-del-file-name
        .
        if v-err-code = 0
          or file-info:file-type = ?
        then do:
          leave bl1 .
        end.
        pause 1 no-message .
      end.
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно удалить &2 &3&4&5", vss-workfile, v-str, p-del-file-name, {&new-line}, v-err-mess ).
      end.
    end.
  end.
  return.
end procedure. /* del-file */

procedure ren-file :
  define input parameter p-file-source as character no-undo .
  define input parameter p-file-target as character no-undo .
  do
  on error  undo, return error substitute( "&1 (ren-file). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (ren-file). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (ren-file). endkey", vss-workfile )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .

    run del-file ( input p-file-target ) no-error .
    if error-status :error then do:
      return error return-value .
    end.

    bl1:
    do v-ind = 1 to 60 :
      os-rename value( p-file-source ) value( p-file-target ).
      assign
        v-err-code = os-error
        file-info:file-name = p-file-source
      .
      if v-err-code = 0
        or file-info:file-type = ?
      then do:
        leave bl1 .
      end.
      pause 1 no-message .
    end.

    if v-err-code <> 0 then do:
      run adm/os-err.p ( output v-err-mess ).
      return error substitute( "&1. Невозможно переименовать файл &2 в &3&4&5", vss-workfile, p-file-source, p-file-target, {&new-line}, v-err-mess ).
    end.
  end.
end procedure. /* ren-file */
/* $Workfile: s-g-pack.p $ end */