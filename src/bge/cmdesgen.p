block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Укладка данных, маршрутизированных во ВС в файл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/23/07
Author: Bakhtadze Natalya
Creation date: 12/23/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-esys-id as integer   no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-db-num-exp as integer no-undo .
define input parameter p-cr-db-num as integer   no-undo .
define input parameter p-esr-dump-ord as int64 no-undo .
define input parameter p-gate-rec as character no-undo .
define input parameter p-xml-file-name as character no-undo .
define input parameter p-xml-file-number as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define output parameter p-num-rec as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Укладка данных, маршрутизированных во ВС в файл".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/oxml-def.i }
{ gbl/gate-clb.i }
{ bge/tmpcxmlh.i }
{ bge/fillxpck.i }
{ gbl/cur-time.i }
{ bge/fillxcnf.i }
{ gbl/tmpreldf.i }

define variable v_dataseth as handle no-undo .
define variable tth as handle  no-undo .
define variable bh_route-dump as handle no-undo .
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable tt-name as character no-undo .
define variable v-xmlh as handle no-undo .
define variable v-headerh as handle no-undo .
define variable v-header-th as handle no-undo .
define variable v-pckrcvd as handle no-undo .
define variable v-pcksent as handle no-undo .
define variable v-currpcksent as handle no-undo .
define variable v-prev-crc as character no-undo .
define variable bh_tt as handle no-undo .
define variable rec-cnt as integer no-undo .
define variable v-num-rec as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-is-ack as logical no-undo .
define variable v-header-schema-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-header-rec as character no-undo .


define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define buffer buf_temp-esys-pck-sent for THpck-sent.
define buffer curr_temp-esys-pck-sent for THcurr-pack.


&glob display-message  run write-log in p-log-handle ( ~
          input 2 ~
        , input ~{&my-message~} ) ~

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
  v-xmlh = buffer buf_temp-xml-tables:handle
  v-pckrcvd = buffer buf_temp-esys-pck-rcvd:handle
  v-pcksent = buffer buf_temp-esys-pck-sent:handle
  v-currpcksent = buffer curr_temp-esys-pck-sent:handle
  .
  for each buf_temp-esys-pck-rcvd:
    delete buf_temp-esys-pck-rcvd.
  end.
  for each buf_temp-esys-pck-sent:
    delete buf_temp-esys-pck-sent.
  end.
  for each curr_temp-esys-pck-sent:
    delete curr_temp-esys-pck-sent.
  end.
  for each t-pck-conf:
    delete t-pck-conf.
  end.
  find first buf_ext-system no-lock where
            buf_ext-system.esys-id = p-esys-id
        and buf_ext-system.db-num = p-db-num
            no-error.
  if not available buf_ext-system then do:
    &scop my-message substitute("Неизвестная внешняя система &1", p-esys-id)
    {&display-message}.
    undo, return error ''.
  end.
  find first buf_esys-pck-sent no-lock
    where buf_esys-pck-sent.esys-id  = p-esys-id
      and buf_esys-pck-sent.db-num   = p-db-num
/*      and buf_esys-pck-sent.esps-cr-db-num   = p-cr-db-num*/
      and buf_esys-pck-sent.esps-pack-num = p-pack-num
    no-error
  .
  if available buf_esys-pck-sent then do:
    if buf_esys-pck-sent.esps-SendTxtDate <> ? then do:
      &scop my-message substitute("Переформирование файла пакета N &1 для ВС N &2", p-pack-num, p-esys-id )
      {&display-message}.
    end.
    else do:
      &scop my-message substitute("Формирование файла пакета N &1 для ВС N &2", p-pack-num, p-esys-id )
      {&display-message}.
    end.
  end.
  else do:
    &scop my-message  substitute("&1. Пакет N &2 для ВС N &3 отсутствует.", vss-workfile, p-pack-num, p-esys-id )
    {&display-message}.
    undo, return error .
  end.
  /*наполняем временные таблицы*/
  if not buf_ext-system.delivery-method = integer({&esys-dm-contour-edi}) and not buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN}) then do:
    if p-esr-dump-ord >= 0 then do:
    find first buf_esys-route exclusive-lock where
              buf_esys-route.esr-dump-ord = p-esr-dump-ord
         and  buf_esys-route.esys-id = p-esys-id
         and  buf_esys-route.db-num = p-db-num
              .
    run  fillxpck in this-procedure (
                                       buffer buf_esys-route
                                      ,output v_dataseth
                                      ,input-output v-xmlh
                                      ,output v-num-rec
                                      ) no-error.
    if error-status:error then do:
      &scop my-message  substitute("&1 Ошибка при заполнении пакета &6 (&6) через gate &2&3&4&3&5" ~
                                              , vss-workfile ~
                                              ,buf_esys-route.uniq-gate-rec ~
                                              ,~{&new-line~} ~
                                              ,error-status:get-message(1) ~
                                              ,return-value ~
                                              ,p-pack-num ~
                                              ,buf_esys-route.esr-name-rec )
      {&display-message}.
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      undo, return error ''.
    end.
    end.
    else do:
      run  fillxpck_empty in this-procedure (
                                         output v_dataseth
                                        ,input-output v-xmlh
                                        ,output v-num-rec
                                        ) no-error.
      if error-status:error then do:
        &scop my-message  substitute("&1 Ошибка при заполнении ПУСТОГО пакета &6 (&6) через &2&3&2&4" ~
                                                , vss-workfile ~
                                                ,~{&new-line~} ~
                                                ,error-status:get-message(1) ~
                                                ,return-value ~
                                                ,p-pack-num ~
                                                ,buf_esys-route.esr-name-rec )
        {&display-message}.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error ''.
      end.
    end.
  
    if buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-wait})  then do:
       run fillxcnf in this-procedure ( input p-esys-id
                                       ,input p-db-num
                                       ,input p-cr-db-num
                                       ,input p-pack-num
                                       ,buffer buf_temp-esys-pck-sent
                                       ,buffer buf_temp-esys-pck-rcvd
                                       ,buffer curr_temp-esys-pck-sent
                                       ,output rec-cnt
                                       ,output v-prev-crc
                                       ) no-error.
       if error-status :error then do:
        &scop my-message  substitute("&1 Ошибка при заполнении пакета &2 данными для подтверждений &3&4&3&5" ~
                                      ,p-pack-num ~
                                      , vss-workfile ~
                                      ,~{&new-line~} ~
                                      ,error-status:get-message(1) ~
                                      ,return-value ~
                                        )
        {&display-message}.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error ''.
       end.
    end. /*  if false buf_ext-system.exp-conf-wait */
    rec-cnt = rec-cnt + v-num-rec.
    case buf_ext-system.delivery-method:
      when integer({&esys-dm-oracle-retail}) then do:
        if entry(num-entries(p-xml-file-name, "."), p-xml-file-name, ".") = "ack" then do:
          v-is-ack = yes.
        end.
        else do:
          v-header-schema-name = "exe/header_.xsd".
          v-header-name = "header_".
          define buffer buf_clients for ub.clients.
          find first buf_clients no-lock where
                    buf_clients.db-num = g#db-num
                and buf_clients.obj-type = {&shop} no-error .
          run get-gate-rec in this-procedure ( input v-header-schema-name
                                              ,output v-header-rec) no-error.
          if error-status:error then do:
            undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
          end.
          run get-header-by-rec in this-procedure ( input v-header-rec
                                                ,output v-header-th
                                                ) no-error.
          if error-status:error then do:
            &scop my-message substitute("Ошибка при создании структуры заголовка пакета согласно гейту:&1&2" ~
                                      , v-header-rec ~
                                      , ~{&new-line~}, error-status:get-message(1) )
            {&display-message}.
            undo, return error '':U.
          end.
  
          run cur-time in this-procedure ( output v-today, output v-time).
          v-headerh = v-header-th:default-buffer-handle.
          v-headerh:buffer-create().
         assign
          v-headerh::to_ = "Oracle Retail"
          v-headerh::from_ = "IBS Trade House"
          v-headerh::obj-type = (if available buf_clients then buf_clients.obj-type else '')
          v-headerh::obj-code = (if available buf_clients then string (buf_clients.obj-code) else '')
          v-headerh::name = entry(2, entry(1, v_dataseth:private-data, {&delim-par}), {&slash-char})
          v-headerh::xsd = entry(2, entry(1, v_dataseth:private-data, {&delim-par}), {&slash-char})
          v-headerh::date-from =  string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
          v-headerh::date-to =  string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
          .
        end.
      end.
      when integer({&esys-dm-exite-edi}) then do:
        v-header-schema-name = "".
        v-header-name = "".
      end.
      otherwise do:
          v-header-schema-name = "exe/ThHeader.xsd".
          v-header-name = "ThHeader".
          run get-gate-rec in this-procedure ( input v-header-schema-name
                                              ,output v-header-rec) no-error.
          if error-status:error then do:
            undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
          end.
          run get-header-by-rec in this-procedure ( input v-header-rec
                                                ,output v-header-th
                                                ) no-error.
          if error-status:error then do:
            &scop my-message substitute("Ошибка при создании структуры заголовка поакета согласно гейту:&1&2" ~
                                      , v-header-rec ~
                                      , ~{&new-line~}, error-status:get-message(1) )
            {&display-message}.
            undo, return error '':U.
          end.
        v-headerh = v-header-th:default-buffer-handle.
        v-headerh:buffer-create( ).
        assign
        v-headerh::THfilename     = p-xml-file-name
        v-headerh::THfilenumber   = p-xml-file-number
        v-headerh::THformat_      = "Trade House OpenXML 1.0"
        v-headerh::THversion_     = trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
        v-headerh::THrevision     = trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
        v-headerh::THesysname     = buf_ext-system.esys-name
        v-headerh::THcurrentDbNum = g#db-num
        v-headerh::THpack-num     = p-pack-num
        v-headerh::THschema-name  = substitute("exe/&1", entry(2, entry(1, v_dataseth:private-data, {&delim-par}), {&slash-char}))
        v-headerh::THprev-crc     = v-prev-crc
        v-headerh::THexport-esys-id  = p-esys-id
    .
      end.
    end case.
    /*добавим к dataset таблицу  для header*/
    if not v-is-ack
    and v-header-name <> ""
    then do:
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-headerh:table
    buf_temp-xml-tables.tbl-handle_ = v-headerh
    buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
    buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = -3
    rec-cnt = rec-cnt + 1
    .
  end.
    if buf_ext-system.exp-conf-wait = integer({&openxml-exp-conf-wait})  then do:
      /*добавим к dataset таблицу  для отправ пакетов*/
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-pcksent:table
      buf_temp-xml-tables.tbl-handle_ = v-pcksent
      buf_temp-xml-tables.table-handle_ = v-pcksent:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = -2
      .
      /*добавим к dataset таблицу  для получ пакетов*/
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-pckrcvd:table
      buf_temp-xml-tables.tbl-handle_ = v-pckrcvd
      buf_temp-xml-tables.table-handle_ = v-pckrcvd:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = -1
      .
      /*добавим к dataset таблицу  для текущего пакета*/
      create buf_temp-xml-tables.
      assign
      buf_temp-xml-tables.tbl-name = v-currpcksent:table
      buf_temp-xml-tables.tbl-handle_ = v-currpcksent
      buf_temp-xml-tables.table-handle_ = v-currpcksent:table-handle
      buf_temp-xml-tables.uniq-gate-rec = (if available buf_esys-route then buf_esys-route.uniq-gate-rec else '')
      buf_temp-xml-tables.gate-name = v_dataseth:name
      buf_temp-xml-tables.gate-handle_ = v_dataseth
      buf_temp-xml-tables.order = v_dataseth:num-buffers + 1
      .
      /*rec-cnt уже учли когда вызывали fillxcnf*/
    end.
    if not (v-is-ack
            or
            v-header-name = '')
    then do:
      if v-headerh:table = "THheader" then do:
        v-headerh::THtotal-recs = rec-cnt.
      end.
    run tmpreldf_get-relations in this-procedure ( input v_dataseth).
    /*пересортируем так чтобы header был первый*/
    for each buf_temp-xml-tables
    break
    by buf_temp-xml-tables.order:
     if first(buf_temp-xml-tables.order) then do:
       glog = v_dataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
     end.
     else do:
       glog = v_dataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
     end.
     if error-status:error
      or not glog                                     then do:
        &scop my-message substitute("Ошибка при создании заголовка XML файла:&1&2", ~{&new-line~}, error-status:get-message(1) )
        {&display-message}.
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        undo, return error '':U.
      end.
    end.
    run tmpreldf_set-relations in this-procedure ( input v_dataseth, input v_dataseth).
    end. /*  if not (v-is-ack*/
    glog = v_dataseth:WRITE-XML("FILE"
                              ,p-xml-file-name
                              ,yes /*lFormatted*/
                              ,(if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})
                                then "utf-8"
                                else "windows-1251") /*encoding*/
                              ,? /*cSchemaLocation*/
                              ,no /*lWriteSchema*/
                              ,no /*lMinSchema*/
                              ) no-error.
  
    if error-status:error then do:
          &scop my-message substitute("Ошибка при записи XML файла данными через гейт &1:&2&3" ~
                                      , v_dataseth:name ~
                                      , ~{&new-line~}, error-status:get-message(1) )
      {&display-message}.
    end.
    p-num-rec = v-num-rec.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
  end.
  else do:
    define stream exp-str .
    define variable mbuffer as memptr .
    output stream exp-str to value(p-xml-file-name). 
    for each buf_esys-route-dump where buf_esys-route-dump.esrd-dump-ord = p-esr-dump-ord:
      mbuffer = buf_esys-route-dump.esrd-blob-value-rec.
      export stream exp-str mbuffer .
    end.
    output stream exp-str close.
  end.
end. /*doe*/