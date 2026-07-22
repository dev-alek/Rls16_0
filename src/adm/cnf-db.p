block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnf-db.p $
$Archive: adm/cnf-db.p $

Процедуры работы с таблицей конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U.
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo init "$Workfile: cnf-db.p $":U.
define variable vss-archive     as character no-undo init "$Archive: adm/cnf-db.p $":U.
define variable vss-description as character no-undo init "Процедуры работы с таблицей конфигурации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/cnf-inc.i  }
{ adm/cfg-pr.i   }
{ gbl/conf-enc.i }

define variable str-hdl as handle  no-undo . /* указатель на процедурц работы с настройкой */
define variable cnf-hdl as handle  no-undo . /* указатель на процедурц работы с настройкой */

procedure init :

  define input parameter  par-str-hdl as handle.

  do
  on error undo, return error return-value
  :
    if valid-handle (par-str-hdl)
    then do:
      assign
        str-hdl = par-str-hdl
      .
    end.
    else do:
      return "2" .    /* невозможно запротоколировать ошибку, так как не ясно - куда */
    end.
    return.
  end.

end procedure. /* init */

procedure kill :

  /* Завершение работы с текущей конфигурации */

  do
  on error undo, return error return-value
  :
    delete procedure this-procedure.
    return.
  end.

end procedure. /* kill */

procedure loaddb :
  /* Загрузка конфигурации из базы данных */

  do
  on error undo, return error return-value
  :
    define buffer buf_db       for ub.db .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define variable v-ok      as logical   no-undo .
    define variable MaxErr    as integer   no-undo .
    define variable v-db-list as character no-undo .

    if not valid-handle (cnf-hdl)
    then do:
      run find-library in this-procedure no-error.
      if not valid-handle (cnf-hdl)
      then do:
          run log-error in str-hdl ("Ошибка при загрузки в памяти библиотек", 2) no-error.
          return ("2") .
      end.
    end.
    read-cycle:
    do on error undo, leave read-cycle:                 /* на случай возникновения неотлавливаемых кодом ошибок */
      find first buf_sys-ctrl no-lock .
      /*  читаем */
      for each ub.config no-lock
      on error undo, leave read-cycle
      :
        find first buf_db no-lock
          where buf_db.db-num = ub.config.db-num
          .
        if ub.config.db-num = buf_sys-ctrl.db-num then do:
          assign
            MaxErr = 2
          .
        end.
        else do:
          assign
            MaxErr = 1
          .
        end.

        create cnf .

      /* сразу проверяем кодированность */
        if lookup( ub.config.conf-type, {&cnf-type-list-protect} ) > 0
        then do:
          run check-enc in this-procedure
            ( input ub.config.db-num
             ,input buf_db.db-key
             ,input ub.config.param-code
             ,input ub.config.param-value
             ,input ub.config.beg-date
             ,input ub.config.end-date
             ,input ub.config.param-encoded
             ,output v-ok
            ) no-error.
          {&log-err}
          if v-ok <> true
          then do:
            assign
              cnf.errorexist = MaxErr
            .

            run log-error in str-hdl
              ( input substitute("Параметр &1 для БД &2 - ошибка кодирования (&3)", ub.config.param-code, ub.config.db-num, ub.config.param-encoded )
               ,input MaxErr
              ).
          end.
        end.
        if ub.config.beg-date = ?
        or ub.config.end-date = ?
        then do:
          assign
            cnf.errorexist = MaxErr
          .
          run log-error in str-hdl
            ( input substitute("Параметр &1 для БД &2 - не задана дата действия параметра", ub.config.param-code, ub.config.db-num )
              ,input MaxErr
            ).
        end.

        buffer-copy ub.config to cnf
          assign
            cnf.db-key = buf_db.db-key
          no-error
        .
        {&log-err}
        release cnf no-error.
        {&log-err}
      end.

      /*  проверка не может быть совмещена с чтением, так как необходимо гарантировать
          наличие в считанных параметрах корневых значений иерархических параметров */

      for each cnf
      on error undo, leave read-cycle
      :
        run chk-param in cnf-hdl
          ( buffer cnf
          ) no-error.
        &scop err-mess "Ошибка вызова процедуры"
        {&log-err}
      end.

      /* добавляем отсутствующее */
      run chk-unref in cnf-hdl
        ( input ?
        , input ?
        , input {&cnf-type-list-mandatory}
        , input false
        ) no-error.
      &scop err-mess "Ошибка вызова процедуры"
      {&log-err}

      return if err-level > 0 then string (err-level) else "".
    end.

    /* обработка ранее не обработанных ошибок */
    run log-sys-error in str-hdl ("При загрузке параметров возникла непредвиденная ошибка").
    return string (err-level).

  end.

end procedure. /* loaddb */


procedure chk-company :

  define input  parameter par-host-code like ub.sysconf.host-code no-undo.

  /* проверить код фирмы по списку фирм */

  define buffer buf_sysconf for ub.sysconf .

  do
  on error undo, return error return-value
  :
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = par-host-code
      no-error .
    if available buf_sysconf
    then do:
      return.
    end.
    else do:
      return "1".
    end.
  end.

end procedure. /* chk-company */


procedure chk-host-code :

  define input  parameter obj-obj-type  as character no-undo .
  define input  parameter obj-obj-code  as integer   no-undo .
  define output parameter obj-host-code as integer   no-undo .

  /* определить код фирмы по коду объекта */

  do
  on error undo, return error return-value
  :
    assign
      obj-host-code = ?
    .

    if obj-obj-type = ""
    or obj-obj-code = 0
    then do:
      return.
    end.

    case obj-obj-type
    :
        when {&stock}
        then do:
              find first ub.store where ub.store.obj-code = obj-obj-code no-lock no-error.
              if available ub.store then
                assign obj-host-code = ub.store.host-code.
              else
                run log-error in str-hdl ("Не допустимый код магазина " + string(obj-obj-code), 1).
        end.
        when {&shop}
        then do:
              find first ub.shop where ub.shop.obj-code = obj-obj-code no-lock no-error.
              if available ub.shop then
                assign obj-host-code = ub.shop.host-code.
              else
                run log-error in str-hdl ("Не допустимый код склада " + string(obj-obj-code), 1).
        end.
        otherwise do:
              run log-error in str-hdl (" Недопустимый тип объекта привязки - " + obj-obj-type, 1).
        end.
    end.
    return.
  end.

end procedure. /* chk-host-code */


procedure chk-cfg :

  define input-output parameter par-chg-encode as logical           no-undo. /* Допускается изменение кодированных параметров */

  /* Проверить наличие ошибок в текущих значениях параметров */

  define variable authorise as logical initial "false" no-undo . /* требуется авторизация изменений */

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_cnf      for cnf .

  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .

    for each cnf no-lock
      where cnf.NotUsed
     ,first cnf-struct no-lock
        where cnf-struct.param-code = cnf.param-code
    on error undo, return error return-value
    :
      if lookup( cnf.conf-type, {&cnf-type-list-mandatory} ) + lookup( cnf-struct.param-type, {&cnf-type-list-mandatory} ) <> 0
      then do:
        if cnf.db-num = buf_sys-ctrl.db-num
        then do:
          run log-error in str-hdl
            ( input substitute( "Отсутствует обязательный параметр &1 для текущей БД", cnf.param-code )
             ,input 2
            ).
        end.
        else do:
          run log-error in str-hdl
            ( input substitute( "Отсутствует обязательный параметр &1 для БД &2", cnf.param-code, cnf.db-num )
             ,input 1
            ).
        end.

      end.
    end.

    /* проверяем наличие ошибок */
    assign
      err-level = 0
    .

    find first buf_cnf
      where buf_cnf.ErrorExist >= 2
        and buf_cnf.db-num = buf_sys-ctrl.db-num
        and ( buf_cnf.NotUsed = false
              or buf_cnf.conf-type <> ""
            )
      no-error .
    if available buf_cnf then do:
      run log-error in str-hdl
        ( input "В параметрах для текущей БД есть ошибки, подлежащие исправлению"
         ,input 2
        ).
    end.

    find first buf_cnf
      where buf_cnf.ErrorExist >= 2
        and buf_cnf.db-num <> buf_sys-ctrl.db-num
        and ( buf_cnf.NotUsed = false
              or buf_cnf.conf-type <> ""
            )
      no-error .
    if available buf_cnf then do:
      run log-error in str-hdl
        ( input substitute( "В параметрах для БД &1 есть ошибки, подлежащие исправлению", buf_cnf.db-num )
         ,input 1
        ).
    end.

    if err-level > 2 then do:
      return.
    end.

    /* проверяем изменение ключевых параметров */
    &scop buf1 ub.config.
    &scop buf2 = cnf.
    &scop link-word and
    for each ub.config
      where lookup( ub.config.conf-type, {&cnf-type-list-protect} ) > 0
/*        and ub.config.db-num =*/
    on error undo, return error
    :
        find first cnf where {&Fields} no-error.
        if not available cnf
        then do:
          run log-error in str-hdl ("В наборе параметров удален кодированный параметр " +
                                    ub.config.param-code, 0).
          Authorise = true.
          next.
        end.
        if cnf.param-value <> ub.config.param-value
        then do:
          run log-error in str-hdl ("Изменен кодированный параметр " + ub.config.param-code  + " на "  +
                                    cnf.param-value  + " с " + ub.config.param-value, 0).
          Authorise = true.
          next.
        end.
    end.

    /* а теперь в обратную сторону - нет ли чего лишнего */
    for each cnf
      where lookup( ub.config.conf-type, {&cnf-type-list-protect} ) > 0
        and cnf.notused = false
    on error undo, return error
    :
        find first ub.config where {&Fields} no-lock no-error.
        if not available ub.config
        then do:
          run log-error in str-hdl ("В новом наборе параметров есть новый кодированный параметр " +
                                    cnf.param-code, 0).
          Authorise = true.
          next.
        end.
    end.
    if authorise and not par-chg-encode
    then do:
      run gbl/authoriz.p (input "Run information dialog",output par-chg-encode ) no-error.
      {&log-err}
      if not par-chg-encode then
          run log-error in str-hdl ("Изменение кодированных параметров запрещено", 2).
    end.

  end.

end procedure. /* chk-cfg */

procedure save-cfg :

  define input  parameter par-chg-encode as logical          no-undo. /* Допускается изменение кодированных параметров */

  /* Сохранить текущие настройки */

  do
  on error undo, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

  /*define variable p-encoded like ub.config.param-encoded no-undo .*/
  define buffer b-config for ub.config.

  /* проверяем наличие ошибок */
  assign
    err-level = 0
  .
  /* если можно менять конфигурационные параметры, то отключим триггера */
  /*if par-chg-encode then*/
  /*      disable triggers for load of ub.config.*/

  run chk-cfg in this-procedure
    (input-output par-chg-encode
    ) no-error.
  {&log-err}

  if err-level > 1 then do:
    return string (err-level) .
  end.

  run adm/cnf-chk.p no-error .
  if error-status :error then do:
    run log-error in str-hdl
      ( input substitute( "Текущий набор невозможно сохранить&1&2&1&3", {&new-line}, return-value, error-status :get-message ( 1 ) )
       ,input 2
      ).
    return "2".
  end.

/* в одной транзакции удаляем старые параметры и прописываем новые
   во избежание ситуации, когда часть сохраненных параметров соответствует
   одной конфигурации настройки, а часть - другой
*/

  tran-write:
  do transaction
  on error undo tran-write, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    /* сначала записываем все, что хотим использовать */
    for each cnf
      where cnf.NotUsed = false
    on error undo tran-write, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      find first ub.config exclusive-lock
        where {&Fields} no-error.
      if not available ub.config
      then do:
        if locked ub.config
        then do:
            run log-error in str-hdl ("Запись текущего набора локирована, попробуйте записать позже", 2).
            undo Tran-Write, return string(err-level).
        end.
        else do:
          create ub.config no-error.
        end.
        {&log-err}
      end.

      buffer-copy cnf to ub.config
        assign
          ub.config.stts = 0
      .
    end.

    /* теперь удалим все неиспользуемое */
    for each ub.config no-lock
    on error undo tran-write, return "2"
    :
      if can-find (first cnf where {&fields} and not cnf.NotUsed) then next.
      find first b-config where ReciD(b-config) = recid(ub.config) exclusive-lock no-error.
      if not available b-config
      then do:
        if locked b-config then
            run log-error in str-hdl ("Запись текущего набора локирована, попробуйте записать позже", 2).
        else if error-status:error then
            run log-sys-error in str-hdl ("Запись текущего набора недоступна").
        if err-level > 0
        then do:
          undo Tran-Write, return string(err-level).
        end.
      end.
      else do:
        if par-chg-encode
        then do:
          assign
            b-config.stts = -1
          .
        end.
        delete b-config .
      end.
    end.

    /* уж если сюда добрались, то все тип-топ */
    return "".
  end.

  end.

end procedure. /* save-cfg */


procedure find-library :

  /* Найти в памяти необходимую библиотеку процедур */

  do
  on error undo, return error return-value
  :
    if valid-handle(cnf-hdl) then return.

    assign
      cnf-hdl = session :first-procedure
    .
    do while valid-handle (cnf-hdl)
    :
      if cnf-hdl:private-data = "Work-with-config"
      then do:
        leave.
      end.
      assign
        cnf-hdl = cnf-hdl :next-sibling
      .
    end.
    /* если не нашли, то по завершении цикла недопустимое значение ссылки */

  end.

end procedure. /* find-library */