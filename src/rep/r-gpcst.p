block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gpcst.p $
$Archive: rep/r-gpcst.p $

Журнал продаж с ГТД и счетами-фактурами (компания СИМПЛ) - данные и печать

Автор: Чернова Светлана Александровна
Дата создания: 07/07/09
Author: Svetlana Chernova
Creation date: 07/07/09

Author1: Alexey Suslov
Creation date: 02/19/09

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-gpcst.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-gpcst.p $":U .
def var vss-description as character no-undo init "Журнал продаж с ГТД и счетами-фактурами (компания СИМПЛ) - данные и печать".
{ cmp/vssrevis.i  }

{ cmp/str-glbl.i  }
{ cmp/library.i   }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i   }
{ cmp/r-page1.i   }
{ gbl/cur-time.i  }
{ gbl/waitfram.i  }
{ str/trdcalib.i  }

define variable sheets              as integer   no-undo.
define variable Line                as character no-undo .
define variable g#report-num        as integer   no-undo .
define variable varline-num         as integer   no-undo.
define variable v-curr-r-b as character no-undo .
define temp-table tt-gds no-undo
field out-code    like ub.chk-doc.out-code
field doc-code    like ub.chk-doc.doc-code
field gds-code    like ub.goods.gds-code
field obj-type    like ub.inkas.obj-type
field obj-code    like ub.inkas.obj-code
field artic       like ub.goods.artic
field prod-type   like ub.goods.prod-type
field prod-code   like ub.goods.prod-code
field gds-name    like ub.goods.gds-name
field prod-name   like ub.clients.obj-name
field price-base  like ub.chk-gds.price-base
field price       like ub.chk-gds.price-base
field discnt-base like ub.chk-gds.discnt
field discnt      like ub.chk-gds.discnt
field doc-qnty    like ub.chk-gds.doc-qnty initial 0.00
field sum-netto   as   decimal
field sum-brutto  as   decimal
field sum-discnt  as   decimal
field nofind-qnty as   decimal
field parts-f     as   logical
index pi is unique primary
out-code doc-code gds-code price-base discnt-base
index qnty
doc-qnty
index ret
out-code gds-code price-base discnt-base.
define temp-table tt-inkas     no-undo like ub.inkas .
define temp-table tt-exp-parts no-undo like ub.parts .
define temp-table tt-ret-parts no-undo like ub.parts .
define temp-table tt-gds-parts no-undo
field out-code    like ub.chk-doc.out-code
field doc-code    like ub.chk-doc.doc-code
field gds-code    like ub.goods.gds-code
field artic       like ub.goods.artic
field gds-name    like ub.goods.gds-name
field prod-name   like ub.clients.obj-name
field doc-qnty    like ub.chk-gds.doc-qnty initial 0.00
field price       like ub.chk-gds.price-base
field sum-brutto  as   decimal format "->,>>>,>>>,>>9.99"
field sum-discnt  as   decimal format "->,>>>,>>>,>>9.99"
field prc-discnt  as   decimal format "->9.9<%"
field sum-netto   as   decimal format "->,>>>,>>>,>>9.99"
field num-doc     as   character
field date-doc    as   date
field cst-code    like ub.parts.cst-code
field line-num    as integer
index pi is unique primary
line-num
index print-order
gds-code line-num
.
define variable varsum-qnty   like tt-gds-parts.doc-qnty   initial 0.00 no-undo.
define variable varsum-brutto like tt-gds-parts.sum-brutto no-undo.
define variable varsum-discnt like tt-gds-parts.sum-discnt no-undo.
define variable varsum-netto  like tt-gds-parts.sum-netto  no-undo.
{ gbl/curr-r-b.i v-curr-r-b }
run prn-lib-open-stream  in this-procedure ( input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

/*заполним временные таблицы*/
run fill-tt in this-procedure.
run waitfram-show in this-procedure ( {&MyWaitMess} ) .
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
            sheetf.sheet-num = 1 No-ERROR.
sheetf.sizes = "".
assign
Sheetf.Excel-Column-Lable = "Код"                        + {&comma-char} +
                            "Артикул"                    + {&comma-char} +
                            "Название"                   + {&comma-char} +
                            "Производитель"              + {&comma-char} +
                            "Кол-во"                     + {&comma-char} +
                            "Цена"                       + {&comma-char} +
                            "Сумма"                      + {&comma-char} +
                            "Сумма скидки"               + {&comma-char} +
                            "%Скидки"                    + {&comma-char} +
                            "Выручка"                    + {&comma-char} +
                            "Номер документа поставщика" + {&comma-char} +
                            "Дата документа поставщика"  + {&comma-char} +
                            "ГТД"
Sheetf.Sizes = "9,16,30,30,10,12,17,17,5,17,20,11,32"
sheetf.colformat = "1=@;2=@;12=dd/mm/yy":U
.

run rep/extitle.p (1) no-error.


for each tt-gds-parts use-index print-order:
  {&PutExcel}
  tt-gds-parts.gds-code    {&tabulation}
  tt-gds-parts.artic       {&tabulation}
  tt-gds-parts.gds-name    {&tabulation}
  tt-gds-parts.prod-name   {&tabulation}
  tt-gds-parts.doc-qnty    {&tabulation}
  tt-gds-parts.price       {&tabulation}
  tt-gds-parts.sum-brutto  {&tabulation}
  tt-gds-parts.sum-discnt  {&tabulation}
  tt-gds-parts.prc-discnt  {&tabulation}
  tt-gds-parts.sum-netto   {&tabulation}
  tt-gds-parts.num-doc     {&tabulation}
  if tt-gds-parts.date-doc  = ? then "" else string(tt-gds-parts.date-doc, "99/99/9999" )  {&tabulation}
  tt-gds-parts.cst-code    {&tabulation}
  skip.
  assign
    varsum-qnty   = varsum-qnty   + tt-gds-parts.doc-qnty
    varsum-brutto = varsum-brutto + tt-gds-parts.sum-brutto
    varsum-discnt = varsum-discnt + tt-gds-parts.sum-discnt
    varsum-netto  = varsum-netto  + tt-gds-parts.sum-netto.
END.
  {&PutExcel}
  "Итого"        {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  varsum-qnty    {&tabulation}
  ""             {&tabulation}
  varsum-brutto  {&tabulation}
  varsum-discnt  {&tabulation}
  ""             {&tabulation}
  varsum-netto   {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  ""             {&tabulation}
  skip.
output stream prnlibstream close .
{&closeExcel}

run waitfram-hide in this-procedure .
run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

procedure fill-tt:
define buffer bf_inkas                for ub.inkas.
define buffer bf_chk-doc              for ub.chk-doc.
define buffer bf_chk-gds              for ub.chk-gds.
define buffer bf_chk-pay              for ub.chk-pay.
define buffer bf-exp_trn-doc          for ub.trn-doc.
define buffer bf-ret_trn-doc          for ub.trn-doc.
define buffer bf-exp_parts            for ub.parts.
define buffer bf-ret_parts            for ub.parts.
define buffer bf_bar-code             for ub.bar-code.
define buffer bf_goods                for ub.goods.
define buffer bf_clients              for ub.clients.
define buffer bf-in_trn-doc           for ub.trn-doc.
define buffer bf-ret_tt-gds           for tt-gds.

define variable v-attr-value-nids as character no-undo.
define variable v-attr-value-dids as character no-undo.
define variable v-attr-type       as character no-undo.

define variable v-rate as decimal no-undo.
for each tt-gds :
  delete tt-gds.
end.
for each tt-gds-parts :
  delete tt-gds-parts.
end.
for each tt-inkas:
  delete tt-inkas.
end.
for each tt-exp-parts:
  delete tt-exp-parts.
end.
for each tt-ret-parts:
  delete tt-ret-parts.
end.

/*Соберем чеки расхода и возврата по закрытым журналам продаж. Объединяем товары внутри одного чека*/
for each obj-list :
  _chk-doc:
  for each bf_chk-doc where
        bf_chk-doc.obj-type =  obj-list.obj-type and
        bf_chk-doc.obj-code =  obj-list.obj-code and
        bf_chk-doc.chk-date >= x-date-start      and
        bf_chk-doc.chk-date <= x-date-end        use-index obj-date no-lock :
    if lookup(string(bf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    find first bf_inkas where bf_inkas.inkas-code = bf_chk-doc.out-code no-lock no-error.
    if not available bf_inkas or bf_inkas.status_ <> {&fact} then next _chk-doc.
    find first tt-inkas where tt-inkas.inkas-code = bf_inkas.inkas-code no-error.
    if not available tt-inkas then do:
      create tt-inkas.
      buffer-copy bf_inkas to tt-inkas.
      find first bf-exp_trn-doc where bf-exp_trn-doc.doc-code = bf_inkas.inkas-code no-lock no-error.
      if available bf-exp_trn-doc then do:
        for each bf-exp_parts where bf-exp_parts.out-code = bf-exp_trn-doc.doc-code no-lock :
          create tt-exp-parts.
          buffer-copy bf-exp_parts to tt-exp-parts.
        end.
      end.
      find first bf-ret_trn-doc where bf-ret_trn-doc.out-code = bf_inkas.inkas-code no-lock no-error.
      if available bf-ret_trn-doc then do:
        for each bf-ret_parts where bf-ret_parts.out-code = bf-ret_trn-doc.doc-code no-lock :
          create tt-ret-parts.
          buffer-copy bf-ret_parts to tt-ret-parts.
        end.
      end.
    end.
    if v-curr-r-b = {&r-b-base} then do:
      assign
        v-rate = bf_chk-doc.cash-rate / bf_chk-doc.cash-scale no-error .
      if error-status:error or
         v-rate = 0         or
         v-rate = ?         then do:
        find first bf_chk-pay where bf_chk-pay.doc-code = bf_chk-doc.doc-code no-lock no-error.
        if not available bf_chk-pay then next _chk-doc.
        assign
          v-rate = bf_chk-pay.tot-rubl / bf_chk-pay.tot-base.
      end.
    end.
    for each bf_chk-gds where
             bf_chk-gds.doc-code = bf_chk-doc.doc-code no-lock :
       find first bf_bar-code where bf_bar-code.b-code  = bf_chk-gds.b-code    no-lock.
       find first bf_goods    where bf_goods.gds-code   = bf_bar-code.gds-code no-lock.
       find first bf_clients  where bf_clients.obj-type = bf_goods.prod-type   and
                                    bf_clients.obj-code = bf_goods.prod-code   no-lock.
       find first tt-gds where tt-gds.out-code    = bf_chk-doc.out-code    and
                               tt-gds.doc-code    = bf_chk-doc.doc-code    and
                               tt-gds.gds-code    = bf_goods.gds-code      and
                               tt-gds.price-base  = bf_chk-gds.price-base  and
                               tt-gds.discnt-base = bf_chk-gds.discnt      no-error.
       if not available tt-gds then do:
         create tt-gds.
         assign
           tt-gds.out-code    = bf_chk-doc.out-code
           tt-gds.doc-code    = bf_chk-doc.doc-code
           tt-gds.gds-code    = bf_goods.gds-code
           tt-gds.obj-type    = bf_inkas.obj-type
           tt-gds.obj-code    = bf_inkas.obj-code
           tt-gds.artic       = bf_goods.artic
           tt-gds.prod-type   = bf_goods.prod-type
           tt-gds.prod-code   = bf_goods.prod-code
           tt-gds.gds-name    = bf_goods.gds-name
           tt-gds.prod-name   = bf_clients.obj-name
           tt-gds.price-base  = bf_chk-gds.price-base
           tt-gds.discnt-base = bf_chk-gds.discnt
           tt-gds.price       = (if v-curr-r-b = {&r-b-base} then round(bf_chk-gds.price-base * v-rate, 2) else bf_chk-gds.price-base)
           tt-gds.discnt      = (if v-curr-r-b = {&r-b-base} then round(bf_chk-gds.discnt     * v-rate, 2) else bf_chk-gds.discnt)
           .
       end.
       assign
         tt-gds.doc-qnty    = tt-gds.doc-qnty   + bf_chk-gds.doc-qnty
         tt-gds.nofind-qnty = tt-gds.doc-qnty
         tt-gds.parts-f     = no
         tt-gds.sum-brutto  = tt-gds.sum-brutto + tt-gds.price                   * bf_chk-gds.doc-qnty
         tt-gds.sum-discnt  = tt-gds.sum-discnt + tt-gds.discnt                  * bf_chk-gds.doc-qnty
         tt-gds.sum-netto   = tt-gds.sum-netto  + (tt-gds.price - tt-gds.discnt) * bf_chk-gds.doc-qnty
       .

    end.
  end.
end.
/*Скомпенсируем чеки возврата. По утверждению Натальи Бахтадзе компенсация не нужна
for each bf-ret_tt-gds where bf-ret_tt-gds.doc-qnty < 0 :
  assign
    varret-qnty = - bf-ret_tt-gds.doc-qnty.
  _tt-gds:
  for each tt-gds where tt-gds.out-code    = bf-ret_tt-gds.out-code    and
                        tt-gds.gds-code    = bf-ret_tt-gds.gds-code    and
                        tt-gds.price-base  = bf-ret_tt-gds.price-base  and
                        tt-gds.discnt-base = bf-ret_tt-gds.discnt-base and
                        tt-gds.doc-qnty    > 0:
    if varret-qnty >= tt-gds.doc-qnty then do:
      assign
        varret-qnty = varret-qnty - tt-gds.doc-qnty.
      assign
        bf-ret_tt-gds.doc-qnty   = bf-ret_tt-gds.doc-qnty   - tt-gds.doc-qnty
        bf-ret_tt-gds.sum-brutto = bf-ret_tt-gds.sum-brutto - tt-gds.sum-brutto
        bf-ret_tt-gds.sum-discnt = bf-ret_tt-gds.sum-discnt - tt-gds.sum-discnt
        bf-ret_tt-gds.sum-netto  = bf-ret_tt-gds.sum-netto  - tt-gds.sum-netto
      .
      delete tt-gds.
      if varret-qnty = 0 then do:
        delete bf-ret_tt-gds.
        leave _tt-gds.
      end.
    end.
    else do:
      assign
        tt-gds.doc-qnty   = tt-gds.doc-qnty   + bf-ret_tt-gds.doc-qnty
        tt-gds.sum-brutto = tt-gds.sum-brutto + bf-ret_tt-gds.sum-brutto
        tt-gds.sum-discnt = tt-gds.sum-discnt + bf-ret_tt-gds.sum-discnt
        tt-gds.sum-netto  = tt-gds.sum-netto  + bf-ret_tt-gds.sum-netto
      .
      delete bf-ret_tt-gds.
      leave _tt-gds.
    end.
  end.
end.
*/
for each tt-gds where tt-gds.doc-qnty = 0 :
  delete tt-gds.
end.
assign
  varline-num = 0.
/*Строим связку с партиями*/
for each tt-gds no-lock :
  if tt-gds.doc-qnty > 0 then do:
    _tt-exp-parts:
    for each tt-exp-parts where tt-exp-parts.out-code  = tt-gds.out-code  and
                                tt-exp-parts.obj-type  = tt-gds.obj-type  and
                                tt-exp-parts.obj-code  = tt-gds.obj-code  and
                                tt-exp-parts.artic     = tt-gds.artic     and
                                tt-exp-parts.prod-type = tt-gds.prod-type and
                                tt-exp-parts.prod-code = tt-gds.prod-code :
      assign
        v-attr-value-nids = ""
        v-attr-value-dids = ""
        v-attr-type       = "".
      find first bf-in_trn-doc where bf-in_trn-doc.doc-code = tt-exp-parts.in-code no-lock no-error.
      if available bf-in_trn-doc then do:
        { str/tdat-val.i
          bf-in_trn-doc.doc-code
          {&trdcattr-nids}
          v-attr-value-nids
          v-attr-type
        }
        { str/tdat-val.i
          bf-in_trn-doc.doc-code
          {&trdcattr-dids}
          v-attr-value-dids
          v-attr-type
        }
      end.
      if tt-gds.nofind-qnty >= tt-exp-parts.fact-qnty then do:
        assign
          varline-num = varline-num + 1.
        create tt-gds-parts.
        assign
          tt-gds-parts.out-code    = tt-gds.out-code
          tt-gds-parts.doc-code    = tt-gds.doc-code
          tt-gds-parts.gds-code    = tt-gds.gds-code
          tt-gds-parts.artic       = tt-gds.artic
          tt-gds-parts.gds-name    = tt-gds.gds-name
          tt-gds-parts.prod-name   = tt-gds.prod-name
          tt-gds-parts.doc-qnty    = tt-exp-parts.fact-qnty
          tt-gds-parts.price       = tt-gds.price
          tt-gds-parts.sum-brutto  = tt-gds.sum-brutto * (if tt-exp-parts.fact-qnty = tt-gds.doc-qnty then 1 else tt-exp-parts.fact-qnty / tt-gds.doc-qnty)
          tt-gds-parts.sum-discnt  = tt-gds.sum-discnt * (if tt-exp-parts.fact-qnty = tt-gds.doc-qnty then 1 else tt-exp-parts.fact-qnty / tt-gds.doc-qnty)
          tt-gds-parts.prc-discnt  = tt-gds-parts.sum-discnt / tt-gds-parts.sum-brutto * 100
          tt-gds-parts.sum-netto   = tt-gds.sum-netto  * (if tt-exp-parts.fact-qnty = tt-gds.doc-qnty then 1 else tt-exp-parts.fact-qnty / tt-gds.doc-qnty)
          tt-gds-parts.num-doc     = (if available bf-in_trn-doc then v-attr-value-nids else "Нет ВПН")
          tt-gds-parts.date-doc    = (if available bf-in_trn-doc then DATE(v-attr-value-dids) else ?)
          tt-gds-parts.cst-code    = tt-exp-parts.cst-code
          tt-gds-parts.line-num    = varline-num
        .
        assign
          tt-gds.nofind-qnty = tt-gds.nofind-qnty - tt-exp-parts.fact-qnty.
        delete tt-exp-parts.
        /*Равенство*/
        if tt-gds.nofind-qnty = 0 then do:
          delete tt-gds.
          leave _tt-exp-parts.
        end.
      end.
      else do:
        assign
          varline-num = varline-num + 1.
        create tt-gds-parts.
        assign
          tt-gds-parts.out-code    = tt-gds.out-code
          tt-gds-parts.doc-code    = tt-gds.doc-code
          tt-gds-parts.gds-code    = tt-gds.gds-code
          tt-gds-parts.artic       = tt-gds.artic
          tt-gds-parts.gds-name    = tt-gds.gds-name
          tt-gds-parts.prod-name   = tt-gds.prod-name
          tt-gds-parts.doc-qnty    = tt-gds.nofind-qnty
          tt-gds-parts.price       = tt-gds.price
          tt-gds-parts.sum-brutto  = tt-gds.sum-brutto * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.sum-discnt  = tt-gds.sum-discnt * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.prc-discnt  = tt-gds-parts.sum-discnt / tt-gds-parts.sum-brutto * 100
          tt-gds-parts.sum-netto   = tt-gds.sum-netto  * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.num-doc     = (if available bf-in_trn-doc then v-attr-value-nids else "Нет ВПН")
          tt-gds-parts.date-doc    = (if available bf-in_trn-doc then DATE(v-attr-value-dids) else ?  )
          tt-gds-parts.cst-code    = tt-exp-parts.cst-code
          tt-gds-parts.line-num    = varline-num
        .
        assign
          tt-exp-parts.fact-qnty = tt-exp-parts.fact-qnty - tt-gds.nofind-qnty.
        delete tt-gds.
        leave _tt-exp-parts.
      end.
    end.
  end.
  else do:
    find first bf-ret_trn-doc where bf-ret_trn-doc.out-code = tt-gds.out-code no-lock no-error.
    if not available bf-ret_trn-doc then do:
      message "Есть возвратная партия по товару " tt-gds.artic " " tt-gds.prod-type " " tt-gds.prod-code " в количестве " tt-gds.doc-qnty " из журнала продаж " tt-gds.out-code ". Не найдена накладная возврата."
      view-as alert-box error.
      return error.
    end.
    _tt-ret-parts:
    for each tt-ret-parts where tt-ret-parts.out-code  = bf-ret_trn-doc.doc-code  and
                                tt-ret-parts.obj-type  = tt-gds.obj-type          and
                                tt-ret-parts.obj-code  = tt-gds.obj-code          and
                                tt-ret-parts.artic     = tt-gds.artic             and
                                tt-ret-parts.prod-type = tt-gds.prod-type         and
                                tt-ret-parts.prod-code = tt-gds.prod-code         :
      assign
        v-attr-value-nids = ""
        v-attr-value-dids = ""
        v-attr-type       = "".
      find first bf-in_trn-doc where bf-in_trn-doc.doc-code = tt-ret-parts.in-code no-lock no-error.
      if available bf-in_trn-doc then do:

        { str/tdat-val.i
          bf-in_trn-doc.doc-code
          {&trdcattr-nids}
           v-attr-value-nids
           v-attr-type
         }


        { str/tdat-val.i
          bf-in_trn-doc.doc-code
         {&trdcattr-dids}
          v-attr-value-dids
          v-attr-type
          }

      end.
      if - tt-gds.nofind-qnty >= tt-ret-parts.fact-qnty then do:
        assign
          varline-num = varline-num + 1.
        create tt-gds-parts.
        assign
          tt-gds-parts.out-code    = tt-gds.out-code
          tt-gds-parts.doc-code    = tt-gds.doc-code
          tt-gds-parts.gds-code    = tt-gds.gds-code
          tt-gds-parts.artic       = tt-gds.artic
          tt-gds-parts.gds-name    = tt-gds.gds-name
          tt-gds-parts.prod-name   = tt-gds.prod-name
          tt-gds-parts.doc-qnty    = - tt-ret-parts.fact-qnty
          tt-gds-parts.price       = tt-gds.price
          tt-gds-parts.sum-brutto  = tt-gds.sum-brutto * (if tt-ret-parts.fact-qnty = - tt-gds.doc-qnty then 1 else tt-ret-parts.fact-qnty / - tt-gds.doc-qnty)
          tt-gds-parts.sum-discnt  = tt-gds.sum-discnt * (if tt-ret-parts.fact-qnty = - tt-gds.doc-qnty then 1 else tt-ret-parts.fact-qnty / - tt-gds.doc-qnty)
          tt-gds-parts.prc-discnt  = tt-gds-parts.sum-discnt / tt-gds-parts.sum-brutto * 100
          tt-gds-parts.sum-netto   = tt-gds.sum-netto  * (if tt-ret-parts.fact-qnty = - tt-gds.doc-qnty then 1 else tt-ret-parts.fact-qnty / - tt-gds.doc-qnty)
          tt-gds-parts.num-doc     = (if available bf-in_trn-doc then v-attr-value-nids       else "Нет ВПН")
          tt-gds-parts.date-doc    = (if available bf-in_trn-doc then DATE(v-attr-value-dids) else ?        )
          tt-gds-parts.cst-code    = tt-ret-parts.cst-code
          tt-gds-parts.line-num    = varline-num
        .
        assign
          tt-gds.nofind-qnty = tt-gds.nofind-qnty + tt-ret-parts.fact-qnty.
        delete tt-ret-parts.
        /*Равенство*/
        if tt-gds.nofind-qnty = 0 then do:
          delete tt-gds.
          leave _tt-ret-parts.
        end.
      end.
      else do:
        assign
          varline-num = varline-num + 1.
        create tt-gds-parts.
        assign
          tt-gds-parts.out-code    = tt-gds.out-code
          tt-gds-parts.doc-code    = tt-gds.doc-code
          tt-gds-parts.gds-code    = tt-gds.gds-code
          tt-gds-parts.artic       = tt-gds.artic
          tt-gds-parts.gds-name    = tt-gds.gds-name
          tt-gds-parts.prod-name   = tt-gds.prod-name
          tt-gds-parts.doc-qnty    = tt-gds.nofind-qnty
          tt-gds-parts.price       = tt-gds.price
          tt-gds-parts.sum-brutto  = tt-gds.sum-brutto * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.sum-discnt  = tt-gds.sum-discnt * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.prc-discnt  = tt-gds-parts.sum-discnt / tt-gds-parts.sum-brutto * 100
          tt-gds-parts.sum-netto   = tt-gds.sum-netto  * (if tt-gds.nofind-qnty = tt-gds.doc-qnty then 1 else tt-gds.nofind-qnty / tt-gds.doc-qnty)
          tt-gds-parts.num-doc     = (if available bf-in_trn-doc then v-attr-value-nids       else "Нет ВПН")
          tt-gds-parts.date-doc    = (if available bf-in_trn-doc then DATE(v-attr-value-dids) else ?        )
          tt-gds-parts.cst-code    = tt-ret-parts.cst-code
          tt-gds-parts.line-num    = varline-num
        .
        assign
          tt-ret-parts.fact-qnty = tt-ret-parts.fact-qnty + tt-gds.nofind-qnty.
        delete tt-gds.
        leave _tt-ret-parts.
      end.
    end.
  end.
end. /*for each tt-gds*/
define variable varerror as logical no-undo.
/*Проверим, что чеки погасили партии*/
for each tt-gds where tt-gds.doc-qnty >   0.01 and
                       tt-gds.doc-qnty < - 0.01 :
  message "Остались непогашенные чеки по товару " tt-gds.artic " " tt-gds.prod-type " " tt-gds.prod-code " в количестве " tt-gds.doc-qnty " из журнала продаж " tt-gds.out-code skip
  view-as alert-box error.
  assign
    varerror = yes.
end.
for each tt-exp-parts where tt-exp-parts.fact-qnty > 0.01 :
  message "Остались непогашенные расходные партии по товару " tt-exp-parts.artic " " tt-exp-parts.prod-type " " tt-exp-parts.prod-code " в количестве " tt-exp-parts.fact-qnty " из журнала продаж " tt-exp-parts.out-code skip
  view-as alert-box error.
  assign
    varerror = yes.
end.
for each tt-ret-parts where tt-ret-parts.fact-qnty < -0.01 :
  message "Остались непогашенные возвратные партии по товару " tt-ret-parts.artic " " tt-ret-parts.prod-type " " tt-ret-parts.prod-code " в количестве " tt-ret-parts.fact-qnty " из журнала продаж " tt-ret-parts.out-code skip
  view-as alert-box error.
  assign
    varerror = yes.
end.
if varerror = yes then do:
  return error.
end.
end procedure.