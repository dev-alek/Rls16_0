block-level on error undo, throw.
/*

$Revision: cc275b2610da, 3580, rls $
$Author: EShklyar $
$Date: 2023/12/14 13:36:13 $
$Workfile: r-pychk2.p $
$Archive: cus/r-pychk2.p $

Суммы продаж с разбивкой по типам кассовых платежей и НДС - печать

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/09/04
Author: Bakhtadze Natalya
Creation date: 07/09/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-group as logical no-undo .
define input parameter p-rv    as logical no-undo .
/*расходы возвраты отдельно*/

define variable vss-revision    as character no-undo init "$Revision: cc275b2610da, 3580, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pychk2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-pychk2.p $":U .
define variable vss-description as character no-undo init "Суммы продаж с разбивкой по типам кассовых платежей и НДС - печать".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
/*{ rep/real3tm.i rep }*/
{ rep/rl-3df-4.i "NEW SHARED" }
{ gbl/cur-time.i }
{ cus/real-vat.i "SHARED" treal-vat }
{ rep/r-pychk0.i defalgo }

&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."
DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
DEFINE VARIABLE cas-num as integer no-undo.
DEFINE VARIABLE found as logical init yes no-undo.
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable inkas-uslugi1 as character no-undo .
define variable inkas-uslugi2 as character no-undo .

define buffer buf_inkas for ub.inkas.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_doc-line for ub.doc-line.

&scop   page-excel-block  if ii-excel > 32000 then do:                                    ~
                           {&pageExcel}                                               ~
                           find first buf_sheetf where                                ~
                                     buf_sheetf.sheet-num = ii-page + 1 no-error.     ~
                           if not available buf_sheetf then do:                       ~
                             create buf_sheetf.                                       ~
                           end.                                                       ~
                           buffer-copy buf1_sheetf except sheet-num                   ~
                           to buf_sheetf                                              ~
                           assign                                                     ~
                           buf_sheetf.sheet-num = ii-page + 1                         ~
                           .                                                          ~
                           run rep/extitle.p (ii-page) .                                   ~
                           assign                                                     ~
                           ii-page = ii-page + 1                                      ~
                           ii-excel = 0                                               ~
                           .                                                          ~
                         end

run waitfram-show in this-procedure ("Ждите...").

/*соберем данные*/

for each treal-3:
  delete treal-3.
end.

for each treal-vat:
  delete treal-vat.
end.

/* Обработка выбора даты и смены в отчёте. */
_realize-filter--Date-and-Shift:
FOR EACH obj-list No-LOCK:
    if x-tog-shift = no then do:
   for each  buf_Inkas no-lock where
            buf_inkas.fact-date     >= x-date-start
        AND buf_inkas.fact-date     <= x-date-end
        AND buf_inkas.obj-type   = obj-list.obj-type
        AND buf_inkas.obj-code   = obj-list.obj-code
        AND buf_inkas.status_     = {&fact}:
            run process-inkas in this-procedure (buffer buf_inkas).
        end. /* for each  buf_Inkas no-lock where */
    end. /* if x-tog-shift = no then do: */
    else do:
        for each buf_Inkas no-lock where
                buf_inkas.shift-date   >= x-date-start
            AND buf_inkas.shift-date   <= x-date-end
            AND buf_inkas.obj-type      = obj-list.obj-type
            AND buf_inkas.obj-code      = obj-list.obj-code
            AND buf_inkas.status_       = {&fact}:
                if buf_inkas.shift-date = x-date-start and buf_inkas.shift-num < x-shift-start then next.
                if buf_inkas.shift-date = x-date-end and buf_inkas.shift-num > x-shift-end then next.
                run process-inkas in this-procedure (buffer buf_inkas).
                
        end. /* for each buf_Inkas no-lock where */
    end. /* else do: */
    
END. /*FOR EACH OBJ-LIST*/

run waitfram-hide in this-procedure .

run printproc in this-procedure.

procedure process-inkas :
define parameter buffer buf_inkas for ub.inkas.

{ rep/r-pychk4.i def }

DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable p-by-pay-desk as logical no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_goods   for ub.goods.
define buffer pay_treal-vat for treal-vat.
define buffer pay0_treal-vat for treal-vat.
define buffer gen_treal-vat for treal-vat.
define buffer gen0_treal-vat for treal-vat.
define buffer buf_doc-line for ub.doc-line.
define variable v-ret-doc-code like ub.trn-doc.doc-code no-undo .
define variable v-grp-code as character no-undo .
define buffer buf_tt-cash-pay  for tt-cash-pay.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.


&scop create-treal-vat  if p-group then do:                                  ~
    find first buf_tt-cash-pay no-lock where                                 ~
              buf_tt-cash-pay.cdpay-code = treal-3.cpay-code                 ~
          AND buf_tt-cash-pay.curr-code = treal-3.curr-code no-error.        ~
    if buf_tt-cash-pay.grp-code = ~{&delim-par~} + "0":U then do:            ~
      assign                                                                 ~
      v-grp-code = string(treal-3.cpay-code) + ~{&delim-par~} +              ~
                   string(treal-3.curr-code)                                 ~
      .                                                                      ~
    end.                                                                     ~
    else do:                                                                 ~
      assign                                                                 ~
      v-grp-code = buf_tt-cash-pay.grp-code                                  ~
      .                                                                      ~
    end.                                                                     ~
  end.                                                                       ~
  else do:                                                                   ~
    assign                                                                   ~
    v-grp-code = string(treal-3.cpay-code) + ~{&delim-par~} +                ~
                 string(treal-3.curr-code)                                   ~
    .                                                                        ~
  end.                                                                       ~
                       find first treal-vat where                            ~
          treal-vat.inkas-code = buf_Inkas.inkas-code                        ~
      AND treal-vat.vat-pc = treal-3.vat-pc                                  ~
      AND treal-vat.grp-code = v-grp-code                                    ~
      AND treal-vat.rv   = treal-3.rv  no-error .                            ~
                       find first pay_treal-vat where                        ~
          pay_treal-vat.inkas-code = "":U                                    ~
      AND pay_treal-vat.vat-pc = treal-3.vat-pc                              ~
      AND pay_treal-vat.grp-code = v-grp-code                                ~
      AND pay_treal-vat.rv = treal-3.rv                no-error .            ~
      if p-rv then do:                                                       ~
                       find first pay0_treal-vat where                       ~
          pay0_treal-vat.inkas-code = "":U                                   ~
      AND pay0_treal-vat.vat-pc = treal-3.vat-pc                             ~
      AND pay0_treal-vat.grp-code = v-grp-code                               ~
      AND pay0_treal-vat.rv = 0                         no-error .           ~
      end.                                                                   ~
                       find first gen_treal-vat where                        ~
          gen_treal-vat.inkas-code = "":U                                    ~
      AND gen_treal-vat.vat-pc = treal-3.vat-pc                              ~
      AND gen_treal-vat.grp-code  = "":U                                     ~
      AND gen_treal-vat.rv = treal-3.rv  no-error .                          ~
      if p-rv then do:                                                       ~
                       find first gen0_treal-vat where                       ~
          gen0_treal-vat.inkas-code = "":U                                   ~
      AND gen0_treal-vat.vat-pc = treal-3.vat-pc                             ~
      AND gen0_treal-vat.grp-code  = "":U                                    ~
      AND gen0_treal-vat.rv = 0  no-error .                                  ~
      end .                                                                  ~
if not available treal-vat then do:                                          ~
  create treal-vat.                                                          ~
  assign                                                                     ~
  treal-vat.inkas-code = buf_inkas.inkas-code                                ~
  treal-vat.doc-date   = buf_inkas.fact-date                                 ~
  treal-vat.fact-order = buf_trn-doc.fact-order                              ~
  treal-vat.grp-code   = v-grp-code                                          ~
  treal-vat.vat-pc     = treal-3.vat-pc                                      ~
  treal-vat.rv         = treal-3.rv                                          ~
  .                                                                          ~
end.                                                                         ~
if not available pay_treal-vat then do:                                      ~
  create pay_treal-vat.                                                      ~
  assign                                                                     ~
  pay_treal-vat.inkas-code = "":U                                            ~
  pay_treal-vat.fact-order = 0                                               ~
  pay_treal-vat.grp-code = v-grp-code                                        ~
  pay_treal-vat.vat-pc     = treal-3.vat-pc                                  ~
  pay_treal-vat.rv         = treal-3.rv                                      ~
  .                                                                          ~
end.                                                                         ~
if P-RV AND not available pay0_treal-vat then do:                            ~
  create pay0_treal-vat.                                                     ~
  assign                                                                     ~
  pay0_treal-vat.inkas-code = "":U                                           ~
  pay0_treal-vat.fact-order = 0                                              ~
  pay0_treal-vat.grp-code = v-grp-code                                       ~
  pay0_treal-vat.vat-pc     = treal-3.vat-pc                                 ~
  pay0_treal-vat.rv         = 0                                              ~
  .                                                                          ~
end.                                                                         ~
if not available gen_treal-vat then do:                                      ~
  create gen_treal-vat.                                                      ~
  assign                                                                     ~
  gen_treal-vat.inkas-code = "":U                                            ~
  gen_treal-vat.grp-code   = "":U                                            ~
  gen_treal-vat.vat-pc     = treal-3.vat-pc                                  ~
  gen_treal-vat.rv         = treal-3.rv                                      ~
  .                                                                          ~
end.                                                                         ~
if P-RV AND not available gen0_treal-vat then do:                            ~
  create gen0_treal-vat.                                                     ~
  assign                                                                     ~
  gen0_treal-vat.inkas-code = "":U                                           ~
  gen0_treal-vat.grp-code   = "":U                                           ~
  gen0_treal-vat.vat-pc     = treal-3.vat-pc                                 ~
  gen0_treal-vat.rv         = 0                                              ~
  .                                                                          ~
end
&scop create-treal-vat2                                                      ~
assign                                                                       ~
treal-vat.netto = treal-vat.netto + treal-3.netto-inkas                      ~
treal-vat.netto-rubl = treal-vat.netto-rubl + treal-3.netto-rubl-inkas       ~
pay_treal-vat.netto = pay_treal-vat.netto + treal-3.netto-inkas              ~
pay_treal-vat.netto-rubl = pay_treal-vat.netto-rubl + treal-3.netto-rubl-inkas ~
gen_treal-vat.netto = gen_treal-vat.netto + treal-3.netto-inkas              ~
gen_treal-vat.netto-rubl = gen_treal-vat.netto-rubl + treal-3.netto-rubl-inkas ~
.                                                                              ~
if p-rv then do:                                                               ~
  assign                                                                       ~
  pay0_treal-vat.netto = pay0_treal-vat.netto + treal-3.netto-inkas              ~
  pay0_treal-vat.netto-rubl = pay0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas ~
  gen0_treal-vat.netto = gen0_treal-vat.netto + treal-3.netto-inkas              ~
  gen0_treal-vat.netto-rubl = gen0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas ~
  .                                                                               ~
end


/*точку не стаивм для проверки синтаксиса*/



do
on error undo, return error
:

{ gbl/curr-r-b.i
  v-curr-r-b
}


  { gbl/basecode.i buf_inkas.host-code v-base-code }
  assign
  v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
  v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
  .
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code no-error. /* Добавил, т.к. в случае не нахождения по условию, у клиента выскочит ошибка от Progress (Хотя программа продолжит работу). Арн. 2013г TH-#3034 */
  find first buf_ret-doc no-lock where
            buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
  if available buf_ret-doc then
  assign
  v-ret-doc-code = buf_ret-doc.doc-code
  .

  /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
  run rep/rpychk0.p ( input "r-pychk2"
                      ,input buf_inkas.obj-type
                      ,input buf_inkas.obj-code
                      ,input ? /*p-date-from*/
                      ,input ? /*p-date-to*/
                      ,input ? /*p-shift-date-from*/
                      ,input ? /*p-shift-date-to*/
                      ,input ? /*p-shift-num-start*/
                      ,input ? /*p-shift-num-end*/
                      ,input buf_inkas.inkas-code /*p-inkas-code*/
                      ).


  _chk-doc:
  FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = buf_inkas.inkas-code:
    if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    pychk_rv = (if p-rv
            then (if ub.chk-doc.netto >= 0 then 1 else - 1)
            else 0).
    for each buf_chk-gds-pay no-lock where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = {&current-algo-1},
        first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds-pay.b-code,
        first buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code
        and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code:
      { rep/r-pychk4.i }
    end.
  END. /*FOR EACH ub.chk-doc No-LOCK WHERE*/
  /*заполним vat*/
  /*пройдем по всем записям, которые обновлялись  в текущей продаже */
  inkas-uslugi1 = entry(1,buf_inkas.inkas-code,"-") + "у-" + entry(2,buf_inkas.inkas-code,"-") .  
  inkas-uslugi2 = entry(1,buf_inkas.inkas-code,"-") + "у=" + entry(2,buf_inkas.inkas-code,"-") .  
  
  _doc-line:
  FOR EACH treal-3 where
          treal-3.vat-pc = - 1,
      FIRST buf_goods no-lock where
            buf_goods.gds-code = treal-3.gds-code:
    if not p-rv or treal-3.rv = 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = buf_inkas.inkas-code AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        {&create-treal-vat}.
        {&create-treal-vat2}.
        NEXT _doc-line.
      end.
    end.
    if (not p-rv and  not available buf_doc-line)
    or treal-3.rv = - 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = v-ret-doc-code AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        {&create-treal-vat}.
        {&create-treal-vat2}.
        NEXT _doc-line.
      end.
    end.
    /*для услуг*/
    
     if not p-rv or treal-3.rv = 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = inkas-uslugi1 AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        {&create-treal-vat}.
        {&create-treal-vat2}.
        NEXT _doc-line.
      end.
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code begins inkas-uslugi2 AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        {&create-treal-vat}.
        {&create-treal-vat2}.
        NEXT _doc-line.
      end.      
    end.
  end. /*for each treal-3*/
end.

end procedure. /* process-inkas */

procedure printproc :
define variable v-only-excel as logical no-undo .
define variable f-cash-pay-name like ub.cash-pay.obj-name no-undo .
define variable f-inkas-code like ub.inkas.inkas-code no-undo .
define variable f-sum-rubl-3 as decimal no-undo .
define variable f-sum-base-4 as decimal no-undo .
define variable f-sum-rubl-4 as decimal no-undo .
define variable f-sum-base as decimal no-undo .

DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill30 as character no-undo.
define variable ii as integer no-undo .
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
define variable accum-netto as decimal no-undo extent 3.
define variable accum-netto-rubl as decimal no-undo extent 3.
define variable glog as logical no-undo .
define variable col-ii as integer no-undo .
define variable col-jj as integer no-undo .
define variable v-page-num as integer no-undo init -1.
define variable v-header as character no-undo .
define variable v-r-b as logical no-undo .
define variable v-rubl as logical no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-header-curr as character no-undo .
define variable v-curr-abbr as character no-undo .
define variable irv as integer no-undo .
define variable irv-start as integer no-undo .
define variable irv-end as integer no-undo .
define variable col-trail as integer no-undo .
define variable col-fix as integer no-undo .
define variable num-vats as integer no-undo .
define variable iext as integer no-undo .
define variable irv2 as integer no-undo .
define variable v-first-found-vat as logical no-undo .
define variable v-first-found-rv as logical no-undo .
define variable jj as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer gen_treal-vat for treal-vat.
define buffer gen0_treal-vat for treal-vat.
define buffer pay_treal-vat for treal-vat.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_currency for ub.currency.


&SCOPED-DEFINE f-sums "->>,>>>,>>>,>>9.99"
&SCOPED-DEFINE f-sums-xls '0.00'

&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.

&scop  get-grp-pay-name      if p-group and ~{&grp-code~}      begins {&delim-par} then do:            ~
  find first buf_tt-cash-group no-lock where                                                           ~
            buf_tt-cash-group.grp-code = ~{&grp-code~} no-error .                                      ~
  if available buf_tt-cash-group then do:                                                              ~
    assign                                                                                             ~
    f-cash-pay-name  = "Группа: " + buf_tt-cash-group.obj-name                                         ~
    .                                                                                                  ~
  end.                                                                                                 ~
  else do:                                                                                             ~
    assign                                                                                             ~
    f-cash-pay-name  = "Неизвестная группа касс.платежа"                                               ~
    .                                                                                                  ~
  end.                                                                                                 ~
end.                                                                                                   ~
else do:                                                                                               ~
  find first buf_cash-pay no-lock where                                                                ~
            buf_cash-pay.cdpay-code = integer(entry(1, ~{&grp-code~}, {&delim-par}))                   ~
        AND buf_cash-pay.curr-code = integer(entry(2, ~{&grp-code~}, {&delim-par})) no-error .         ~
  if available buf_cash-pay then do:                                                                   ~
    assign                                                                                             ~
    f-cash-pay-name = buf_cash-pay.obj-name                                                            ~
    .                                                                                                  ~
  end.                                                                                                 ~
  else do:                                                                                             ~
    assign                                                                                             ~
    f-cash-pay-name  = "Неизвестный тип. касс.платежа"                                                 ~
    .                                                                                                  ~
  end.                                                                                                 ~
end



define buffer buf_treal-vat for treal-vat.
&scop rv-name entry(lookup(string(~{&rv-code~}), "1,-1,0"), " Расход,Возврат,Рас+Взвр")

&scop irv irv + 2
&scop gen 2
/*получается возврат 1 общая сумма 2 расход 3*/

  do
  on error undo, return error
  :
    { gbl/curr-r-b.i
      v-curr-r-b
    }


    assign
    sheetf.Excel-Column-Lable =  "Продажа,Дата док.,Тип кассового платежа" +
                                 (if p-rv then ",Рас/Взв" else '':U)
    sheetf.colformat = "2=dd/mm/yyyy"
    sheetf.sizes = "16,10,30" +  (if p-rv then ",7" else '':U)
    v-header = string("Продажа", "X(16)") + {&space-char} +
               string("Дата док.", "X(10)") + {&space-char} +
               string("Тип кассового платежа", "X(30)")  + {&space-char}  +
               (if p-rv then (string("Рас/Взвр", "X(7)")  + {&space-char})
                else '':U)
    /*можно ли печатать в r-b*/
    v-r-b = (if v-curr-r-b = {&r-b-rubl} or v-one-curr-code then yes else no)
    /*печатаем р у б л и ? */
    v-rubl =(if not v-r-b or (v-r-b = yes and v-curr-r-b = {&r-b-rubl})
            then yes
            else no)
    .
    if v-rubl = yes then do:
      assign
      v-header-curr = string( "(Все суммы в {&abbr_rublyah})" )
      .
    end.
    else do:
      find first buf_currency no-lock where
                buf_currency.curr-code = v-curr-code no-error .
      assign
      v-header-curr = string( "(Все суммы в " +
                             (if available buf_currency
                             then buf_currency.curr-abbr
                             else string(v-curr-code)) + ")"
                            )
      .
    end.

    if p-rv then do:
      assign
      irv-start = 1
      irv-end = - 1
      col-fix  = 59
      col-trail = 67
      .
    end.
    else do:
      assign
      col-fix  = 59
      col-trail = 59
      irv-start = 0
      irv-end = 0
      .
    end.

    /*проверим сколько типов НДС получилось*/
    for each gen0_treal-vat no-lock where
            gen0_treal-vat.inkas-code = "":U
        AND gen0_treal-vat.grp-code   = ""
        AND gen0_treal-vat.rv   = 0
    break
    by gen0_treal-vat.vat-pc:
      if first-of(gen0_treal-vat.vat-pc) then do:
        assign
        num-vats = num-vats + 1
        sheetf.Excel-Column-Lable =  sheetf.Excel-Column-Lable + {&comma-char} + "Товар с НДС" + {&space-char} + string(gen0_treal-vat.vat-pc, ">9.99")
        sheetf.sizes = sheetf.sizes + {&comma-char} +  "20"
        v-header   = v-header + string("Товар с НДС" + {&space-char} + string(gen0_treal-vat.vat-pc, ">9.99"), "X(20)")
        .
      end.
    end.  /*for each gen0_treal-vat no-lock where*/

    assign
    sheetf.Excel-Column-Lable =  sheetf.Excel-Column-Lable + {&comma-char} + "Итого по всем НДС"
    sheetf.sizes = sheetf.sizes + {&comma-char} +  "20"
    v-header = v-header + string("Итого по всем НДС", "X(20)")
    .
    /*общее число колонок num-vats + 4 + (if p-rv then 1 else 0)*/
    if num-vats >= (if p-rv then 5 else 6) then do:
      assign
      v-only-excel = yes
      .
      message
      "Общая ширина интересующих Вас колонок больше 198" skip
      "отчет не уместится на бумаге формата А4 (ориентация альбомная)"
      "Выводить только в Excel?"
      view-as alert-box QUESTION buttons yes-no update glog.
      if not glog then do:
        run waitfram-hide in this-procedure .
        return.
      end.
    end.
    DEFINE FRAME OutFrame
    HEADER
    cur-time-print() AT 5 format "X(35)"
    string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 70 format "X(23)" SKIP
    Line format "X(195)" AT 1 skip
    v-header format "X(195)" AT 1
    with width {&DOS_CW_2} down stream-io.

    FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.

    run waitfram-show in this-procedure ("Ждите..." ).

    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input {&LS_PS_A4}
                                                ,input yes /*p-is-stream*/
                                                ,input no /*p-append*/
                                                ).
    assign
    str3 = v-header-curr.
    run rep/extitle.p (1).
    run waitfram-show in this-procedure ("Ждите..." ).
    find first buf1_sheetf no-lock where
              buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.

    PUT stream PrnLibStream UNFORMATTED
    "Суммы продаж с разбивкой по типам кассовых платежей и НДС"
    format "x(50)" SKIP(1).
    if p-rv then do:
      PUT stream PrnLibStream UNFORMATTED
      "Раздельно по чекам продажи и возврата"
      format "x(50)" SKIP(1).
    end.
    PUT stream PrnLibStream UNFORMATTED
    str1 skip
    str2 skip
    str4 skip
    v-header-curr skip
    .
    PUT stream PrnLibStream UNFORMATTED
    reportheader SKIP(0).
    FORM with FRAME OutFrame.
    VIEW STREAM PrnLibStream FRAME BottomFrame .
    VIEW STREAM PrnLibStream FRAME OutFrame .
    for each treal-vat no-lock where treal-vat.fact-order > 0
    break
    by treal-vat.fact-order
    by treal-vat.inkas-code
    by treal-vat.grp-code
    :
      if first-of(treal-vat.inkas-code) then do:
        if not v-only-excel then do:
           Put stream PrnLibStream unformatted
           treal-vat.inkas-code format "X(16)" {&space-char}
           string(treal-vat.doc-date, "99/99/9999")
           .
        end.
        {&page-excel-block} .
        {&PutExcel}
        treal-vat.inkas-code {&tabulation}
        treal-vat.doc-date   {&tabulation}
        .
      end. /*if first-of(treal-vat.inkas-code) then do:*/
      if first-of(treal-vat.grp-code) then do:
        do iext = 1 to 3:
          assign
          accum-netto[iext] = 0
          accum-netto-rubl[iext] = 0
          v-first-found-vat = yes
          .
        end.
  &scop grp-code treal-vat.grp-code
          {&get-grp-pay-name}.
        if first-of(treal-vat.grp-code)
        and (not p-rv  or v-first-found-vat  = yes)
        then do:
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            f-cash-pay-name at 29.
          end.
          {&PutExcel}
          (if first-of(treal-vat.inkas-code ) then '':U else fill({&tabulation}, 2))
          f-cash-pay-name {&tabulation}
          .
        end.
        v-first-found-rv = yes.
        do irv = irv-start to irv-end by -2:
          assign
          ii = 0
          v-first-found-vat = yes
          .
          /*идем по вему набору НДС*/
          for each gen0_treal-vat no-lock where
                  gen0_treal-vat.inkas-code = "":U
              AND gen0_treal-vat.grp-code = "":U
              AND gen0_treal-vat.rv = 0
              :
            assign
            ii = ii + 1
            col-ii = col-trail + 20 * (ii - 1 )
            .
            /*ищем есть ли такой НДС для данной продажи и типа оплаты (и если p-rv расхода-возврата)*/
            find first buf_treal-vat no-lock where
                  buf_treal-vat.inkas-code = treal-vat.inkas-code
              AND buf_treal-vat.grp-code   = treal-vat.grp-code
              AND buf_treal-vat.vat-pc     = gen0_treal-vat.vat-pc
              AND buf_treal-vat.rv         = irv
              no-error.
            if available buf_treal-vat then do:
              if p-rv and v-first-found-vat then do:
                /*надо напечатать слово РАСХОД или ВОЗВРАТ */
                &scop rv-code irv
                if not v-only-excel then do:
                  put stream PrnLibStream unformatted
                  {&rv-name} at col-fix.
                  /*и пробить нулями колонки, которые были по нулям*/
                  do jj = 1 to (ii - 1) :
                    col-jj = col-trail + 20 * (jj - 1).
                    put stream PrnLibStream unformatted
                    string(0, {&f-sums}) at col-jj.
                  end.
                end.
                {&PutExcel}
                (if v-first-found-rv
                 then '':U
                 else fill({&tabulation}, 3)
                 )
                {&rv-name}
                {&tabulation}.
                do jj = 1 to (ii - 1) :
                  {&PutExcel}
                  0
                  {&tabulation}
                  .
                end.
              end. /*if p-rv and v-first-found-vat then do:*/
              assign
              v-first-found-vat = no
              accum-netto[{&gen}] = accum-netto[{&gen}] + buf_treal-vat.netto
              accum-netto-rubl[{&gen}] = accum-netto-rubl[{&gen}] + buf_treal-vat.netto-rubl
              .
              if buf_treal-vat.rv <> 0 then do:
                assign
                accum-netto[{&irv}] = accum-netto[{&irv}] + buf_treal-vat.netto
                accum-netto-rubl[{&irv}] = accum-netto-rubl[{&irv}] + buf_treal-vat.netto-rubl
                .
              end.
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(if v-rubl
                      then buf_treal-vat.netto-rubl
                      else buf_treal-vat.netto , {&f-sums}) at col-ii.
              end.
              {&PutExcel}
              (if v-rubl
              then buf_treal-vat.netto-rubl
              else buf_treal-vat.netto) {&tabulation}
              .
              v-first-found-rv = no.
            end. /*available buf_treal-vat*/
            else do:
              /*если РАСХОДУ или ВОЗВРАТУ не было НДС - не печатаем строчку*/
              if not p-rv
              or v-first-found-vat = no  then do:
                if not v-only-excel then do:
                  put stream PrnLibStream unformatted
                  string(0, {&f-sums}) at col-ii.
                end.
                {&PutExcel}
                0
                {&tabulation}
                .
              end.
            end. /* not avail buf_treal-vat*/
          end. /*for each gen0_treal-vat*/  /*конец колонок НДС-ов*/
          assign
          ii = ii + 1
          col-ii = col-trail + 20 * (ii - 1)
          .
          /*печатаем сумму по всем НДС данной продажи и данного платежа (и если p-rv Расх-Возвр)
          если была сумма хоть по одному НДС
          */
          if (not p-rv) or (v-first-found-vat = no) then do:
            if not v-only-excel then do:
              put stream PrnLibStream unformatted
              string(if v-rubl
                      then accum-netto-rubl[{&irv}]
                      else accum-netto[{&irv}], {&f-sums}) at col-ii skip.
            end.
            {&PutExcel}
            (if v-rubl
            then accum-netto-rubl[{&irv}]
            else accum-netto[{&irv}])
            SKIP.
            assign
            ii-excel = ii-excel + 1
            .
          end.
        end. /*цикл расход возврат do */
      end. /*if first-of grp-code*/   /*конец строчки*/
      if last-of(treal-vat.inkas-code) then do:
        DOWN STREAM PrnLibStream
        1 with FRAME OutFrame .
        {&page-excel-block} .
        {&DOWN-EXCEL}
      end.
    end. /*for each treal-vat*/
    /*итоги*/
    if not v-only-excel then do:
      DOWN STREAM PrnLibStream
      1 with FRAME OutFrame .
      Put stream PrnLibStream unformatted "Итого ПО ПРОДАЖАМ" .
    end.
    {&page-excel-block} .
    {&PutExcel}
    "Итого ПО ПРОДАЖАМ"
    skip
    {&tabulation}
    {&tabulation}
    .
    for each pay_treal-vat no-lock where
            pay_treal-vat.inkas-code = "":U
        AND pay_treal-vat.grp-code <> "":U
    break
    by pay_treal-vat.fact-order
    by pay_treal-vat.inkas-code
    by pay_treal-vat.grp-code
    by pay_treal-vat.rv :
      if first-of(pay_treal-vat.grp-code) then do:
        do iext = 1 to 3:
          assign
          accum-netto[iext] = 0
          accum-netto-rubl[iext] = 0
          .
        end.
&scop grp-code pay_treal-vat.grp-code
        {&get-grp-pay-name}.
        /*итоги по платежу печатаем тремя строчками если p-rv  и одной если не p-rv*/
        do irv2 = 1 to num-entries(if p-rv then "1,-1,0" else "0"):
          if not first-of(pay_treal-vat.inkas-code)
          or irv2 > 1
          then do:
            {&page-excel-block} .
            {&PutExcel}
            {&tabulation}
            {&tabulation}
            .
          end.
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            f-cash-pay-name at 29.
          end.
          {&PutExcel}
          f-cash-pay-name {&tabulation}
          .
          assign
          irv = integer(entry(irv2, (if p-rv then "1,-1,0" else "0"))).
          assign
          ii = 0
          .
          if p-rv then do:
            /*надо напечатать слово РАСХОД или ВОЗВРАТ */
            &scop rv-code irv
            if not v-only-excel then do:
              put stream PrnLibStream unformatted
              {&rv-name} at col-fix.
            end.
            {&PutExcel}
            {&rv-name}
            {&tabulation}
            .
          end.
          /*идем по всем возможным НДС */
          for each gen0_treal-vat no-lock where
                gen0_treal-vat.inkas-code = "":U
            AND gen0_treal-vat.grp-code = "":U
            AND gen0_treal-vat.rv = 0:
            /*ищем был ли такой НДС для данного платежа среди ВСЕХ продаж (и если p-rv РАСХОДА-ВОЗВРАТА)*/
            find first buf_treal-vat no-lock where
                  buf_treal-vat.inkas-code = "":U
              AND buf_treal-vat.grp-code   = pay_treal-vat.grp-code
              AND buf_treal-vat.vat-pc     = gen0_treal-vat.vat-pc
              AND buf_treal-vat.rv         = irv  no-error.
            assign
            ii = ii + 1
            col-ii = col-trail + 20 * (ii - 1)
            .
            if available buf_treal-vat then do:
              /*
              assign
              accum-netto[{&gen}] = accum-netto[{&gen}] + buf_treal-vat.netto
              accum-netto-rubl[{&gen}] = accum-netto-rubl[{&gen}] + buf_treal-vat.netto-rubl
              .
              */
              /*if buf_treal-vat.rv <> 0 then do:*/
                assign
                accum-netto[{&irv}] = accum-netto[{&irv}] + buf_treal-vat.netto
                accum-netto-rubl[{&irv}] = accum-netto-rubl[{&irv}] + buf_treal-vat.netto-rubl
                .
              /*end.*/
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(if v-rubl
                      then buf_treal-vat.netto-rubl
                      else buf_treal-vat.netto, {&f-sums}) at col-ii.
              end.
              {&PutExcel}
              (if v-rubl
              then buf_treal-vat.netto-rubl
              else buf_treal-vat.netto)  {&tabulation}
              .
            end. /* if available gen_treal-vat  */
            else do:
              /*нулевые итоги печатаем и для строк возврата расхода*/
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(0, {&f-sums}) at col-ii.
              end.
              &scop rv-code irv
              {&PutExcel}
              0  {&tabulation}
              .
            end.
          end.  /*for each gen0_treal-vat*/
          /*конец колонок НДС*/
          assign
          ii = ii + 1
          col-ii = col-trail + 20 * (ii - 1)
          .
          /*сумма по всем НДС всех продаж данного платежа ( и если p-rv то РАСХОд-возврат) */
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(if v-rubl
                  then accum-netto-rubl[{&irv}]
                  else accum-netto[{&irv}], {&f-sums}) at col-ii skip.
          end. /*          if not v-only-excel then do:*/
          {&PutExcel}
          (if v-rubl
          then accum-netto-rubl[{&irv}]
          else accum-netto[{&irv}])
          SKIP.
          assign
          ii-excel = ii-excel + 1
          .
        end. /*do irv*/
        if p-rv then do:
          if not v-only-excel then do:
            DOWN STREAM PrnLibStream
            1 with FRAME OutFrame .
          end.
          {&PutExcel}
          {&tabulation}
          SKIP.
          assign
          ii-excel = ii-excel + 1
          .
        end.
      end. /*if first-of(pay_treal-vat.grp-code) then do:*/
    end.     /*for each pay_treal-vat*/
    if not v-only-excel then do:
      DOWN STREAM PrnLibStream
      1 with FRAME OutFrame .
      Put stream PrnLibStream unformatted "ИТОГО ПО ВСЕМ ПРОДАЖАМ И ТИПАМ ПЛАТЕЖЕЙ" .
    end.
    {&page-excel-block} .
    {&PutExcel}
    "ИТОГО ПО ВСЕМ" {&tabulation}
    "ПРОДАЖАМ" {&tabulation}
    "И ТИПАМ ПЛАТЕЖЕЙ"  {&tabulation}
    .
    do iext = 1 to 3:
      assign
      accum-netto[iext] = 0
      accum-netto-rubl[iext] = 0
      .
    end.
    /*итоги по ВСЕМ ПЛАТЕЖМ ВСЕМ ПРОДАЖАМ печатаем тремя строками если p-rv и одной если не p-rv*/
    do irv2 = 1 to num-entries(if p-rv then "1,-1,0" else '0'):
      ii = 0.
      irv = integer(entry(irv2, if p-rv then "1,-1,0" else '0')).
      if p-rv then do:
        if not v-only-excel then do:
          &scop rv-code irv
          put stream PrnLibStream unformatted
          {&rv-name} at col-fix
          .
        end.
        {&putExcel}
        (if irv2 > 1
         then fill({&tabulation}, 3)
         else '':U)
         {&rv-name} {&tabulation}.
      end.
      for each gen0_treal-vat no-lock where
              gen0_treal-vat.inkas-code = "":U
          AND gen0_treal-vat.grp-code   = "":U
          AND gen0_treal-vat.rv   = 0 :
        find first gen_treal-vat no-lock where
                  gen_treal-vat.inkas-code = ""
              AND gen_treal-vat.grp-code = ""
              AND gen_treal-vat.vat-pc = gen0_treal-vat.vat-pc
              AND gen_treal-vat.rv = irv no-error.
        assign
        ii = ii + 1
        col-ii = col-trail + 20 * (ii - 1)
        .
        if available gen_treal-vat then do:
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(if v-rubl
                  then gen_treal-vat.netto-rubl
                  else gen_treal-vat.netto, {&f-sums}) at col-ii.
          end.
          {&PutExcel}
          (if v-rubl
          then gen_treal-vat.netto-rubl
          else gen_treal-vat.netto) {&tabulation}
          .
          assign
          accum-netto[{&irv}] = accum-netto[{&irv}] + gen_treal-vat.netto
          accum-netto-rubl[{&irv}] = accum-netto-rubl[{&irv}] + gen_treal-vat.netto-rubl
          .
        end. /*if available gen_treal-vat*/
        else do:
          /*нулевые итоги печатаем и для строк возврата расхода*/
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(0, {&f-sums}) at col-ii.
          end.
          &scop rv-code irv
          {&PutExcel}
          0  {&tabulation}
          .
        end.
      end. /*for each gen0_treal-vat*/
      /*конец колонок НДС*/
      assign
      ii  = ii + 1
      col-ii = col-trail + 20 * (ii - 1)
      .
      /*печатаем СУММУ по всем НДС ВСЕХ продаж ВСЕХ поатежей (и если p-rv РАСХод-ВОЗВРАТ */
      if not v-only-excel then do:
        put stream PrnLibStream unformatted
        string(if v-rubl
              then accum-netto-rubl[{&irv}]
              else accum-netto[{&irv}], {&f-sums}) at col-ii.
        if irv = 0 then do:
          DOWN STREAM PrnLibStream
          1 with FRAME OutFrame .
        end.
        else do:
          put stream PrnLibStream unformatted skip.
        end.
      end.
      {&PutExcel}
      (if v-rubl
      then accum-netto-rubl[{&irv}]
      else accum-netto[{&irv}])
      skip.
    end. /*do irv2 = 1 to num-entries(if p-rv then "1,-1,0" else '0'):*/
    HIDE STREAM PrnLibStream FRAME BottomFrame .
    OUTPUT STREAM PrnLibStream CLOSE.
    {&CloseExcel}
    run waitfram-hide in this-procedure .
    if not v-only-excel then do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input 8
                                                ).
    end.
    else do:
      define variable v-report-name as character no-undo .
      run prn-lib-get-report-name  in this-procedure(
                                                     input parParentProc
                                                    ,output v-report-name ) .

      run rep/runexcel.p (v-report-name + ".txt").
    end.
  end. /*doe*/
end procedure. /* printproc */



procedure printproc-gds :
/*процедура не используется - сохранено для потомков*/
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable f-artic like ub.goods.artic no-undo .
define variable f-gds-name like ub.goods.gds-name no-undo .
define variable f-prod-name like ub.clients.obj-name no-undo .
define variable f-cash-pay-name like ub.cash-pay.obj-name no-undo .
define variable f-grp-name like ub.goods.grp-name no-undo .
define variable f-sum-rubl as decimal no-undo .
define variable f-sum-base as decimal no-undo .
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.



  do
  on error undo, return error
  :

DEFINE FRAME OutFrame
v-gds-code COLUMN-LABEL "Код товара"
f-artic  COLUMN-LABEL "Артикул"
f-gds-name COLUMn-LABEL "Название товара"  format "X(40)"
f-prod-name COLUMn-LABEL "Производитель" format "X(30)"
f-cash-pay-name COLUMn-LABEL "Тип касс.платежа" format "X(30)"
f-grp-name  COLUMn-LABEL "Группа" format "X(50)"
f-sum-rubl      COLUMn-LABEL "Сумма в {&abbr_rub}." format "->>>,>>>,>>9.99"
f-sum-base      COLUMn-LABEL "Сумма в б.в." format "->>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 170 format "X(13)" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io.



FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width {&DOS_CW_2}
PAGE-BOTTOM no-labels no-box.
run waitfram-show in this-procedure ("Ждите..." ).

run prn-lib-open-stream  in this-procedure (
                                            input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
run rep/extitle.p (1).
find first buf1_sheetf no-lock where buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.

PUT stream PrnLibStream UNFORMATTED
("Разбивка товаров в чеке по типам кассовых платежей" +
string( x-date-start, "99/99/9999" ) + " по " + string(x-date-end, "99/99/9999") + ".")
format "x(110)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED
str1 skip
str2 skip
str4 skip.
PUT stream PrnLibStream UNFORMATTED
reportheader SKIP(0).

VIEW STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME OutFrame.

for each treal-3 no-lock
break
by treal-3.gds-code
by treal-3.cpay-code
by treal-3.curr-code
by treal-3.is-pay
:
  {&page-excel-block} .
  if first-of(treal-3.is-pay) then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = treal-3.gds-code.
    find first buf_clients no-lock where
              buf_Clients.obj-type = buf_goods.prod-type
          AND buf_Clients.obj-code = buf_goods.prod-code no-error .
    assign
    f-prod-name = buf_clients.obj-name
    f-gds-name = buf_goods.gds-name
    f-grp-name = buf_goods.grp-name
    f-artic = buf_goods.artic
    .
    display stream PrnLibStream
    treal-3.gds-code @ v-gds-code
    f-artic
    f-gds-name
    f-prod-name
    f-grp-name
    treal-3.out-name @ f-cash-pay-name
    treal-3.netto-rubl @ f-sum-rubl
    treal-3.netto @ f-sum-base
    with frame OutFrame.
    DOWN STREAM PrnLibStream
    1 with FRAME OutFrame .
  end.
  else do:
    display stream PrnLibStream
    treal-3.out-name @ f-cash-pay-name
    treal-3.netto-rubl @ f-sum-rubl
    treal-3.netto @ f-sum-base
    with frame OutFrame.
    DOWN STREAM PrnLibStream
    1 with FRAME OutFrame .
  end.

  {&PutExcel}
  treal-3.gds-code          {&tabulation}
  f-artic                   {&tabulation}
  f-gds-name                {&tabulation}
  f-prod-name               {&tabulation}
  f-grp-name                {&tabulation}
  treal-3.out-name          {&tabulation}
  treal-3.netto-rubl        {&tabulation}
  treal-3.netto             {&tabulation}
  skip.
  assign
  ii-excel = ii-excel + 1
  .
end.

HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
{&CloseExcel}
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


  end.

end procedure. /* printproc */