/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересылка категорий налогов и ставок налогов на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает

def input param i-obj-code like ub.clients.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка категорий налогов и ставок налогов на кассу":U.
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable action as char no-undo.

{ str/defc-txn.i SHARED }
{ str/defc-txr.i SHARED }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }

/*значение параметра передавать на кассы налоги*/
define variable tax-cass as logical no-undo init no.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
DEFINE VARIABLE g#log as logical no-undo .
DEFINE VARIABLE x-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE x-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE x-obj-code like ub.clients.obj-code no-undo .

/*разбивать НДС по ставкам*/
define variable cd-vat                       as integer           no-undo .
/*список ссответсвтия кодов ставок налогов - категория налогов на кассе для cd-vat = 1*/
define variable cdtaxlst                     as character         no-undo .

def buffer shop-buffer for ub.shop.

FUNCTION convert-tax-code returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .

  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return integer(entry(2, entry(jj, p-cdtaxlst, ";"), "-":U)).
    end.
  end.

END FUNCTION.
FUNCTION convert-maria-tax-code-2 returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable v-return-value as integer no-undo .

  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return jj.
    end.
  end.
return 0.
END FUNCTION.


/*PROCEDURE putc-..*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-12.i }
{ str/putc-13.i }
{ str/putc-15.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyc12.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen12.i }


assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
action = entry(2, p-parameter, {&delim-par})
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


find first ub.shop no-lock where
           ub.shop.obj-code = i-obj-code no-error .
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  i-obj-code
    ,input  {&attr-cd-inf-send}
    ,input  {&attr-cd-inf-send_tax-cass} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error then
assign
tax-cass = v-value-logical
.
delete object v-tth.
if error-status:error or NOT tax-cass  then do:
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("В магазине &1 передача налогов на кассы не используется", i-obj-code)
                                       ).
end.

else do:

  FIND FIRST shop-buffer No-LOCK WHERE
            shop-buffer.obj-code = i-obj-code No-ERROR.
  if not avail shop-buffer then do:
      IF NOT g#news then
      message "Нет магазина " i-obj-code
      view-as alert-box ERROR.
      return error.
  end.

  RUN SENDING no-error.
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибки при отсылке информации по налогам на кассы  маг&1"
                          , i-obj-code
                          )
                                          ).

    assign
    v-view-log = yes
    .
    if not g#news then return error .
  end.
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
