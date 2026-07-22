block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Импорт файла XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/23/07
Author: Bakhtadze Natalya
Creation date: 12/23/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-xml-file-name as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-xsd-file as character no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input-output parameter v_dataseth as handle no-undo .
define input-output parameter v-xmlh as handle no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт файла XML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ rul/tempcxml.i "SHARED" }
/*должно быть шаред чтобы был доступ к temp-xml-tables глубоко внизу*/
{ gbl/gate-clb.i }
// { bge/tmpcxmlh.i } - 23/VIII-2018 подключается в составе getoxmlh.i
{ bge/getoxmlh.i }
{ gbl/xmlchar.i }
{ gbl/tmpreldf.i }

define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-headerh as handle no-undo .
define variable v-header-th as handle no-undo .
define variable v_locdataseth as handle no-undo .
define variable v-schema-name as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-pack-num as integer no-undo .
define variable v-schema-tmp-file as character no-undo .
define variable v-gate-rec as character no-undo .
define variable v-part-num as integer no-undo init 1.
define variable v-clob-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-pck-num                 as integer                  no-undo .
define variable v-rec-cnt     as integer   no-undo.
define variable v-xml-err as character no-undo .
define variable v-header-schema-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-header-rec as character no-undo .


define buffer buf_temp-xml-tables for temp-xml-tables.
define buffer buf_clob-data for ub.clob-data.
define buffer buf_temp_xmllib_rec for temp_xmllib_rec.
define buffer buf_temp_xmllib_rec-fld for temp_xmllib_rec-fld.

&glob display-message  run write-log in p-log-handle ( ~
          input 2 ~
        , input ~{&my-message~} ) ~

define frame imp-pck
p-xml-file-name label "Файл пакета" format "x(50)" skip
v-rec-cnt       label "Основных записей" format ">>>>>>>>>9" skip
with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета"
.


main-block:
do
on error undo, return error return-value
:

  assign
  v-xmlh = buffer buf_temp-xml-tables:handle:table-handle:default-buffer-handle
  .

  run gbl/filename.p (
                  input p-xml-file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .

  if error-status :error then do:
    &scop my-message substitute("Файл пакета &1 не найден" ~
                                 , p-xml-file-name ~
                                  )

    {&display-message}.
    undo, return error {&my-message}.
  end.
  /* будем искать имя схемы*/
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
  run getoxmlh in this-procedure ( input v-full-path
                                  ,input ? // или передать memptr в который загружен xml-файл  
                                  ,input v-headerh
                                  ,input -1 /*p-delivery-method - нет тут*/
                                   ) no-error.
  define buffer buf_rec for temp_xmllib_rec.
  define buffer buf_rec-fld for temp_xmllib_rec-fld.

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
         v-esys-id = integer(buf_temp_xmllib_rec-fld.fldvalue).
       end.
       when "THpack-num" then do:
         v-pack-num = integer(buf_temp_xmllib_rec-fld.fldvalue).
       end.
    end case.
  end.
  if p-esys-id <> 0
  and v-esys-id <> p-esys-id then do:
    &scop my-message substitute("Ожидался файл от ВС &1, в файле импорта указана ВС &2" ~
                                 , p-esys-id ~
                                 , v-esys-id ~
                                  )

    {&display-message}.
    return error {&my-message}.
  end.
  if p-pack-num <> 0
  and v-pack-num <> p-pack-num then do:
    &scop my-message substitute("Читается пакет № &1, в файле импорта у№ пакета указан как &2" ~
                                 , p-pack-num ~
                                 , v-pack-num ~
                                  )

    {&display-message}.
    return error {&my-message}.
  end.

  if v-schema-name <> p-xsd-file then do:
    &scop my-message substitute("В профайле &1 нет обработки данных по схеме &2" ~
                                 , p-profile-id ~
                                 , v-schema-name ~
                                  )

    {&display-message}.
    return error {&my-message}.
  end.
  assign
  v-pck-num = 0.
  run get-gate-rec in this-procedure ( v-schema-name
                                      ,output v-gate-rec) no-error.
  if error-status:error then do:
    undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", v-schema-name).
  end.
  define variable v-longchar as longchar no-undo .
  v-longchar = ?.
  run get-gate-by-rec in this-procedure ( input v-gate-rec
                                        ,output v_locdataseth
                                        ,input-output v-xmlh
                                        ,input-output  v-longchar
                                        ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2" ~
                               , v-gate-rec ~
                               , ~{&new-line~}, error-status:get-message(1) )
    {&display-message}.
    undo, return error {&my-message}.
  end.
  create buf_temp-xml-tables.
  assign
  buf_temp-xml-tables.tbl-name = v-headerh:table
  buf_temp-xml-tables.tbl-handle_ = v-headerh
  buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
  buf_temp-xml-tables.order = -3
  buf_temp-xml-tables.gate-handle = v_locdataseth
  buf_temp-xml-tables.gate-name = v-schema-name
  buf_temp-xml-tables.uniq-gate-rec = v-gate-rec
  .
  run tmpreldf_get-relations in this-procedure ( input v_locdataseth).
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
   if first(buf_temp-xml-tables.order) then do:
     glog = v_locdataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   else do:
     glog = v_locdataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
   end.
   if error-status:error
   or not glog
   then do:
      &scop my-message substitute("Ошибка при создании заголовка XML файла:&1&2", ~{&new-line~}, error-status:get-message(1) )
      {&display-message}.
      run gate-clear in this-procedure ( input v_locdataseth, input v-xmlh).
      undo, return error {&my-message}.
    end.
  end.
  run tmpreldf_set-relations in this-procedure ( input v_locdataseth, input v_locdataseth).
  run gbl/_tmpfile.p (
                      input ""
                    , input "xml"
                    , output v-schema-tmp-file) .

  assign
  glog = v_locdataseth:WRITE-XMLSCHEMA( "FILE"
                                   , v-schema-tmp-file
                                   , yes /*lFormatted*/
                                   , ? /*cEncoding*/
                                   , no /*lMinSchema*/
                                   ) no-error .
  if error-status :error then do:
        &scop my-message substitute("Ошибка при создании временного файла xsd со схемой &1:&2&3" ~
                                    , v_locdataseth:name ~
                                    , ~{&new-line~}   ~
                                    , error-status:get-message(1) )
    {&display-message}.
    run gate-clear in this-procedure ( input v_locdataseth, input v-xmlh).
    undo, return error {&my-message}.
  end.
  assign
  v-rec-cnt = 0
  .
  run gate-clear in this-procedure ( input v_locdataseth, input v-xmlh).
  for each buf_temp-xml-tables:
    delete buf_temp-xml-tables.
  end.
  run get-gate-by-file in this-procedure ( input v-schema-tmp-file
                                        ,input v-gate-rec
                                        ,output v_dataseth
                                        ,input-output v-xmlh) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно файлу схемы:&1&2&3&2&4" ~
                               , v-schema-tmp-file ~
                               , ~{&new-line~}, error-status:get-message(1), return-value  )
    {&display-message}.
    undo, return error {&my-message}.
  end.
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
      &scop my-message substitute("Ошибка при чтении XML файла &1 данными через гейт &2:&3&4" ~
                                    , p-xml-file-name ~
                                    , v-schema-name ~
                                    , ~{&new-line~}   ~
                                    , error-status:get-message(1))

    {&display-message}.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    undo, return error {&my-message}.
  end.
  if not glog then do:
    v-xml-err = error-status:get-message(1) + {&new-line} + error-status:get-message(2).
    &scop my-message substitute("Не прошел верификацию с помощью схемы &1 XML файл &2:&3&4&3&5" ~
                                    , v-schema-name ~
                                    , p-xml-file-name ~
                                    , ~{&new-line~}   ~
                                    , v-xml-err )
    {&display-message}.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error {&my-message}.
  end.
  find first buf_temp-xml-tables where
            buf_temp-xml-tables.tbl-name = "THheader"
        and buf_temp-xml-tables.gate-handle_ = v_dataseth
            no-error.
  if not available buf_temp-xml-tables then do:
     &scop my-message substitute("Не найден THHEADER в XML файлe &1:&2&3" ~
                                    , p-xml-file-name ~
                                    , ~{&new-line~}   ~
                                    , error-status:get-message(1))

    {&display-message}.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error {&my-message}.
  end.
  glog = buf_temp-xml-tables.tbl-handle_:find-first( "where true") no-error.
  if error-status:error
  or not glog
  or buf_temp-xml-tables.tbl-handle_:available = no then do:
     &scop my-message substitute("Не найдена запись THHEADER в XML файлe &1:&2&3" ~
                                    , p-xml-file-name ~
                                    , ~{&new-line~}   ~
                                    , error-status:get-message(1))

    {&display-message}.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error {&my-message}.
  end.
  assign
  v-rec-cnt = v-rec-cnt + 1 /*в нашем пакете только одна запись - зато большая*/
  .

  /*кусок кода который поможет если чо понять у нас читается в dataset или нет*/
  /*
  for each buf_temp-xml-tables:
    glog = buf_temp-xml-tables.tbl-handle:find-first( "where true") no-error.
    if buf_temp-xml-tables.tbl-handle:available then do:
       message
       string(buf_temp-xml-tables.tbl-handle_)
       string(buf_temp-xml-tables.table-handle_)
       buf_temp-xml-tables.tbl-handle:buffer-field(1):name
       buf_temp-xml-tables.tbl-handle:buffer-field(1):buffer-value view-as alert-box .
    end.
    else do:
       message
       string(buf_temp-xml-tables.tbl-handle_)
       string(buf_temp-xml-tables.table-handle_)
       "not avail"
       buf_temp-xml-tables.tbl-name view-as alert-box .

    end.
  end.
  */
  os-delete value(v-schema-tmp-file).
  v-xmlh = buffer buf_temp-xml-tables:handle:table-handle:default-buffer-handle.
  /*
  if v-headerh::THtotal-recs <> v-rec-cnt then do:
    &scop my-message  substitute("Не совпадает количество считанных записей и ожидаемое количество :&1" +  ~
                                 "принято: &2&1"  +  ~
                                 "должно быть: &3" ~
                                 ,~{&new-line~}  ~
                                 ,v-rec-cnt  ~
                                 ,v-headerh::THtotal-recs)


    {&display-message}.
    run gate-clear in this-procedure ( input v_dataseth, input v-xmlh).
    os-delete value(v-schema-tmp-file).
    undo, return error {&my-message}.
  end.
  */
end. /*doe*/