block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doc-kass.p $
$Archive: bge/doc-kass.p $

Экспорт расхода товаров по чекам

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
      p-obj-type  - тип объекта
      p-obj-code  - код объекта
      p-date      - дата
      p-out-file  - имя файла (XML) вывода с путем без расширени
      p-log-file  - полное имя файла (LOG) для записи событий
      p-EDT       - hanndle окна вывода информации
*/
DEF INPUT PARAM p-obj-type     AS CHAR    NO-UNDO.
DEF INPUT PARAM p-obj-code     AS INTEGER NO-UNDO.
DEF INPUT PARAM p-date         AS DATE    NO-UNDO.
DEF INPUT PARAM p-out-file     AS CHAR    NO-UNDO.
DEF INPUT PARAM p-log-file     AS CHAR    NO-UNDO.
DEF INPUT PARAM p-EDT          AS HANDLE  NO-UNDO.
DEF INPUT PARAM p-CNT          AS HANDLE  NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-kass.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-kass.p $":U .
define variable vss-description as character no-undo init "Экспорт расхода товаров по чекам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ bge/bge-xml.i }
&SCOP OperProd  "es"
&SCOP OperVozvr "rs"

define variable v-counter       as integer no-undo.
define variable v-inkas-exists  as logical no-undo.

define buffer buf_inkas     for ub.inkas.
define buffer buf_chk-doc   for ub.chk-doc.
define buffer buf_chk-gds   for ub.chk-gds.
define buffer buf_bar-code  for ub.bar-code.
define buffer buf_goods     for ub.goods.
define buffer buf_chk-pay   for ub.chk-pay.

do
on error undo, return error
:
ASSIGN
  v-counter       = 0
  v-inkas-exists = NO
.

DEF TEMP-TABLE temp-kass NO-UNDO
  FIELD cass-num   LIKE ub.chk-doc.pay-desk
  FIELD oper-num   AS CHAR
  FIELD obj-type   LIKE ub.inkas.obj-type
  FIELD obj-code   LIKE ub.inkas.obj-code
  index pk is primary unique cass-num oper-num
.
DEF TEMP-TABLE temp-kass-pay NO-UNDO
  FIELD cass-num   LIKE ub.chk-doc.pay-desk
  FIELD oper-num   AS CHAR
  FIELD pay-code   LIKE ub.inkas-pay.pay-code
  FIELD curr-code  LIKE ub.inkas-pay.curr-code
  FIELD tot-base   LIKE ub.inkas-pay.tot-base
  FIELD tot-rubl   LIKE ub.inkas-pay.tot-rubl
  FIELD tot-sum    LIKE ub.inkas-pay.tot-sum
  index pk is primary unique cass-num oper-num pay-code curr-code
.

DEF TEMP-TABLE temp-kass-goods NO-UNDO
  FIELD cass-num     LIKE ub.chk-doc.pay-desk
  FIELD oper-num     AS CHAR
  FIELD gds-code     LIKE ub.goods.gds-code
  FIELD tot-qnty     LIKE ub.chk-gds.doc-qnty
  FIELD tot-sum      LIKE ub.chk-doc.tot-doc
  index pk is primary unique cass-num oper-num gds-code
.

/*DEF TEMP-TABLE temp-kass-goodsVozvr NO-UNDO*/
/*  FIELD cass-num   LIKE chk-doc.pay-desc*/
/*  FIELD gds-code   LIKE bar-code.gds-code*/
/*  FIELD tot-qnty   LIKE chk-gds.doc-qnty*/
/*  FIELD tot-sum    LIKE chk-doc.tot-doc*/
/*.*/

RUN wp-XMLWriteLog(p-log-file, 0, "&Line").
RUN wp-XMLWriteLog(p-log-file, 1, "XML - Вывод операций по кассам").
/*---START--------- Заполнение temp-table ---------------------*/
FOR EACH buf_inkas NO-LOCK
   WHERE buf_inkas.doc-date = p-date
     AND buf_inkas.obj-type = p-obj-type
     AND buf_inkas.obj-code = p-obj-code
     AND buf_inkas.status_ = {&fact}
:
  IF NOT AVAILABLE buf_inkas
  THEN RUN wp-XMLWriteLog(p-log-file, 1, "Нет записей INKAS за дату " + STRING(p-date)).
  ELSE DO:

    IF NOT v-inkas-exists
    THEN DO:
      ASSIGN v-inkas-exists = YES.
      RUN wp-XMLWriteEDT( p-EDT, 4, "Дата " + STRING(p-date) + ". Заполнение таблиц для кассовых операций...").
    END.
    _chk-doc:
    FOR EACH buf_chk-doc NO-LOCK
      WHERE  buf_chk-doc.out-code = buf_inkas.inkas-code
    :

      if buf_chk-doc.correct = no then next.
      if LOOKUP(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      find first temp-kass no-lock
           where temp-kass.cass-num = buf_chk-doc.pay-desk
           and   temp-kass.oper-num = (if buf_chk-doc.netto >= 0 then {&operprod} else {&opervozvr})
      no-error.
      IF NOT AVAILABLE temp-kass THEN
      DO:
        CREATE temp-kass.
        ASSIGN
          temp-kass.cass-num = buf_chk-doc.pay-desk
          temp-kass.oper-num = (IF buf_chk-doc.netto >= 0 THEN {&OperProd} ELSE {&OperVozvr})
          temp-kass.obj-type = buf_inkas.obj-type
          temp-kass.obj-code = buf_inkas.obj-code
        .
      END.

      FOR EACH buf_chk-gds NO-LOCK
         WHERE buf_chk-gds.doc-code = buf_chk-doc.doc-code
      :
          ASSIGN v-counter = v-counter + 1.
          RUN wp-XMLWriteCNT(p-CNT, "Товаров: " + STRING(v-counter, "zzzzz9")).
          IF v-counter MOD 10 = 0 THEN PROCESS EVENTS.
/*          PROCESS EVENTS.*/
          FIND FIRST buf_bar-code NO-LOCK
               WHERE buf_bar-code.b-code = buf_chk-gds.b-code
          .
          FIND FIRST buf_goods    NO-LOCK
               WHERE buf_goods.gds-code = buf_bar-code.gds-code
          .
          IF buf_chk-doc.netto >= 0
          THEN DO:                /* Продажа */
                run update-temp-kass-goods in this-procedure ( input {&OperProd}, input 1 ).
          END.
          ELSE DO:               /* Возврат */
                run update-temp-kass-goods in this-procedure ( input {&OperVozvr}, input -1 ).
          END.
      END.

      FOR EACH buf_chk-pay NO-LOCK
         WHERE buf_chk-pay.doc-code = buf_chk-doc.doc-code
      :
          ASSIGN v-counter = v-counter + 1.
          RUN wp-XMLWriteCNT(p-CNT, "Оплат: " + STRING(v-counter, "zzzzz9")).
          IF v-counter MOD 10 = 0 THEN PROCESS EVENTS.
          IF buf_chk-doc.netto >= 0
          THEN DO:                /* Продажа */
                run update-temp-kass-pay in this-procedure ( input {&OperProd}, input 1 ).
          END.
          ELSE DO:               /* Возврат */
                run update-temp-kass-pay in this-procedure ( input {&OperVozvr}, input -1 ).
          END.
      END.
    END.
/*          ASSIGN temp-kass.tot-sum = temp-kass.tot-sum  + chk-doc.tot-doc*/
/*  скидки           temp-kass.discnt-sum = temp-kass.discnt-sum + chk-doc.discnt.*/
/*  "чистая" сумма   xNettoSum = xNettoSum + chk-doc.netto.*/
/*
  без касс

    brutto-sum = brutto-sum + inkas.tot-doc.
    discnt-sum = discnt-sum + inkas.discnt.
    netto-sum = netto-sum + inkas.netto.
*/
  END.
END.
/*---END----------- Заполнение temp-table ---------------------*/
/*---START--------- Вывод в XML ---------------------*/
OUTPUT STREAM stmXMLOut TO VALUE( p-out-file + "xm1" ) CONVERT TARGET "1251" APPEND.
FOR EACH temp-kass
:
  RUN wp-XMLTagOpen( 2, "operation", "").
  RUN wp-XMLTagPut( 3, "referenceNo", "", 1 ).
  RUN wp-XMLTagPut( 3, "dateDoc", STRING(p-date,"99.99.9999"), 0 ).
  RUN wp-XMLTagPut( 3, "organization", temp-kass.cass-num, 0 ).
  RUN wp-XMLTagPut( 3, "objType", temp-kass.obj-type, 0 ).
  RUN wp-XMLTagPut( 3, "objCode", temp-kass.obj-code, 0 ).
/*  RUN wp-XMLTagPut(3, "organization", temp-kass.obj-type + STRING(temp-kass.obj-code), 0).*/
  RUN wp-XMLTagPut( 3, "codeOperation", temp-kass.oper-num, 0 ).
  RUN wp-XMLWriteEDT( p-EDT, 4,
      "Касса " + STRING( temp-kass.cass-num ) + " объекта " + p-obj-type + STRING( p-obj-code )
      + ". Операция " + temp-kass.oper-num ).

  run wp-xmltagopen( 3, "docPay", "" ).
  for each temp-kass-pay
     where temp-kass-pay.cass-num = temp-kass.cass-num
       and temp-kass-pay.oper-num = temp-kass.oper-num
  break by temp-kass-pay.pay-code
        by temp-kass-pay.curr-code
  :
      if first-of( temp-kass-pay.pay-code )
      then do:
          run wp-xmltagopen( 4, "pay", "" ).
          run wp-XMLTagPut( 5, "payCode", string( temp-kass-pay.pay-code ), 0 ).
      end.
      run wp-xmltagopen( 5, "curr", "" ).
      run wp-XMLTagPut( 6, "currCode", string( temp-kass-pay.curr-code ), 0 ).
      run wp-XMLTagPut( 6, "totBase", string( temp-kass-pay.tot-base ), 0 ).
      run wp-XMLTagPut( 6, "totRubl", string( temp-kass-pay.tot-rubl ), 0 ).
      run wp-XMLTagPut( 6, "totSum",  string( temp-kass-pay.tot-sum ),  0 ).
      run wp-xmltagclose( 5, "curr" ).
      if last-of( temp-kass-pay.pay-code )
      then do:
          run wp-xmltagclose( 4, "pay" ).
      end.
  end.
  run wp-xmltagclose( 3, "docPay" ).
  FOR EACH temp-kass-goods
     WHERE temp-kass-goods.cass-num = temp-kass.cass-num
       AND temp-kass-goods.oper-num = temp-kass.oper-num
  :
        run wp-XMLTagOpen( 3, "lineDoc", "").
        run wp-XMLTagPut( 4, "good", string(temp-kass-goods.gds-code), 0 ).
        run wp-XMLTagPut( 4, "quantity", string(temp-kass-goods.tot-qnty), 0 ).
        run wp-xmltagopen( 4, "docSum","" ).
        run wp-XMLTagPut( 5, "sum", string(ABSOLUTE(temp-kass-goods.tot-sum)), 0 ).
        run wp-xmltagclose( 4, "docSum" ).

        run wp-XMLTagClose( 3, "lineDoc" ).
  END.
  RUN wp-XMLTagClose( 2, "operation" ).
END.

OUTPUT STREAM stmXMLOut CLOSE.
/*---END----------- Вывод в XML ---------------------*/

end.





/*==========================================================================*/
procedure update-temp-kass-goods :
do
on error undo, return error
:
def input parameter p-oper-num as char no-undo.
def input parameter p-sign     as integer no-undo. /* 1 или -1, множитель для сумм */

    FIND FIRST temp-kass-goods
         WHERE temp-kass-goods.cass-num = buf_chk-doc.pay-desk
           AND temp-kass-goods.gds-code = buf_goods.gds-code
           AND temp-kass-goods.oper-num = p-oper-num
    no-error.
    IF NOT AVAILABLE temp-kass-goods
    THEN DO:
    CREATE temp-kass-goods.
    ASSIGN
        temp-kass-goods.cass-num = buf_chk-doc.pay-desk
        temp-kass-goods.gds-code = buf_goods.gds-code
        temp-kass-goods.oper-num = p-oper-num
        temp-kass-goods.tot-qnty = 0
        temp-kass-goods.tot-sum  = 0
    .
    END.
    ASSIGN
        temp-kass-goods.tot-qnty = temp-kass-goods.tot-qnty + ( p-sign * buf_chk-gds.doc-qnty )
        temp-kass-goods.tot-sum  = temp-kass-goods.tot-sum + ( buf_chk-gds.doc-qnty * ( buf_chk-gds.price-base
                                                                                    + buf_chk-gds.price-service
                                                                                    - buf_chk-gds.discnt
                                                                                  )
                                                             )
    .
end.
end procedure. /* update-temp-kass-goods */
















/*==========================================================================*/
procedure update-temp-kass-pay :
do
on error undo, return error
:
def input parameter p-oper-num as char no-undo.
def input parameter p-sign     as integer no-undo. /* 1 или -1, множитель для сумм */

    FIND FIRST temp-kass-pay
         WHERE temp-kass-pay.cass-num   = buf_chk-doc.pay-desk
           AND temp-kass-pay.oper-num   = p-oper-num
           AND temp-kass-pay.pay-code   = buf_chk-pay.pay-code
           AND temp-kass-pay.curr-code  = buf_chk-pay.curr-code
    no-error.
    IF NOT AVAILABLE temp-kass-pay
    THEN DO:
    CREATE temp-kass-pay.
    ASSIGN
        temp-kass-pay.cass-num  = buf_chk-doc.pay-desk
        temp-kass-pay.oper-num  = p-oper-num
        temp-kass-pay.pay-code  = buf_chk-pay.pay-code
        temp-kass-pay.curr-code = buf_chk-pay.curr-code
        temp-kass-pay.tot-base = 0
        temp-kass-pay.tot-rubl = 0
        temp-kass-pay.tot-sum  = 0
    .
    END.
    ASSIGN
        temp-kass-pay.tot-base  = temp-kass-pay.tot-base + ( p-sign * buf_chk-pay.tot-base )
        temp-kass-pay.tot-rubl  = temp-kass-pay.tot-rubl + ( p-sign * buf_chk-pay.tot-rubl )
        temp-kass-pay.tot-sum   = temp-kass-pay.tot-sum  + ( p-sign * buf_chk-pay.tot-sum  )
    .
end.
end procedure. /* update-temp-kass-pay */