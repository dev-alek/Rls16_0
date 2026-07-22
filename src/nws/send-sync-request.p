
/*------------------------------------------------------------------------
    File        : send-sync-request.p
    Purpose     : 

    Syntax      :

    Description : Отправка файла с запросом синхронизации обмена СПН с УБД на ТБД

    Author(s)   : SSlivenko
    Created     : Mon Jun 08 14:26:22 MSK 2026
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

/* ********************  Preprocessor Definitions  ******************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as handle     no-undo .
define input parameter p-db-num       as integer    no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Синхронизация новостей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }

do
on error undo, return error
:

  define variable vOk as logical no-undo .
  define variable v-req as longchar no-undo .
  define variable v-req64 as longchar no-undo .
  define variable vMem as memptr no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-err-msg      as character no-undo .
  define variable v-real-last-sent-pck as integer no-undo init 0 .
  define variable v-real-last-rcv-pck as integer no-undo init 0 .
  
  define buffer buf-dst_db   for ub.db .
  define buffer buf-src_db   for ub.db .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  /* ***************************  Main Block  *************************** */

  find first buf_sys-ctrl no-lock .

  find first buf-src_db no-lock
    where buf-src_db.db-num = buf_sys-ctrl.db-num
    no-error
  .
  if not available buf-src_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, buf_sys-ctrl.db-num ) ) .
    return error.
  end.

  find first buf-dst_db no-lock
    where buf-dst_db.db-num = p-db-num
    no-error
  .
  if not available buf-dst_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, p-db-num ) ) .
    return error.
  end.
  
  run nws/lock-nws.p
    ( input p-db-num
     ,buffer buf-dst_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.
  
  assign v-pack-num = 9999999 .
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
    assign
      v-err-msg = substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
    .
    run write-to-log( v-err-msg ) .
    return error.
  end.
  
  assign
    file-info:file-name = v-source-dir + {&back-slash-char} + v-pack-name
  .
  if file-info:file-type <> ?
  then do :
    message "Запрос на синхронизацию уже отправлен. Повторить?" view-as alert-box question buttons yes-no update vOk .
    if not vOk
    then 
      return .
  end .
  
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
  
  for each pck-sent no-lock where pck-sent.db-num = p-db-num :
    v-real-last-sent-pck = max(v-real-last-sent-pck, pck-sent.pack-num) .
  end.
  for each pck-rcvd no-lock where pck-rcvd.db-num = p-db-num :
    v-real-last-rcv-pck = max(v-real-last-rcv-pck, pck-rcvd.pack-num) .
  end.
  
  assign v-req = "needsync" + {&delim-par} + string(buf-src_db.db-num) + {&delim-par} + string(v-real-last-sent-pck) + {&delim-par} + string(v-real-last-rcv-pck) + {&delim-par} + string(now) .
  copy-lob from v-req to vMem .
  v-req64 = base64-encode(vMem) .
  copy-lob from v-req64 to file (v-source-dir + {&back-slash-char} + v-pack-name) .
  
  run nws/s-g-pack.p
    ( input "put":U
     ,input "7zip":U
     ,input v-pack-name
     ,input v-source-dir
     ,input v-target-dir
     ,input v-temp-dir
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при отправке пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                    ) .
    return error.
  end.
end .
