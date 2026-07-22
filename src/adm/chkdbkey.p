block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkdbkey.p $
$Archive: adm/chkdbkey.p $

Процедура проверки правильности кодировки ключей БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkdbkey.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/chkdbkey.p $":U .
define variable vss-description as character no-undo init "Процедура проверки правильности кодировки ключей БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/conf-enc.i }
{ cmp/library.i  }
{ gbl/get-ro.i   }

&scop err-file "neceskey.txt":U

do
on error  undo, return error
:

  define variable v-ind              as integer   no-undo .
  define variable v-start-time       as int64     no-undo .
  define variable v-current-time     as character no-undo .
  define variable v-err-code         as integer   no-undo .
  define variable v-load-db-key-now  as logical   no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-log              as logical   no-undo .
  define variable v-str              as character no-undo .
  define variable v-last-key         as integer no-undo .
  define variable v-delimeter        as character no-undo .
  define variable v-num-entries      as integer no-undo .

  define variable v-check-db-num     as integer   no-undo .
  define variable v-check-user-id    as character no-undo .
  define variable v-check-user-admin as logical   no-undo .

  define variable v-get-ro_read-only as logical   no-undo .

  define variable v-db-num     like ub.db.db-num no-undo .
  define variable v-db-key     like ub.db.db-key no-undo .
  define variable v-db-key-enc like ub.db.db-key-enc no-undo .

  define buffer buf_db for ub.db .

  define stream NecesDb .
  define stream FileDbKey .

  create widget-pool .
  define variable w-login as widget-handle no-undo.
  create window w-login assign
         title              = "Проверка ключей БД"
         column             = 31.5
         row                = 9
         height             = 2.0
         width              = 10
         resize             = false
         scroll-bars        = false
         status-area        = false
         three-d            = true
         message-area       = false
         sensitive          = true
         visible            = true
         .

  define frame a
    v-ind           format ">>9"   label "Обработано ключей" skip
    v-current-time  format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Проверка ключей БД"
    .

  assign
    current-window = w-login
    v-start-time   = etime
  .

  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  view frame a.

  /* в новости ничего не должно пойти */
  disable triggers for load of ub.db .

  assign
    v-err-code        = -1
    v-load-db-key-now = TRUE
  .

  do while v-err-code <> 0
     and v-load-db-key-now = TRUE
  on error undo, return error
  :
    /* удалим файл ошибок */
    os-delete value( {&err-file} ) .

    assign
      v-ind = 0
    .
    display
      v-ind
      v-current-time
      with frame a .

    for each buf_db no-lock
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0 then do:
        assign
          v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
        .

        display
          v-ind
          v-current-time
          with frame a.
      end.

      run check-enc in this-procedure
        ( input buf_db.db-num
         ,input buf_db.db-key
         ,input "":U
         ,input "":U
         ,input ?
         ,input ?
         ,input buf_db.db-key-enc
         ,output v-log
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при проверке кодированых ключей БД! (1)" ) skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return error .
      end.

      if v-log <> TRUE then do:
        assign
          v-err-code = 1
        .
        output stream NecesDb to {&err-file} append.
        put stream NecesDb unformatted
          substitute( "БД: &1 Ключ: &2 Кодированое значение: &3", buf_db.db-num, buf_db.db-key, buf_db.db-key-enc ) skip
        .
        output stream NecesDb close.
      end.
    end.

    if v-err-code > 0
    then do:
      { gbl/getcurus.i
        v-check-db-num
        v-check-user-id
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при определении текущей БД и/или пользователя") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      { gbl/user-adm.i
        v-check-db-num
        v-check-user-id
        v-check-user-admin
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при определении является ли текущий пользователь администратором") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.

      if v-check-user-admin = true
        and v-get-ro_read-only = false
      then do:
        message
          "Требуется загрузка кодированых ключей БД!" skip
          "Список БД с неправильной кодировкой ключей выведен в файл" {&space-char} {&err-file} skip
          "Загрузить кодированые ключи БД сейчас?" skip
          view-as alert-box question buttons yes-no update v-load-db-key-now.

        if v-load-db-key-now = TRUE then do:
          SYSTEM-DIALOG GET-FILE
            v-file-name
            FILTERS "Текстовые файлы  *.txt" "*.txt",
                    "Все файлы"  "*.*"
            MUST-EXIST
            TITLE "Выберите файл для импорта кодированых ключей"
            USE-FILENAME
            UPDATE v-log.

          if v-log <> true then do:
            return error .
          end.

          assign
            v-delimeter = {&space-char}
            v-last-key  = 0
          .
          input stream FileDbKey from value(v-file-name) .
          block_read:
          repeat while v-last-key <> -2
          on error undo, return error
          :
            assign
              v-last-key   = 0
              v-str        = "":U
              v-db-num     = -1
              v-db-key     = "":U
              v-db-key-enc = "":U

            .
            do while v-last-key <> 13
                     and v-last-key <> -2 /* конец файла */
            on error undo, return error
            :
              readkey stream FileDbKey pause 0.
              assign
                v-last-key = lastkey
                v-str = v-str + chr( v-last-key )
              .
            end.
            assign
              v-str = trim( v-str )
              v-num-entries = num-entries( v-str, v-delimeter )
            .
            if v-str = "":U then do:
              next.
            end.
            if v-num-entries > 3 then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Некорректный файл ключей БД!" ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            assign
              v-db-num = integer( entry( 1, v-str, v-delimeter ) ) no-error
            .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при чтении файла ключей БД!" ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.

            if v-num-entries >= 2 then do:
              assign
                v-db-key = entry( 2, v-str, v-delimeter )
              .
            end.
            if v-num-entries = 3 then do:
              assign
                v-db-key-enc = entry( 3, v-str, v-delimeter )
              .
            end.

            find first buf_db
              where buf_db.db-num = v-db-num
              no-error
            .
            if not available buf_db then do:
              next.
            end.
            if ( ( v-db-num = 0
                   and buf_db.db-key <> "":U
                 )
                 or v-db-num <> 0
               )
              and buf_db.db-key <> v-db-key
            then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "В файле импорта обнаружено несоответствие ключей по БД &1 !", v-db-num ) skip
                substitute( "В БД: Ключ - &1", buf_db.db-key ) skip
                substitute( "В файле: Ключ - &1", v-db-key ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            run check-enc in this-procedure
              ( input v-db-num
               ,input v-db-key
               ,input "":U
               ,input "":U
               ,input ?
               ,input ?
               ,input v-db-key-enc
               ,output v-log
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при проверке кодированых ключей БД! (2)" ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            if v-log <> TRUE then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "В файле импорта обнаружена ошибка кодировки ключей БД!" ) skip
                substitute( "БД: &1; Ключ БД: &2; Кодированое значение: &3", v-db-num, v-db-key, v-db-key-enc ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.

            if buf_db.db-key <> v-db-key then do:
              assign
                buf_db.db-key = v-db-key
              .
            end.
            assign
              buf_db.db-key-enc = v-db-key-enc
              v-err-code        = 0
            .
          end.
          input stream FileDbKey close.

          if v-err-code = 0 then do:
            message
              "Предоставленные кодированые значения ключей БД загружены!"
              view-as alert-box information.
          end.
        end.
        else do:
          return error.
        end.
      end.
      else do:
        message "Требуется загрузка кодированых ключей БД!" skip
                "Список БД с неправильной кодировкой ключей выведен в файл" {&space-char} {&err-file} skip
                "Обратитесь к администратору системы."
          view-as alert-box error.
        return error.
      end.
    end.
    else do:
      assign
        v-err-code = 0
      .
    end.

  end.

  hide frame a .

  delete object w-login .

end.

return.