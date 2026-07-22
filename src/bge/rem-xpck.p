block-level on error undo, throw.
/*

$Revision: f0ffd58b8bac, 1562, rls $
$Author: SMMolotkov $
$Date: Tue Nov 06 04:41:34 2018 +0300 $
$Workfile: rem-xpck.p $
$Archive: bge/rem-xpck.p $

Удаление пакетов OXML по указанной ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/12/08
Author: Bakhtadze Natalya
Creation date: 11/12/08

*/

define input parameter p-esys-id      like ub.ext-system.esys-id         no-undo .
define input parameter p-db-num       like ub.ext-system.db-num          no-undo .

define variable vss-revision    as character no-undo init "$Revision: f0ffd58b8bac, 1562, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rem-xpck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/rem-xpck.p $":U .
define variable vss-description as character no-undo init "Удаление пакетов OXML по указанной ВС".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/oxml-def.i  }
{ bge/esallatr.i work }

do
on error undo, return error
:

  define stream dir-stream .

  define buffer buf_ext-system       for ub.ext-system .
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
  define buffer buf_esys-all-attr for ub.esys-all-attr.

  define variable v-pck-for-esys  as integer   no-undo .
  define variable v-add-to-list  as logical   no-undo .

  define variable v-list-action  as character no-undo .
  define variable v-action       as character no-undo .
  define variable v-dir-name     as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-type         as character no-undo .
  define variable v-filename     as character no-undo .
  define variable v-fullfilename as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .
  define variable v-custom-pack-flag as logical no-undo .
  define variable v-file-cnt     as integer   no-undo .


  define variable v-count-del      as integer   no-undo .
  define variable v-count-need-del as integer   no-undo .

  define variable v-today        as date      no-undo .
  define variable v-time         as integer   no-undo .
  define variable v-success      as logical no-undo .

  find first buf_ext-system no-lock
    where buf_ext-system.esys-id = p-esys-id
      and buf_ext-system.db-num = p-db-num
    no-error
  .
  if not available buf_ext-system then do:
    run write-to-log( substitute( "&1. ВС &2 не найдена", vss-workfile, p-esys-id ) ) .
    return error.
  end.

  if buf_ext-system.delete-pck-on = 0 then do:
    return .
  end.

  assign
  v-pck-for-esys = buf_ext-system.esys-id
  .
  if buf_ext-system.save-days-pck-num < 20 then do:
    return.
  end.

  run write-to-log( substitute("Анализ необходимости удаления файлов OXML по ВС &1", v-pck-for-esys ) ) .

  v-success = no.
  run bge/lockesys.p (
    input buf_ext-system.esys-id
    ,input buf_ext-system.db-num
    ,buffer buf_ext-system
    ,output v-success
  ) no-error.
  if error-status:error
  or not v-success
  then do:
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
    v-count-del      = 0
    v-count-need-del = 0
    v-file-cnt       = 0
  .
  do v-ind = 1 to 2
  :
    assign
      v-action   = entry( v-ind, v-list-action )
      v-pack-num = ?
    .
    run bge/espcknum.p
      ( input v-action
       ,input p-esys-id
       ,input p-db-num
       ,input buf_ext-system.delivery-method
       ,input oxml-exch-dir
       ,input oxml-heap-dir
       ,input ""
       ,input-output v-pack-num
       ,input-output v-custom-pack-name
       ,output v-pack-name
       ,output v-source-dir
       ,output v-target-dir
       ,output v-temp-dir
       ,output v-log-file-name
       ,output v-list-file-name
       ,output v-custom-pack-flag
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

    input stream dir-stream from os-dir ( v-dir-name )  no-attr-list no-echo  .
    _repeat:
    repeat:
      import stream dir-stream v-filename v-fullfilename .
      assign
      file-info :file-name = v-fullfilename
      .
      if caps( file-info :file-type ) begins "F":U
        and num-entries( v-filename, "." ) > 1
      then do:
        assign
        v-file-cnt = v-file-cnt + 1
        .
        if file-info :file-mod-date + buf_ext-system.save-days-pck-num < v-today then do:
          if length(v-filename) = 14
          and substring(v-filename, 1, 1) = 'o'
          and substring(v-filename, 11, 4) = '.xml'
          and trim(substring(v-filename, 2, 9), '0123456789') = '' then do:
            /*каноническая форма*/
            assign
              v-pack-num    = integer( substring( v-filename, 2, r-index(v-filename, '.':U) - 1 ) )
              v-add-to-list = true
            .
          end.
          else do:
            /*проверим по атрибутам*/
            find first buf_esys-all-attr no-lock where
                    buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
                and buf_esys-all-attr.table-name = (if v-ind = 1 then {&table_esys-pck-sent} else {&table_esys-pck-rcvd})
                and buf_esys-all-attr.key2 = p-esys-id
                and buf_esys-all-attr.attr-value  = v-filename
                and buf_esys-all-attr.key5 =  p-db-num no-error.
            if not available buf_esys-all-attr then next _repeat.
            assign
              v-pack-num    = buf_esys-all-attr.key1
              v-add-to-list = true
            .
          end.
          case v-action :
            when "put":U then do:
              find first buf_esys-pck-sent no-lock
                where buf_esys-pck-sent.esys-id  = v-pck-for-esys
                  and buf_esys-pck-sent.db-num   = p-db-num
                  and buf_esys-pck-sent.esps-pack-num = v-pack-num
                  and buf_esys-pck-sent.esps-cr-db-num = g#db-num
                no-error .
              if not available buf_esys-pck-sent
                or buf_esys-pck-sent.esps-rcvd <> true
              then do:
                assign
                  v-add-to-list = false
                .
              end.
            end.
            when "get":U then do:
              find first buf_esys-pck-rcvd no-lock
                where buf_esys-pck-rcvd.esys-id   = v-pck-for-esys
                  and buf_esys-pck-rcvd.db-num   = p-db-num
                  and buf_esys-pck-rcvd.espr-pack-num = v-pack-num
                  and buf_esys-pck-rcvd.espr-cr-db-num = g#db-num
                no-error .
              if not available buf_esys-pck-rcvd then do:
                assign
                  v-add-to-list = false
                .
              end.
            end.
          end case.
          if v-add-to-list = true then do:

            if v-count-need-del = 0 then do:
              run write-to-log( substitute("Удаление файлов OXML по ВС &1", v-pck-for-esys ) ) .
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
    input stream dir-stream close.
  end.

  if v-count-need-del > 0 then do:
    run write-to-log( substitute("Анализ пакетов по ВС &1 завершен. Просмотрено &2 файлов. Удалено &3 из &4 старых пакетов."
                                 , v-pck-for-esys
                                 , v-file-cnt
                                 , v-count-del
                                 , v-count-need-del
                                   ) ) .
  end.
  else do:
    run write-to-log( substitute("Анализ пакетов по ВС &1 завершен. Просмотрено &2 файлов. Старых файлов не обнаружено."
                                 , v-pck-for-esys
                                 , v-file-cnt
                                   ) ) .

  end.
end.

/* $Workfile: rem-xpck.p $ end */