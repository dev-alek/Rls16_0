block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bon1-1.p $
$Archive: cus/r-bon1-1.p $

Отчет Начисление и списание бонусов -лист 1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/06
Author: Bakhtadze Natalya
Creation date: 09/21/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-schema-code as integer no-undo .
define input parameter p-cdpay-code as integer no-undo .
define input parameter p-curr-code as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bon1-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-bon1-1.p $":U .
define variable vss-description as character no-undo init "Отчет Начисление и списание бонусов -лист 1".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i  }
{ gbl/prn-lib.i "shared" }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cus/r-bon1df.i "SHARED" }

define variable pol1 as character no-undo .  /*товар*/
define variable pol2 as character no-undo .  /*дата время*/
define variable pol3 as character no-undo . /*дата смены номер смены*/
define variable pol4 as character no-undo . /*чек*/
define variable pol5 as character no-undo . /*номер карты*/
define variable pol6 as character no-undo . /*тип операции*/
define variable pol7 as character no-undo . /*товар*/
define variable pol8 as decimal   no-undo . /*кол-во*/
define variable pol9 as decimal   no-undo . /*цена*/
define variable pol10 as decimal  no-undo . /*стоимость*/
define variable pol11 as decimal  no-undo . /*оплачено*/
define variable pol12 as decimal  no-undo . /*начислено бонусов*/
define variable pol13 as character  no-undo . /*оператор*/
define buffer buf_temp-bon1 for temp-bon1.
define buffer item_temp-bon1 for temp-bon1.
define buffer op_temp-bon1 for temp-bon1.
define buffer obj_temp-bon1 for temp-bon1.
define buffer buf_temp-bon1-gds for temp-bon1-gds.
define buffer buf_temp-bon1-cashier for temp-bon1-cashier.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.

&scop All-Pol13 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13
&scop All-Pol13-xm pol1 {&tabulation} pol2 {&tabulation} pol3 {&tabulation} pol4 {&tabulation} pol5 {&tabulation} pol6 {&tabulation} pol7 {&tabulation} pol8 {&tabulation} pol9 {&tabulation} pol10 {&tabulation} pol11 {&tabulation} pol12 {&tabulation} pol13

{ cus/r-bon1.i proc-def }

DEFINE FRAME FRAME-1
pol1 column-label "1":c12 format "X(12)"
pol2 column-label "2":c17 format "X(17)"
pol3 column-label "3":c11 format "X(11)"
pol4 column-label "4":c20 format "X(20)"
pol5 column-label "5":c9 format "X(9)"
pol6 column-label "6":c14 format "X(14)"
pol7 column-label "7":c20 format "X(20)"
pol8 column-label "8":c10 format "->>,>>9.99"
pol9 column-label "9":c11 format ">>>,>>9.99"
pol10 column-label "10":c15 format "->>>,>>>,>>9.99"
pol11 column-label "11":c15 format "->>>,>>>,>>9.99"
pol12 column-label "12":c15 format "->>>,>>>,>>9.99"
pol13 column-label "13":c18 format "X(18)"
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

{ cus/r-bon1.i r-bon-1-1 }

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
  by buf_temp-bon1.item-type
  by buf_temp-bon1.item-name
  by buf_temp-bon1.op-code
  by buf_temp-bon1.chk-date
  by buf_temp-bon1.chk-time :
    if first-of(buf_temp-bon1.item-name) then do:
      display stream PrnLibStream
      buf_temp-bon1.item-name @ pol1
      WITH FRAME FRAME-1
      .
      DOWN STREAM PrnLibStream
      with frame frame-1.
      {&PutExcel}
      buf_temp-bon1.item-name
      skip.
    end. /*if first-of(temp-bon1.item-name) then do:*/
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

    display stream PrnLibStream
    (string(buf_temp-bon1.chk-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.chk-time, "HH:MM:SS")) @ pol2
    (string(buf_temp-bon1.shift-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.shift-name, "X(2)")) @ pol3
    buf_temp-bon1.doc-code @ pol4
    buf_temp-bon1.d-card @ pol5
    (if buf_temp-bon1.op-code = 1
     then "Бонус (безнал)"
     else "Бонус (нал)") @ pol6
     buf_temp-bon1-gds.gds-name @ pol7
     buf_temp-bon1.src-qnty @ pol8
     buf_temp-bon1.src-price @ pol9
     (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty) @ pol10
     buf_temp-bon1.src-sum @ pol11
     buf_temp-bon1.discnt-value-abs @ pol12
     buf_temp-bon1-cashier.obj-name @ pol13
    WITH FRAME FRAME-1
    .
    DOWN STREAM PRnLibStream
    with frame frame-1.

    {&PutExcel}
    {&tabulation}
    (string(buf_temp-bon1.chk-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.chk-time, "HH:MM:SS")) {&tabulation}
    (string(buf_temp-bon1.shift-date, "99.99.99") + {&space-char} + string(buf_temp-bon1.shift-name, "X(2)")) {&tabulation}
    buf_temp-bon1.doc-code {&tabulation}
    buf_temp-bon1.d-card {&tabulation}
    (if buf_temp-bon1.op-code = 1
     then "Бонус (безнал)"
     else "Бонус (нал)") {&tabulation}
     buf_temp-bon1-gds.gds-name {&tabulation}
     buf_temp-bon1.src-qnty {&tabulation}
     buf_temp-bon1.src-price {&tabulation}
     (buf_temp-bon1.src-price * buf_temp-bon1.src-qnty) {&tabulation}
     buf_temp-bon1.src-sum {&tabulation}
     buf_temp-bon1.discnt-value-abs {&tabulation}
     buf_temp-bon1-cashier.obj-name
     skip.
    if last-of (buf_temp-bon1.item-name) then do:
      underline stream PrnLibstream
      {&All-Pol13}
      with frame frame-1 .
      DOWN STREAM PRnLibStream
      with frame frame-1.

      find first item_temp-bon1 no-lock where
                item_temp-bon1.obj-type = buf_temp-bon1.obj-type
            and item_temp-bon1.obj-code = buf_temp-bon1.obj-code
            and item_temp-bon1.item-type = buf_temp-bon1.item-type
            and item_temp-bon1.item-name = buf_temp-bon1.item-name
            and item_temp-bon1.gds-code = -1
            and item_temp-bon1.op-code = 1 no-error.
      DOWN STREAM PRnLibStream
      with frame frame-1.
      display stream PrnLibStream
      "Итого" @ pol1
      buf_temp-bon1.item-name @ pol2
      "Бонус (безнал)" @ pol6
      (if available item_temp-bon1
       then item_temp-bon1.src-qnty
       else 0.0)  @ pol8
      (if available item_temp-bon1
       then item_temp-bon1.src-sum
       else 0.0) @ pol11
      WITH FRAME FRAME-1.
      DOWN STREAM PrnLibStream
      with frame frame-1.

      {&PutExcel}
      "Итого" {&tabulation}
      buf_temp-bon1.item-name {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      "Бонус (безнал)" {&tabulation}
      {&tabulation}
      (if available item_temp-bon1
       then item_temp-bon1.src-qnty
       else 0.0)  {&tabulation}
       {&tabulation}
       {&tabulation}
      (if available item_temp-bon1
       then item_temp-bon1.src-sum
       else 0.0) {&tabulation}
       skip.
      find first item_temp-bon1 no-lock where
                item_temp-bon1.obj-type = buf_temp-bon1.obj-type
            and item_temp-bon1.obj-code = buf_temp-bon1.obj-code
            and item_temp-bon1.item-type = buf_temp-bon1.item-type
            and item_temp-bon1.item-name = buf_temp-bon1.item-name
            and item_temp-bon1.gds-code = -1
            and item_temp-bon1.op-code = 2 no-error.
      display stream PrnLibStream
      "Итого" @ pol1
      buf_temp-bon1.item-name @ pol2
      "Бонус (нал)" @ pol6
      (if available item_temp-bon1
       then item_temp-bon1.src-qnty
       else 0.0)  @ pol8
      (if available item_temp-bon1
       then item_temp-bon1.src-sum
       else 0.0) @ pol11
      (if available item_temp-bon1
      then item_temp-bon1.discnt-value-abs
      else 0.0) @ pol12
      WITH FRAME FRAME-1.
      DOWN STREAM PrnLibStream
      with frame frame-1.
      {&PutExcel}
      "Итого" {&tabulation}
      buf_temp-bon1.item-name {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      "Бонус (нал)" {&tabulation}
      {&tabulation}
      (if available item_temp-bon1
       then item_temp-bon1.src-qnty
       else 0.0)  {&tabulation}
       {&tabulation}
       {&tabulation}
      (if available item_temp-bon1
       then item_temp-bon1.src-sum
       else 0.0) {&tabulation}
      (if available item_temp-bon1
      then item_temp-bon1.discnt-value-abs
      else 0.0)
      skip.
      if last(buf_temp-bon1.item-name) then do:
        underline stream PrnLibstream
        {&All-Pol13}
        with frame frame-1 .
        DOWN STREAM PRnLibStream
        with frame frame-1.
        for each item_temp-bon1 where
                item_temp-bon1.obj-type = obj-list.obj-type
            and item_temp-bon1.obj-code = obj-list.obj-code
            and item_temp-bon1.gds-code = -1
            and item_temp-bon1.op-code = 0
            and item_temp-bon1.item-type > 0
        break
        by item_temp-bon1.obj-type
        by item_temp-bon1.obj-code
        by item_temp-bon1.item-type
        by item_temp-bon1.item-name:
            display stream PrnLibStream
            "Итого" @ pol1
            item_temp-bon1.item-name @ pol2
            item_temp-bon1.src-qnty  @ pol8
            item_temp-bon1.src-sum @ pol11
            item_temp-bon1.discnt-value-abs @ pol12
            WITH FRAME FRAME-1.
            DOWN STREAM PRnLibStream
            with frame frame-1.
            {&PutExcel}
            "Итого" {&tabulation}
            item_temp-bon1.item-name {&tabulation}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            item_temp-bon1.src-qnty  {&tabulation}
            {&tabulation}
            {&tabulation}
            item_temp-bon1.src-sum {&tabulation}
            item_temp-bon1.discnt-value-abs
            skip.
        end.
        underline stream PrnLibstream
        {&All-Pol13}
        with frame frame-1 .
        DOWN STREAM PRnLibStream
        with frame frame-1.

        for each op_temp-bon1 where
                op_temp-bon1.obj-type = obj-list.obj-type
            and op_temp-bon1.obj-code = obj-list.obj-code
            and op_temp-bon1.gds-code = -1
            and op_temp-bon1.item-type = 0
            and op_temp-bon1.item-name = '':U
            and op_temp-bon1.op-code > 0
        by op_temp-bon1.obj-type
        by op_temp-bon1.obj-code
        by op_temp-bon1.item-type
        by op_temp-bon1.item-name:
            display stream PrnLibStream
            "Итого" @ pol1
            obj-list.obj-name @ pol2
            (if op_temp-bon1.op-code = 1
            then "Бонус (безнал)"
            else "Бонус (нал)") @ pol6
            op_temp-bon1.src-qnty  @ pol8
            op_temp-bon1.src-sum @ pol11
            op_temp-bon1.discnt-value-abs @ pol12
            WITH FRAME FRAME-1.
            DOWN STREAM PRnLibStream
            with frame frame-1.
            {&PutExcel}
            "Итого" {&tabulation}
            obj-list.obj-name {&tabulation}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            (if op_temp-bon1.op-code = 1
            then "Бонус (безнал)"
            else "Бонус (нал)") {&tabulation}
            {&tabulation}
            op_temp-bon1.src-qnty  {&tabulation}
            {&tabulation}
            {&tabulation}
            op_temp-bon1.src-sum {&tabulation}
            op_temp-bon1.discnt-value-abs
            skip.
        end.
        underline stream PrnLibstream
        {&All-Pol13}
        with frame frame-1 .
        DOWN STREAM PRnLibStream
        with frame frame-1.

        find first obj_temp-bon1 where
                obj_temp-bon1.obj-type = obj-list.obj-type
            and obj_temp-bon1.obj-code = obj-list.obj-code
            and obj_temp-bon1.gds-code = -1
            and obj_temp-bon1.item-type = 0
            and obj_temp-bon1.item-name = '':U
            and obj_temp-bon1.op-code = 0
            no-error.
        display stream PrnLibStream
        "Итого" @ pol1
        obj-list.obj-name @ pol2
        (if available obj_temp-bon1
         then obj_temp-bon1.src-qnty
         else 0) @ pol8
        (if available obj_temp-bon1
        then obj_temp-bon1.src-sum
        else 0) @ pol11
        (if available obj_temp-bon1
        then obj_temp-bon1.discnt-value-abs
        else 0) @ pol12
        WITH FRAME FRAME-1.
        DOWN STREAM PRnLibStream
        with frame frame-1.
        {&PutExcel}
        "Итого" {&tabulation}
        obj-list.obj-name {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        (if available obj_temp-bon1
        then obj_temp-bon1.src-qnty
        else 0) {&tabulation}
        {&tabulation}
        {&tabulation}
        (if available obj_temp-bon1
        then obj_temp-bon1.src-sum
        else 0) {&tabulation}
        (if available obj_temp-bon1
        then obj_temp-bon1.discnt-value-abs
        else 0)
        skip.
      end. /*if last*temp-bon1.item-name*/
    end. /*if last-of(temp-bon1.item-name) then do:*/
  end. /*for each buf_temp-bon1*/
end.  /*for each obj-list.*/