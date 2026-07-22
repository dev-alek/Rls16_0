block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bon1-2.p $
$Archive: cus/r-bon1-2.p $

Отчет Начисление и списание бонусов -лист 2,3

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/06
Author: Bakhtadze Natalya
Creation date: 09/21/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-schema-code as integer no-undo .
define input parameter p-cdpay-code as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define input parameter p-sheet-num as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bon1-2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-bon1-2.p $":U .
define variable vss-description as character no-undo init "Отчет Начисление и списание бонусов -лист 2,3".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i  }
{ gbl/prn-lib.i "shared" }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cus/r-bon1df.i "SHARED" }

define variable pol2 as character no-undo .  /*дата время*/
define variable pol3 as character no-undo . /*дата смены номер смены*/
define variable pol4 as character no-undo . /*чек*/
define variable pol5 as character no-undo . /*номер карты*/
define variable pol7 as character no-undo . /*товар*/
define variable pol8 as decimal   no-undo . /*кол-во*/
define variable pol9 as decimal   no-undo . /*цена*/
define variable pol10 as decimal  no-undo . /*стоимость*/
define variable pol11n as decimal  no-undo . /*оплачено наличными*/
define variable pol11b as decimal  no-undo . /*оплачено бонусами*/
define variable pol12 as decimal  no-undo . /*начислено бонусов*/
define variable pol13 as character  no-undo . /*оператор*/
define variable acc-sum as decimal no-undo . /*сумма стоимостей*/
define variable acc-pay-sumn as decimal no-undo . /*сумма оплач налом*/
define variable acc-pay-sumb as decimal no-undo . /*сумма оплач безналом*/
define variable acc-discnt-value-abs as decimal no-undo . /*сумма начсиленных бонусов*/
define variable d-acc-sum as decimal no-undo . /*сумма стоимостей*/
define variable d-acc-pay-sumn as decimal no-undo . /*сумма оплач налом*/
define variable d-acc-pay-sumb as decimal no-undo . /*сумма оплач безналом*/
define variable d-acc-discnt-value-abs as decimal no-undo . /*сумма начсиленных бонусов*/

define buffer buf_temp-bon1 for temp-bon1.
define buffer item_temp-bon1 for temp-bon1.
define buffer op_temp-bon1 for temp-bon1.
define buffer obj_temp-bon1 for temp-bon1.
define buffer buf_temp-bon1-gds for temp-bon1-gds.
define buffer buf_temp-bon1-cashier for temp-bon1-cashier.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.

&scop All-Pol13 pol2 pol3 pol4 pol5 pol7 pol8 pol9 pol10 pol11n pol11b pol12 pol13
&scop All-Pol13-xm pol2 {&tabulation} pol3 {&tabulation} pol4 {&tabulation} pol5 {&tabulation} pol7 {&tabulation} pol8 {&tabulation} pol9 {&tabulation} pol10 {&tabulation} pol11n {&tabulation} pol11b {&tabulation} pol12 {&tabulation} pol13

{ cus/r-bon1.i proc-def }

DEFINE FRAME FRAME-1
pol2 column-label "1":c17 format "X(17)"
pol3 column-label "2":c11 format "X(11)"
pol4 column-label "3":c20 format "X(20)"
pol5 column-label "4":c9 format "X(9)"
pol7 column-label "5":c20 format "X(20)"
pol8 column-label "6":c10 format "->>,>>9.99"
pol9 column-label "7":c11 format ">>>,>>9.99"
pol10 column-label "8":c15 format "->>>,>>>,>>9.99"
pol11n column-label "9":c15 format "->>>,>>>,>>9.99"
pol11b column-label "10":c15 format "->>>,>>>,>>9.99"
pol12 column-label "11":c15 format "->>>,>>>,>>9.99"
pol13 column-label "12":c18 format "X(18)"
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

{ cus/r-bon1.i r-bon-1-2 }

form header
 skip(4)
{&header-text1}
with frame TopFrameSystem width {&DOS_CW_2} page-top no-labels no-box.


view stream PrnLibStream frame TopFrameSystem.



for each obj-list no-lock:
  for each buf_temp-bon1 where
          buf_temp-bon1.obj-type = obj-list.obj-type
      and buf_temp-bon1.obj-code = obj-list.obj-code
      and buf_temp-bon1.level = 0
  break
  by buf_temp-bon1.obj-type
  by buf_temp-bon1.obj-code
  by buf_temp-bon1.chk-date
  by buf_temp-bon1.chk-time :
    if first-of( buf_temp-bon1.obj-code) then do:
      assign
      acc-sum = 0.0
      acc-discnt-value-abs = 0.0
      acc-pay-sumn = 0.0
      acc-pay-sumb = 0.0
      .
    end.
    if first-of( buf_temp-bon1.chk-date)
    and p-sheet-num = 3
    then do:
      assign
      d-acc-sum = 0.0
      d-acc-discnt-value-abs = 0.0
      d-acc-pay-sumn = 0.0
      d-acc-pay-sumb = 0.0
      .

      display stream PrnLibStream
      substitute("Дата: &1", string(buf_temp-bon1.chk-date, "99.99.99")) @ pol2
      WITH FRAME FRAME-1
      .
      DOWN STREAM PRnLibStream
      with frame frame-1.

      {&PutExcel}
      substitute("Дата: &1", string(buf_temp-bon1.chk-date, "99.99.99"))
      skip.
    end.
    find first buf_temp-bon1-gds where
              buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code no-error.
    if not available buf_temp-bon1-gds then do:
      find first buf_goods no-lock where
              buf_goods.gds-code = buf_temp-bon1.gds-code no-error.
      create buf_temp-bon1-gds.
      assign
      buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code
      buf_temp-bon1-gds.gds-name = (if available buf_goods
                                    then buf_goods.gds-name
                                    else substitute("Неизвестный товар &1", buf_temp-bon1.gds-code))
      .
    end.
    find first buf_temp-bon1-cashier where
              buf_temp-bon1-cashier.cashier-psn-code = buf_temp-bon1.cashier-psn-code no-error.
    if not available buf_temp-bon1-cashier then do:
      find first buf_clients no-lock where
              buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_temp-bon1.cashier-psn-code no-error.
      create buf_temp-bon1-cashier.
      assign
      buf_temp-bon1-cashier.cashier-psn-code = buf_temp-bon1.cashier-psn-code
      buf_temp-bon1-cashier.obj-name = (if available buf_clients
                                    then buf_clients.obj-name
                                    else substitute("Неизвестный кассир чел&1", buf_temp-bon1.cashier-psn-code))
      .
    end.
    if buf_temp-bon1.op-code = 1 then do:
      assign
      pol11n = 0
      pol11b = buf_temp-bon1.pay-sum
      .
    end.
    if buf_temp-bon1.op-code = 2 then do:
      assign
      pol11n = buf_temp-bon1.pay-sum
      pol11b = 0
      .
    end.

    display stream PrnLibStream
    (string(buf_temp-bon1.chk-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.chk-time, "HH:MM:SS")) @ pol2
    (string(buf_temp-bon1.shift-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.shift-name, "X(2)")) @ pol3
    buf_temp-bon1.doc-code @ pol4
    buf_temp-bon1.d-card @ pol5
     buf_temp-bon1-gds.gds-name @ pol7
     buf_temp-bon1.src-qnty @ pol8
     buf_temp-bon1.src-price @ pol9
     (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty) @ pol10
     /*нал*/
     pol11n
     pol11b
     buf_temp-bon1.discnt-value-abs @ pol12
     buf_temp-bon1-cashier.obj-name @ pol13
    WITH FRAME FRAME-1
    .
    DOWN STREAM PRnLibStream
    with frame frame-1.
    {&PutExcel}
    (string(buf_temp-bon1.chk-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.chk-time, "HH:MM:SS")) {&tabulation}
    (string(buf_temp-bon1.shift-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.shift-name, "X(2)")) {&tabulation}
    buf_temp-bon1.doc-code {&tabulation}
    buf_temp-bon1.d-card {&tabulation}
     buf_temp-bon1-gds.gds-name {&tabulation}
     buf_temp-bon1.src-qnty {&tabulation}
     buf_temp-bon1.src-price {&tabulation}
     (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty) {&tabulation}
     /*нал*/
    (if buf_temp-bon1.op-code = 1
     then "-"
     else string(buf_temp-bon1.pay-sum, "-999,999,999.99")) {&tabulation}
     /*безнал*/
    (if buf_temp-bon1.op-code = 2
     then "-"
     else string(buf_temp-bon1.pay-sum, "-999,999,999.99")) {&tabulation}
     buf_temp-bon1.discnt-value-abs {&tabulation}
     buf_temp-bon1-cashier.obj-name
     skip.
     assign
     acc-sum = acc-sum + (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty)
     acc-discnt-value-abs = acc-discnt-value-abs + buf_temp-bon1.discnt-value-abs
     acc-pay-sumn = acc-pay-sumn +  (if buf_temp-bon1.op-code = 1 /*безнал*/
                                    then 0
                                    else buf_temp-bon1.pay-sum)
     acc-pay-sumb = acc-pay-sumb +  (if buf_temp-bon1.op-code = 2 /*безнал*/
                                    then 0
                                    else buf_temp-bon1.pay-sum)
     d-acc-sum = d-acc-sum + (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty)
     d-acc-discnt-value-abs = d-acc-discnt-value-abs + buf_temp-bon1.discnt-value-abs
     d-acc-pay-sumn = d-acc-pay-sumn +  (if buf_temp-bon1.op-code = 1 /*безнал*/
                                    then 0
                                    else buf_temp-bon1.pay-sum)
     d-acc-pay-sumb = d-acc-pay-sumb +  (if buf_temp-bon1.op-code = 2 /*безнал*/
                                    then 0
                                    else buf_temp-bon1.pay-sum)

     .
     if last-of( buf_temp-bon1.chk-date)
     and p-sheet-num = 3
     then do:
        display stream PrnLibStream
        substitute("Итого за &1", string(buf_temp-bon1.chk-date, "99.99.99")) @ pol2
        acc-sum @ pol10
        acc-pay-sumn @ pol11n
        acc-pay-sumb @ pol11b
        acc-discnt-value-abs @ pol12
        WITH FRAME FRAME-1
        .
        DOWN STREAM PRnLibStream
        with frame frame-1.
        {&PutExcel}
        substitute("Итого за &1", string(buf_temp-bon1.chk-date, "99.99.99")) {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        acc-sum {&tabulation}
        acc-pay-sumn {&tabulation}
        acc-pay-sumb {&tabulation}
        acc-discnt-value-abs
        skip.
     end.

     if last-of( buf_temp-bon1.obj-code) then do:
        display stream PrnLibStream
        "Итого по отчету" @ pol2
        acc-sum @ pol10
        acc-pay-sumn @ pol11n
        acc-pay-sumb @ pol11b
        acc-discnt-value-abs @ pol12
        WITH FRAME FRAME-1
        .
        DOWN STREAM PRnLibStream
        with frame frame-1.
        {&PutExcel}
        "Итого по отчету" {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        acc-sum {&tabulation}
        acc-pay-sumn {&tabulation}
        acc-pay-sumb {&tabulation}
        acc-discnt-value-abs
        skip.
     end.
  end. /*for each buf_temp-bon1*/
end.  /*for each obj-list.*/