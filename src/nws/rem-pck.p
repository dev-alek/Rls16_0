block-level on error undo, throw.
/*

$Revision: 4e080738a7b9, 3543, rls $
$Author: Ostroukhov $
$Date: 2023/11/27 08:31:17 $
$Workfile: rem-pck.p $
$Archive: nws/rem-pck.p $

Удаление пакетов СПН по указанной БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input parameter parparentproc as   widget-handle        no-undo .
define input parameter p-db-num      like ub.db.db-num         no-undo .

def var vss-revision    as character no-undo init "$Revision: 4e080738a7b9, 3543, rls $":U .
def var vss-author      as character no-undo init "$Author: Ostroukhov $":U .
def var vss-date        as character no-undo init "$Date: 2023/11/27 08:31:17 $":U .
def var vss-workfile    as character no-undo init "$Workfile: rem-pck.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/rem-pck.p $":U .
def var vss-description as character no-undo init "Удаление пакетов СПН по указанной БД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }

do
on error undo, return error
:

  define stream dir-stream .

  define buffer buf_db       for ub.db .
  define buffer buf_pck-sent for ub.pck-sent.
  define buffer buf_pck-rcvd for ub.pck-rcvd .

  define variable v-pck-for-db    as integer   no-undo .

  define variable v-add-to-list  as logical   no-undo .

  define variable v-list-action  as character no-undo .
  define variable v-action       as character no-undo .
  define variable v-dir-name     as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-filename     as character no-undo .
  define variable v-fullfilename as character no-undo .
  define variable v-file-cnt     as integer   no-undo .

  define variable v-count-del      as integer   no-undo .
  define variable v-count-need-del as integer   no-undo .

  define variable v-today        as date      no-undo .
  define variable v-time         as integer   no-undo .

  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error
  .
  if not available buf_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, p-db-num ) ) .
    return error.
  end.

  if buf_db.save-packs = ? then do:
    return .
  end.

  if g#db-num = 0 then do:
    assign
      v-pck-for-db = buf_db.db-num
    .
  end.
  else do:
    assign
      v-pck-for-db = 0
    .
  end.

  run write-to-log( substitute("Анализ необходимости удаления пакетов СПН по БД &1", v-pck-for-db ) ) .

  run nws/lock-nws.p
    ( input buf_db.db-num
     ,buffer buf_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.

  run cur-time in this-procedure
    ( output v-today
     ,output v-time
    ) no-error .
  if error-status :error then do:
    run write-to-log( substitute( "&1. Ошибка при определении текущего времени. &2&3&2&4", vss-workfile, {&new-line}, error-status :get-message(1) , return-value )
                    ) .
    return error.
  end.


  assign
    v-list-action    = "put,get":U
    v-file-cnt       = 0
    v-count-del      = 0
    v-count-need-del = 0
  .
  do v-ind = 1 to 2
  :
    assign
      v-action   = entry( v-ind, v-list-action )
      v-pack-num = ?
    .
    run nws/pck-num.p
      ( input v-action
       ,input v-pck-for-db
       ,input-output v-pack-num
       ,output v-pack-name
       ,output v-source-dir
       ,output v-target-dir
       ,output v-temp-dir
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value ) ) .
    end.

    if v-action = "put":U  then do:
      assign
        v-dir-name = v-source-dir
      .
    end.
    else do:
      assign
        v-dir-name = v-target-dir
      .
    end.

    assign
      file-info :file-name = v-dir-name
    .
    if file-info :full-pathname = ""
    or file-info :full-pathname = ?  then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Каталог: &1 ('heap') не найден !!!", v-dir-name ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      undo, return error .
    end.

    assign
      v-dir-name = file-info :full-pathname
    .

    input stream dir-stream from os-dir ( v-dir-name ) no-attr-list no-echo .
    repeat:
      import stream dir-stream v-filename v-fullfilename .
      assign
        file-info :file-name = v-fullfilename
      .
      if caps( file-info :file-type ) begins "F":U then do:
        assign
          v-file-cnt = v-file-cnt + 1
        .
        if     file-info :file-mod-date + buf_db.save-packs < v-today
           and num-entries( v-filename, "." ) > 1
           and lookup(entry( num-entries( v-filename, ".":U ), v-filename, ".":U ), "txt":U) > 0
           and v-filename begins "p":U
        then do:

          assign
            v-pack-num    = integer( substring( v-filename, 2, r-index(v-filename, '.':U) - 1 ) )
            v-add-to-list = true
          no-error.
          if not error-status:error
          then do:
            case v-action :
              when "put":U then do:
                find first buf_pck-sent no-lock
                  where buf_pck-sent.db-num   = v-pck-for-db
                    and buf_pck-sent.pack-num = v-pack-num
                no-error .
                if   not available buf_pck-sent
                  or buf_pck-sent.rcvd <> true
                then do:
                  assign
                    v-add-to-list = false
                  .
                end.
              end.
              when "get":U then do:
                find first buf_pck-rcvd no-lock
                  where buf_pck-rcvd.db-num   = v-pck-for-db
                    and buf_pck-rcvd.pack-num = v-pack-num
                no-error .
                if not available buf_pck-rcvd then do:
                  assign
                    v-add-to-list = false
                  .
                end.
              end.
            end case.

            if v-add-to-list = true then do:

              if v-count-need-del = 0 then do:
                run write-to-log( substitute("Удаление пакетов СПН по БД &1", v-pck-for-db ) ) .
              end.

              assign
                v-count-need-del = v-count-need-del + 1
              .
              run gbl/del-file.p
                ( input file-info :full-pathname
                ) no-error .
              if error-status:error then do:
                run write-to-log( substitute( "&1. Ошибка при удалении пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                              ) .
              end.
              else do:
                assign
                  v-count-del = v-count-del + 1
                .
              end.
            end.
          end.
        end.
      end.
    end.
    input stream dir-stream close.
  end.

  if v-count-need-del > 0 then do:
    run write-to-log( substitute("Анализ пакетов по БД &1 завершен. Просмотрено &2 файлов. Удалено &3 из &4 старых пакетов.", v-pck-for-db, v-file-cnt, v-count-del, v-count-need-del ) ) .
  end.
  else do:
    run write-to-log( substitute("Анализ пакетов по БД &1 завершен. Просмотрено &2 файлов. Старых пакетов не обнаружено.", v-pck-for-db, v-file-cnt ) ) .
  end.

end.

/* $Workfile: rem-pck.p $ end */