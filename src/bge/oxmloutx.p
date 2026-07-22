block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт в файл OpenXML

Автор: Хныкин Павел Андреевич
Дата создания: 08/16/06
Author: Pavel Khnykin
Creation date: 08/16/06

Input:
    parparentproc     - handle главного окна
    p-parent-handle       - handle вызывающей процедуры
    p-log-handle          - handle для записи лога (в handl-е должна быть поцедура write-log)
    p-parameter-string    - Строка параметров, через запятую. Первый параметр должен быть номером БД.

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle      as widget-handle    no-undo.
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-parameter-string   as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт в файл OpenXML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/xmlchar.i  }
{ str/xmllib.i   }
{ gbl/filelist.i }
{ bge/oxml-def.i }
{ gbl/db-attr.i  }
{ bge/esysattr.i } // ext-system-attr-value для проверки сертификатов

define stream out-stream.
define variable v-action as character no-undo .
define variable v-ver-num as character no-undo .
define variable v-err-msg as character no-undo .

define temp-table t-list-pack no-undo
field pack-num    like ub.esys-pck-sent.esps-pack-num
field re-gen-time as   logical                 initial false
field SendTxtDate like ub.esys-pck-sent.esps-SendTxtDate initial ?
index pi is unique primary pack-num ascending
index iregen re-gen-time SendTxtDate
.

define temp-table temp_esys-route no-undo
    field tesr-key  as int64
    field esys-id           as integer
    field db-num            as integer
    field esr-cr-db-num     as integer
    field esr-last-pack     as integer
    field esr-tbl-ord       as int64

    index pi is primary unique
        tesr-key
.

    define variable v-cur-db-num        as integer      no-undo.
    define variable v-tesr-key          as integer      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-time-wait         as integer      no-undo.
    define variable v-success           as logical      no-undo.
    define variable v-esys-id           as integer      no-undo.
    define variable v-esys-db-num       as integer      no-undo.
    define variable v-esps-cr-db-num    as integer      no-undo.
    define variable v-esps-pack-num     as integer      no-undo .
    define variable v-esps-pack-name    as character no-undo .
    define variable v-pack-file-name    as character no-undo .
    define variable v-custom-pack-name  as character no-undo .
    define variable v-custom-pack-flag  as logical   no-undo .
    define variable v-source-dir        as character no-undo .
    define variable v-target-dir        as character no-undo .
    define variable v-temp-dir          as character no-undo .
    define variable v-log-file-name     as character    no-undo.
    define variable v-list-file-name    as character    no-undo.
    define variable v-err-gen-pack      as integer   no-undo . /* 0 - нет ошибок */
    define variable v-ind               as integer   no-undo .
    define variable v-max-p-queue       as integer   no-undo .
    define variable v-max-p-time        as integer   no-undo .

define variable v-attr-type        as character no-undo . // для чтения значений из ext-system-attr
define variable v-cert-enstr       as character no-undo . // чтение v-cert-enabled строкой
define variable v-cert-enabled     as logical no-undo . // true - добавить цифровую подпись
define variable v-cert-subj-name   as character no-undo . // поле SubjectName (моё имя) в сертификате
define variable v-cert-issuer-name as character no-undo . // поле IssuerName (кем выдан) в сертификате
define variable v-sign-fileext     as character no-undo . // расширение файла с электронной подписью
define variable v-cert-repository  as integer no-undo .

    define buffer buf_ext-system         for ub.ext-system.
    define buffer buf_esys-pck-sent      for ub.esys-pck-sent.
    define buffer buf_temp_esys-route for temp_esys-route.
    define buffer buf_esys-route for ub.esys-route.

    define temp-table tt_esys-route no-undo like ub.esys-route.

    define stream 1c-log .

do
for buf_ext-system
on error undo, return error
:

  assign
      v-action =  entry( 1, p-parameter-string )
      v-cur-db-num = integer( entry( 2, p-parameter-string ) )
      no-error
  .
  if error-status:error then do:
      assign
      add-log-file-name = ?
      .
      message vss-workfile vss-revision vss-description skip
              substitute( "Неверная структура составного параметра p-parameter-string = &1", p-parameter-string )
              view-as alert-box error.
      return error.

  end.
  case v-action:
    when "all" then do:
    end.
    when "one-esys" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      no-error .
    end.
    when "all-unconf" then do:
      assign
      v-esys-id = 0
      v-esys-db-num  = 0
      v-esps-cr-db-num = -1
      v-esps-pack-num  = -1
      no-error
      .
    end.
    when "one-esys-unconf" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      v-esps-cr-db-num = -1
      v-esps-pack-num  = -1
      no-error
      .
    end.
    when "one-pack" then do:
      assign
      v-esys-id = integer( entry( 3, p-parameter-string ) )
      v-esys-db-num  = integer( entry( 4, p-parameter-string ) )
      v-esps-cr-db-num = integer( entry( 5, p-parameter-string ) )
      v-esps-pack-num  = integer( entry( 6, p-parameter-string ) )
      no-error
      .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Не предусмотрена операция &1", v-action )
              view-as alert-box error.
      return error.
    end.
  end.
  if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Неверная структура составного параметра p-parameter-string = &1", p-parameter-string )
              view-as alert-box error.
      return error.
  end.

   run get-version-num in parparentproc
    ( output v-ver-num
    ).
  run write-log in p-log-handle (
        input 1
      , input substitute( "Выгрузка данных по внешним системам..." )
  ).

  start-export:
  for each buf_ext-system no-lock
      where (buf_ext-system.esys-have-export = yes
        and buf_ext-system.esys-db-num-exp = v-cur-db-num
        and (v-esys-id = 0
              or
              (buf_ext-system.esys-id = v-esys-id
              and
              buf_ext-system.db-num = v-esys-db-num)
            )
           )

        or
       (buf_ext-system.esys-have-import = yes
        and buf_ext-system.imp-conf-send = integer({&openxml-imp-conf-send})
        and buf_ext-system.esys-db-num-imp = v-cur-db-num
        and (v-esys-id = 0
              or
              (buf_ext-system.esys-id = v-esys-id
              and
              buf_ext-system.db-num = v-esys-db-num)
            )
           )


  by buf_ext-system.esys-id
  on error undo, return error
  :
    assign
    add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", buf_ext-system.esys-id )
    .
    case v-action:
      when "all"
      or
      when "one-esys"
      then do:
        run write-log in p-log-handle (
              input 2
            , input substitute( "Выгрузка данных по внешней системе '&1'...", buf_ext-system.esys-name )
        ).
      end.
      when "one-pack":U then do:
        find first buf_esys-pck-sent no-lock
          where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
            and buf_esys-pck-sent.db-num = buf_ext-system.db-num
            and buf_esys-pck-sent.esps-pack-num = v-esps-pack-num
          no-error
        .
        if buf_esys-pck-sent.esps-rcvd = no or
           can-find(first buf_esys-route no-lock where
                          buf_esys-route.esys-id = buf_esys-pck-sent.esys-id
                      and buf_esys-route.db-num = buf_esys-pck-sent.db-num
                      and buf_esys-route.esr-cr-db-num = g#db-num
                      and Buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
                   )
        then do:
          run write-log in p-log-handle (
                input 2
               ,input substitute("Отправка одного пакета данных в ВС &1 пакет номер &2", buf_ext-system.esys-name, v-esps-pack-num )
          ).
        end.
        else do:
          run write-log in p-log-handle (
                input 2
               ,input substitute("Отправить пакет N &1 для ВС N &2 нельзя. Получено подтверждение о его приеме и данные удалены. Дата и время подтверждения: &3 &4.", v-esps-pack-num, buf_ext-system.esys-id, buf_esys-pck-sent.esps-rcvdDate, buf_esys-pck-sent.esps-rcvdTime )
          ).
          return.
        end.
      end.
      when "one-esys-unconf":U
      or
      when "all-unconf"
      then do:
        run write-log in p-log-handle (
              input 2
            ,input substitute("Отправка всех неподтвержденных пакетов данных в ВС &1", buf_ext-system.esys-name )
        ).
      end.
      otherwise do:
        message vss-workfile vss-revision vss-description skip
                substitute( "Не предусмотрена операция &1", v-action )
                view-as alert-box error.
        return error.
      end.
    end case.
    
    /* 29/VIII-2018  параметры настройки ЭЦП перенесены из ini-файла в настройки внешней системы */
    run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign}
                                     ,output v-cert-enstr
                                     ,output v-attr-type) no-error .
    if not error-status:error then v-cert-enabled = logical (v-cert-enstr) no-error .
    if error-status:error then do:
      run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4&2&5"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,substitute( "Параметр &1", {&attr-esys-cert-sign} ) 
                                                  ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                  ,substitute( "&1", return-value )
                                                  )
                        ) .
      return error.
    end.
    if v-cert-enabled then do :
      run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-issuer}
                                     ,output v-cert-issuer-name
                                     ,output v-attr-type) no-error .
      if not error-status:error then
      run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-sign-subject}
                                     ,output v-cert-subj-name
                                     ,output v-attr-type) no-error .
      if not error-status:error then
      run ext-system-attr-value in this-procedure (
                                      input  buf_ext-system.esys-id
                                     ,input  buf_ext-system.db-num
                                     ,input  {&attr-esys-cert-file-ext}
                                     ,output v-sign-fileext
                                     ,output v-attr-type) no-error .
      if error-status:error then do:
        run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3&2&4"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                  ,substitute( "&1", return-value )
                                                  )
                        ) .
        return error.
      end.
      v-cert-repository = ? .
      run ext-system-attr-value in this-procedure (
                                input  buf_ext-system.esys-id
                               ,input  buf_ext-system.db-num
                               ,input  {&attr-esys-cert-repository}
                               ,output v-cert-enstr
                               ,output v-attr-type) no-error .
      if v-cert-enstr > ""
      then
        v-cert-repository = integer(v-cert-enstr) no-error .    
      if v-cert-repository = ?
      then
        v-cert-repository = 0 .
      if v-cert-subj-name > "" then . else do :
        run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,"Отсутствует имя Владельца сертификата (~"Субъект~") в параметрах настройки внешней системы"
                                                  )
                        ) .
        return error.
      end .
      if v-cert-issuer-name > "" then . else do :
        run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка чтения настроек ВС.&2&3"
                                                  ,vss-workfile
                                                  ,{&new-line}
                                                  ,"Отсутствует имя Издателя сертификата в параметрах настройки внешней системы"
                                                  )
                        ) .
        return error.
      end .
    end .
    else assign
      v-cert-issuer-name = ""
      v-cert-subj-name   = ""
      v-sign-fileext     = ""
    .
    
    empty temp-table temp_esys-route .
    assign
    v-success = no
    g#esys-source-esys = -1
    .
    run bge/lockesys.p (
        input buf_ext-system.esys-id
      ,input buf_ext-system.db-num
      ,buffer buf_ext-system
      ,output v-success) no-error.
    if error-status:error
    or v-success = no
    then do:
        run write-log in p-log-handle (
              input 2
            , input return-value
        ).
        undo start-export, next start-export.
    end.
    /*начало блока обычной выгрузки*/

    assign
      v-max-p-queue = (if buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-wait})
                       then buf_ext-system.max-p-queue
                       else 1000)
      v-max-p-time  = buf_ext-system.max-p-time
      v-err-gen-pack = 0
    .
    for each t-list-pack
    on error undo, return error
    :
      delete t-list-pack .
    end.

    if v-action = "one-pack":U then do:
      create t-list-pack .
      assign
        t-list-pack.pack-num = v-esps-pack-num
      .
    end.
    else do:
      run cur-time( output v-today
                    ,output v-time
                  ) no-error .
      if error-status :error then do:
        run write-log in p-log-handle(
                          input 2
                          ,input substitute("&1 Ошибка при определении текущего времени"
                                            ,vss-workfile )
                        ) .
        return error.
      end.

      assign
        v-time-wait    = -1
      .
      /*времянка, где хранится список роутов для обрабатываемой ВС*/
      for each tt_esys-route exclusive-lock:
          delete tt_esys-route.
      end.
      /*заполним ее*/
      for each buf_esys-route no-lock
        where buf_esys-route.esys-id       = buf_ext-system.esys-id
              and buf_esys-route.db-num = buf_ext-system.db-num
             /* and buf_esys-route.esr-cr-db-num = v-cur-db-num */
      :
          create tt_esys-route.
          buffer-copy buf_esys-route to tt_esys-route.
      end.
      /* посчитаем и составим список отправленных, но неподтвержденных пакетов */
      _buf_esys-pck-sent:
      for each buf_esys-pck-sent no-lock
        where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
          and buf_esys-pck-sent.db-num = buf_ext-system.db-num
          and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
      on error undo, leave
      :

        if buf_esys-pck-sent.esps-rcvd = yes then next _buf_esys-pck-sent.   

        find first t-list-pack no-lock
          where t-list-pack.pack-num = buf_esys-pck-sent.esps-pack-num
          no-error
        .
        if not available t-list-pack then do:
          create t-list-pack .
          assign
            t-list-pack.pack-num    = buf_esys-pck-sent.esps-pack-num
            t-list-pack.SendTxtDate = buf_esys-pck-sent.esps-SendTxtDate
            v-ind = v-ind + 1
          .
        end.


        if v-max-p-time <> 0
          and
          buf_esys-pck-sent.esps-SendTxtDate <> ?
          and buf_esys-pck-sent.esps-SendTxtTimeInt <> 0
          and ( buf_esys-pck-sent.esps-SendTxtDate < v-today
                or ( buf_esys-pck-sent.esps-SendTxtDate = v-today
                    and buf_esys-pck-sent.esps-SendTxtTimeInt <= v-time
                  )
              )
        then do:
          assign
            v-time-wait = ( v-today - buf_esys-pck-sent.esps-SendTxtDate ) * 24 * 60 * 60
                          + ( v-time - buf_esys-pck-sent.esps-SendTxtTimeInt )
          .
        end.

        if v-time-wait >= v-max-p-time * 60 then do:
          assign
            t-list-pack.re-gen-time = true
          .
        end.

        if buf_ext-system.esys-num-days-keep-exp > 0
        and (v-today - buf_esys-pck-sent.esps-Credate) > buf_ext-system.esys-num-days-keep-exp
        and buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-no-wait})
        then do:
          /*удалить руты*/
          run delete-old-pck in this-procedure ( buffer buf_esys-pck-sent
                                                ,input buf_esys-pck-sent.esys-id
                                                ,input buf_esys-pck-sent.db-num
                                                ,input buf_esys-pck-sent.esps-cr-db-num
                                                ,input buf_esys-pck-sent.esps-pack-num
                                                ,input buf_ext-system.esys-name
                                                ) no-error.
          delete t-list-pack.
        end.
      end.
      if buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-wait})
      and buf_ext-system.esys-num-days-keep-exp > 0
      then do:
        /*найдем самый ранний route*/
        find first buf_esys-route no-lock where
                  buf_esys-route.esys-id = buf_ext-system.esys-id
              and buf_esys-route.db-num = buf_ext-system.db-num
/*              and buf_esys-route.esr-cr-db-num = v-cur-db-num*/
              and buf_esys-route.esr-last-pack > 0
              no-error.
        if available buf_esys-route then do:
          for each buf_esys-pck-sent no-lock
            where buf_esys-pck-sent.esys-id = buf_ext-system.esys-id
              and buf_esys-pck-sent.db-num = buf_ext-system.db-num
              and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
              and buf_esys-pck-sent.esps-pack-num >= buf_esys-route.esr-last-pack
              and buf_esys-pck-sent.esps-rcvd = yes:
            if (v-today - buf_esys-pck-sent.esps-Credate) > buf_ext-system.esys-num-days-keep-exp
            /*todo and buf_ext-system.exp-conf-wait = no*/
            then do:
              /*удалить руты*/
              run delete-old-pck in this-procedure ( buffer buf_esys-pck-sent
                                                    ,input buf_esys-pck-sent.esys-id
                                                    ,input buf_esys-pck-sent.db-num
                                                    ,input buf_esys-pck-sent.esps-cr-db-num
                                                    ,input buf_esys-pck-sent.esps-pack-num
                                                    ,input buf_ext-system.esys-name
                                                    ) no-error.
            end.
          end. /*for each buf_esys-pck-sent no-lock*/
        end. /*if available buf_esys-route then do:*/
      end. /*if buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-wait})*/
      if v-action = "all":U
      or v-action = "one-esys"
        and v-ind < v-max-p-queue
      then do:
        /* если неподтвержденных пакетов меньше чем задано в настройках, то и не будем их переформировывать */
        for each t-list-pack
          where t-list-pack.re-gen-time = false
            and t-list-pack.SendTxtDate <> ?
        on error undo, return error
        :
          delete t-list-pack .
        end.
      end.
    end.
    
    output stream 1c-log to value ("1c-tech.log") append.
    gen-pack:
    for each t-list-pack
      by t-list-pack.pack-num
    on error undo, return error
    :
      assign
        v-esps-pack-num = t-list-pack.pack-num
      .
      delete t-list-pack .
      v-custom-pack-name = ?.
      run bge/espcknum.p ( input "put":U
                    ,input buf_ext-system.esys-id
                    ,input buf_ext-system.db-num
                    ,input buf_ext-system.delivery-method
                    ,input oxml-exch-dir
                    ,input oxml-heap-dir
                    ,input ""
                    ,input-output v-esps-pack-num
                    ,input-output v-custom-pack-name
                    ,output v-esps-pack-name
                    ,output v-source-dir
                    ,output v-target-dir
                    ,output v-temp-dir
                    ,output v-log-file-name
                    ,output v-list-file-name
                    ,output v-custom-pack-flag
                  ) no-error.
      if error-status:error then do:
        run write-log in p-log-handle (
                                        input 2
                                      , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                    ,vss-workfile
                                                    ,{&new-line}
                                                  ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                  ,substitute( "&1", return-value )
                                                  )
                        ) .
        return error.
      end.

      if buf_ext-system.esys-have-export = yes
     and buf_ext-system.esys-db-num-exp = v-cur-db-num then do :
        v-pack-file-name = substitute("&1&2&3", v-source-dir, {&back-slash-char}, v-esps-pack-name) .
        run start-exp-pack in this-procedure  (
                      buffer buf_ext-system
                    ,input v-esps-pack-num
                    ,input (  v-pack-file-name  +  (if v-custom-pack-flag then '' else 'xml')  )
                    ,input v-cert-enabled
                    ,input v-cert-subj-name
                    ,input v-cert-issuer-name
                    ,input v-sign-fileext
                    ,input v-cert-repository
                    ,output v-err-gen-pack
                  ) no-error.
        if error-status:error then do:
          run write-log in p-log-handle (
                                        input 2
                                        , substitute("&1 Ошибка при формировании пакета.&2&3&2&4"
                                                    ,vss-workfile
                                                    ,{&new-line}
                                                    ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                                    , substitute( "&1", return-value ))
                        ) .
          leave gen-pack.
        end.
      end .
      if v-err-gen-pack <> 2 then do:
        run bge/sxg-pack.p (
                       input parparentproc
                      ,input this-procedure:handle /*p-parent-handle*/ /*место определения write-to-lo и write-to-screen*/
                      ,input p-log-handle /*место определения write-log-and-file*/
                      ,input "put":U
                      ,input true
                      ,input (v-esps-pack-name + (if v-custom-pack-flag then '' else "xml"))
                      ,input v-source-dir
                      ,input v-target-dir
                      ,input v-temp-dir
                      ,input v-esps-pack-num
                      ,input buf_ext-system.esys-id
                      ,input buf_ext-system.db-num
                      ,input v-cur-db-num
                      ,input buf_ext-system.delivery-method /*p-delivery-method*/

                      ) no-error.
        if error-status:error then do:
          run write-log in p-log-handle (
                                          input 2
                                        , substitute("&1 &2"
                                                      ,vss-workfile
                                                      , return-value )
                          ).
          leave gen-pack.
        end.
      end.
      if v-err-gen-pack <> 0 then do:
        leave gen-pack.
      end.
    end. /*for each t-list-pack*/
    
    output stream 1c-log close.

    for each t-list-pack
    on error undo, return error
    :
      delete t-list-pack .
    end.

    run gbl/del-file.p ( input v-temp-dir ) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 2
                                    , substitute("&1 &2"
                                                  ,vss-workfile
                                                  , return-value )
                      ).
    end.
    case v-action:
      when "one-pack":U then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка одного пакета данных в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
      when "one-esys-unconf":U
      or
      when "all-unconf"
      then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка всех неподтвержденных пакетов данных в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
      when "all":U
      or
      when "one-esys"
      then do:
        run write-log in p-log-handle ( input 2
                                        ,input substitute("Завершена отправка новостей в ВС &1", buf_Ext-system.esys-name ) ) .
      end.
    end case.
    run bge/rem-xpck.p
      ( input buf_Ext-system.esys-id
       ,input buf_Ext-system.db-num
      ) no-error.
    if error-status:error then do:
      run write-log in p-log-handle (
                                     input 2
                                    ,input (substitute( "&1. ERROR!!! Ошибка при удалении файлов OXML по ВС &2&3&4&5&6"
                                    ,vss-workfile
                                    ,buf_ext-system.esys-id
                                    ,{&new-line}
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                              ))
                      ) .
    end.
    assign
    add-log-file-name = ?
    .
  end.        /* for each buf_ext-system */
  run write-log in p-log-handle (
        input 1
      , input "Выгрузка данных по внешним системам завершена."
  ).
end.


/*==========================================================================*/
procedure expand-dump-and-export :
define input parameter p-action             as character        no-undo.
define input parameter p-unique-key         as character        no-undo.
define input parameter p-esrd-dump-name     as character        no-undo.
define input parameter p-value-rec-handle   as handle           no-undo.

    define variable v-temp-table-handle     as handle       no-undo.
    define variable v-temp-table-name       as character    no-undo.
    define variable v-buf-temp-table-handle as handle       no-undo.
    define variable v-ok                    as logical      no-undo.
do
on error undo, return error
:
    create temp-table v-temp-table-handle.
    assign
        v-temp-table-name   = "temp_":U + p-esrd-dump-name
    .
    assign
        v-ok                = v-temp-table-handle :create-like( "ub.":U + p-esrd-dump-name )
    no-error.
    if v-ok <> yes
    then do:
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-workfile, v-temp-table-name ) .
    end.
    assign
        v-ok = v-temp-table-handle :temp-table-prepare( v-temp-table-name )
    no-error.
    if v-ok <> yes
    then do:
        undo, return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-workfile, v-temp-table-name ) .
    end.
    assign
        v-buf-temp-table-handle = v-temp-table-handle :default-buffer-handle
    .
    assign
        v-ok = v-buf-temp-table-handle :buffer-create
    no-error.
    if v-ok <> true
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-workfile, v-temp-table-name ).
    end.
    assign
        v-ok = v-buf-temp-table-handle :raw-transfer ( no, p-value-rec-handle )
    no-error.
    if v-ok <> true
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        undo, return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2", vss-workfile, v-temp-table-name ).
    end.
/*    message*/
/*        "X"*/
/*        skip v-buf-temp-table-handle :name*/
/*        skip v-buf-temp-table-handle :buffer-field( 1 ) :name*/
/*        skip v-buf-temp-table-handle :buffer-field( 1 ) :buffer-value*/
/*    view-as alert-box information.*/
    run exp-pack in this-procedure (
          input p-action
        , input p-unique-key
        , input v-buf-temp-table-handle
        , input p-esrd-dump-name
    ) no-error.
    if error-status :error
    then do:
        delete object v-buf-temp-table-handle.
        delete object v-temp-table-handle.
        return error substitute( "&1. Ошибка exp-pack для таблицы &2", vss-workfile, v-temp-table-name ).
    end.
    if valid-handle ( v-temp-table-handle )
    then do:
        delete object v-temp-table-handle.
    end.
    if valid-handle ( v-buf-temp-table-handle )
    then do:
        delete object v-buf-temp-table-handle.
    end.
end.
end procedure. /* expand-dump-and-export */

procedure start-exp-pack :
define parameter buffer buf_ext-system for ub.ext-system.
define input  parameter p-pack-num as integer   no-undo .
define input  parameter p-pack-file as character no-undo .
define input  parameter p-cert-enabled     as logical no-undo .
define input  parameter p-cert-subj-name   as character no-undo .
define input  parameter p-cert-issuer-name as character no-undo .
define input  parameter p-sign-fileext     as character no-undo .
define input  parameter p-cert-repository  as integer   no-undo .
define output parameter p-err-gen-pack as integer   no-undo . // 20/VIII-2018 - не используется, снаружи не проверяется

define variable v-buffer-handle        as handle       no-undo.
define variable v-parameter-list       as character    no-undo.
define variable v-esr-action           as character    no-undo.

define variable v-start-regular-pack   as logical      no-undo.
define variable v-end-regular-pack     as logical      no-undo.
define variable rec-cnt                as integer      no-undo.
define variable v-start                as logical      no-undo init yes.
define variable v-error-num            as integer      no-undo.
define variable v-found-route          as logical      no-undo .

define variable sw as handle no-undo.
define variable sender-id as character no-undo.
define variable v-longdata as longchar no-undo.
define variable v-type as character no-undo .
define variable v-packdata as memptr no-undo .

define buffer buf_esys-route         for ub.esys-route.
define buffer buf_esys-route-dump    for ub.esys-route-dump.
define buffer buf_temp_esys-route    for temp_esys-route.
define buffer buf_esys-pck-sent      for ub.esys-pck-sent.

define variable v-pkcs             as class ibs.th.gbl.pkcs no-undo .
define variable v-signdata         as memptr no-undo .
define variable v-sign-file        as character no-undo . // имя файла с электронной подписью
define variable v-position         as integer no-undo . // позиция точки в имени файла


do
on error undo, return error return-value
:
      if buf_Ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
      then do :
        
        run db-attr-value in this-procedure 
           (input ibs.th.gbl.gbl-var:g#db-num
           ,input {&attr-int-point}
           ,output sender-id
           ,output v-type
           ) no-error .
        
        put stream 1c-log unformatted string(now) "  Начало формирования пакета " string(p-pack-num) "  " p-pack-file skip .
        
        create sax-writer sw.
        sw:formatted = true.
        sw:set-output-destination ("memptr", v-packdata).
        
        sw:encoding = "UTF-8".
        sw:start-document () .
        
        sw:start-element ("GC-ERPRN") .
        
        sw:insert-attribute ("xmlns", "http://www.rosneft.ru/GasComplex/Retail/11.0") .
        sw:insert-attribute ("xmlns:xs", "http://www.w3.org/2001/XMLSchema") .
        sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .

        put stream 1c-log unformatted string(now) "  Заполнение шапки" skip .
          sw:start-element ("header") .
            sw:write-data-element ("num", string(p-pack-num)) .
            sw:write-data-element ("sender-id", sender-id) .
            sw:write-data-element ("reciever-id", "00000") .
            sw:write-data-element ("created-date", iso-date (now)) .
          sw:end-element ("header") .
        put stream 1c-log unformatted string(now) "  Шапка заполнена" skip .

      end.
      
      assign
          v-start-regular-pack = yes
          v-end-regular-pack = no
          v-found-route = no
      .
      _buf_esys-route:
      for each buf_esys-route no-lock
          where buf_esys-route.esys-id     = buf_ext-system.esys-id
            and buf_esys-route.db-num      = buf_Ext-system.db-num
/*            and buf_esys-route.esr-cr-db-num = v-cur-db-num*/
            and buf_esys-route.esr-last-pack = p-pack-num
      on error undo, return error
      break by buf_esys-route.esr-oper by buf_esys-route.esr-tbl-ord
      :
        assign
            rec-cnt    = rec-cnt + (if v-start then 1 else 0)
            v-tesr-key = v-tesr-key + 1
            v-esr-action   = buf_esys-route.esr-action
            v-found-route = yes
          .
        create buf_temp_esys-route.
        assign
            buf_temp_esys-route.tesr-key         = v-tesr-key
            buf_temp_esys-route.esys-id          = buf_esys-route.esys-id
            buf_temp_esys-route.db-num           = buf_esys-route.db-num
            buf_temp_esys-route.esr-cr-db-num    = buf_esys-route.esr-cr-db-num
            buf_temp_esys-route.esr-last-pack    = buf_esys-route.esr-last-pack
            buf_temp_esys-route.esr-tbl-ord      = buf_esys-route.esr-tbl-ord
        .
        case buf_esys-route.esr-action
        :
          when {&nwsdochs_action_command-bush}
          or
          when {&nwsdochs_action_command-pbush}
          then do:
            /*а это уже выгрузка по команде*/
            if buf_Ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
            then do :
                if first-of(buf_esys-route.esr-oper)
                then put stream 1c-log unformatted string(now) "  Запись секции " buf_esys-route.esr-oper skip .
                
                if first-of(buf_esys-route.esr-oper)
                then sw:start-element (buf_esys-route.esr-oper) .
                
                if buf_esys-route.esr-oper = "sales-p-shifts"
                then do :
                  sw:start-element ("sales-p-shift") .
                    sw:write-data-element ("tbl-ord", string(buf_esys-route.esr-tbl-ord)) .
                end.
                
                for each buf_esys-route-dump where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord:
                  v-longdata = "" .
                  fix-codepage(v-longdata) = "UTF-8" .
                  copy-lob from buf_esys-route-dump.esrd-blob-value-rec to v-longdata no-convert.
                  sw:write-fragment (v-longdata) .
                end.
                
                if buf_esys-route.esr-oper = "sales-p-shifts"
                then do :
                  sw:end-element ("sales-p-shift") .
                end.
                
                if last-of(buf_esys-route.esr-oper)
                then sw:end-element (buf_esys-route.esr-oper) .
                
                if last-of(buf_esys-route.esr-oper)
                then put stream 1c-log unformatted string(now) "  Запись секции " buf_esys-route.esr-oper " завершена" skip .
            end.
            else do :
                if v-start then do:
                run bge/cmdesgen.p (
                                      input parparentproc
                                      ,input p-log-handle
                                      ,input buf_ext-system.esys-id
                                      ,input buf_ext-system.db-num
                                      ,input buf_ext-system.esys-db-num-exp
                                      ,input buf_esys-route.esr-cr-db-num
                                      ,input buf_esys-route.esr-dump-ord
                                      ,input buf_esys-route.uniq-gate-rec
                                      ,input p-pack-file
                                      ,input 1 /*p-xml-file-number  пока 1 */
                                      ,input buf_esys-route.esr-last-pack
                                      ,output rec-cnt
                                      ) no-error.
                if error-status:error then do:
                  v-err-msg =  substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                          , return-value
                                          , trim( error-status :get-message( 1 ) ))
                  .
    
                  run write-log in p-log-handle (
                        input 2
                      , input v-err-msg
                  ).
                  run send-msg-to-email in parparentproc
                      ( input substitute( "ТН (ver &2) БД &1. Ошибка OXML при экспорте пакета из ВС &2"
                                          , v-ver-num
                                          , v-cur-db-num
                                          , buf_ext-system.esys-id )
                      ,input v-err-msg
                      ,input "":U
                      ) no-error .
                  if error-status :error then do:
                      run write-log in p-log-handle (
                      input 2
                    , input substitute( "&1. &3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                                                      ) .
                  end.
                  undo, return error .
                end.
                end. /*if v-start = yes then do:*/
                v-start = no.
                next _buf_esys-route.
            end.
          end.
          when {&nwsdochs_action_update}
          or when {&nwsdochs_action_delete}
          then do:
             if v-start-regular-pack then do:
                assign
                v-list-file-name = "":U
                v-parameter-list = substitute( "&1,&2,&3,&4,&5,&6,&7"
                                                , 6
                                                , "THformat":U
                                                , "Trade House OpenXML 1.0":U
                                                , "THversion":U
                                                , trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
                                                , "THrevision":U
                                                , trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
                                            )
                v-parameter-list = substitute( "&1,&2,&3,&4,&5,&6,&7"
                                                , v-parameter-list
                                                , "THesysName":U
                                                , buf_ext-system.esys-name
                                                , "THcurrentDbNum":U
                                                , string( v-cur-db-num )
                                                , "THpack-num":U
                                                , string( p-pack-num )

                                            )
                .

                run xmllib-write-header in this-procedure (
                      input yes
                    , input p-pack-file
                    , input v-list-file-name
                    , input 1
                    , input no
                    , input "":U
                    , input v-parameter-list
                ).
                output STREAM stmXMLOut TO VALUE( p-pack-file + {&xmllib-temp-extension} ) CONVERT TARGET "1251" APPEND.
                v-start-regular-pack = no.
                v-end-regular-pack = yes.
              end.
              for each buf_esys-route-dump no-lock
                where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
              on error undo, return error
              :
                  assign
                     v-buffer-handle = buffer buf_esys-route-dump :handle
                  .
                  run expand-dump-and-export in this-procedure (
                        input v-esr-action
                      , input buf_esys-route.esr-uniq-key-rec
                      , input buf_esys-route-dump.esrd-dump-name
                      , input v-buffer-handle :buffer-field( "esrd-value-rec":U )
                  ) no-error.
                  if error-status :error
                  then do:
                      run write-log in p-log-handle (
                            input 2
                          , input substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                              , return-value
                                              , trim( error-status :get-message( 1 ) )
                                              , trim( error-status :get-message( 2 ) )
                                          )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", return-value )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", trim( error-status :get-message( 1 ) ) )
                      ).
                      run write-log in p-log-handle (
                          input 0
                          , input substitute( "&1.", trim( error-status :get-message( 2 ) ) )
                      ).
                      undo, return error .
                  end.
/*                    run write-log in p-log-handle (*/
/*                        input 1*/
/*                        , input substitute( "&1&2  &3 &4", {&new-line}*/
/*                                            , buf_esys-route.esr-name-rec*/
/*                                            , buf_esys-route-dump.esrd-dump-name*/
/*                                            , buf_esys-route-dump.esrd-rec-ord*/

/*                                          )*/
/*                    ).*/
              end.        /* for each buf_esys-route-dump */
            end.        /* when {&nwsdochs_action_update} */
        end case.       /* case buf_temp_esys-route.esr-action */
      end.        /* for each buf_esys-route */

      if buf_Ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
      then do :
          sw:end-element ("GC-ERPRN") .
          sw:end-document () .
          
        put stream 1c-log unformatted string(now) "  Окончание формирования пакета" skip .

        COPY-LOB FROM OBJECT v-packdata TO FILE p-pack-file NO-CONVERT NO-ERROR .
        
        if p-cert-enabled then do on error undo, throw :
          define variable v-err-msg as character no-undo .
          v-err-msg = "" .
            
          // p-cert-subj-name > "" и p-cert-issuer-name > "" были проверены при чтении параметров
            v-pkcs = new ibs.th.gbl.pkcs().
            v-signdata = v-pkcs:computeSign(v-packdata, p-cert-subj-name, p-cert-issuer-name, p-cert-repository) .
            // взять имя файла p-pack-file без расширения
            v-position = r-index(p-pack-file, ".") .
            v-sign-file = if v-position > 0 then substring(p-pack-file, 1, v-position - 1) else p-pack-file .
            v-sign-file = substitute("&1.&2", v-sign-file, p-sign-fileext) .
            COPY-LOB FROM OBJECT v-signdata TO FILE v-sign-file NO-CONVERT .
          
          // ошибки - в лог, и ... 
          catch exAppErrors as class Progress.Lang.AppError :
            v-err-msg = exAppErrors:ReturnValue .
            if v-err-msg > "" then . else do :
              v-err-msg = exAppErrors:GetMessage(1) . 
              if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
            end .
          end catch .
          catch exProErrors as class Progress.Lang.ProError :
            v-err-msg = exProErrors:GetMessage(1) . 
            if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
          end catch .
          catch exAnyErrors as class Progress.Lang.Error:
            v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
          end catch .
          finally: 
            set-size(v-signdata) = 0 .
            if valid-object(v-pkcs) then delete object v-pkcs .
            if v-err-msg > "" then do :
              run write-log in p-log-handle ( input 0, input v-err-msg ).
              undo, return error . // ... - и прекращаем выгрузку
            end .
          end finally.
        end . // end_of if_cert
        
        set-size(v-packdata) = 0 .
        
        put stream 1c-log unformatted string(now) "  Пакет " string(p-pack-num) "  " p-pack-file "   СФОРМИРОВАН" skip .
        
        file-info:file-name = p-pack-file .
        if file-info:file-size = 0
        then put stream 1c-log unformatted "!!!!!!!!! " string(now) "  Пакет " string(p-pack-num) "  " p-pack-file "   ПУСТОЙ" skip .
      end.
    if v-found-route = no
    and buf_ext-system.esys-type > integer({&openxml-type-ordinal})
    then do:
      if buf_Ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
      then put stream 1c-log unformatted string(now) "  1_cmdesgen.p  Пакет " string(p-pack-num) "  " p-pack-file skip .
        
      run bge/cmdesgen.p (
                            input parparentproc
                            ,input p-log-handle
                            ,input buf_ext-system.esys-id
                            ,input buf_ext-system.db-num
                            ,input buf_ext-system.esys-db-num-exp
                            ,input v-cur-db-num /*esr-cr-db-num-*/
                            ,input -1 /*esr-dump-ord*/
                            ,input '' /*uniq-gate-rec*/
                            ,input p-pack-file
                            ,input 1 /*p-xml-file-number  пока 1 */
                            ,input p-pack-num
                            ,output rec-cnt
                            ) no-error.
      if error-status:error then do:
        run write-log in p-log-handle (
              input 2
            , input substitute( "Ошибка 1 разбора esys-route-dump. &1. &2. &3"
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                            )
        ).
        undo, return error .
      end.
      
      if buf_Ext-system.delivery-method = integer({&esys-dm-erp-1C-RN})
      then put stream 1c-log unformatted string(now) "  2_cmdesgen.p  Пакет " string(p-pack-num) "  " p-pack-file skip .
    end.
    if v-end-regular-pack
    and v-found-route = yes
    then do:
      output STREAM stmXMLOut close.
      run bge/os_copy.p (
            input "D"
          , input (p-pack-file + "xml")
          , input ""
          , output v-error-num
      ).

      run xmllib-write-footer in this-procedure (
            input yes
          , input p-pack-file
          , input v-list-file-name
          , input no
          , input "":U
      ).
       v-end-regular-pack = no.
    end.

    run cur-time in this-procedure (
              output v-today
            , output v-time
    ).
    for each buf_temp_esys-route
    on error undo, return error
    :
        find first buf_esys-route exclusive-lock
            where buf_esys-route.esys-id        = buf_temp_esys-route.esys-id
              and buf_esys-route.db-num         = buf_temp_esys-route.db-num
              and buf_esys-route.esr-cr-db-num  = buf_temp_esys-route.esr-cr-db-num
              and buf_esys-route.esr-last-pack  = buf_temp_esys-route.esr-last-pack
              and buf_esys-route.esr-tbl-ord    = buf_temp_esys-route.esr-tbl-ord
        .
        assign
            buf_esys-route.esr-status            = 1
            buf_esys-route.esr-sys-date          = v-today
            buf_esys-route.esr-sys-time-int      = v-time
            buf_esys-route.esr-sys-time          = string( v-time, "hh:mm:ss" )
        .
       delete buf_temp_esys-route.
    end.        /* for each buf_temp_esys-route */
    find first buf_esys-pck-sent exclusive-lock
      where buf_esys-pck-sent.esys-id   = buf_ext-system.esys-id
        and buf_esys-pck-sent.db-num   = buf_ext-system.db-num
        and buf_esys-pck-sent.esps-cr-db-num = v-cur-db-num
        and buf_esys-pck-sent.esps-pack-num = p-pack-num
    .
    assign
      buf_esys-pck-sent.esps-total-recs     = rec-cnt + (if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})
                                                          then 0
                                                          else 1)
      buf_esys-pck-sent.esps-CreNum         = buf_esys-pck-sent.esps-CreNum + 1
      buf_esys-pck-sent.esps-SendTxtDate    = v-today
      buf_esys-pck-sent.esps-SendTxtTimeInt = v-time
      buf_esys-pck-sent.esps-SendTxtTime    = string( v-time, "HH:MM:SS" )
      .
end. /*doe*/

end procedure. /* start-exp-pack */



/*==========================================================================*/
procedure exp-pack :
define input parameter p-action         as character        no-undo.
define input parameter p-unique-key     as character        no-undo.
define input parameter p-tbl-handle     as handle           no-undo.
define input parameter p-table-name     as character        no-undo.

      define variable v-num-fields      as integer          no-undo.
      define variable v-counter         as integer          no-undo.
      define variable v-field-handle    as handle           no-undo.
      define buffer buf_datatype-table          for ub.datatype-table.
      define buffer buf_datatype-table-field    for ub.datatype-table-field.
do
for buf_datatype-table
  , buf_datatype-table-field
on error  undo, return error substitute( "&1 (oxmloutx). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1 (oxmloutx). stop", vss-workfile )
on endkey undo, return error substitute( "&1 (oxmloutx). endkey", vss-workfile )
:
    find first buf_datatype-table no-lock
         where buf_datatype-table.dtt-name = p-table-name
    no-error.
    if available buf_datatype-table
    then do:
        run xmllib-tag-open in this-procedure ( input 1, input buf_datatype-table.dtt-xml-tag, input "":U ).
        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-action"       , input p-action    , input 0 ).
        run xmllib-tag-put in this-procedure ( input 2, input "TH__record-unique-key"   , input p-unique-key, input 0 ).
        assign
            v-num-fields = p-tbl-handle :num-fields
        .
        do v-counter = 1 to v-num-fields
        on error undo, return error substitute( "&1 (nws-exp). &2", vss-workfile, error-status :get-message ( 1 ) )
        :
            assign
                v-field-handle = p-tbl-handle :buffer-field( v-counter )
            .                                                                  /* replace( replace( v-field-handle:buffer-value, '"':U, '""':U ), '~~':U, '~~~~':U ) */
            find first buf_datatype-table-field no-lock
                 where buf_datatype-table-field.dtt-name = buf_datatype-table.dtt-name
                   and buf_datatype-table-field.dtf-name = v-field-handle :name
            no-error.
            if available buf_datatype-table-field
            then do:
                if v-field-handle :buffer-value = ?
                then do:
                    run xmllib-tag-put-null in this-procedure ( input 2, input buf_datatype-table-field.dtf-xml-tag ).
                end.
                else do:
                    run xmllib-tag-put in this-procedure ( input 2, input buf_datatype-table-field.dtf-xml-tag  , input v-field-handle :buffer-value, input 0 ).
                end.
            end.        /* if available buf_datatype-table-field */
        end.
        run xmllib-tag-close in this-procedure ( input 1, input buf_datatype-table.dtt-xml-tag ).
    end.        /* if available buf_datatype-table */
end.
end procedure. /* exp-pack */

procedure delete-old-pck :
define parameter buffer buf_esys-pck-sent for ub.esys-pck-sent.
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-esps-cr-db-num as integer no-undo .
define input parameter p-esps-pack-num as integer no-undo .
define input parameter p-esys-name as character no-undo .


define variable v-del-pck-num as integer   no-undo.
define variable v-del-cnt     as integer   no-undo.
define variable v-today as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define frame del-route
v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
v-del-cnt       label "Записей" format ">>>>>>>>>9"
with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации" .

do
on error undo, return error
:
  run write-log in p-log-handle (
        input 2
      , input substitute( "Удаление данных пакета &1 ВС '&2'&3:истек срок хранения"
                         ,p-esps-pack-num
                         ,p-esys-name
                         ,{&new-line}
                          )
      ).
  view frame del-route .
  for each buf_esys-route
    where buf_esys-route.esys-id    = p-esys-id
      and buf_esys-route.db-num    = p-db-num
      and buf_esys-route.esr-cr-db-num = p-esps-cr-db-num
      and buf_esys-route.esr-last-pack = p-esps-pack-num
  on error  undo, return error substitute("&1. error buf_esys-route &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey buf_esys-route")
  on stop   undo, return error substitute("&1. stop buf_esys-route")
  :
    assign
      v-del-cnt = v-del-cnt + 1
    .
    do with frame del-route
    :
      assign
        v-del-pck-num :screen-value   = string( buf_esys-route.esr-last-pack, v-del-pck-num :format)
        v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
      .
    end.
    delete buf_esys-route.
  end.
  hide frame del-route .
  run cur-time in this-procedure ( output v-today, output v-time).
  transaction_block_pck-rcvd:
  do transaction
  on error  undo, return error substitute("&1. error transaction_block_esys-pck-rcvd &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on endkey undo, return error substitute("&1. endkey transaction_block_esys-pck-rcvd")
  on stop   undo, return error substitute("&1. stop transaction_block_esys-pck-rcvd")
  :
    find current buf_esys-pck-sent exclusive-lock.
    assign
    buf_esys-pck-sent.esps-rcvd        = yes
    buf_esys-pck-sent.esps-rcvdDate    = v-today
    buf_esys-pck-sent.esps-RcvdTimeInt = v-time
    buf_esys-pck-sent.esps-RcvdTime    = string( v-time, "HH:MM:SS" )
    .
  end.
  run write-log in p-log-handle (
        input 2
      , input substitute( ".....Удален" )
      ).

end.

end procedure. /* delete-old-pck */

procedure get-log-file-name :
define output parameter p-log-file-name as character no-undo .

  do
  on error undo, return error
  :
    p-log-file-name = add-log-file-name.
  end.

end procedure. /* get-lof-file-name */