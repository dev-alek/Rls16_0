/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения  чтения чеков - требует { cmp/library.i }

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/05
Author: Bakhtadze Natalya
Creation date: 10/13/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/thbj-def.i }

&if "{1}" = "def" &then
{ cmp/library.i }
{ str/libchkvl.i }
define variable log-file-name as character no-undo init "get-chkf.log".

define stream ChkStream .
define stream InvStream.
DEFINE VARIABLE ss                         as   character             no-undo .
DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE ii                         as   integer               no-undo .
DEFINE VARIABLE bc-buf                     as   character             no-undo .
DEFINE VARIABLE b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-base-code                like ub.sysconf.base-code  no-undo .
DEFINE VARIABLE shop-type                  as   character             no-undo .
DEFINE VARIABLE shop-code                  as   integer               no-undo .
DEFINE VARIABLE chk-type_                  like ub.chk-doc.chk-type   no-undo .
DEFINE VARIABLE chk-date_                  like ub.chk-doc.chk-date   no-undo .
DEFINE VARIABLE chk-time_                  like ub.chk-doc.chk-time   no-undo .
DEFINE VARIABLE shift-date_                like ub.chk-doc.shift-date no-undo .
DEFINE VARIABLE shift-num_                 like ub.chk-doc.shift-num  no-undo .
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable shift-open-time_           as integer no-undo .
DEFINE VARIABLE z-num_                     like ub.chk-doc.z-number   no-undo.
DEFINE VARIABLE cash-rate_                 as decimal                 no-undo .
DEFINE VARIABLE cash-scale_                like ub.chk-doc.cash-scale no-undo .
DEFINE VARIABLE chk-num_                   like ub.chk-doc.chk-num    no-undo .
DEFINE VARIABLE AuthType_                  as integer  no-undo .
DEFINE VARIABLE qr-alchol_                 like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE CBCType_                   as integer  no-undo .
DEFINE VARIABLE CBCString_                 like ub.chk-gds-attr.line-num  no-undo .
DEFINE VARIABLE CBCBarcode_                like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE pay-desk_                  like ub.chk-doc.pay-desk   no-undo .
DEFINE VARIABLE cashier_                   like ub.chk-doc.cashier    no-undo .
DEFINE VARIABLE sales-man_                 like ub.chk-doc.sales-man  no-undo .
DEFINE VARIABLE d-card_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE cli-type_                  like ub.chk-doc.cli-type   no-undo .
DEFINE VARIABLE cli-code_                  like ub.chk-doc.cli-code   no-undo .
DEFINE VARIABLE d-mask_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE tot-d-pcnt                 like ub.chk-doc.src-d-pcnt no-undo .
DEFINE VARIABLE doc-num_                   like ub.chk-doc.doc-num    no-undo .
DEFINE VARIABLE doc-num2_                   like ub.chk-doc.doc-num2  no-undo .
DEFINE VARIABLE num-str_                   as   integer               no-undo .
/*глобальный тип чека в спуле* - стринг от цифры */
DEFINE VARIABLE gbl-type                   as   character             no-undo .
/*глобальный тип чека в спуле* - до аннуляции*/
DEFINE VARIABLE prev-gbl-type              as   character             no-undo .
/*касса по умолчанию*/
define variable dflt-cd                    as   character             no-undo .
/*разделять смешанные чеки (ТОВАРЫ+УСЛУГИ) сразу после приема*/
DEFINE VARIABLE split-check                as   logical               no-undo init no .
/*текущая касса*/
DEFINE VARIABLE current-pay-desk           as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
/*курс нац вал из шапки чека*/
/*DEFINE VARIABLE naz-rate                   as   decimal               no-undo .*/
/*для раскладки строчки*/
DEFINE VARIABLE time-oper_                 like ub.chk-gds.time-oper  no-undo .
DEFINE VARIABLE t-c-d                      as   decimal               no-undo .
DEFINE VARIABLE pass-gds_                  like ub.chk-gds.pass-gds   no-undo .
DEFINE VARIABLE pump_                      like ub.chk-gds.pump       no-undo .
DEFINE VARIABLE nozzle_                    as   integer               no-undo .
DEFINE VARIABLE place_                     as   integer               no-undo .
DEFINE VARIABLE pl-code_                   as   integer               no-undo .
DEFINE VARIABLE road-tax_                  as   decimal               no-undo .
DEFINE VARIABLE curr-string-qnty           as   decimal               no-undo .
DEFINE VARIABLE sum-from-check             as   decimal               no-undo .
DEFINE VARIABLE discnt-from-check          as   decimal               no-undo .
DEFINE VARIABLE units-rate                 as   decimal               no-undo .
DEFINE VARIABLE units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE cass-rate                  as   decimal               no-undo .
DEFINE VARIABLE rate-por                   as   integer               no-undo .
DEFINE VARIABLE bank-rate_                 as   decimal               no-undo .
DEFINE VARIABLE bank-scale_                as   integer               no-undo .
DEFINE VARIABLE pass-pay_                  like ub.chk-pay.pass-pay   no-undo .
DEFINE VARIABLE pay-card_                  like ub.chk-pay.pay-card   no-undo .
DEFINE VARIABLE exist                      as   logical init TRUE     no-undo .
DEFINE VARIABLE mc-exist                   as   logical init TRUE     no-undo .
DEFINE VARIABLE price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE sub-d                      like ub.chk-doc.sub-discnt    no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE mc-for-chk-type            as   character             no-undo init "".
DEFINE VARIABLE prev-code                  like ub.chk-doc.doc-code      no-undo init "".
DEFINE VARIABLE mc-prev-code               like ub.chk-doc.doc-code    no-undo init "".
DEFINE VARIABLE pay_code                   like ub.cash-pay.cdpay-code     no-undo .
DEFINE VARIABLE curr_code                  like ub.cash-pay.curr-code    no-undo .
DEFINE VARIABLE pay-type                   as   character             no-undo .
DEFINE VARIABLE cstCode                    as   character             no-undo .
DEFINE VARIABLE cstValue                   as   decimal               no-undo .

DEFINE VARIABLE tot_sum                    as   decimal               no-undo .
DEFINE VARIABLE curr-chk-type              as   character             no-undo .
DEFINE VARIABLE mc-curr-chk-type           like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .

define variable v-curr-r-b                as character               no-undo .
/*номер строки товара*/
DEFINE VARIABLE lng                        as   integer               no-undo .
/*номер строки оплаты*/
DEFINE VARIABLE lnp                        as   integer               no-undo .
/*номер строки учета наличности*/
DEFINE VARIABLE lnc                        as   integer               no-undo .
/*сумма по первым строк товара на которые распространяется абс скидка на итог с учетом этой скидки*/
DEFINE VARIABLE netto-for-sub-d           as    decimal               no-undo .
DEFINE VARIABLE accum-src-for-sub-d       as    decimal               no-undo .
/*суммы брутто и нетто*/
define variable netto-sum_                as    decimal               no-undo .
define variable brutto-sum_               as    decimal               no-undo .
/*номер строки скидки*/
DEFINE VARIABLE lng-sub-d                 as   integer               no-undo .
/*счетчик скидок*/
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
/*брутто-чек*/
define variable v-src-tot-doc             as decimal                 no-undo .
/*идентификатор чека */
define variable chk-id_                   as character               no-undo .
DEFINE VARIABLE v-path                    as character               no-undo .
DEFINE VARIABLE v-full-path               as character               no-undo .
DEFINE VARIABLE v-file-name               as character               no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character               no-undo .
DEFINE VARIABLE v-file-name-ext           as character               no-undo .
DEFINE VARIABLE v-error-message           as longchar                no-undo .
define buffer buf_shift-cash for ub.shift-cash .

&if "{2}" <> "update" &then
&glob error-in-file-format                                                   ~
  if file_ begins "<?xml" then                                               ~
    v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300). ~
  else                                                                       ~
    v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) + ~
      ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300). ~
  if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ". ~
  run write-log-and-file in p-log-handle (                                   ~
        input 1                                                              ~
      , input log-file-name                                                  ~
      , input 1                                                              ~
      , input v-error-message                                                ~
                                      ).                                     ~
       assign                                                                ~
       p-view-log = yes                                                      ~
      exist = yes                                                            ~
      mc-exist = yes                                                         ~
      .                                                                      ~
      return.
&endif
{ str/libbcrcn.i      }
{ str/pos_context.i tt-wd  }
{ str/pos_context.i temp-table get-chkc_context  }
/*{ gbl/gbclcode.i }*/

&endif

&if "{1}" = "run" &then
&if "{2}" = "" &then
&scop p-obj-type p-obj-type
&else
&scop p-obj-type {2}
&endif
&if "{3}" = "" &then
&scop p-obj-code p-obj-code
&else
&scop p-obj-code {3}
&endif

FUNCTION convert-discount returns integer
                                          ( input p-disc-reason as integer
                                          , input p-disc-type  as integer
                                          , input p-line-type as integer) :
define variable v-disc-type as integer no-undo .
if p-line-type = integer({&discnt-gds})
or p-line-type = integer({&discnt-unknown})
then do:
  if p-disc-type = 0  /*неизв*/
  or p-disc-type = 1  /*ручн*/
  or p-disc-type = 2  /*станд*/
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-line-type = integer({&discnt-total})
or p-line-type = integer({&discnt-sub-total}) then do:
  if p-disc-type = 101 /*ручн*/
  or p-disc-type = 102 /*сумма*/
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-disc-reason <> 0 then do:
  CASE p-disc-reason:
    when 0 then do:
    /*неопределено*/
      return integer({&discnt-t-unknown}).
    end.
    when 1 then do:
      return integer({&discnt-t-season}).
    end.
    when 2 then do:
      return integer({&discnt-t-d-card}).
    end.
    when 3 or when 15 then do:
      return integer({&discnt-t-promo}).
    end.
    when 4 then do:
      return integer({&discnt-t-qnty}).
    end.
    when 5 then do:
      return integer({&discnt-t-categ}).
    end.
    when 6 then do:
      return integer({&discnt-t-time}).
    end.
    when 7 then do:
      return integer({&discnt-t-manual}).
    end.
    when 8
    or
    when 9
    or
    when 10
    then do:
      return integer({&discnt-t-cashloyal}).
    end.
    when 11
    then do:
      return integer({&discnt-t-cashround}).
    end.
    when 13
    then do:
      return integer({&discnt-t-bonuscard}).
    end.
    when 16 then do:
      return integer({&discnt-t-petrolcoupon}).
    end.    
  END CASE.
end.
CASE p-disc-type:
  when 0 then do:
  /*неопределено*/
    return integer({&discnt-t-unknown}).
  end.
  when 1 then do:
    return integer({&discnt-t-manual}).
  end.
  when 2 then do:
    return integer({&discnt-t-std}).
  end.
  when 3 then do:
    return integer({&discnt-t-qnty}).
  end.
  when 4 then do:
    return integer({&discnt-t-categ}).
  end.
  when 5 then do:
    return integer({&discnt-t-d-card}).
  end.
  when 6 then do:
    return integer({&discnt-t-time}).
  end.
  when 7 then do:
    return integer({&discnt-t-d-mask}).
  end.
  when 8 then do:
    return integer({&discnt-t-round}).
  end.
  when 9 then do:
    return integer({&discnt-t-template}).
  end.
  when 101 then do:
    return integer({&discnt-t-manual}).
  end.
  when 102 then do:
    return integer({&discnt-t-sum}).
  end.
  when 103 then do:
    return integer({&discnt-t-d-card}).
  end.
  when 104 then do:
    return integer({&discnt-t-sum}).
  end.
  when 105 then do:
    return integer({&discnt-t-d-card}).
  end.
  when 106 then do:
    return integer({&discnt-t-d-card}).
  end.
END CASE.

END FUNCTION.

run get-general-parameters in this-procedure .

procedure get-general-parameters :

define buffer buf_get-chkc_context for get-chkc_context.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  for each buf_get-chkc_context:
    delete buf_get-chkc_context.
  end.

  create buf_get-chkc_context.

  { str/libchkvl_create-context.i
   ~{&p-obj-type~}
   ~{&p-obj-code~}
   "buffer buf_get-chkc_context:handle"
   no-error
   }
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_get-chkc_context.
  assign
  buf_get-chkc_context.parparentproc = parparentproc
  buf_get-chkc_context.p-log-handle = p-log-handle
  buf_get-chkc_context.tt-wd-bh     = buffer tt-wd:handle
  .
  release buf_get-chkc_context.
  find first get-chkc_context.
end.

end procedure. /* get-general-parameters */

&endif

/* $Workfile$ e n d */