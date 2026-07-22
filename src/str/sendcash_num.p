/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка номера кассы - пускальник

Автор: Шкляр Елена
Дата создания: 09/09/05
Author: Shklyar Elena
Creation date: 09/09/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает

define input parameter i-obj-code like shop.obj-code no-undo.
define input parameter mode as char no-undo .
*/

/*"U' "D" "R" - справочник*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "пересылка номера кассы - пускальник".
{ cmp/vssrevis.i }

{ str/defc-csh.i "NEW SHARED" }
{ cmp/stf-list.i }
{ gbl/cur-time.i }
{ str/get-chk.i  NEW }
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
{ gbl/getcntxt.i def }


define variable choice        as integer   no-undo.
define variable cli-list      as character no-undo.
define variable kk            as integer   no-undo.
define variable callpoint     as char      no-undo.
define variable glog          as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log    as logical   no-undo .

define variable i-obj-code    like ub.clients.obj-code no-undo.
define variable mode          as character no-undo.
define variable v-work-place  as character no-undo .
DEFINE VARIABLE v-today       as date      no-undo .
DEFINE VARIABLE v-time        as integer   no-undo .

define variable cash-num      as character no-undo .
define variable reful         as integer   no-undo .
define variable cash-reful    as integer   no-undo .
define variable cmd           as character no-undo .
define variable ii            as integer   no-undo . 
define buffer buf_clients for ub.clients.
define buffer buf_staff   for ub.staff.
define variable v-xml-file as character no-undo .
define variable OS-time    as character no-undo .
define variable id         as character no-undo .
define buffer buf_db for ub.db.

assign

  i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
  cash-num   = entry(2, p-parameter, {&delim-par})
/*cash-reful = integer(entry(3, p-parameter, {&delim-par}))*/
/*reful = integer(entry(2, p-parameter, {&delim-par}))*/
no-error
  .
if error-status:error then 
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("Ошибка входных параметров &1:&2&3"
    , p-parameter
    , {&new-line}
    , error-status:get-message(1)
    )).
  v-view-log = yes.
  undo, return error .
end .
{ gbl/getcntxt.i get }

do ii = 1 to num-entries (cash-num,";"):
  for each ub.cash-desk NO-LOCK WHERE
    ub.cash-desk.db-num = g#db-num
    and ub.cash-desk.obj-code = i-obj-code
    and ub.cash-desk.cash-num = integer(entry(ii,cash-num,";"))
    and ub.cash-desk.pos-type = {&cd-type-ibm-xml}   
    and ub.cash-desk.cash-on:


    run xml-cd-filename in this-procedure (
      input out
      ,output v-xml-file-name
      ,output v-xml-file-name-path
      ,output v-log-file-name
      ,output v-locked
      ).
   
    assign
      v-obj-list = {&shop} + string(ub.cash-desk.obj-code)
      .
    v-xml-file = ibs.th.gbl.gbl-inipar:logDir + v-xml-file-name-path + "xml" .
   
    output stream stmxmlout to value( v-xml-file ) convert target "1251" append.
    put stream stmXMLOut unformatted 
      "<?xml version='1.0' encoding='windows-1251'?>".

    assign
      OS-time = string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
      .
    run bgelib-tag-open in this-procedure (
      1 /*iTagLevel*/
      ,"config" /*sTagName*/
      ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", v-xml-file-name, v-obj-list, (v-obj-list + "_":U + "касса" + string(ub.cash-desk.cash-num)), OS-time )/*sParValue*/
      ).
    run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "KassaNumber":U)).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(ub.cash-desk.cash-num), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "Номер кассы", input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Param").  
    run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "ShopNumber":U)).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(ub.cash-desk.obj-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "Номер магазина", input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Param").  
    run bgelib-tag-close( 1, "config" ).
    output stream stmxmlout close.

    assign
      log-file-name = 'get-chkf.log'.
      
    assign
      cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search (v-xml-file)
                      , (entry(1, ub.cash-desk.addr-path, {&delim-par}) + '://' + entry(2, ub.cash-desk.addr-path, {&delim-par}))
                      , "cashParNum.txt")
      .          
    os-command silent value (cmd) .        
    os-delete value( v-xml-file).
  end.
end.

for each ub.cash-desk NO-LOCK WHERE
  ub.cash-desk.db-num = g#db-num
  and ub.cash-desk.obj-code = i-obj-code
  and ub.cash-desk.cash-num = cash-reful
  and ub.cash-desk.pos-type = {&cd-type-ibm-xml}   
  and ub.cash-desk.cash-on:


  run xml-cd-filename in this-procedure (
    input out
    ,output v-xml-file-name
    ,output v-xml-file-name-path
    ,output v-log-file-name
    ,output v-locked
    ).
   
  assign
    v-obj-list = {&shop} + string(ub.cash-desk.obj-code)
    .
  v-xml-file = ibs.th.gbl.gbl-inipar:logDir + v-xml-file-name-path + "xml" .
   
  output stream stmxmlout to value( v-xml-file ) convert target "1251" append.
  put stream stmXMLOut unformatted 
    "<?xml version='1.0' encoding='windows-1251'?>".

  assign
    OS-time = string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    .
  run bgelib-tag-open in this-procedure (
    1 /*iTagLevel*/
    ,"config" /*sTagName*/
    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", v-xml-file-name, v-obj-list, (v-obj-list + "_":U + "касса" + string(ub.cash-desk.cash-num)), OS-time )/*sParValue*/
    ).
  run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "RfNumber":U)).
  run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(reful), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "RfNumber кассы", input 1 ).
  run bgelib-tag-close in this-procedure ( input 2, input "Param").  
  run bgelib-tag-close( 1, "config" ).
  output stream stmxmlout close.


  assign
    log-file-name = 'get-chkf.log'.
      
  assign
    cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search (v-xml-file)
                      , (entry(1, ub.cash-desk.addr-path, {&delim-par}) + '://' + entry(2, ub.cash-desk.addr-path, {&delim-par}))
                      , "cashParNum.txt")
    .          
  os-command silent value (cmd) .        
  os-delete value( v-xml-file).
end.

finally :
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("&1", {&new-line})
    ).
  define variable v-save-file-name as character no-undo .

  v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .

  // где смотрят файл и где его удаляют - не известно.
  // поэтому здесь мы его только копируем
  OS-APPEND value(log-file-name) value(v-save-file-name).
end finally .
