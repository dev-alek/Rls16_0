/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка типов-масок диск карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter i-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка типов-масок диск карт".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo .
define variable action     as character no-undo .
define variable choice as integer no-undo .
define variable v-rid-list AS CHARACTER NO-UNDO.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable ii as integer no-undo .
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE v-type as character no-undo .
define variable run-from as character no-undo.
define variable v-date-format as character no-undo .
define variable v-del-mrkt-cli as logical        no-undo .
define variable v-record as character no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по пост клиенту*/
define variable drdcrank as character no-undo .
define variable v-magia-kat-codes-rule as integer no-undo .


define buffer buf_dis-card-mask for ub.dis-card-mask.

{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ str/defc-cli.i " NEW SHARED " }
{ ref/dc-prop.i }
{ ref/discprop.i }
{ gbl/dct-algo.i }
{ gbl/windtfrm.i }
{ rul/propreft.i }
{ str/cash-c-i.i " " def }
{ gbl/getcntxt.i def }
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
{ gbl/disrules.i cash-desk }
{ ref/get-dpcn.i }

define temp-table temp-dis-card-mask no-undo
like ub.dis-card-mask.

/*вспомогат*/
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".

assign
p-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
no-error
.
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

define variable v-chk-act-host-code as integer   no-undo .
{ gbl/hostcode.i
  {&shop}
  abs(i-obj-code)
  v-chk-act-host-code
}

if action = "U"
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-clients_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    abs(i-obj-code)
    0
    0
    0
    true
    glog
  }
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-clients_deletion':U
    {&cntxt-object}
    v-chk-act-host-code
    {&shop}
    abs(i-obj-code)
    0
    0
    0
    true
    glog
  }
end.


if NOT glog then  return .
glog = yes.

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           (ub.cash-desk.pos-type = {&cd-type-IBM}
            AND
            ub.cash-desk.obj-code = i-obj-code)
           OR
           (ub.cash-desk.pos-type = {&cd-type-IBM-XML}
           AND
           ub.cash-desk.obj-code = i-obj-code)
            No-error.
IF not avail(ub.cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 масок карт реализуется только для касс &2 &3 "
                          , (if action = "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm}
                          , {&cd-type-ibm-xml}
                        )
                                        ).
  return.
end.

run gbl/d-askw.w (input "Выбор масок для пересылки",
            input ( (if action = "U"
                    then "Переслать на кассу"
                    else "Удалить с кассы" ) +
                    " информацию о масках карт"
                      ),
            input "|",
            input "Все имеющиеся в базе|Выборочно|Отказ от пересылки",
            input "||",
            input 1,
            input 3,
            output choice).
CASE choice:
  when 3 then return.
  when 2 then do:
    { gbl/hostcode.i p-obj-type i-obj-code v-host-code }
    run ref/dc-masks.w (
                       INPUT parparentproc
                      ,INPUT v-host-code
                      ,INPUT p-obj-type
                      ,INPUT i-obj-code
                      ,input "b-sel,b-mark":U
                      ,INPUT {&g___object}
                      ,INPUT "":U /*p-type*/
                      ,INPUT ? /*p-emitent-host-code*/
                      ,INPUT ? /*p-stts*/
                      ,input-output v-rid-list
                        ) NO-ERROR.
    if not error-status:error
    and v-rid-list <> "":U then do:
      _do:
      do ii = 1 to num-entries(v-rid-list):
        find first buf_dis-card-mask no-lock where
                  recid(buf_dis-card-mask) = integer(entry(ii, v-rid-list)) no-error .
        if num-entries(buf_dis-card-mask.mask) > 1
        and buf_dis-card-mask.use-on = integer({&dcm-only-th}) then do:
          if choice = 2 then do:
            assign
            v-view-log = yes.
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("!Ошибка при пересылке на кассу: Выбрана маска &1 использующаяся только в TH", buf_dis-card-mask.mask)
                                                  ).
          end.
          next _do.
        end.
        if available buf_dis-card-mask then do:
          create temp-dis-card-mask.
          buffer-copy buf_dis-card-mask to temp-dis-card-mask.
        end.
      end.
    end.
    else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не определен список масок для пересылки")
                                          ).
      return .
    end.
  end.
END CASE.

{ gbl/curr-r-b.i
  v-curr-r-b
}

/*PROCEDURE putc-cli.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-2.i }


/*PROCEDURE putc-dis-card-mask.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-20.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyc20.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen20.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &2&3 информации о типах-масках карт", p-obj-type, i-obj-code)
                                          ).

find first ub.shop no-lock where
          ub.shop.obj-code = abs(i-obj-code).
find first ub.sysconf no-lock where
          ub.sysconf.host-code = ub.shop.host-code.
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке информации о типах-масках карт на кассы &1&2"
                         , p-obj-type
                         , i-obj-code
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.

  finally :
      output to value(log-file-name) append. // если файла нет
      put skip.
      output close.
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
