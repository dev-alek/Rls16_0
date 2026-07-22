block-level on error undo, throw.
/*

$Revision: 7b0cc5f31b3c, 1617, rls $
$Author: SSlivenko $
$Date: Tue Nov 06 04:41:38 2018 +0300 $
$Workfile: send-pay.p $
$Archive: str/send-pay.p $

пересылка кодов оплат на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/20/05
Author: Bakhtadze Natalya
Creation date: 09/20/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
/*по оплатам выборочно или все!*/
DEFINE INPUT PARAMETER rid-list as char no-undo.
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7b0cc5f31b3c, 1617, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:38 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-pay.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-pay.p $":U .
define variable vss-description as character no-undo init "Пересылка видов оплат на кассы".
define variable rdlist as int64 no-undo .
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ ref/cp-attr.i }
{ str/cp-isuse.i }

DEFINE VARIABLE kassa-rub-code as integer.
DEFINE VARIABLE ibmnalc as integer no-undo .
define variable multicurr as logical no-undo .
define variable conf-attr as character no-undo .
DEFINE VARIABLE conf-par as character no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE par-type as character no-undo.
DEFINE VARIABLE dopi as decimal no-undo.
DEFINE VARIABLE ii as integer no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-cp-is-use as logical no-undo .
define variable mariapayg as character no-undo .
define variable mariapayp as character no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по группе товара*/
define variable drcprank as character no-undo .
define variable v-record as character no-undo .
define variable v-found-maria-discnt as logical no-undo .
define temp-table tt-cash-pay no-undo like cash-pay 
index cdpay-code cdpay-code.

/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
procedure putc-5 :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter par-cash-num like ub.cash-desk.cash-num no-undo .
define input parameter par-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-pos-version like ub.cash-desk.version no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-index as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-plu as character no-undo .
define variable v-dop as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-cp-attr-code as character no-undo .
define variable attr-value as character no-undo .
define variable attr-type as character no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-skip-fields as integer no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-paymentetc as character no-undo .
define buffer BUF_DIS-RULE for UB.DIS-RULE.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.

&scop check-cp-is-use  if not cp-isuse ( input  ub.cash-pay.cdpay-code ~
                                 ,input  ub.cash-pay.curr-code         ~
                                 ,input  v-host-code                   ~
                                 ,input {&shop}                        ~
                                 ,input i-obj-code                     ~
                                 ,input v-cp-is-use                    ~
                                 ,input par-cash-num                   ~
                                 ,input par-pos-type )                 ~
                                 then next ~{&metka~}

  do
  on error undo, return error
  :
    if selective = 0 then do:
      _non-selective:
      FOR EACH ub.cash-pay where
              (par-pos-type <> {&cd-type-ibm} or ub.cash-pay.cdpay-code < 99):
&scop metka _non-selective
        {&check-cp-is-use}.
        { str/putc-5.i }
      END. /* FOR EACh cash-pay*/
    end.
    else do:

      if rid-list eq "*"
      then  do:
        create tt-cash-pay.
        tt-cash-pay.cdpay-code = ?.
        { str/putc-5.i &prefix = "tt-"} 
        delete tt-cash-pay.
      end.
       else
        _selective:
        DO ii = 1 to NUm-ENTRIES(rid-list):
        rdlist =  int64(entry(ii, rid-list)).
          FIND FIRST ub.cash-pay No-LOCK WHERE
                    recid(ub.cash-pay) = rdlist No-ERROR.

          IF avail ub.cash-pay then do:

          &scop metka _selective
          {&check-cp-is-use}.
            { str/putc-5.i }
          end.
        END.
       
    end.

  end.

end procedure. /* putc-5 */

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl5.i }

/*PROCEDURE SENDING.*/
{ str/cd-send5.i }

assign
log-file-name = p-log-file-name
.

{ gbl/hostcode.i {&shop} i-obj-code v-host-code }
if     action = "D" 
   and rid-list ne "*"
then do:
  message
  "Вы действительно хотите удалить с кассы записи от типах кассовых платежей?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.
if action = 'D':U then do:
  assign
  v-cp-is-use = no.
end.
if action <> 'D':U then do:
  run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  i-obj-code
      ,input  {&attr-cd-inf-send}
      ,input  {&attr-cd-inf-send_cp-is-use} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error
  then do:
    v-cp-is-use = v-value-logical.
    delete object v-tth.
  end.
  else do:
    delete object v-tth.
    return error return-value .
  end.
end.


RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке типов кассовых платежей на кассы  маг&1:&2&3 &4"
                         , i-obj-code
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сформированы файлы для касс объекта &1&2", {&shop}, i-obj-code)
                                                  ).