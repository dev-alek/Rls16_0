block-level on error undo, throw.
/*

$Revision: 3ac8d1d44d52, 3383, rls $
$Author: DRuban $
$Date: 2023/05/31 09:28:12 $
$Workfile: menu-upd.p $
$Archive: gbl/menu-upd.p $

Проверка необходимости загрузки меню и загрузка меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/09
Author: Dmitry Ukhanov
Creation date: 10/06/09

Автор2: Белоусов Илья Александрович
Дата создания2: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/03/06

*/

define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-dm-menu-handle    as widget-handle no-undo .
define input  parameter p-menu-code         as integer   no-undo .
define input  parameter p-db-num            as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 3ac8d1d44d52, 3383, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menu-upd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/menu-upd.p $":U .
define variable vss-description as character no-undo init "Проверка необходимости загрузки меню и загрузка меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/operlist.i }
{ gbl/waitfram.i }
{ gbl/get-ro.i   }

define temp-table temp-menu-group no-undo
  field menu-group-code          as integer
  field menu-group-id            as character
  field menu-group-name          as character
  field menu-group-description   as character
  field menu-group-licence-param as character
  field button-image-name        as character
  field menu-group-configuration as character
  field menu-group-procedure     as character

  index xpk is primary unique menu-group-code
  index xie1 menu-group-id
  .

define temp-table temp-menu-item no-undo
  field file-item-code     as integer
  field item-code          as integer
  field item-type          as character
  field item-name          as character
  field item-procedure     as character
  field item-id            as character
  field parent-id          as character
  field parent-code        as integer
  field item-condition     as character
  field item-context       as character
  field item-configuration as character
  field item-group-id      as character
  field item-encoded       as character
  field sub-menu-enable    as logical

  index xpk is primary unique file-item-code
  index xie1 item-id
  index xie2 parent-id item-code
  .

define temp-table temp-menu-item-group no-undo
  field menu-code       as integer
  field item-code       as integer
  field item-context    as character
  field menu-group-code as integer
  field parent-code     as integer
  field item-condition  as character

  index xpk is primary unique menu-code item-code item-context menu-group-code
  index ie1 menu-code item-context menu-group-code parent-code item-code
  .

define stream sinp .

define variable v-valid-menu-group-id-list as character no-undo .

do
on error undo, return error return-value
:
  run check-menu-item in this-procedure .
end.

procedure check-menu-item :

  define variable v-db-control-number   as character no-undo .
  define variable v-menu-file-name      as character no-undo .
  define variable v-file-control-number as character no-undo .

  define variable v-sys-key             as character no-undo .

  define variable v-get-ro_read-only    as logical   no-undo .

  define buffer buf_menu-head for ub.menu-head .

  do
  on error undo, return error return-value
  :

    run get-db-control-number in this-procedure
      (output v-db-control-number
      ) .

    run get-menu-file-name in this-procedure
      (output v-menu-file-name
      ) .
    if v-menu-file-name = ""
    or v-menu-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден файл с описание меню" "cmp/menu.enc" skip
        "Работа системы будет продолжена, но возможно некоторые пункты меню" skip
        "работать не будут" skip
        view-as alert-box error .
      return . /* --->>>--- */
    end.

    run get-file-control-number in this-procedure
      (input  v-menu-file-name
      ,output v-file-control-number
      ) .

    if v-db-control-number <> v-file-control-number
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
            "Описание пунктов меню изменилось" skip
            "Контрольный номер в базе данных" v-db-control-number skip
            "Контрольный номер в файле" v-file-control-number skip
            "Путь к файлу" v-menu-file-name skip
            "Загрузить в базу данных описание пунктов меню?"
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok <> true
          then do:
            return . /* --->>>--- */
          end.
        end.

        run lock-menu-head in this-procedure
          (buffer buf_menu-head
          ) .
        if buf_menu-head.control-number = v-file-control-number
        then do:
          /* меню уже было обновлено другим пользователем */
          return . /* --->>>--- */
        end.

        run read-menu-item in this-procedure
          (input v-menu-file-name
          ) .

        run filter-configuration-menu-group in this-procedure
          .

        run filter-configuration-menu-item in this-procedure
          .

        run filter-configuration-sub-menu in this-procedure
          .

        run set-db-code-menu-item in this-procedure
          .

        run set-parent-code-menu-item in this-procedure
          .

        run calculate-menu-item-group in this-procedure
          .

        run validate-menu-item in this-procedure
          no-error .
        if  error-status :error
        then do:
          if v-sys-key = {&SuperSysKey}
          then do:
            assign
              v-ok = false
            .
            message
              "При проверке описания меню были обнаружены ошибки" skip
              "Загрузить в базу данных описание пунктов меню?"
              view-as alert-box question buttons yes-no update v-ok .
            if v-ok <> true
            then do:
              return . /* --->>>--- */
            end.
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "При проверке пунктов меню были обнаружены ошибки" skip
              "Меню не было загружено" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return . /* --->>>--- */
          end.
        end.

        do transaction
        on error undo, return error return-value
        :
          run clear-menu in this-procedure .

          run write-menu in this-procedure .

          run update-user-menu-group in this-procedure .

          assign
            buf_menu-head.control-number = v-file-control-number
          .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip(1)
          substitute("Описание пунктов меню изменилось") skip
          substitute("До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!") skip
          view-as alert-box error .
        return error .
      end.


      /* отладочная выгрузка */
/*      run export-menu-item in this-procedure .*/
    end.

    run waitfram-hide in this-procedure .
  end.

end procedure. /* check-menu-item */

procedure get-db-control-number :

  define output parameter p-db-control-number as character no-undo .

  define buffer buf_menu-head for ub.menu-head .

  do
  on error undo, return error return-value
  :
    find first buf_menu-head no-lock
      where buf_menu-head.menu-code = p-menu-code
      no-error .
    if available buf_menu-head
    then do:
      assign
        p-db-control-number = buf_menu-head.control-number
      .
    end.
    else do:
      assign
        p-db-control-number = '':u
      .
    end.
  end.

end procedure. /* get-db-control-number */

procedure get-menu-file-name :

  define output parameter p-menu-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-menu-file-name = search("cmp/menu.enc")
    .
  end.

end procedure. /* get-menu-file-name */

procedure get-file-control-number :

  define input  parameter p-menu-file-name      as character no-undo .
  define output parameter p-file-control-number as character no-undo .

  define variable v-str-encrypt        as character no-undo .

  do
  on error undo, return error return-value
  :
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
    input stream sinp from value(p-menu-file-name) .

    import stream sinp UNFORMATTED v-str-encrypt .
    { gbl/pdecrypt.i v-str-encrypt p-file-control-number }
    /*
    run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                      , OUTPUT p-file-control-number
                                      ) .
    */
    ASSIGN
       p-file-control-number = TRIM(p-file-control-number, '~" ')
    .
    input stream sinp close .

  end.

end procedure. /* get-file-control-number */


procedure lock-menu-head :

  define parameter buffer buf_menu-head for ub.menu-head .
  define variable v-load    as logical      no-undo.

  do
  on error undo, return error return-value
  :
    find first buf_menu-head exclusive-lock
      where buf_menu-head.menu-code = p-menu-code
      no-error
      no-wait
      .
    if not available buf_menu-head
    then do:
      IF locked buf_menu-head then do:
         message
            "Производится загрузка меню другим пользователем." SKIP
            "Для корректной работы системы необходимо подождать."
         view-as alert-box.

         run waitfram-show in this-procedure ( input "Происходит загрузка меню. Ждите..." ).
         REPEAT :
            find first buf_menu-head
               where buf_menu-head.menu-code = p-menu-code
               exclusive-lock
               no-error
               no-wait
               .
            IF AVAILABLE buf_menu-head THEN DO:
               run waitfram-hide in this-procedure .
               RETURN.
            END. /* exit condition */
            pause 10 no-message.
         END. /* REPEAT */
      end.
      create buf_menu-head .
      assign
        buf_menu-head.menu-code      = p-menu-code
        buf_menu-head.menu-name      = "Системное меню"
        buf_menu-head.control-number = ""
      .
    end.
  end.

end procedure. /* lock-menu-head */

procedure read-menu-item :

  define input  parameter p-menu-file-name as character no-undo .

  define buffer buf_menu-head       for ub.menu-head .
  define buffer buf_menu-item       for ub.menu-item .
  define buffer buf_temp-menu-group for temp-menu-group .
  define buffer buf_temp-menu-item  for temp-menu-item .

  define variable v-control-number     as character no-undo .
  define variable v-file-item-code     as integer   no-undo .
  define variable v-item-type          as character no-undo .
  define variable v-item-name          as character no-undo .
  define variable v-item-procedure     as character no-undo .
  define variable v-item-id            as character no-undo .
  define variable v-parent-id          as character no-undo .
  define variable v-item-condition     as character no-undo .
  define variable v-item-context       as character no-undo .
  define variable v-item-configuration as character no-undo .
  define variable v-item-group-id      as character no-undo .
  define variable v-action-item-id     as character no-undo .
  define variable v-item-encoded       as character no-undo .

  define variable v-str-encrypt        as character no-undo .
  define variable v-str-decrypt        as character no-undo .

  do
  on error undo, return error return-value
  :

    input stream sinp from value(p-menu-file-name) .

    ASSIGN
       v-str-encrypt    = '':U
       v-control-number = '':U
    .

    import stream sinp UNFORMATTED v-str-encrypt .
    { gbl/pdecrypt.i v-str-encrypt v-control-number }
    /*
    run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                      , OUTPUT v-control-number
                                      ) .
    */
    ASSIGN
       v-control-number = TRIM(v-control-number, '~" ')
    .

    define variable v-tag-name                 as character no-undo .
    define variable v-menu-group-code          as integer   no-undo .
    define variable v-menu-group-id            as character no-undo .
    define variable v-menu-group-name          as character no-undo .
    define variable v-menu-group-description   as character no-undo .
    define variable v-menu-group-licence-param as character no-undo .
    define variable v-button-image-name        as character no-undo .
    define variable v-menu-group-configuration as character no-undo .
    define variable v-menu-group-procedure     as character no-undo .

    assign
      v-menu-group-code          = 0
      v-valid-menu-group-id-list = '':U
    .

    read_menu_group:
    repeat
    :
      assign
        v-tag-name = '':u
        v-str-encrypt            = '':U
      .

      import stream sinp UNFORMATTED v-str-encrypt .
      { gbl/pdecrypt.i v-str-encrypt v-tag-name }
      /*
      run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                        , OUTPUT v-tag-name
                                        ) .
      */
      ASSIGN
         v-tag-name = TRIM(v-tag-name, '~" ')
      .
      if v-tag-name = 'menu-group':u
      then do:
        assign
          v-menu-group-code          = v-menu-group-code + 1
          v-menu-group-id            = '':u
          v-menu-group-name          = '':u
          v-menu-group-description   = '':u
          v-menu-group-licence-param = '':U
          v-button-image-name        = '':u
          v-menu-group-configuration = '':U
          v-menu-group-procedure     = '':U
          v-str-encrypt              = '':U
        .

        import stream sinp UNFORMATTED v-str-encrypt .
        { gbl/pdecrypt.i v-str-encrypt v-str-decrypt }
        /*
        run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                          , OUTPUT v-str-decrypt
                                          ) .
        */
        ASSIGN
          v-menu-group-id            = TRIM(SUBSTRING(v-str-decrypt, 1  ,  6), '~" ')
          v-menu-group-name          = TRIM(SUBSTRING(v-str-decrypt, 7  , 25), '~" ')
          v-menu-group-description   = TRIM(SUBSTRING(v-str-decrypt, 32 , 49), '~" ')
          v-menu-group-licence-param = TRIM(SUBSTRING(v-str-decrypt, 81 , 14), '~" ')
          v-button-image-name        = TRIM(SUBSTRING(v-str-decrypt, 95 , 33), '~" ')
          v-menu-group-configuration = TRIM(SUBSTRING(v-str-decrypt, 128, 22), '~" ')
          v-menu-group-procedure     = TRIM(SUBSTRING(v-str-decrypt, 150, 20), '~" ')
        .

        create buf_temp-menu-group .
        assign
          buf_temp-menu-group.menu-group-code          = v-menu-group-code
          buf_temp-menu-group.menu-group-id            = v-menu-group-id
          buf_temp-menu-group.menu-group-name          = v-menu-group-name
          buf_temp-menu-group.menu-group-description   = v-menu-group-description
          buf_temp-menu-group.menu-group-licence-param = v-menu-group-licence-param
          buf_temp-menu-group.button-image-name        = v-button-image-name
          buf_temp-menu-group.menu-group-configuration = v-menu-group-configuration
          buf_temp-menu-group.menu-group-procedure     = v-menu-group-procedure
        .

        assign
          v-valid-menu-group-id-list = v-valid-menu-group-id-list
                                     + (if v-valid-menu-group-id-list <> '':U then ',':U else '':U)
                                     + v-menu-group-id
        .
      end.

      if v-tag-name = 'menu-item':u
      then do:
        leave read_menu_group . /* --->>>--- */
      end.
    end.

    assign
      v-file-item-code = 0
    .

    read_menu_item:
    repeat
    :
      assign
        v-file-item-code     = v-file-item-code + 1
        v-item-type          = '':u
        v-item-name          = '':u
        v-item-procedure     = '':u
        v-item-id            = '':u
        v-parent-id          = '':u
        v-item-condition     = '':u
        v-item-context       = '':u
        v-item-configuration = '':u
        v-item-group-id      = '':u
        v-action-item-id     = '':U
        v-item-encoded       = '':u
        v-str-encrypt        = '':U
      .

      if v-file-item-code modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Чтение описания меню из файла &1"
                          ,v-file-item-code
                          )
          ) .
      end.

      import stream sinp UNFORMATTED v-str-encrypt .
      { gbl/pdecrypt.i v-str-encrypt v-str-decrypt }
      /*
      run vpk_decrypt IN THIS-PROCEDURE ( INPUT  v-str-encrypt
                                        , OUTPUT v-str-decrypt
                                        ) .
      */
      ASSIGN
        v-item-type          = TRIM(SUBSTRING(v-str-decrypt, 1  ,  4), '~" ')
        v-item-name          = TRIM(SUBSTRING(v-str-decrypt, 5  , 57), '~" ')
        v-item-procedure     = TRIM(SUBSTRING(v-str-decrypt, 62 , 63), '~" ')
        v-item-id            = TRIM(SUBSTRING(v-str-decrypt, 125, 27), '~" ')
        v-parent-id          = TRIM(SUBSTRING(v-str-decrypt, 152, 27), '~" ')
        v-item-condition     = TRIM(SUBSTRING(v-str-decrypt, 179, 66), '~" ')
        v-item-context       = TRIM(SUBSTRING(v-str-decrypt, 245, 10), '~" ')
        v-item-configuration = TRIM(SUBSTRING(v-str-decrypt, 255, 81), '~" ')
        v-item-group-id      = TRIM(SUBSTRING(v-str-decrypt, 336, 43), '~" ')
        v-action-item-id     = TRIM(SUBSTRING(v-str-decrypt, 379, 4 ), '~" ')
        v-item-encoded       = TRIM(SUBSTRING(v-str-decrypt, 383, 2 ), '~" ')
      .

      IF v-item-type = 'x-i':u
      THEN DO:
         NEXT read_menu_item.
      END.

      assign
        v-item-name = replace(v-item-name, "~{&abbr_rublyah~}", "{&abbr_rublyah}")
      .

      if lookup('~{&', v-item-name) > 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "В меню задан препроцессинг для которого не указан способ обработки" skip
          "Идентификатор пункта" v-item-id skip
          "Имя пункта" v-item-name skip
          view-as alert-box error .
      end.

      if v-item-type <> 'r-l':u
      then do:
        find first buf_temp-menu-item
          where buf_temp-menu-item.item-id   = v-item-id
          no-error .
        if available buf_temp-menu-item
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании пункта меню" skip
            "Уже создан пункт меню с таким же именем" v-item-id skip
            "item-type"          v-item-type          skip
            "item-name"          v-item-name          skip
            "item-procedure"     v-item-procedure     skip
            "item-id"            v-item-id            skip
            "parent-id"          v-parent-id          skip
            "item-condition"     v-item-condition     skip
            "item-context"       v-item-context       skip
            "item-configuration" v-item-configuration skip
            "item-group-id"      v-item-group-id      skip
            "item-encoded"       v-item-encoded       skip
            view-as alert-box error .
        end.
      end.

      create buf_temp-menu-item .
      assign
        buf_temp-menu-item.file-item-code     = v-file-item-code
        buf_temp-menu-item.item-type          = v-item-type
        buf_temp-menu-item.item-name          = v-item-name
        buf_temp-menu-item.item-procedure     = v-item-procedure
        buf_temp-menu-item.item-id            = v-item-id
        buf_temp-menu-item.parent-id          = v-parent-id
        buf_temp-menu-item.parent-code        = 0
        buf_temp-menu-item.item-condition     = v-item-condition
        buf_temp-menu-item.item-context       = v-item-context
        buf_temp-menu-item.item-configuration = v-item-configuration
        buf_temp-menu-item.item-group-id      = v-item-group-id
        buf_temp-menu-item.item-encoded       = v-item-encoded
      .
    end.

    input stream sinp close .
  end.

end procedure. /* read-menu-item */

procedure export-menu-item :

  define buffer buf_menu-item for ub.menu-item .
  define buffer buf_menu-item-group for ub.menu-item-group .

  do
  on error undo, return error return-value
  :

    output to value('menu-export.txt':u) .
    for each buf_menu-item
    on error undo, return error return-value
    :
      export "menu-item" .
      export buf_menu-item .
    end.

    for each buf_menu-item-group
    on error undo, return error return-value
    :
      export "menu-item-group" .
      export buf_menu-item-group .
    end.

    output close .
  end.

end procedure. /* export-temp-menu-item */


procedure filter-configuration-menu-group :

  /* удаляются все группы меню, недоступные в данной конфигурации */

  define buffer buf_temp-menu-group for temp-menu-group .

  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-group
    on error undo, return error return-value
    :
      assign
        v-configuration-list = buf_temp-menu-group.menu-group-configuration
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
        delete buf_temp-menu-group .
      end.
    end.
  end.

end procedure. /* filter-configuration-menu-group */


procedure filter-configuration-menu-item :

  /* удаляются все пункты меню, недоступные в данной конфигурации */
  /* затем удаляются все пустые группы                            */

  define buffer buf_temp-menu-group for temp-menu-group .
  define buffer buf_temp-menu-item  for temp-menu-item .

  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
    on error undo, return error return-value
    :
      /* проверяется список групп меню */
      /* при этом идентификатор меняется на код */
      define variable v-num-entries-item-group-id as integer   no-undo .
      define variable v-new-item-group-id         as character no-undo .

      assign
        v-num-entries-item-group-id = num-entries(buf_temp-menu-item.item-group-id, {&comma-char})
        v-new-item-group-id         = '':U
      .
      do v-ind = 1 to v-num-entries-item-group-id
      :
        if lookup(entry(v-ind, buf_temp-menu-item.item-group-id, {&comma-char}), v-valid-menu-group-id-list) = 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный идентификатор группы пунктов меню" skip
            "Идентификтор пункта меню" buf_temp-menu-item.item-id skip
            "Номер пункта меню в файле"  buf_temp-menu-item.file-item-code skip
            "Идентификатор группы пукнтов" entry(v-ind, buf_temp-menu-item.item-group-id, {&comma-char}) skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        find first buf_temp-menu-group
          where buf_temp-menu-group.menu-group-id = entry(v-ind, buf_temp-menu-item.item-group-id, {&comma-char})
          no-error .
        if available buf_temp-menu-group
        then do:
          assign
            v-new-item-group-id = v-new-item-group-id
                                + (if v-new-item-group-id <> '':U then ',':U else '':U)
                                + string(buf_temp-menu-group.menu-group-code)
          .
        end.
      end.

      assign
        buf_temp-menu-item.item-group-id = v-new-item-group-id
      .

      if buf_temp-menu-item.item-type <> 's-m':u
      then do:
        if buf_temp-menu-item.item-group-id = '':U
        then do:
          assign
            v-enable-item = false
          .
        end.
        else do:
          assign
            v-configuration-list = buf_temp-menu-item.item-configuration
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
        end.

        if v-enable-item <> true
        then do:
          delete buf_temp-menu-item .
        end.
      end.
    end.
  end.

end procedure. /* filter-configuration-menu-item */

procedure filter-configuration-sub-menu :

  /* пометить все группы, */
  /* которые содержат хотя бы один пункт меню как разрешенные */

  define buffer buf_temp-menu-item        for temp-menu-item .
  define buffer buf_parent_temp-menu-item for temp-menu-item .

  define variable v-parent-id as character no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.item-type = 's-m':u
    on error undo, return error return-value
    :
      assign
        buf_temp-menu-item.sub-menu-enable = false
      .
    end.

    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-id <> '':u
        and ( buf_temp-menu-item.item-type = 'm-i':u
              or buf_temp-menu-item.item-type = 'm-t':u
              or buf_temp-menu-item.item-type = 'r-l':u
            )
    on error undo, return error return-value
    :
      find first buf_parent_temp-menu-item
        where buf_parent_temp-menu-item.item-id = buf_temp-menu-item.parent-id
        no-error
        .
      if not available buf_parent_temp-menu-item then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "В текущей конфигурации должен быть доступен пункт меню,"                                       skip
          substitute( "но недоступен или отсутствует его 'родитель' (&1)", buf_temp-menu-item.parent-id ) skip
          "item-code"          buf_temp-menu-item.item-code                                               skip
          "item-type"          buf_temp-menu-item.item-type                                               skip
          "item-name"          buf_temp-menu-item.item-name                                               skip
          "item-procedure"     buf_temp-menu-item.item-procedure                                          skip
          "item-id"            buf_temp-menu-item.item-id                                                 skip
          "parent-id"          buf_temp-menu-item.parent-id                                               skip
          "item-condition"     buf_temp-menu-item.item-condition                                          skip
          "item-context"       buf_temp-menu-item.item-context                                            skip
          "item-configuration" buf_temp-menu-item.item-configuration                                      skip
          "item-group-id"      buf_temp-menu-item.item-group-id                                           skip
          "item-encoded"       buf_temp-menu-item.item-encoded                                            skip
          view-as alert-box warning .
        delete buf_temp-menu-item .
/*         return error substitute("Не найдено родительское меню (&1) для &2, &3", buf_temp-menu-item.parent-id, buf_temp-menu-item.item-id, buf_temp-menu-item.item-name).*/
      end.
      else do:
        parent_scan:
        do while available buf_parent_temp-menu-item
        :
          if buf_parent_temp-menu-item.sub-menu-enable = true
          then do:
            leave parent_scan . /* --->>>--- */
          end.
          assign
            buf_parent_temp-menu-item.sub-menu-enable = true
          .
          assign
            v-parent-id = buf_parent_temp-menu-item.parent-id
          .
          if v-parent-id = '':u
          then do:
            leave parent_scan . /* --->>>--- */
          end.
          find first buf_parent_temp-menu-item
            where buf_parent_temp-menu-item.item-id = v-parent-id
            .
        end.
      end.
    end.

    for each buf_temp-menu-item
      where buf_temp-menu-item.item-type = 's-m':u
        and buf_temp-menu-item.sub-menu-enable = false
    on error undo, return error return-value
    :
      delete buf_temp-menu-item .
    end.
  end.

end procedure. /* filter-configuration-sub-menu */


procedure set-db-code-menu-item :

  define buffer buf_temp-menu-item for temp-menu-item .

  define variable v-menu-item-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* задать значения item-code в соответствии со структурой меню */

    assign
      v-menu-item-code = 0
    .

    run set-db-code-menu-item-childs
      (input  '':u
      ,input  v-menu-item-code
      ,output v-menu-item-code
      ).
  end.

end procedure. /* set-db-code-menu-item */


procedure set-parent-code-menu-item :

  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_parent_temp-menu-item for temp-menu-item .

  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-id <> ''
    on error undo, return error return-value
    :
      find first buf_parent_temp-menu-item
        where buf_parent_temp-menu-item.item-id = buf_temp-menu-item.parent-id
        no-error .
      if available buf_parent_temp-menu-item
      then do:
        assign
          buf_temp-menu-item.parent-code = buf_parent_temp-menu-item.item-code
        .
      end.
    end.
  end.

end procedure. /* set-parent-code-menu-item */


procedure calculate-menu-item-group :

  define buffer buf_temp-menu-group for temp-menu-group .
  define buffer buf_temp-menu-item-group for temp-menu-item-group .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_parent_temp-menu-item for temp-menu-item .

  define variable v-ind            as integer   no-undo .
  define variable v-context        as character no-undo .
  define variable v-context-list   as character no-undo .
  define variable v-item-condition as character no-undo .
  define variable v-parent-id      as character no-undo .

  do
  on error undo, return error return-value
  :
    /* предвычисляем видимость групп на основании условий видимости пунктов меню */
    /* вычисление производится независимо для каждого типа контекста */

    do v-ind = 1 to 3
    :
      case v-ind :
        when 1
        then do:
          assign
            v-context      = {&cntxt-global}
            v-context-list = {&cntxt-global}
          .
        end.
        when 2
        then do:
          assign
            v-context      = {&cntxt-firm}
            v-context-list = {&cntxt-global} + {&comma-char} + {&cntxt-firm}
          .
        end.
        when 3
        then do:
          assign
            v-context      = {&cntxt-object}
            v-context-list = {&cntxt-global} + {&comma-char} + {&cntxt-firm} + {&comma-char} + {&cntxt-object}
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной v-ind" skip
            v-ind skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .

      for each buf_temp-menu-group
      on error undo, return error return-value
      :
        for each buf_temp-menu-item
          where buf_temp-menu-item.parent-id <> '':u
            and lookup(buf_temp-menu-item.item-context, v-context-list) > 0
            and lookup(string(buf_temp-menu-group.menu-group-code), buf_temp-menu-item.item-group-id) > 0
            and ( buf_temp-menu-item.item-type = 'm-i':u
                  or buf_temp-menu-item.item-type = 'm-t':u
                )
        on error undo, return error return-value
        :
          assign
            v-item-condition = buf_temp-menu-item.item-condition
          .
          find first buf_parent_temp-menu-item
            where buf_parent_temp-menu-item.item-id = buf_temp-menu-item.parent-id
            .
          parent_scan:
          do while available buf_parent_temp-menu-item
          :
            find first buf_temp-menu-item-group
              where buf_temp-menu-item-group.menu-code       = p-menu-code
                and buf_temp-menu-item-group.item-code       = buf_parent_temp-menu-item.item-code
                and buf_temp-menu-item-group.item-context    = v-context
                and buf_temp-menu-item-group.menu-group-code = buf_temp-menu-group.menu-group-code
              no-error .
            if not available buf_temp-menu-item-group
            then do:
              create buf_temp-menu-item-group .
              assign
                buf_temp-menu-item-group.menu-code       = p-menu-code
                buf_temp-menu-item-group.item-code       = buf_parent_temp-menu-item.item-code
                buf_temp-menu-item-group.item-context    = v-context
                buf_temp-menu-item-group.menu-group-code = buf_temp-menu-group.menu-group-code
                buf_temp-menu-item-group.parent-code     = buf_parent_temp-menu-item.parent-code
                buf_temp-menu-item-group.item-condition  = v-item-condition
              .
            end.
            else do:
              assign
                buf_temp-menu-item-group.item-condition
                  = cross-list(buf_temp-menu-item-group.item-condition
                              ,v-item-condition
                              ,{&comma-char}
                              )
              .
            end.
            assign
              v-item-condition = buf_temp-menu-item-group.item-condition
              v-parent-id = buf_parent_temp-menu-item.parent-id
            .
            if v-parent-id = '':u
            then do:
              leave parent_scan . /* --->>>--- */
            end.
            find first buf_parent_temp-menu-item
              where buf_parent_temp-menu-item.item-id = v-parent-id
              .
          end.
        end.
      end.
    end.
  end.

end procedure. /* calculate-menu-item-group */


procedure set-db-code-menu-item-childs :

  define input  parameter p-item-id         as character no-undo .
  define input  parameter p-first-item-code as integer   no-undo .
  define output parameter p-last-item-code  as integer   no-undo .

  define buffer buf_temp-menu-item for temp-menu-item .

  define variable v-menu-item-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-menu-item-code = p-first-item-code
    .

    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-id = p-item-id
    by buf_temp-menu-item.file-item-code
    on error undo, return error
    :
      assign
        v-menu-item-code = v-menu-item-code + 1
      .

      assign
        buf_temp-menu-item.item-code = v-menu-item-code
      .

      if buf_temp-menu-item.item-type = 's-m':u
      then do:
        run set-db-code-menu-item-childs in this-procedure
          (input  buf_temp-menu-item.item-id
          ,input  v-menu-item-code
          ,output v-menu-item-code
          ) .
      end.
    end.

    assign
      p-last-item-code = v-menu-item-code
    .
  end.

end procedure. /* set-db-code-menu-item-childs */


procedure clear-menu :

  define buffer buf_menu-group      for ub.menu-group .
  define buffer buf_menu-item-group for ub.menu-item-group .
  define buffer buf_menu-item       for ub.menu-item .

  do
  on error undo, return error return-value
  :
    define variable v-ind as integer   no-undo .

    assign
      v-ind = 0
    .

    for each buf_menu-group exclusive-lock
      where buf_menu-group.menu-code = p-menu-code
    by buf_menu-group.menu-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Удаление групп меню &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_menu-group .
    end.

    assign
      v-ind = 0
    .
    for each buf_menu-item-group exclusive-lock
      where buf_menu-item-group.menu-code = p-menu-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Удаление групп пунктов меню &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_menu-item-group .
    end.


    assign
      v-ind = 0
    .
    for each buf_menu-item exclusive-lock
      where buf_menu-item.menu-code = p-menu-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Удаление пунктов меню &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_menu-item .
    end.
  end.

end procedure. /* clear-menu */

procedure write-menu :

  define buffer buf_temp-menu-group for temp-menu-group .
  define buffer buf_menu-group for ub.menu-group .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_menu-item      for ub.menu-item .
  define buffer buf_temp-menu-item-group for temp-menu-item-group .
  define buffer buf_menu-item-group for ub.menu-item-group .

  define variable v-ind as integer   no-undo .

  do transaction
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .

    for each buf_temp-menu-group
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Создание групп меню &1"
                          ,v-ind
                          )
          ) .
      end.

      create buf_menu-group .
      assign
        buf_menu-group.menu-group-code          = buf_temp-menu-group.menu-group-code
        buf_menu-group.menu-group-id            = buf_temp-menu-group.menu-group-id
        buf_menu-group.menu-group-name          = buf_temp-menu-group.menu-group-name
        buf_menu-group.menu-group-description   = buf_temp-menu-group.menu-group-description
        buf_menu-group.menu-group-licence-param = buf_temp-menu-group.menu-group-licence-param
        buf_menu-group.button-image-name        = buf_temp-menu-group.button-image-name
        buf_menu-group.menu-group-procedure     = buf_temp-menu-group.menu-group-procedure
      .
    end.

    for each buf_temp-menu-item
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Создание новых пунктов меню &1"
                          ,v-ind
                          )
          ) .
      end.

      if buf_temp-menu-item.item-code = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Пункт меню не прошел обработку"                           skip
          "item-code"          buf_temp-menu-item.item-code          skip
          "item-type"          buf_temp-menu-item.item-type          skip
          "item-name"          buf_temp-menu-item.item-name          skip
          "item-procedure"     buf_temp-menu-item.item-procedure     skip
          "item-id"            buf_temp-menu-item.item-id            skip
          "parent-id"          buf_temp-menu-item.parent-id          skip
          "item-condition"     buf_temp-menu-item.item-condition     skip
          "item-context"       buf_temp-menu-item.item-context       skip
          "item-configuration" buf_temp-menu-item.item-configuration skip
          "item-group-id"      buf_temp-menu-item.item-group-id      skip
          "item-encoded"       buf_temp-menu-item.item-encoded       skip
          view-as alert-box error .
        return error .
      end.

      create buf_menu-item .
      assign
        buf_menu-item.menu-code          = p-menu-code
        buf_menu-item.item-code          = buf_temp-menu-item.item-code
        buf_menu-item.item-type          = buf_temp-menu-item.item-type
        buf_menu-item.item-name          = buf_temp-menu-item.item-name
        buf_menu-item.item-procedure     = buf_temp-menu-item.item-procedure
        buf_menu-item.item-id            = buf_temp-menu-item.item-id
        buf_menu-item.parent-id          = buf_temp-menu-item.parent-id
        buf_menu-item.parent-code        = buf_temp-menu-item.parent-code
        buf_menu-item.item-condition     = buf_temp-menu-item.item-condition
        buf_menu-item.item-context       = buf_temp-menu-item.item-context
        buf_menu-item.item-configuration = buf_temp-menu-item.item-configuration
        buf_menu-item.item-group-id      = buf_temp-menu-item.item-group-id
        buf_menu-item.item-encoded       = buf_temp-menu-item.item-encoded
      .
    end.

    assign
      v-ind = 0
    .

    for each buf_temp-menu-item-group
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Создание групп пунктов меню &1"
                          ,v-ind
                          )
          ) .
      end.

      create buf_menu-item-group .
      assign
        buf_menu-item-group.menu-code       = buf_temp-menu-item-group.menu-code
        buf_menu-item-group.item-code       = buf_temp-menu-item-group.item-code
        buf_menu-item-group.item-context    = buf_temp-menu-item-group.item-context
        buf_menu-item-group.menu-group-code = buf_temp-menu-item-group.menu-group-code
        buf_menu-item-group.parent-code     = buf_temp-menu-item-group.parent-code
        buf_menu-item-group.item-condition  = buf_temp-menu-item-group.item-condition
      .
    end.
  end.

end procedure. /* write-menu */

procedure validate-menu-item :

  define buffer buf_temp-menu-item  for temp-menu-item .
  define buffer buf_temp-menu-group for temp-menu-group .

  define variable v-proc-name   as character no-undo .
  define variable v-proc-found  as logical   no-undo .

  define variable v-error-exist as logical   no-undo .
  define variable v-ind         as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-error-exist = false
    .
    create-temp-menu-item :
    for each buf_temp-menu-item
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление меню. Проверка описания пунктов меню &1"
                          ,v-ind
                          )
          ) .
      end.

      if lookup(buf_temp-menu-item.item-context
               ,{&cntxt-global} + {&comma-char} + {&cntxt-firm} + {&comma-char} + {&cntxt-object}
               ) = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестный тип привязки пункта меню" buf_temp-menu-item.item-context skip
          "item-code"          buf_temp-menu-item.item-code          skip
          "item-type"          buf_temp-menu-item.item-type          skip
          "item-name"          buf_temp-menu-item.item-name          skip
          "item-procedure"     buf_temp-menu-item.item-procedure     skip
          "item-id"            buf_temp-menu-item.item-id            skip
          "parent-id"          buf_temp-menu-item.parent-id          skip
          "item-condition"     buf_temp-menu-item.item-condition     skip
          "item-context"       buf_temp-menu-item.item-context       skip
          "item-configuration" buf_temp-menu-item.item-configuration skip
          "item-group-id"      buf_temp-menu-item.item-group-id      skip
          "item-encoded"       buf_temp-menu-item.item-encoded       skip
          view-as alert-box error .
        assign
          v-error-exist = true
        .
      end.

      define variable v-num-entries-menu-group-id as integer   no-undo .
      define variable v-index-menu-group-id       as integer   no-undo .
      define variable v-value-menu-group-code     as character no-undo .

      assign
        v-num-entries-menu-group-id = num-entries(buf_temp-menu-item.item-group-id, {&comma-char})
      .

      do v-index-menu-group-id = 1 to v-num-entries-menu-group-id
      :
        assign
          v-value-menu-group-code = entry(v-index-menu-group-id
                                         ,buf_temp-menu-item.item-group-id
                                         ,{&comma-char}
                                         )
        .
        find first buf_temp-menu-group
          where buf_temp-menu-group.menu-group-code = integer(v-value-menu-group-code)
          no-error .
        if not available buf_temp-menu-group
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестный код группы пунктов меню" v-value-menu-group-code skip
            "item-code"          buf_temp-menu-item.item-code          skip
            "item-type"          buf_temp-menu-item.item-type          skip
            "item-name"          buf_temp-menu-item.item-name          skip
            "item-procedure"     buf_temp-menu-item.item-procedure     skip
            "item-id"            buf_temp-menu-item.item-id            skip
            "parent-id"          buf_temp-menu-item.parent-id          skip
            "item-condition"     buf_temp-menu-item.item-condition     skip
            "item-context"       buf_temp-menu-item.item-context       skip
            "item-configuration" buf_temp-menu-item.item-configuration skip
            "item-group-id"      buf_temp-menu-item.item-group-id      skip
            "item-encoded"       buf_temp-menu-item.item-encoded       skip
            view-as alert-box error .
        end.
      end.

      case buf_temp-menu-item.item-type
      :
        when 's-m':u
        then do:
        end.
        when 'r-l':u
        then do:
        end.
        when 'm-i':u
        then do:
          if lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'int':u + {&comma-char} + 'ext':u + {&comma-char} + 'par':u + {&comma-char} + 'lst':u + {&comma-char} + 'pst':u
                   ) = 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестный тип процедуры" buf_temp-menu-item.item-procedure skip
              "item-code"          buf_temp-menu-item.item-code          skip
              "item-type"          buf_temp-menu-item.item-type          skip
              "item-name"          buf_temp-menu-item.item-name          skip
              "item-procedure"     buf_temp-menu-item.item-procedure     skip
              "item-id"            buf_temp-menu-item.item-id            skip
              "parent-id"          buf_temp-menu-item.parent-id          skip
              "item-condition"     buf_temp-menu-item.item-condition     skip
              "item-context"       buf_temp-menu-item.item-context       skip
              "item-configuration" buf_temp-menu-item.item-configuration skip
              "item-group-id"      buf_temp-menu-item.item-group-id      skip
              "item-encoded"       buf_temp-menu-item.item-encoded       skip
              view-as alert-box error .
            assign
              v-error-exist = true
            .
          end.

          if  (lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'int':u + {&comma-char} + 'ext':u + {&comma-char} + 'par':u
                   ) <> 0
               and num-entries(buf_temp-menu-item.item-procedure, {&comma-char}) <> 2
              )
          or  (lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'lst':u + {&comma-char} + 'pst':u
                   ) <> 0
               and num-entries(buf_temp-menu-item.item-procedure, {&comma-char}) <> 3
              )
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неправильное количество элементов в имени процедуры" buf_temp-menu-item.item-procedure skip
              "item-code"          buf_temp-menu-item.item-code          skip
              "item-type"          buf_temp-menu-item.item-type          skip
              "item-name"          buf_temp-menu-item.item-name          skip
              "item-procedure"     buf_temp-menu-item.item-procedure     skip
              "item-id"            buf_temp-menu-item.item-id            skip
              "parent-id"          buf_temp-menu-item.parent-id          skip
              "item-condition"     buf_temp-menu-item.item-condition     skip
              "item-context"       buf_temp-menu-item.item-context       skip
              "item-configuration" buf_temp-menu-item.item-configuration skip
              "item-group-id"      buf_temp-menu-item.item-group-id      skip
              "item-encoded"       buf_temp-menu-item.item-encoded       skip
              view-as alert-box error .
            assign
              v-error-exist = true
            .
            undo create-temp-menu-item, next create-temp-menu-item .
          end.

          assign
            v-proc-name = entry(2, buf_temp-menu-item.item-procedure, {&comma-char})
          .

          if p-dm-menu-handle <> ?
          then do:
            if  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'int':u
            and p-dm-menu-handle :get-signature(v-proc-name) = ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Не найдена внутренняя процедура" v-proc-name skip
                "item-code"          buf_temp-menu-item.item-code          skip
                "item-type"          buf_temp-menu-item.item-type          skip
                "item-name"          buf_temp-menu-item.item-name          skip
                "item-procedure"     buf_temp-menu-item.item-procedure     skip
                "item-id"            buf_temp-menu-item.item-id            skip
                "parent-id"          buf_temp-menu-item.parent-id          skip
                "item-condition"     buf_temp-menu-item.item-condition     skip
                "item-context"       buf_temp-menu-item.item-context       skip
                "item-configuration" buf_temp-menu-item.item-configuration skip
                "item-group-id"      buf_temp-menu-item.item-group-id      skip
                "item-encoded"       buf_temp-menu-item.item-encoded       skip
                view-as alert-box error .
              assign
                v-error-exist = true
              .
            end.
          end.

          if  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'ext':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'par':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'str':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'pst':u
          then do:
            assign
              v-proc-found = false
            .

            if search(v-proc-name) <> ?
            then do:
              assign
                v-proc-found = true
              .
            end.

            if v-proc-found = false
            and search( entry(1, v-proc-name, '.') + '.r':u ) <> ?
            then do:
              assign
                v-proc-found = true
              .
            end.

            if v-proc-found <> true
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Не найдена внешняя процедура" v-proc-name skip
                "item-code"          buf_temp-menu-item.item-code          skip
                "item-type"          buf_temp-menu-item.item-type          skip
                "item-name"          buf_temp-menu-item.item-name          skip
                "item-procedure"     buf_temp-menu-item.item-procedure     skip
                "item-id"            buf_temp-menu-item.item-id            skip
                "parent-id"          buf_temp-menu-item.parent-id          skip
                "item-condition"     buf_temp-menu-item.item-condition     skip
                "item-context"       buf_temp-menu-item.item-context       skip
                "item-configuration" buf_temp-menu-item.item-configuration skip
                "item-group-id"      buf_temp-menu-item.item-group-id      skip
                "item-encoded"       buf_temp-menu-item.item-encoded       skip
                view-as alert-box error .
              assign
                v-error-exist = true
              .
            end.
          end.
        end.
        when 'm-t':u
        then do:
          if lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'int':u + {&comma-char} + 'ext':u + {&comma-char} + 'par':u + {&comma-char} + 'lst':u + {&comma-char} + 'pst':u
                   ) = 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестный тип процедуры" buf_temp-menu-item.item-procedure skip
              "item-code"          buf_temp-menu-item.item-code          skip
              "item-type"          buf_temp-menu-item.item-type          skip
              "item-name"          buf_temp-menu-item.item-name          skip
              "item-procedure"     buf_temp-menu-item.item-procedure     skip
              "item-id"            buf_temp-menu-item.item-id            skip
              "parent-id"          buf_temp-menu-item.parent-id          skip
              "item-condition"     buf_temp-menu-item.item-condition     skip
              "item-context"       buf_temp-menu-item.item-context       skip
              "item-configuration" buf_temp-menu-item.item-configuration skip
              "item-group-id"      buf_temp-menu-item.item-group-id      skip
              "item-encoded"       buf_temp-menu-item.item-encoded       skip
              view-as alert-box error .
            assign
              v-error-exist = true
            .
          end.

          if  (lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'int':u + {&comma-char} + 'ext':u + {&comma-char} + 'par':u
                   ) <> 0
               and num-entries(buf_temp-menu-item.item-procedure, {&comma-char}) <> 2
              )
          or  (lookup(entry(1, buf_temp-menu-item.item-procedure, {&comma-char})
                   ,'lst':u + {&comma-char} + 'pst':u
                   ) <> 0
               and num-entries(buf_temp-menu-item.item-procedure, {&comma-char}) <> 3
              )
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неправильное количество элементов в имени процедуры" buf_temp-menu-item.item-procedure skip
              "item-code"          buf_temp-menu-item.item-code          skip
              "item-type"          buf_temp-menu-item.item-type          skip
              "item-name"          buf_temp-menu-item.item-name          skip
              "item-procedure"     buf_temp-menu-item.item-procedure     skip
              "item-id"            buf_temp-menu-item.item-id            skip
              "parent-id"          buf_temp-menu-item.parent-id          skip
              "item-condition"     buf_temp-menu-item.item-condition     skip
              "item-context"       buf_temp-menu-item.item-context       skip
              "item-configuration" buf_temp-menu-item.item-configuration skip
              "item-group-id"      buf_temp-menu-item.item-group-id      skip
              "item-encoded"       buf_temp-menu-item.item-encoded       skip
              view-as alert-box error .
            assign
              v-error-exist = true
            .
            undo create-temp-menu-item, next create-temp-menu-item .
          end.

          assign
            v-proc-name = entry(2, buf_temp-menu-item.item-procedure, {&comma-char})
          .

          if p-dm-menu-handle <> ?
          then do:
            if  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'int':u
            and p-dm-menu-handle :get-signature(v-proc-name) = ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Не найдена внутренняя процедура" v-proc-name skip
                "item-code"          buf_temp-menu-item.item-code          skip
                "item-type"          buf_temp-menu-item.item-type          skip
                "item-name"          buf_temp-menu-item.item-name          skip
                "item-procedure"     buf_temp-menu-item.item-procedure     skip
                "item-id"            buf_temp-menu-item.item-id            skip
                "parent-id"          buf_temp-menu-item.parent-id          skip
                "item-condition"     buf_temp-menu-item.item-condition     skip
                "item-context"       buf_temp-menu-item.item-context       skip
                "item-configuration" buf_temp-menu-item.item-configuration skip
                "item-group-id"      buf_temp-menu-item.item-group-id      skip
                "item-encoded"       buf_temp-menu-item.item-encoded       skip
                view-as alert-box error .
              assign
                v-error-exist = true
              .
            end.
          end.

          if  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'ext':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'par':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'str':u
          or  entry(1, buf_temp-menu-item.item-procedure, {&comma-char}) = 'pst':u
          then do:
            assign
              v-proc-found = false
            .

            if search(v-proc-name) <> ?
            then do:
              assign
                v-proc-found = true
              .
            end.

            if v-proc-found = false
            and search( entry(1, v-proc-name, '.') + '.r':u ) <> ?
            then do:
              assign
                v-proc-found = true
              .
            end.

            if v-proc-found <> true
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Не найдена внешняя процедура" v-proc-name skip
                "item-code"          buf_temp-menu-item.item-code          skip
                "item-type"          buf_temp-menu-item.item-type          skip
                "item-name"          buf_temp-menu-item.item-name          skip
                "item-procedure"     buf_temp-menu-item.item-procedure     skip
                "item-id"            buf_temp-menu-item.item-id            skip
                "parent-id"          buf_temp-menu-item.parent-id          skip
                "item-condition"     buf_temp-menu-item.item-condition     skip
                "item-context"       buf_temp-menu-item.item-context       skip
                "item-configuration" buf_temp-menu-item.item-configuration skip
                "item-group-id"      buf_temp-menu-item.item-group-id      skip
                "item-encoded"       buf_temp-menu-item.item-encoded       skip
                view-as alert-box error .
              assign
                v-error-exist = true
              .
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестный тип пункта меню" buf_temp-menu-item.item-type skip
            "item-code"          buf_temp-menu-item.item-code          skip
            "item-type"          buf_temp-menu-item.item-type          skip
            "item-name"          buf_temp-menu-item.item-name          skip
            "item-procedure"     buf_temp-menu-item.item-procedure     skip
            "item-id"            buf_temp-menu-item.item-id            skip
            "parent-id"          buf_temp-menu-item.parent-id          skip
            "item-condition"     buf_temp-menu-item.item-condition     skip
            "item-context"       buf_temp-menu-item.item-context       skip
            "item-configuration" buf_temp-menu-item.item-configuration skip
            "item-group-id"      buf_temp-menu-item.item-group-id      skip
            "item-encoded"       buf_temp-menu-item.item-encoded       skip
            view-as alert-box error .
          assign
            v-error-exist = true
          .
        end.
      end case .
    end.

    if v-error-exist = true
    then do:
      undo, return error .
    end.
  end.

end procedure. /* validate-menu-item */


procedure update-user-menu-group :

  define buffer buf_user-menu-group for ub.user-menu-group .
  define buffer buf_menu-group      for ub.menu-group .

  do
  on error undo, return error return-value
  :
    for each buf_user-menu-group exclusive-lock
      where buf_user-menu-group.db-num = p-db-num
    on error undo, return error return-value
    :
      find first buf_menu-group no-lock
        where buf_menu-group.menu-code     = buf_user-menu-group.menu-code
          and buf_menu-group.menu-group-id = buf_user-menu-group.menu-group-id
        no-error .
      if available buf_menu-group
      then do:
        assign
          buf_user-menu-group.menu-group-code = buf_menu-group.menu-group-code
        .
      end.
      else do:
        assign
          buf_user-menu-group.menu-group-code = 0
        .
      end.
    end.
  end.

end procedure. /* update-user-menu-group */

procedure update-action-post-menu-group :

  define buffer buf_action-post-menu-group for ub.action-post-menu-group .
  define buffer buf_menu-group      for ub.menu-group .

  do
  on error undo, return error return-value
  :
  /*
    for each buf_action-post-menu-group exclusive-lock
      where buf_action-post-menu-group.db-num = p-db-num
    on error undo, return error return-value
    :
      find first buf_menu-group no-lock
        where buf_menu-group.menu-code     = buf_action-post-menu-group.menu-code
          and buf_menu-group.menu-group-id = buf_action-post-menu-group.menu-group-id
        no-error .
      if available buf_menu-group
      then do:
        assign
          buf_action-post-menu-group.menu-group-code = buf_menu-group.menu-group-code
        .
      end.
      else do:
        assign
          buf_action-post-menu-group.menu-group-code = 0
        .
      end.
    end.
    */
  end.

end procedure. /* update-action-post-menu-group */