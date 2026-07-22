block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-akt.p $
$Archive: rep/inv-akt.p $

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter p-trn-doc-recid      as recid    no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: inv-akt.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/inv-akt.p $":U .
def var vss-description as character no-undo init "Пустографка".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i     }
{ gbl/cur-time.i    }
/*{ cmp/r-page1.i new }*/
{ cmp/r-pril.i new  }
{ rep/r-sym.i       }
{ gbl/waitfram.i    }

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .

&scoped-define gds-name-length 70

define shared variable  sort-name    as logical  no-undo.
define shared variable  sort-gr      as logical  no-undo.

define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.
define buffer buf_goods     for goods.
define buffer This_Object   for clients .

define variable v-lines-counter as int no-undo.

def temp-table temp_goods no-undo
    field obj-type      as character
    field unit-base     as character
    field obj-code      as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field gds-name      as character
    field full-grp-name as character
    field qnty          as decimal

    index byart is primary unique artic prod-type prod-code
    index byname gds-name artic
    index bygrp full-grp-name
.

define stream OutStream.

define variable v-line-string   as character            no-undo.
define variable UndLine         as character            no-undo.
define variable v-doc-string    as character no-undo .
define variable v-qnty          as decimal   no-undo .

/* ************** frame 1 для формы **************************************************************************** */
 DEFINE FRAME zapas
        sym1                 column-label ":"            format "x(1)"                   space(0)
        v-lines-counter      column-label "№"            format ">>>>>>>9":C             space(0)
        sym2                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.artic     column-label "Артикул"      format "X(17)"                  space(0)
        sym3                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.gds-name  column-label "Наименование" format "X({&gds-name-length})"  space(0)
        sym4                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.unit-base column-label "ед.изм"       format "X(6)"                   space(0)
        sym5                 column-label ":"            format "x(1)"                   space(0)
        temp_goods.qnty      column-label "Факт. кол-во" format "->>>>>>>>>>>.<<<"       space(0)
        sym6                 column-label ":"            format "x(1)"                   space(0)
    HEADER
        cur-time-print()                                                        at 5    format "X(35)"
/*        string( "Объект " + string( store-type) + " " + string( store-code) )   at 48   format "X(13)"*/
        v-doc-string                                                            at 67   format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") )    at 111  format "X(17)"
    skip
        v-line-string  format "X(120)"  with width {&A4_CW0} down stream-io use-text NO-BOX.
/*===================================================================================================================*/
    { gbl/working.i }
    { cmp/open-out.i stream OutStream " " }
    assign
      v-line-string = fill("-", 129)
      UndLine       = fill("_", 129)
    .

    find first buf_trn-doc no-lock where recid( buf_trn-doc ) = p-trn-doc-recid .

    assign v-doc-string = "По документу N " + buf_trn-doc.doc-code + " от " + string( buf_trn-doc.doc-date, "99/99/9999" ) .

  find first This_Object  WHERE This_Object.obj-type = buf_trn-doc.obj-type AND This_Object.obj-code = buf_trn-doc.obj-code  NO-LOCK.
  find first  clients      WHERE clients.obj-type     = {&cmp}           AND clients.obj-code     = buf_trn-doc.host-code NO-LOCK.

      PUT STREAM OutStream
         v-line-string format  "X(100)" skip
         "| "  "Предприятие, организация " format  "X(30)" AT 15 "| " AT 50  "Склад " format  "X(20)" AT 75 "|" AT 100 skip
         v-line-string format  "X(100)" skip
         "| "  CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" format  "X(47)"  "| " AT 50
         string(  This_Object.obj-name  + " (" + string(This_Object.obj-code) + ")" ) format  "X(47)"  "| " AT 100  skip
         v-line-string format  "X(100)" skip (2)
        space(15) string( "Акт приема-передачи товарно-материальных ценностей № "
                + buf_trn-doc.doc-code + string( buf_trn-doc.doc-date, "99/99/9999")
                + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip (2)
      .

    form with frame zapas .
    form header
        v-line-string format "X(120)" at 1 skip   "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream OutStream frame BottomFrame .

    for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code :
      find first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
          and buf_goods.prod-type  = buf_doc-line.prod-type
          and buf_goods.prod-code  = buf_doc-line.prod-code
      no-error.
      create temp_goods no-error.
      assign
        temp_goods.obj-type         = buf_doc-line.obj-type
        temp_goods.obj-code         = buf_doc-line.obj-code
        temp_goods.artic            = buf_doc-line.artic
        temp_goods.prod-type        = buf_doc-line.prod-type
        temp_goods.prod-code        = buf_doc-line.prod-code
        temp_goods.qnty             = buf_doc-line.doc-qnty
        temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )
        temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )
        temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )
        temp_goods.unit-base        = buf_goods.unit-base
      .
    end.

    if sort-gr = yes then do:
      if sort-name = no  then do:
        for each temp_goods
          break by temp_goods.full-grp-name
                by temp_goods.artic
                by temp_goods.prod-type
                by temp_goods.prod-code
        :
          if first-of( temp_goods.full-grp-name ) then do:
            run print-group-line in this-procedure ( input temp_goods.full-grp-name ).
          end.
          run print-line in this-procedure .
        end.
      end.        /* if sort-name = no  */
      else do:
        for each temp_goods
          break by temp_goods.full-grp-name
              by temp_goods.gds-name
        :
          if first-of( temp_goods.full-grp-name )  then  run print-group-line in this-procedure ( input temp_goods.full-grp-name ).
          run print-line in this-procedure .
        end.
      end.        /* NOT ( if sort-name = no  ) */
    end.        /* if sort-gr = yes */
    else do:
      if sort-name = no then do:
        for each temp_goods  use-index byart :
          run print-line in this-procedure .
        end.
      end.        /* if sort-name = no  */
      else do:
        for each temp_goods use-index byname :
          run print-line in this-procedure .
        end.
      end.        /* NOT ( if sort-name = no  ) */
    end.        /* NOT ( if sort-gr = yes ) */
    put  stream outstream  v-line-string  format "X(120)" .
    display stream OutStream
      Sym1 Sym5 Sym6
      "Итого:" @ temp_goods.gds-name
      v-qnty @ temp_goods.qnty
    with frame zapas.
    down stream  OutStream 1 with frame zapas.
    put  stream outstream  v-line-string  format "X(120)" .

    put  stream outstream skip
              "   Все ценности, поименованные  в  настоящей  инвентаризационной  описи  с комиссией проверены в натуре в моем (нашем)" SKIP
              "личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем). " SKIP
              "Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Сдал: " "Принял: " at 70 SKIP(1)
              UndLine   format "X(25)" AT 1  UndLine   format "X(25)" AT 30 UndLine   format "X(25)" AT 60 UndLine   format "X(25)" AT 90 SKIP
              "Фамилия" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "Фамилия" format "X(25)" AT 70 "подпись" format "X(25)" AT 100  SKIP
              UndLine   format "X(25)" AT 1  UndLine   format "X(25)" AT 30 UndLine   format "X(25)" AT 60 UndLine   format "X(25)" AT 90 SKIP
              "Фамилия" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "Фамилия" format "X(25)" AT 70 "подпись" format "X(25)" AT 100  SKIP
              "Указанные в настоящей описи данные и расчеты проверил"
                  UndLine format "X(25)" AT 10 UndLine format "X(25)"   AT 40 UndLine format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. " .


    HIDE   stream OutStream FRAME BottomFrame .
    HIDE   STREAM OutStream FRAME ZAPAS .
    Output stream OutStream close.
    { gbl/stopwork.i }
    { rep/q-print.i 0 }


/*==========================================================================*/
procedure print-line :
  do on error undo, return error :
    assign
      v-lines-counter = v-lines-counter + 1
      v-qnty = v-qnty + temp_goods.qnty
    .
    { rep/r-mess.i v-lines-counter 50 }
    display stream OutStream
      Sym1  Sym2 Sym3 Sym4 Sym5 Sym6
      v-lines-counter
      temp_goods.artic
      temp_goods.gds-name
      temp_goods.unit-base
      temp_goods.qnty
    with frame zapas.
    down stream  OutStream 1 with frame zapas.
  end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-group-line :
  define input parameter p-full-grp-name  as character        no-undo.

  do on error undo, return error :
/*    if line-counter( OutStream ) + 5 > page-size( OutStream )  then  page stream outstream.*/
   DOWN stream OutStream 1 with FRAME zapas .
   PUT stream OutStream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(p-full-grp-name)) + UndLine)  FORMAT "X(120)" skip  .
  end.
end procedure. /* print-group-line */