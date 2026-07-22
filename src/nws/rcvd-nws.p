block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcvd-nws.p $
$Archive: nws/rcvd-nws.p $

Прием новостей из указанной БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/
define input  parameter parparentproc   as   widget-handle        no-undo .
define input  parameter p-action        as   character            no-undo .
define input  parameter p-db-num        like ub.db.db-num         no-undo .
define input  parameter p-pack-num      like ub.pck-sent.pack-num no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: rcvd-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/rcvd-nws.p $":U .
def var vss-description as character no-undo init "Прием новостей из указанной БД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ adm/push-m.i   }
{ gbl/db-attr.i  }
{ gbl/getsect.i def }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_db       for ub.db .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db-attr  for ub.db-attr .

  define variable v-ver-num      as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .

  define variable v-rcvd-pack    as logical   no-undo .
  define variable v-err-msg      as character no-undo .
  
  define variable v-mem as memptr no-undo .
  define variable v-str as longchar no-undo .
  define variable v-last-rcv-pck as integer no-undo .
  define variable v-last-sent-pck as integer no-undo .
  define variable vOk as logical no-undo .

  define variable apusharh as logical   no-undo . /* для чтения параметра конфигурации */

  find first buf_sys-ctrl no-lock .

  run get-version-num in parparentproc
    ( output v-ver-num
    ).

  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error
  .
  if not available buf_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, p-db-num ) ) .
    return error.
  end.
  if buf_db.db-key = "":U
    or buf_db.db-key = ?
  then do:
    run write-to-log( substitute("СПН для БД &1 отключена. Пакеты новостей не принимаются.", p-db-num ) ) .
    return.
  end.

  case p-action:
    when "take":U then do:
      run write-to-log( substitute("Прием пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "analys":U then do:
      run write-to-log( substitute("Разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "take+analys":U then do:
      run write-to-log( substitute("Прием и разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Не предусмотрена операция &1", p-action )
              view-as alert-box error.
      return error.
    end.
  end case.

  assign
    g#news-source-db = p-db-num
  .

  run nws/lock-nws.p
    ( input p-db-num
     ,buffer buf_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.

  assign
    v-pack-num = -1
    v-rcvd-pack = false
  .

  run nws/pck-num.p
    ( input "get":U
     ,input p-db-num
     ,input-output v-pack-num
     ,output v-pack-name
     ,output v-source-dir
     ,output v-target-dir
     ,output v-temp-dir
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                    ) .
    return error.
  end.

  if lookup( p-action, "take,take+analys":U ) <> 0 then do:
    /* копируем скопом все файлы из exch в heap */
    run nws/s-g-pack.p
      ( input "get":U
       ,input ?
       ,input ?
       ,input v-source-dir
       ,input v-target-dir
       ,input v-temp-dir
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
      return error.
    end.
  end.

  if lookup( p-action, "analys,take+analys":U ) <> 0
  then do:
    if p-db-num > 0
    then do transaction : /* Проверка запроса на синхронизацию обмена СПН */
      assign
        file-info:file-name = v-target-dir + {&back-slash-char} + "p9999999.txt"
      .
      if file-info:file-type <> ?
      and file-info:file-type begins "F":U
      then do :
        copy-lob from file (v-target-dir + {&back-slash-char} + "p9999999.txt") to v-str .
        v-mem = base64-decode (v-str) no-error .
        copy-lob from v-mem to v-str no-error .
        if v-str begins "needsync"
        and num-entries(v-str, {&delim-par}) = 5
        then do :
          os-delete value (v-target-dir + {&back-slash-char} + "p9999999.txt") no-error .
          os-delete value (v-source-dir + {&back-slash-char} + "p9999999.zip") no-error .
          
          find first buf_db-attr no-lock where buf_db-attr.db-num = p-db-num
                                           and buf_db-attr.attr-code = "last-nws-sync"
          no-error .
          if integer(entry(2, v-str, {&delim-par})) = p-db-num
          and (not available buf_db-attr
               or (available buf_db-attr and datetime-tz(buf_db-attr.attr-value) < datetime-tz(entry(5, v-str, {&delim-par})))
               )
          then do :
            run write-to-log( substitute( "Получен запрос на синхронизацию обмена СПН с БД &1", p-db-num ) ) .
            
            run nws/pck-num.p
              ( input "put":U
               ,input p-db-num
               ,input-output v-pack-num
               ,output v-pack-name
               ,output v-source-dir
               ,output v-target-dir
               ,output v-temp-dir
              ) no-error.
            if error-status:error then do:
              run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                              ) .
              return error.
            end.
            
            os-delete value (v-source-dir) recursive .
            os-delete value (v-target-dir) recursive .
            os-delete value (v-temp-dir)   recursive .
            
            assign
              file-info:file-name = v-source-dir
            .
            if file-info:file-type = ?
            or not ( file-info:file-type begins "D":U )
            then do:
              os-create-dir value( v-source-dir ).
              if os-error <> 0 then do:
                return error string( vss-workfile + {&space-char}
                                     + "Каталог" + {&space-char} + v-source-dir
                                     + {&space-char} + "отсутствует, а создать его не удалось." ).
              end.
            end.
            
            assign
              file-info:file-name = v-target-dir
            .
            if file-info:file-type = ?
            or not ( file-info:file-type begins "D":U )
            then do:
              os-create-dir value( v-target-dir ).
              if os-error <> 0 then do:
                return error string( vss-workfile + {&space-char}
                                     + "Каталог" + {&space-char} + v-target-dir
                                     + {&space-char} + "отсутствует, а создать его не удалось." ).
              end.
            end.
            
            assign
              v-last-rcv-pck  = integer(entry(3, v-str, {&delim-par}))
              v-last-sent-pck = integer(entry(4, v-str, {&delim-par}))
            .
            run nws/nws-sync.p (input parparentproc,
                                input p-db-num,
                                input v-last-rcv-pck,
                                input v-last-sent-pck,
                                output vOk)
                                no-error .
            if not vOk
            or error-status:error
            then do :
              run write-to-log( substitute( "Ошибка при синхронизация обмена СПН с БД &1&2&3", p-db-num, {&new-line}, return-value ) ) .
            end .
            if vOk
            then do :
              run db-attr-write in this-procedure
              ( input p-db-num
               ,input "last-nws-sync"
               ,input entry(5, v-str, {&delim-par})
              ) no-error.
              
              return .
            end .
          end .
        end . 
      end .
    end .  /* Проверка запроса на синхронизацию обмена СПН */
      
    rcvd-pack:
    do while TRUE
    on error  undo, return error substitute( "&1 (rcvd-pack). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (rcvd-pack). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (rcvd-pack). endkey", vss-workfile )
    :
      run nws/pck-num.p
        ( input "get":U
         ,input p-db-num
         ,input-output v-pack-num
         ,output v-pack-name
         ,output v-source-dir
         ,output v-target-dir
         ,output v-temp-dir
        ) no-error.
      if error-status:error then do:
        run write-to-log( substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                        ) .
        return error.
      end.

      assign
        file-info:file-name = v-target-dir + {&back-slash-char} + v-pack-name
      .
      if file-info:file-type = ?
        or not ( file-info:file-type begins "F":U ) then do:
        /* исходный файл не найден, значит он еще не пришел */
        leave rcvd-pack.
      end.

      run nws/imp-pck.p
        ( input parparentproc
        , input p-db-num
        , input v-pack-num
        , input v-target-dir + {&back-slash-char} + v-pack-name
        ) no-error.
      if error-status:error then do:
        assign
          v-err-msg = substitute("&1. Ошибка импорта пакета &3\&4&2&5&2&6", vss-workfile, {&new-line}, v-target-dir, v-pack-name, error-status :get-message( 1 ), return-value )
        .
        run write-to-log( v-err-msg ) .
        run send-msg-to-email in parparentproc
          ( input substitute( "ТН (ver &1) БД &2. Ошибка СПН при импорте пакета из БД &2", v-ver-num, buf_sys-ctrl.db-num, p-db-num )
           ,input v-err-msg
           ,input "":U
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. &3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                          ) .
        end.
        return error.
      end.

      assign
        v-rcvd-pack = true
        v-pack-num = v-pack-num + 1
      .
      if ( p-pack-num <> -1
           and v-pack-num > p-pack-num
         )
/*        or lookup( p-action, "analys":U ) <> 0*/
      then do:
        leave rcvd-pack.
      end.
    end.
    if v-rcvd-pack = true then do: /* толкатель авторасчета архивов */

      { gbl/getsect.i run "''"  0 {&attr-arh-global} }
      for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = 'apusharh'  then apusharh = thbjattr_thbj-attr.property-value-logical.
      end.
      empty temp-table thbjattr_thbj-attr.

      if apusharh then do:
        run push-abtpr in this-procedure
          ( input auto-window-h
           ,input p-db-num
           ,input {&btpr-type-autoarh}
           ,input "news-push":U
           ,input ?
           ,input ?
          ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при изменении времени запуска автоматического расчета архивов. &2&3&2&4"
                                        , vss-workfile
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                      )
                          ) .
        end.
      end.
    end.
  end.

  run gbl/del-file.p
    ( input v-temp-dir
    ) no-error .
  if error-status:error then do:
    run write-to-log(  substitute( "&1. &2", vss-workfile, return-value ) ).
  end.

  case p-action:
    when "take":U then do:
      run write-to-log( substitute( "Завершен прием пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "analys":U then do:
      run write-to-log( substitute( "Завершен разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
    when "take+analys":U then do:
      run write-to-log( substitute( "Завершен прием и разбор пакетов новостей из БД &1", p-db-num ) ) .
    end.
  end case.

  return.

end.

/* $Workfile: rcvd-nws.p $ end */