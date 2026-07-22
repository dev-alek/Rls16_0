block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-crmpl.p $
$Archive: utl/pr-crmpl.p $

Процедура перехода на 15 версию по переоценкам

Автор: Чернова Светлана Александровна
Дата создания: 05/05/06
Author: Svetlana Chernova
Creation date: 05/05/06

Обрбатывает все последние цены товаров .


*/
define input  parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-crmpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pr-crmpl.p $":U .
define variable vss-description as character no-undo init "Процедура перехода на 15 версию по переоценкам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/obji-ad.i  }
{ ref/typl-ad.i  }
{ gbl/waitfram.i }

define buffer buf_shop  for    ub.shop  .
define buffer buf_store for    ub.store  .

define variable v-curr-code as integer   no-undo .

define variable loc_calc-round-method  as character no-undo .
define variable loc_calc-round-base    as decimal   no-undo .
define variable loc_calc-increase-pc   as decimal   no-undo .
define variable loc_calc-method        as character no-undo .

define variable vcalc-round-base   as character no-undo .
define variable vcalc-increase-pc  as character no-undo .
define variable par-type as character no-undo .
define variable v-base-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-curr-abbr-bv as character no-undo .
define variable v-exch-rate as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-curr-abbr-vd as character no-undo .
define variable v-is-base as logical   no-undo .
define variable t1 as integer   no-undo .
define variable t2 as integer   no-undo .

{ gbl/rbisbase.i v-is-base }

loc_calc-method = {&pr-calc-no}.
t1 = time.

for each buf_shop no-lock :
  { gbl/basecode.i  buf_shop.host-code  v-base-code  }
  { gbl/r-b-curr.i  buf_shop.host-code  v-curr-code  }
  { gbl/exchrate.i v-base-code TODAY v-base-rate v-base-scale v-curr-abbr-bv }
  { gbl/exchrate.i v-curr-code TODAY v-exch-rate v-exch-scale v-curr-abbr-vd }
  { gbl/conf-rd.i "'pr-incpc'" buf_shop.host-code {&shop} buf_shop.obj-code "''" "''" "''" no vcalc-increase-pc     par-type no-error }.
  { gbl/conf-rd.i "'pr-rndmt'" buf_shop.host-code {&shop} buf_shop.obj-code "''" "''" "''" no loc_calc-round-method par-type no-error }.
  { gbl/conf-rd.i "'pr-rndbs'" buf_shop.host-code {&shop} buf_shop.obj-code "''" "''" "''" no vcalc-round-base      par-type no-error }.
  loc_calc-increase-pc = decimal ( vcalc-increase-pc ) .
  loc_calc-round-base  = decimal ( vcalc-round-base  ) .

  case loc_calc-round-method:
    when "pr-round-9end" then
      loc_calc-round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      loc_calc-round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      loc_calc-round-method = {&pr-round-integer}.
    when "pr-round-select" then
      loc_calc-round-method = {&pr-round-select}.
    when "pr-round-up" then
      loc_calc-round-method = {&pr-round-up}.
    when "pr-round-coef" then
      loc_calc-round-method = {&pr-round-coef}.
    when "pr-round-off" then
      loc_calc-round-method = {&pr-round-off}.
    otherwise
      loc_calc-round-method = {&pr-round-off}.
  end case.

  run proc-b in this-procedure ({&shop} , buf_shop.obj-code ) .
end.

for each buf_store no-lock :
   { gbl/basecode.i  buf_store.host-code  v-base-code }
   { gbl/r-b-curr.i  buf_store.host-code   v-curr-code  }
   { gbl/exchrate.i v-base-code TODAY v-base-rate v-base-scale v-curr-abbr-bv }
   { gbl/exchrate.i v-curr-code TODAY v-exch-rate v-exch-scale v-curr-abbr-vd }
   { gbl/conf-rd.i "'pr-incpc'" buf_store.host-code {&stock} buf_store.obj-code "''" "''" "''" no vcalc-increase-pc     par-type no-error }.
   { gbl/conf-rd.i "'pr-rndmt'" buf_store.host-code {&stock} buf_store.obj-code "''" "''" "''" no loc_calc-round-method par-type no-error }.
   { gbl/conf-rd.i "'pr-rndbs'" buf_store.host-code {&stock} buf_store.obj-code "''" "''" "''" no vcalc-round-base      par-type no-error }.
   loc_calc-increase-pc = decimal ( vcalc-increase-pc ) .
   loc_calc-round-base  = decimal ( vcalc-round-base  ) .
  case loc_calc-round-method:
    when "pr-round-9end" then
      loc_calc-round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      loc_calc-round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      loc_calc-round-method = {&pr-round-integer}.
    when "pr-round-select" then
      loc_calc-round-method = {&pr-round-select}.
    when "pr-round-up" then
      loc_calc-round-method = {&pr-round-up}.
    when "pr-round-coef" then
      loc_calc-round-method = {&pr-round-coef}.
    when "pr-round-off" then
      loc_calc-round-method = {&pr-round-off}.
    otherwise
      loc_calc-round-method = {&pr-round-off}.
  end case.

   run proc-b in this-procedure ({&stock} , buf_store.obj-code ) .
end.
run waitfram-hide in this-procedure.
t2 = time.
message "Все"  string ( t2 - t1  , "hh:mm:ss" ) .


procedure proc-b :
define input  parameter p-type as character no-undo .
define input  parameter p-code as integer   no-undo .
  do
  on error undo, return error return-value
  :

define variable  p-gop-id as integer no-undo .
define variable  p-recid  as recid   no-undo .
do
on error undo :

p-gop-id = next-value ( s-gop , {&db-name_schema} ) .
create ub.grp-obj-price.
assign
  ub.grp-obj-price.gop-db-num   = v-cntxt-db-num
  ub.grp-obj-price.gop-id       = p-gop-id
  ub.grp-obj-price.db-num-chg   = v-cntxt-db-num
  ub.grp-obj-price.stts         = 0
  ub.grp-obj-price.sys-date     = today
  ub.grp-obj-price.sys-time     = time
  ub.grp-obj-price.sys-time-chr = string(ub.grp-obj-price.sys-time,"hh:mm")
  ub.grp-obj-price.who          = v-cntxt-userid
  ub.grp-obj-price.name-group   = "По объекту " + p-type + string ( p-code )
  .
  run  objo-ADD (
    input  v-cntxt-db-num  ,
    input  p-gop-id            ,
    input  p-type  ,
    input  p-code  ,
    input  0               ,
    input  v-cntxt-db-num  ,
    input  v-cntxt-userid  ,
    output p-recid ) .

/* ГТПЛ */
define variable v-plt-id as integer   no-undo .
find first ub.price-list-type no-lock where
           ub.price-list-type.main = true and
           ub.price-list-type.gop-id = p-gop-id and
           ub.price-list-type.gop-db-num = v-cntxt-db-num and
           ub.price-list-type.stts       = integer({&pdf-new}) and
           ub.price-list-type.plt-db-num = v-cntxt-db-num no-error .
    if available ub.price-list-type then do:
       v-plt-id = ub.price-list-type.plt-id .
    end.
    else do:
    v-plt-id = next-value (s-plt, {&db-name_schema})  .

        run type-price-list-ADD (
            v-cntxt-db-num                                    /*p-db-num                       */
          , v-plt-id                                          /*p-id                           */
          , "ГТПЛ по объекту " + p-type + string (p-code)     /*p-name                         */
          , int ( true )                                      /*p-ban-discnt                   */
          , loc_calc-round-method                             /*p-calc-round-method            */
          , loc_calc-round-base                               /*p-calc-round-base              */
          , loc_calc-increase-pc                              /*p-calc-increase-pc             */
          , loc_calc-method                                   /*p-calc-method                  */
          , int ( true )                                      /*p-create-price-doc             */
          , false                                             /*p-fix-cource-crc-base          */
          , false                                             /*p-fix-cource-crc-doc           */
          , int ( false )                                     /*p-have-rs-qnty-group           */
          , false                                             /*p-have-rs-sum-group            */
          , true                                              /*p-main                         */
          , int ( false )                                     /*p-only-gbd                     */
          , v-cntxt-db-num                                    /*p-plt-main-db-num              */
          ,  ?                                                /*p-plt-main-id                  */
          ,  0                                                /*p-priority                     */
          ,  0                                                /*p-rs-buyer                     */
          ,  true                                             /*p-send-cassa                   */
          ,  int  ( true  )                                   /*p-under-hand-corr              */
          ,  ?                                                /*p-under-round-method           */
          ,  ?                                                /*p-under-perc                   */
          ,  int ( false )                                    /*p-under-type-list              */
          ,  0                                                /*p-use-cassa                    */
          ,  int ( false )                                    /*p-use-gds-group                */
          ,  2                                                /*p-use-obj                      */
          ,  0                                                /*p-work-date                    */
          ,  v-cntxt-db-num                                   /*p-bgr-db-num                   */
          ,  ?                                                /*p-bgr-id                       */
          ,  v-curr-code                                      /*p-curr-code                    */
          ,  v-cntxt-db-num                                   /*p-gop-db-num                   */
          ,  v-cntxt-db-num                                   /*p-gop-db-num-for-calc-turnover */
          ,  p-gop-id                                         /*p-gop-id                       */
          ,  ?                                                /*p-gop-id-for-calc-turnover     */
          ,  v-cntxt-db-num                                   /*p-qgr-db-num                   */
          ,  ?                                                /*p-qgr-id                       */
          ,  v-cntxt-db-num                                   /*p-sgr-db-num                   */
          ,  ?                                                /*p-sgr-id                       */
          ,  v-cntxt-db-num                                   /*p-tog-db-num                   */
          ,  ?                                                /*p-tog-id                       */
          ,  ?                                                /*p-obj-turnover                 */
          ,  v-cntxt-db-num                                   /*p-ttg-summa                    */
          ,  v-cntxt-userid                                   /*p-userid                       */
          ,  v-cntxt-db-num                                   /*p-db-num-usr                   */
          ,  int( false )                                     /*p-have-rs-turn-group           */
          ,  0                                                /*p-have-tog-db-num              */
          ,  ?                                                /*p-have-tog-id                  */
          ,  int( false  )                                    /*p-use-cash-pay                 */
          ,  int( false  )                                    /*p-use-pay-type                 */
          ,  output p-recid                                   /*p-recid                        */
          ,  input table TT_cassa                             /*table for tt_cassa .*/
          ,  input table TT_grp                               /*table for tt_grp   .*/
          ,  input table TT_pay-type                          /*table for tt_pay-type .*/
          ,  input table TT_cash-pay                          /*table for tt_cash-pay .*/
          ) no-error .
          find first ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
     end.
 end.
/* ДНЦ */
define variable v-pdf as integer   no-undo .
define variable v-line-num   as integer   no-undo .
define variable v-excise-base       as decimal   no-undo .
define variable v-excise-doc        as decimal   no-undo .
define variable v-excise-rubl       as decimal   no-undo .
define variable v-price-calc-base   as decimal   no-undo .
define variable v-price-calc-doc    as decimal   no-undo .
define variable v-price-calc-rubl   as decimal   no-undo .
define variable v-price-prev-base   as decimal   no-undo .
define variable v-price-prev-doc    as decimal   no-undo .
define variable v-price-prev-rubl   as decimal   no-undo .
define variable v-price-sale-base   as decimal   no-undo .
define variable v-price-sale-doc    as decimal   no-undo .
define variable v-price-sale-rubl   as decimal   no-undo .
define variable v-road-tax-base     as decimal   no-undo .
define variable v-road-tax-doc      as decimal   no-undo .
define variable v-road-tax-rubl     as decimal   no-undo .
define variable   v-b-code          as integer   no-undo .
define variable   v-doc-num         as character no-undo .
define variable   v-price-sale      as decimal   no-undo .
define variable   v-road-tax        as decimal   no-undo .
define variable   v-excise          as decimal   no-undo .

v-line-num = 0 .
find first ub.price-doc-forming no-lock where
           ub.price-doc-forming.stts       = integer({&pdf-new}) and
           ub.price-doc-forming.plt-id     = ub.price-list-type.plt-id and
           ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num no-error .

  if available ub.price-doc-forming then do:
    v-pdf = ub.price-doc-forming.plt-id .
  end.
  else do:
   v-pdf = next-value ( s-pdf , {&db-name_schema} ) .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id            = v-plt-id
      ub.price-doc-forming.plt-db-num        = v-cntxt-db-num
      ub.price-doc-forming.pdf-id            = v-pdf
      ub.price-doc-forming.pdf-db            = v-cntxt-db-num
      ub.price-doc-forming.base-rate         = v-base-rate
      ub.price-doc-forming.base-scale        = v-base-scale
      ub.price-doc-forming.db-num-chg        = v-cntxt-db-num
      ub.price-doc-forming.exch-rate         = v-exch-rate
      ub.price-doc-forming.exch-scale        = v-exch-scale
      ub.price-doc-forming.stts              = integer({&pdf-new})
      ub.price-doc-forming.sys-date          = today
      ub.price-doc-forming.sys-time          = time
      ub.price-doc-forming.sys-time-chr      = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who               = v-cntxt-userid
      ub.price-doc-forming.name              = "ДНЦ при переходе на 15v "  + p-type + string (p-code)
      ub.price-doc-forming.have-start-period = int( false )
      ub.price-doc-forming.start-sys-date    = ?
      ub.price-doc-forming.start-shift-num   = ?
      ub.price-doc-forming.start-shift-date  = ?
      ub.price-doc-forming.have-end-period   = int ( false  )
      ub.price-doc-forming.end-sys-date      = ?
      ub.price-doc-forming.end-shift-num     = ?
      ub.price-doc-forming.end-date          = ?
      ub.price-doc-forming.end-shift-date    = ?
      ub.price-doc-forming.out-code          = if available ub.price-doc then ub.price-doc.out-code else ""
      ub.price-doc-forming.start-date        = if available ub.price-doc then ub.price-doc.fact-date  else ?

      .
  end.

define variable v-main-b-code as integer   no-undo .
define variable v-type-price as integer   no-undo .
define buffer buf_goods    for ub.goods     .
define buffer buf_gds-prt  for ub.gds-prt   .

/* Создание строк для ДНЦ */
  for each ub.gds-obj no-lock where
           ub.gds-obj.obj-type = p-type and
           ub.gds-obj.obj-code = p-code :

       find first buf_goods    no-lock where buf_goods.gds-code   = ub.gds-obj.gds-code .
       run waitfram-show in this-procedure ( buf_goods.artic + " " + p-type + string(p-code) ) .
         { gbl/gdsbcode.i ub.gds-obj.gds-code ? v-main-b-code }

       for each ub.bar-code no-lock where
           ub.bar-code.gds-code = ub.gds-obj.gds-code:
         { gbl/bcodeprc.i
                p-type
                p-code
                ub.bar-code.b-code
                0
                0
                v-doc-num
                v-price-sale
                v-road-tax
                v-excise
                no-error  }
        if error-status :error = false and v-doc-num <> ?  then do:

         find first ub.price-list no-lock where
                    ub.price-list.doc-num = v-doc-num and
                    ub.price-list.price-type = ""     and
                    ub.price-list.b-code  = ub.bar-code.b-code no-error .
         if not available ub.price-list then next.

      find first ub.price-doc no-lock where
                 ub.price-doc.doc-num = v-doc-num and
            not (
            ub.price-doc.pdf-id               = v-pdf and
            ub.price-doc.pdf-db               = v-cntxt-db-num and
            ub.price-doc.plt-id               = v-plt-id and
            ub.price-doc.plt-db-num           = v-cntxt-db-num ) no-error .
       if available ub.price-doc then do:
           find current ub.price-doc exclusive-lock no-error .
           assign
            ub.price-doc.pdf-id               = v-pdf
            ub.price-doc.pdf-db               = v-cntxt-db-num
            ub.price-doc.plt-id               = v-plt-id
            ub.price-doc.plt-db-num           = v-cntxt-db-num
            ub.price-doc-forming.start-date   = ub.price-doc.fact-date
           .
       end.
      if v-is-base = true then do:
      assign
        v-excise-base      = ub.price-list.excise
        v-price-calc-base  = ub.price-list.price-calc
        v-price-prev-base  = ub.price-list.price-prev
        v-price-sale-base  = ub.price-list.price-sale
        v-road-tax-base    = ub.price-list.road-tax
        v-excise-rubl       = v-excise-base       * v-base-rate / v-base-scale
        v-price-calc-rubl   = v-price-calc-base   * v-base-rate / v-base-scale
        v-price-prev-rubl   = v-price-prev-base   * v-base-rate / v-base-scale
        v-price-sale-rubl   = v-price-sale-base   * v-base-rate / v-base-scale
        v-road-tax-rubl     = v-road-tax-base     * v-base-rate / v-base-scale
        v-excise-doc      = v-excise-base
        v-price-calc-doc  = v-price-calc-base
        v-price-prev-doc  = v-price-prev-base
        v-price-sale-doc  = v-price-sale-base
        v-road-tax-doc    = v-road-tax-base
      .
      end.
      else do:
      assign
        v-excise-rubl     = ub.price-list.excise
        v-price-calc-rubl = ub.price-list.price-calc
        v-price-prev-rubl = ub.price-list.price-prev
        v-price-sale-rubl = ub.price-list.price-sale
        v-road-tax-rubl   = ub.price-list.road-tax
        v-excise-base     = v-excise-rubl     / v-base-rate * v-base-scale
        v-price-calc-base = v-price-calc-rubl / v-base-rate * v-base-scale
        v-price-prev-base = v-price-prev-rubl / v-base-rate * v-base-scale
        v-price-sale-base = v-price-sale-rubl / v-base-rate * v-base-scale
        v-road-tax-base   = v-road-tax-rubl   / v-base-rate * v-base-scale
        v-excise-doc      = v-excise-rubl
        v-price-calc-doc  = v-price-calc-rubl
        v-price-prev-doc  = v-price-prev-rubl
        v-price-sale-doc  = v-price-sale-rubl
        v-road-tax-doc    = v-road-tax-rubl
      .
      end.

 /* Создание строки ДНЦ */
      find first ub.price-doc no-lock where
                 ub.price-doc.doc-num = ub.price-list.doc-num no-error .

      v-line-num  = v-line-num   + 1.
      create ub.price-doc-forming-gds.
      buffer-copy ub.price-doc-forming to ub.price-doc-forming-gds
      assign
          ub.price-doc-forming-gds.line-num        = v-line-num
          ub.price-doc-forming-gds.b-code          = ub.price-list.b-code
          ub.price-doc-forming-gds.artic           = ub.price-list.artic
          ub.price-doc-forming-gds.prod-code       = ub.price-list.prod-code
          ub.price-doc-forming-gds.prod-type       = ub.price-list.prod-type
          ub.price-doc-forming-gds.calc-method     = ub.price-list.calc-method
          ub.price-doc-forming-gds.d-pcnt          = ub.price-list.d-pcnt
          ub.price-doc-forming-gds.excise-base     = v-excise-base
          ub.price-doc-forming-gds.excise-doc      = v-excise-doc
          ub.price-doc-forming-gds.excise-rubl     = v-excise-rubl
          ub.price-doc-forming-gds.price-calc-base = v-price-calc-base
          ub.price-doc-forming-gds.price-calc-doc  = v-price-calc-doc
          ub.price-doc-forming-gds.price-calc-rubl = v-price-calc-rubl
          ub.price-doc-forming-gds.price-prev-base = v-price-prev-base
          ub.price-doc-forming-gds.price-prev-doc  = v-price-prev-doc
          ub.price-doc-forming-gds.price-prev-rubl = v-price-prev-rubl
          ub.price-doc-forming-gds.price-sale-base = v-price-sale-base
          ub.price-doc-forming-gds.price-sale-doc  = v-price-sale-doc
          ub.price-doc-forming-gds.price-sale-rubl = v-price-sale-rubl
          ub.price-doc-forming-gds.road-tax-base   = v-road-tax-base
          ub.price-doc-forming-gds.road-tax-doc    = v-road-tax-doc
          ub.price-doc-forming-gds.road-tax-rubl   = v-road-tax-rubl
          ub.price-doc-forming-gds.slt-pc          = ub.price-list.slt-pc
          ub.price-doc-forming-gds.vat-pc          = ub.price-list.vat-pc
      .

         find first buf_gds-prt  no-lock where buf_gds-prt.node-code = ub.bar-code.node-code.

         if buf_goods.unit-base = ub.bar-code.unit-cli then do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ({&mpl-type-main}) . /* основные */
               else v-type-price  = integer ({&mpl-type-spec}) . /* спец на основные */
         end.
         else do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ({&mpl-type-main}) . /* неосновные */
               else v-type-price  = integer ({&mpl-type-nomain}) . /* спец на неосновные */
         end.

         create ub.price-all.
         assign
            ub.price-all.main-indication = 0
            ub.price-all.type-price      = if ub.bar-code.b-code = v-main-b-code then 0  else 1
            ub.price-all.pal-db-num      = v-cntxt-db-num
            ub.price-all.pal-id          = next-value ( s-pal , {&db-name_schema} )
            ub.price-all.b-code          = ub.price-doc-forming-gds.b-code
            ub.price-all.gds-code        = ub.bar-code.gds-code
            ub.price-all.obj-code        = p-code
            ub.price-all.obj-type        = p-TYPE
            ub.price-all.bgr-db-num      = 0
            ub.price-all.bgr-id          = 0
            ub.price-all.curr-code       = ub.price-list-type.curr-code
            ub.price-all.pdf-id               = ub.price-doc-forming-gds.pdf-id
            ub.price-all.pdf-db               = ub.price-doc-forming-gds.pdf-db
            ub.price-all.pdf-base-rate        = v-base-rate
            ub.price-all.pdf-base-scale       = v-base-scale
            ub.price-all.pdf-exch-rate        = v-exch-rate
            ub.price-all.pdf-exch-scale       = v-exch-scale
            ub.price-all.plt-id               = ub.price-doc-forming-gds.plt-id
            ub.price-all.plt-db-num           = ub.price-doc-forming-gds.plt-db-num
            ub.price-all.plt-fix-cource-crc-base   = ub.price-list-type.fix-cource-crc-base
            ub.price-all.plt-fix-cource-crc-doc    = ub.price-list-type.fix-cource-crc-doc
            ub.price-all.plt-priority           = ub.price-list-type.priority
            ub.price-all.plt-work-date          = ub.price-list-type.work-date
            ub.price-all.qnty-from              = ?
            ub.price-all.qnty-to                = ?
            ub.price-all.sum-from               = ?
            ub.price-all.sum-to                 = ?
            ub.price-all.turnover-from          = ?
            ub.price-all.turnover-to            = ?
            ub.price-all.tog-db-num             = 0
            ub.price-all.tog-id                 = 0
            ub.price-all.use-cash-pay           = ub.price-list-type.use-cash-pay
            ub.price-all.use-pay-type           = ub.price-list-type.use-pay-type
            ub.price-all.price-sale             = ub.price-list.price-sale
            ub.price-all.start-date             =  ub.price-doc-forming.start-date
            ub.price-all.start-shift-date       =  ub.price-doc-forming.start-shift-date
            ub.price-all.start-shift-name       =  ub.price-doc-forming.start-shift-name
            ub.price-all.start-shift-num        =  ub.price-doc-forming.start-shift-num
            ub.price-all.start-sys-date         =  ub.price-doc-forming.start-sys-date
            ub.price-all.start-sys-time         =  ub.price-doc-forming.start-sys-time
            ub.price-all.end-date               =  ub.price-doc-forming.end-date
            ub.price-all.end-shift-date         =  ub.price-doc-forming.end-shift-date
            ub.price-all.end-shift-name         =  ub.price-doc-forming.end-shift-name
            ub.price-all.end-shift-num          =  ub.price-doc-forming.end-shift-num
            ub.price-all.end-sys-date           =  ub.price-doc-forming.end-sys-date
            ub.price-all.end-sys-time           =  ub.price-doc-forming.end-sys-time
            ub.price-all.fact-order-shift-from  = ?
            ub.price-all.fact-order-shift-to   = ?
            ub.price-all.fact-order-sys-from   = ?
            ub.price-all.fact-order-sys-to     = ?
            ub.price-all.extra-pcnt            = ?
            ub.price-all.extra-round           = ?
            ub.price-all.work-acc-price        = ?
            ub.price-all.work-acc-price        = ?
            ub.price-all.out-code    =  v-doc-num
            ub.price-all.status_     =  ub.price-doc.status_
            ub.price-all.last-pr     = true
            ub.price-all.fact-order  =  ub.price-doc.fact-order
            .

      end.
   end.
   end.
   find current ub.price-doc-forming exclusive-lock .
   if not can-find (first ub.price-doc-forming-gds no-lock   where
            ub.price-doc-forming-gds.pdf-id               = ub.price-doc-forming.pdf-id and
            ub.price-doc-forming-gds.pdf-db               = ub.price-doc-forming.pdf-db and
            ub.price-doc-forming-gds.plt-id               = ub.price-doc-forming.plt-id   and
            ub.price-doc-forming-gds.plt-db-num           = ub.price-doc-forming.plt-db-num ) then
                 delete ub.price-doc-forming .
            else ub.price-doc-forming.stts = integer({&pdf-fact}) /* fact */ .
  end.

end procedure. /* proc-b */