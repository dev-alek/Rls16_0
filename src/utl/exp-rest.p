/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгружает текущие остатки для сравнения остатков в 16_0 после импорта

Автор: Молотков Сергей
Дата создания: 23/01/19
Author: Molotkov Sergey
Creation date: 23/01/19

*/


/* выгружаемая таблица по товарам */
define temp-table tt-stk-gd no-undo
  field gds-code      as integer
  field gds-name      as character
  field fact-qnty     as decimal /* количество в 15 */
  field sum-rubl-cost as decimal /* сумма в учетных ценах в 15 */
  field vat-rubl      as decimal /* сумма НДС в учетных ценах в 15 */
  field sum-rubl-crsa as decimal /* сумма в продажных ценах в 15 */
  index pi is primary gds-code
.

/* выгружаемая таблица по топливу */
define temp-table tt-stk-fu no-undo
  field gds-code      as integer
  field gds-name      as character
  field fact-qnty-lt  as decimal /* остатки в лт в 15 */
  field fact-qnty-kg  as decimal /* остатки в кг в 15 */
  index pi is primary gds-code
.

define input  parameter p-obj-code       as integer no-undo .
define input  parameter p-obj-type       as character no-undo .
define output parameter table for tt-stk-gd .
define output parameter table for tt-stk-fu .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выгружает текущие остатки для сравнения остатков в 16_0 после импорта".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i } /* &arh-crsa, &root-cat-id, &free-code */
{ str/lib-trn.i }  /* для str/is-petrl.i */


define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable v-today      as date no-undo .
define variable v-line-count as integer no-undo .
define buffer buf_gds-obj   for ub.gds-obj .
define buffer buf_goods     for ub.goods .
define buffer buf_pl-gds    for ub.pl-gds .
define buffer buf_stk-line  for ub.stk-line .


    v-today = today .

  /* 02/II-2019  Расчет архивов надо принудительно запустить при сверке и на 15 и 16 версиях. */
  define variable v-date-start as date no-undo .
  define variable v-date-end   as date no-undo .
  define variable v-archive-ok as logical no-undo .
  define variable v-comment    as character no-undo .
  define variable v-can-print  as logical no-undo .
  assign
    v-date-start = v-today
    v-date-end   = v-today
  .
  run rep/chk-ahz.p
  (input p-obj-type /* p-obj-type          */
  ,input p-obj-code /* p-obj-code          */
  ,input false      /* p-verify-detail     */
  ,input true       /* p-verify-arh        */
  ,input false      /* p-verify-ahsp       */
  ,input false      /* p-verify-aht        */
  ,input false      /* true           p-check-act         */
  ,input 0          /* v-cntxt-db-num p-check-act-db-num  */
  ,input ""         /* v-cntxt-userid p-check-act-user-id */
  ,input-output v-date-start /* p-date-start        */
  ,input-output v-date-end   /* p-date-end          */
  ,output       v-archive-ok      /* p-archive-ok        */
  ,output       v-comment         /* p-comment           */
  ,output       v-can-print       /* p-can-print         */
  ) .
  
  
    empty temp-table tt-stk-gd .
    empty temp-table tt-stk-fu .
    v-line-count = 0 .

    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code :
      v-line-count = v-line-count + 1 .
      
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code no-error .

      /* Топливо - налево, остальные - направо. */
      { str/is-petrl.i
          buf_gds-obj.artic
          buf_gds-obj.prod-type
          buf_gds-obj.prod-code
          is-petrolium
          is-pieces
      }

      if is-petrolium then do :
        /* бензин: только остатки в литрах и в киллограммах */
        
        create tt-stk-fu .
        assign
          tt-stk-fu.gds-code     = buf_gds-obj.gds-code
          tt-stk-fu.gds-name     = if available buf_goods then buf_goods.gds-name else "товар отсутствует"
          tt-stk-fu.fact-qnty-lt = 0 /* остатки в лт в 15 */
          tt-stk-fu.fact-qnty-kg = 0 /* остатки в кг в 15 */
        .
        for each buf_pl-gds no-lock
           where buf_pl-gds.gds-code = buf_gds-obj.gds-code
             and buf_pl-gds.obj-type = buf_gds-obj.obj-type
             and buf_pl-gds.obj-code = buf_gds-obj.obj-code :
          assign
            tt-stk-fu.fact-qnty-lt = tt-stk-fu.fact-qnty-lt + buf_pl-gds.fact-qnty
            tt-stk-fu.fact-qnty-kg = tt-stk-fu.fact-qnty-kg + buf_pl-gds.cli-fact-qnty
          .
        end .
        
      end .
      else do :
        /* небензин: остатки в штуках и в рублях */
        
        create tt-stk-gd .
        assign
          tt-stk-gd.gds-code      = buf_gds-obj.gds-code
          tt-stk-gd.gds-name      = if available buf_goods then buf_goods.gds-name else "товар отсутствует"
          tt-stk-gd.fact-qnty     = 0
          tt-stk-gd.sum-rubl-cost = 0
          tt-stk-gd.vat-rubl      = 0
          tt-stk-gd.sum-rubl-crsa = 0
        .
        find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = buf_gds-obj.obj-type
              and buf_stk-line.obj-code   = buf_gds-obj.obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.sum-type   = {&arh-cost}    /* 'cost':U учетная цена */
              and buf_stk-line.cat-id     = {&root-cat-id} /* '##,##':U */
              and buf_stk-line.fact-date <= v-today
        use-index category no-error.
        if available buf_stk-line then assign
          tt-stk-gd.fact-qnty     = buf_stk-line.fact-qnty
          tt-stk-gd.sum-rubl-cost = buf_stk-line.sum-rubl
          tt-stk-gd.vat-rubl      = buf_stk-line.VAT-rubl
        .
        find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = buf_gds-obj.obj-type
              and buf_stk-line.obj-code   = buf_gds-obj.obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.sum-type   = {&arh-crsa}    /* 'crsa':U продажная цена */
              and buf_stk-line.cat-id     = {&root-cat-id} /* '##,##':U */
              and buf_stk-line.fact-date <= v-today
        use-index category no-error.
        if available buf_stk-line then assign
          /* считаем, что stk-line.fact-qnty для cost и для crsa совпадают */
          tt-stk-gd.fact-qnty     = buf_stk-line.fact-qnty when tt-stk-gd.fact-qnty = 0
          tt-stk-gd.sum-rubl-crsa = buf_stk-line.sum-rubl
        .
        
      end . /* end_of not_petrolium */

    end . /* end_of for_each_gds-obj */
