block-level on error undo, throw.
/*

$Revision: 3ac8d1d44d52, 3383, rls $
$Author: DRuban $
$Date: 2023/05/31 09:28:12 $
$Workfile: actn-upd.p $
$Archive: gbl/actn-upd.p $

Проверка и загрузка прав доступа

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/09
Author: Dmitry Ukhanov
Creation date: 10/06/09

Автор2: Белоусов Илья Александрович
Дата создания2: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания1: 05/16/06

*/

define input  parameter parparentproc       as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 3ac8d1d44d52, 3383, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: actn-upd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/actn-upd.p $":U .
define variable vss-description as character no-undo init "Проверка и загрузка прав доступа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ gbl/get-ro.i   }

&scoped-define bt-actn-update  "actn-update":U

define temp-table temp-action-group no-undo
  field action-group-code          as integer
  field action-group-id            as character
  field action-group-name          as character
  field action-group-description   as character
  field action-group-configuration as character

  index xpk is primary unique action-group-code
  index xie1 action-group-id
.


define temp-table temp-action-item no-undo
  field action-item-code           as integer
  field action-item-id             as character
  field action-item-context        as character
  field action-item-configuration  as character
  field action-group-code          as integer
  field action-group-id            as character
  field action-item-name           as character
  field action-item-description    as character
  field action-item-encoded        as character

  index xpk is primary unique action-item-code
  index xie1 action-item-id
.

define temp-table temp-action-item-attr no-undo
  field action-item-code           as integer
  field attr-code                  as character
  field attr-value                 as character

  index xpk is primary unique action-item-code
.
  define buffer buf_global-state             for ub.global-state .
  define buffer buf_global-state-attr        for ub.global-state-attr .
  define variable v-action-gbl               as logical no-undo .

define buffer buf_batchprocess for ub.batchprocess .

define variable v-action-head-code as integer   no-undo .

define stream sinp .

do
on error undo, return error return-value
:
  assign
    v-action-head-code = {&action-head-code-main}
  .
       FIND FIRST buf_global-state
        NO-LOCK
        .
   FIND FIRST buf_global-state-attr
        WHERE buf_global-state-attr.gls-id    = buf_global-state.gls-id
          AND buf_global-state-attr.attr-code = "action-gbl"
        NO-LOCK
        NO-error
        .
        if available (buf_global-state-attr) then v-action-gbl = logical (buf_global-state-attr.attr-value) .
        
  run check-action-item in this-procedure
    .
end.



procedure check-action-item :

  define variable v-action-db-control-number   as character no-undo .
  define variable v-action-file-name           as character no-undo .
  define variable v-action-file-control-number as character no-undo .

  define variable v-sys-key                    as character no-undo .
  define variable v-get-ro_read-only           as logical   no-undo .


  define buffer buf_action-head for ub.action-head .

  do
  on error undo, return error return-value
  :
    run get-action-db-control-number in this-procedure
      (output v-action-db-control-number
      ) .

    run get-action-file-name in this-procedure
      (output v-action-file-name
      ) .
    if v-action-file-name = ""
    or v-action-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден файл с описание прав" "cmp/actn.enc" skip
        "Работа системы будет продолжена, но возможно некоторые функции системы" skip
        "работать не будут" skip
        view-as alert-box error .
      return . /* --->>>--- */
    end.

    run get-action-file-control-number in this-procedure
      (input  v-action-file-name
      ,output v-action-file-control-number
      ) .

    if v-action-db-control-number <> v-action-file-control-number
    then do:

      assign
        v-get-ro_read-only = false
      .
      run get-ro_get-read-only in this-procedure
        ( output v-get-ro_read-only
        ) .
      if v-get-ro_read-only = false then do:
        { gbl/currsysk.i
          v-sys-key
          no-error
        }

        if v-sys-key = {&SuperSysKey}
        then do:
          define variable v-ok as logical   no-undo .
          message
            "Описание прав изменилось" skip
            "Контрольный номер в базе данных" v-action-db-control-number skip
            "Контрольный номер в файле"       v-action-file-control-number skip
            "Путь к файлу" v-action-file-name skip
            "Загрузить в базу данных описание прав?"
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok <> true
          then do:
            return . /* --->>>--- */
          end.
        end.

        do transaction
        on error undo, return error return-value
        :
          run lock-action-head in this-procedure
            (buffer buf_action-head
            ) .
          if buf_action-head.action-head-control-number = v-action-file-control-number
          then do:
            /* система прав уже была обновлена другим пользователем */
                DELETE buf_batchprocess.
            return . /* --->>>--- */
          end.

          run read-action-item in this-procedure
            (input v-action-file-name
            ) .

/*          run filter-configuration-action-group in this-procedure
            .

          run filter-configuration-action-item in this-procedure
            .
*/
          run validate-action-item in this-procedure
            no-error .
          if  error-status :error
          then do:
            if v-sys-key = {&SuperSysKey}
            then do:
              assign
                v-ok = false
              .
              message
                "При проверке прав были обнаружены ошибки" skip
                "Загрузить в базу данных описание прав?"
                view-as alert-box question buttons yes-no update v-ok .
              if v-ok <> true
              then do:
                  DELETE buf_batchprocess.
                return . /* --->>>--- */
              end.
            end.
            else do:
              message
                vss-workfile vss-revision vss-description skip
                "При проверке прав были обнаружены ошибки" skip
                "Права не были загружены" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
                DELETE buf_batchprocess.
              return . /* --->>>--- */
            end.
          end.

          run clear-action in this-procedure .

          run write-action in this-procedure .

          run update-action-role-item in this-procedure .

          run update-user-login-action-item in this-procedure .

          assign
            buf_action-head.action-head-control-number = v-action-file-control-number
          .
          DELETE buf_batchprocess.
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip(1)
          substitute("Описание прав изменилось") skip
          substitute("До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!") skip
          view-as alert-box error .
        return error .
      end.

      /* отладочная выгрузка */
/*      run export-action-item in this-procedure .*/
    end.

    run waitfram-hide in this-procedure .
  end.


end procedure. /* check-action-item */


procedure get-action-db-control-number :

  define output parameter p-action-db-control-number as character no-undo .

  define buffer buf_action-head for ub.action-head .

  do
  on error undo, return error return-value
  :
    find first buf_action-head no-lock
      where buf_action-head.action-head-code = v-action-head-code
      no-error .
    if available buf_action-head
    then do:
      assign
        p-action-db-control-number = buf_action-head.action-head-control-number
      .
    end.
    else do:
      assign
        p-action-db-control-number = '':u
      .
    end.
  end.

end procedure. /* get-db-control-number */


procedure get-action-file-name :

  define output parameter p-action-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-action-file-name = search("cmp/actn.enc")
    .
  end.

end procedure. /* get-action-file-name */


procedure get-action-file-control-number :

  define input  parameter p-action-file-name           as character no-undo .
  define output parameter p-action-file-control-number as character no-undo .

  define variable v-str-encrypt        as character no-undo .

  do
  on error undo, return error return-value
  :
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").

    input stream sinp from value(p-action-file-name) .

    import stream sinp UNFORMATTED v-str-encrypt .
    { gbl/pdecrypt.i v-str-encrypt p-action-file-control-number }
    /*
    run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                      , OUTPUT p-action-file-control-number
                                      ) .
    */
    ASSIGN
       p-action-file-control-number = TRIM(p-action-file-control-number, '~" ')
    .
/*    import stream sinp p-action-file-control-number . */
    input stream sinp close .

  end.

end procedure. /* get-file-control-number */


procedure lock-action-head :

  define parameter buffer buf_action-head for ub.action-head .

  do
  on error undo, return error return-value
  :
    find first buf_action-head exclusive-lock
      where buf_action-head.action-head-code = v-action-head-code
      no-error .
    if not available buf_action-head
    then do:
      create buf_action-head .
      assign
        buf_action-head.action-head-code           = v-action-head-code
        buf_action-head.action-head-name           = "Системные права"
        buf_action-head.action-head-control-number = ""
      .
    end.
    for each  buf_batchprocess
        where buf_batchprocess.bp_type     = {&bt-actn-update}
          and buf_batchprocess.bp_status   = {&btpr-normal}
        exclusive-lock
         :
         DELETE buf_batchprocess.
    END.
    create buf_batchprocess .

    assign
       buf_batchprocess.bp_type        = {&bt-actn-update}
       buf_batchprocess.bp_status      = {&btpr-normal}
       buf_batchprocess.batchprocess#  = next-value(s-btpr, {&db-name_schema})
       /*
       buf_batchprocess.user_id        = p-user-id
       */
       buf_batchprocess.bp_sysdate     = TODAY
       buf_batchprocess.bp_systime     = string( time, 'hh:mm' )
       buf_batchprocess.bp_systimeint  = TIME
    .
  end.

end procedure. /* lock-action-head */

procedure read-action-item :

  define input  parameter p-action-file-name as character no-undo .

  define buffer buf_action-head            for ub.action-head .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_temp-action-group      for temp-action-group .
  define buffer buf_temp-action-item       for temp-action-item .
  define buffer buf_temp-action-item-attr  for temp-action-item-attr .


  define variable v-action-head-control-number as character no-undo .
  define variable v-tag-name                   as character no-undo .
  define variable v-action-group-code          as integer   no-undo .
  define variable v-action-group-id            as character no-undo .
  define variable v-action-group-name          as character no-undo .
  define variable v-action-group-description   as character no-undo .
  define variable v-action-group-configuration as character no-undo .
  define variable v-action-item-code           as integer   no-undo .
  define variable v-action-item-id             as character no-undo .
  define variable v-action-item-context        as character no-undo .
  define variable v-action-item-configuration  as character no-undo .
  define variable v-action-item-name           as character no-undo .
  define variable v-action-item-description    as character no-undo .
  define variable v-action-item-encoded        as character no-undo .
  define variable v-action-item-attr-value     as character no-undo .

  define variable v-str-encrypt        as character no-undo .
  define variable v-str-decrypt        as character no-undo .
  define variable v-cc    as integer      no-undo.

  do
  on error undo, return error return-value
  :
    input stream sinp from value(p-action-file-name) .

    import stream sinp UNFORMATTED v-str-encrypt .
    v-cc = v-cc + 1.

    assign
      v-action-group-code = 0
    .

    read_action_group:
    repeat
    :
      assign
        v-tag-name      = '':u
        v-str-encrypt   = '':U
      .
      import stream sinp UNFORMATTED v-str-encrypt .
      v-cc = v-cc + 1.
      { gbl/pdecrypt.i v-str-encrypt v-tag-name }
      v-tag-name = TRIM( v-tag-name , '~" ').
      /*
      run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                        , OUTPUT v-tag-name
                                        ) .
      */


      if v-tag-name = 'action-group':u
      then do:
        assign
          v-action-group-code          = v-action-group-code + 1
          v-action-group-id            = '':u
          v-action-group-name          = '':u
          v-action-group-description   = '':u
          v-action-group-configuration = '':U
          v-str-encrypt                = '':U
        .

        import stream sinp UNFORMATTED v-str-encrypt .
        v-cc = v-cc + 1.
        { gbl/pdecrypt.i v-str-encrypt v-str-decrypt }
        /*
        run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                          , OUTPUT v-str-decrypt
                                          ) .
        */
        ASSIGN
          v-action-group-id            = TRIM(SUBSTRING(v-str-decrypt, 1  , 11), '~" ')
          v-action-group-name          = TRIM(SUBSTRING(v-str-decrypt, 12 , 25), '~" ')
          v-action-group-description   = TRIM(SUBSTRING(v-str-decrypt, 38 , 40), '~" ')
          v-action-group-configuration = TRIM(SUBSTRING(v-str-decrypt, 79 , 14), '~" ')
        .

        create buf_temp-action-group .
        assign
          buf_temp-action-group.action-group-code          = v-action-group-code
          buf_temp-action-group.action-group-id            = v-action-group-id
          buf_temp-action-group.action-group-name          = v-action-group-name
          buf_temp-action-group.action-group-description   = v-action-group-description
          buf_temp-action-group.action-group-configuration = v-action-group-configuration
        .
      end.

      if v-tag-name = 'action-item':u
      then do:
        leave read_action_group . /* --->>>--- */
      end.
    end. /* repeat read_action_group */

    assign
      v-action-item-code = 0
    .

    read_action_item:
    repeat
    :
      assign
        v-action-item-code          = v-action-item-code + 1
        v-action-item-id            = '':u
        v-action-item-context       = '':u
        v-action-item-configuration = '':u
        v-action-group-id           = '':u
        v-action-item-name          = '':u
        v-action-item-description   = '':u
        v-action-item-encoded       = '':u
        v-action-item-attr-value    = '':u
        v-str-encrypt               = '':U
      .

      if v-action-item-code modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Чтение описания прав из файла &1"
                           ,v-action-item-code
                           )
          ) .
      end.

      import stream sinp UNFORMATTED v-str-encrypt .
       v-cc = v-cc + 1.

      { gbl/pdecrypt.i v-str-encrypt v-str-decrypt }

      IF length(v-str-decrypt) > 1 then do:
         ASSIGN
            v-action-item-id            = TRIM(SUBSTRING(v-str-decrypt, 1  ,  53), '~" ')
            v-action-item-context       = TRIM(SUBSTRING(v-str-decrypt, 54 ,   8), '~" ')
            v-action-item-configuration = TRIM(SUBSTRING(v-str-decrypt, 63 ,  28), '~" ')
            v-action-group-id           = TRIM(SUBSTRING(v-str-decrypt,  92,   9), '~" ')
            v-action-item-name          = TRIM(SUBSTRING(v-str-decrypt, 102, 130), '~" ')
            v-action-item-description   = TRIM(SUBSTRING(v-str-decrypt, 233, 233), '~" ')
            v-action-item-encoded       = TRIM(SUBSTRING(v-str-decrypt, 436,  10), '~" ')
            v-action-item-attr-value    = TRIM(SUBSTRING(v-str-decrypt, 467,  50), '~" ')
         .
      end.
      else do:
        leave read_action_item.
      end.

      assign
        v-action-item-description = replace(v-action-item-description, "~{&abbr_rubley~}", "{&abbr_rubley}")
        v-action-item-description = replace(v-action-item-description, "~{&abbr_rublyam_allshift~}", "{&abbr_rublyam_allshift}")
      .

      if lookup('~{&', v-action-item-description) > 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "В правах задан препроцессинг для которого не указан способ обработки" skip
          "Идентификатор права" v-action-item-id skip
          "Имя права" v-action-item-description skip
          view-as alert-box error .
      end.

      find first buf_temp-action-item
        where buf_temp-action-item.action-item-id = v-action-item-id
        no-error .
      if available buf_temp-action-item
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании права" skip
          "Уже создано право с таким же идентификатором" v-action-item-id skip
          "action-item-id"             v-action-item-id             skip
          "action-item-context"        v-action-item-context        skip
          "action-group-configuration" v-action-group-configuration skip
          "action-group-id"            v-action-group-id            skip
          "action-item-name"           v-action-item-name           skip
          "action-item-description"    v-action-item-description    skip
          "action-item-encoded"        v-action-item-encoded        skip
          view-as alert-box error .
      end.

      create buf_temp-action-item .
      assign
        buf_temp-action-item.action-item-code          = v-action-item-code
        buf_temp-action-item.action-item-id            = v-action-item-id
        buf_temp-action-item.action-item-context       = v-action-item-context
        buf_temp-action-item.action-item-configuration = v-action-item-configuration
        buf_temp-action-item.action-group-code         = 0
        buf_temp-action-item.action-group-id           = v-action-group-id
        buf_temp-action-item.action-item-name          = v-action-item-name
        buf_temp-action-item.action-item-description   = v-action-item-description
        buf_temp-action-item.action-item-encoded       = v-action-item-encoded
      .
      if length(v-action-item-attr-value) <> 0 then do :
        find first buf_temp-action-item-attr
          where buf_temp-action-item-attr.action-item-code = v-action-item-code
          no-error.
        if available buf_temp-action-item-attr
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании атрибута Linking"                        skip
            "Уже существует атрибут"        v-action-item-attr-value     skip
            "Для права с идентификатором"   v-action-item-id             skip
            "action-item-context"           v-action-item-context        skip
            "action-group-configuration"    v-action-group-configuration skip
            "action-group-id"               v-action-group-id            skip
            "action-item-name"              v-action-item-name           skip
            "action-item-description"       v-action-item-description    skip
            "action-item-encoded"           v-action-item-encoded        skip
            view-as alert-box error .
        end.

        create buf_temp-action-item-attr .
        assign
          buf_temp-action-item-attr.action-item-code = v-action-item-code
          buf_temp-action-item-attr.attr-code      = "Linking"
          buf_temp-action-item-attr.attr-value     = v-action-item-attr-value
        .
      end.
    end. /* repeat read_action_item */

    input stream sinp close .
  end. /* do on error */

end procedure. /* read-action-item */


procedure filter-configuration-action-group :

  /* удаляются все группы прав, недоступные в данной конфигурации */

  define buffer buf_temp-action-group for temp-action-group .

  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-action-group
    on error undo, return error return-value
    :
      assign
        v-configuration-list = buf_temp-action-group.action-group-configuration
      .

      if v-configuration-list = '':u
      then do:
        assign
          v-enable-item = true
        .
      end.
      else do:
        assign
          v-enable-item = false
        .
        assign
          v-num-items-configuration-list = num-entries(v-configuration-list)
        .
        check_block :
        do v-ind = 1 to v-num-items-configuration-list
        :
          assign
            v-configuration-item = entry(v-ind, v-configuration-list)
          .
          run value(v-configuration-item) in parparentproc
            (output v-check-enable-item
            ) .
          if v-check-enable-item = true
          then do:
            assign
              v-enable-item = true
            .
            leave check_block . /* --->>>--- */
          end.
        end.
      end.

      if v-enable-item <> true
      then do:
        delete buf_temp-action-group .
      end.
    end.
  end.

end procedure. /* filter-configuration-action-group */


procedure filter-configuration-action-item :

  /* удаляются все права, недоступные в данной конфигурации */

  define buffer buf_temp-action-item for temp-action-item .
  define buffer buf_temp-action-item-attr for temp-action-item-attr .

  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-action-item
    on error undo, return error return-value
    :
      assign
        v-configuration-list = buf_temp-action-item.action-item-configuration
      .

      if v-configuration-list = '':u
      then do:
        assign
          v-enable-item = true
        .
      end.
      else do:
        assign
          v-enable-item = false
        .
        assign
          v-num-items-configuration-list = num-entries(v-configuration-list)
        .
        check_block :
        do v-ind = 1 to v-num-items-configuration-list
        :
          assign
            v-configuration-item = entry(v-ind, v-configuration-list)
          .
          run value(v-configuration-item) in parparentproc
            (output v-check-enable-item
            ) .
          if v-check-enable-item = true
          then do:
            assign
              v-enable-item = true
            .
            leave check_block . /* --->>>--- */
          end.
        end.
      end.

      if v-enable-item <> true
      then do:
        find first buf_temp-action-item-attr exclusive-lock
          where buf_temp-action-item-attr.action-item-code = buf_temp-action-item.action-item-code
          no-error.
        if available buf_temp-action-item-attr then do :
          delete buf_temp-action-item-attr .
        end.
        delete buf_temp-action-item .
      end.
    end.
  end.

end procedure. /* filter-configuration-action-item */


procedure validate-action-item :

  do
  on error undo, return error return-value
  :
    /* todo - написать проверку прав */
  end.

end procedure. /* validate-action-item */


procedure export-action-item :

  define buffer buf_action-group for ub.action-group .
  define buffer buf_action-item  for ub.action-item .

  do
  on error undo, return error return-value
  :

    output to value('actn-export.txt':u) .
    for each buf_action-group
    on error undo, return error return-value
    :
      export "action-group" .
      export buf_action-group .
    end.

    for each buf_action-item
    on error undo, return error return-value
    :
      export "action-item" .
      export buf_action-item .
    end.

    output close .
  end.

end procedure. /* export-action-item */


procedure clear-action :

  define buffer buf_action-group for ub.action-group .
  define buffer buf_action-item  for ub.action-item .
  define buffer buf_action-item-attr for ub.action-item-attr .

  do
  on error undo, return error return-value
  :
    define variable v-ind as integer   no-undo .

    assign
      v-ind = 0
    .

    for each buf_action-group exclusive-lock
      where buf_action-group.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление групп прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-group .
    end.

    assign
      v-ind = 0
    .
    for each buf_action-item exclusive-lock
      where buf_action-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-item .
    end.

    assign
      v-ind = 0
    .
    for each buf_action-item-attr exclusive-lock
      where buf_action-item-attr.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление атрибутов прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-item-attr .
    end.
  end.

end procedure. /* clear-action */

procedure write-action :

  define buffer buf_temp-action-group      for temp-action-group .
  define buffer buf_action-group           for ub.action-group .
  define buffer buf_temp-action-item       for temp-action-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_temp-action-item-attr  for temp-action-item-attr .
  define buffer buf_action-item-attr       for ub.action-item-attr .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .

    for each buf_temp-action-group
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание групп прав &1"
                          ,v-ind
                          )
          ) .
      end.

      create buf_action-group .
      assign
        buf_action-group.action-head-code         = v-action-head-code
        buf_action-group.action-group-code        = buf_temp-action-group.action-group-code
        buf_action-group.action-group-id          = buf_temp-action-group.action-group-id
        buf_action-group.action-group-name        = buf_temp-action-group.action-group-name
        buf_action-group.action-group-description = buf_temp-action-group.action-group-description
      .
    end.

    for each buf_temp-action-item
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание новых прав &1"
                          ,v-ind
                          )
          ) .
      end.

      create buf_action-item .
      assign
        buf_action-item.action-head-code           = v-action-head-code
        buf_action-item.action-item-code           = buf_temp-action-item.action-item-code
        buf_action-item.action-item-id             = buf_temp-action-item.action-item-id
        buf_action-item.action-item-context        = buf_temp-action-item.action-item-context
        buf_action-item.action-group-code          = buf_temp-action-item.action-group-code
        buf_action-item.action-group-id            = buf_temp-action-item.action-group-id
        buf_action-item.action-item-name           = buf_temp-action-item.action-item-name
        buf_action-item.action-item-description    = buf_temp-action-item.action-item-description
        buf_action-item.action-item-encoded        = buf_temp-action-item.action-item-encoded
      .
    end.

    for each buf_temp-action-item-attr
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание атрибутов новых прав &1"
                          ,v-ind
                          )
          ) .
      end.

      create buf_action-item-attr .
      assign
        buf_action-item-attr.action-head-code = v-action-head-code
        buf_action-item-attr.action-item-code = buf_temp-action-item-attr.action-item-code
        buf_action-item-attr.attr-code        = buf_temp-action-item-attr.attr-code
        buf_action-item-attr.attr-value       = buf_temp-action-item-attr.attr-value
      .
    end.
  end.

end procedure. /* write-action */


procedure update-action-role-item :

  define variable v-current-db-num as integer   no-undo .

  define buffer buf_action-role-item         for ub.action-role-item .
  define buffer buf_action-item              for ub.action-item .
  define buffer buf_action-role-item-gds     for ub.action-role-item-gds .
  define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .
  do
  on error undo, return error return-value
  :

            { gbl/curdbnum.i
              v-current-db-num
            }

    for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num           = v-current-db-num
        and buf_action-role-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_action-role-item.action-head-code
          and buf_action-item.action-item-id   = buf_action-role-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_action-role-item.action-item-code = buf_action-item.action-item-code
        .
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
            .
        END.
      end.
      else do:
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = 0
            .
        END.
        assign
          buf_action-role-item.action-item-code = 0
        .
      end.
    end.
    
    if v-current-db-num <> 0 and v-action-gbl then do:
       disable triggers for load of buf_action-role-item .
       v-current-db-num = 0 .
       for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num           = v-current-db-num
        and buf_action-role-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_action-role-item.action-head-code
          and buf_action-item.action-item-id   = buf_action-role-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_action-role-item.action-item-code = buf_action-item.action-item-code
        .
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
            .
        END.
      end.
      else do:
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = 0
            .
        END.
        assign
          buf_action-role-item.action-item-code = 0
        .
      end.
    end.
/*    enable triggers buf_action-role-item .*/
    end.  
  end.

end procedure. /* update-action-role-item */


procedure update-user-login-action-item :

  define variable v-current-db-num as integer   no-undo .

  define buffer buf_user-login-action-item for ub.user-login-action-item.
  define buffer buf_action-item      for ub.action-item .

  do
  on error undo, return error return-value
  :
    
    { gbl/curdbnum.i
      v-current-db-num
    }

    for each buf_user-login-action-item exclusive-lock
      where buf_user-login-action-item.db-num           = v-current-db-num
        and buf_user-login-action-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_user-login-action-item.action-head-code
          and buf_action-item.action-item-id   = buf_user-login-action-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_user-login-action-item.action-item-code = buf_action-item.action-item-code
        .
      end.
      else do:
        assign
          buf_user-login-action-item.action-item-code = 0
        .
      end.
    end.
  end.

end procedure. /* update-user-login-action-item */