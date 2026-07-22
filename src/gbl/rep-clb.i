/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура для работы с CLOB-DATA типа report-xml

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/10/09
Author: Bakhtadze Natalya
Creation date: 07/10/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure rep-clb_fill-report-xml :
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field-name_ as character no-undo .
define input parameter p-dataseth as handle no-undo .
define output parameter p-db-num-list as character no-undo .
define output parameter p-int64-id-list as character no-undo .
define output parameter p-part-num-list as character no-undo .

define variable v-longchar as longchar no-undo .
define variable glog as logical no-undo .
define buffer buf_clob-bind for ub.clob-bin.
define buffer buf_clob-data for ub.clob-data.

for each buf_clob-bind no-lock where
          buf_clob-bind.uniq-key-rec = p-uniq-key-rec
      and buf_clob-bind.field-name_ = p-field-name_
      and buf_clob-bind.resource-type = {&lob-res-report-xml}
by buf_clob-bind.uniq-key-rec
by buf_clob-bind.field-name_
by buf_clob-bind.part-num:
  find first buf_clob-data no-lock where
            buf_clob-data.db-num = buf_clob-bind.db-num
        and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
  if not available buf_clob-data then do:
    undo, return error substitute("Отсутствует CLOB-DATA (БД &1 id &2) для имеющегося CLOB-BIND:&3" +
                                  "ресурс типа &4 объект &5 файл № &6"
                                  ,buf_clob-bind.db-num
                                  ,buf_clob-bind.int64-id
                                  ,{&new-line}
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ,buf_clob-bind.part-num) .
  end.
  v-longchar = ''.
  COPY-LOB FROM object buf_clob-data.cdata
  to OBJECT v-longchar NO-ERROR .
  assign
  p-part-num-list = p-part-num-list +
                    (if p-part-num-list = '' then '' else {&comma-char}) +
                    string(buf_clob-bind.part-num)
  p-db-num-list = p-db-num-list +
              (if p-db-num-list = '' then '' else {&comma-char}) +
              string(buf_clob-bind.db-num)
  p-int64-id-list = p-int64-id-list +
              (if p-int64-id-list = '' then '' else {&comma-char}) +
              string(buf_clob-bind.int64-id)
  .
  glog = p-dataseth:READ-XML("LONGCHAR"
                              ,v-longchar /*source*/
                              ,"append" /*cReadMode*/
                              ,? /*schemalocation*/
                              ,? /*lOverrideDefaultMapping*/
                              ,? /*cFieldTypeMapping*/
                              ,"LOOSE") no-error.
  v-longchar = ''.
  if error-status:error
  then do:
    undo, return error substitute("&1&2Ошибка при заполнении датасета данными&2" +
                                    "отчет ID &3 срез &4"
                                    ,vss-include-info{&vssseq}
                                    ,{&new-line}
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ).
  end.
  if not glog then do:
    undo, return error substitute("&1&2Ошибка при заполнении датасета данными&2" +
                                    "отчет ID &3 срез &4"
                                    ,vss-include-info{&vssseq}
                                    ,{&new-line}
                                  , p-uniq-key-rec
                                  , p-field-name_
                                  ).
  end.
end. /*for each buf_clob-bind no-lock where*/
v-longchar = ''.
end procedure. /* rep-clb_fill-report-xml */


procedure rep-clb_save-rep-xml :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field-name_ as character no-undo .
define input parameter p-part-num-list as character no-undo .
define input parameter p-clob-db-num-list as character no-undo .
define input parameter p-int64-id-list as character no-undo .
define input parameter p-locked-rec-handle as handle no-undo .
define input parameter p-descr as character no-undo .
define input parameter p-nws as logical no-undo .
define input parameter p-encoding as character no-undo .
define input parameter p-dataseth as handle no-undo .

define variable v-ii as integer no-undo .
define variable v-clob-db-num as integer no-undo .
define variable v-part-num as integer no-undo .
define variable v-int64-id as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-num-entries as integer no-undo .


do
on error undo, return error
:

  if p-part-num-list = "" then do:
    assign
    p-part-num-list = string(0)
    p-clob-db-num-list = ''
    p-int64-id-list = string(0)
    .
  end.
  do v-ii = 1 to num-entries(p-part-num-list):

    run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name).
    p-dataseth:write-xml("file"
                        ,v-file-name
                        ,yes /*formatted*/
                        ,(if p-encoding = "1251" then "windows-1251" else p-encoding) /*encoding*/
                        ,? /*schema-location*/
                        ,no /*write-schema*/
                        ,no /*min-schema*/
                        ).
    assign
    v-part-num = integer(entry(v-ii, p-part-num-list))
    v-clob-db-num = (if entry(v-ii, p-clob-db-num-list) = ''
                     then ?
                     else integer(entry(v-ii, p-clob-db-num-list)))
    v-int64-id = int64(entry(v-ii, p-int64-id-list))
    .
    run gbl/file2clb.p ( input (if v-clob-db-num = ?
                                then {&add-def}
                                else {&update})  /*p-mode*/
                        ,input ("override" +
                                (if p-nws = no
                                 then ({&comma-char} + string(no))
                                 else "")
                                )
                               /*p-clob-mode*/
                        ,input p-locked-rec-handle /*p-bh - для блокирования при записи*/
                        ,input p-uniq-key-rec
                        ,input p-field-name_
                        ,input p-descr
                        ,input-output v-part-num
                        ,input {&lob-res-report-xml} /*p-resource-type*/
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input v-file-name /*p-file*/
                        ,input p-encoding
                        ) no-error .
    if error-status:error then do:
      undo, return error substitute("&1&2Ошибка при сохранении в БД отчета ID &3 срез &4"
                                      ,vss-include-info{&vssseq}
                                      ,{&new-line}
                                    , p-uniq-key-rec
                                    , p-field-name_
                                    ).
    end.
    /*в новости само уйдет из триггера*/
    os-delete value(v-file-name).
  end.

end. /*doe*/

end procedure. /* rep-clb_save-rep-xml */

  /* $Workfile$ e n d */