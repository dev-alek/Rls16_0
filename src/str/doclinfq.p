block-level on error undo, throw.
/*

$Revision: f80e41f51855, 1693, rls $
$Author: ASMorozov $
$Date: Tue Dec 11 10:07:53 2018 +0300 $
$Workfile: doclinfq.p $
$Archive: str/doclinfq.p $

Редактирование фактического количества в приходной накладной

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/14/05


*/

define input  parameter parparentproc as widget-handle no-undo.
define parameter buffer t-doc for ub.trn-doc .
define parameter buffer doc-line for ub.doc-line .
define input  parameter p-fact-qnty   as decimal   no-undo .
define output parameter p-edit-ok     as logical   no-undo .
define output parameter p-err-message as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: f80e41f51855, 1693, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 11 10:07:53 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclinfq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclinfq.p $":U .
define variable vss-description as character no-undo init "Редактирование фактического количества в приходной накладной".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }

define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable line-rec     as recid   no-undo .
define variable v-part-code  as character no-undo.
define variable v-alcohol-prod as logical no-undo .
define variable v-hold-doc as logical   no-undo .

define buffer bf_parts    for ub.parts.

do
on error undo, return error return-value
:
  update_block:
  do transaction
  on error undo update_block, return error
  :
    if not available t-doc
    then do:
      undo, return error "Не задан документ" .
    end.
    { gbl/hold-doc.i t-doc.doc-code v-hold-doc }
    if not available doc-line
    then do:
      undo, return error "Не задана строка документа" .
    end.

    define variable v-gds-code as integer   no-undo .

    { gbl/gds-code.i
      doc-line.artic
      doc-line.prod-type
      doc-line.prod-code
      v-gds-code
    }

    if p-fact-qnty <> doc-line.fact-qnty
    then do:
      if  p-fact-qnty = ?
      and t-doc.flag_ = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "Не указано фактическое количество"
        .
        undo update_block, return .
      end.

      if  p-fact-qnty > doc-line.doc-qnty
      and v-hold-doc = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "Данный документ был автоматически создан по перемещению от своей фирмы."
                        + {&new-line} + "Нельзя указывать фактическое количество больше документарного"
        .
        undo update_block, return .
      end.
      /*if t-doc.flag_ = false
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "В данном статусе нельзя редактировать фактическое количество"
        .
        undo update_block, return .
      end.*/

      define variable v-goods-serial as logical   no-undo .
      { gbl/gdscdat.i
        v-gds-code
        "'serial=request':u"
        v-goods-serial
        no-error
      }
      if error-status :error
      then do:
        undo update_block, return error "Ошибка при определении свойства товара 'serial=request':u" .
      end.

      if v-goods-serial = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "В серийном товаре нельзя редактировать фактическое количество"
        .
        undo update_block, return .
      end.
      { str/is-petrl.i
        doc-line.artic
        doc-line.prod-type
        doc-line.prod-code
        is-petrolium
        is-pieces
        no-error
      }
      if is-petrolium and not is-pieces then do:
        assign
          p-edit-ok     = false
          p-err-message = "В жидком топливе нельзя редактировать фактическое количество"
        .
        undo update_block, return .
      end.

      assign
        v-part-code = ?
      .

      /* Является ли товар алкогольной продукцией */
      { gbl/gdscdat.i
        v-gds-code
        "'alcohol-prod=request':u"
        v-alcohol-prod
      }
      if v-alcohol-prod then do:
        /* ищем первую попавшуюся партию из строки приходной накладной и берем ее код
           как код партии по умолчанию */
        find first bf_parts no-lock
          where bf_parts.obj-type  = doc-line.obj-type  and
                bf_parts.obj-code  = doc-line.obj-code  and
                bf_parts.prod-type = doc-line.prod-type and
                bf_parts.prod-code = doc-line.prod-code and
                bf_parts.artic     = doc-line.artic     and
                bf_parts.out-code  = doc-line.doc-code
          no-error.
        if available bf_parts then do:
          assign
            v-part-code = bf_parts.part-code
          .
        end.
      end.

      assign
        line-rec = recid(doc-line)
      .
      run str/cor-line.p
        (input parparentproc          /* parparentproc       */
        ,input-output line-rec        /* par-rec-doc-line    */
        ,input doc-line.doc-code      /* pardoc-code         */
        ,input doc-line.prod-type     /* parprod-type        */
        ,input doc-line.prod-code     /* parprod-code        */
        ,input doc-line.artic         /* parartic            */
        ,input doc-line.cli-qnty      /* parcli-qnty         */
        ,input doc-line.cli-base-rate /* parcli-base-rate    */
        ,input p-fact-qnty            /* parfact-qnty        */
        ,input doc-line.doc-qnty      /* pardoc-qnty         */
        ,input doc-line.unit-cli      /* parunit-cli         */
        ,input doc-line.vat-pc        /* parvat-pc           */
        ,input doc-line.slt-pc        /* parslt-pc           */
        ,input doc-line.price-cli     /* parprice-cli        */
        ,input doc-line.price-base    /* parprice-base       */
        ,input doc-line.price-rubl    /* parprice-rubl       */
        ,input doc-line.new-price-sale /* parprice-rubl       */
        ,input doc-line.num-place     /* parnum-place        */
        ,input doc-line.wt-brutto     /* parwt-brutto        */
        ,input doc-line.road-tax      /* parroad-tax         */
        ,input doc-line.excise        /* parexcise           */
        ,input doc-line.doc-density   /* pardoc-density      */
        ,input doc-line.temperature   /* partemperature      */
        ,input ?                      /* parcontract-code    */
        ,input ?                      /* parlast-date        */
        ,input ?                      /* parfact-qnty-kg     */
        ,input doc-line.fact-density  /* parfact-density     */
        ,input ?                      /* parcst-code         */
        ,input no                     /* paralc-update              */
        ,input v-part-code            /* paralc-part-code           */
        ,input ?                      /* paralc-mark-db-num         */
        ,input ?                      /* paralc-mark-code           */
        ,input ?                      /* paralc-bottling-date       */
        ,input ?                      /* paralc-ref-ab-path         */
        ,input ?                      /* paralc-quality-certif-path */
        ,input ?                      /* paralc-imp-type            */
        ,input ?                      /* paralc-imp-code            */
        ,input ?                      /* paralc-certif-path         */
        ) no-error.
      if error-status :error
      then do:
        undo update_block, return error substitute("Ошибка при вызове процедуры создания линии документа &1", return-value).
      end.
      assign
        line-rec = recid(doc-line)
      .
      /* Вызов разбивки по шкале */
      run str/chk-prt.p
        (input  line-rec
        ,input  no
        ,buffer t-doc
        ) .
    end.
  end.

  assign
    p-edit-ok     = true
    p-err-message = ''
  .
end.