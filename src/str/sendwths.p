/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Передача на кассу масок серийных МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/09/07
Author: Polina Gridchina
Creation date: 08/09/07

Input:

Output:

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Передача на кассу масок серийных МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/cdsnddef.i }
{ bge/bgelib.i }
{ gbl/getcntxt.i def }

&scop view-log   ~{ str/cdviewlg.i   ~
                   "'!!!При отсылке информации на кассы произошли ошибки!!!'" ~
                   "'send-cd.txt'" ~}   ~
                    return

define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-action as char no-undo .

define variable choice as integer no-undo.
define variable rid-list as char no-undo.
/*define variable v-view-log  as logical        no-undo .   */
/*define variable glog as logical no-undo .*/
/*define variable log-file-name as character no-undo init "sendwths.txt":U .*/
define variable v-host-code like ub.sysconf.host-code no-undo .


assign
v-obj-type = entry(1, p-parameter, {&delim-par})
v-obj-code = integer(entry(2, p-parameter, {&delim-par}))
v-action     = entry(3, p-parameter, {&delim-par})
no-error .
if error-status:error then do:
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
{ gbl/hostcode.i v-obj-type v-obj-code v-host-code }


FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           ub.cash-desk.pos-type = {&cd-type-IBM-XML}   AND
           ub.cash-desk.obj-code = v-obj-code
            No-error.
IF not avail(ub.cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 масок серийных МЦ реализуется только для касс &2 "
                          , (if v-action = "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm-xml}
                        )
                                        ).
      v-view-log = yes.
//      {&view-log}.
  undo, return .
end.

run gbl/d-askw.w (input "Выбор масок серийных МЦ для пересылки",
            input ( (if v-action = "U"
                      then "Переслать на кассу"
                      else "Удалить из кассы" ) + {&new-line} +
                              "информацию о типах кассовых платежей"
                              ),
            input "|",
            input "Все|Выборочно|Отказ от пересылки",
            input "||",
            input 1,
            input 3,
            output choice).
CASE choice:
  when 1 then do:
  end.
  when 2 then do:
      run ref/wths-ref.w
        (input parparentproc
        ,input "b-mark,b-sel":U
        ,input v-host-code
        ,input v-obj-type
        ,input v-obj-code
        ,input {&all}
        ,input 0
        ,input 0
        ,input-output rid-list
        ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не определен список масок для пересылки")
                                          ).
      assign
      v-view-log = yes.
//      {&view-log}.
      undo, return .
      end.
    if rid-list = "" then return.
  end.
  when 3 then do:
    return.
  end.
END CASE.
run str/sndwssh.p (parparentproc
               ,p-parent-handle
               ,p-log-handle
               ,v-obj-type
               ,v-obj-code
               ,rid-list
               ,v-action
                  ) no-error.
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "ошибка при отправке масок серийных МЦ на кассу по магазину &1&2&3&2&4"
                          , v-obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
  end.
  
  finally :
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
log-file-name not-delete }

    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
  