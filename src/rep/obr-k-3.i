/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".
  /* обороты */
  /* нужны обороты ПРИХОДОВ от ПОСТАВ. */
  if buf_goods.gds-type = {&gds-office} then do:
    assign
      str-find  = {&arh-csdt-service}  /*закупка*/
      str-find1 = {&arh-sadt-service}  /*документ*/
      str-find2 = {&arh-cgdt-service}  /*продажа*/
    .
    if sys-key = "mag" then do:
      assign
        str-find2 = {&arh-sadt-service}
      .
    end.
  end.
  else do:
    assign
      str-find  = {&arh-csdt}   /*закупка*/
      str-find1 = {&arh-sadt}   /*документ*/
      str-find2 = {&arh-cgdt}   /*продажа*/
    .
  end.

  if use-column[14] = yes or use-column[33] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign gds-prop.InExt-Qnty = gds-prop.InExt-Qnty + buf_stk-line.fact-qnty .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.InExt-Qnty = gds-prop.InExt-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ВОЗВРАТОВ ПОСТАВ. */
  if use-column[15] = yes or use-column[34] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_VP}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_VP}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  /* ***************************************************************************************** */
  /* нужны обороты ВНЕШ. РАСХОД */
  if use-column[10] = yes or use-column[11] = yes or use-column[35] = yes or use-column[37] = yes or use-column[41] = yes or use-column[43] = yes then do: /* закуп. цены */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[10] = yes or use-column[11] = yes or use-column[16] = yes or use-column[18] = yes or use-column[52] = yes or use-column[54] = yes or use-column[68] = yes or
     use-column[70] = yes or use-column[77] = yes or use-column[79] = yes or use-column[22] = yes or use-column[24] = yes or
     use-column[58] = yes or use-column[60] = yes or use-column[74] = yes or use-column[76] = yes or use-column[83] = yes or
     use-column[85] = yes then do: /* прод. цены, кол-во, скидки */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutExt-Qnty = gds-prop.OutExt-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExt-SaleSum   = gds-prop.OutExt-SaleSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExt-SaleSum   = gds-prop.OutExt-SaleSum - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExt-SaleSum   = gds-prop.OutExt-SaleSum   + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExt-SaleSum   = gds-prop.OutExt-SaleSum   + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExt-DiscntSum = gds-prop.OutExt-DiscntSum - buf_stk-line.other-rubl
          gds-prop.OutExt-DocSum = gds-prop.OutExt-DocSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExt-DiscntSum = gds-prop.OutExt-DiscntSum - buf_stk-line.other-base
          gds-prop.OutExt-DocSum = gds-prop.OutExt-DocSum - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Ras_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExt-DiscntSum = gds-prop.OutExt-DiscntSum + buf_stk-line.other-rubl
          gds-prop.OutExt-DocSum = gds-prop.OutExt-DocSum + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExt-DiscntSum = gds-prop.OutExt-DiscntSum + buf_stk-line.other-base
          gds-prop.OutExt-DocSum = gds-prop.OutExt-DocSum + buf_stk-line.sum-base
        .
    end.
  end.

  /* ***************************************************************************************** */
  /* нужны обороты ВНЕШ. ВОЗВРАТ */
  if use-column[10] = yes or use-column[11] = yes or use-column[36] = yes or use-column[37] = yes or use-column[42] = yes or use-column[43] = yes then do: /* закуп. цены */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum + buf_stk-line.sum-base .
      end.
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetOut-CostSum = gds-prop.RetOut-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[10] = yes or use-column[11] = yes or use-column[17] = yes or use-column[18] = yes or use-column[53] = yes or use-column[54] = yes or use-column[69] = yes or
     use-column[70] = yes or use-column[78] = yes or use-column[79] = yes or use-column[23] = yes or use-column[24] = yes or
     use-column[59] = yes or use-column[60] = yes or use-column[75] = yes or use-column[76] = yes or use-column[84] = yes or
     use-column[85] = yes then do: /* прод. цены, кол-во, скидки */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetOut-Qnty = gds-prop.RetOut-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOut-SaleSum   = gds-prop.RetOut-SaleSum + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOut-SaleSum   = gds-prop.RetOut-SaleSum + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetOut-Qnty    = gds-prop.RetOut-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOut-SaleSum   = gds-prop.RetOut-SaleSum   - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOut-SaleSum   = gds-prop.RetOut-SaleSum   - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOut-DiscntSum = gds-prop.RetOut-DiscntSum + buf_stk-line.other-rubl
          gds-prop.RetOut-DocSum = gds-prop.RetOut-DocSum + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOut-DiscntSum = gds-prop.RetOut-DiscntSum + buf_stk-line.other-base
          gds-prop.RetOut-DocSum = gds-prop.RetOut-DocSum + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Vozvrat_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOut-DiscntSum = gds-prop.RetOut-DiscntSum - buf_stk-line.other-rubl
          gds-prop.RetOut-DocSum = gds-prop.RetOut-DocSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOut-DiscntSum = gds-prop.RetOut-DiscntSum - buf_stk-line.other-base
          gds-prop.RetOut-DocSum = gds-prop.RetOut-DocSum - buf_stk-line.sum-base
        .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ВНЕШ. РАСХОД КАССА  */
  if use-column[10] = yes or use-column[11] = yes or use-column[38] = yes or use-column[40] = yes or use-column[41] = yes or use-column[43] = yes then do: /* закуп. цены */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[10] = yes or use-column[11] = yes or use-column[19] = yes or use-column[21] = yes or use-column[55] = yes or use-column[57] = yes or use-column[71] = yes or
     use-column[73] = yes or use-column[80] = yes or use-column[82] = yes or use-column[22] = yes or use-column[24] = yes or
     use-column[58] = yes or use-column[60] = yes or use-column[74] = yes or use-column[76] = yes or use-column[83] = yes or
     use-column[85] = yes then do: /* прод. цены, кол-во, скидки */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutExtKass-Qnty    = gds-prop.OutExtKass-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExtKass-DiscntSum = gds-prop.OutExtKass-DiscntSum - buf_stk-line.other-rubl
          gds-prop.OutExtKass-DocSum    = gds-prop.OutExtKass-DocSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExtKass-DiscntSum = gds-prop.OutExtKass-DiscntSum - buf_stk-line.other-base
          gds-prop.OutExtKass-DocSum    = gds-prop.OutExtKass-DocSum - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Ras_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.OutExtKass-DiscntSum = gds-prop.OutExtKass-DiscntSum + buf_stk-line.other-rubl
          gds-prop.OutExtKass-DocSum = gds-prop.OutExtKass-DocSum + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.OutExtKass-DiscntSum = gds-prop.OutExtKass-DiscntSum + buf_stk-line.other-base
          gds-prop.OutExtKass-DocSum = gds-prop.OutExtKass-DocSum + buf_stk-line.sum-base
        .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ВНЕШ. ВОЗВРАТ КАССА  */
  if use-column[10] = yes or use-column[11] = yes or use-column[39] = yes or use-column[40] = yes or use-column[42] = yes or use-column[43] = yes then do: /* закуп. цены */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl .
        else                 assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum + buf_stk-line.sum-base .
      end.
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetOutKass-CostSum = gds-prop.RetOutKass-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[10] = yes or use-column[11] = yes or use-column[20] = yes or use-column[21] = yes or use-column[56] = yes or use-column[57] = yes or use-column[72] = yes or
     use-column[73] = yes or use-column[81] = yes or use-column[82] = yes or use-column[23] = yes or use-column[24] = yes or
     use-column[59] = yes or use-column[60] = yes or use-column[75] = yes or use-column[76] = yes or use-column[84] = yes or
     use-column[85] = yes then do: /* прод. цены, кол-во, скидки */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetOutKass-Qnty = gds-prop.RetOutKass-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOutKass-SaleSum   = gds-prop.RetOutKass-SaleSum + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOutKass-SaleSum   = gds-prop.RetOutKass-SaleSum + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetOutKass-Qnty    = gds-prop.RetOutKass-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOutKass-SaleSum   = gds-prop.RetOutKass-SaleSum   - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOutKass-SaleSum   = gds-prop.RetOutKass-SaleSum   - buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOutKass-DiscntSum = gds-prop.RetOutKass-DiscntSum + buf_stk-line.other-rubl
          gds-prop.RetOutKass-DocSum    = gds-prop.RetOutKass-DocSum    + buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOutKass-DiscntSum = gds-prop.RetOutKass-DiscntSum + buf_stk-line.other-base
          gds-prop.RetOutKass-DocSum = gds-prop.RetOutKass-DocSum + buf_stk-line.sum-base
        .
    end.

    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Vozvrat_Vnesh_Kass}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then
        assign
          gds-prop.RetOutKass-DiscntSum = gds-prop.RetOutKass-DiscntSum - buf_stk-line.other-rubl
          gds-prop.RetOutKass-DocSum = gds-prop.RetOutKass-DocSum - buf_stk-line.sum-rubl
        .
      else
        assign
          gds-prop.RetOutKass-DiscntSum = gds-prop.RetOutKass-DiscntSum - buf_stk-line.other-base
          gds-prop.RetOutKass-DocSum = gds-prop.RetOutKass-DocSum - buf_stk-line.sum-base
        .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ИНВЕНТАР. */
  if use-column[25] = yes or use-column[44] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Inv}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Inv-Qnty    = gds-prop.Inv-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Inv}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Inv-Qnty = gds-prop.Inv-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Peresort}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Inv-Qnty    = gds-prop.Inv-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Peresort}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Inv-Qnty = gds-prop.Inv-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.Inv-CostSum = gds-prop.Inv-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[61] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Inv}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Inv}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum - buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Peresort}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find1 + {&TDEDT_Peresort}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.Inv-SaleSum = gds-prop.Inv-SaleSum - buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты СПИСАНИЕ. */
  if use-column[26] = yes or use-column[45] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Spi-Qnty = gds-prop.Spi-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.Spi-Qnty = gds-prop.Spi-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[62] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Spi_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Spi-SaleSum = gds-prop.Spi-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.Spi-SaleSum = gds-prop.Spi-SaleSum - buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Spi_Vnesh}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Spi-SaleSum = gds-prop.Spi-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.Spi-SaleSum = gds-prop.Spi-SaleSum + buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПЕРЕМЕЩЕНИЕ ПРИХОД */
  if use-column[27] = yes or use-column[46] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.InInt-Qnty = gds-prop.InInt-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.InInt-Qnty = gds-prop.InInt-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.InInt-CostSum = gds-prop.InInt-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[63] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Pri_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.InInt-SaleSum = gds-prop.InInt-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.InInt-SaleSum = gds-prop.InInt-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Pri_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.InInt-SaleSum = gds-prop.InInt-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.InInt-SaleSum = gds-prop.InInt-SaleSum - buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПЕРЕМЕЩЕНИЕ РАСХОД */
  if use-column[28] = yes or use-column[47] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutInt-Qnty = gds-prop.OutInt-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutInt-Qnty = gds-prop.OutInt-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl .
        else                 assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutInt-CostSum = gds-prop.OutInt-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[64] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.OutInt-SaleSum = gds-prop.OutInt-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.OutInt-SaleSum = gds-prop.OutInt-SaleSum - buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.OutInt-SaleSum = gds-prop.OutInt-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.OutInt-SaleSum = gds-prop.OutInt-SaleSum + buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПЕРЕМЕЩЕНИЕ ВОЗВРАТ */
  if use-column[29] = yes or use-column[48] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetInt-Qnty = gds-prop.RetInt-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.RetInt-Qnty = gds-prop.RetInt-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.RetInt-CostSum = gds-prop.RetInt-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[65] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.RetInt-SaleSum = gds-prop.RetInt-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.RetInt-SaleSum = gds-prop.RetInt-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Perem}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.RetInt-SaleSum = gds-prop.RetInt-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.RetInt-SaleSum = gds-prop.RetInt-SaleSum - buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПРОИЗ-ВО ПРИХОД */
  if use-column[30] = yes or use-column[49] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[66] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Pri_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.InProiz-SaleSum = gds-prop.InProiz-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.InProiz-SaleSum = gds-prop.InProiz-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Pri_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.InProiz-SaleSum = gds-prop.InProiz-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.InProiz-SaleSum = gds-prop.InProiz-SaleSum - buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПРОИЗ-ВО РАСХОД */
  if use-column[86] = yes or use-column[87] = yes then do: /* закупка и кол-во */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty - buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-rubl + buf_stk-line.VAT-rubl .
        else                 assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-base + buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-base .
      end.
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      assign
        gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty + buf_stk-line.fact-qnty
      .
      if x-SET_val_TYPE = 1  then do:
        if no-nds = yes then assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-rubl - buf_stk-line.VAT-rubl  .
        else                 assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-rubl .
      end.
      else do:
        if no-nds = yes then assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-base - buf_stk-line.VAT-base  .
        else                 assign gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-base .
      end.
    end.
  end.

  if use-column[88] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Spi_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.OutProiz-SaleSum = gds-prop.OutProiz-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.OutProiz-SaleSum = gds-prop.OutProiz-SaleSum - buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Spi_Prvo}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.OutProiz-SaleSum = gds-prop.OutProiz-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.OutProiz-SaleSum = gds-prop.OutProiz-SaleSum + buf_stk-line.sum-base .
    end.
  end.


  /* ***************************************************************************************** */
  /* нужны обороты ПЕРЕОЦЕНКА */
  if use-column[67] = yes then do: /* продажа */
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Overturn}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Per-SaleSum = gds-prop.Per-SaleSum + buf_stk-line.sum-rubl .
      else                        assign gds-prop.Per-SaleSum = gds-prop.Per-SaleSum + buf_stk-line.sum-base .
    end.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Overturn}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign gds-prop.Per-SaleSum = gds-prop.Per-SaleSum - buf_stk-line.sum-rubl .
      else                        assign gds-prop.Per-SaleSum = gds-prop.Per-SaleSum - buf_stk-line.sum-base .
    end.
  end.


  if use-column[10] = yes or use-column[11] = yes or use-column[6] = yes or use-column[7] = yes then do:
  /* прод. цены и план. наценка */
    assign
      gds-prop.Effect-Value = gds-prop.OutExt-DocSum + gds-prop.OutExtKass-DocSum
                            - gds-prop.RetOut-DocSum - gds-prop.RetOutKass-DocSum
                            - gds-prop.OutExt-CostSum - gds-prop.OutExtKass-CostSum
                            + gds-prop.RetOut-CostSum + gds-prop.RetOutKass-CostSum
      gds-prop.Up-Fact = gds-prop.Effect-Value * 100 / ( gds-prop.OutExt-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOut-CostSum - gds-prop.RetOutKass-CostSum )
      gds-prop.Avrg-Sale-Price = ( gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum + gds-prop.RetOut-SaleSum + gds-prop.RetOutKass-SaleSum ) / (  gds-prop.OutExt-Qnty + gds-prop.OutExtKass-Qnty + gds-prop.RetOut-Qnty + gds-prop.RetOutKass-Qnty )
      gds-prop.Up-Plan = (gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum
                        - gds-prop.RetOut-SaleSum - gds-prop.RetOutKass-SaleSum
                        - gds-prop.OutExt-CostSum - gds-prop.OutExtKass-CostSum
                        + gds-prop.RetOut-CostSum + gds-prop.RetOutKass-CostSum)
                        * 100 / ( gds-prop.OutExt-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOut-CostSum - gds-prop.RetOutKass-CostSum )
    .
  end.

/* $Workfile$   E n d */