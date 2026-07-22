block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: trnfactb.p $
$Archive: utl/trnfactb.p $

Корректировка партий внешнего прихода закрытого на факт

Автор: Чернова Светлана Александровна
Дата создания: 08/24/07
Author: Svetlana Chernova
Creation date: 08/24/07

*/

DEFINE TEMP-TABLE x_parts LIKE ub.parts.

define input  parameter ParParentProc as handle no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter table for x_parts.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trnfactb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trnfactb.p $":U .
define variable vss-description as character no-undo init "Корректировка партий внешнего прихода закрытого на факт".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ trg/partrqst.i }
{ trg/gdsobjcl.i }
{ str/in-vatp.i def }
&scop partrqst-prefix v-total-parts-
{&partrqst-var}

/*
for each x_parts :
message
      'alc-bottling-date      '  x_parts.alc-bottling-date
skip  'alc-certif-path        '  x_parts.alc-certif-path
skip  'alc-quality-certif-path'  x_parts.alc-quality-certif-path
skip  'alc-ref-ab-path        '  x_parts.alc-ref-ab-path
skip  'artic                  '  x_parts.artic
skip  'cli-base-rate          '  x_parts.cli-base-rate
skip  'cli-qnty               '  x_parts.cli-qnty
skip  'contract-code          '  x_parts.contract-code
skip  'cst-code               '  x_parts.cst-code
skip  'doc-type               '  x_parts.doc-type
skip  'exch-code              '  x_parts.exch-code
skip  'fact-date              '  x_parts.fact-date
skip  'fact-num               '  x_parts.fact-num
skip  'fact-qnty              '  x_parts.fact-qnty
skip  'host-code              '  x_parts.host-code
skip  'in-code                '  x_parts.in-code
skip  'is-supp                '  x_parts.is-supp
skip  'last-date              '  x_parts.last-date
skip  'mark-code              '  x_parts.mark-code
skip  'mark-db-num            '  x_parts.mark-db-num
skip  'obj-code               '  x_parts.obj-code
skip  'obj-type               '  x_parts.obj-type
skip  'other-base             '  x_parts.other-base
skip  'other-rubl             '  x_parts.other-rubl
skip  'out-code               '  x_parts.out-code
skip  'part-code              '  x_parts.part-code
skip  'pay-code               '  x_parts.pay-code
skip  'pl-code                '  x_parts.pl-code
skip  'price-base             '  x_parts.price-base
skip  '>>price-cli              '  x_parts.price-cli
skip  'price-rubl             '  x_parts.price-rubl
skip  'prod-code              '  x_parts.prod-code
skip  'prod-type              '  x_parts.prod-type
skip  'PS                     '  x_parts.PS
skip  'purch-code             '  x_parts.purch-code
skip  'qnty                   '  x_parts.qnty
skip  'real-qnty              '  x_parts.real-qnty
skip  'road-tax-base          '  x_parts.road-tax-base
skip  'road-tax-rubl          '  x_parts.road-tax-rubl
skip  'rsrv-free              '  x_parts.rsrv-free
skip  'SLT-pc                 '  x_parts.SLT-pc
skip  'SLT-type               '  x_parts.SLT-type
skip  'status_                '  x_parts.status_
skip  'supp-code              '  x_parts.supp-code
skip  'supp-type              '  x_parts.supp-type
skip  'transport-base         '  x_parts.transport-base
skip  'transport-rubl         '  x_parts.transport-rubl
skip  'VAT-pc                 '  x_parts.VAT-pc
skip  'VAT-type               '  x_parts.VAT-type
.
end.
*/

define buffer buf_trn-doc    for ub.trn-doc  .
define buffer oth_trn-doc    for ub.trn-doc  .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_parts      for ub.parts    .
define buffer all_parts      for ub.parts    .
define buffer free_parts     for ub.parts    .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods   .

define variable v-doc-line-VAT-pc   as decimal   no-undo .
define variable v-rash-cli          as decimal   no-undo .
define variable v-rash-qnty         as decimal   no-undo .
define variable v-delta-qnty        as decimal   no-undo .
define variable v-delta-cli-qnty    as decimal   no-undo .
define variable v-root-node         like ub.gds-prt.node-code no-undo .

find first buf_trn-doc exclusive-lock where
           buf_trn-doc.doc-code = p-doc-code
           no-error .
if available buf_trn-doc then
    run str/trn-hist.p
        ( buffer buf_trn-doc ,
          input  buf_trn-doc.obj-type ,
          input  buf_trn-doc.obj-code ,
          input  "Корр. закрытого на ФАКТ"
        ) .

do :
for each x_parts break by x_parts.prod-type  /* Партии документа */
                       by x_parts.prod-code
                       by x_parts.artic
                       :
  find first buf_goods no-lock where
             buf_goods.artic      = x_parts.artic     and
             buf_goods.prod-type  = x_parts.prod-type and
             buf_goods.prod-code  = x_parts.prod-code no-error .

    find first free_parts exclusive-lock where  /* свободная зона */
               free_parts.obj-type   = x_parts.obj-type  and
               free_parts.obj-code   = x_parts.obj-code  and
               free_parts.out-code   = {&free-code}      and
               free_parts.part-code  = x_parts.part-code and
               free_parts.in-code    = x_parts.in-code   and
               free_parts.artic      = x_parts.artic     and
               free_parts.prod-type  = x_parts.prod-type and
               free_parts.prod-code  = x_parts.prod-code
               no-error .
       if available free_parts then do:
         /* Количества */
         run calc-rash-part in this-procedure (
            input  x_parts.artic    ,
            input  x_parts.prod-type,
            input  x_parts.prod-code,
            input  x_parts.obj-type ,
            input  x_parts.obj-code ,
            input  x_parts.in-code  ,
            input  x_parts.part-code  ,
            output v-rash-cli ,
            output v-rash-qnty
            ) .
         assign
           free_parts.cli-qnty   = x_parts.cli-qnty  - v-rash-cli
           free_parts.qnty       = x_parts.qnty      - v-rash-qnty
           free_parts.fact-qnty  = x_parts.fact-qnty - v-rash-qnty
         .
       end.
       else do:
       end.

    find first buf_parts exclusive-lock where
               buf_parts.obj-type   = x_parts.obj-type  and
               buf_parts.obj-code   = x_parts.obj-code  and
               buf_parts.out-code   = x_parts.out-code  and
               buf_parts.part-code  = x_parts.part-code and
               buf_parts.in-code    = x_parts.in-code   and
               buf_parts.artic      = x_parts.artic     and
               buf_parts.prod-type  = x_parts.prod-type and
               buf_parts.prod-code  = x_parts.prod-code
               no-error .
    If available buf_parts then  do:
       buffer-copy x_parts to buf_parts . /* сохраним все в партию документа */
    end.

    for each  buf_parts-attr exclusive-lock where  /* сохраним и туда */
              buf_parts-attr.gds-code   = buf_goods.gds-code and
              buf_parts-attr.in-code    = x_parts.in-code and
              buf_parts-attr.part-code  = x_parts.part-code :
        assign
          buf_parts-attr.alc-bottling-date       = x_parts.alc-bottling-date
          buf_parts-attr.alc-certif-path         = x_parts.alc-certif-path
          buf_parts-attr.alc-quality-certif-path = x_parts.alc-quality-certif-path
          buf_parts-attr.alc-ref-ab-path         = x_parts.alc-ref-ab-path
          buf_parts-attr.cli-qnty                = x_parts.cli-qnty
          buf_parts-attr.cst-code                = x_parts.cst-code
          buf_parts-attr.doc-qnty                = x_parts.qnty
          buf_parts-attr.fact-qnty               = x_parts.fact-qnty
          buf_parts-attr.last-date               = x_parts.last-date
          buf_parts-attr.mark-code               = x_parts.mark-code
          buf_parts-attr.mark-db-num             = x_parts.mark-db-num
          buf_parts-attr.price-base              = x_parts.price-base
          buf_parts-attr.price-cli               = x_parts.price-cli
          buf_parts-attr.price-rubl              = x_parts.price-rubl
          buf_parts-attr.road-tax-base           = x_parts.road-tax-base
          buf_parts-attr.road-tax-rubl           = x_parts.road-tax-rubl
          buf_parts-attr.transport-base          = x_parts.transport-base
          buf_parts-attr.transport-rubl          = x_parts.transport-rubl
          buf_parts-attr.vat-pc                  = x_parts.vat-pc
          .
          v-doc-line-VAT-pc =  x_parts.vat-pc .
          { str/in-vatp.i calc-parts x_parts. " " loc }
          assign
            buf_parts-attr.vat-base     = vat-base-loc
            buf_parts-attr.vat-rubl     = vat-rubl-loc
            buf_parts-attr.slt-base     = slt-base-loc
            buf_parts-attr.slt-rubl     = slt-rubl-loc
            buf_parts-attr.discnt-base  = 0
            buf_parts-attr.discnt-rubl  = 0
          .
    end.

    /* по всем партиям которые разошлись из ПН */
    for each all_parts exclusive-lock where
             all_parts.artic     = x_parts.artic      and
             all_parts.prod-type = x_parts.prod-type  and
             all_parts.prod-code = x_parts.prod-code  and
             all_parts.in-code   = p-doc-code and
             all_parts.out-code  <> x_parts.out-code
             :
     assign
        all_parts.price-cli  = x_parts.price-cli
        all_parts.price-base = x_parts.price-base
        all_parts.price-rubl = x_parts.price-rubl
        all_parts.vat-pc     = x_parts.vat-pc
        all_parts.cst-code   = x_parts.cst-code
        all_parts.last-date  = x_parts.last-date
     .
    end.
    if last-of(x_parts.artic) then do:
     /*  пересчитать строки по партии  */
        find first buf_doc-line exclusive-lock where
                   buf_doc-line.doc-code  = p-doc-code and
                   buf_doc-line.artic     = x_parts.artic     and
                   buf_doc-line.prod-type = x_parts.prod-type and
                   buf_doc-line.prod-code = x_parts.prod-code
                   no-error .
        if available buf_doc-line then do:
        run partrqst in this-procedure
          (input  buf_doc-line.doc-code        /* p-doc-code               */
          ,input  buf_doc-line.obj-type        /* p-obj-type               */
          ,input  buf_doc-line.obj-code        /* p-obj-code               */
          ,input  buf_doc-line.artic           /* p-artic                  */
          ,input  buf_doc-line.prod-type       /* p-prod-type              */
          ,input  buf_doc-line.prod-code       /* p-prod-code              */
          &scop partrqst-prefix v-total-parts-
          {&partrqst-param}
          ).

        assign
          buf_doc-line.price-cli  = v-total-parts-price-cli / v-total-parts-cli-qnty
          buf_doc-line.doc-qnty   = v-total-parts-qnty
          buf_doc-line.fact-qnty  = v-total-parts-fact-qnty
          buf_doc-line.cli-qnty   = v-total-parts-cli-qnty
          buf_doc-line.price-base = v-total-parts-price-base   / v-total-parts-fact-qnty
          buf_doc-line.price-rubl = v-total-parts-price-rubl   / v-total-parts-fact-qnty
          buf_doc-line.transport-base  = v-total-parts-transport-base / v-total-parts-fact-qnty
          buf_doc-line.transport-rubl  = v-total-parts-transport-rubl / v-total-parts-fact-qnty
          buf_doc-line.other-base      = v-total-parts-other-base     / v-total-parts-fact-qnty
          buf_doc-line.other-rubl      = v-total-parts-other-rubl     / v-total-parts-fact-qnty
          buf_doc-line.vat-pc          = vat-pc-loc
        .
         find first ub.gds-obj exclusive-lock where
                    ub.gds-obj.gds-code = buf_goods.gds-code and
                    ub.gds-obj.obj-code = buf_doc-line.obj-code and
                    ub.gds-obj.obj-type = buf_doc-line.obj-type no-error .
        if available ub.gds-obj then do :
        /* Изменить на gds-obj и prt-obj */
          run utl/par2gds.p (
              input ub.gds-obj.artic,
              input ub.gds-obj.prod-type,
              input ub.gds-obj.prod-code,
              input ub.gds-obj.obj-type,
              input ub.gds-obj.obj-code
              ) .
            /* Пересчет остальных полей в gds-obj */
            run gdsobjcl in this-procedure (recid(ub.gds-obj), false ).
        end.
       end.

    end.
    find first oth_trn-doc no-lock where
               oth_trn-doc.doc-code = buf_parts.out-code no-error .
    if available oth_trn-doc and oth_trn-doc.status_ = {&fact} then do:
        run str/calc-hd.p (input oth_trn-doc.doc-code) .
        run str/vtrecalc.p ( input parparentproc , input recid (oth_trn-doc)).
         find first ub.gds-obj exclusive-lock where
                    ub.gds-obj.gds-code = buf_goods.gds-code and
                    ub.gds-obj.obj-code = oth_trn-doc.obj-code and
                    ub.gds-obj.obj-type = oth_trn-doc.obj-type no-error .
        if available ub.gds-obj then run gdsobjcl in this-procedure (recid(ub.gds-obj), false ).
        run trg/markdoc.p
          ( input oth_trn-doc.doc-code /* p-doc-code */
           ,input 'doc-change':u       /* p-action   */
          ) .
        find current oth_trn-doc exclusive-lock .
                     oth_trn-doc.bge-date = ? .

    end.
end.

if available buf_trn-doc then do:
    run str/calc-hd.p  ( input buf_trn-doc.doc-code ) .
    run str/vtrecalc.p ( input parparentproc , input recid (buf_trn-doc) ).
    run trg/markdoc.p
      ( input buf_trn-doc.doc-code /* p-doc-code */
      , input 'doc-change':u       /* p-action   */
      ) .
    find current buf_trn-doc exclusive-lock .
                 buf_trn-doc.bge-date = ? .
end.

/* запустим изменения в новости */
define variable v-remote-db-list as character no-undo .
define buffer buf_db for ub.db  .

  v-remote-db-list = "":U .
  for each buf_db where buf_db.db-num > 0 no-lock :
    assign
      v-remote-db-list = (if v-remote-db-list <> "":U then v-remote-db-list + {&delim-nws}
                                                      else ""
                          ) + string(buf_db.db-num)
    .
  end.

 if ( g#db-num > 0 and g#news = false ) or g#db-num = 0 then do:
        run trg/cmd-corr.p
          ( input p-doc-code ,
            input table x_parts ,
            input {&cmd-parts-fact-corr} ,
            input ( if g#db-num = 0 then v-remote-db-list else "0" )
            ) .
 end.

end.

procedure calc-rash-part :
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-in-code     as character no-undo .
define input  parameter p-part-code   as character no-undo .
define output parameter p-rash-cli    as decimal   no-undo .
define output parameter p-rash-qnty   as decimal   no-undo .

define buffer r_parts   for ub.parts  .
define buffer rez_parts for ub.parts  .

  do
  on error undo, return error return-value
  :
  p-rash-cli  = 0 .
  p-rash-qnty = 0 .
  for each r_parts no-lock where
           r_parts.artic      =  p-artic and
           r_parts.prod-type  =  p-prod-type and
           r_parts.prod-code  =  p-prod-code and
           r_parts.obj-type   =  p-obj-type  and
           r_parts.obj-code   =  p-obj-code  and
           r_parts.part-code  =  p-part-code  and
           r_parts.out-code   = {&output-code} and
           r_parts.rsrv-free  = no :
      assign
        p-rash-cli  = p-rash-cli  + r_parts.cli-qnty
        p-rash-qnty = p-rash-qnty + r_parts.fact-qnty
      .
  end.
  for each rez_parts no-lock where
          rez_parts.artic       =  p-artic      and
          rez_parts.prod-type   =  p-prod-type  and
          rez_parts.prod-code   =  p-prod-code  and
          rez_parts.part-code   =  p-part-code  and
          rez_parts.in-code     =  p-in-code    and
          rez_parts.out-code    <> p-in-code    and
          rez_parts.out-code    <> {&free-code} and
          rez_parts.status_     =  false        and
          rez_parts.rsrv-free   =  true
          :
          assign
              p-rash-cli  = p-rash-cli  + rez_parts.cli-qnty
              p-rash-qnty = p-rash-qnty + rez_parts.fact-qnty
            .
    end.
 end.
end procedure. /* calc-rash-part */