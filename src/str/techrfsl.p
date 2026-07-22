block-level on error undo, throw.
/*

$Revision: 315b966a6a9b, 3487, rls $
$Author: BelovaMM $
$Date: 2023/10/16 15:13:36 $
$Workfile: techrfsl.p $
$Archive: str/techrfsl.p $

Создание приходного документа техпролива по документу Техпролива, относящемуся к продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter log-file-name    as character no-undo .
define input parameter p-auto           as integer no-undo .
define input parameter v-curr-r-b       as character no-undo .
define input parameter p-close-in-rfsl  as integer no-undo .
define input parameter p-doc-kind       as character no-undo .
/*документ техпролива продажи  -списание*/
define parameter buffer buf_trn-doc for ub.trn-doc.
/*создарнный документ прихода по техпроливу */
define parameter buffer buf-new_trn-doc for ub.trn-doc.


define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: techrfsl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/techrfsl.p $":U .
define variable vss-description as character no-undo init "Создание приходного документа техпролива по документу Техпролива, относящемуся к продаже".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ str/lib-def.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/croslist.i }
{ ref/gdsoattr.i }
{ str/placelib.i }
{ str/trdcalib.i }
{ str/saledoc.i " " }

define variable v-mes as character no-undo .
define variable v-out-pay         as integer   no-undo .
define variable v-out-pay-str     as character no-undo .
define variable v-out-pay-type    as character no-undo .
define variable v-doc-code        like ub.trn-doc.doc-code no-undo .
define variable v-doc-code-chip   like ub.trn-doc.doc-code no-undo .
define variable v-prev-doc-code   like ub.trn-doc.doc-code no-undo .
define variable v-seq             as integer no-undo .
define variable v-seq-max         as integer no-undo .
define variable v-sum-rubl        as decimal no-undo .
define variable v-sum-base        as decimal no-undo .
define variable v-qnty            as decimal no-undo .
define variable v-insalepr        as logical initial ? no-undo.
define variable v-attr-type       as character no-undo .
define variable v-exist           as logical   no-undo .
define variable v-pl-code         as integer no-undo.
define variable v-value           as character no-undo.
define variable v-ok              as logical no-undo.
define variable v-gds-list-diff-place as character no-undo .

define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_gds-dtl       for ub.gds-dtl.
define buffer buf_parts         for ub.parts.
define buffer buf_inv-line      for ub.inv-line.
define buffer buf_doc-pl        for ub.doc-pl.
define buffer buf_goods         for ub.goods.
define buffer buf_units         for ub.units.
define buffer in_doc-pl         for ub.doc-pl.
define buffer in_inv-line       for ub.inv-line.
define buffer in_doc-line       for ub.doc-line.
define buffer in_gds-dtl        for ub.gds-dtl.
define buffer buf_sale-doc      for ub.sale-doc.
define buffer buf_pl-gds        for ub.pl-gds.

define temp-table tt-in_trn-doc       no-undo like lib-trn_ret-doc.
define temp-table tt-in_doc-line      no-undo like lib-trn_ret-line.
define temp-table tt-in_doc-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table tt-in_gds-dtl       no-undo like lib-trn_ret-dtl.
define temp-table tt-in_parts         no-undo like lib-trn_ret-parts.
define temp-table temp-tank           no-undo like ub.doc-pl
field doc-seq       as integer
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field price-base    like ub.doc-line.price-base
field price-rubl    like ub.doc-line.price-rubl
field price-cli     like ub.doc-line.price-cli
field cli-base-rate like ub.doc-line.cli-base-rate
field unit-type     like ub.units.type
index pi is unique primary
doc-seq gds-code
index
iart
artic prod-type prod-code.
define buffer buf_temp-tank  for temp-tank.
define buffer buf2_temp-tank for temp-tank.

_main:
do
on error undo, return error return-value :

  if not available buf_trn-doc then do:
        undo _main, return error substitute("&1 &2 &3&4Отсутствует документ списания техпролива"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}).
  end.
  if (buf_trn-doc.ext-doc-type <> {&tdedt_Spi_vnesh} and buf_trn-doc.ext-doc-type <> {&tdedt_Ras_vnesh})
  or buf_trn-doc.internal <> no
  or buf_trn-doc.status_ <> {&fact} then do:
    undo _main, return error substitute("&1 &2 &3&4Документ списания техпролива, используемый для создания прихода по техпроливу&4" +
                                          "имеет неправильный расширенный тип &5 или internal &6 или статус &7"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          , buf_trn-doc.ext-doc-type
                                          , buf_trn-doc.internal
                                          , buf_trn-doc.status_
                                          ).

  end.
  find first buf_sale-doc where buf_sale-doc.inkas-code = buf_trn-doc.out-code no-lock no-error.

  for each buf_temp-tank:
    delete buf_temp-tank.
  end.
  /*придется делать несколько накладных так как в один приходит оп одному топливу влезает только один бак*/
  v-gds-list-diff-place = "" .
  for each buf_doc-pl no-lock where
          buf_doc-pl.out-code = buf_trn-doc.doc-code
  break
  by buf_doc-pl.gds-code:
    if first-of(buf_doc-pl.gds-code) then do:
      assign
      v-seq = 0.
    end.
    create buf_temp-tank.
    buffer-copy buf_doc-pl
    to buf_temp-tank
    assign
    buf_temp-tank.gds-code = buf_doc-pl.gds-code
    buf_temp-tank.pl-code = buf_doc-pl.pl-code
    v-seq = v-seq + 1
    buf_temp-tank.doc-seq = v-seq
    v-seq-max = (if v-seq > v-seq-max then v-seq else v-seq-max)
    .
    if v-seq > 1
    then do :
      v-gds-list-diff-place = v-gds-list-diff-place + string(buf_doc-pl.gds-code) + "," .
    end .
  end.
  v-gds-list-diff-place = trim(v-gds-list-diff-place, ",") .
  run doc-code in this-procedure
      (input "chip"
/*      input "stock-up"*/
      ,input buf_trn-doc.obj-type
      ,input buf_trn-doc.obj-code
      ,input buf_trn-doc.out-code
      ,output v-doc-code ) no-error.
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации номера прихода по техпроливу для продажи &4:&1&2 &3"
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value
                      , buf_trn-doc.out-code
                      ).
    undo _main, return error v-mes.
  end.
  v-doc-code-chip = v-doc-code.
  { gbl/objatext.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    "'out-pay=request'"
    v-out-pay-str
    v-out-pay-type
  }
  assign
  v-out-pay = integer(v-out-pay-str)
  .
  v-prev-doc-code = v-doc-code.
  _v-seq:
  do v-seq = 1 to v-seq-max:
    if v-seq-max > 1 then do:
      run doc-code in this-procedure
          (input "chip"
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input v-prev-doc-code
          ,output v-doc-code-chip ) no-error.
      if error-status:error then do:
        v-mes = substitute("Ошибка при генерации номера прихода &5 по техпроливу для продажи &4:&1&2 &3"
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          , buf_trn-doc.out-code
                          , v-seq
                          ).
        undo _main, return error v-mes.
      end.
      assign
      v-prev-doc-code = v-doc-code-chip.
    end.
    for each tt-in_trn-doc:
      delete tt-in_trn-doc.
    end.
    for each tt-in_doc-line:
      delete tt-in_doc-line.
    end.
    for each tt-in_doc-line-attr:
      delete tt-in_doc-line-attr.
    end.
    for each tt-in_gds-dtl:
      delete tt-in_gds-dtl.
    end.
    for each tt-in_parts:
      delete tt-in_parts.
    end.
    create tt-in_trn-doc.
    buffer-copy
    buf_trn-doc except doc-code doc-type status_ ext-doc-type out-code
    to tt-in_trn-doc
    assign
    tt-in_trn-doc.doc-code = v-doc-code-chip
    tt-in_trn-doc.doc-type = {&income}
    tt-in_trn-doc.ext-doc-type = {&TDEDT_Pri_VNesh}
    tt-in_trn-doc.out-code = buf_trn-doc.doc-code
    tt-in_trn-doc.pay-code = v-out-pay
    tt-in_trn-doc.status_ = {&wayb}
    tt-in_trn-doc.ps = substitute('по списанию техпролива &1 продажи &2'
                      , buf_trn-doc.doc-code
                      , buf_trn-doc.out-code
                      )
    tt-in_trn-doc.discnt-type = '':U
    tt-in_trn-doc.flag = no
    tt-in_trn-doc.ret-supp  = no
    tt-in_trn-doc.slt-type  = {&without-slt}
    tt-in_trn-doc.vat-type  = {&inc-vat}
    tt-in_trn-doc.purch-code = integer({&repayment-code})
    .
    if available buf_sale-doc then do:
      assign
        tt-in_trn-doc.shift-date = buf_sale-doc.shift-date
        tt-in_trn-doc.shift-num  = buf_sale-doc.shift-num
        tt-in_trn-doc.shift-name = buf_sale-doc.shift-name
        tt-in_trn-doc.fact-date  = buf_sale-doc.fact-date
      .
    end.
    else do:
      assign
        tt-in_trn-doc.shift-date = ?
        tt-in_trn-doc.shift-num = 0
        tt-in_trn-doc.shift-name = ?
      .
    end.
    _doc-line:
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo _main, return error return-value :
      find first buf_goods no-lock where
                buf_goods.artic = buf_Doc-line.artic
          AND buf_goods.prod-type = buf_Doc-line.prod-type
          AND buf_goods.prod-code = buf_Doc-line.prod-code.
      find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base .
      find first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_goods.gds-code
             AND buf_temp-tank.doc-seq  = v-seq no-error .
      if not available buf_temp-tank then next _doc-line.
      assign
      buf_temp-tank.artic = buf_doc-line.artic
      buf_temp-tank.prod-type = buf_doc-line.prod-type
      buf_temp-tank.prod-code = buf_doc-line.prod-code
/*      buf_temp-tank.cli-base-rate = 1 / buf_doc-line.doc-density*/
      buf_temp-tank.cli-base-rate = buf_temp-tank.fact-qnty / buf_temp-tank.cli-qnty
      buf_temp-tank.unit-type = buf_units.type
      .
      create tt-in_doc-line.
      buffer-copy
      buf_Doc-line except
      buf_doc-line.doc-code
      buf_doc-line.price-cli
      buf_doc-line.price-base
      buf_doc-line.price-rubl
      to tt-in_doc-line
      assign
      tt-in_doc-line.doc-code = v-doc-code-chip
      tt-in_doc-line.unit-cli = buf_goods.unit-cli
      tt-in_doc-line.fact-qnty = buf_temp-tank.fact-qnty
      tt-in_doc-line.doc-qnty = buf_temp-tank.doc-qnty
      .
      assign
      v-qnty       = 0
      v-sum-rubl   = 0
      v-sum-base   = 0
      .
      for each buf_parts no-lock where
              buf_parts.out-code = buf_trn-doc.doc-code
          AND buf_parts.obj-type = buf_trn-doc.obj-type
          AND buf_parts.obj-code = buf_trn-doc.obj-code
          AND buf_parts.artic = buf_doc-line.artic
          AND buf_parts.prod-type = buf_doc-line.prod-type
          AND buf_parts.prod-code = buf_doc-line.prod-code
          AND buf_parts.pl-code = buf_temp-tank.pl-code,
          first buf2_temp-tank where
                buf2_temp-tank.doc-seq = v-seq
            AND buf2_temp-tank.gds-code = buf_temp-tank.gds-code
            AND buf2_temp-tank.pl-code = buf_temp-tank.pl-code
      on error undo _main, return error return-value :
        create tt-in_parts.
        buffer-copy
        buf_parts except buf_parts.out-code
        to tt-in_parts
        assign
        tt-in_parts.out-code = v-doc-code-chip
        tt-in_parts.purch-code = tt-in_trn-doc.purch-code
        tt-in_parts.slt-type  = {&without-slt}
        tt-in_parts.vat-type  = {&inc-vat}.
        
        if p-doc-kind = {&sale-add-vir-res} then do: /* Поменяем на виртуальный резервуар */
            v-pl-code = ?.
            for each buf_pl-gds no-lock
                where buf_pl-gds.obj-type = buf_trn-doc.obj-type
                and buf_pl-gds.obj-code = buf_trn-doc.obj-code
                and buf_pl-gds.gds-code  = buf2_temp-tank.gds-code:
            
                run placelib_get-attr  ( input {&place-virtual}
                                        ,input buf_trn-doc.obj-code
                                        ,input buf_trn-doc.obj-type
                                        ,input buf_pl-gds.pl-code
                                        ,output v-value
                                        ,output v-ok) no-error.
                if v-ok and logical(v-value) then v-pl-code = buf_pl-gds.pl-code.
            end. /* for each buf_pl-gds no-lock */
            
            tt-in_parts.pl-code = v-pl-code.
            
        end. /* if p-doc-kind = {&sale-add-vir-res} */
        
        assign
        v-qnty = v-qnty + buf_parts.fact-qnty
        v-sum-rubl = v-sum-rubl + buf_parts.price-rubl * buf_parts.fact-qnty
        v-sum-base = v-sum-base + buf_parts.price-base * buf_parts.fact-qnty
        .
      end.
      assign
      buf_temp-tank.price-rubl = v-sum-rubl / v-qnty
      buf_temp-tank.price-base = v-sum-rubl / v-qnty / buf_trn-doc.base-rate * buf_trn-doc.base-scale
      buf_temp-tank.price-cli = (if v-curr-r-b = {&r-b-base}
                                  then buf_temp-tank.price-base
                                  else buf_temp-tank.price-rubl) * buf_temp-tank.cli-base-rate
      tt-in_doc-line.price-rubl = v-sum-rubl / v-qnty
      tt-in_doc-line.price-base = v-sum-rubl / v-qnty / buf_trn-doc.base-rate * buf_trn-doc.base-scale
      /*эти три строчки верны потому, что у нас одна накладная -щепка-один резервуар*/
      tt-in_doc-line.cli-base-rate = buf_temp-tank.cli-base-rate
      tt-in_doc-line.doc-density = 1 / tt-in_doc-line.cli-base-rate
      tt-in_doc-line.cli-qnty = tt-in_doc-line.doc-density * buf_temp-tank.fact-qnty
      tt-in_doc-line.price-cli = (if v-curr-r-b = {&r-b-base}
                                  then tt-in_doc-line.price-base
                                  else tt-in_doc-line.price-rubl) * tt-in_doc-line.cli-base-rate
      .
    end.
    for each buf_doc-line-attr no-lock where
            buf_doc-line-attr.doc-code = buf_trn-doc.doc-code,
      first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_goods.gds-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      create tt-in_doc-line-attr.
      buffer-copy
      buf_doc-line-attr except buf_doc-line-attr.doc-code
      to tt-in_doc-line-attr
      assign
      tt-in_doc-line-attr.doc-code = v-doc-code-chip
      .
    end.
    for each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = buf_trn-doc.doc-code,
        first buf_temp-tank where
              buf_temp-tank.artic = buf_gds-dtl.artic
          AND buf_temp-tank.prod-type = buf_gds-dtl.prod-type
          AND buf_temp-tank.prod-code = buf_gds-dtl.prod-code
          AND  buf_temp-tank.doc-seq   = v-seq
    on error undo _main, return error return-value :
      create tt-in_gds-dtl.
      buffer-copy
      buf_gds-dtl except buf_gds-dtl.doc-code
      to tt-in_gds-dtl
      assign
      tt-in_gds-dtl.doc-code = v-doc-code-chip
      tt-in_gds-dtl.price-base = buf_gds-dtl.price-base - buf_gds-dtl.discnt-base
      tt-in_gds-dtl.price-rubl = buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl
      tt-in_gds-dtl.discnt-pc = 0
      tt-in_gds-dtl.discnt-base = 0
      tt-in_gds-dtl.discnt-rubl = 0
      tt-in_gds-dtl.fact-qnty = buf_temp-tank.fact-qnty
      tt-in_gds-dtl.doc-qnty = buf_temp-tank.doc-qnty
      .
    end.
    { str/crtrndoc.i
      ?
      ?
      tt-in_trn-doc.base-rate
      tt-in_trn-doc.base-scale
      tt-in_trn-doc.cli-code
      tt-in_trn-doc.cli-type
      tt-in_trn-doc.cli-name
      tt-in_trn-doc.cr-db-num
      g#userid
      tt-in_trn-doc.discnt-type
      tt-in_trn-doc.doc-code
      tt-in_trn-doc.doc-date
      tt-in_trn-doc.doc-type
      tt-in_trn-doc.flag
      tt-in_trn-doc.host-code
      tt-in_trn-doc.internal
      tt-in_trn-doc.obj-code
      tt-in_trn-doc.obj-type
      tt-in_trn-doc.office
      tt-in_trn-doc.pay-code
      tt-in_trn-doc.ps
      tt-in_trn-doc.ret-supp
      tt-in_trn-doc.slt-type
      tt-in_trn-doc.status_
      tt-in_trn-doc.vat-type
      tt-in_trn-doc.ext-doc-type
      tt-in_trn-doc.purch-code
      no-error
    }
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации документа прихода по техпроливу для продажи &4:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , buf_trn-doc.doc-code
                        ).
      undo _main, return error v-mes.
    end.
    find buf-new_trn-doc where buf-new_trn-doc.doc-code = v-doc-code-chip.
    assign
    buf-new_trn-doc.out-code = buf_trn-doc.doc-code
    buf-new_trn-doc.exch-code = buf_trn-doc.exch-code
    buf-new_trn-doc.exch-rate =  buf_trn-doc.exch-rate
    buf-new_trn-doc.exch-scale = buf_trn-doc.exch-scale
    buf-new_trn-doc.print-rubl = buf_trn-doc.print-rubl
    buf-new_trn-doc.agnt       = buf_trn-doc.agnt
    buf-new_trn-doc.wrkr       = buf_trn-doc.wrkr
    buf-new_trn-doc.boss       = buf_trn-doc.boss
    .
    if available buf_sale-doc then do:
      assign
        buf-new_trn-doc.shift-date = buf_sale-doc.shift-date
        buf-new_trn-doc.shift-num  = buf_sale-doc.shift-num
        buf-new_trn-doc.shift-name = buf_sale-doc.shift-name
        buf-new_trn-doc.fact-date  = buf_sale-doc.fact-date
      .
    end.
    else do:
      assign
        buf-new_trn-doc.shift-date = ?
        buf-new_trn-doc.shift-num = 0
        buf-new_trn-doc.shift-name = ?
      .
    end.
    
    { str/tdat-wrt.i                                    
       buf-new_trn-doc.doc-code
       {&trdcattr-is-auto-trn}
       "yes" 
    no-error}
    
    /* Для техпролива устанавливаем атрибут "Прочие перемещения НП" = yes */
    if p-doc-kind = {&sale-add-tech-refuell} then do:
       { str/tdat-wrt.i                                    
          buf-new_trn-doc.doc-code
          {&trdcattr-othermoves}
          "yes" 
       no-error}
    end.
    
    run saledoc-create  in this-procedure (
                                            input buf_trn-doc.out-code
                                            ,input buf-new_trn-doc.host-code
                                            ,input buf-new_trn-doc.obj-type
                                            ,input buf-new_trn-doc.obj-code
                                            ,input {&sale-add2-in-tech-refuell}
                                            ,input {&gds-goods}
                                            ,input no /*p-tpsidoc*/
                                            ,input '':U /*p-alias-type-price*/
                                            ,input '':U /*p-price-obj-type*/
                                            ,input 0 /*price-obj-code*/
                                            ,buffer buf-new_trn-doc
                                            ) no-error .
    if error-status:error then do:
      undo _main, return error substitute("Ошибка при генерации записи связанного документа для прихода по техпроливу по продаже &4:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , buf-new_trn-doc.doc-code
                        ).
    end.

  /*
    for each buf_inv-line no-lock where
            buf_inv-line.doc-code = buf_trn-doc.doc-code
    on error undo _main, return error return-value :
      create in_inv-line.
      buffer-copy
      buf_inv-line except buf_inv-line.doc-code
      to in_inv-line
      assign
      in_inv-line.doc-code = v-doc-code
      .
    end.
    */
    { str/copy-in.i
      parparentproc
      recid(buf-new_trn-doc)
      tt-in_trn-doc
      tt-in_doc-line
      tt-in_doc-line-attr
      tt-in_gds-dtl
      tt-in_parts
      no
      no
      yes
      yes
      this-procedure
      no-error
    }
    if error-status:error then do:
      undo _main, return error substitute("Ошибка при заполнении документа прихода по техпроливу по списанию по техпроливу по продаже &1&2" +
                                          "&3&2&4&2"
                                          , buf_trn-doc.out-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value ).
    end.
    
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.artic = buf_doc-line.artic
             AND buf_temp-tank.prod-type = buf_doc-line.prod-type
             AND buf_temp-tank.prod-code = buf_doc-line.prod-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_doc-line where
                in_doc-line.artic = buf_Doc-line.artic
          AND in_doc-line.prod-type = buf_Doc-line.prod-type
          AND in_doc-line.prod-code = buf_Doc-line.prod-code
          AND in_doc-line.doc-code = v-doc-code-chip no-error .
      if available in_doc-line then do:
        { gbl/gdsobjat.i
          in_doc-line.obj-type
          in_doc-line.obj-code
          in_doc-line.artic
          in_doc-line.prod-type
          in_doc-line.prod-code
          "'insalepr=request'":U
          v-insalepr
        }
        if v-insalepr = false
        or (can-do(v-gds-list-diff-place, string(buf_temp-tank.gds-code)) and in_doc-line.fact-qnty = buf_temp-tank.fact-qnty)
        then do:
          assign
            in_doc-line.price-base = buf_temp-tank.price-base
            in_doc-line.price-rubl = buf_temp-tank.price-rubl
          .
        end.
        if in_doc-line.price-rubl = buf_temp-tank.price-rubl
        then do :
          assign
            in_doc-line.cli-qnty = buf_temp-tank.cli-qnty
            in_doc-line.doc-density = in_doc-line.cli-qnty / in_doc-line.fact-qnty
            in_doc-line.fact-density = in_doc-line.doc-density
            in_doc-line.cli-base-rate = 1 / in_doc-line.doc-density
            in_doc-line.price-cli = buf_temp-tank.price-cli
          .
        end .
        
      end.
    end.
    for each buf_doc-pl no-lock where
          buf_doc-pl.out-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_doc-pl.gds-code
             AND buf_temp-tank.pl-code = buf_doc-pl.pl-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_doc-pl where
                 in_doc-pl.gds-code = buf_doc-pl.gds-code
             and in_doc-pl.pl-code  = buf_doc-pl.pl-code
             and in_doc-pl.out-code = v-doc-code-chip
             no-error .
      if available in_doc-pl
      then do :
        assign
          in_doc-pl.cli-qnty = buf_temp-tank.cli-qnty
          in_doc-pl.cli-doc-qnty = in_doc-pl.cli-qnty
          in_doc-pl.cli-fact-qnty = in_doc-pl.cli-qnty
        .
      end .
    end .   
    for each buf_inv-line no-lock where
            buf_inv-line.doc-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.artic = buf_inv-line.artic
             AND buf_temp-tank.prod-type = buf_inv-line.prod-type
             AND buf_temp-tank.prod-code = buf_inv-line.prod-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_inv-line where
                in_inv-line.artic = buf_inv-line.artic
          AND in_inv-line.prod-type = buf_inv-line.prod-type
          AND in_inv-line.prod-code = buf_inv-line.prod-code
          AND in_inv-line.doc-code = v-doc-code-chip no-error .
      if available in_inv-line then do:
        assign
          in_inv-line.wast-cli-qnty = buf_temp-tank.cli-qnty
          in_inv-line.after-cli-qnty = in_inv-line.before-cli-qnty + in_inv-line.wast-cli-qnty
          in_inv-line.wast-rubl = buf_temp-tank.price-cli
          in_inv-line.wast-base = buf_temp-tank.price-cli / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          in_inv-line.unus-wast-rubl = in_inv-line.wast-rubl
          in_inv-line.unus-wast-base = in_inv-line.wast-base
        .
      end .
    end .
    for each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = buf_trn-doc.doc-code,
        first buf_temp-tank where
              buf_temp-tank.artic = buf_gds-dtl.artic
          AND buf_temp-tank.prod-type = buf_gds-dtl.prod-type
          AND buf_temp-tank.prod-code = buf_gds-dtl.prod-code
          AND  buf_temp-tank.doc-seq   = v-seq
    on error undo _main, return error return-value :
      find first in_GDS-DTL where
                in_GDS-DTL.artic = buf_gds-dtl.artic
          AND in_GDS-DTL.prod-type = buf_gds-dtl.prod-type
          AND in_gds-dtl.prod-code = buf_gds-dtl.prod-code
          AND in_gds-dtl.prt-code = buf_gds-dtl.prt-code
          AND in_gds-dtl.doc-code = v-doc-code-chip no-error .
      if not available in_gds-dtl then do:
        { str/crgdsdtl.i
          buf_gds-dtl.obj-code
          buf_gds-dtl.obj-type
          v-doc-code-chip
          buf_gds-dtl.artic
          buf_gds-dtl.prod-code
          buf_gds-dtl.prod-type
          buf_gds-dtl.prt-code
          no
          }
        find first in_gds-dtl where
                  in_gds-dtl.artic = buf_gds-dtl.artic
            AND in_gds-dtl.prod-type = buf_gds-dtl.prod-type
            AND in_gds-dtl.prod-code = buf_gds-dtl.prod-code
            AND in_gds-dtl.prt-code = buf_gds-dtl.prt-code
            AND in_gds-dtl.doc-code = v-doc-code-chip .
        find first in_doc-line where
                  in_doc-line.artic = buf_gds-dtl.artic
            AND in_doc-line.prod-type = buf_gds-dtl.prod-type
            AND in_doc-line.prod-code = buf_gds-dtl.prod-code
            AND in_doc-line.doc-code = v-doc-code-chip .
        assign
        in_gds-dtl.doc-qnty = buf_temp-tank.doc-qnty
        in_gds-dtl.fact-qnty = buf_temp-tank.fact-qnty
        .
      end.
      { gbl/gdsobjat.i
        in_gds-dtl.obj-type
        in_gds-dtl.obj-code
        in_gds-dtl.artic
        in_gds-dtl.prod-type
        in_gds-dtl.prod-code
        "'insalepr=request'":U
        v-insalepr
      }
      assign
      in_gds-dtl.price-base = if v-insalepr = false
                              then (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                              else in_doc-line.price-base
      in_gds-dtl.price-rubl = if v-insalepr = false
                              then (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                              else in_doc-line.price-rubl
      in_gds-dtl.discnt-pc = 0
      in_gds-dtl.discnt-base = 0
      in_gds-dtl.discnt-rubl = 0
      .
    end.
    if v-seq-max > 1
    and v-seq < v-seq-max then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создана приходная накладная по Техпроливу &1 в статусе &2..."
                           ,v-doc-code-chip
                           ,buf-new_trn-doc.status_
                          )).
    if p-close-in-rfsl = 1 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Согласно настройкам приходная накладная по Техпроливу &1 в статусе &2 закрывается на факт..."
                            ,v-doc-code-chip
                            ,buf-new_trn-doc.status_
                            )).

     run close-trn in this-procedure (
                                      buffer buf-new_trn-doc
                                    ) no-error.
     if error-status:error then do:
       undo _main, return error return-value .
     end.
    end.
  end.

end. /*doe*/

procedure close-trn :
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return    as   logical             no-undo.
define variable varchg-inv         as   logical             no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
  varmode         = {&close-fact}
  varcheck-return = true
  varchg-inv      = true
  .
  run gbl/calc-trn.p ( input parparentproc
                  ,input  recid(buf_trn-doc)).
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
assign
v-cntxt-obj-type = buf_trn-doc.obj-type
v-cntxt-obj-code = buf_trn-doc.obj-code
v-cntxt-host-code-obj = buf_trn-doc.host-code
v-cntxt-db-num-obj = g#db-num
v-cntxt-db-num = g#db-num
v-cntxt-userid = g#userid
.

{ str/getctxtp.i get-no-cntxt }
buf_trn-doc.tot-cli = buf_trn-doc.tot-calc.

run str/trn-stat.p (
     input  parparentproc
    ,input  this-procedure:handle
    ,input  varmode
    ,input  buf_trn-doc.doc-code
    ,input  varcheck-return
    ,input  g#db-num
    ,input  v-cntxp-in-ov
    ,input  v-cntxp-rsrv-time
    ,input  v-cntxp-load-time
    ,input  v-cntxp-holidays
    ,input  NO
    ,output varchg-inv
    ,output table gds-list)    no-error.
if error-status:error then do:
  undo main-block, return error substitute("Ошибка при принудительном закрытии документа прихода по техпроливу по списанию по техпроливу по продаже &1&2" +
                                      "&3&2&4&2"
                                      , buf_trn-doc.doc-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value ).

  end.
end. /*doe*/
end procedure. /* clos-trn */
