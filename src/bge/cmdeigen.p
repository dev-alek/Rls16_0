block-level on error undo, throw.
/*

$Revision: f4cdafb70594, 2001, rls $
$Author: druban $
$Date: Wed Sep 18 21:00:35 2019 +0300 $
$Workfile: cmdeigen.p $
$Archive: bge/cmdeigen.p $

Импорт файла XML из внешней системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/23/07
Author: Bakhtadze Natalya
Creation date: 12/23/07

Вызывается ТОЛЬКО из bge/oxmlinx.p .
В параметре p-pack-data лежит файл, прочитанный из p-xml-file-name .
Требуется передать p-pack-data в машину правил, чтобы исключить
повторное чтение файла p-xml-file-name внутри 000002098.p 
*/
define input parameter parparentproc as handle no-undo .
/* самостоятельно не используется; передаётся в:
  str/saledc.p
  str/cgrprum.p
  str/clisrum.p
  str/edocrum.p
  ref/threfrum.p
  str/ggrprum.p
  str/goodsrum.p
  и в виде &imp2cd_parparentproc в
  str/diallog.w
*/

define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .

/* @NOTE вместе с p-esys-id и p-db-num из buf_ext-system здесь используются:
  - buf_ext-system.esys-name
  - buf_ext-system.delivery-method
  - buf_ext-system.imp-conf-send
  ! buf_ext-system.db-num используется только для повторного поиска записи в buf_ext-system
    и больше не применяется
*/
define input parameter p-esys-id as integer   no-undo . /* = input buf_ext-system.esys-id */
define input parameter p-db-num  as integer   no-undo . /* = input buf_ext-system.db-num  */

define input parameter p-cr-db-num as integer no-undo .
define input parameter p-xml-file-name as character no-undo . /* = v-full-path from filename.p */
define input parameter p-file-name as character no-undo .     /* = v-file-name from filename.p */
define input parameter p-pack-data as memptr no-undo . // с 23/VIII-2018 xml-файл читается из memptr, а не из файла 
define input parameter p-pack-num as integer   no-undo .
define input parameter p-log-file-name as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: f4cdafb70594, 2001, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:00:35 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdeigen.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cmdeigen.p $":U .
define variable vss-description as character no-undo init "Импорт файла XML из внешней системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/oxml-def.i }
{ gbl/key-rec.i }
{ rul/tempcxml.i "NEW SHARED" }
/*должно быть шаред чтобы был доступ к temp-xml-tables глубоко внизу*/
{ gbl/gate-clb.i }
{ rul/xmlischn.i shared }
{ bge/impxcbsh.i }
{ bge/getoxmlh.i }
{ gbl/xmlchar.i }
{ bge/esallatr.i }
{ bge/espcknam.i }
{ bge/get-xcnf.i }
{ bge/esysattr.i }
{ gbl/tmpreldf.i }
{ gbl/orapreps.i }
&glob  imp2cd_parparentproc parparentproc
{ str/imp2cd.i }
{ rul/ruleset_.i }

define variable v_dataseth as handle no-undo .
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-xmlh as handle no-undo .
define variable v-headerh as handle no-undo .
define variable v-header-th as handle no-undo .
define variable v-pckrcvd as handle no-undo .
define variable v-pcksent as handle no-undo .
define variable v-currpcksent as handle no-undo .
define variable v-schema-name as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-schema-tmp-file as character no-undo .
define variable v-gate-rec as character no-undo .
define variable v-part-num as integer no-undo init 1.
define variable v-clob-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-prev-crc as character no-undo .
define variable v-import-prev-crc as character no-undo .
/*
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo . 12/VIII-2019 не используется. Заменён на p-xml-file-name
DEFINE VARIABLE v-file-name               as character                no-undo . 12/VIII-2019 не используется. Заменён на p-file-name
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
*/
define variable v-pck-num                 as integer                  no-undo .
define variable v-header-obj-type as character no-undo .
define variable v-header-obj-code as integer no-undo .
define variable v-rec-cnt     as integer   no-undo.
define variable v-task as integer no-undo .
define variable v-task-ok as integer no-undo .
define variable v-header-schema-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-header-rec as character no-undo .
define variable v-process as character no-undo .
define variable v-insert-header as logical   no-undo .
define variable v-my-message as character no-undo .

define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_temp-esys-pck-rcvd for THpck-rcvd.
define buffer buf_temp-esys-pck-sent for THpck-sent.
define buffer curr_temp-esys-pck-sent for THcurr-pack.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_temp-param-name for temp-param-name.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_esys-pck-sent for ub.esys-pck-sent.
define buffer buf_temp_xmllib_rec for temp_xmllib_rec.
define buffer buf_temp_xmllib_rec-fld for temp_xmllib_rec-fld.

&glob display-message  run write-log in p-log-handle ( input 2, input ~{&my-message~} )

define frame imp-pck
p-esys-id        label "ВС" skip
v-pck-num       label "Пакет" format ">>>>>>>>>9" skip
p-xml-file-name label "Файл пакета" format "x(50)" skip
v-rec-cnt       label "Основных записей" format ">>>>>>>>>9" skip
with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета"
.

main-block:
do
on error undo, return error return-value
:

  find first buf_ext-system no-lock where
            buf_ext-system.esys-id = p-esys-id
       and buf_ext-system.db-num = p-db-num
            no-error.
  if not available buf_ext-system then do:

  end.
  
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


  /* будем искать имя схемы*/
  case buf_ext-system.delivery-method:
    when integer({&esys-dm-oracle-retail}) then do:
      assign
      v-header-schema-name = "exe/header_.xsd"
      v-header-name = "header_".
    end.
    when integer({&esys-dm-exite-edi}) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    when integer({&esys-dm-contour-edi}) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    when integer({&esys-dm-erp-1C-RN}) then do:
      assign
      v-header-schema-name = ""
      v-header-name = "".
    end.
    otherwise do:
      assign
      v-header-schema-name = "exe/THheader.xsd"
      v-header-name = "THheader".
    end.
  end case.
  if v-header-name <> '' then do:
  run get-gate-rec in this-procedure ( input v-header-schema-name
                                      ,output v-header-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-header-schema-name).
  end.
  run get-header-by-rec in this-procedure ( input v-header-rec
                                            ,output v-header-th
                                            ) no-error.
  if error-status:error then do:
    v-my-message = substitute("Ошибка при создании структуры заголовка пакета согласно гейту:&1&2&3&2&4"
                               , v-header-rec
                               , {&new-line}
                               , error-status:get-message(1)
                               , return-value  ) .
    /* {&display-message}. 09/VIII-2019 */
    delete object v-header-th no-error.
    undo, return error v-my-message.
  end.
  v-headerh = v-header-th:default-buffer-handle.
  end. /*if v-header-name <> '' then do:*/
  run  xmllib-set-log-handle in this-procedure (
                                                 input p-log-handle
                                                ,input "write-to-log"
                                                 ).
  run getoxmlh in this-procedure ( input p-xml-file-name
                                  ,input p-pack-data
                                  ,input v-headerh
                                  ,input buf_ext-system.delivery-method
                                  ) no-error.


define buffer buf_rec for temp_xmllib_rec.
define buffer buf_rec-fld for temp_xmllib_rec-fld.


  find first buf_esys-pck-rcvd no-lock
    where buf_esys-pck-rcvd.esys-id = p-esys-id
      and buf_esys-pck-rcvd.db-num   = p-db-num
      and buf_esys-pck-rcvd.espr-cr-db-num   = p-cr-db-num
      and buf_esys-pck-rcvd.espr-pack-num = p-pack-num - 1
    no-error
  .
  if available buf_esys-pck-rcvd then do:
    assign
      v-prev-crc = buf_esys-pck-rcvd.espr-crc-pack
    .
  end.
  else do:
    assign
      v-prev-crc = "":U
    .
  end.

  case buf_ext-system.delivery-method:
    when integer({&esys-dm-exite-edi}) then do:
      /*ищем первую запись*/
      find first buf_temp_xmllib_rec no-error.
      if not available buf_temp_xmllib_rec
      or lookup(buf_temp_xmllib_rec.recname, "ORDRSP_,DESADV_,STATUS__") = 0
      then do:
        v-my-message = substitute("Неверный тип пакета &1"
                                    , p-pack-num
      , (if available buf_temp_xmllib_rec then buf_temp_xmllib_rec.recname else '')
                                  ) .
        /* {&display-message}. 09/VIII-2019 */
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      v-schema-name = substitute("exe/&1.xsd",buf_temp_xmllib_rec.recname).
    end.
    when integer({&esys-dm-contour-edi}) then do:
      /*ищем первую запись*/
      v-schema-name = entry (1, p-file-name, "_").
      if not can-find(first ub.clients
                      where ub.clients.obj-type = v-header-obj-type
                        and ub.clients.obj-code = v-header-obj-code
                        and ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num)
      then do:
        v-my-message = substitute("Адресат пакета &1 (&2&3) НЕИЗВЕСТЕН", p-pack-num, v-header-obj-type, v-header-obj-code) .
        /* {&display-message}. 09/VIII-2019 */
        delete object v-header-th no-error.
        return error v-my-message .
      end.
      v-pck-num = p-pack-num.
    end.
    when integer({&esys-dm-erp-1C-RN}) then do:
      v-pck-num = integer(entry(3, p-file-name, "_"))  no-error.
      find first buf_temp_xmllib_rec where
              buf_temp_xmllib_rec.recLevel = 0 no-error.
      /*ищем первую запись*/
      if available (buf_temp_xmllib_rec)
        then v-schema-name =   buf_temp_xmllib_rec.recName.
    end.
    when integer({&esys-dm-oracle-retail}) then do:
      v-esys-id = buf_ext-system.esys-id.
      find first buf_temp_xmllib_rec
           where buf_temp_xmllib_rec.recname = "Oracle_Retail" no-error.
      if not available buf_temp_xmllib_rec then do:
        v-my-message = substitute("Неверный тип пакета &1", p-pack-num, v-header-obj-code) .
        /* {&display-message}. 09/VIII-2019 */
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      for first buf_temp_xmllib_rec
          where buf_temp_xmllib_rec.recname = "header_",
           each buf_temp_xmllib_rec-fld
          where buf_temp_xmllib_rec-fld.rec-key = buf_temp_xmllib_rec.rec-key:
        case buf_temp_xmllib_rec-fld.fldname:
          when "obj-type" then do:
            v-header-obj-type = buf_temp_xmllib_rec-fld.fldvalue.
          end.
          when "obj-code" then do:
            assign
            v-header-obj-code = 0
            v-header-obj-code = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error.
          end.
          when "xsd" then do:
            v-schema-name = "exe/" + buf_temp_xmllib_rec-fld.fldvalue.
          end.
          when "date-from" then do:
            run set-exch-date-time in p-parent-handle ( input buf_temp_xmllib_rec-fld.fldvalue) no-error .
          end.
        end case.
      end.
      if not can-find (first ub.clients
                       where ub.clients.obj-type = v-header-obj-type
                         and ub.clients.obj-code = v-header-obj-code
                         and ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num)
      then do:
        v-my-message = substitute("Адресат пакета &1 (&2&3) НЕИЗВЕСТЕН", p-pack-num, v-header-obj-type, v-header-obj-code) .
        /* {&display-message}. 09/VIII-2019 */
        delete object v-header-th no-error.
        return error v-my-message.
      end.
      v-pck-num = p-pack-num.
    end. /* end_of esys-dm-oracle-retail */
    otherwise do:
  for first buf_temp_xmllib_rec where
          buf_temp_xmllib_rec.recname = "THheader",
        each buf_temp_xmllib_rec-fld where
         buf_temp_xmllib_rec-fld.rec-key = buf_temp_xmllib_rec.rec-key:
    case buf_temp_xmllib_rec-fld.fldname:
       when "THfilename" then do:
       end.
       when "THschema-name" then do:
         v-schema-name = buf_temp_xmllib_rec-fld.fldvalue.
       end.
       when "THimport-esys-id" then do:
         v-esys-id = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error .
       end.
       when "THpack-num" then do:
          v-pck-num = integer(buf_temp_xmllib_rec-fld.fldvalue) no-error.
       end.
       when "THprev-crc" then do:
          v-import-prev-crc = buf_temp_xmllib_rec-fld.fldvalue no-error.
       end.
    end case.
  end.
    end.
  end case.
  /* 14/II-2019 экземпляры для oracle-retail и для contour-edi перенесёны в вышестоящий case  
  if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail})
    or buf_ext-system.delivery-method = integer({&esys-dm-contour-edi}) then do:
    v-pck-num = p-pack-num.
    if not can-find(first ub.clients where
                         ub.clients.obj-type = v-header-obj-type
                     and ub.clients.obj-code = v-header-obj-code
                     and ub.clients.db-num = g#db-num)
    then do:
      &scop my-message substitute("Адресат пакета &1 (&2&3) НЕИЗВЕСТЕН" ~
                                  , v-pck-num ~
                                  , v-header-obj-type ~
                                  , v-header-obj-code)
      {&display-message}.
      delete object v-header-th no-error.
      return error.
    end.
  end.
  */
  if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})
     or buf_ext-system.delivery-method = integer({&esys-dm-contour-edi})
  then do:
    v-pck-num = p-pack-num.
  end.
  if v-pck-num <> p-pack-num
  and not (buf_ext-system.delivery-method = integer({&esys-dm-nnold}))
  then do:
    v-my-message = substitute("Номер пакета &1 в заголовке файла &2&5 не совпадает с номером пакета &3 для вн.системы '&4'"
                                 , v-pck-num
                                 , p-xml-file-name
                                 , p-pack-num
                                 ,buf_ext-system.esys-name
                                 , {&new-line}) .
    /* {&display-message}. 09/VIII-2019 */
    delete object v-header-th no-error.
    return error v-my-message.
  end.
  if buf_ext-system.imp-conf-send > 0  then do:
    if v-import-prev-crc <> v-prev-crc then do:
      v-my-message = substitute("&1. Ошибка приема! Пакет &2 сформирован в некорректной ВС&3" +
                                  "Ключ предыдущего пакета в файле (&4)&3не совпадает с ключом предыдущего пакета в БД (&5)"
                                  , vss-workfile
                                  , v-pck-num    
                                  , {&new-line} 
                                  ,v-import-prev-crc
                                  , v-prev-crc 
                                  ) .
      /* {&display-message}. 09/VIII-2019 */
      delete object v-header-th no-error.
      undo, return error v-my-message.
    end.
  end. /* buf_ext-system.imp-conf-wait > 0*/
  if buf_ext-system.delivery-method <> integer({&esys-dm-exite-edi})
    and buf_ext-system.delivery-method <> integer({&esys-dm-contour-edi})
    and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN})
  then do:
    assign
    v-pck-num = 0.
  end.
  find first buf_temp-param-name where
            buf_temp-param-name.schema-name = v-schema-name
       and  (buf_temp-param-name.esys-id = p-esys-id
            or
            buf_temp-param-name.esys-id = -1)
       no-error.
  if not available buf_temp-param-name then do:
    v-my-message = substitute("Не настроена обработка данных по схеме &1 для вн.системы &2"
                                 , v-schema-name
                                 ,buf_ext-system.esys-name ) .
    /* {&display-message}. 09/VIII-2019 */
    delete object v-header-th no-error.
    return error v-my-message.
  end.
    if buf_ext-system.delivery-method <> integer({&esys-dm-contour-edi})
     and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN}) then do:
      run get-gate-rec in this-procedure ( v-schema-name
                                          ,output v-gate-rec) no-error.
      if error-status:error then do:
        undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-schema-name).
      end.
      define variable v-longchar as longchar no-undo .
      v-longchar = ''.
      run get-gate-by-rec in this-procedure ( input v-gate-rec
                                            ,output v_dataseth
                                            ,input-output v-xmlh
                                            ,input-output v-longchar
                                            ) no-error.
      if error-status:error then do:
        v-my-message = substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4"
                                  , v-gate-rec
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ) .
        /* {&display-message}. 09/VIII-2019 */
        delete object v-header-th no-error.
        undo, return error v-my-message.
      end.
    end.
    if v-header-name <> '' then do:
  v-headerh = v-header-th:default-buffer-handle.
  find first buf_temp-xml-tables where
            buf_temp-xml-tables.tbl-name = v-headerh:table no-error.
  if not available buf_temp-xml-tables then do:
    v-insert-header = yes.
  create buf_temp-xml-tables.
  assign
  buf_temp-xml-tables.tbl-name = v-headerh:table
  buf_temp-xml-tables.tbl-handle_ = v-headerh
  buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
  buf_temp-xml-tables.order = -3
  buf_temp-xml-tables.gate-handle = v_dataseth
  buf_temp-xml-tables.gate-name = v-schema-name
  buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
  .
 end.
  else do:
    delete object v-header-th.
    v-headerh = buf_temp-xml-tables.table-handle_:default-buffer-handle.
  end.
  end. /*if v-header-name <> '' then do:*/
  if buf_ext-system.imp-conf-send > 0  then do:
    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-pckrcvd:table
    buf_temp-xml-tables.tbl-handle_ = v-pckrcvd
    buf_temp-xml-tables.table-handle_ = v-pckrcvd:table-handle
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = -2
    .

    create buf_temp-xml-tables.
    assign
    buf_temp-xml-tables.tbl-name = v-pcksent:table
    buf_temp-xml-tables.tbl-handle_ = v-pcksent
    buf_temp-xml-tables.table-handle_ = v-pcksent:table-handle
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
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
    buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
    buf_temp-xml-tables.gate-name = v_dataseth:name
    buf_temp-xml-tables.gate-handle_ = v_dataseth
    buf_temp-xml-tables.order = v_dataseth:num-buffers + 1
    .
  end.
  if v-insert-header = yes then do:

  run tmpreldf_get-relations in this-procedure ( input v_dataseth).
  /*пересортируем так чтобы header был первый*/
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
   if first(buf_temp-xml-tables.order) then do:
     glog = v_dataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   else do:
     glog = v_dataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   if error-status:error
   or not glog
   then do:
      v-my-message = substitute("Ошибка при создании заголовка XML файла:&1&2", {&new-line}, error-status:get-message(1) ) .
      /* {&display-message}. 09/VIII-2019 */
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      undo, return error v-my-message.
    end.
  end.
  run tmpreldf_set-relations in this-procedure ( input v_dataseth, input v_dataseth).
    run gbl/_tmpfile.p (
                      input ""
                    , input "xml"
                    , output v-schema-tmp-file) .

  assign
  glog = v_dataseth:WRITE-XMLSCHEMA( "FILE"
                                   , v-schema-tmp-file
                                   , yes /*lFormatted*/
                                   , ? /*cEncoding*/
                                    , no /*lMinSchema*/
                                   ) no-error .
  if error-status :error then do:
        v-my-message = substitute("Ошибка при создании временного файла xsd со схемой &1:&2&3"
                                    , v_dataseth:name
                                    , {&new-line}  
                                    , error-status:get-message(1) ) .
    /* {&display-message}. 09/VIII-2019 */
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    undo, return error v-my-message.
  end.

  end. /*  if v-insert-header = yes then do:*/
  else do:
    if buf_ext-system.delivery-method <> integer({&esys-dm-contour-edi})
     and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN})then do:
        run gbl/_tmpfile.p (
                            input ""
                          , input "xml"
                          , output v-schema-tmp-file) .
        COPY-LOB
        FROM  OBJECT v-longchar
        TO  FILE v-schema-tmp-file
        no-convert
        NO-ERROR .
        v-longchar = ''.
        if error-status :error then do:
            v-my-message = substitute("Ошибка при создании временного файла xsd со схемой &1:&2&3"
                                        , v_dataseth:name
                                        , {&new-line}  
                                        , error-status:get-message(1) ) .
          /* {&display-message}. 09/VIII-2019 */
          run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
          undo, return error v-my-message.
        end.
      end.
    end.
    if buf_ext-system.delivery-method <> integer({&esys-dm-contour-edi})
     and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN}) then do:
      assign
      v-rec-cnt = 0
      .
      ASSIGN
      glog = v_dataseth:read-xml( "file"
                                ,p-xml-file-name
                                ,"merge" /*cReadMode*/
                                ,v-schema-tmp-file /*schemalocation*/
                                ,? /*override filemapping*/
                                ,?  /*FieldTypeMapping*/
                                ,"strict" /*VerifySchemaMode*/
                                ) no-error .
      if error-status:error
      then do:
        v-my-message = substitute("Ошибка при чтении XML файла &1 данными через гейт &2:&3&4"
                                        , p-xml-file-name
                                        , v_dataseth:name
                                        , {&new-line}
                                        , error-status:get-message(1)) .

        /* {&display-message}. 09/VIII-2019 */
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail}) then do:
          run set-err-type in p-parent-handle ( input {&ora-err-type-structure}) no-error.
        end.
        undo, return error v-my-message.
      end.
       if not glog then do:
          v-my-message = substitute("Не прошел верификацию с помощью схемы &1 XML файл &2:&3&4&3&5"
                                        , v_dataseth:name
                                        , p-xml-file-name
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , error-status:get-message(2) ) .
       /* {&display-message}. 09/VIII-2019 */
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        os-delete value(v-schema-tmp-file).
        if buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail}) then do:
          run set-err-type in p-parent-handle ( input {&ora-err-type-structure}) no-error.
        end.
        undo, return error v-my-message.
      end.
    end.
  if buf_ext-system.delivery-method <>  integer({&esys-dm-exite-edi})
    and buf_ext-system.delivery-method <>  integer({&esys-dm-contour-edi})
    and buf_ext-system.delivery-method <>  integer({&esys-dm-erp-1C-RN})
  then do:
  case buf_ext-system.delivery-method:
    when integer({&esys-dm-oracle-retail}) then do:
      find first buf_temp-xml-tables where
                buf_temp-xml-tables.tbl-name = v-header-name
            and buf_temp-xml-tables.gate-handle_ = v_dataseth
                no-error.
    end.
    otherwise do:
  find first buf_temp-xml-tables where
                buf_temp-xml-tables.tbl-name = v-header-name
        and buf_temp-xml-tables.gate-handle_ = v_dataseth
            no-error.
    end.
  end case.
  if not available buf_temp-xml-tables then do:
     v-my-message = substitute("Не найден THHEADER или Header_ в XML файлe &1:&2&3"
                                    , p-xml-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)) .
    /* {&display-message}. 09/VIII-2019 */
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
  glog = buf_temp-xml-tables.tbl-handle_:find-first( "where true") no-error.
  if error-status:error
  or not glog
  or buf_temp-xml-tables.tbl-handle_:available = no then do:
     v-my-message = substitute("Не найдена запись THHEADER или Header_ в XML файлe &1:&2&3"
                                    , p-xml-file-name
                                    , {&new-line}
                                    , error-status:get-message(1)) .
    /* {&display-message}. 09/VIII-2019 */
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
  else do:
    case buf_ext-system.delivery-method:
      when integer({&esys-dm-nnold}) then do:
      v-pck-num = p-pack-num.
      buf_temp-xml-tables.tbl-handle_:buffer-field("THpack-num"):buffer-value = p-pack-num.
        buf_temp-xml-tables.tbl-handle_:buffer-field("THimport-esys-id"):buffer-value = p-esys-id.
      END.
      when integer({&esys-dm-oracle-retail}) then do:
        v-pck-num = p-pack-num.
      end.
      otherwise do:
        v-pck-num = buf_temp-xml-tables.tbl-handle_:buffer-field("THpack-num"):buffer-value.
        buf_temp-xml-tables.tbl-handle_:buffer-field("THimport-esys-id"):buffer-value = p-esys-id.
      end.
    end.
  end.
  end. /*if buf_ext-system.delivery-method <>  integer({&esys-dm-exite-edi})  then do:*/
  if buf_ext-system.imp-conf-send > 0
  or buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})
  then do:
    run get-xcnf_get-xcnf in this-procedure (
                                      input p-esys-id
                                     ,input p-db-num
                                     ,input g#db-num
                                     ,input p-pack-num
                                     ,input buf_ext-system.delivery-method
                                     ,buffer buf_temp-esys-pck-sent
                                     ,buffer buf_temp-esys-pck-rcvd
                                     ,buffer curr_temp-esys-pck-sent
                                     ,output v-rec-cnt
                                   ) no-error.
    if error-status :error then do:
     v-my-message = substitute("Ошибка при принятии подтверждений из ВС:&1&2&1&3"
                                 , {&new-line}
                                 , error-status:get-message(1)
                                 , return-value ) .
     /* {&display-message}. 09/VIII-2019 */
     run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
     os-delete value(v-schema-tmp-file).
     undo, return error v-my-message.
    end.
  end. /*if buf_ext-system.imp-conf-wait > 0  then do:*/
  assign
  v-rec-cnt = v-rec-cnt + 1 /*в нашем пакете только одна запись - зато большая*/
  .

  /*кусок кода который поможет если чо понять у нас читается в dataset или нет*/
  /*
  for each buf_temp-xml-tables:
    glog = buf_temp-xml-tables.tbl-handle:find-first( "where true") no-error.
    if buf_temp-xml-tables.tbl-handle:available then do:
       message
       buf_temp-xml-tables.tbl-handle:buffer-field(1):name
       buf_temp-xml-tables.tbl-handle:buffer-field(1):buffer-value view-as alert-box .
    end.
  end.
  */
  if buf_ext-system.delivery-method <> integer({&esys-dm-contour-edi})
   and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN}) then do:
    os-delete value(v-schema-tmp-file).
  end.

  &scop my-message v-my-message                            
  _rule-profile:
  for each buf_temp-param-name WHERE
         (buf_temp-param-name.esys-id = p-esys-id
         or
         buf_temp-param-name.esys-id = -1)
      and buf_temp-param-name.schema-name = v-schema-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    v-task = v-task + 1.
    find first buf_esys-pck-keys no-lock where
            buf_esys-pck-keys.esys-id = p-esys-id
        and buf_esys-pck-keys.db-num = p-db-num
        and buf_esys-pck-keys.espr-cr-db-num = g#db-num
        and buf_esys-pck-keys.espr-pack-num = v-pck-num
        and buf_esys-pck-keys.espr-prev-uniq-key = ''
        and buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                            , {&delim-par}
                                                            , buf_temp-param-name.call_id
                                                            , buf_temp-param-name.codex_id
                                                            , buf_temp-param-name.ruleset_id
                                                            , buf_temp-param-name.order_id)
        no-error.
    if available buf_esys-pck-keys then do:
      v-task-ok = v-task-ok + 1.
      next _rule-profile.
    end.
      case buf_temp-param-name.profile-type:
      when {&table_dis-card-type} then do:
        define variable v-field-list as character no-undo .
        define variable v-value-list as character no-undo .
        run gen-key-fv in this-procedure ( input buf_temp-param-name.call_id
                                          ,output v-field-list
                                          ,output v-value-list).
        run str/saledc.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&dct-proc_sale-xml-import}
          ,input integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
          ,input  entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
          ,input buf_temp-param-name.profile_id
            ,input 0 /*p-codex-id*/
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input ? /*doc-date - выставим внутри*/
          ,input ? /*fact-date - выставим внутри*/
          ,input ? /*cre-pay*/
          ,input 1 /*p-sign*/
          ,input 1 /* p-direction */
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id 
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 2 then do:
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимаетмя по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          undo _rule-profile, next _rule-profile.
        end.
      end.
     when {&table_cli-grp} then do:
        run str/cgrprum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&cli-grp-proc_xml-esys-import}
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимаетмя по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end.
      when {&table_clients} then do:
        run str/clisrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&clients-proc_xml-esys-import}
          ,input buf_temp-param-name.profile_id
            ,input buf_temp-param-name.codex_id /*p-codex-id*/
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимаетмя по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end.
      when {&edoc} then do:
        case buf_temp-param-name.ruleset_id:
            when {&edoc-proc_18_xml-esys-import_order_4} then do:
            assign
            v-process = {&edoc-proc_xml-esys-import_order}
            .
          end.
           when {&edoc-proc_18_xml-esys-import_rcv_8} then do:
              assign
              v-process = {&edoc-proc_xml-esys-import_rcv}
              .
            end.
            when {&edoc-proc_18_xml-esys-import_price-doc_12} then do:
            assign
            v-process = {&edoc-proc_xml-esys-import_price-doc}
            .
          end.
            when {&edoc-proc_18_xml-esys-import_trn-doc_16} then do:
            assign
            v-process = {&edoc-proc_xml-esys-import_trn-doc}
            .
          end.
            when {&edoc-proc_18_xml-esys-import_inv-doc_20} then do:
            assign
            v-process = {&edoc-proc_xml-esys-import_inv-doc}
            .
          end.
            when {&edoc-proc_18_xml-esys-import_contract_24}  then do:
            assign
            v-process = {&edoc-proc_xml-esys-import_contract}
            .
          end.
        end case.
        run str/edocrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input v-process
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}

                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3 профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимаетмя по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end.
      when {&thref} then do:
        run ref/threfrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&thref-proc_xml-esys-import}
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-file-name + {&delim-par} +
                 (if string(v_dataseth) = ? then p-xml-file-name else string(v_dataseth)) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2: профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимается по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end.
      when {&table_gds-grp} then do:
        run str/ggrprum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&gds-grp-proc_xml-esys-import}
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
              /*файл принимается по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end. /*when {&table_gds-grp} then do:*/
      when {&table_goods} then do:
        run str/goodsrum.p
          (
           input parparentproc
          ,input this-procedure :handle
          ,input p-log-handle
          ,input {&goods-proc_xml-esys-import}
          ,input buf_temp-param-name.profile_id
          ,input buf_temp-param-name.codex_id
          ,input buf_temp-param-name.ruleset_id
          ,input g#db-num
          ,input buf_temp-param-name.call_id
          ,input (
                 string(p-esys-id) + {&delim-par} +
                 p-xml-file-name + {&delim-par} +
                 string(v_dataseth) + {&delim-par} +
                 string(v-pck-num) + {&delim-par} +
                 p-log-file-name + {&delim-par} +
                 buf_temp-param-name.param-name + {&delim-par} +
                 buf_temp-param-name.schema-name + {&delim-par}
                  )
          ,input yes /*p-save*/
          ) no-error .
        if error-status:error then do:
          v-my-message = substitute("Ошибка при импорте данных по схеме &2:&3профайл правил &1&3&4&3&5"
                                      ,buf_temp-param-name.profile_id
                                      ,v-schema-name
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ) .
          {&display-message}.
          if buf_temp-param-name.ruleset_id = 5 then do:
            /*еще нет такого ruleset*/
            /*buf_esys-pck-keys должны быть заполнены выше*/
            /*файл принимаетмя по одной записи*/
            /*
            /*когда нибудь попробуем сохранить в esys-route сейчас не можем потому что надо писат в систему -esys-id a cr-rto.i не пускает*/
            run impxcbsh in this-procedure (  input p-esys-id
                                            ,input v-pck-num
                                            ,input v-gate-rec
                                            ,input v_dataseth
                                            ,buffer buf_temp-xml-tables
                                            ) no-error.*/
          end.
          next _rule-profile.
        end.
      end. /*when {&table_goods} then do:*/
      otherwise do:
        v-my-message = substitute("Неизвестный тип &1  профайла &2 для обработки данных по схеме &3"
                                      ,buf_temp-param-name.profile-type
                                    ,buf_temp-param-name.profile_id
                                    , v-schema-name) .
        {&display-message}.
        next _rule-profile.
      end.
    end case.
    v-task-ok = v-task-ok + 1.
    find first buf_esys-pck-keys no-lock where
            buf_esys-pck-keys.esys-id = p-esys-id
        and buf_esys-pck-keys.db-num = p-db-num
        and buf_esys-pck-keys.espr-cr-db-num = g#db-num
        and buf_esys-pck-keys.espr-pack-num = v-pck-num
        and buf_esys-pck-keys.espr-prev-uniq-key = ''
        and buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                            , {&delim-par}
                                                            , buf_temp-param-name.call_id
                                                            , buf_temp-param-name.codex_id
                                                            , buf_temp-param-name.ruleset_id
                                                            , buf_temp-param-name.order_id)
        no-error.
    if not available buf_esys-pck-keys then do:
      do transaction
      on error undo, return error
      :
        create buf_esys-pck-keys.
        assign
        buf_esys-pck-keys.esys-id = p-esys-id
        buf_esys-pck-keys.db-num = p-db-num
        buf_esys-pck-keys.espr-cr-db-num = g#db-num
        buf_esys-pck-keys.espr-pack-num = v-pck-num
        buf_esys-pck-keys.espr-prev-uniq-key = ''
        buf_esys-pck-keys.espr-uniq-key = substitute("&2&1&3&1&4&1&5"
                                                              , {&delim-par}
                                                              , buf_temp-param-name.call_id
                                                              , buf_temp-param-name.codex_id
                                                              , buf_temp-param-name.ruleset_id
                                                              , buf_temp-param-name.order_id)

        .
      end.
    end.
  end. /*  for each buf_temp-param-name ,*/
  v-rec-cnt = v-rec-cnt + 1
  .
    if valid-handle(v-headerh) then do:
  if v-headerh:available
  and v-headerh:table = "THheader"
  and v-headerh::THtotal-recs <> v-rec-cnt then do:
    v-my-message = substitute("Не совпадает количество считанных записей и ожидаемое количество :&1" + 
                                 "принято: &2&1"  + 
                                 "должно быть: &3" 
                                 ,{&new-line}
                                 ,v-rec-cnt
                                ,v-headerh::THtotal-recs) .
    /* {&display-message}. 09/VIII-2019 */
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error v-my-message.
  end.
end.
  if v-task = v-task-ok then do:
    /*пакет принят по всем получателям правилам*/
    if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})  then do:
      run get-xcnf_get-xcnf in this-procedure (
                                        input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num
                                      ,input p-pack-num
                                      ,input buf_ext-system.delivery-method
                                      ,buffer buf_temp-esys-pck-sent
                                      ,buffer buf_temp-esys-pck-rcvd
                                      ,buffer curr_temp-esys-pck-sent
                                      ,output v-rec-cnt
                                    ) no-error.
      if error-status :error then do:
        v-my-message = substitute("Ошибка при принятии подтверждений из ВС:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ) .
      /* {&display-message}. 09/VIII-2019 */
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      os-delete value(v-schema-tmp-file).
      undo, return error v-my-message.
      end.
    end. /*if buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})  then do:*/
    if buf_ext-system.imp-conf-send  = integer({&openxml-imp-conf-send})
    then do:
      run get-xcnf_set-xcnf in this-procedure (
                                       input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num /*p-cr-db-num*/
                                      ,input p-pack-num
                                      ,input v-rec-cnt
                                      ,input v-headerh
                                      ,buffer buf_temp-esys-pck-sent
                                      ,buffer buf_temp-esys-pck-rcvd
                                      ,buffer curr_temp-esys-pck-sent
                                    ) no-error.
    if error-status :error then do:
      v-my-message = substitute("Ошибка при выставлении подтверждений:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value ) .
      /* {&display-message}. 09/VIII-2019 */
      run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
      os-delete value(v-schema-tmp-file).
      undo, return error v-my-message.
    end.
    end.
    else do:
      /* get-xcnf_set0xcnf вызывается только отсюда; get-short-pack-name вызывается отсюда и из espcknum.p */
      run get-xcnf_set0xcnf in this-procedure (
                                       input p-esys-id
                                      ,input p-db-num
                                      ,input g#db-num
                                      ,input p-pack-num
                                      ,input buf_ext-system.delivery-method
                                      ,input v-rec-cnt
                                      ,input v-headerh
                                      )  no-error.

      if error-status :error then do:
        v-my-message = substitute("Ошибка при выставлении подтверждений:&1&2&1&3"
                                  , {&new-line} 
                                  , error-status:get-message(1)
                                  , return-value ) .
        /* {&display-message}. 09/VIII-2019 */
        run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
        os-delete value(v-schema-tmp-file).
        undo, return error v-my-message.
      end.
    end.
  end. /*if v-task = v-task-ok then do:*/
  for each buf_temp-esys-pck-sent  :
    delete buf_temp-esys-pck-sent .
  end.
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
  run send-to-cash in this-procedure no-error.
  return.
end. /*doe*/

procedure set-err-type :
define input parameter p-err-type as character no-undo .

do
on error undo, return error
:
  run set-err-type in p-parent-handle ( input p-err-type) no-error.
  if error-status:error then do:
    return error return-value .
  end.
end.

end procedure. /* set-err-type */