/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр соответствия по строкам товара

Автор: Чернова Светлана Александровна
Дата создания: 06/20/07
Author: Svetlana Chernova
Creation date: 06/20/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(onlycheck) eq 0 
&then
procedure fact-bc:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define variable g-log       as logical              no-undo.
define variable varnum      as integer              no-undo.
define variable varbar-code like ub.bar-code.b-code no-undo.
define variable varrecid    as   recid              no-undo.
define variable is-petrolium as logical no-undo.
define variable is-pieces    as logical no-undo.
define variable v-part-code  as character no-undo.
define variable v-alcohol-prod as logical no-undo .
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define buffer bf_units    for ub.units.
define buffer bf_parts    for ub.parts.

do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
for each tt-bar-code-ne:
  delete tt-bar-code-ne.
end.
assign
  g-log = yes.
if bf_trn-doc.doc-qnty <> bf_trn-doc.fact-qnty and
   bf_trn-doc.fact-qnty <> 0 then do:
  message "Начать заполнять фактическое количество с нуля?" view-as alert-box question
  buttons yes-no update g-log.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
    { gbl/gdsbcode.i bf_goods.gds-code bf_gds-prt.node-code varbar-code }
    assign
      varnum = varnum + 1.
    create tt-bar-code-ne.
    assign
     tt-bar-code-ne.nm             = varnum
     tt-bar-code-ne.mark           = (if bf_gds-dtl.fact-qnty < bf_gds-dtl.doc-qnty then "<" else "")
     tt-bar-code-ne.b-c            = varbar-code
     tt-bar-code-ne.scn-qnty-doc   = bf_gds-dtl.doc-qnty
     tt-bar-code-ne.scn-qnty-file  = (if g-log = yes then 0 else bf_gds-dtl.fact-qnty)
     tt-bar-code-ne.mem-qnty       = tt-bar-code-ne.scn-qnty-file
     tt-bar-code-ne.bef-qnty       = bf_gds-dtl.fact-qnty
     tt-bar-code-ne.artic          = bf_goods.artic
     tt-bar-code-ne.prod-type      = bf_goods.prod-type
     tt-bar-code-ne.prod-code      = bf_goods.prod-code
     tt-bar-code-ne.gds-name       = bf_goods.gds-name
     tt-bar-code-ne.node-name      = (if bf_gds-prt.node-name = {&empty-scale} then "--------------------" else bf_gds-prt.node-name)
     tt-bar-code-ne.part-code      = ''
     tt-bar-code-ne.in-code        = ''.
  end.
end.
run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input "in-doc", input yes, input v-cntxt-obj-type, input v-cntxt-obj-code).
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock by bf_doc-line.line-num :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code     and
                            bf_gds-dtl.artic     = bf_goods.artic     and
                            bf_gds-dtl.prod-type = bf_goods.prod-type and
                            bf_gds-dtl.prod-code = bf_goods.prod-code
                            no-lock on error undo, return error return-value :
    find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
    { gbl/gdsbcode.i bf_goods.gds-code bf_gds-prt.node-code varbar-code }
    find first tt-bar-code-ne where tt-bar-code-ne.b-c = varbar-code.
    if tt-bar-code-ne.scn-qnty-file <> bf_gds-dtl.fact-qnty then do :
      find bf_units where bf_units.unit-name = bf_goods.unit-base no-lock.
      if lookup({&serial}, bf_units.type) > 0 then do:
         message "В серийном товаре нельзя редактировать количество. Пропускаем.".
         next.
      end.

      if tt-bar-code-ne.scn-qnty-file > bf_gds-dtl.doc-qnty then do:
        message "По признаку " bf_gds-dtl.artic " "
                bf_gds-dtl.prod-type " "
                bf_gds-dtl.prod-code " "
                bf_gds-prt.f-name " "
                "количество факт уже больше чем по документу. Устанавливаем по документу."
        view-as alert-box.
        assign
          tt-bar-code-ne.scn-qnty-file = bf_gds-dtl.doc-qnty.
      end.
      assign varrecid = recid(bf_doc-line).
      if bf_trn-doc.doc-type = {&income} and
         bf_trn-doc.internal = no        then do:
        { str/is-petrl.i
          bf_goods.artic
          bf_goods.prod-type
          bf_goods.prod-code
          is-petrolium
          is-pieces
          no-error
        }
        if is-petrolium and not is-pieces then do:
          MESSAGE "В жидком топливе нельзя редактировать фактическое количество" view-as alert-box.
          next.
        end.

        assign
          v-part-code = ?
        .
        /* Является ли товар алкогольной продукцией */
        { gbl/gdscdat.i
          bf_goods.gds-code
          "'alcohol-prod=request':u"
          v-alcohol-prod
        }
        if v-alcohol-prod then do:
          /* ищем первую попавшуюся партию из строки приходной накладной и берем ее код
             как код партии по умолчанию */
          find first bf_parts no-lock
            where bf_parts.obj-type  = bf_doc-line.obj-type  and
                  bf_parts.obj-code  = bf_doc-line.obj-code  and
                  bf_parts.prod-type = bf_doc-line.prod-type and
                  bf_parts.prod-code = bf_doc-line.prod-code and
                  bf_parts.artic     = bf_doc-line.artic     and
                  bf_parts.out-code  = bf_doc-line.doc-code
            no-error.
          if available bf_parts then do:
            assign
              v-part-code = bf_parts.part-code
            .
          end.
        end.

        run str/cor-line.p
          (input parparentproc
          ,input-output varrecid              /* par-rec-doc-line    */
          ,input bf_doc-line.doc-code         /* pardoc-code         */
          ,input bf_doc-line.prod-type        /* parprod-type        */
          ,input bf_doc-line.prod-code        /* parprod-code        */
          ,input bf_doc-line.artic            /* parartic            */
          ,input bf_doc-line.cli-qnty         /* parcli-qnty         */
          ,input bf_doc-line.cli-base-rate    /* parcli-base-rate    */
          ,input tt-bar-code-ne.scn-qnty-file /* parfact-qnty        */
          ,input bf_doc-line.doc-qnty         /* pardoc-qnty         */
          ,input bf_doc-line.unit-cli         /* parunit-cli         */
          ,input bf_doc-line.vat-pc           /* parvat-pc           */
          ,input bf_doc-line.slt-pc           /* parslt-pc           */
          ,input bf_doc-line.price-cli        /* parprice-cli        */
          ,input bf_doc-line.price-base       /* parprice-base       */
          ,input bf_doc-line.price-rubl       /* parprice-rubl       */
          ,input bf_doc-line.new-price-sale   /* parprice-rubl       */
          ,input bf_doc-line.num-place        /* parnum-place        */
          ,input bf_doc-line.wt-brutto        /* parwt-brutto        */
          ,input bf_doc-line.road-tax         /* parroad-tax         */
          ,input bf_doc-line.excise           /* parexcise           */
          ,input bf_doc-line.doc-density      /* pardoc-density      */
          ,input bf_doc-line.temperature      /* partemperature      */
          ,input ?                            /* parcontract-code    */
          ,input ?                            /* parlast-date        */
          ,input ?                            /* parfact-qnty-kg     */
          ,input bf_doc-line.fact-density     /* parfact-density     */
          ,input ?                            /* parcst-code         */
          ,input no                           /* paralc-update              */
          ,input v-part-code                  /* paralc-part-code           */
          ,input ?                            /* paralc-mark-db-num         */
          ,input ?                            /* paralc-mark-code           */
          ,input ?                            /* paralc-bottling-date       */
          ,input ?                            /* paralc-ref-ab-path         */
          ,input ?                            /* paralc-quality-certif-path */
          ,input ?                            /* paralc-imp-type            */
          ,input ?                            /* paralc-imp-code            */
          ,input ?                            /* paralc-certif-path         */
          ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
      else do:
        run str/out-add.p (parparentproc,
                       recid(bf_trn-doc),
                       recid(bf_doc-line),
                       recid(bf_gds-dtl),
                       recid(bf_goods),
                       "ch-fact-qnty",
                       tt-bar-code-ne.scn-qnty-file) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.
    end.
  end.
end.
end.
end procedure.
&endif

/*
    Создана: 27.03.2025 Ростовцев А.М.
    Описание: Процедура проверки возможности добавления товара в накладную
              по бар-коду
              Запрещает добавлять товар в накладную по бар-коду, если на товаре
              установлен тип маркировки
              Доработка по BTS-1493 
*/
procedure checkTypeByBarCode:
  define input parameter iBarCode    as integer no-undo.
  define input parameter iExtDocType as character no-undo.
  
  define variable vValue as character no-undo.
  define variable vType  as character no-undo.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods    for ub.goods.

  /* согласно сапроса только для 
    Расход внешний
    Расход внешний (возврат поставщику)
    Приход внешний
    Приход внутренний
    Расход внутренний
    Списание
   */
  if iExtDocType = ? or
     iExtDocType = {&TDEDT_Ras_Vnesh} or
     iExtDocType = {&TDEDT_Pri_Vnesh} or
     iExtDocType = {&TDEDT_Pri_Perem} or
     iExtDocType = {&TDEDT_Ras_Perem} or
     iExtDocType = {&TDEDT_Spi_Vnesh} then

      find buf_bar-code where buf_bar-code.b-code = iBarCode no-lock.
      find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock.
     
      RUN gds-attr-value (
         INPUT buf_goods.gds-code,
         INPUT {&attr-mark-type},
         OUTPUT vValue,
         OUTPUT vType
      ).
      if vValue <> "" then
      do:
        message 
          substitute("Товар: &1 &2", b-c, buf_goods.gds-name) skip
          "нельзя добавлять в ручном режиме, так как он подлежит маркировке."   
          view-as alert-box error buttons ok.
        return error.
      end.
    
end procedure.

/* $Workfile$ e n d */