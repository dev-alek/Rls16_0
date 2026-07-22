block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cr-chpdf.p $
$Archive: str/cr-chpdf.p $

Cоздание ДНЦ-детей по Кустовому ТПЛ

Автор: Чернова Светлана Александровна
Дата создания: 07/26/06
Author: Svetlana Chernova
Creation date: 07/26/06


*/
define input  parameter parparentproc as handle no-undo    .
define input  parameter p-recid       as recid no-undo     .
define input  parameter p-action      as character no-undo . /* {&fact}  до какого статуса закрывать переоценки */
define input  parameter p-trn-doc     as character no-undo . /* Номер ПН */
define input  parameter p-ask-pr      as logical   no-undo . /* Молча закрывать переоценки */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-chpdf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cr-chpdf.p $":U .
define variable vss-description as character no-undo init "Cоздание ДНЦ-детей по Кустовому ТПЛ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/xobjgrp.i  }  /* список объектов  */
{ gbl/waitfram.i }

define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-attr     for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds      for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .

define buffer buf_price-list-type for ub.price-list-type  . /* родитель */
define buffer child_price-list-type for ub.price-list-type  . /* дети   */
define buffer bufold_price-doc-forming for ub.price-doc-forming  .

define variable v1-recid as recid no-undo .
define variable v1-cur-rt as decimal   no-undo .
define variable v1-cur-ex as decimal   no-undo .


find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming) = p-recid no-error .
if error-status :error then return error return-value .
find first buf_price-list-type no-lock where
           buf_price-list-type.stts = integer({&pdf-new}) and
           buf_price-list-type.under-type-list = 0 and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num and
           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id
           no-error .
if error-status :error then return error return-value .

define variable v-pdf-id     as integer   no-undo .
define variable v-pdf-db as integer   no-undo .
run waitfram-show in this-procedure ("Создание подчиненных ДНЦ ...") .
for each child_price-list-type exclusive-lock where
         child_price-list-type.stts = integer({&pdf-new}) and
         child_price-list-type.under-type-list = 1 and
         child_price-list-type.plt-main-db-num = buf_price-doc-forming.plt-db-num and
         child_price-list-type.plt-main-id     = buf_price-doc-forming.plt-id :
         run waitfram-show in this-procedure ("Создание подчиненных ДНЦ " + string( child_price-list-type.plt-id) + " БД:" + string ( child_price-list-type.plt-db-num)) .
         assign
          v-pdf-id = next-value ( s-pdf , {&db-name_schema})
          v-pdf-db = v-cntxt-db-num
         .

         create ub.price-doc-forming .
         buffer-copy buf_price-doc-forming to ub.price-doc-forming
         assign
            ub.price-doc-forming.plt-id       = child_price-list-type.plt-id
            ub.price-doc-forming.plt-db-num   = child_price-list-type.plt-db-num
            ub.price-doc-forming.pdf-id       = v-pdf-id
            ub.price-doc-forming.pdf-db       = v-pdf-db
            ub.price-doc-forming.stts         = integer({&pdf-new})
            ub.price-doc-forming.sys-date     = today
            ub.price-doc-forming.sys-time     = time
            ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
            ub.price-doc-forming.who          = v-cntxt-userid
            ub.price-doc-forming.des          = "Подчиненный"
            ub.price-doc-forming.main-pdf-id  =  buf_price-doc-forming.pdf-id
            ub.price-doc-forming.main-pdf-db  =  buf_price-doc-forming.pdf-db
         .

         for each buf_price-doc-forming-attr     no-lock   where
                  buf_price-doc-forming-attr.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-attr.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-attr.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-attr.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-attr.
                  buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
                  assign
                    ub.price-doc-forming-attr.plt-id       = child_price-list-type.plt-id
                    ub.price-doc-forming-attr.plt-db-num   = child_price-list-type.plt-db-num
                    ub.price-doc-forming-attr.pdf-id       = v-pdf-id
                    ub.price-doc-forming-attr.pdf-db       = v-pdf-db
                  .
         end.

         for each buf_price-doc-forming-gds      no-lock   where
                  buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds.
                  buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
                  assign
                    ub.price-doc-forming-gds.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds.price-calc-doc   = buf_price-doc-forming-gds.price-sale-doc
                    ub.price-doc-forming-gds.price-calc-rubl  = buf_price-doc-forming-gds.price-sale-rubl
                    ub.price-doc-forming-gds.price-calc-base  = buf_price-doc-forming-gds.price-sale-base
                  .

              { gbl/bc-mpl.i
                child_price-list-type.gop-id
                child_price-list-type.gop-db-num
                ub.price-doc-forming-gds.b-code
                0
                0
                v1-recid
                ub.price-doc-forming-gds.price-prev-doc
                v1-cur-rt
                v1-cur-ex
                no-error }

                find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
                ub.price-doc-forming-gds.prev-doc-code = if available bufold_price-doc-forming
                then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                else "" .

                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds.price-sale-doc
                      ,input buf_price-doc-forming-gds.price-sale-rubl
                      ,input buf_price-doc-forming-gds.price-sale-base
                      ,output ub.price-doc-forming-gds.price-sale-doc
                      ,output ub.price-doc-forming-gds.price-sale-rubl
                      ,output ub.price-doc-forming-gds.price-sale-base
                      ) .

         end.

         for each buf_price-doc-forming-gds-sum  no-lock where
                  buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-sum.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-sum.
                  buffer-copy buf_price-doc-forming-gds-sum to ub.price-doc-forming-gds-sum
                  assign
                    ub.price-doc-forming-gds-sum.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-sum.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-sum.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-sum.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-sum.price-calc-doc   = buf_price-doc-forming-gds-sum.price-sale-doc
                    ub.price-doc-forming-gds-sum.price-calc-rubl  = buf_price-doc-forming-gds-sum.price-sale-rubl
                    ub.price-doc-forming-gds-sum.price-calc-base  = buf_price-doc-forming-gds-sum.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-sum.price-sale-doc
                      ,input buf_price-doc-forming-gds-sum.price-sale-rubl
                      ,input buf_price-doc-forming-gds-sum.price-sale-base
                      ,output ub.price-doc-forming-gds-sum.price-sale-doc
                      ,output ub.price-doc-forming-gds-sum.price-sale-rubl
                      ,output ub.price-doc-forming-gds-sum.price-sale-base
                      ) .
         end.

         for each buf_price-doc-forming-gds-tnv  no-lock  where
                  buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-tnv.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-tnv.
                  buffer-copy buf_price-doc-forming-gds-tnv to ub.price-doc-forming-gds-tnv
                  assign
                    ub.price-doc-forming-gds-tnv.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-tnv.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-tnv.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-tnv.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-tnv.price-calc-doc   = buf_price-doc-forming-gds-tnv.price-sale-doc
                    ub.price-doc-forming-gds-tnv.price-calc-rubl  = buf_price-doc-forming-gds-tnv.price-sale-rubl
                    ub.price-doc-forming-gds-tnv.price-calc-base  = buf_price-doc-forming-gds-tnv.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-tnv.price-sale-doc
                      ,input buf_price-doc-forming-gds-tnv.price-sale-rubl
                      ,input buf_price-doc-forming-gds-tnv.price-sale-base
                      ,output ub.price-doc-forming-gds-tnv.price-sale-doc
                      ,output ub.price-doc-forming-gds-tnv.price-sale-rubl
                      ,output ub.price-doc-forming-gds-tnv.price-sale-base
                      ) .
         end.

         for each buf_price-doc-forming-gds-qnty no-lock  where
                  buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-qnty.
                  buffer-copy buf_price-doc-forming-gds-qnty to ub.price-doc-forming-gds-qnty
                  assign
                    ub.price-doc-forming-gds-qnty.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-qnty.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-qnty.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-qnty.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-qnty.price-calc-doc   = buf_price-doc-forming-gds-qnty.price-sale-doc
                    ub.price-doc-forming-gds-qnty.price-calc-rubl  = buf_price-doc-forming-gds-qnty.price-sale-rubl
                    ub.price-doc-forming-gds-qnty.price-calc-base  = buf_price-doc-forming-gds-qnty.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-qnty.price-sale-doc
                      ,input buf_price-doc-forming-gds-qnty.price-sale-rubl
                      ,input buf_price-doc-forming-gds-qnty.price-sale-base
                      ,output ub.price-doc-forming-gds-qnty.price-sale-doc
                      ,output ub.price-doc-forming-gds-qnty.price-sale-rubl
                      ,output ub.price-doc-forming-gds-qnty.price-sale-base
                      ) .
         end.

          if child_price-list-type.under-hand-corr = 0 then do:
    run str/diallog.w
        (parparentproc
        , this-procedure
        , 'str/pdf-clos.p':U
        , ( string(recid(ub.price-doc-forming)) + {&delim-par} +
           'no' + {&delim-par} +
           'no' + {&delim-par} +
           '?' + {&delim-par} +
           '?' + {&delim-par} +
           string(p-action) + {&delim-par} +
           p-trn-doc + {&delim-par} +
           string(p-ask-pr)  )
        , yes /*p-auto-go*/
        , '':U
        , 'Закрытие ДНЦ') no-error .
         end.

end.
run waitfram-hide in this-procedure  .

procedure new-price :
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-price-calc-doc   as decimal   no-undo .
define input  parameter  p-price-calc-rubl  as decimal   no-undo .
define input  parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .

  do
  on error undo, return error return-value
  :
   p-price-sale-doc   = p-price-calc-doc  * ( 1 + ( p-increase-pc / 100 )) .
   p-price-sale-rubl  = p-price-calc-rubl * ( 1 + ( p-increase-pc / 100 )) .
   p-price-sale-base  = p-price-calc-base * ( 1 + ( p-increase-pc / 100 )) .

    { str/pr-99.i
    p-price-sale-doc
    p-round-method
    p-round-base
  }

  { str/pr-99.i
    p-price-sale-rubl
    p-round-method
    p-round-base
  }

  { str/pr-99.i
    p-price-sale-base
    p-round-method
    p-round-base
  }


  end.

end procedure. /* new-price */