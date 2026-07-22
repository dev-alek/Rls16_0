block-level on error undo, throw.
using ibs.th.str.alcohol.*.
using ibs.th.gbl.storage.*.
define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-action      as character no-undo .
define parameter    buffer    rsrv-gds-dtl  for ub.gds-dtl .
define input-output parameter chg-qnty      as   decimal no-undo .
define input-output parameter cost-base     as   decimal no-undo .
define input-output parameter cost-rubl     as   decimal no-undo .
define input        parameter p-b-code      as   integer no-undo .
define input        parameter p-mark        as   character  no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Процедура резервирования товара".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9',p-action,rsrv-gds-dtl.artic,rsrv-gds-dtl.prod-type,rsrv-gds-dtl.prod-code,rsrv-gds-dtl.prt-code,chg-qnty,cost-base,cost-rubl,p-b-code)
    .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define stream alc-rsrv .
define stream tobacco-rsrv .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rsrgdsck :
  define input  parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input  parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input  parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define output parameter p-free-parts-qnty        like ub.parts.qnty         no-undo .
  define output parameter p-free-parts-fact-qnty   like ub.parts.fact-qnty    no-undo .
  define output parameter p-free-parts-cli-qnty    like ub.parts.cli-qnty     no-undo .
  define output parameter p-free-parts-price-base  as decimal                 no-undo .
  define output parameter p-free-parts-price-rubl  as decimal                 no-undo .
  define output parameter p-out-parts-qnty         like ub.parts.qnty         no-undo .
  define output parameter p-out-parts-fact-qnty    like ub.parts.fact-qnty    no-undo .
  define output parameter p-out-parts-cli-qnty     like ub.parts.cli-qnty     no-undo .
  define output parameter p-out-parts-price-base   as decimal                 no-undo .
  define output parameter p-out-parts-price-rubl   as decimal                 no-undo .
  define buffer buf_parts    for ub.parts.
  assign
    p-free-parts-qnty       = 0
    p-free-parts-fact-qnty  = 0
    p-free-parts-cli-qnty   = 0
    p-free-parts-price-base = 0
    p-free-parts-price-rubl = 0
    p-out-parts-qnty        = 0
    p-out-parts-fact-qnty   = 0
    p-out-parts-cli-qnty    = 0
    p-out-parts-price-base  = 0
    p-out-parts-price-rubl  = 0
  .
  for each buf_parts no-lock
    where buf_parts.out-code  = p-doc-code
      and buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
  on error undo, return error
  :
    if can-do('при,рас,спи':U, p-doc-type)
    or (p-doc-type = 'инв':U
        and buf_parts.fact-qnty < 0)
    then do:
      assign
        p-free-parts-qnty       = p-free-parts-qnty
                                + abs(buf_parts.qnty)
        p-free-parts-fact-qnty  = p-free-parts-fact-qnty
                                + abs(buf_parts.fact-qnty)
        p-free-parts-cli-qnty   = p-free-parts-cli-qnty
                                + abs(buf_parts.cli-qnty)
        p-free-parts-price-base = p-free-parts-price-base
                                + abs(buf_parts.fact-qnty) * buf_parts.price-base
        p-free-parts-price-rubl = p-free-parts-price-rubl
                                + abs(buf_parts.fact-qnty) * buf_parts.price-rubl
      .
    end.
    else do:
      assign
        p-out-parts-qnty        = p-out-parts-qnty
                                + buf_parts.qnty
        p-out-parts-fact-qnty   = p-out-parts-fact-qnty
                                + buf_parts.fact-qnty
        p-out-parts-cli-qnty    = p-out-parts-cli-qnty
                                + buf_parts.cli-qnty
        p-out-parts-price-base  = p-out-parts-price-base
                                + buf_parts.fact-qnty * buf_parts.price-base
        p-out-parts-price-rubl  = p-out-parts-price-rubl
                                + buf_parts.fact-qnty * buf_parts.price-rubl
      .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
procedure partscr :
  define input  parameter parparentproc      as widget-handle no-undo.
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-supp-type        as character no-undo .
  define input  parameter p-supp-code        as integer   no-undo .
  define input  parameter p-part-code        as character no-undo .
  define input  parameter p-cst-code         as character no-undo .
  define input  parameter p-ps               as character no-undo .
  define input  parameter p-dop              as character no-undo .
  define input  parameter p-part-reserv-base as decimal   no-undo .
  define input  parameter p-part-reserv-rubl as decimal   no-undo .
  define input  parameter p-vat-type         as character no-undo .
  define input  parameter p-vat-pc           as decimal   no-undo .
  define input  parameter p-slt-type         as character no-undo .
  define input  parameter p-slt-pc           as decimal   no-undo .
  define input  parameter p-change-qnty      as decimal   no-undo .
  define input  parameter p-action           as character no-undo .
  define input  parameter p-cli-qnty         as decimal   no-undo .
  define input  parameter p-last-date        as date      no-undo .
  define input  parameter p-hold-date        as date      no-undo .
  define input  parameter p-pl-code          as integer   no-undo .
  define parameter buffer buf_doc-line       for ub.doc-line .
  define parameter buffer buf_parts          for ub.parts .
  define variable vss-description as character no-undo initial "$Workfile$ $Revision$ Процедура создания партии".
  define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
  define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
  define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable v-price-base               like ub.doc-line.price-base no-undo.
  define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
  define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable l-fact-qnty              as logical   no-undo .
  define variable v-action                 as character no-undo .
  define variable l-need-create-old-return as logical   no-undo init false .
  define variable l-create-old-return      as logical   no-undo init false .
  define variable v-izlcstpr        as character no-undo .
  define variable l-goods-serial           as logical   no-undo .
  define variable l-goods-twounit          as logical   no-undo .
  define variable l-reserv-pl-code         as logical   no-undo .
  define variable l-goods-bottle           as logical   no-undo .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  define variable v-prompt-price       as character no-undo .
  define variable v-check-right        as logical   no-undo .
  define variable v-ind                as integer   no-undo .
  define variable v-num-entries-action as integer   no-undo .
  define variable v-option             as character no-undo .
  define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-check-right = true
    .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-type = ?
    or p-supp-type = ''
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-type имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-supp-code = ?
    or p-supp-code = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-supp-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-cst-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-cst-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-ps = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-ps имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-base < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-base имеет отрицательное значение" skip
        "p-part-reserv-base" p-part-reserv-base skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-part-reserv-rubl < 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-part-reserv-rubl имеет отрицательное значение" skip
        "p-part-reserv-rubl" p-part-reserv-rubl skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-change-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-change-qnty имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-pl-code = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Параметр p-pl-code имеет неопределенное значение" skip
        "Документ" buf_doc-line.doc-code skip
        "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-num-entries-action = num-entries(p-action, chr(44))
    .
    do v-ind = 1 to v-num-entries-action
    :
      assign
        v-option = entry(v-ind, p-action, chr(44))
      .
      if num-entries(v-option, '=':u) <> 2
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Количество входений в опцию отлично от двух"
          "p-action" p-action skip
          "v-option" v-option skip
          view-as alert-box error .
        undo, return error .
      end.
      case entry(1, v-option, '=':u)
      :
        when 'prompt':u
        then do:
          assign
            v-prompt-price = v-option
          .
        end.
        when 'check-right':u
        then do:
          assign
            v-check-right = logical(entry(2, v-option, '=':u))
          .
        end.
        when 'izlcstpr':u
        then do :
            assign
                v-izlcstpr = v-option
            .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Неизвестная опция"
            "p-action" p-action skip
            "v-option" v-option skip
            view-as alert-box error .
          undo, return error .
        end.
      end case .
    end.
    if lookup(v-prompt-price, 'prompt=enable,prompt=disable-reject,prompt=disable-create':u ) > 0
    then do:
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "v-prompt-price" v-prompt-price skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      .
define variable v-negparts as character no-undo .
define variable v-negmanuf as character no-undo .
define variable v-prcshrs0 as character no-undo .
define variable v-prcshrs1 as character no-undo .
define variable v-prdocrs0 as character no-undo .
define variable v-prdocrs1 as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input 'rezerv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'negparts'  then  v-negparts  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'negmanuf'  then  v-negmanuf  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs0'  then  v-prcshrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prcshrs1'  then  v-prcshrs1  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs0'  then  v-prdocrs0  = thbjattr_thbj-attr.property-value-character.
  if thbjattr_thbj-attr.prop-code = 'prdocrs1'  then  v-prdocrs1  = thbjattr_thbj-attr.property-value-character.
end.
    if p-cst-code = ?
    then do:
      assign
        p-cst-code = (if buf_trn-doc.cst-code <> ?
                      then buf_trn-doc.cst-code
                      else "")
      .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'serial=request':u
  ,output l-goods-serial
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'serial=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'bottle=request':u
  ,output l-goods-bottle
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        'bottle=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
    then do:
      if buf_trn-doc.flag_ = no
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        assign
          l-fact-qnty = true
        .
      end.
    end.
    else do:
      define variable conf-par as character no-undo .
      define variable par-type as character no-undo .
      define variable lok      as logical no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output l-reserv-pl-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "place-rsrv=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-reserv-pl-code
      then do:
        return
          "Товар на объекте резервируется по складским местам" + chr(10)
          + "Создание партий запрещено " + chr(10)
          + "Объект " + string(buf_doc-line.obj-type)
              + " " + string(buf_doc-line.obj-code) + chr(10)
          + "Артикул " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code) + chr(10)
          .
      end.
      if buf_trn-doc.ext-doc-type = 'im':U
      then do:
      end.
      else do:
        conf-par  =  v-negparts .
        if buf_trn-doc.ext-doc-type = 're':U
        or buf_trn-doc.ext-doc-type = 'rs':U
        or buf_trn-doc.ext-doc-type = 'vt':U
        or buf_trn-doc.ext-doc-type = 'vp':U
        then do:
          if conf-par = "disable"
          or buf_goods.negative-rest = false
          then do:
            if v-prompt-price = 'prompt=enable':u and v-izlcstpr <> 'izlcstpr=enable':u
            then do:
              assign
                l-need-create-old-return = true
              .
            end.
          end.
        end.
        else do:
          if conf-par = "disable"
          then do:
            return
              "Порождение отрицательных партий для объекта "
              + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
              + " запрещено (negparts)"
              .
          end.
          if buf_goods.negative-rest = false
          then do:
            return
              "Для товара " + string(buf_doc-line.artic)
              + " " + string(buf_doc-line.prod-type)
              + " " + string(buf_doc-line.prod-code)
              + " запрещены отрицательные остатки"
              .
          end.
        end.
      end.
      if buf_trn-doc.ext-doc-type = 'ep':U
      then do:
        return
          "Недопустимо создавать порожденные партии для данного типа документа"
          .
      end.
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      then do:
        conf-par = v-negmanuf.
        if conf-par = "disable"
        then do:
          return
            "Для документа производства порождение отрицательных партий для объекта "
            + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
            + " запрещено (negmanuf)"
            .
        end.
      end.
      define variable v-reason as character no-undo .
      run partscr_check-valid-supp in this-procedure
        (input  p-supp-type
        ,input  p-supp-code
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        ,input  buf_trn-doc.ext-doc-type
        ,output l-create-old-return
        ,output v-reason
        ).
      if v-reason <> ""
      then do:
        return
          v-reason
          .
      end.
      if l-goods-serial = true
      then do:
        if not(buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = false
              and v-prompt-price = 'prompt=disable-create':u
              )
        then do:
          return
            "Порождение партий серийного товара допустимо только во внешнем приходе в интерфейсе партий."
            .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if l-create-old-return
        then do:
          if l-create-old-return
          then do:
            assign
              p-cli-qnty = 1
            .
          end.
        end.
        else do:
          return
            "Для товара с двумя единицами измерения допустимо создание партий во внешнем приходе или партий старого возврата"
            .
        end.
      end.
      if buf_trn-doc.doc-type = 'инв':U
      then do:
        assign
          l-fact-qnty = false
        .
      end.
      else do:
        if buf_trn-doc.doc-type = 'при':U
        and buf_trn-doc.internal = true
        and buf_trn-doc.discnt-type = 'прво':U
        then do:
          assign
            l-fact-qnty = false
          .
        end.
        else do:
          if buf_trn-doc.status_ = 'разрешен':U
          or (buf_trn-doc.doc-type = 'при':U
              and buf_trn-doc.internal = true
            )
          then do:
            assign
              l-fact-qnty = true
            .
          end.
          else do:
            assign
              l-fact-qnty = false
            .
          end.
        end.
      end.
    end.
    find buf_parts
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.part-code = p-part-code
      no-error.
    if not available buf_parts
    then do:
      assign
        v-action = ""
      .
      if  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = false
          )
      or  ( buf_trn-doc.doc-type = 'при':U
            and buf_trn-doc.internal = true
            and buf_trn-doc.discnt-type = 'прво':U
          )
      then do:
        assign
          v-action = "exit":u
        .
      end.
      else do:
        if v-check-right = true
        then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  p-user-id
    ,input  0
    ,input  'actn_parts_createneg':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_doc-line.obj-type
    ,input  buf_doc-line.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output lok
    )  .
end.
          if lok <> true
          then do:
            return "Отсутствуют права на создание порожденных партий" .
          end.
        end.
        if l-need-create-old-return
        or l-create-old-return
        then do:
        end.
        else do:
          define variable v-parameter-name as character no-undo .
          define variable v-document-name  as character no-undo .
          if p-part-reserv-base = 0
          or p-part-reserv-rubl = 0
          then do:
            run trg/partplas.p
              (input  buf_doc-line.obj-type
              ,input  buf_doc-line.obj-code
              ,input  buf_goods.gds-code
              ,input  buf_trn-doc.base-rate
              ,input  buf_trn-doc.base-scale
              ,output p-part-reserv-base
              ,output p-part-reserv-rubl
              ) .
          end.
          if buf_trn-doc.discnt-type = 'касс':U
          then do:
            assign
              v-action         = "exit":u
              v-document-name  = "продажи"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prcshrs0':U
                conf-par  = v-prcshrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prcshrs1':U
                conf-par  = v-prcshrs1
              .
            end.
          end.
          else do:
            assign
              v-action         = ""
              v-document-name  = "документа"
            .
            if  p-part-reserv-base = 0
            and p-part-reserv-rubl = 0
            then do:
              assign
                v-parameter-name = 'prdocrs0':U
                conf-par  = v-prdocrs0
              .
            end.
            else do:
              assign
                v-parameter-name = 'prdocrs1':U
                conf-par  = v-prdocrs1
              .
            end.
          end.
          if conf-par = ""
          or conf-par = ?
          then do:
            assign
              conf-par = "disable"
            .
          end.
          case conf-par :
            when "disable"
            then do:
              return
                "Для " + v-document-name + " " + buf_doc-line.doc-code + " порождение отрицательных партий для объекта "
                + string(buf_doc-line.obj-type) + " " + string(buf_doc-line.obj-code)
                + " c учетной ценой "
                + ( if p-part-reserv-base <> 0 then "не равной 0" else "равной 0")
                + " запрещено." + chr(10)
                + "Параметр " + v-parameter-name + "=" + conf-par + "."
                .
            end.
            when "enable"
            then do:
              assign
                v-action = "exit":u
              .
            end.
            when "prompt"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = ""
              .
            end.
            when "manual"
            then do:
              if v-prompt-price = 'prompt=disable-reject':u
              then do:
                return
                  "Требуется ручное редактирование партий" + chr(10)
                  + "В данном режиме резервирования ручное редактирование невозможно" + chr(10)
                  + "Параметр " + v-parameter-name + "=" + conf-par + "." + chr(10)
                  .
              end.
              assign
                v-action = "chg":u
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестное значение параметра" v-parameter-name skip
                "conf-par" conf-par skip
                view-as alert-box error .
              return
                "Неизвестное значение параметра " + v-parameter-name
                + " conf-par = " + conf-par
                .
            end.
          end.
        end.
      end.
      if l-need-create-old-return
      then do:
        assign
          v-action = "chg":u
        .
      end.
      if v-prompt-price = 'prompt=disable-create':u
      then do:
        assign
          v-action = "exit":u
        .
      end.
      if v-action = ""
      then do:
        assign
          v-action = "exit":u
        .
        run trg/in-price.w
          (input parparentproc
          ,input-output p-part-reserv-base
          ,input-output p-part-reserv-rubl
          ,output v-action
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,input  p-supp-type
          ,input  p-supp-code
          ,input  buf_trn-doc.base-rate
          ,input  buf_trn-doc.base-scale
          ,input  p-change-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запросе учетной цены" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return error .
        end.
      end.
      case v-action :
        when "chg":u
        then do:
          run str/partsedt.p
            (input parparentproc
            ,buffer buf_doc-line
            ,input  true
            ,input  false
            ,input  p-change-qnty
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при редактировании партий" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error .
          end.
        end.
        when "exit":u
        then do:
          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .
          if  buf_trn-doc.doc-type = 'при':U
          and buf_trn-doc.internal = false
          then do:
          end.
          else do:
            if l-goods-bottle
            then do:
              define variable v-gds-code    like ub.goods.gds-code  no-undo .
              define variable v-root-b-code like ub.bar-code.b-code no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  ?
  ,output v-root-b-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
              if v-price-sale = ?
              then do:
                return
                  "Для товара " + string(buf_doc-line.artic)
                  + " " + string(buf_doc-line.prod-type)
                  + " " + string(buf_doc-line.prod-code)
                  + " типа стеклопосуда не задана продажная цена"
                  .
              end.
            end.
            else do:
              assign
                v-road-tax = 0
                v-excise   = 0
              .
            end.
          end.
          define variable v-curr-r-b as character no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
          if p-dop = "" or p-dop = ? then do:
             if buf_trn-doc.ext-doc-type = 'ie':U then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
                define variable  v-dop1 as character no-undo .
                define variable  v-dop2 as character no-undo .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prod':U ,
                    output  v-dop1      ,
                    output  v-type )
                    no-error .
                run lineattr-value in this-procedure (
                    input   buf_trn-doc.doc-code  ,
                    input   v-gds-code  ,
                    input   'price-prodvat':U ,
                    output  v-dop2   ,
                    output  v-type )
                    no-error .
                    p-dop = substitute("&1;&2" , v-dop1, v-dop2) .
             end.
             if p-dop = ? then p-dop = "" .
          end.
          create buf_parts .
          assign
            buf_parts.obj-type       = buf_doc-line.obj-type
            buf_parts.obj-code       = buf_doc-line.obj-code
            buf_parts.artic          = buf_doc-line.artic
            buf_parts.prod-type      = buf_doc-line.prod-type
            buf_parts.prod-code      = buf_doc-line.prod-code
            buf_parts.in-code        = buf_doc-line.doc-code
            buf_parts.out-code       = buf_doc-line.doc-code
            buf_parts.part-code      = p-part-code
            buf_parts.cst-code       = p-cst-code
            buf_parts.pl-code        = p-pl-code
            buf_parts.ps             = p-ps
            buf_parts.dop            = p-dop
            buf_parts.doc-type       = buf_trn-doc.doc-type
            buf_parts.status_        = no
            buf_parts.qnty           = 0
            buf_parts.fact-qnty      = 0
            buf_parts.cli-qnty       = 0
            buf_parts.real-qnty      = 0
            buf_parts.transport-base = 0
            buf_parts.transport-rubl = 0
            buf_parts.other-base     = 0
            buf_parts.other-rubl     = 0
            buf_parts.supp-type      = p-supp-type
            buf_parts.supp-code      = p-supp-code
            buf_parts.host-code      = buf_trn-doc.host-code
            buf_parts.last-date      = p-last-date
            buf_parts.hold-date      = p-hold-date
            buf_parts.vat-type       = p-vat-type
            buf_parts.vat-pc         = p-vat-pc
            buf_parts.slt-type       = p-slt-type
            buf_parts.slt-pc         = p-slt-pc
            buf_parts.contract-code  = buf_trn-doc.contract-code
          .
          if buf_trn-doc.ext-doc-type = 'ie':U
          or buf_trn-doc.ext-doc-type = 'im':U
          then do:
            if buf_trn-doc.ext-doc-type = 'ie':U
            then do:
              assign
                buf_parts.is-supp       = yes
              .
            end.
            else do:
              assign
                buf_parts.is-supp       = no
              .
            end.
            assign
              buf_parts.rsrv-free     = ?
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = buf_trn-doc.purch-code
              buf_parts.exch-code     = buf_trn-doc.exch-code
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.price-cli     = buf_doc-line.price-cli
              buf_parts.price-base    = buf_doc-line.price-base
              buf_parts.price-rubl    = buf_doc-line.price-rubl
            .
            if v-curr-r-b = 'base':U
            then do:
              assign
                buf_parts.road-tax-base = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-rubl = buf_parts.road-tax-base
                                        * buf_trn-doc.base-rate
                                        / buf_trn-doc.base-scale
              .
            end.
            else do:
              assign
                buf_parts.road-tax-rubl = buf_doc-line.road-tax
              .
              assign
                buf_parts.road-tax-base = buf_parts.road-tax-rubl
                                        / buf_trn-doc.base-rate
                                        * buf_trn-doc.base-scale
              .
            end.
            if  l-goods-twounit = false
            and buf_trn-doc.ext-doc-type = 'ie':U
            then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   buf_trn-doc.doc-code
  ,input   buf_trn-doc.base-rate
  ,input   buf_trn-doc.base-scale
  ,input   buf_trn-doc.exch-rate
  ,input   buf_trn-doc.exch-scale
  ,input   buf_trn-doc.vat-type
  ,input   buf_trn-doc.slt-type
  ,input   buf_parts.artic
  ,input   buf_parts.prod-type
  ,input   buf_parts.prod-code
  ,input   buf_parts.price-cli
  ,input   buf_parts.cli-base-rate
  ,input   buf_parts.price-rubl
  ,input   buf_parts.vat-pc
  ,input   buf_parts.slt-pc
  ,input   buf_doc-line.road-tax
  ,input   buf_parts.transport-rubl
  ,input   buf_parts.other-rubl
  ,output  v-price-cli
  ,output  v-price-cli-unit-base
  ,output  v-price-road-tax
  ,output  v-price-other-exp
  ,output  v-price-transport-exp
  ,output  v-price-without-abs
  ,output  v-price-slt
  ,output  v-price-no-slt
  ,output  v-price-vat
  ,output  v-price-no-vat-slt
  ,output  v-price-rubl
  ,output  v-price-road-tax-rubl
  ,output  v-price-other-exp-rubl
  ,output  v-price-transport-exp-rubl
  ,output  v-price-without-abs-rubl
  ,output  v-price-slt-rubl
  ,output  v-price-no-slt-rubl
  ,output  v-price-vat-rubl
  ,output  v-price-no-vat-slt-rubl
  ,output  v-price-base
  ,output  v-price-road-tax-base
  ,output  v-price-other-exp-base
  ,output  v-price-transport-exp-base
  ,output  v-price-without-abs-base
  ,output  v-price-slt-base
  ,output  v-price-no-slt-base
  ,output  v-price-vat-base
  ,output  v-price-no-vat-slt-base
  ) no-error.
              if error-status :error
              then do:
                return error "Ошибка при пересчете линии документа".
              end.
              assign
                buf_parts.price-cli  = v-price-cli
                buf_parts.price-rubl = v-price-rubl
                buf_parts.price-base = v-price-base
              .
            end.
          end.
          else do:
            define variable v-curr-r-b-code as integer no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_trn-doc.host-code
  ,output v-curr-r-b-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры basecode.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.rsrv-free     = (if can-do('рас,спи':U, buf_trn-doc.doc-type)
                                          or (can-do('инв':U, buf_trn-doc.doc-type)
                                              and (buf_parts.qnty + p-change-qnty) < 0
                                              )
                                        then yes
                                        else no
                                      )
              buf_parts.is-supp       = ( if l-create-old-return then yes else no )
              buf_parts.pay-code      = buf_trn-doc.pay-code
              buf_parts.purch-code    = integer('1':U)
              buf_parts.price-base    = p-part-reserv-base
              buf_parts.price-rubl    = p-part-reserv-rubl
              buf_parts.road-tax-base = 0
              buf_parts.road-tax-rubl = 0
              buf_parts.cli-base-rate = buf_doc-line.cli-base-rate
              buf_parts.exch-code     = 0
              buf_parts.price-cli     = buf_parts.price-rubl
            .
          end.
          validate buf_parts .
        end.
        when "quit":u
        then do:
        end.
      end case .
    end.
    if available buf_parts
    then do:
      if l-fact-qnty
      then do:
        assign
          buf_parts.fact-qnty = buf_parts.fact-qnty + p-change-qnty
        .
      end.
      else do:
        assign
          buf_parts.qnty      = buf_parts.qnty + p-change-qnty
          buf_parts.fact-qnty = buf_parts.qnty
        .
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          assign
            buf_parts.rsrv-free     = ( if buf_parts.qnty < 0
                                        then true
                                        else false
                                      )
          .
        end.
      end.
      if l-goods-twounit = true
      then do:
        if p-cli-qnty <> 0
        then do:
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
          assign
            buf_parts.cli-base-rate = buf_parts.qnty / buf_parts.cli-qnty
          .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if abs(buf_parts.cli-qnty - p-cli-qnty) < 0.0011
        then do :
          assign
            buf_parts.cli-qnty = p-cli-qnty
          .
        end .
      end.
      if l-goods-twounit = false
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run qntycalc in g#library
  (input  'cli-qnty'
  ,input  buf_parts.cli-base-rate
  ,input  buf_parts.cli-qnty
  ,input  buf_parts.qnty
  ,output buf_parts.cli-qnty
  ,output buf_parts.qnty
  ) no-error .
        if error-status :error
        then do:
          message
            "Невозможно пересчитать количество по ТТН" skip
            "Документ" buf_parts.out-code skip
            'Артикул':U buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" + string(buf_parts.part-code) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.
      if l-goods-serial
      then do:
        if  buf_parts.qnty <> 0
        and buf_parts.qnty <> 1
        then do:
          message
            "Товар серийный." skip
            "Невозможно порождение партии с количеством, отличным от 1."
            view-as alert-box .
          undo, return error .
        end.
      end.
    end.
    return .
  end.
end procedure.
procedure partscr_check-valid-supp :
  define input parameter  p-supp-type         like ub.parts.supp-type no-undo .
  define input parameter  p-supp-code         like ub.parts.supp-code no-undo .
  define input parameter  p-trn-doc-supp-type like ub.parts.supp-type no-undo .
  define input parameter  p-trn-doc-supp-code like ub.parts.supp-code no-undo .
  define input parameter  p-extended-doc-type as character no-undo .
  define output parameter p-old-return        as logical no-undo .
  define output parameter p-reason            as character no-undo .
  assign
    p-old-return = false
    p-reason     = ""
  .
  if p-supp-type <> p-trn-doc-supp-type
  or p-supp-code <> p-trn-doc-supp-code
  then do:
    if p-extended-doc-type = 're':U
    or p-extended-doc-type = 'rs':U
    or p-extended-doc-type = 'vt':U
    or p-extended-doc-type = 'vp':U
    then do:
      if p-supp-type = 'чел':U
      or p-supp-type = 'орг':U
      then do:
        assign
          p-old-return = true
        .
      end.
      else do:
        assign
          p-reason = "Поставщиком партии старого возврата может быть только человек или организация"
        .
        return .
      end.
    end.
    else do:
      assign
        p-reason = "Поставщиком порожденной партии может быть только объект документа"
      .
      return .
    end.
  end.
  return .
end procedure.
procedure partscr_get-default-values :
  define parameter buffer buf_doc-line for ub.doc-line .
  define output parameter p-vat-type   as character no-undo .
  define output parameter p-vat-pc     as decimal   no-undo .
  define output parameter p-slt-type   as character no-undo .
  define output parameter p-slt-pc     as decimal   no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .
  define variable v-vat-pc as decimal   no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задана строка документа" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Код документа" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка поиска товара" skip
        "Товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'im':U
    then do:
      assign
        p-vat-type = buf_trn-doc.vat-type
        p-vat-pc   = buf_doc-line.vat-pc
        p-slt-type = buf_trn-doc.slt-type
        p-slt-pc   = buf_doc-line.slt-pc
      .
    end.
    else do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
      assign
        p-vat-type = 'в т. ч.':U
        p-vat-pc   = v-vat-pc
        p-slt-type = 'без':U
        p-slt-pc   = 0
      .
    end.
  end.
end procedure.
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-trndocrs-gds-dtl-rsrv no-undo
  field prt-code         like ub.gds-dtl.prt-code
  field rsrv-qnty        like ub.gds-dtl.fact-qnty
  field rsrv-out-qnty    like ub.gds-dtl.fact-qnty
  index xpk is primary unique prt-code
.
define temp-table temp-trndocrs-pl-gds-rsrv no-undo
  field pl-code          like ub.pl-gds.pl-code
  field rsrv-qnty        like ub.pl-gds.free-qnty
  field cli-rsrv-qnty    like ub.pl-gds.cli-free-qnty
  field rsrv-out-qnty    like ub.pl-gds.fact-qnty
  field before-free-qnty like ub.pl-gds.fact-qnty
  field before-out-qnty  like ub.pl-gds.fact-qnty
  field after-free-qnty  like ub.pl-gds.fact-qnty
  field after-out-qnty   like ub.pl-gds.fact-qnty
  field fact-qnty        like ub.pl-gds.fact-qnty
  field cli-qnty         like ub.pl-gds.cli-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  index xpk is primary unique pl-code
.
procedure trndocrs-gds-dtl-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-clear :
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-accum :
  define input parameter p-pl-code       like ub.pl-gds.pl-code       no-undo .
  define input parameter p-rsrv-qnty     like ub.pl-gds.free-qnty     no-undo .
  define input parameter p-cli-rsrv-qnty like ub.pl-gds.cli-free-qnty no-undo .
  define input parameter p-fact-qnty     like ub.pl-gds.fact-qnty     no-undo .
  define input parameter p-cli-fact-qnty like ub.pl-gds.cli-fact-qnty no-undo .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-pl-gds-rsrv
      where buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      no-error .
    if not available buf_temp-trndocrs-pl-gds-rsrv then do:
      create buf_temp-trndocrs-pl-gds-rsrv .
      assign
        buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     = buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     + p-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty + p-cli-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     = buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     + p-fact-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty + p-cli-fact-qnty
    .
  end.
end procedure.
procedure trndocrs-gds-dtl-accum :
  define input parameter p-prt-code   like ub.gds-dtl.prt-code   no-undo .
  define input parameter p-rsrv-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv  for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-gds-dtl-rsrv
      where buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      no-error .
    if not available buf_temp-trndocrs-gds-dtl-rsrv then do:
      create buf_temp-trndocrs-gds-dtl-rsrv .
      assign
        buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      .
    end.
    assign
      buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty = buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
                                             + p-rsrv-qnty
    .
  end.
end procedure.
procedure trndocrs-pl-gds-request :
  define input parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define input parameter p-field-accum            as character no-undo .
  define variable vss-description as character no-undo init "trndocrs-pl-gds-request: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    if lookup(p-field-accum, "before,after":u ) = 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров параметров" skip
        "Неизвестное значение параметра" skip
        "p-field-accum" p-field-accum skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case p-field-accum :
      when "before":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty = 0
            buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty  = 0
          .
        end.
      end.
      when "after":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty  = 0
            buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty   = 0
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка задания входных параметров параметров" skip
          "Неизвестное значение параметра" skip
          "p-field-accum" p-field-accum skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define buffer buf_parts for ub.parts.
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      find first buf_temp-trndocrs-pl-gds-rsrv
        where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        no-error .
      if not available buf_temp-trndocrs-pl-gds-rsrv then do:
        create buf_temp-trndocrs-pl-gds-rsrv .
        assign
          buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        .
      end.
      if can-do('при,рас,спи':U, p-doc-type)
      or (p-doc-type = 'инв':U
          and buf_parts.fact-qnty < 0)
      then do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-calc-rsrv :
  define variable vss-description as character no-undo init "trndocrs-pl-gds-calc-rsrv: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
      .
    end.
  end.
end procedure.
procedure trndocrs-need-rsrv :
  define input  parameter p-doc-type     like ub.trn-doc.doc-type no-undo .
  define input  parameter p-artic        like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code    like ub.doc-line.prod-code no-undo .
  define output parameter p-need-rsrv    as logical   no-undo .
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    if buf_goods.gds-type = 'т':U
    and ( p-doc-type = 'рас':U
          or p-doc-type = 'спи':U
        )
    then do:
      assign
        p-need-rsrv = true
      .
    end.
    else do:
      assign
        p-need-rsrv = false
      .
    end.
  end.
end procedure.
procedure trndocrs-need-create-doc-pl :
  define input  parameter p-extended-doc-type  as character no-undo .
  define input  parameter p-news               as logical   no-undo .
  define input  parameter p-sale-auto          as logical   no-undo .
  define output parameter p-need-create-doc-pl as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  not p-news
    and p-extended-doc-type <> 'ie':U
    and p-extended-doc-type <> 'es':U
    and p-extended-doc-type <> 'rs':U
    and not p-sale-auto
    then do:
      assign
        p-need-create-doc-pl = true
      .
    end.
    else do:
      assign
        p-need-create-doc-pl = false
      .
    end.
  end.
end procedure.
procedure trndocrs-validate :
  define input parameter p-place-rsrv as logical no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define variable v-total-gds-dtl-rsrv-qnty as decimal no-undo .
  define variable v-total-pl-gds-rsrv-qnty as decimal no-undo .
  assign
    v-total-gds-dtl-rsrv-qnty = 0
    v-total-pl-gds-rsrv-qnty  = 0
  .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-gds-dtl-rsrv-qnty = v-total-gds-dtl-rsrv-qnty
                                  + buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
      .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-pl-gds-rsrv-qnty = v-total-pl-gds-rsrv-qnty
                                 + buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
      .
    end.
    if round(v-total-gds-dtl-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при резервировании свободных количеств" skip
        "Запрошено резервирование:" skip
        "По товару" p-chg-qnty skip
        "По признакам" v-total-gds-dtl-rsrv-qnty skip
        "По складским местам" v-total-pl-gds-rsrv-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-place-rsrv then do:
      if round(v-total-pl-gds-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при резервировании свободных количеств" skip
          "Запрошено резервирование:" skip
          "По товару" p-chg-qnty skip
          "По признакам" v-total-gds-dtl-rsrv-qnty skip
          "По складским местам" v-total-pl-gds-rsrv-qnty skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure trndocrs :
  define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
  define input parameter p-obj-type   like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code   like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic      like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_db         for ub.db .
  define buffer buf_gds-obj    for ub.gds-obj .
  define buffer buf_prt-obj    for ub.prt-obj .
  define buffer buf_gds-prt    for ub.gds-prt .
  define buffer buf_goods      for ub.goods .
  define buffer buf_pl-gds     for ub.pl-gds .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define variable v-node-code   like ub.gds-prt.node-code no-undo .
  define variable v-curr-db-num like ub.db.db-num         no-undo .
  define variable v-cmd         as   character            no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при поиске товара на объекте" skip
        "p-obj-type"  p-obj-type  skip
        "p-obj-code"  p-obj-code  skip
        "p-artic"     p-artic     skip
        "p-prod-type" p-prod-type skip
        "p-prod-code" p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
    run trndocrs-validate in this-procedure
      (input buf_gds-obj.place-rsrv
      ,input p-chg-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Противоречивые данные для резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_gds-obj.free-qnty   = buf_gds-obj.free-qnty - p-chg-qnty
      buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
    find first buf_db no-lock
      where buf_db.db-num = v-curr-db-num
      .
    if buf_db.db-num <> 0
      and buf_db.on-line-rest = true
    then do:
      assign
        v-cmd = "command":U + chr(1)
                + "create":U + chr(1)
                + "on-line-rest":U + chr(1)
                + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
      .
      run nws/cr-route.p
        ( input 'send-cmd':U
          ,input v-cmd
          ,input ?
          ,input "0":U
        ).
    end.
    if buf_gds-obj.place-rsrv = true then do:
      for each buf_temp-trndocrs-pl-gds-rsrv
      on error undo, return error return-value
      :
        find first buf_goods no-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "Не найдена товар" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_pl-gds exclusive-lock
          where buf_pl-gds.obj-type = p-obj-type
            and buf_pl-gds.obj-code = p-obj-code
            and buf_pl-gds.gds-code = buf_goods.gds-code
            and buf_pl-gds.pl-code  = buf_temp-trndocrs-pl-gds-rsrv.pl-code
          no-error .
        if not available buf_pl-gds then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "Не найдена привязка товара к складскому месту" skip
            "Код товара" buf_temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty
        .
        if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
          and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
        then do:
          assign
            buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_temp-trndocrs-gds-dtl-rsrv.prt-code
  ,output v-node-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при определении первого терминального признака" skip
          "prt-code" buf_temp-trndocrs-gds-dtl-rsrv.prt-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      do while available buf_gds-prt
      on error undo, return error return-value
      :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  )  .
        find current buf_prt-obj exclusive-lock .
        assign
          buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
        .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.
  end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION Base2Int64 RETURNS INT64 ( INPUT i-hex AS CHARACTER, INPUT i-base AS INTEGER ) :
  DEFINE VARIABLE j_num AS INT64 NO-UNDO.
  RUN conv-base-to-int64 IN THIS-PROCEDURE ( INPUT i-hex, INPUT i-base, OUTPUT j_num ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_num ).
END FUNCTION.
PROCEDURE conv-base-to-int64 :
  DEFINE  INPUT PARAMETER p-num  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-base AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-int  AS INT64     NO-UNDO.
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  DEFINE VARIABLE jj     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j_sign AS INT64   NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-base > 60 THEN DO:
      ASSIGN p-int = ?.
      UNDO, RETURN ERROR.
    END.
    ASSIGN v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U +
                    'Б,Г,Д,Ё,Ж,З,И,Й,Л,П,У,Ф,Ц,Ч,Ш,Щ,Ъ,Ы,Ь,Э,Ю,Я,@,$':U
           v_list = SUBSTRING( v_list, 1, p-base * 2 - 1 )
           p-num  = TRIM( p-num ).
    IF SUBSTRING( p-num, 1, 1 ) = "-" THEN DO:
        ASSIGN j_sign = -1
               p-num  = SUBSTRING( p-num, 2 ).
    END.                              ELSE DO: ASSIGN j_sign = 1. END.
    DO jj = 1 TO LENGTH( p-num ) :
      ASSIGN p-int = p-int * p-base + LOOKUP( SUBSTRING( p-num, jj, 1 ), v_list ) - 1.
    END.
    ASSIGN p-int = j_sign * p-int.
  END.
END PROCEDURE.
def var vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info34 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info34, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info34, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info34, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info34, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info34 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info34, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info34 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info34, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info34, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info34, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info34, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info34, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info34, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info34 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info34 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info34, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info34, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info34, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info34 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info34 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info34, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info34, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
  define temp-table tt-alc-codes
    field alc-code      as character
    field qnty          as decimal
    index pi as primary unique
      alc-code
  .
  define temp-table tt-marks
    field mark as character
    field qnty as integer
    index pi as primary unique
      mark
  .
  define temp-table tt-tobacco-marks
    field mark as character case-sensitive
    field unit as character
    field qnty as integer
    field to-ungroup as logical
    field is-weight as logical
    field weight as decimal
    index pi as primary unique
      mark
    index un
      unit ascending
  .
  define buffer buf_tt-tobacco-marks for tt-tobacco-marks .
  define temp-table tt-tobacco-part-qnty
    field part-row as rowid
    field qnty as decimal
    index pi as primary unique
      part-row
  .
procedure rsrv-doc :
  define input  parameter parparentproc          AS WIDGET-HANDLE           NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define input  parameter p-trn-doc-recid        as recid     no-undo .
  define input  parameter p-doc-line-recid       as recid     no-undo .
  define input  parameter p-reserv-base          as decimal   no-undo .
  define input  parameter p-reserv-rubl          as decimal   no-undo .
  define input  parameter p-partscr-prompt-price as character no-undo .
  define input  parameter p-extended-doc-type    as character no-undo .
  define input  parameter p-reserv-single-part   as logical   no-undo .
  define input  parameter p-in-code              as character no-undo .
  define input  parameter p-part-code            as character no-undo .
  define input  parameter p-reserv-pl-code       as logical   no-undo .
  define input  parameter p-pl-code              as character no-undo .
  define input  parameter p-goods-serial         as logical   no-undo .
  define input  parameter p-goods-twounit        as logical   no-undo .
  define input  parameter p-purch-code-list      as character no-undo .
  define input  parameter p-chg-qnty             as decimal   no-undo .
  define input  parameter p-unreserv-other-sign  as logical   no-undo .
  define output parameter p-real-chg-qnty        as decimal   no-undo .
  define variable vss-description as character no-undo init "rsrv-doc: Процедура резервирования партий".
  define variable v-chg-qnty-sign   as integer         no-undo .
  define variable v-rsrv-code       as character       no-undo .
  define variable v-reason          as character       no-undo .
  define variable v-process-part    as logical         no-undo .
  define variable v-real-chg-qnty   like ub.parts.qnty no-undo .
  define variable v-parts-recid     as recid           no-undo .
  define variable v-check-part-qnty as decimal         no-undo .
  define buffer buf_parts    for ub.parts .
  define buffer buf2_parts   for ub.parts .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf1_doc-line-attr for ub.doc-line-attr .
  define buffer buf1_goods    for ub.goods .
  define buffer buf_goods    for ub.goods .
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf2_gen-attr for ub.gen-attr .
  define variable v-part-key        as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-mark-alchol     as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-attr-value      as character no-undo .
  define variable vCodeIdent        as character no-undo .
  define variable v-mark as character no-undo .
  define variable v-mark-list as character no-undo .
  define variable v-alc-code as character no-undo .
  define variable mark-ii as integer  no-undo .
  define variable jj as integer  no-undo .
  define variable v-alc-qnty as decimal no-undo .
  define variable v-tobacco-mark      as character  no-undo .
  define variable v-tobacco-mark-list as character  no-undo .
  define variable v-mark-tobacco      as logical    no-undo .
  define variable v-box-qnty          as integer    no-undo .
  define variable v-GTIN              as character  no-undo .
  define variable v-GTIN-qnty         as integer    no-undo .
   define buffer buf_marking         for ub.marking .
  define buffer buf_marking-childs  for ub.marking .
  define buffer buf_marking-lines   for ub.marking-lines .
  define buffer buf_marking-chk     for ub.marking-chk .
  define variable v-copy-doc-code     as character  no-undo .
  define buffer buf_copy-trn-doc    for ub.trn-doc .
  define buffer buf_utd-lines       for ub.utd-lines .
  define buffer buf_utd-marking-lines for ub.utd-marking-lines .
  define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
  define variable varb-code like ub.bar-code.b-code .
  define variable vardoc-num     like ub.price-list.doc-num    no-undo .
  define variable varprice-sale  like ub.price-list.price-sale no-undo .
  define variable varroad-tax    like ub.price-list.road-tax   no-undo .
  define variable varexcise      like ub.price-list.excise     no-undo .
  define variable varcur-vat-pc  like ub.price-list.vat-pc     no-undo .
  define variable varcur-slt-pc  like ub.price-list.slt-pc     no-undo .
  define variable varprice-rubl  as decimal no-undo .
  define variable varprice-base  as decimal no-undo .
  define variable vIsExemplarGoods as logical no-undo init false.
  define variable v-isweighed as logical no-undo init false.
  define variable varvalue as character no-undo .
  define variable vartype  as character no-undo .
  define variable v-mark-weight as decimal   no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Указатель" p-doc-line-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
         no-error.
    if avail buf_goods then
    do:
      run isExemplarGoods in this-procedure
          (buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code).
      RUN gds-attr-value (
                          INPUT buf_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT varvalue,
                          OUTPUT vartype
                          ).
      v-isweighed = WeighedProd(buf_goods.gds-code)
                and varvalue > ""
                and (EDOParSec:GetIsEDOForType(varvalue)
                  or EDOParSec:GetIsArticForType(varvalue))
      .
    end.
    v-mark-alchol = true .
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
    if p-pl-code <> ? and trim(p-pl-code) <> "" and p-pl-code <> "0"
    then
    v-izlcstpr = false .
    empty temp-table tt-alc-codes .
    output stream tobacco-rsrv to value ("tobacco-rsrv.log") .
    if buf_trn-doc.ext-doc-type = 'es':U
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                    and bar-code.unit-cli = buf_doc-line.unit-cli .
      for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_doc-line.doc-code
        and not ub.chk-doc.chk-type = integer ('8':U):
        for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code
                                   and chk-gds.b-code = bar-code.b-code:
          for each chk-gds-attr no-lock where chk-gds-attr.doc-code = chk-gds.doc-code
                                          and chk-gds-attr.line-num = chk-gds.line-num
                                          and chk-gds-attr.attr-code = "mark-code":
            do mark-ii = 1 to num-entries(chk-gds-attr.attr-value) :
              v-mark = entry(mark-ii, chk-gds-attr.attr-value) .
              find first tt-marks exclusive-lock where tt-marks.mark = v-mark no-error .
              if not available tt-marks
              then do :
                create tt-marks.
                tt-marks.mark = v-mark.
                tt-marks.qnty = 0 .
              end .
              tt-marks.qnty = tt-marks.qnty + (chk-gds.doc-qnty / abs(chk-gds.doc-qnty)) .
            end .
          end .
        end .
      end .
    end .
    if buf_trn-doc.ext-doc-type = 'es':U
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      RUN gds-attr-value (
                          INPUT buf1_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-attr-value)
      then do :
        find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                      and bar-code.unit-cli = buf_doc-line.unit-cli .
        for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_doc-line.doc-code
          and ub.chk-doc.chk-type = integer ('1':U):
          for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code
                                     and chk-gds.b-code = bar-code.b-code:
            for each buf_marking-chk no-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                               and buf_marking-chk.line-num = chk-gds.line-num
                                               :
              if chg-qnty > 0 and buf_marking-chk.sts = 1 then next .
              if chg-qnty < 0 and buf_marking-chk.sts = 0 then next .
              if buf_marking-chk.sts = 2 then next .
              assign vCodeIdent = GetCodeIdent(buf_marking-chk.mark) .
              find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = vCodeIdent no-error .
              find first buf_marking no-lock where buf_marking.mark begins vCodeIdent no-error .
              if not available tt-tobacco-marks
              then do :
                create tt-tobacco-marks.
                tt-tobacco-marks.mark = vCodeIdent .
                tt-tobacco-marks.qnty = 0 .
              end .
              if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
              tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + (chk-gds.doc-qnty / abs(chk-gds.doc-qnty)) .
            end .
          end .
        end .
      end .
    end .
    if buf_trn-doc.ext-doc-type = 'rs':U
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      RUN gds-attr-value (
                          INPUT buf1_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-attr-value)
      then do :
        find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                      and bar-code.unit-cli = buf_doc-line.unit-cli .
        for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_trn-doc.out-code
          and (ub.chk-doc.chk-type = integer ('6':U) or ub.chk-doc.chk-type = integer ('69':U) ):
          for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code
                                     and chk-gds.b-code = bar-code.b-code:
            for each buf_marking-chk no-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                               and buf_marking-chk.line-num = chk-gds.line-num
                                               :
              if buf_marking-chk.sts = 2 then next .
              assign vCodeIdent = GetCodeIdent(buf_marking-chk.mark) .
              find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = vCodeIdent no-error .
              find first buf_marking no-lock where buf_marking.mark = vCodeIdent no-error .
              if not available tt-tobacco-marks
              then do :
                create tt-tobacco-marks.
                tt-tobacco-marks.mark = vCodeIdent .
                tt-tobacco-marks.qnty = 0 .
              end .
              if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
              tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + 1 .
            end .
          end .
        end .
      end .
    end .
    define variable v-keyrec   as character no-undo .
    for each ub.fbr-line no-lock where buf_trn-doc.ext-doc-type = 'wm':U
      and ub.fbr-line.doc-code = buf_doc-line.doc-code
      and ub.fbr-line.artic = buf_doc-line.artic
      and ub.fbr-line.prod-type = buf_doc-line.prod-type
      and ub.fbr-line.prod-code = buf_doc-line.prod-code
      :
        run gen-key-rec(input "fbr-line",input buffer ub.fbr-line:handle ,output v-keyrec).
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark-fbr':U
                                        and buf_gen-attr.p-key = v-keyrec
                                        :
          find first buf2_gen-attr no-lock where
                buf2_gen-attr.table-name = 'excise-mark-fbr':U
            and buf2_gen-attr.p-key = v-keyrec
            and buf2_gen-attr.attr-code = buf_gen-attr.attr-code no-error.
          find current buf2_gen-attr exclusive-lock.
          buf2_gen-attr.table-name = 'excise-mark':U.
          buf2_gen-attr.p-key = buf2_gen-attr.attr-value.
          buf2_gen-attr.attr-value = "".
          create tt-marks.
          tt-marks.mark = buf2_gen-attr.attr-code.
          tt-marks.qnty = 1.
        end.
    end.
    for each tt-marks exclusive-lock :
      if tt-marks.qnty = 0 then delete tt-marks .
      else
      if tt-marks.qnty <> 1
      then do :
        if not g#auto
        then do :
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не правильное количество по марке - " string(tt-marks.qnty) skip
          "Марка " tt-marks.mark skip
          view-as alert-box error .
        end .
        undo, return error return-value .
      end.
    end.
    for each tt-marks no-lock :
      run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
      if v-alc-code = '' or v-alc-code = ?
      then do :
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения алкогольного кода" skip
          "Марка - " v-mark skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-alc-code > ''
      then do :
        find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code = v-alc-code no-error.
        if not available tt-alc-codes
        then do :
            create tt-alc-codes.
            assign tt-alc-codes.alc-code = v-alc-code .
        end.
        tt-alc-codes.qnty = tt-alc-codes.qnty + 1 .
      end.
    end.
    if p-mark = "tech-marks"
    then do :
      assign
        p-mark = ""
      .
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                      and buf1_goods.prod-type  = buf_doc-line.prod-type
                                      and buf1_goods.prod-code  = buf_doc-line.prod-code .
      for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf1_goods.gds-code
                                           and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                           and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                           and buf_marking-lines.out-code = 'free-zone':U
                                           and buf_marking-lines.mark begins 'tech_':U
                                           :
        find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-lines.mark no-error .
        find first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark no-error .
        if not available tt-tobacco-marks
        then do :
          create tt-tobacco-marks.
          tt-tobacco-marks.mark = buf_marking-lines.mark  .
          tt-tobacco-marks.qnty = 1 .
        end .
        if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
      end .
    end .
    if p-mark <> ""
    and num-entries(p-mark, chr(4)) = 2
    and entry(1, p-mark, chr(4)) = "copy-ret"
    then do :
      assign
        v-copy-doc-code = entry(2, p-mark, chr(4))
        p-mark = ""
      .
      find first buf_copy-trn-doc no-lock where buf_copy-trn-doc.doc-code = v-copy-doc-code no-error .
      if available buf_copy-trn-doc
      then do :
        find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                        and buf1_goods.prod-type  = buf_doc-line.prod-type
                                        and buf1_goods.prod-code  = buf_doc-line.prod-code .
        for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf1_goods.gds-code
                                             and buf_marking-lines.obj-type = buf_copy-trn-doc.obj-type
                                             and buf_marking-lines.obj-code = buf_copy-trn-doc.obj-code
                                             and buf_marking-lines.out-code = buf_copy-trn-doc.doc-code
                                             :
          find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-lines.mark no-error .
          find first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark no-error .
          if not available tt-tobacco-marks
          then do :
            create tt-tobacco-marks.
            tt-tobacco-marks.mark = buf_marking-lines.mark  .
            tt-tobacco-marks.qnty = 1 .
          end .
          if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
        end .
      end .
    end .
    if p-mark <> ""
    and num-entries(p-mark, chr(4)) = 2
    and entry(1, p-mark, chr(4)) = "copy-utd-line"
    then do :
      assign
        v-copy-doc-code = entry(2, p-mark, chr(4))
        p-mark = ""
      .
      find first buf_utd-lines no-lock where recid(buf_utd-lines) = integer(v-copy-doc-code) no-error .
      if available buf_utd-lines
      then do :
        for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                                 and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                                 and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum
                                                 and doc-level = 1
                                                 :
          find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_utd-marking-lines.mark no-error .
          find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
          if not available tt-tobacco-marks
          then do :
            create tt-tobacco-marks.
            tt-tobacco-marks.mark = buf_marking.mark  .
            tt-tobacco-marks.qnty = 1 .
          end .
          if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
        end .
      end .
    end .
    for each tt-tobacco-marks no-lock where tt-tobacco-marks.qnty = -1
                                        and tt-tobacco-marks.unit = "UNIT",
    first buf_marking-childs no-lock where buf_marking-childs.mark = tt-tobacco-marks.mark,
    first buf_tt-tobacco-marks exclusive-lock where buf_tt-tobacco-marks.mark = buf_marking-childs.mark-parent :
      buf_tt-tobacco-marks.to-ungroup = true .
    end .
    for each buf_tt-tobacco-marks exclusive-lock where buf_tt-tobacco-marks.to-ungroup :
      for each buf_marking-childs no-lock where buf_marking-childs.mark-parent = buf_tt-tobacco-marks.mark :
        find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-childs.mark no-error .
        if not available tt-tobacco-marks
        then do :
          create tt-tobacco-marks.
          tt-tobacco-marks.mark = buf_marking-childs.mark .
          tt-tobacco-marks.unit = buf_marking-childs.unit-ext .
          tt-tobacco-marks.qnty = 0 .
        end .
        tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + 1 .
      end .
      delete buf_tt-tobacco-marks .
    end .
    for each tt-tobacco-marks exclusive-lock :
      if tt-tobacco-marks.qnty = 0 then delete tt-tobacco-marks .
      else
      if tt-tobacco-marks.qnty <> 1
      then do :
        undo, return error return-value .
      end.
    end.
    if p-mark <> "" and not buf_trn-doc.ext-doc-type = 'vt':U
    then do :
      find first buf_marking no-lock where buf_marking.mark begins p-mark no-error .
      find first tt-tobacco-marks no-lock where tt-tobacco-marks.mark = p-mark no-error .
      if available buf_marking
      and not available tt-tobacco-marks
      then do :
        create tt-tobacco-marks .
        assign
          tt-tobacco-marks.mark = buf_marking.mark
          tt-tobacco-marks.qnty = 1
          tt-tobacco-marks.unit = buf_marking.unit-ext
          tt-tobacco-marks.qnty = buf_marking.box-qnty
          p-mark = ""
          v-mark-tobacco = true
        .
        if v-isweighed
        then do :
          v-mark-weight = MarkWeight(buf_marking.mark).
          assign
            tt-tobacco-marks.is-weight = yes
            tt-tobacco-marks.weight = v-mark-weight
          .
        end .
      end .
    end .
    find first tt-marks no-error.
    if not available tt-marks then v-mark-alchol = false .
    v-alc-qnty = 0 .
    for each tt-alc-codes exclusive-lock :
        v-alc-qnty = v-alc-qnty + tt-alc-codes.qnty .
    end.
    if p-chg-qnty < v-alc-qnty and p-chg-qnty > 0
    then
    for each  buf2_parts no-lock
        where buf2_parts.obj-type  = buf_doc-line.obj-type
          and buf2_parts.obj-code  = buf_doc-line.obj-code
          and buf2_parts.artic     = buf_doc-line.artic
          and buf2_parts.prod-type = buf_doc-line.prod-type
          and buf2_parts.prod-code = buf_doc-line.prod-code
          and buf2_parts.out-code  = buf_doc-line.doc-code
          and buf2_parts.status_   = no
          and buf2_parts.fact-qnty > 0
    use-index FIFO :
        if num-entries(buf2_parts.alc-ref-ab-path) = 4
        and entry(3, buf2_parts.alc-ref-ab-path) <> ""
        then do :
            find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code = entry(3, buf2_parts.alc-ref-ab-path) no-error.
            if not available tt-alc-codes
            then do :
              find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code <> "new-mark" no-error.
              if not available tt-alc-codes
              then do :
                find first tt-alc-codes exclusive-lock .
              end.
            end.
            tt-alc-codes.qnty = tt-alc-codes.qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            v-alc-qnty = v-alc-qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            if tt-alc-codes.qnty = 0
            then do :
                delete tt-alc-codes .
                if p-chg-qnty < v-alc-qnty
                then do :
                    find next tt-alc-codes exclusive-lock no-error.
                    if not available tt-alc-codes then find first tt-alc-codes exclusive-lock .
                    tt-alc-codes.qnty = tt-alc-codes.qnty - (v-alc-qnty - p-chg-qnty) .
                    v-alc-qnty = p-chg-qnty .
                    leave .
                end.
            end.
        end.
        else do :
            find first tt-alc-codes exclusive-lock .
            tt-alc-codes.qnty = tt-alc-codes.qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            v-alc-qnty = v-alc-qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            if tt-alc-codes.qnty = 0
            then do :
                delete tt-alc-codes .
                if p-chg-qnty < v-alc-qnty
                then do :
                    find next tt-alc-codes exclusive-lock no-error.
                    if not available tt-alc-codes then find first tt-alc-codes exclusive-lock .
                    tt-alc-codes.qnty = tt-alc-codes.qnty - (v-alc-qnty - p-chg-qnty) .
                    v-alc-qnty = p-chg-qnty .
                    leave .
                end.
            end.
        end.
    end.
    find first tt-tobacco-marks no-error.
    if not available tt-tobacco-marks
    then v-mark-tobacco = false .
    else v-mark-tobacco = true .
    assign
      v-chg-qnty-sign = 0
    .
    if p-chg-qnty > 0
    then do:
      assign
        v-chg-qnty-sign = 1
      .
    end.
    if p-chg-qnty < 0
    then do:
      assign
        v-chg-qnty-sign = - 1
      .
    end.
    if  buf_trn-doc.ext-doc-type <> 'vp':U
    and buf_trn-doc.ext-doc-type <> 'ap':U
    and buf_trn-doc.ext-doc-type <> 'mp':U
    then do:
      run unrsrv-negative in this-procedure
        (buffer buf_doc-line
        ,input  p-chg-qnty
        ,output v-real-chg-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры unrsrv-negative" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    assign
      p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
      p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
    .
    if p-chg-qnty = 0
    then do:
      return .
    end.
    define variable v-fifo as logical   no-undo .
    define variable v-alc-rsrv  as logical   no-undo .
    if p-unreserv-other-sign
    then do:
      if buf_trn-doc.doc-type = 'рас':U
      or buf_trn-doc.doc-type = 'спи':U
      then do:
        assign
          v-fifo = true
        .
      end.
      else do:
        assign
          v-fifo = false
        .
      end.
      if v-fifo
      then do:
        find first buf_parts
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
            and buf_parts.in-code   <> buf_parts.out-code
            and buf_parts.qnty * p-chg-qnty < 0
          use-index FIFO
          no-error.
      end.
      else do:
        find last buf_parts
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
            and buf_parts.in-code   <> buf_parts.out-code
            and buf_parts.qnty * p-chg-qnty < 0
          use-index FIFO
          no-error.
      end.
      if p-mark <> "" and buf_trn-doc.ext-doc-type = 'vt':U
      then do:
        find first buf_marking no-lock where buf_marking.mark begins p-mark no-error .
        if not available buf_marking
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . В БД не найдена запись для марки " p-mark  skip .
          undo, return error ("В БД не найдена запись для марки " + p-mark) .
        end .
        if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . Марка " p-mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
          undo, return error ("Марка " + p-mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .
        end .
        find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark
                                               and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                               and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                               and buf_marking-lines.in-code <> buf_marking-lines.out-code
                                               no-error .
        if not available buf_marking-lines
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . В БД не найдена запись для марки в линии документа " p-mark  skip .
          undo, return error ("В БД не найдена запись для марки в линии документа " + p-mark) .
        end.
        find first buf_goods no-lock where buf_goods.gds-code = buf_marking-lines.gds-code .
        find first buf_parts
          where buf_parts.obj-type  = buf_marking-lines.obj-type
            and buf_parts.obj-code  = buf_marking-lines.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
            and buf_parts.in-code   = buf_marking-lines.in-code
            and buf_parts.out-code  = buf_marking-lines.out-code
            and buf_parts.part-code = buf_marking-lines.part-code
          use-index FIFO
          no-error.
        if available buf_parts
        then v-fifo = false .
        else v-fifo = true .
      end.
      do while p-chg-qnty <> 0
      and available buf_parts
      :
        assign
          v-check-part-qnty = p-chg-qnty
                            * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                                then -1
                                else 1
                              )
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run part-prc in g#library
  (buffer buf_parts
  ,buffer buf_trn-doc
  ,input  p-reserv-single-part
  ,input  p-in-code
  ,input  p-part-code
  ,input  p-pl-code
  ,input  p-goods-twounit
  ,input  p-purch-code-list
  ,input  v-check-part-qnty
  ,input  true
  ,output v-reason
  ,output v-process-part
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении возможности резервирования партии" skip
            "Документ" buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if v-process-part = true
        then do:
          run partrsrv in this-procedure
            (input  p-chg-qnty
                    * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                        then -1
                        else 1
                      )
            ,input  p-goods-serial
            ,input  p-goods-twounit
            ,input  true
            ,buffer buf_parts
            ,buffer buf_trn-doc
            ,output v-real-chg-qnty
            ,output v-parts-recid
            ,input  p-mark
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове partrsrv" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return return-value .
          end.
          assign
            p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
            p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
          .
        end.
        if v-fifo
        then do:
          find next buf_parts
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.in-code   <> buf_parts.out-code
              and buf_parts.qnty * p-chg-qnty < 0
            use-index FIFO
            no-error.
        end.
        else do:
          find prev buf_parts
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.in-code   <> buf_parts.out-code
              and buf_parts.qnty * p-chg-qnty < 0
            use-index FIFO
            no-error.
        end.
      end.
    end.
    if  buf_trn-doc.discnt-type = 'касс':U
    and p-goods-serial = true
    then do:
      if p-reserv-single-part = false
      then do:
        return .
      end.
    end.
    define variable v-partlist-use    as logical   no-undo .
    define variable v-partlist-order  as character no-undo .
    run partlist_use-get in this-procedure
      (output v-partlist-use
      ) .
    if p-chg-qnty < 0
    then do:
      if buf_trn-doc.doc-type = 'инв':U
      then do:
        assign
          v-rsrv-code = 'free-zone':U
        .
        assign
          v-fifo = true
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order  = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order  = 'parts':u
          .
        end.
      end.
      else do:
        assign
          v-rsrv-code = buf_doc-line.doc-code
        .
        if buf_trn-doc.doc-type = 'рас':U
        or buf_trn-doc.doc-type = 'спи':U
        then do:
          find first tt-alc-codes no-error.
          if available tt-alc-codes
          then do :
            v-alc-rsrv = true .
          end.
          else do :
             v-alc-rsrv = false .
          end.
          assign
            v-fifo = false
          .
          if v-partlist-use = true
          then do:
            assign
              v-partlist-order  = 'parts,partlist-decrement':u
            .
          end.
          else do:
            assign
              v-partlist-order  = 'parts':u
            .
          end.
        end.
        else do:
          assign
            v-fifo = true
          .
          if v-partlist-use = true
          then do:
            assign
              v-partlist-order  = 'parts,partlist-decrement':u
            .
          end.
          else do:
            assign
              v-partlist-order  = 'parts':u
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-rsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and 0 < 0)
      then 'free-zone':U
      else 'out-zone':U )
      .
      if v-rsrv-code = 'free-zone':U
      then do:
        find first tt-alc-codes no-error.
        if available tt-alc-codes
        then do :
          v-alc-rsrv = true .
        end.
        else do :
           v-alc-rsrv = false .
        end.
        assign
          v-fifo = true
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order = 'parts':u
          .
        end.
      end.
      else do:
        assign
          v-fifo = false
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order = 'parts':u
          .
        end.
      end.
    end.
    if  v-partlist-use = false
    and v-partlist-order <> 'parts':u
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка резервирования" skip
        view-as alert-box error .
    end.
    define variable v-find-first         as logical   no-undo .
    define variable v-rsrv-index         as integer   no-undo .
    define variable v-rsrv-entry         as character no-undo .
    define variable v-iteration-chg-qnty as decimal   no-undo .
    define variable v-part-index         as integer   no-undo .
    define variable v-max-part-index     as integer   no-undo .
    define variable v-partlist-in-code   as character no-undo .
    define variable v-partlist-part-code as character no-undo .
    define variable v-partlist-rsrv-qnty as decimal   no-undo .
    define variable v-msg                as character no-undo .
    assign
      v-find-first = true
      v-rsrv-index = 1
      v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, chr(44))
    .
    output stream alc-rsrv to value ("alc-rsrv.log") .
    rsrv_cycle:
    do while p-chg-qnty <> 0
    :
      assign
        v-iteration-chg-qnty = 0
      .
      case v-rsrv-entry :
        when 'parts':u
        then do:
          assign
            v-iteration-chg-qnty = p-chg-qnty
          .
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            if p-mark <> ""
            or v-mark-alchol
            then do :
              find first tt-marks no-error .
              assign
                v-iteration-chg-qnty = v-chg-qnty-sign
              .
              find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                                and buf_gen-attr.attr-code = (if available tt-marks then tt-marks.mark else p-mark)
                                                and num-entries(buf_gen-attr.p-key, chr(3)) >= 8
                                                and entry(8, buf_gen-attr.p-key, chr(3)) = v-rsrv-code
                                                and entry(2, buf_gen-attr.p-key, chr(3)) = buf_doc-line.obj-type
                                                and integer(entry(3, buf_gen-attr.p-key, chr(3))) = buf_doc-line.obj-code
                                                no-error .
              if available buf_gen-attr
              then do :
                  if not
                    (
                        entry(4, buf_gen-attr.p-key, chr(3)) = buf_doc-line.artic
                    and entry(5, buf_gen-attr.p-key, chr(3)) = buf_doc-line.prod-type
                    and entry(6, buf_gen-attr.p-key, chr(3)) = string (buf_doc-line.prod-code)
                    )
                  then do:
                    v-msg = "Артикул товара в чеке " + buf_doc-line.artic + " " + buf_doc-line.prod-type + string(buf_doc-line.prod-code)
                      + substitute ("  не сооотвествует артиклу &1 &2&3 с маркой в свободной зоне "
                      , entry(4, buf_gen-attr.p-key, chr(3))
                      , entry(5, buf_gen-attr.p-key, chr(3))
                      , entry(6, buf_gen-attr.p-key, chr(3))) + tt-marks.mark.
                    put stream alc-rsrv unformatted v-msg skip .
                    message
                      vss-workfile vss-revision vss-description skip
                      v-msg skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                  find first  buf_parts
                        where buf_parts.obj-type  = entry(2, buf_gen-attr.p-key, chr(3))
                          and buf_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, chr(3)))
                          and buf_parts.artic     = entry(4, buf_gen-attr.p-key, chr(3))
                          and buf_parts.prod-type = entry(5, buf_gen-attr.p-key, chr(3))
                          and buf_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, chr(3)))
                          and buf_parts.in-code   = entry(7, buf_gen-attr.p-key, chr(3))
                          and (
                           (buf_parts.out-code  = entry(8, buf_gen-attr.p-key, chr(3))and available tt-marks)
                            or p-mark <> ""
                               )
                          and buf_parts.part-code = entry(9, buf_gen-attr.p-key, chr(3))
                          and buf_parts.status_   = no
                          and buf_parts.fact-qnty > 0
                        use-index FIFO
                        no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else v-fifo = true .
              end.
              if not available buf_gen-attr
              or (available buf_gen-attr and not available buf_parts)
              then do :
                  if not available buf_gen-attr
                  then do :
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                  end.
                  else do :
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                  end.
                  if available tt-marks
                  then run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
                  else run ProcAlcCode (input p-mark, output v-alc-code) no-error.
                  if v-alc-code <> "" and v-alc-code <> ?
                  then
                  find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = v-alc-code
                    use-index FIFO
                    no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else do :
                    v-fifo = true .
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                  end.
              end.
            end.
            else
            if v-alc-rsrv
            then do :
              find first tt-alc-codes .
              assign
                v-iteration-chg-qnty = tt-alc-codes.qnty
              .
              find first buf_parts
                where buf_parts.obj-type  = buf_doc-line.obj-type
                  and buf_parts.obj-code  = buf_doc-line.obj-code
                  and buf_parts.artic     = buf_doc-line.artic
                  and buf_parts.prod-type = buf_doc-line.prod-type
                  and buf_parts.prod-code = buf_doc-line.prod-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.status_   = no
                  and buf_parts.fact-qnty > 0
                  and num-entries(buf_parts.alc-ref-ab-path) = 4
                  and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                use-index FIFO
                no-error.
              if available buf_parts
              then v-fifo = false .
              else v-fifo = true .
            end.
            if v-mark-tobacco
            then do :
              find first tt-tobacco-marks use-index un no-error .
              if tt-tobacco-marks.unit = "UNIT"
              then do :
                assign
                  v-iteration-chg-qnty = v-chg-qnty-sign
                .
              end .
              else
              if tt-tobacco-marks.unit = "LEVEL1"
              then do :
                assign
                  v-GTIN = getGtinByDM(tt-tobacco-marks.mark)
                  v-GTIN-qnty = getQntyCodeByGtin(v-GTIN)
                  v-iteration-chg-qnty = v-chg-qnty-sign * v-GTIN-qnty
                .
              end .
              if tt-tobacco-marks.is-weight
              then do :
                assign
                  v-iteration-chg-qnty = v-chg-qnty-sign * tt-tobacco-marks.weight
                .
              end .
              find first buf_marking no-lock where buf_marking.mark begins tt-tobacco-marks.mark no-error .
              if not available buf_marking
              then do :
                put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки " tt-tobacco-marks.mark  skip .
                undo, return error ("В БД не найдена запись для марки " + tt-tobacco-marks.mark) .
              end .
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
              then do :
                put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . Марка " tt-tobacco-marks.mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
                undo, return error ("Марка " + tt-tobacco-marks.mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .
              end .
              find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and can-find(first buf_marking-lines where
                                    buf_marking-lines.mark      = tt-tobacco-marks.mark
                                and buf_marking-lines.in-code   = buf_parts.in-code
                                and buf_marking-lines.out-code  = buf_parts.out-code
                                and buf_marking-lines.prt-code  = buf_parts.prt-code
                                and buf_marking-lines.part-code = buf_parts.part-code
                                and buf_marking-lines.obj-code  = buf_parts.obj-code
                                and buf_marking-lines.obj-type  = buf_parts.obj-type)
  use-index FIFO
  no-error.
              if available buf_parts
                then v-fifo = false .
                else v-fifo = true .
            end .
            if v-fifo = true
            then do:
              release buf_parts.
              if vIsExemplarGoods or v-isweighed then
                find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and not can-find(first buf_marking-lines where
                                          buf_marking-lines.in-code   = buf_parts.in-code
                                      and buf_marking-lines.out-code  = buf_parts.out-code
                                      and buf_marking-lines.prt-code  = buf_parts.prt-code
                                      and buf_marking-lines.part-code = buf_parts.part-code
                                      and buf_marking-lines.obj-code  = buf_parts.obj-code
                                      and buf_marking-lines.obj-type  = buf_parts.obj-type )
  use-index FIFO
  no-error.
              if not avail buf_parts then
                 find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
            end.
            else if not v-alc-rsrv and not v-mark-tobacco
            then do:
              if p-mark = "" and not (v-izlcstpr and buf_trn-doc.ext-doc-type = 'vt':U) or (v-izlcstpr and p-action = 'reserv-create':U) then
              do:
                release buf_parts.
                if vIsExemplarGoods or v-isweighed then
                  find last buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)
  use-index FIFO
  no-error.
                if not avail buf_parts then
                   find last buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
              end.
            end.
          end.
          else do:
            if p-mark <> ""
            or v-mark-alchol
            then do :
                find next tt-marks no-error .
                if available tt-marks
                or p-mark <> ""
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign
                  .
                  find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                                    and buf_gen-attr.attr-code = (if available tt-marks then tt-marks.mark else p-mark)
                                                    and num-entries(buf_gen-attr.p-key, chr(3)) >= 8
                                                    and entry(8, buf_gen-attr.p-key, chr(3)) = v-rsrv-code
                                                    and entry(2, buf_gen-attr.p-key, chr(3)) = buf_doc-line.obj-type
                                                    and integer(entry(3, buf_gen-attr.p-key, chr(3))) = buf_doc-line.obj-code
                                                    no-error .
                  if available buf_gen-attr
                  then do :
                      if not
                        (
                            entry(4, buf_gen-attr.p-key, chr(3)) = buf_doc-line.artic
                        and entry(5, buf_gen-attr.p-key, chr(3)) = buf_doc-line.prod-type
                        and entry(6, buf_gen-attr.p-key, chr(3)) = string (buf_doc-line.prod-code)
                        )
                      then do:
                        put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                          substitute ("  не сооотвествует артиклу &1 &2&3 с маркой в свободной зоне "
                          , entry(4, buf_gen-attr.p-key, chr(3)) = buf_doc-line.artic
                          , entry(5, buf_gen-attr.p-key, chr(3)) = buf_doc-line.artic
                          , entry(6, buf_gen-attr.p-key, chr(3)) = buf_doc-line.artic) tt-marks.mark  skip .
                        next rsrv_cycle .
                      end.
                      find first  buf_parts
                            where buf_parts.obj-type  = entry(2, buf_gen-attr.p-key, chr(3))
                              and buf_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, chr(3)))
                              and buf_parts.artic     = entry(4, buf_gen-attr.p-key, chr(3))
                              and buf_parts.prod-type = entry(5, buf_gen-attr.p-key, chr(3))
                              and buf_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, chr(3)))
                              and buf_parts.in-code   = entry(7, buf_gen-attr.p-key, chr(3))
                              and buf_parts.out-code  = entry(8, buf_gen-attr.p-key, chr(3))
                              and buf_parts.part-code = entry(9, buf_gen-attr.p-key, chr(3))
                              and buf_parts.status_   = no
                              and buf_parts.fact-qnty > 0
                            use-index FIFO
                            no-error.
                      if available buf_parts
                      then v-fifo = false .
                      else v-fifo = true .
                  end.
                  if not available buf_gen-attr
                  or (available buf_gen-attr and not available buf_parts)
                  then do :
                      if not available buf_gen-attr
                          then do :
                            if available tt-marks
                            then
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " tt-marks.mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                            else
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " p-mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                          end.
                          else do :
                            if available tt-marks
                            then
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " tt-marks.mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                            else
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " p-mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                          end.
                          if available tt-marks
                          then run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
                          else run ProcAlcCode (input p-mark, output v-alc-code) no-error.
                      if v-alc-code <> "" and v-alc-code <> ?
                      then
                      find first buf_parts
                        where buf_parts.obj-type  = buf_doc-line.obj-type
                          and buf_parts.obj-code  = buf_doc-line.obj-code
                          and buf_parts.artic     = buf_doc-line.artic
                          and buf_parts.prod-type = buf_doc-line.prod-type
                          and buf_parts.prod-code = buf_doc-line.prod-code
                          and buf_parts.out-code  = v-rsrv-code
                          and buf_parts.status_   = no
                          and buf_parts.fact-qnty > 0
                          and num-entries(buf_parts.alc-ref-ab-path) = 4
                          and entry(3, buf_parts.alc-ref-ab-path) = v-alc-code
                        use-index FIFO
                        no-error.
                      if available buf_parts
                      then v-fifo = false .
                      else do :
                        v-fifo = true .
                        if available tt-marks
                            then
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " tt-marks.mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                            else
                              put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                                "  марка " p-mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                      end.
                  end.
                end.
                else do :
                    v-fifo = true .
                end.
            end.
            else
            if v-alc-rsrv
            then do :
              if p-real-chg-qnty = tt-alc-codes.qnty
              then do :
                  find next tt-alc-codes no-error.
                  if available tt-alc-codes
                  then do :
                    assign
                      v-iteration-chg-qnty = tt-alc-codes.qnty
                    .
                    find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                    use-index FIFO
                    no-error.
                    if available buf_parts
                    then v-fifo = false .
                    else v-fifo = true .
                  end.
                  else do :
                    v-fifo = true .
                  end.
              end.
              else do :
                  find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                    use-index FIFO
                    no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else v-fifo = true .
              end.
            end.
            if v-mark-tobacco
            then do :
              find next tt-tobacco-marks use-index un no-error .
              if available tt-tobacco-marks
              then do :
                if tt-tobacco-marks.unit = "UNIT"
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign
                  .
                end .
                else
                if tt-tobacco-marks.unit = "LEVEL1"
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign * 10
                  .
                end .
                find first buf_marking no-lock where buf_marking.mark begins tt-tobacco-marks.mark no-error .
                if not available buf_marking
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки " tt-tobacco-marks.mark  skip .
                  undo, return error ("В БД не найдена запись для марки " + tt-tobacco-marks.mark) .
                end .
                if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                          " . Марка " tt-tobacco-marks.mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
                  undo, return error ("Марка " + tt-tobacco-marks.mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .
                end .
                find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark
                                                       and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                                       and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                                       and buf_marking-lines.out-code = v-rsrv-code
                                                       no-error .
                if not available buf_marking-lines
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки в линии документа " tt-tobacco-marks.mark  skip .
                  undo, return error ("В БД не найдена запись для марки в линии документа " + tt-tobacco-marks.mark) .
                end.
                find first buf_goods no-lock where buf_goods.gds-code = buf_marking-lines.gds-code .
                find first buf_parts
                  where buf_parts.obj-type  = buf_marking-lines.obj-type
                    and buf_parts.obj-code  = buf_marking-lines.obj-code
                    and buf_parts.artic     = buf_goods.artic
                    and buf_parts.prod-type = buf_goods.prod-type
                    and buf_parts.prod-code = buf_goods.prod-code
                    and buf_parts.in-code   = buf_marking-lines.in-code
                    and buf_parts.out-code  = buf_marking-lines.out-code
                    and buf_parts.part-code = buf_marking-lines.part-code
                    and buf_parts.prt-code  = buf_marking-lines.prt-code
                    and buf_parts.status_   = no
                    and buf_parts.fact-qnty > 0
                  use-index FIFO
                  no-error.
                if available buf_parts
                then v-fifo = false .
                else v-fifo = true .
              end .
              else do :
                v-fifo = true .
              end .
            end .
            if v-fifo = true
            then do:
              if v-alc-rsrv
              or v-mark-tobacco
              then
              do:
                release buf_parts.
                if vIsExemplarGoods or v-isweighed then
                  find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)
  use-index FIFO
  no-error.
                if not avail buf_parts then
                   find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
              end.
              else
              do:
                if vIsExemplarGoods or v-isweighed then
                do:
                  release buf_parts.
                  find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)
  use-index FIFO
  no-error.
                  if not avail buf_parts then
                     find first buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
                end.
                else
                do:
                  find next buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
                end.
              end.
            end.
            else if not v-alc-rsrv and not v-mark-tobacco
            then do:
              if vIsExemplarGoods or v-isweighed then
              do:
                release buf_parts.
                find last buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
    and not can-find(first buf_marking-lines where
                                          buf_marking-lines.in-code   = buf_parts.in-code
                                      and buf_marking-lines.out-code  = buf_parts.out-code
                                      and buf_marking-lines.prt-code  = buf_parts.prt-code
                                      and buf_marking-lines.part-code = buf_parts.part-code
                                      and buf_marking-lines.obj-code  = buf_parts.obj-code
                                      and buf_marking-lines.obj-type  = buf_parts.obj-type)
  use-index FIFO
  no-error.
                if not avail buf_parts then
                  find last buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
              end.
              else
              do:
                find prev buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U)
                                then p-chg-qnty else 0)
  use-index FIFO
  no-error.
              end.
            end.
          end.
          if not available buf_parts
          then do:
            if (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'we':U) then
            do:
              message "Просканирована групповая упаковка, не найдено партий для списания.~nНеобходимо сканировать потребительские упаковки"
                view-as alert-box.
              leave rsrv_cycle .
            end.
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, chr(44))
              .
              next rsrv_cycle .
            end.
            else do:
              leave rsrv_cycle .
            end.
          end.
          if v-partlist-use = true
          then do:
            define variable v-parts-rsrv-qnty  as decimal   no-undo .
            define variable v-parts-check-qnty as decimal   no-undo .
            run partlist_check-part-qnty in this-procedure
              (input  buf_parts.in-code
              ,input  buf_parts.part-code
              ,output v-parts-check-qnty
              ) .
            if v-parts-check-qnty > 0
            then do:
              assign
                v-parts-rsrv-qnty = 0
              .
              if buf_parts.out-code = buf_doc-line.doc-code
              then do:
                assign
                  v-parts-rsrv-qnty = buf_parts.qnty
                .
              end.
              else do:
                define buffer buf_rsrv_parts for ub.parts .
                find first buf_rsrv_parts
                  where buf_rsrv_parts.obj-type  = buf_doc-line.obj-type
                    and buf_rsrv_parts.obj-code  = buf_doc-line.obj-code
                    and buf_rsrv_parts.artic     = buf_doc-line.artic
                    and buf_rsrv_parts.prod-type = buf_doc-line.prod-type
                    and buf_rsrv_parts.prod-code = buf_doc-line.prod-code
                    and buf_rsrv_parts.in-code   = buf_parts.in-code
                    and buf_rsrv_parts.out-code  = buf_doc-line.doc-code
                    and buf_rsrv_parts.part-code = buf_parts.part-code
                  no-error .
                if available buf_rsrv_parts
                then do:
                  assign
                    v-parts-rsrv-qnty = buf_rsrv_parts.qnty
                  .
                end.
                if v-parts-rsrv-qnty > v-parts-check-qnty
                then do:
                  assign
                    v-iteration-chg-qnty = min(v-parts-rsrv-qnty - v-parts-check-qnty
                                              ,abs(v-iteration-chg-qnty)
                                              )
                                         * (if v-iteration-chg-qnty > 0
                                            then 1
                                            else -1
                                           )
                  .
                end.
                else do:
                  assign
                    v-iteration-chg-qnty = 0
                  .
                end.
              end.
            end.
          end.
        end.
        when 'partlist-increment':u
        then do:
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            run partlist_get-total-num in this-procedure
              (output v-max-part-index
              ) .
            assign
              v-part-index = 1
            .
          end.
          else do:
            assign
              v-part-index = v-part-index + 1
            .
          end.
          if v-part-index <= v-max-part-index
          then do:
            run partlist_get-part-qnty in this-procedure
              (input  v-part-index
              ,output v-partlist-in-code
              ,output v-partlist-part-code
              ,output v-partlist-rsrv-qnty
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при получении необходимых количеств для резервирования" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            find first buf_parts
              where buf_parts.obj-type  = buf_doc-line.obj-type
                and buf_parts.obj-code  = buf_doc-line.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
                and buf_parts.out-code  = v-rsrv-code
                and buf_parts.in-code   = v-partlist-in-code
                and buf_parts.part-code = v-partlist-part-code
                and buf_parts.status_   = no
                and buf_parts.fact-qnty > 0
              no-error .
            if not available buf_parts
            then do:
              next rsrv_cycle .
            end.
            assign
              v-iteration-chg-qnty = min(abs(p-chg-qnty)
                                        ,abs(v-partlist-rsrv-qnty)
                                        )
                                   * (if p-chg-qnty > 0 then 1 else -1)
            .
          end.
          else do:
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, chr(44))
              .
              next rsrv_cycle .
            end.
            else do:
              leave rsrv_cycle .
            end.
          end.
        end.
        when 'partlist-decrement':u
        then do:
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            run partlist_get-total-num in this-procedure
              (output v-max-part-index
              ) .
            assign
              v-part-index = v-max-part-index
            .
          end.
          else do:
            assign
              v-part-index = v-part-index - 1
            .
          end.
          if v-part-index >= 1
          then do:
            run partlist_get-part-qnty in this-procedure
              (input  v-part-index
              ,output v-partlist-in-code
              ,output v-partlist-part-code
              ,output v-partlist-rsrv-qnty
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при получении необходимых количеств для резервирования" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            find first buf_parts
              where buf_parts.obj-type  = buf_doc-line.obj-type
                and buf_parts.obj-code  = buf_doc-line.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
                and buf_parts.out-code  = v-rsrv-code
                and buf_parts.in-code   = v-partlist-in-code
                and buf_parts.part-code = v-partlist-part-code
                and buf_parts.status_   = no
                and buf_parts.fact-qnty > 0
              no-error .
            if not available buf_parts
            then do:
              next rsrv_cycle .
            end.
            assign
              v-iteration-chg-qnty = min(abs(p-chg-qnty)
                                        ,abs(v-partlist-rsrv-qnty)
                                        )
                                   * (if p-chg-qnty > 0 then 1 else -1)
            .
          end.
          else do:
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, chr(44))
              .
              next rsrv_cycle .
            end.
            else do:
              leave rsrv_cycle .
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной" v-rsrv-entry skip
            view-as alert-box error .
        end.
      end.
      assign
        v-check-part-qnty = p-chg-qnty
                          * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                              then -1
                              else 1
                            )
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run part-prc in g#library
  (buffer buf_parts
  ,buffer buf_trn-doc
  ,input  p-reserv-single-part
  ,input  p-in-code
  ,input  p-part-code
  ,input  p-pl-code
  ,input  p-goods-twounit
  ,input  p-purch-code-list
  ,input  v-check-part-qnty
  ,input  true
  ,output v-reason
  ,output v-process-part
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении возможности резервирования партии" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-process-part = true
      then do:
        run partrsrv in this-procedure
          (input  v-iteration-chg-qnty
                    * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                        then -1
                        else 1
                      )
          ,input  p-goods-serial
          ,input  p-goods-twounit
          ,input  false
          ,buffer buf_parts
          ,buffer buf_trn-doc
          ,output v-real-chg-qnty
          ,output v-parts-recid
          ,input (if available tt-marks then tt-marks.mark else if available buf_marking then buf_marking.mark else if available tt-tobacco-marks then tt-tobacco-marks.mark else p-mark)
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове partrsrv" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return return-value .
        end.
        assign
          p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
          p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
        .
      end.
    end.
    output stream alc-rsrv close .
    output stream tobacco-rsrv close .
    if p-chg-qnty = 0
    then do:
      return .
    end.
    if v-chg-qnty-sign < 0
    then do:
      if p-chg-qnty <> 0
      then do:
      end.
    end.
    if  p-chg-qnty <> 0
    and p-reserv-single-part = false
    and p-purch-code-list    = '':u
    then do:
      if v-izlcstpr and buf_trn-doc.ext-doc-type = 'vt':U and p-action <> 'reserv-create':U
      then do :
          p-partscr-prompt-price  = p-partscr-prompt-price + ",izlcstpr=enable" .
          find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                         and buf_goods.prod-type  = buf_doc-line.prod-type
                                         and buf_goods.prod-code  = buf_doc-line.prod-code .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  varb-code
  ,input  0
  ,input  0
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
          if varprice-sale = ?
          then do:
              assign
                varprice-sale = 0
                varcur-vat-pc = 0
                varcur-slt-pc = 0
              .
          end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  buf_trn-doc.doc-date
  ,input  buf_trn-doc.host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
          varprice-rubl = varprice-sale / (1 + (varcur-vat-pc / 100)) .
          if varprice-rubl = 0
          then do :
            if varcur-vat-pc <> 0 and varcur-vat-pc <> ?
            then
              varprice-rubl = buf_doc-line.price-rubl / (1 + (varcur-vat-pc / 100)) .
            else
              varprice-rubl = buf_doc-line.price-rubl / (1 + (buf_doc-line.vat-pc / 100)) .
          end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  buf_trn-doc.host-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ) no-error .
          varprice-base = varprice-rubl / v-exch-rate * v-exch-scale .
          if varprice-rubl <> 0 and varprice-rubl <> ? then p-reserv-rubl = varprice-rubl .
          if varprice-base <> 0 and varprice-base <> ? then p-reserv-base = varprice-base .
      end.
      run rsrv-negative in this-procedure
        (input  parparentproc
        ,input  p-db-num
        ,input  p-user-id
        ,buffer buf_doc-line
        ,buffer buf_trn-doc
        ,input  p-chg-qnty
        ,input  p-reserv-base
        ,input  p-reserv-rubl
        ,input  p-partscr-prompt-price
        ,output v-real-chg-qnty
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> '':U
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры rsrv-negative" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
        p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
      .
      if  v-real-chg-qnty <> p-chg-qnty
      and return-value <> '':U
      then do:
        return return-value .
      end.
    end.
  end.
  return .
end procedure.
procedure rsrv-negative :
  define input parameter  parparentproc         AS WIDGET-HANDLE NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define parameter buffer buf_doc-line           for ub.doc-line .
  define parameter buffer buf_trn-doc            for ub.trn-doc  .
  define input parameter  p-chg-qnty             as decimal   no-undo .
  define input parameter  p-reserv-base          as decimal   no-undo .
  define input parameter  p-reserv-rubl          as decimal   no-undo .
  define input parameter  p-partscr-prompt-price as character no-undo .
  define output parameter p-real-rsrv-qnty       as decimal   no-undo .
  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .
  define variable v-vat-type  as character no-undo .
  define variable v-vat-pc    as decimal   no-undo .
  define variable v-slt-type  as character no-undo .
  define variable v-slt-pc    as decimal   no-undo .
  define variable v-is-hold-doc as logical no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                   and buf_goods.prod-type  = buf_doc-line.prod-type
                                   and buf_goods.prod-code  = buf_doc-line.prod-code
                                   .
    if is-gas(buf_goods.gds-code) then return .
    run partscr_get-default-values in this-procedure
      (buffer buf_doc-line
      ,output v-vat-type
      ,output v-vat-pc
      ,output v-slt-type
      ,output v-slt-pc
      ) .
    if lookup('izlcstpr=enable':u, p-partscr-prompt-price) > 0 and p-action <> 'reserv-create':U
    and buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        v-vat-pc = 0 .
        v-vat-type = 'без':U .
    end.
    run partscr in this-procedure
      (input  parparentproc
      ,input  p-db-num
      ,input  p-user-id
      ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
      ,input
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
      ,input  '':U
      ,input  '':U
      ,input  '':U
      ,input  '':U
      ,input  p-reserv-base
      ,input  p-reserv-rubl
      ,input  v-vat-type
      ,input  v-vat-pc
      ,input  v-slt-type
      ,input  v-slt-pc
      ,input  p-chg-qnty
      ,input  p-partscr-prompt-price
      ,input  0
      ,input  ?
      ,input  ?
      ,input  0
      ,buffer buf_doc-line
      ,buffer buf_parts
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании партии" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    if not available buf_parts
    and return-value <> '':U
    then do:
      return return-value .
    end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold-doc
  )  .
    if v-is-hold-doc
    and buf_trn-doc.ext-doc-type = 'ee':U
    then do:
      assign
        buf_parts.contract-code = 0
      .
    end.
    assign
      p-real-rsrv-qnty = p-chg-qnty
    .
  end.
end procedure.
procedure unrsrv-negative :
  define parameter buffer buf_doc-line for ub.doc-line .
  define input  parameter p-chg-qnty      as decimal no-undo .
  define output parameter p-real-chg-qnty as decimal no-undo .
  define variable v-part-chg-qnty as decimal no-undo .
  define buffer buf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    for each buf_parts
      where buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      assign
        v-part-chg-qnty = 0
      .
      if buf_parts.fact-qnty > 0
      and p-chg-qnty < 0
      then do:
        assign
          v-part-chg-qnty = - min(abs(buf_parts.qnty), abs(p-chg-qnty))
        .
      end.
      if buf_parts.fact-qnty < 0
      and p-chg-qnty > 0
      then do:
        assign
          v-part-chg-qnty = min(abs(buf_parts.qnty), abs(p-chg-qnty))
        .
      end.
      if v-part-chg-qnty = 0
      then do:
        next .
      end.
      if p-chg-qnty = 0
      then do:
        return .
      end.
      assign
        p-chg-qnty          = p-chg-qnty          - v-part-chg-qnty
        p-real-chg-qnty     = p-real-chg-qnty     + v-part-chg-qnty
        buf_parts.qnty      = buf_parts.qnty      + v-part-chg-qnty
        buf_parts.fact-qnty = buf_parts.fact-qnty + v-part-chg-qnty
      .
    end.
  end.
end procedure.
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define variable v-kol              as integer    no-undo .
  define variable alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .
  if length(p-mark-alc) = 150 then
  do:
    p-alc-code = "new-mark" .
    return .
  end.
  else
  do:
    alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  end.
  p-alc-code = string (Base2Int64 (alc-code, 36) ) no-error.
  if (Base2Int64 (alc-code, 36) ) < 0 then
  do:
    p-alc-code = ?.
  end.
  else
  do:
    if length(p-alc-code) < 20 then
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.
  end.
END PROCEDURE.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rsrvincr :
  define input  parameter parparentproc          AS WIDGET-HANDLE          NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define input  parameter p-trn-doc-recid        as recid                   no-undo .
  define input  parameter p-doc-line-recid       as recid                   no-undo .
  define input  parameter p-reserv-base          as decimal                 no-undo .
  define input  parameter p-reserv-rubl          as decimal                 no-undo .
  define input  parameter p-partscr-prompt-price as character               no-undo .
  define input  parameter p-extended-doc-type    as character               no-undo .
  define input  parameter p-reserv-single-part   as logical                 no-undo .
  define input  parameter p-in-code              like ub.parts.in-code      no-undo .
  define input  parameter p-part-code            like ub.parts.part-code    no-undo .
  define input  parameter p-reserv-pl-code       as logical                 no-undo .
  define input  parameter p-pl-code              as character               no-undo .
  define input  parameter p-goods-serial         as logical                 no-undo .
  define input  parameter p-goods-twounit        as logical                 no-undo .
  define output parameter p-abs-rsrv-qnty        as decimal                 no-undo .
  define variable vss-description as character no-undo init "rsrvincr: Процедура компенсации отрицательных партий".
  define buffer buf_trn-doc    for ub.trn-doc .
  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-abs-rsrv-qnty = 0
    .
    if p-reserv-pl-code = true
    then do:
      return .
    end.
    if p-goods-twounit = true
    then do:
      return .
    end.
    define variable v-total-rsrv-qnty as decimal no-undo .
    assign
      v-total-rsrv-qnty = 0
    .
    define variable v-neg-beg-date as date no-undo .
    define variable v-neg-end-date as date no-undo .
    assign
      v-neg-beg-date = ?
      v-neg-end-date = ?
    .
    define variable v-parameter-beg-name as character no-undo .
    define variable v-parameter-end-name as character no-undo .
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'rezerv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invngbeg'  then v-neg-beg-date = thbjattr_thbj-attr.property-value-date.
        if thbjattr_thbj-attr.prop-code = 'invngend'  then v-neg-end-date = thbjattr_thbj-attr.property-value-date.
    end.
    empty temp-table thbjattr_thbj-attr.
    assign
      v-parameter-beg-name = "invngbeg"
      v-parameter-end-name = "invngend"
    .
    if (v-neg-beg-date = ? ) <> (v-neg-end-date = ?)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивое задание параметров ограничения по резервированию порожденных партий" skip
        "Параметры" v-parameter-beg-name v-parameter-end-name skip
        "должны быть или одновременно заданы" skip
        "или одновременно не заданы" skip
        view-as alert-box error .
      undo, return error .
    end.
    if  v-neg-beg-date <> ?
    and v-neg-end-date <> ?
    and v-neg-beg-date > v-neg-end-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивое задание параметров ограничения по резервированию порожденных партий" skip
        "Первый день интервала резервирования(" v-parameter-beg-name ")" v-neg-beg-date skip
        "Последний день интервала резервирования(" v-parameter-end-name ")" v-neg-end-date skip
        "Дата" v-parameter-beg-name "должна быть меьшне равна даты" v-parameter-end-name skip
        view-as alert-box error .
      undo, return error .
    end.
    run rsrv-inv-create-supp in this-procedure
      (input        p-trn-doc-recid
      ,input        p-doc-line-recid
      ,input        p-goods-serial
      ,input        p-goods-twounit
      ,input        'out-zone':U
      ,input        v-neg-beg-date
      ,input        v-neg-end-date
      ,input-output v-total-rsrv-qnty
      ,input-output p-abs-rsrv-qnty
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры резервирования отрицательных партий расходной зоны" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run rsrv-inv-create-supp in this-procedure
      (input        p-trn-doc-recid
      ,input        p-doc-line-recid
      ,input        p-goods-serial
      ,input        p-goods-twounit
      ,input        'free-zone':U
      ,input        v-neg-beg-date
      ,input        v-neg-end-date
      ,input-output v-total-rsrv-qnty
      ,input-output p-abs-rsrv-qnty
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры резервирования отрицательных партий свободной зоны" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-total-rsrv-qnty <> 0
    then do:
      define variable v-real-chg-qnty as decimal   no-undo .
      run rsrv-doc in this-procedure
        (input  parparentproc
        ,input  p-db-num
        ,input  p-user-id
        ,input  p-trn-doc-recid
        ,input  p-doc-line-recid
        ,input  p-reserv-base
        ,input  p-reserv-rubl
        ,input  p-partscr-prompt-price
        ,input  p-extended-doc-type
        ,input  p-reserv-single-part
        ,input  p-in-code
        ,input  p-part-code
        ,input  p-reserv-pl-code
        ,input  p-pl-code
        ,input  p-goods-serial
        ,input  p-goods-twounit
        ,input  '':u
        ,input  - v-total-rsrv-qnty
        ,input  false
        ,output v-real-chg-qnty
        ) no-error .
      if error-status :error
      or v-real-chg-qnty <> - v-total-rsrv-qnty
      then do:
        undo, return error .
      end.
      assign
        p-abs-rsrv-qnty = p-abs-rsrv-qnty + abs(v-real-chg-qnty)
      .
    end.
    assign
      p-abs-rsrv-qnty = p-abs-rsrv-qnty / 2
    .
  end.
end procedure.
procedure rsrv-inv-create-supp :
  define input        parameter p-trn-doc-recid   as recid     no-undo .
  define input        parameter p-doc-line-recid  as recid     no-undo .
  define input        parameter p-goods-serial    as logical   no-undo .
  define input        parameter p-goods-twounit   as logical   no-undo .
  define input        parameter p-negative-code   as character no-undo .
  define input        parameter p-neg-beg-date    as date      no-undo .
  define input        parameter p-neg-end-date    as date      no-undo .
  define input-output parameter p-total-rsrv-qnty as decimal   no-undo .
  define input-output parameter p-abs-rsrv-qnty   as decimal   no-undo .
  define variable vss-description as character no-undo init "rsrv-inv-create-supp: компенсация партий свободной/расходной зоны".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer negative_parts for ub.parts .
  define buffer buf_parts      for ub.parts .
  define variable v-rsrv-qnty       as decimal   no-undo .
  define variable v-real-rsrv-qnty  as decimal   no-undo .
  define variable v-parts-recid     as decimal   no-undo .
  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Указатель" p-doc-line-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each negative_parts
      where negative_parts.obj-type  = buf_doc-line.obj-type
        and negative_parts.obj-code  = buf_doc-line.obj-code
        and negative_parts.artic     = buf_doc-line.artic
        and negative_parts.prod-type = buf_doc-line.prod-type
        and negative_parts.prod-code = buf_doc-line.prod-code
        and negative_parts.out-code  = p-negative-code
        and negative_parts.qnty      < 0
    on error undo, return error
    :
      if p-neg-beg-date <> ?
      then do:
        if negative_parts.fact-date < p-neg-beg-date
        or negative_parts.fact-date > p-neg-end-date
        then do:
          next .
        end.
      end.
      find buf_parts exclusive-lock
        where buf_parts.obj-type  = negative_parts.obj-type
          and buf_parts.obj-code  = negative_parts.obj-code
          and buf_parts.artic     = negative_parts.artic
          and buf_parts.prod-type = negative_parts.prod-type
          and buf_parts.prod-code = negative_parts.prod-code
          and buf_parts.in-code   = negative_parts.in-code
          and buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.part-code = negative_parts.part-code
        no-error.
      define variable v-already-rsrv-qnty as decimal no-undo .
      assign
        v-already-rsrv-qnty = 0
      .
      if available buf_parts
      then do:
        assign
          v-already-rsrv-qnty = buf_parts.qnty
        .
      end.
      assign
        v-rsrv-qnty = negative_parts.qnty
                    * ( if p-negative-code = 'free-zone':U
                        then -1
                        else 1
                      )
                    - v-already-rsrv-qnty
      .
      define variable v-real-chg-qnty as decimal   no-undo .
      run partrsrv in this-procedure
        (input  v-rsrv-qnty
        ,input  p-goods-serial
        ,input  p-goods-twounit
        ,input  false
        ,buffer negative_parts
        ,buffer buf_trn-doc
        ,output v-real-chg-qnty
        ,output v-parts-recid
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове partrsrv" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return return-value .
      end.
      assign
        p-total-rsrv-qnty = p-total-rsrv-qnty + v-real-chg-qnty
        p-abs-rsrv-qnty   = p-abs-rsrv-qnty   + abs(v-real-chg-qnty)
      .
    end.
  end.
end procedure.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
function stsMarkWhenDeleteGoods returns integer
    (input iDocCode as character,
     input iMark as character):
  define variable vValue as character no-undo.
  define variable vType as character no-undo.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-marking for ub.c-marking.
  if iDocCode <> ? then
  do:
      find first buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = iDocCode no-error.
      if avail buf_trn-doc then
      do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'is-return':U ,
                       output vValue ,
                       output vType ) no-error .
         if buf_trn-doc.ext-doc-type = 'we':U or
            buf_trn-doc.ext-doc-type = 'ev':U or
            vValue = "yes" then
         do:
           find last buf_c-marking no-lock where
                     buf_c-marking.mark = iMark
                use-index pi-2 no-error.
           if avail buf_c-marking and
                   (buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB or
                    buf_c-marking.sts = objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB) then
             return buf_c-marking.sts .
         end.
      end.
  end.
  return objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
end function.
procedure partrsrv :
  define input parameter  p-chg-qnty      as decimal   no-undo .
  define input parameter  p-goods-serial  as logical   no-undo .
  define input parameter  p-goods-twounit as logical   no-undo .
  define input parameter  p-unreserv-only as logical   no-undo .
  define parameter buffer buf_orig_parts  for ub.parts .
  define parameter buffer buf_trn-doc     for ub.trn-doc .
  define output parameter p-real-chg-qnty as decimal   no-undo .
  define output parameter p-parts-recid   as recid     no-undo .
  define input  parameter p-mark          as character  no-undo .
  define variable vss-description as character no-undo init "$Workfile$ Резервирование и снятие резервов по одной партии".
  define buffer buf_parts  for ub.parts .
  define buffer rsrv-parts for ub.parts .
  define buffer unrsrv-parts for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define buffer free_marking-lines for ub.marking-lines .
  define variable lok                as logical   no-undo .
  define variable v-sign-chg-qnty    as integer   no-undo .
  define variable v-sign-rsrv-qnty   as integer   no-undo .
  define variable v-rsrv-qnty        as decimal   no-undo .
  define variable v-orig-unrsrv-code as character no-undo .
  define variable v-new-rsrv-code    as character no-undo .
  define variable v-new-unrsrv-code  as character no-undo .
  define variable v-unrsrv-qnty      as decimal   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable v-part-code-int   as integer no-undo .
  define variable v-old-part-code   as character no-undo .
  define variable v-part-gds-code   as integer   no-undo .
  do transaction
  on error undo, return error
  :
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_orig_parts.obj-type
          ,input buf_orig_parts.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
    assign
      p-parts-recid = ?
    .
    if p-chg-qnty = 0 then do:
      assign
        p-parts-recid = recid(buf_orig_parts)
      .
      return .
    end.
    assign
      v-sign-chg-qnty = 0
    .
    if p-chg-qnty < 0 then do:
      assign
        v-sign-chg-qnty = -1
      .
    end.
    if p-chg-qnty > 0 then do:
      assign
        v-sign-chg-qnty = 1
      .
    end.
    assign
      v-sign-rsrv-qnty = v-sign-chg-qnty
    .
    if lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 then do:
      assign
        v-sign-rsrv-qnty = - v-sign-chg-qnty
      .
    end.
    run partcopy in this-procedure
      (input  false
      ,input  buf_trn-doc.doc-code
      ,buffer buf_orig_parts
      ,buffer buf_parts
      ,input  p-mark
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании партии" skip
        "Объект" buf_orig_parts.obj-type buf_orig_parts.obj-code skip
        "Артикул" buf_orig_parts.artic buf_orig_parts.prod-type buf_orig_parts.prod-code skip
        "Партия" buf_orig_parts.in-code buf_orig_parts.part-code skip
        "Резерв" buf_trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_parts.in-code = buf_parts.out-code then do:
      assign
        v-rsrv-qnty = abs(p-chg-qnty)
      .
      if buf_trn-doc.doc-type <> 'инв':U then do:
        if buf_parts.qnty < 0
        or buf_parts.fact-qnty < 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Резервирование невозможно" skip
            "Партия зарезервированная за обычным документом имеет отрицательное количество" skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-sign-rsrv-qnty < 0 then do:
          assign
            v-rsrv-qnty = min(abs(buf_parts.qnty), v-rsrv-qnty)
          .
        end.
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
        buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
      .
      if p-goods-twounit = true
      then do:
        if buf_parts.qnty < 0 then do:
          message
            "Порожденная партия ювелирных изделий не может иметь отрицательное количество" skip
            "Количество" buf_parts.qnty skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_parts.qnty = 0 then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        if  buf_parts.qnty <> 0
        and buf_parts.cli-qnty <> 1
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Порожденная партия ювелирных изделий должна иметь определенное клиентское количество" skip
            "qnty" buf_parts.qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        if buf_parts.cli-base-rate <> 0
        then do:
          assign
            buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
          .
        end.
        else do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
      end.
      assign
        p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
        p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
      .
    end.
    else do:
      assign
        v-orig-unrsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and buf_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
        v-new-rsrv-code    =  ( if p-chg-qnty > 0
                                then 'free-zone':U
                                else 'out-zone':U
                              )
        v-new-unrsrv-code  =  ( if p-chg-qnty > 0
                                then 'out-zone':U
                                else 'free-zone':U
                              )
      .
      if v-new-rsrv-code = v-orig-unrsrv-code then do:
        assign
          v-rsrv-qnty = min(abs(buf_parts.qnty), abs(p-chg-qnty) )
        .
        if v-izlcstpr and buf_parts.out-code <> v-new-rsrv-code and p-chg-qnty > 0
        then do :
            find first rsrv-parts exclusive-lock
                where rsrv-parts.obj-type  = buf_parts.obj-type
                  and rsrv-parts.obj-code  = buf_parts.obj-code
                  and rsrv-parts.artic     = buf_parts.artic
                  and rsrv-parts.prod-type = buf_parts.prod-type
                  and rsrv-parts.prod-code = buf_parts.prod-code
                  and rsrv-parts.in-code   = buf_parts.out-code
                  and rsrv-parts.out-code  = v-new-rsrv-code
                  and rsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.
        if not available rsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true
              ,input  v-new-rsrv-code
              ,buffer buf_parts
              ,buffer rsrv-parts
              ,input p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.
        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty > 0)
        then
        assign
          rsrv-parts.qnty      = rsrv-parts.qnty      + v-rsrv-qnty
          rsrv-parts.fact-qnty = rsrv-parts.fact-qnty + v-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            rsrv-parts.cli-qnty = rsrv-parts.cli-qnty + abs(buf_parts.cli-qnty)
          .
        end.
        else do:
          if rsrv-parts.cli-base-rate <> 0
          then do:
            assign
              rsrv-parts.cli-qnty = rsrv-parts.fact-qnty / rsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              rsrv-parts.cli-qnty = 0
            .
          end.
        end.
        assign
          buf_parts.qnty      = buf_parts.qnty      + v-rsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-rsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = 0
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.
        assign
          p-chg-qnty      = p-chg-qnty      - v-rsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-rsrv-qnty * v-sign-chg-qnty
        .
      end.
      if p-chg-qnty <> 0
      and (
           (buf_trn-doc.doc-type = 'инв':U
           and p-unreserv-only = false
           )
          or v-new-unrsrv-code = v-orig-unrsrv-code
          )
      then do:
        if v-izlcstpr and buf_parts.out-code <> v-new-unrsrv-code and p-chg-qnty < 0
        then do :
            find first unrsrv-parts exclusive-lock
                where unrsrv-parts.obj-type  = buf_parts.obj-type
                  and unrsrv-parts.obj-code  = buf_parts.obj-code
                  and unrsrv-parts.artic     = buf_parts.artic
                  and unrsrv-parts.prod-type = buf_parts.prod-type
                  and unrsrv-parts.prod-code = buf_parts.prod-code
                  and unrsrv-parts.in-code   = buf_parts.in-code
                  and unrsrv-parts.out-code  = v-new-unrsrv-code
                  and unrsrv-parts.part-code = buf_parts.part-code
                no-error.
        end.
        if not available unrsrv-parts
        then do :
            run partcopy in this-procedure
              (input  true
              ,input  v-new-unrsrv-code
              ,buffer buf_parts
              ,buffer unrsrv-parts
              ,input  p-mark
              ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании партии" skip
                "Объект" buf_parts.obj-type buf_parts.obj-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "Резерв" v-new-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
        end.
        assign
          v-unrsrv-qnty = min( (if unrsrv-parts.qnty > 0
                                then unrsrv-parts.qnty
                                else 0
                                )
                          , abs(p-chg-qnty))
        .
        assign
          buf_parts.qnty      = buf_parts.qnty      + v-unrsrv-qnty * v-sign-rsrv-qnty
          buf_parts.fact-qnty = buf_parts.fact-qnty + v-unrsrv-qnty * v-sign-rsrv-qnty
        .
        if p-goods-twounit = true then do:
          assign
            buf_parts.cli-qnty = buf_parts.cli-qnty + unrsrv-parts.cli-qnty * v-sign-rsrv-qnty
          .
        end.
        else do:
          if buf_parts.cli-base-rate <> 0
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
            .
          end.
          else do:
            assign
              buf_parts.cli-qnty = 0
            .
          end.
        end.
        if num-entries(buf_parts.part-code, "_") = 2
        and buf_parts.qnty > 0
        and buf_parts.out-code <> 'free-zone':U
        and buf_parts.out-code <> 'out-zone':U
        and buf_trn-doc.ext-doc-type = 'vt':U
        then do :
          v-old-part-code = buf_parts.part-code .
          v-part-code-int = 0 .
          buf_parts.part-code = entry(2, buf_parts.part-code, "_") no-error .
          do while error-status:error :
            v-part-code-int = v-part-code-int + 1 .
            buf_parts.part-code = string(integer(entry(2, buf_parts.part-code, "_")) + v-part-code-int) no-error .
          end .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-part-gds-code
  )  .
          find first buf_parts-attr exclusive-lock where buf_parts-attr.in-code   = buf_parts.in-code
                                                     and buf_parts-attr.gds-code  = v-part-gds-code
                                                     and buf_parts-attr.part-code = buf_parts.part-code
                                                     no-error.
          if not available buf_parts-attr then do:
            find first ub.parts-attr no-lock where ub.parts-attr.in-code   = buf_parts.in-code
                                               and ub.parts-attr.gds-code  = v-part-gds-code
                                               and ub.parts-attr.part-code = v-old-part-code
                                               no-error.
            if available ub.parts-attr then do:
              create buf_parts-attr.
              buffer-copy ub.parts-attr to buf_parts-attr
              assign
                buf_parts-attr.part-code = buf_parts.part-code
              .
            end.
          end.
        end .
        if not v-izlcstpr or (v-izlcstpr and p-chg-qnty < 0)
        then
        assign
          unrsrv-parts.qnty      = unrsrv-parts.qnty      - v-unrsrv-qnty
          unrsrv-parts.fact-qnty = unrsrv-parts.fact-qnty - v-unrsrv-qnty
        .
        if p-goods-twounit = true
        then do:
          assign
            unrsrv-parts.cli-qnty = 0
          .
        end.
        else do:
          if unrsrv-parts.cli-base-rate <> 0
          then do:
            assign
              unrsrv-parts.cli-qnty = unrsrv-parts.fact-qnty / unrsrv-parts.cli-base-rate
            .
          end.
          else do:
            assign
              unrsrv-parts.cli-qnty = 0
            .
          end.
        end.
        assign
          p-chg-qnty      = p-chg-qnty      - v-unrsrv-qnty * v-sign-chg-qnty
          p-real-chg-qnty = p-real-chg-qnty + v-unrsrv-qnty * v-sign-chg-qnty
        .
      end.
    end.
    if available unrsrv-parts
    and unrsrv-parts.qnty      = 0
    and unrsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if unrsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" unrsrv-parts.obj-type unrsrv-parts.obj-code skip
            "Артикул" unrsrv-parts.artic unrsrv-parts.prod-type unrsrv-parts.prod-code skip
            "Партия" unrsrv-parts.in-code unrsrv-parts.part-code skip
            "Резерв" unrsrv-parts.out-code skip
            "qnty" unrsrv-parts.qnty skip
            "fact-qnty" unrsrv-parts.fact-qnty skip
            "cli-qnty" unrsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      define variable origpart-key-rec as character no-undo .
      define buffer buf_gen-attr for ub.gen-attr .
      define buffer buf1_gen-attr for ub.gen-attr .
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer unrsrv-parts:handle)
                                        ,output part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output origpart-key-rec).
      if  v-new-rsrv-code <> 'out-zone':U then do:
        for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
          find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                                            and buf_gen-attr.p-key =  origpart-key-rec
                                            and buf_gen-attr.attr-code = ub.gen-attr.attr-code no-error .
        if not available (buf_gen-attr) then do:
            create buf_gen-attr .
            buffer-copy ub.gen-attr to buf_gen-attr
            assign
                buf_gen-attr.p-key = origpart-key-rec
            no-error .
        end.
          find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
          find current buf1_gen-attr exclusive-lock.
          delete buf1_gen-attr .
      end.
      end.
      define variable v-gds-code as integer   no-undo .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  unrsrv-parts.artic
  ,input  unrsrv-parts.prod-type
  ,input  unrsrv-parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = unrsrv-parts.obj-type
        and ub.marking-lines.obj-code = unrsrv-parts.obj-code
        and ub.marking-lines.in-code = unrsrv-parts.in-code
        and ub.marking-lines.out-code = unrsrv-parts.out-code
        and ub.marking-lines.part-code = unrsrv-parts.part-code
        and ub.marking-lines.prt-code = unrsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      delete unrsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(unrsrv-parts)
      .
    end.
    if available rsrv-parts
    and rsrv-parts.qnty      = 0
    and rsrv-parts.fact-qnty = 0
    then do:
      if p-goods-twounit = true then do:
        if rsrv-parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" rsrv-parts.obj-type rsrv-parts.obj-code skip
            "Артикул" rsrv-parts.artic rsrv-parts.prod-type rsrv-parts.prod-code skip
            "Партия" rsrv-parts.in-code rsrv-parts.part-code skip
            "Резерв" rsrv-parts.out-code skip
            "qnty" rsrv-parts.qnty skip
            "fact-qnty" rsrv-parts.fact-qnty skip
            "cli-qnty" rsrv-parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer rsrv-parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
            find first buf_gen-attr no-lock where recid (buf_gen-attr) = recid (ub.gen-attr).
            find current buf_gen-attr exclusive-lock.
            delete buf_gen-attr.
      end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  rsrv-parts.artic
  ,input  rsrv-parts.prod-type
  ,input  rsrv-parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = rsrv-parts.obj-type
        and ub.marking-lines.obj-code = rsrv-parts.obj-code
        and ub.marking-lines.in-code = rsrv-parts.in-code
        and ub.marking-lines.out-code = rsrv-parts.out-code
        and ub.marking-lines.part-code = rsrv-parts.part-code
        and ub.marking-lines.prt-code = rsrv-parts.prt-code:
          delete ub.marking-lines.
      end.
      delete rsrv-parts .
    end.
    else do:
      assign
        p-parts-recid = recid(rsrv-parts)
      .
    end.
    if  buf_parts.qnty      = 0
    and buf_parts.fact-qnty = 0 then do:
      if p-goods-twounit = true then do:
        if buf_parts.cli-qnty <> 0 then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении партии" skip
            "Объект" buf_parts.obj-type buf_parts.obj-code skip
            "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
            "Партия" buf_parts.in-code buf_parts.part-code skip
            "Резерв" buf_parts.out-code skip
            "qnty" buf_parts.qnty skip
            "fact-qnty" buf_parts.fact-qnty skip
            "cli-qnty" buf_parts.cli-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      define variable part-key-rec_free as character no-undo .
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                            and ub.gen-attr.p-key =  part-key-rec :
        if (entry (8,part-key-rec,chr(3)) <> 'free-zone':U) and (entry (8,part-key-rec,chr(3)) <> entry (7,part-key-rec,chr(3))) then do:
        part-key-rec_free = part-key-rec .
        entry (8,part-key-rec_free,chr(3)) = 'free-zone':U .
        find first buf_gen-attr no-lock where buf_gen-attr.table-name = 'excise-mark':U
                    and buf_gen-attr.attr-code = ub.gen-attr.attr-code
                    and num-entries (buf_gen-attr.p-key, chr(3)) >= 8
                    and entry(8, buf_gen-attr.p-key, chr(3)) = 'free-zone':U
                    no-error .
                if not available (buf_gen-attr) then
                do:
                    create buf_gen-attr.
                    buffer-copy ub.gen-attr except ub.gen-attr.p-key to buf_gen-attr .
                    assign
                        buf_gen-attr.p-key = part-key-rec_free
                        .
                end.
        end.
        find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
        find current buf1_gen-attr exclusive-lock.
        delete buf1_gen-attr .
      end.
      release buf_gen-attr.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
      for each ub.marking-lines where ub.marking-lines.gds-code = v-gds-code
        and ub.marking-lines.obj-type = buf_parts.obj-type
        and ub.marking-lines.obj-code = buf_parts.obj-code
        and ub.marking-lines.in-code = buf_parts.in-code
        and ub.marking-lines.out-code = buf_parts.out-code
        and ub.marking-lines.part-code = buf_parts.part-code
        and ub.marking-lines.prt-code = buf_parts.prt-code:
          if chg-qnty < 0
          then do :
            for first ub.marking exclusive-lock where ub.marking.mark = ub.marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = ub.marking-lines.mark
                                                      and free_marking-lines.gds-code   = ub.marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = ub.marking-lines.obj-type
                                                      and free_marking-lines.obj-code   = ub.marking-lines.obj-code
                                                      and free_marking-lines.in-code    = ub.marking-lines.in-code
                                                      and free_marking-lines.out-code   = 'free-zone':U
                                                      and free_marking-lines.part-code  = ub.marking-lines.part-code
                                                      and free_marking-lines.prt-code   = ub.marking-lines.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = ub.marking-lines.mark
                  free_marking-lines.doc-level  = ub.marking-lines.doc-level
                  free_marking-lines.gds-code   = ub.marking-lines.gds-code
                  free_marking-lines.obj-type   = ub.marking-lines.obj-type
                  free_marking-lines.obj-code   = ub.marking-lines.obj-code
                  free_marking-lines.in-code    = ub.marking-lines.in-code
                  free_marking-lines.out-code   = 'free-zone':U
                  free_marking-lines.part-code  = ub.marking-lines.part-code
                  free_marking-lines.prt-code   = ub.marking-lines.prt-code
                .
              end .
              ub.marking.sts = stsMarkWhenDeleteGoods(if avail buf_trn-doc then buf_trn-doc.doc-code else ?,
                                                      ub.marking-lines.mark).
            end .
          end .
          delete ub.marking-lines.
      end.
      delete buf_parts .
    end.
    else do:
      assign
        buf_parts.rsrv-free =
        ( (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and buf_parts.qnty < 0))
      .
      if  buf_trn-doc.doc-type <> 'инв':U
      and (buf_parts.qnty < 0
           or buf_parts.fact-qnty < 0
          )
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Партии с отрицательным количеством допустимы" skip
          "только для документа инвентаризации" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_trn-doc.doc-code skip
          "Количество по документу" buf_parts.qnty skip
          "Фактическое количество" buf_parts.fact-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        p-parts-recid = recid(buf_parts)
      .
    end.
  end.
end procedure.
procedure partrsrv-need-rsrv :
  define input  parameter p-parts-in-code   as character no-undo .
  define input  parameter p-parts-out-code  as character no-undo .
  define output parameter p-need-rsrv-parts as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-parts-out-code <> p-parts-in-code
    then do:
      assign
        p-need-rsrv-parts = true
      .
    end.
    else do:
      assign
        p-need-rsrv-parts = false
      .
    end.
  end.
end procedure.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partcopy :
  define input parameter  p-free-output-copy as logical   no-undo .
  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .
  define input parameter  p-mark             as character no-undo .
  define variable vss-description as character no-undo init "partcopy-01: процедура копирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable orig-part-key-rec as character no-undo .
  define variable del-part-key-rec  as character no-undo .
  define variable objMarks as class excisemarks  no-undo .
  define variable v-parent-mark-sts as integer   no-undo .
  define variable v-mark-sts-list   as character no-undo .
  define variable oMarkSts as class ibs.th.str.marking.sts.mark .
  oMarkSts = objSrv:Env:Marking:Sts:Mark.
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf1_gen-attr for ub.gen-attr .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-childs for ub.marking .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer orig_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-pack for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_goods for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer pri_trn-doc for ub.trn-doc .
  define buffer buf_chk-doc for ub.chk-doc .
  do
  on error undo, return error return-value
  :
    if p-free-output-copy = true
    then do:
      if  p-out-code <> 'free-zone':U
      and p-out-code <> 'out-zone':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info48 skip
          "Ошибка задания входных параметров процедуры partcopy" skip
          "p-free-output-copy" p-free-output-copy skip
          "p-out-code" p-out-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if buf_orig_parts.out-code <> p-out-code
    then do:
      find first buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_orig_parts.obj-type
          and buf_parts.obj-code  = buf_orig_parts.obj-code
          and buf_parts.artic     = buf_orig_parts.artic
          and buf_parts.prod-type = buf_orig_parts.prod-type
          and buf_parts.prod-code = buf_orig_parts.prod-code
          and buf_parts.in-code   = buf_orig_parts.in-code
          and buf_parts.out-code  = p-out-code
          and buf_parts.part-code = buf_orig_parts.part-code
        no-error.
      if not available buf_parts
      then do:
        define variable v-rsrv-free as logical   no-undo .
        if p-out-code = 'free-zone':U
        or p-out-code = 'out-zone':U
        then do:
          assign
            v-rsrv-free =
       (if p-out-code = 'free-zone':U then yes else no)
          .
        end.
        else do:
          assign
            v-rsrv-free = ?
          .
        end.
        create buf_parts .
        buffer-copy buf_orig_parts to buf_parts
        assign
          buf_parts.out-code  = p-out-code
          buf_parts.status_   = no
          buf_parts.rsrv-free = v-rsrv-free
          buf_parts.qnty      = 0
          buf_parts.fact-qnty = 0
          buf_parts.real-qnty = 0
          buf_parts.cli-qnty  = 0
        .
        validate buf_parts .
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_orig_parts:handle)
                                        ,output orig-part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
            and ub.gen-attr.p-key =  orig-part-key-rec:
          if not valid-object (objMarks)
            then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
            if p-out-code = 'free-zone':U
            and (entry(7,orig-part-key-rec,chr(3)) = entry(8,orig-part-key-rec,chr(3)) )
             then
            do:
                objMarks:CrFreeMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
                if objMarks:StatusErr
                    then
                do:
                    message objMarks:ReturnMsg view-as alert-box error.
                    delete object objMarks no-error.
                    undo, return error.
                end.
            end.
          if (entry(7,orig-part-key-rec,chr(3)) <> entry(8,orig-part-key-rec,chr(3)) ) then
          do:
              if p-mark <> "" then do:
              if p-out-code = 'free-zone':U then do:
                objMarks:RezervMarkForParts(buffer buf_parts, buffer buf_orig_parts, p-mark) .
              end.
              else do:
                objMarks:RezervMarkForParts(buffer buf_orig_parts, buffer buf_parts, p-mark) .
              end.
              if objMarks:StatusErr
                then
              do:
                message objMarks:ReturnMsg view-as alert-box error.
                delete object objMarks no-error.
                undo, return error.
              end.
            end.
          end.
          if p-out-code = 'out-zone':U then
          do:
              objMarks:CrOutMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
          end.
      end.
      delete object objMarks no-error.
      if p-mark = "news" then return .
      find first pri_trn-doc no-lock where pri_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-out-code no-error.
      if not available buf_trn-doc
      then
         find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      if (
          p-out-code = 'free-zone':U
          and buf_orig_parts.in-code = buf_orig_parts.out-code
         )
      or
         (
          p-out-code = 'free-zone':U
          and available pri_trn-doc
          and (pri_trn-doc.ext-doc-type = 'iv':U or pri_trn-doc.ext-doc-type = 'rv':U)
         )
      or
         (
          available buf_trn-doc
          and p-out-code = buf_trn-doc.doc-code
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'rs':U
         )
      then do :
        find first ub.goods no-lock where ub.goods.artic = buf_parts.artic
          and ub.goods.prod-type = buf_parts.prod-type
          and ub.goods.prod-code = buf_parts.prod-code.
        def buffer buf_orig_ml for ub.marking-lines.
        for each buf_orig_ml where buf_orig_ml.gds-code = ub.goods.gds-code
          and buf_orig_ml.obj-type = buf_orig_parts.obj-type
          and buf_orig_ml.obj-code = buf_orig_parts.obj-code
          and buf_orig_ml.in-code = buf_orig_parts.in-code
          and buf_orig_ml.out-code = buf_orig_parts.out-code
          and buf_orig_ml.part-code = buf_orig_parts.part-code
          and buf_orig_ml.prt-code = buf_orig_parts.prt-code:
          if available pri_trn-doc
          and pri_trn-doc.ext-doc-type = 'iv':U
          and buf_orig_ml.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do :
            for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark :
              assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
            end .
            next .
          end .
          find first ub.marking-lines no-lock where ub.marking-lines.mark     = buf_orig_ml.mark
                                                and ub.marking-lines.gds-code = buf_orig_ml.gds-code
                                                and ub.marking-lines.obj-type = buf_orig_ml.obj-type
                                                and ub.marking-lines.obj-code = buf_orig_ml.obj-code
                                                and ub.marking-lines.in-code  = buf_orig_ml.in-code
                                                and ub.marking-lines.out-code = p-out-code
                                                and ub.marking-lines.part-code = buf_orig_ml.part-code
                                                and ub.marking-lines.prt-code = buf_orig_ml.prt-code
                                                no-error .
          if not available ub.marking-lines
          then do :
            create ub.marking-lines.
            buffer-copy buf_orig_ml to ub.marking-lines
            assign
              ub.marking-lines.out-code  = p-out-code
              ub.marking-lines.fact-order = pri_trn-doc.fact-order when available pri_trn-doc
            .
            validate ub.marking-lines.
          end .
          if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U then do:
          for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark
            and not (buf_marking.sts = oMarkSts:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U):
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB and
               not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) and
               not can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
            then do:
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              validate buf_marking.
            end.
          end .
        end .
        end.
      end .
      define variable v-doc-type  as character no-undo .
      define variable   v-status    as character no-undo .
      define variable v-fact-qnty   as  decimal no-undo .
      define variable ii    as integer no-undo .
      find first buf_goods no-lock where buf_goods.artic = buf_orig_parts.artic
                                     and buf_goods.prod-type = buf_orig_parts.prod-type
                                     and buf_goods.prod-code = buf_orig_parts.prod-code
                                     .
      if available pri_trn-doc
      and pri_trn-doc.ext-doc-type = 'rs':U
      then do :
        if p-mark <> ""
        then do :
        end .
        else do :
        end .
      end .
      else do :
        if buf_orig_parts.in-code <> buf_orig_parts.out-code
        and p-mark <> ""
        then do :
          if p-out-code = 'free-zone':U
          then do:
              if chg-qnty < 0
              then do :
                find first orig_marking-lines no-lock where orig_marking-lines.mark       = p-mark
                                                        and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                        and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                        and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                        and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                        and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                        and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                        and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                        no-error .
                if available orig_marking-lines
                then do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                         and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                         and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                         and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                         and buf_marking-lines.in-code    = buf_parts.in-code
                                                         and buf_marking-lines.out-code   = buf_parts.out-code
                                                         and buf_marking-lines.part-code  = buf_parts.part-code
                                                         and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    create buf_marking-lines .
                    assign
                      buf_marking-lines.mark       = p-mark
                      buf_marking-lines.doc-level  = orig_marking-lines.doc-level
                      buf_marking-lines.gds-code   = buf_goods.gds-code
                      buf_marking-lines.obj-type   = buf_parts.obj-type
                      buf_marking-lines.obj-code   = buf_parts.obj-code
                      buf_marking-lines.in-code    = buf_parts.in-code
                      buf_marking-lines.out-code   = buf_parts.out-code
                      buf_marking-lines.part-code  = buf_parts.part-code
                      buf_marking-lines.prt-code   = buf_parts.prt-code
                    .
                    validate buf_marking-lines.
                  end .
                  for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                    assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                    for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                      for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                      and buf_chk-doc.out-code = buf_orig_parts.out-code
                                                      :
                        assign buf_marking-chk.sts = 0 .
                        validate buf_marking-chk.
                      end .
                    end .
                    if buf_marking.unit-ext <> "UNIT" or
                       (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                    then do :
                      run addChildMarkingLines in this-procedure (
                        buf_marking.mark,
                        objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                        buffer buf_marking-lines,
                        buffer buf_parts,
                        buffer orig_marking-lines,
                        buffer buf_orig_parts,
                        buffer buf_goods
                      ).
                    end .
                  end.
                  find current orig_marking-lines exclusive-lock .
                  delete orig_marking-lines .
                end .
              end .
          end.
          else do:
            find first orig_marking-lines exclusive-lock where orig_marking-lines.mark       = p-mark
                                                           and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                           and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                           and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                           and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                           and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                           and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                           and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                           no-error .
              find first buf_marking-lines no-lock where  buf_marking-lines.mark       = p-mark
                                                      and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                      and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                      and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                      and buf_marking-lines.in-code    = buf_parts.in-code
                                                      and buf_marking-lines.out-code   = buf_parts.out-code
                                                      and buf_marking-lines.part-code  = buf_parts.part-code
                                                      and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available buf_marking-lines
              then do :
                create buf_marking-lines .
                assign
                  buf_marking-lines.mark       = p-mark
                  buf_marking-lines.doc-level  = 1
                  buf_marking-lines.gds-code   = buf_goods.gds-code
                  buf_marking-lines.obj-type   = buf_parts.obj-type
                  buf_marking-lines.obj-code   = buf_parts.obj-code
                  buf_marking-lines.in-code    = buf_parts.in-code
                  buf_marking-lines.out-code   = buf_parts.out-code
                  buf_marking-lines.part-code  = buf_parts.part-code
                  buf_marking-lines.prt-code   = buf_parts.prt-code
                  buf_marking-lines.sts        = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                validate buf_marking-lines.
              end .
              for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
                validate buf_marking.
                for first buf_marking-childs exclusive-lock where
                          buf_marking-childs.mark = buf_marking.mark-parent:
                  buf_marking-childs.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
                  validate buf_marking-childs.
                end.
                for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                  for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                  and buf_chk-doc.out-code = buf_parts.out-code
                                                  :
                    if buf_marking-chk.sts <> 2 then
                    do:
                       assign buf_marking-chk.sts = 1 .
                       validate buf_marking-chk.
                    end.
                  end .
                end .
                if buf_marking.unit-ext <> "UNIT" or
                   (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                then do :
                  run addChildMarkingLines in this-procedure (
                    buf_marking.mark,
                    buf_marking.sts,
                    buffer buf_marking-lines,
                    buffer buf_parts,
                    buffer orig_marking-lines,
                    buffer buf_orig_parts,
                    buffer buf_goods
                  ).
                end .
              end.
              if available orig_marking-lines then
                delete orig_marking-lines .
          end.
        end.
      end .
      if p-out-code = 'out-zone':U
      and trim(p-mark) = ""
      then do :
        for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                              and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                              and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                              and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                              and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                              and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                              and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                              :
          find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                  and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                  and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                  and buf_marking-lines.out-code   = p-out-code
                                                  no-error .
          if available buf_marking-lines
          then do :
            find current buf_marking-lines exclusive-lock .
            delete buf_marking-lines .
            for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                validate buf_marking.
              end.
            end .
          end .
          else do :
            if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_parts.out-code <> 'out-zone':U then do:
            create buf_marking-lines .
            assign
              buf_marking-lines.mark       = orig_marking-lines.mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
              buf_marking-lines.prt-code   = buf_parts.prt-code
            .
            validate buf_marking-lines.
            if buf_parts.out-code <> buf_parts.in-code
            and buf_parts.out-code <> 'free-zone':U
            and buf_parts.out-code <> 'out-zone':U
            then do :
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
              if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
            end .
            end.
          end .
          release buf_marking-lines no-error .
        end.
      end .
      if p-mark <> "" and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U
      then do:
        for each orig_marking-lines no-lock where orig_marking-lines.mark         = p-mark
                                                and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                .
          find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                 and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                 and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                 and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                 and buf_marking-lines.in-code    = buf_parts.in-code
                                                 and buf_marking-lines.out-code   = buf_orig_parts.out-code
                                                 and buf_marking-lines.part-code  = buf_parts.part-code
                                                 no-error .
          for each ub.marking where ub.marking.mark = buf_marking-lines.mark:
            if p-out-code = 'free-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:FreeZone:KeyIntDB.
            if p-out-code = 'out-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:OutZone:KeyIntDB.
            validate ub.marking.
          end.
          run partcopy-to-childs-mark (buffer buf_marking-lines, buffer orig_marking-lines, input buf_parts.out-code, oMarkSts).
          if available (buf_marking-lines)
          then do:
            assign
              buf_marking-lines.mark       = p-mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
            .
            validate buf_marking-lines.
          end.
        end.
      end.
    end.
    else do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(buf_orig_parts)
        .
    end.
    if p-out-code = 'free-zone':U
    or p-out-code = 'out-zone':U
    then do:
      if buf_parts.rsrv-free <>
       (if buf_parts.out-code = 'free-zone':U then yes else no)
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info48 skip
          "Ошибка типа резерва партии" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code  skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_parts.out-code skip
          "Статус" buf_parts.status_ skip
          "Тип резерва" buf_parts.rsrv-free skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure partcopy-to-childs-mark :
  define parameter buffer buf_ml for ub.marking-lines .
  define parameter buffer buf_orig-ml for ub.marking-lines .
  define input parameter p-out-code as character no-undo .
  define input parameter THMarkSts as class ibs.th.str.marking.sts.mark no-undo .
  define buffer buf_ml-childs for ub.marking-lines .
  for each ub.marking where ub.marking.mark-parent = buf_ml.mark:
    if p-out-code = 'free-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:FreeZone:KeyIntDB.
    if p-out-code = 'out-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:OutZone:KeyIntDB.
    for each buf_ml-childs exclusive-lock where buf_ml-childs.mark = ub.marking.mark
      and buf_ml-childs.obj-type  = buf_orig-ml.obj-type
      and buf_ml-childs.obj-code  = buf_orig-ml.obj-code
      and buf_ml-childs.in-code   = buf_orig-ml.in-code
      and buf_ml-childs.out-code  = buf_orig-ml.out-code
      and buf_ml-childs.part-code = buf_orig-ml.part-code
      and buf_ml-childs.prt-code  = buf_orig-ml.prt-code
      :
      assign
        buf_ml-childs.out-code  = p-out-code
      .
      run partcopy-to-childs-mark (buffer buf_ml-childs, buffer buf_orig-ml, input p-out-code, input THMarkSts).
    end.
  end.
end.
procedure partcopy-update-parts :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-parts-01: процедура обработки партий при закрытии документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code     as character no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock where buf_goods.artic = p-artic
                                   and buf_goods.prod-type = p-prod-type
                                   and buf_goods.prod-code = p-prod-code
                                   no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define query partcopy-select-parts for archive_parts .
    open query partcopy-select-parts preselect each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
      .
    get first partcopy-select-parts .
    if buf_trn-doc.doc-type = 'при':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        if can-do('рас,спи':U, buf_trn-doc.doc-type)
        or (buf_trn-doc.doc-type = 'инв':U
            and archive_parts.fact-qnty < 0)
        then do:
          assign
            v-rsrv-code = 'out-zone':U
          .
        end.
        else do:
          assign
            v-rsrv-code = 'free-zone':U
          .
        end.
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.in-code = p-doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          run partcopy in this-procedure
            (input  true
            ,input  v-rsrv-code
            ,buffer archive_parts
            ,buffer buf_parts
            ,input  ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info48 skip
              "Ошибка при создании партии" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Резерв" v-rsrv-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty     + archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
            .
            case buf_trn-doc.ext-doc-type :
              when 'ie':U
              then do:
                if archive_parts.cli-qnty <> truncate(archive_parts.cli-qnty, 0 )
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info48 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              when 'iv':U
              then do:
                if archive_parts.cli-qnty <> 1
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info48 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Товар учитывается по двум единицам измерения" skip
                  "Для приходов разрешен только внешний приход или приход перемещение" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type archive_parts.prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        else do :
          if buf_trn-doc.ext-doc-type = 'iv':U
          then
          for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                and orig_marking-lines.in-code    = archive_parts.in-code
                                                and orig_marking-lines.out-code   = archive_parts.out-code
                                                and orig_marking-lines.part-code  = archive_parts.part-code,
          first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
          end .
        end .
        get next partcopy-select-parts .
      end.
    end.
    if buf_trn-doc.doc-type = 'рас':U
    or buf_trn-doc.doc-type = 'спи':U
    or buf_trn-doc.doc-type = 'возврат':U
    or buf_trn-doc.doc-type = 'инв':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.fact-qnty <> archive_parts.qnty
        then do:
          define variable v-is-hold as logical   no-undo .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info48
              "Ошибка при определении типа документа hold-doc.i" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if buf_trn-doc.ext-doc-type = 'vt':U
          or (buf_trn-doc.ext-doc-type = 're':U and v-is-hold = true)
          or buf_trn-doc.ext-doc-type = 'ap':U
          or buf_trn-doc.ext-doc-type = 'pc':U
          or buf_trn-doc.ext-doc-type = 'mp':U
          or  buf_trn-doc.ext-doc-type = 'vp':U
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info48 skip
              "Фактическое количество не может отличаться от количества по документу" skip
              "для документов инвентаризации, внутреннего возврата и автоматического возврата между фирмами" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Количество по документу" archive_parts.qnty skip
              "Фактическое количество" archive_parts.fact-qnty skip
              "Клиентское количество" archive_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
          if archive_parts.in-code <> archive_parts.out-code
          then do:
            if can-do('рас,спи':U,buf_trn-doc.doc-type)
            or (buf_trn-doc.doc-type = 'инв':U
                and archive_parts.fact-qnty < 0)
            then do:
              assign
                v-rsrv-code = 'free-zone':U
              .
            end.
            else do:
              assign
                v-rsrv-code = 'out-zone':U
              .
            end.
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при создании партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + (archive_parts.qnty - archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              if archive_parts.cli-qnty <> 1
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться единице" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  available buf_parts
          and buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          if can-do('рас,спи':U, buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48
                "Ошибка при определении типа документа hold-doc.i" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              v-rsrv-code = 'out-zone':U
            .
            if buf_trn-doc.ext-doc-type  = 'ep':U
            or (buf_trn-doc.ext-doc-type = 'ap':U )
            or (buf_trn-doc.ext-doc-type = 'pc':U )
            then do:
              assign
                v-rsrv-code = ""
              .
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end .
            end.
          end.
          else do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          if v-rsrv-code <> ""
          then do:
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при создании партии" skip
                "Документ" buf_trn-doc.doc-code skip
                "Объект" archive_parts.obj-type archive_parts.obj-code skip
                "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + abs(archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              define variable v-qnty-sign as integer   no-undo .
              assign
                v-qnty-sign = 1
              .
              if  buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
              then do:
                assign
                  v-qnty-sign = - 1
                .
              end.
              if archive_parts.cli-qnty <> v-qnty-sign
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться" v-qnty-sign skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = archive_parts.qnty
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + abs(archive_parts.cli-qnty)
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
            if  buf_parts.qnty      = 0
            and buf_parts.fact-qnty = 0
            then do:
              if v-goods-twounit = true
              then do:
                if buf_parts.cli-qnty <> 0
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info48 skip
                    "Ошибка при удалении партии" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" buf_parts.in-code buf_parts.part-code skip
                    "Резерв" buf_parts.out-code skip
                    "qnty" buf_parts.qnty skip
                    "fact-qnty" buf_parts.fact-qnty skip
                    "cli-qnty" buf_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              delete buf_parts .
            end.
          end.
        end.
        if  ( archive_parts.in-code = buf_trn-doc.doc-code
        and archive_parts.supp-type =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        and archive_parts.supp-code =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        )
        or buf_trn-doc.ext-doc-type = 'rv':U
        then do:
          if can-do('рас,спи':U,buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          else do:
            assign
              v-rsrv-code = 'out-zone':U
            .
          end.
          if not v-izlcstpr
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Резерв" v-rsrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              assign
                buf_parts.qnty      = buf_parts.qnty - abs(archive_parts.fact-qnty)
                buf_parts.fact-qnty = buf_parts.qnty
              .
              if buf_trn-doc.ext-doc-type = 'rv':U
              then
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code
                                                    and orig_marking-lines.prt-code   = archive_parts.prt-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                then
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              end .
              if v-goods-twounit = true
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Запрещено порождение партий," skip
                  "который учитывается по двум единицам измерения" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              else do:
                if buf_parts.cli-base-rate <> 0
                then do:
                  assign
                    buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                  .
                end.
                else do:
                  assign
                    buf_parts.cli-qnty = 0
                  .
                end.
              end.
          end.
        end.
        get next partcopy-select-parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-parts-delete :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable objMarks as class excisemarks no-undo.
  define variable vss-description as character no-undo init "partcopy-update-parts-delete-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer archive_parts  for ub.parts .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define variable v-rsrv-code as character no-undo .
  define variable v-unrv-code as character no-undo .
  define variable v-need-rsrv as logical   no-undo .
  define variable v-need-unrv as logical   no-undo .
  define variable v-rsrv-sign as integer   no-undo .
  define variable v-unrv-sign as integer   no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer del_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_chk-doc for ub.chk-doc .
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_arhive   as character no-undo .
  define buffer buf1_gen-attr for ub.gen-attr .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
    for each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
    on error undo, return error return-value
    :
      if archive_parts.fact-qnty <> 0
      then do:
        define variable v-create-part as logical   no-undo .
        define variable v-old-return  as logical   no-undo .
        assign
          v-create-part = false
          v-old-return  = false
        .
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            v-create-part = true
          .
          if archive_parts.supp-type <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
          or archive_parts.supp-code <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
          then do:
            assign
              v-old-return = true
            .
          end.
        end.
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info48
            "Ошибка при определении типа документа hold-doc.i" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partcond in g#library
  (input  buf_trn-doc.ext-doc-type
  ,input  v-is-hold
  ,input  archive_parts.fact-qnty
  ,input  v-create-part
  ,input  v-old-return
  ,output v-rsrv-code
  ,output v-unrv-code
  ,output v-need-rsrv
  ,output v-need-unrv
  ,output v-rsrv-sign
  ,output v-unrv-sign
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info48
            "Ошибка при определении параметров резервирования партии" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-izlcstpr and archive_parts.fact-qnty > 0 then v-need-unrv = false .
        if v-need-rsrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-rsrv-code and v-rsrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            define variable v-fact-num as integer   no-undo .
            define variable v-doc-type as character no-undo .
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-rsrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines exclusive-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                            and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                            and free_marking-lines.obj-type   = buf_parts.obj-type
                                                            and free_marking-lines.obj-code   = buf_parts.obj-code
                                                            and free_marking-lines.in-code    = buf_parts.in-code
                                                            and free_marking-lines.out-code   = buf_parts.out-code
                                                            and free_marking-lines.part-code  = buf_parts.part-code
                                                            and free_marking-lines.prt-code   = buf_parts.prt-code
                                                            no-error .
              if available free_marking-lines
              then do :
                delete free_marking-lines .
              end .
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
                 not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts))
              then do:
                buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end.
            end .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-rsrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer archive_parts:handle)
                                        ,output part-key-rec_arhive).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                                  and ub.gen-attr.p-key =  part-key-rec
            :
              if not valid-object (objMarks)
                then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
              objMarks:DelMarkForParts(buffer buf_parts, buffer archive_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            delete buf_parts .
          end.
        end.
        delete object objMarks no-error.
        if v-need-unrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-unrv-code and v-unrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-unrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-unrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info48 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-unrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                      and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = buf_parts.obj-type
                                                      and free_marking-lines.obj-code   = buf_parts.obj-code
                                                      and free_marking-lines.in-code    = buf_parts.in-code
                                                      and free_marking-lines.out-code   = buf_parts.out-code
                                                      and free_marking-lines.part-code  = buf_parts.part-code
                                                      and free_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = buf_marking-lines.mark
                  free_marking-lines.doc-level  = buf_marking-lines.doc-level
                  free_marking-lines.gds-code   = buf_marking-lines.gds-code
                  free_marking-lines.obj-type   = buf_parts.obj-type
                  free_marking-lines.obj-code   = buf_parts.obj-code
                  free_marking-lines.in-code    = buf_parts.in-code
                  free_marking-lines.out-code   = buf_parts.out-code
                  free_marking-lines.part-code  = buf_parts.part-code
                  free_marking-lines.prt-code   = buf_parts.prt-code
                .
              end .
              if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_trn-doc.doc-type <> 'спи':U and
                 not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U)
                then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              if buf_trn-doc.ext-doc-type = 'es':U
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB .
              end .
              for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                assign buf_marking-chk.sts = 0 .
              end .
            end .
            delete buf_marking-lines .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-unrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info48 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec
            :
              find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
              find current buf1_gen-attr exclusive-lock.
              delete buf1_gen-attr .
            end.
            delete buf_parts .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure partcopy-rsrv-parts :
  define input  parameter p-doc-code-rowid as rowid no-undo .
  define input  parameter p-parts-rowid    as rowid no-undo .
  define input  parameter p-rsrv-direction as logical   no-undo .
  define input  parameter p-goods-twounit  as logical   no-undo .
  define input  parameter p-is-hold        as logical   no-undo .
  define variable vss-description as character no-undo init "partcopy-rsrv-parts-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where rowid(buf_trn-doc) = p-doc-code-rowid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first archive_parts
      where rowid(archive_parts) = p-parts-rowid
      no-error .
    if not available archive_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найдена партия" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  archive_parts.out-code <> archive_parts.in-code
    and archive_parts.qnty <> 0
    and (buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = yes ) = false
    and (buf_trn-doc.doc-type = 'возврат':U and p-is-hold = true  ) = false
    then do:
      assign
        v-rsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and archive_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
      .
      run partcopy in this-procedure
        (input  true
        ,input  v-rsrv-code
        ,buffer archive_parts
        ,buffer buf_parts
        ,input  "news"
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info48 skip
          "Ошибка при создании партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" archive_parts.obj-type archive_parts.obj-code skip
          "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
          "Партия" archive_parts.in-code archive_parts.part-code skip
          "Количество" archive_parts.qnty skip
          "Резерв" v-rsrv-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty     - abs(archive_parts.qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        buf_parts.fact-qnty = buf_parts.qnty
      .
      find first buf_goods no-lock where buf_goods.artic = archive_parts.artic
                                     and buf_goods.prod-type = archive_parts.prod-type
                                     and buf_goods.prod-code = archive_parts.prod-code
                                     .
      for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                            and orig_marking-lines.obj-type   = archive_parts.obj-type
                                            and orig_marking-lines.obj-code   = archive_parts.obj-code
                                            and orig_marking-lines.in-code    = archive_parts.in-code
                                            and orig_marking-lines.out-code   = archive_parts.out-code
                                            and orig_marking-lines.part-code  = archive_parts.part-code
                                            and orig_marking-lines.prt-code   = archive_parts.prt-code
                                            :
        find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                and buf_marking-lines.in-code    = buf_parts.in-code
                                                and buf_marking-lines.out-code   = buf_parts.out-code
                                                and buf_marking-lines.part-code  = buf_parts.part-code
                                                and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                no-error .
        if available buf_marking-lines
        then do :
          find current buf_marking-lines exclusive-lock .
          delete buf_marking-lines .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
          end .
        end .
        else do :
          create buf_marking-lines .
          assign
            buf_marking-lines.mark       = orig_marking-lines.mark
            buf_marking-lines.doc-level  = orig_marking-lines.doc-level
            buf_marking-lines.gds-code   = buf_goods.gds-code
            buf_marking-lines.obj-type   = buf_parts.obj-type
            buf_marking-lines.obj-code   = buf_parts.obj-code
            buf_marking-lines.in-code    = buf_parts.in-code
            buf_marking-lines.out-code   = buf_parts.out-code
            buf_marking-lines.part-code  = buf_parts.part-code
            buf_marking-lines.prt-code   = buf_parts.prt-code
          .
          if buf_parts.out-code <> buf_parts.in-code
          and buf_parts.out-code <> 'free-zone':U
          and buf_parts.out-code <> 'out-zone':U
          then do :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
            if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
          end .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when buf_parts.out-code = 'free-zone':U
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB when buf_parts.out-code = 'out-zone':U
            .
          end .
        end .
        release buf_marking-lines no-error .
      end.
      if p-goods-twounit = true
      then do:
        assign
          buf_parts.cli-qnty = buf_parts.cli-qnty - abs(archive_parts.cli-qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        .
      end.
      if  buf_parts.qnty      = 0
      and buf_parts.fact-qnty = 0
      then do:
        if p-goods-twounit = true
        then do:
          if buf_parts.cli-qnty <> 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info48 skip
              "Ошибка при удалении партии" skip
              "Документ" buf_trn-doc.doc-code skip
              "Объект" buf_parts.obj-type buf_parts.obj-code skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "Партия" buf_parts.in-code buf_parts.part-code skip
              "Резерв" buf_parts.out-code skip
              "qnty" buf_parts.qnty skip
              "fact-qnty" buf_parts.fact-qnty skip
              "cli-qnty" buf_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        delete buf_parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-doc-line-tot-fact :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-doc-line-tot-fact-01: процедура обновления средней учетной цены в строке документа".
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  define buffer buf_doc-line for ub.doc-line .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run partrqst in this-procedure
      (input buf_doc-line.doc-code
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input buf_doc-line.artic
      ,input buf_doc-line.prod-type
      ,input buf_doc-line.prod-code
            ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        buf_doc-line.price-base      = v-total-parts-price-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.price-rubl      = v-total-parts-price-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-base  = v-total-parts-transport-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-rubl  = v-total-parts-transport-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-base      = v-total-parts-other-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-rubl      = v-total-parts-other-rubl
                                     / v-total-parts-fact-qnty
      .
    end.
    else do:
    end.
  end.
end procedure.
procedure partcopy-change-purch-code :
  define input parameter  p-in-code          like ub.parts.in-code no-undo .
  define input parameter  p-dest-purch-code  like ub.parts.purch-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf1_parts         for ub.parts .
  define parameter buffer buf2_parts         for ub.parts .
  define variable vss-description as character no-undo init "partcopy-change-purch-code01: процедура копирования партии при смене purch-code".
  define variable var-out-code  like ub.parts.out-code no-undo .
  define variable var-part-code like ub.parts.part-code no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_parts-root   for ub.parts-root.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf-orig_trn-doc for ub.trn-doc.
  define buffer buf_units        for ub.units .
  do
  on error undo, return error return-value
  :
    if buf_orig_parts.out-code = p-in-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info48 skip
        "Ошибка задания входных параметров процедуры partcopy" skip
        "buf_orig_parts.out-code" buf_orig_parts.out-code skip
        "p-in-code" p-in-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-in-code
      .
    find first buf-orig_trn-doc where buf-orig_trn-doc.doc-code = buf_orig_parts.out-code.
    find first buf_goods no-lock
      where buf_goods.artic = buf_orig_parts.artic
        and buf_goods.prod-type = buf_orig_parts.prod-type
        and buf_goods.prod-code = buf_orig_parts.prod-code
      .
    find first buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    find first buf1_parts exclusive-lock
      where buf1_parts.obj-type  = buf_orig_parts.obj-type
        and buf1_parts.obj-code  = buf_orig_parts.obj-code
        and buf1_parts.artic     = buf_orig_parts.artic
        and buf1_parts.prod-type = buf_orig_parts.prod-type
        and buf1_parts.prod-code = buf_orig_parts.prod-code
        and buf1_parts.in-code   = buf_orig_parts.in-code
        and buf1_parts.out-code  = p-in-code
        and buf1_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf1_parts
    then do:
      create buf1_parts .
      buffer-copy buf_orig_parts to buf1_parts
      assign
        buf1_parts.in-code    = buf_orig_parts.in-code
        buf1_parts.out-code   = p-in-code
        buf1_parts.status_    = no
        buf1_parts.qnty       = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.fact-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.cli-qnty   = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.cli-qnty  else - buf_orig_parts.cli-qnty  )
        buf1_parts.purch-code = buf_orig_parts.purch-code
        buf1_parts.rsrv-free  = ?
        buf1_parts.status_    = yes
      .
      validate buf1_parts .
    end.
    if  lookup('сер':U, buf_units.type) > 0
    then do:
       var-part-code = buf_orig_parts.part-code.
    end.
    else do:
        run holdprts-get-part-code in this-procedure
          (input  p-in-code
          ,output var-part-code
          ) no-error .
        if error-status :error
        then dO:
          undo, return error return-value.
        end.
    end.
    find first buf2_parts exclusive-lock
      where buf2_parts.obj-type  = buf_orig_parts.obj-type
        and buf2_parts.obj-code  = buf_orig_parts.obj-code
        and buf2_parts.artic     = buf_orig_parts.artic
        and buf2_parts.prod-type = buf_orig_parts.prod-type
        and buf2_parts.prod-code = buf_orig_parts.prod-code
        and buf2_parts.in-code   = p-in-code
        and buf2_parts.out-code  = p-in-code
        and buf2_parts.part-code = var-part-code
      no-error.
    if not available buf2_parts
    then do:
      create buf2_parts .
      buffer-copy buf_orig_parts to buf2_parts
      assign
        buf2_parts.in-code   = p-in-code
        buf2_parts.out-code  = p-in-code
        buf2_parts.qnty      = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.fact-qnty = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.cli-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.cli-qnty  else buf_orig_parts.cli-qnty  )
        buf2_parts.purch-code = p-dest-purch-code
        buf2_parts.part-code  = var-part-code
        buf2_parts.rsrv-free  = ?
        buf2_parts.status_    = yes
      .
      validate buf2_parts .
    end.
    assign
      buf_orig_parts.in-code    = p-in-code
      buf_orig_parts.part-code  = buf2_parts.part-code
      buf_orig_parts.purch-code = buf2_parts.purch-code
    .
    find first buf_parts-root
      where buf_parts-root.doc-code       = p-in-code
        and buf_parts-root.in-code        = p-in-code
        and buf_parts-root.gds-code       = buf_goods.gds-code
        and buf_parts-root.part-code      = buf2_parts.part-code
        and buf_parts-root.orig-in-code   = buf1_parts.in-code
        and buf_parts-root.orig-gds-code  = buf_goods.gds-code
        and buf_parts-root.orig-part-code = buf1_parts.part-code
      no-error .
    if not available buf_parts-root
    then do:
      create buf_parts-root.
      assign
      buf_parts-root.doc-code       = p-in-code
      buf_parts-root.in-code        = p-in-code
      buf_parts-root.gds-code       = buf_goods.gds-code
      buf_parts-root.part-code      = buf2_parts.part-code
      buf_parts-root.orig-in-code   = buf1_parts.in-code
      buf_parts-root.orig-gds-code  = buf_goods.gds-code
      buf_parts-root.orig-part-code = buf1_parts.part-code
      .
    end.
  end.
end procedure.
procedure addChildMarkingLines:
  define input parameter iMark as character no-undo.
  define input parameter iSts  as integer   no-undo.
  define parameter buffer buf_marking-lines  for ub.marking-lines.
  define parameter buffer buf_parts          for ub.parts.
  define parameter buffer orig_marking-lines for ub.marking-lines.
  define parameter buffer buf_orig_parts     for ub.parts.
  define parameter buffer buf_goods          for ub.goods.
  define buffer buf_marking-childs        for ub.marking.
  define buffer buf_marking-lines-childs  for ub.marking-lines.
  define buffer buf_marking-chk           for ub.marking-chk.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer orig_marking-lines-childs for ub.marking-lines.
  for each buf_marking-childs exclusive-lock where
           buf_marking-childs.mark-parent = iMark :
      find first buf_marking-lines-childs no-lock where
                 buf_marking-lines-childs.mark       = buf_marking-childs.mark
             and buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
             and buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
             and buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
             and buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
             and buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
             and buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
             and buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
      no-error .
      if not available buf_marking-lines-childs then
      do:
        create buf_marking-lines-childs .
        assign
          buf_marking-lines-childs.mark       = buf_marking-childs.mark
          buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
          buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
          buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
          buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
          buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
          buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
          buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
          buf_marking-lines-childs.fact-order = buf_marking-lines.fact-order
          buf_marking-lines-childs.doc-level  = buf_marking-lines.doc-level + 1
        .
        validate buf_marking-childs.
      end .
      buf_marking-childs.sts = iSts .
      for each buf_marking-chk exclusive-lock where
               buf_marking-chk.mark begins buf_marking-childs.mark
      :
        for first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_marking-chk.doc-code
              and buf_chk-doc.out-code = buf_parts.out-code
        :
          buf_marking-chk.sts = 0 .
          validate buf_marking-chk.
        end .
      end .
      if available orig_marking-lines
      then do :
        find first orig_marking-lines-childs exclusive-lock where
                   orig_marking-lines-childs.mark       = buf_marking-childs.mark
               and orig_marking-lines-childs.gds-code   = buf_goods.gds-code
               and orig_marking-lines-childs.obj-type   = buf_orig_parts.obj-type
               and orig_marking-lines-childs.obj-code   = buf_orig_parts.obj-code
               and orig_marking-lines-childs.in-code    = buf_orig_parts.in-code
               and orig_marking-lines-childs.out-code   = buf_orig_parts.out-code
               and orig_marking-lines-childs.part-code  = buf_orig_parts.part-code
               and orig_marking-lines-childs.prt-code   = buf_orig_parts.prt-code
        no-error .
        if available orig_marking-lines-childs then
          delete orig_marking-lines-childs .
      end.
      run addChildMarkingLines in this-procedure (
        buf_marking-childs.mark,
        iSts,
        buffer buf_marking-lines,
        buffer buf_parts,
        buffer orig_marking-lines,
        buffer buf_orig_parts,
        buffer buf_goods
      ).
  end .
end.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure holdprts-create-parts-supp :
  define input  parameter p-orig-in-code   like ub.parts-supp.orig-in-code   no-undo .
  define input  parameter p-orig-part-code like ub.parts-supp.orig-part-code no-undo .
  define input  parameter p-in-code        like ub.parts-supp.in-code        no-undo .
  define input  parameter p-artic          like ub.parts-supp.artic          no-undo .
  define input  parameter p-prod-type      like ub.parts-supp.prod-type      no-undo .
  define input  parameter p-prod-code      like ub.parts-supp.prod-code      no-undo .
  define input  parameter p-part-code      like ub.parts-supp.part-code      no-undo .
  define variable vss-description as character no-undo init "holdprts-create-parts-supp-01: скопировать атрибут партии".
  define buffer buf_parent_trn-doc  for ub.trn-doc .
  define buffer buf_child_trn-doc   for ub.trn-doc .
  define buffer buf_parts           for ub.parts .
  define buffer buf_parts-supp      for ub.parts-supp .
  define buffer buf_orig_parts-supp for ub.parts-supp .
  define buffer buf_income_trn-doc  for ub.trn-doc .
  define buffer buf_income_doc-line for ub.doc-line .
  define buffer buf_goods           for ub.goods .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
  do
  on error undo, return error return-value
  :
    find first buf_child_trn-doc no-lock
      where buf_child_trn-doc.doc-code = p-in-code
      no-error .
    if not available buf_child_trn-doc
    then do:
      return substitute("Не найден исходный документ &1", p-in-code) .
    end.
    find first buf_parent_trn-doc no-lock
      where buf_parent_trn-doc.doc-code = buf_child_trn-doc.hold-doc-code-parent
      no-error .
    if not available buf_parent_trn-doc
    then do:
      return substitute("Не найден приходный документ &1", buf_child_trn-doc.hold-doc-code-parent) .
    end.
    find first buf_parts-supp exclusive-lock
      where buf_parts-supp.in-code   = p-in-code
        and buf_parts-supp.artic     = p-artic
        and buf_parts-supp.prod-type = p-prod-type
        and buf_parts-supp.prod-code = p-prod-code
        and buf_parts-supp.part-code = p-part-code
      no-error .
    if available buf_parts-supp
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Попытка повторного создания партии атрибутов" skip
        "Документ прихода" p-in-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код партии" p-part-code skip
        "Исходный код партии" p-orig-in-code skip
        "Исходный код документа" p-orig-part-code skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_parts-supp .
    assign
      buf_parts-supp.in-code   = p-in-code
      buf_parts-supp.artic     = p-artic
      buf_parts-supp.prod-type = p-prod-type
      buf_parts-supp.prod-code = p-prod-code
      buf_parts-supp.part-code = p-part-code
    .
    assign
      buf_parts-supp.orig-in-code   = p-orig-in-code
      buf_parts-supp.orig-part-code = p-orig-part-code
    .
    find first buf_orig_parts-supp share-lock
      where buf_orig_parts-supp.in-code   = p-orig-in-code
        and buf_orig_parts-supp.artic     = p-artic
        and buf_orig_parts-supp.prod-type = p-prod-type
        and buf_orig_parts-supp.prod-code = p-prod-code
        and buf_orig_parts-supp.part-code = p-orig-part-code
      no-error .
    if available buf_orig_parts-supp
    then do:
      buffer-copy buf_orig_parts-supp
      except
        buf_orig_parts-supp.in-code
        buf_orig_parts-supp.artic
        buf_orig_parts-supp.prod-type
        buf_orig_parts-supp.prod-code
        buf_orig_parts-supp.part-code
        buf_orig_parts-supp.orig-in-code
        buf_orig_parts-supp.orig-part-code
      to buf_parts-supp.
    end.
    else do:
      find first buf_parts share-lock
        where buf_parts.obj-type  = buf_parent_trn-doc.obj-type
          and buf_parts.obj-code  = buf_parent_trn-doc.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.in-code   = p-orig-in-code
          and buf_parts.out-code  = buf_parent_trn-doc.doc-code
          and buf_parts.part-code = p-orig-part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info60 skip
          "Ошибка задания входных параметров" skip
          "Не найдена исходная партия" skip
          "Исходный документ" p-orig-in-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код партии" p-orig-part-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-base-rate         as decimal   no-undo .
      define variable v-base-scale        as integer   no-undo .
      define variable v-exch-rate         as decimal   no-undo .
      define variable v-exch-scale        as integer   no-undo .
      define variable v-extended-doc-type as character no-undo .
      define variable v-unit-cli          as character no-undo .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = p-orig-in-code
        no-error .
      if available buf_income_trn-doc
      then do:
        find first buf_income_doc-line no-lock
          where buf_income_doc-line.doc-code  = p-orig-in-code
            and buf_income_doc-line.artic     = p-artic
            and buf_income_doc-line.prod-type = p-prod-type
            and buf_income_doc-line.prod-code = p-prod-code
          no-error .
        if not available buf_income_doc-line
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info60 skip
            "Не найдена исходная строка документа прихода" skip
            "Исходный документ" p-orig-in-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код партии" p-orig-part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-base-rate         = buf_income_trn-doc.base-rate
          v-base-scale        = buf_income_trn-doc.base-scale
          v-exch-rate         = buf_income_trn-doc.exch-rate
          v-exch-scale        = buf_income_trn-doc.exch-scale
          v-extended-doc-type = buf_income_trn-doc.ext-doc-type
          v-unit-cli          = buf_income_doc-line.unit-cli
        .
      end.
      else do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
        assign
          v-base-rate         = buf_parts.price-rubl / buf_parts.price-base
          v-base-scale        = 1
          v-exch-rate         = buf_parts.price-rubl / (buf_parts.price-cli * buf_parts.cli-base-rate)
          v-exch-scale        = 1
          v-extended-doc-type = 'ie':U
          v-unit-cli          = buf_goods.unit-cli
        .
      end.
       if v-base-rate = ? then v-base-rate = 1.
       if v-exch-rate = ? then v-exch-rate = 1.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        buf_parts-supp.PS                = buf_parts.PS
        buf_parts-supp.SLT-type          = buf_parts.SLT-type
        buf_parts-supp.VAT-type          = buf_parts.VAT-type
        buf_parts-supp.base-rate         = v-base-rate
        buf_parts-supp.base-scale        = v-base-scale
        buf_parts-supp.cli-qnty          = buf_parts.cli-qnty
        buf_parts-supp.cst-code          = buf_parts.cst-code
        buf_parts-supp.doc-qnty          = buf_parts.qnty
        buf_parts-supp.exch-code         = buf_parts.exch-code
        buf_parts-supp.exch-rate         = v-exch-rate
        buf_parts-supp.exch-scale        = v-exch-scale
        buf_parts-supp.extended-doc-type = v-extended-doc-type
        buf_parts-supp.fact-date         = buf_parts.fact-date
        buf_parts-supp.fact-qnty         = buf_parts.fact-qnty
        buf_parts-supp.last-date         = buf_parts.last-date
        buf_parts-supp.pay-code          = buf_parts.pay-code
        buf_parts-supp.price-cli         = buf_parts.price-cli
        buf_parts-supp.purch-code        = buf_parts.purch-code
        buf_parts-supp.supp-code         = buf_parts.supp-code
        buf_parts-supp.supp-type         = buf_parts.supp-type
        buf_parts-supp.unit-cli          = v-unit-cli
      .
      assign
        buf_parts-supp.vat-pc         = vat-pc-loc
        buf_parts-supp.slt-pc         = slt-pc-loc
        buf_parts-supp.price-base     = price-base-with-tax-loc
        buf_parts-supp.price-rubl     = price-rubl-with-tax-loc
        buf_parts-supp.vat-base       = vat-base-loc
        buf_parts-supp.vat-rubl       = vat-rubl-loc
        buf_parts-supp.slt-base       = slt-base-loc
        buf_parts-supp.slt-rubl       = slt-rubl-loc
        buf_parts-supp.road-tax-base  = road-tax-base-loc
        buf_parts-supp.road-tax-rubl  = road-tax-rubl-loc
        buf_parts-supp.transport-base = transport-base-loc
        buf_parts-supp.transport-rubl = transport-rubl-loc
        buf_parts-supp.other-base     = other-base-loc
        buf_parts-supp.other-rubl     = other-rubl-loc
      .
    end.
  end.
end procedure.
procedure holdprts-get-part-code :
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-hold-part-code as integer   no-undo .
  define variable vss-description as character no-undo init "holdprts-get-part-code-01: создать уникальный код партии внутри документа".
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'hold-part-code':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    assign
      p-hold-part-code = integer(v-attr-value) + 1
    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'hold-part-code':U ,
                       input string(p-hold-part-code) )  .
  end.
end procedure.
procedure holdprts-validate-document :
  define input  parameter p-doc-code as character no-undo .
  define variable vss-description as character no-undo init "holdprts-validate-document-01: проверить правильность документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer parent_trn-doc for ub.trn-doc .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-supp for ub.parts-supp .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first parent_trn-doc exclusive-lock
      where parent_trn-doc.doc-code = buf_trn-doc.hold-doc-code-parent
      no-error .
    if not available parent_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Не найден родительский документ" skip
        "Документ" buf_trn-doc.doc-code skip
        "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> 'ie':U
    then do:
      return .
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts-supp share-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info60 skip
          "Не найдена информация о поставщике" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts-supp share-lock
      where buf_parts-supp.in-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts share-lock
        where buf_parts.out-code  = buf_parts-supp.in-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_parts-supp.artic
          and buf_parts.prod-type = buf_parts-supp.prod-type
          and buf_parts.prod-code = buf_parts-supp.prod-code
          and buf_parts.part-code = buf_parts-supp.part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info60 skip
          "Задана информация о поставщике для неизвестной партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.hold-doc-code-parent
    on error undo, return error
    :
      if  buf_trn-doc.doc-type = 'при':U
      and buf_parts.qnty = buf_parts.fact-qnty
      then do:
        next.
      end.
      find first buf_parts-supp share-lock
        where buf_parts-supp.orig-in-code   = buf_parts.in-code
          and buf_parts-supp.artic          = buf_parts.artic
          and buf_parts-supp.prod-type      = buf_parts.prod-type
          and buf_parts-supp.prod-code      = buf_parts.prod-code
          and buf_parts-supp.orig-part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info60 skip
          "Не найдена информация о поставщике для исходной накладной" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure holdprts-doc-type :
  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-is-sale  as logical   no-undo .
  define output parameter p-is-purch as logical   no-undo .
  define variable vss-description as character no-undo init "holdprts-doc-type-01: определение типа документа для межфирменного архива".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Тип архива" p-cat-code skip
        view-as alert-box error .
      undo, return error .
    end.
    case p-cat-code :
      when 1
      then do:
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            p-is-sale  = false
            p-is-purch = false
          .
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ie':U or
            when 'ep':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = true
              .
            end.
            when 'ee':U or
            when 'es':U or
            when 're':U or
            when 'rs':U
            then do:
              assign
                p-is-sale  = true
                p-is-purch = false
              .
            end.
            when 'we':U or
            when 'vt':U or
            when 'vp':U or
            when 'ap':U or
            when 'mp':U or
            when 'pc':U or
            when 'iv':U or
            when 'ev':U or
            when 'io':U or
            when 'eo':U or
            when 'rv':U or
            when 'em':U or
            when 'wm':U or
            when 'im':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = false
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info60 skip
                "Неизвестный тип документа" skip
                "Документ" buf_trn-doc.doc-code skip
                "Тип документа" buf_trn-doc.ext-doc-type skip
                "Тип архива" p-cat-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      when 2
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'vt':U or
          when 'vp':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      when 3
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'we':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип архивов" skip
          "Документ" buf_trn-doc.doc-code skip
          "Тип документа" buf_trn-doc.ext-doc-type skip
          "Тип архива" p-cat-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure holdprts-purch-values :
  define input  parameter p-doc-code             like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic                like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type            like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code            like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty            as decimal   no-undo .
  define output parameter p-purch-sum-base       as decimal   no-undo .
  define output parameter p-purch-sum-rubl       as decimal   no-undo .
  define output parameter p-purch-VAT-base       as decimal   no-undo .
  define output parameter p-purch-VAT-rubl       as decimal   no-undo .
  define output parameter p-purch-SLT-base       as decimal   no-undo .
  define output parameter p-purch-SLT-rubl       as decimal   no-undo .
  define output parameter p-purch-road-tax-base  as decimal   no-undo .
  define output parameter p-purch-road-tax-rubl  as decimal   no-undo .
  define output parameter p-purch-excise-base    as decimal   no-undo .
  define output parameter p-purch-excise-rubl    as decimal   no-undo .
  define output parameter p-purch-transport-base as decimal   no-undo .
  define output parameter p-purch-transport-rubl as decimal   no-undo .
  define output parameter p-purch-other-base     as decimal   no-undo .
  define output parameter p-purch-other-rubl     as decimal   no-undo .
  define output parameter p-purch-discnt-base    as decimal   no-undo .
  define output parameter p-purch-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-purch-values-01: параметры закупки товара".
  define variable v-price-base     as decimal   no-undo .
  define variable v-price-rubl     as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_parts          for ub.parts .
  define buffer buf_parts-supp     for ub.parts-supp .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_income_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-fact-qnty            = 0
      p-purch-sum-base       = 0
      p-purch-sum-rubl       = 0
      p-purch-VAT-base       = 0
      p-purch-VAT-rubl       = 0
      p-purch-SLT-base       = 0
      p-purch-SLT-rubl       = 0
      p-purch-road-tax-base  = 0
      p-purch-road-tax-rubl  = 0
      p-purch-excise-base    = 0
      p-purch-excise-rubl    = 0
      p-purch-transport-base = 0
      p-purch-transport-rubl = 0
      p-purch-other-base     = 0
      p-purch-other-rubl     = 0
      p-purch-discnt-base    = 0
      p-purch-discnt-rubl    = 0
    .
    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      define variable v-parts-qnty as decimal   no-undo .
      assign
        v-parts-qnty = buf_parts.fact-qnty
                     * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                         then -1
                         else 1
                       )
      .
      find first buf_parts-supp no-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-supp
      then do:
        assign
          v-price-base     = buf_parts-supp.price-base
          v-price-rubl     = buf_parts-supp.price-rubl
          v-VAT-base       = buf_parts-supp.VAT-base
          v-VAT-rubl       = buf_parts-supp.VAT-rubl
          v-SLT-base       = buf_parts-supp.SLT-base
          v-SLT-rubl       = buf_parts-supp.SLT-rubl
          v-road-tax-base  = buf_parts-supp.road-tax-base
          v-road-tax-rubl  = buf_parts-supp.road-tax-rubl
          v-transport-base = buf_parts-supp.transport-base
          v-transport-rubl = buf_parts-supp.transport-rubl
          v-other-base     = buf_parts-supp.other-base
          v-other-rubl     = buf_parts-supp.other-rubl
        .
      end.
      else do:
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
          v-price-base     = price-base-with-tax-loc
          v-price-rubl     = price-rubl-with-tax-loc
          v-VAT-base       = vat-base-loc
          v-VAT-rubl       = vat-rubl-loc
          v-SLT-base       = slt-base-loc
          v-SLT-rubl       = slt-rubl-loc
          v-road-tax-base  = road-tax-base-loc
          v-road-tax-rubl  = road-tax-rubl-loc
          v-transport-base = transport-base-loc
          v-transport-rubl = transport-rubl-loc
          v-other-base     = other-base-loc
          v-other-rubl     = other-rubl-loc
        .
      end.
      assign
        p-fact-qnty            = p-fact-qnty            + v-parts-qnty
        p-purch-sum-base       = p-purch-sum-base       + v-price-base     * v-parts-qnty
        p-purch-sum-rubl       = p-purch-sum-rubl       + v-price-rubl     * v-parts-qnty
        p-purch-VAT-base       = p-purch-VAT-base       + v-VAT-base       * v-parts-qnty
        p-purch-VAT-rubl       = p-purch-VAT-rubl       + v-VAT-rubl       * v-parts-qnty
        p-purch-SLT-base       = p-purch-SLT-base       + v-SLT-base       * v-parts-qnty
        p-purch-SLT-rubl       = p-purch-SLT-rubl       + v-SLT-rubl       * v-parts-qnty
        p-purch-road-tax-base  = p-purch-road-tax-base  + v-road-tax-base  * v-parts-qnty
        p-purch-road-tax-rubl  = p-purch-road-tax-rubl  + v-road-tax-rubl  * v-parts-qnty
        p-purch-excise-base    = p-purch-excise-base    + 0
        p-purch-excise-rubl    = p-purch-excise-rubl    + 0
        p-purch-transport-base = p-purch-transport-base + v-transport-base * v-parts-qnty
        p-purch-transport-rubl = p-purch-transport-rubl + v-transport-rubl * v-parts-qnty
        p-purch-other-base     = p-purch-other-base     + v-other-base     * v-parts-qnty
        p-purch-other-rubl     = p-purch-other-rubl     + v-other-rubl     * v-parts-qnty
        p-purch-discnt-base    = p-purch-discnt-base    + 0
        p-purch-discnt-rubl    = p-purch-discnt-rubl    + 0
      .
    end.
  end.
end procedure.
procedure holdprts-sale-values :
  define input  parameter p-doc-code            like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic               like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type           like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code           like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty           as decimal   no-undo .
  define output parameter p-sale-sum-base       as decimal   no-undo .
  define output parameter p-sale-sum-rubl       as decimal   no-undo .
  define output parameter p-sale-VAT-base       as decimal   no-undo .
  define output parameter p-sale-VAT-rubl       as decimal   no-undo .
  define output parameter p-sale-SLT-base       as decimal   no-undo .
  define output parameter p-sale-SLT-rubl       as decimal   no-undo .
  define output parameter p-sale-road-tax-base  as decimal   no-undo .
  define output parameter p-sale-road-tax-rubl  as decimal   no-undo .
  define output parameter p-sale-excise-base    as decimal   no-undo .
  define output parameter p-sale-excise-rubl    as decimal   no-undo .
  define output parameter p-sale-transport-base as decimal   no-undo .
  define output parameter p-sale-transport-rubl as decimal   no-undo .
  define output parameter p-sale-other-base     as decimal   no-undo .
  define output parameter p-sale-other-rubl     as decimal   no-undo .
  define output parameter p-sale-discnt-base    as decimal   no-undo .
  define output parameter p-sale-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-sale-values-01: параметры продажи товара".
  define variable v-gds-dtl-fact-qnty as decimal   no-undo .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer buf_trn-doc  for ub.trn-doc.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info60 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> 'инв':U
      then do:
        if buf_trn-doc.doc-type = 'при':U
        or buf_trn-doc.doc-type = 'возврат':U
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.
      if v-gds-dtl-fact-qnty <> 0
      then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
          p-fact-qnty           = p-fact-qnty          + v-gds-dtl-fact-qnty
          p-sale-sum-base       = p-sale-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-sum-rubl       = p-sale-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-vat-base       = p-sale-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
          p-sale-vat-rubl       = p-sale-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-base       = p-sale-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-rubl       = p-sale-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-road-tax-base  = p-sale-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
          p-sale-road-tax-rubl  = p-sale-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
          p-sale-excise-base    = p-sale-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
          p-sale-excise-rubl    = p-sale-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-base    = p-sale-discnt-base   + discnt-base-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-rubl    = p-sale-discnt-rubl   + discnt-rubl-sale          * v-gds-dtl-fact-qnty
        .
      end.
    end.
    assign
      p-sale-transport-base = 0
      p-sale-transport-rubl = 0
      p-sale-other-base     = 0
      p-sale-other-rubl     = 0
    .
  end.
end procedure.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ Список партий для резервирования".
define variable v-partlist-use       as logical   no-undo .
define variable v-partlist-total-num as integer   no-undo .
define temp-table temp-part-list no-undo
  field ord-num   as integer
  field in-code   as character
  field part-code as character
  field qnty      as decimal
  index xpk is primary unique ord-num
  index ie1 in-code part-code
  .
procedure partlist_clear :
  define buffer buf_temp-part-list for temp-part-list .
  do
  on error undo, return error return-value
  :
    assign
      v-partlist-total-num = 0
    .
    for each buf_temp-part-list
    on error undo, return error return-value
    :
      delete buf_temp-part-list .
    end.
  end.
end procedure.
procedure partlist_use-set :
  define input  parameter p-use as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-partlist-use = p-use
    .
  end.
end procedure.
procedure partlist_use-get :
  define output parameter p-use as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-use = v-partlist-use
    .
  end.
end procedure.
procedure partlist_append_part :
  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-part-code as character no-undo .
  define input  parameter p-qnty      as decimal   no-undo .
  define buffer buf_temp-part-list for temp-part-list .
  do
  on error undo, return error return-value
  :
    assign
      v-partlist-total-num = v-partlist-total-num + 1
    .
    create buf_temp-part-list .
    assign
      buf_temp-part-list.ord-num   = v-partlist-total-num
      buf_temp-part-list.in-code   = p-in-code
      buf_temp-part-list.part-code = p-part-code
      buf_temp-part-list.qnty      = p-qnty
    .
  end.
end procedure.
procedure partlist_get-total-num :
  define output parameter p-total-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-total-num = v-partlist-total-num
    .
  end.
end procedure.
procedure partlist_get-part-qnty :
  define input  parameter p-ord-num   as integer   no-undo .
  define output parameter p-in-code   as character no-undo .
  define output parameter p-part-code as character no-undo .
  define output parameter p-qnty      as decimal   no-undo .
  define buffer buf_temp-part-list for temp-part-list .
  do
  on error undo, return error return-value
  :
    find first buf_temp-part-list
      where buf_temp-part-list.ord-num = p-ord-num
      no-error .
    if not available buf_temp-part-list
    then do:
      undo, return error substitute("Не найдена партия с номером &1. Текущее количество партий &2"
                                   ,p-ord-num
                                   ,v-partlist-total-num
                                   )
        .
    end.
    assign
      p-in-code   = buf_temp-part-list.in-code
      p-part-code = buf_temp-part-list.part-code
      p-qnty      = buf_temp-part-list.qnty
    .
  end.
end procedure.
procedure partlist_check-part-qnty :
  define input  parameter p-in-code    as character no-undo .
  define input  parameter p-part-code  as character no-undo .
  define output parameter p-part-qnty  as decimal   no-undo .
  define buffer buf_temp-part-list for temp-part-list .
  do
  on error undo, return error return-value
  :
    find first buf_temp-part-list
      where buf_temp-part-list.in-code   = p-in-code
        and buf_temp-part-list.part-code = p-part-code
      no-error .
    if available buf_temp-part-list
    then do:
      assign
        p-part-qnty = buf_temp-part-list.qnty
      .
    end.
    else do:
      assign
        p-part-qnty = 0
      .
    end.
  end.
end procedure.
define variable v-obj-type   like ub.gds-dtl.obj-type  no-undo .
define variable v-obj-code   like ub.gds-dtl.obj-code  no-undo .
define variable v-doc-code   like ub.gds-dtl.doc-code  no-undo .
define variable v-artic      like ub.gds-dtl.artic     no-undo .
define variable v-prod-type  like ub.gds-dtl.prod-type no-undo .
define variable v-prod-code  like ub.gds-dtl.prod-code no-undo .
define variable v-prt-code   like ub.gds-dtl.prt-code  no-undo .
define variable v-cli-qnty   like ub.doc-line.cli-qnty no-undo initial ? .
define variable v-input-qnty as decimal   no-undo .
define variable chg-cli-qnty as decimal   no-undo .
define variable v-option-no-message    as logical   no-undo initial false .
define variable v-partscr-prompt-price as character no-undo .
define variable v-rename-part-code     as logical   no-undo init false .
define variable v-old-part-code        as character no-undo .
define variable v-create-part-code     as character no-undo initial "" .
define variable was-created-part-code  as logical   no-undo initial ? .
define variable v-create-cst-code      as character no-undo initial "" .
define variable v-create-ps            as character no-undo init "" .
define variable v-create-dop           as character no-undo init "" .
define variable v-partsupd-action      as character no-undo initial "" .
define variable v-contract-code        as integer   no-undo .
define variable v-reserv-single-part   as logical   no-undo .
define variable v-in-code              as character no-undo .
define variable v-part-code            as character no-undo .
define variable v-pl-code              as integer   no-undo initial 0 .
define variable v-hold-code-parent     as character no-undo .
define variable v-hold-part-code       as character no-undo .
define variable v-purch-code-list      as character no-undo .
define variable v-use-partlist         as logical   no-undo .
define variable v-last-date            as date      no-undo .
define variable v-hold-date            as date      no-undo .
define variable v-negative-check       as integer   no-undo initial 0 .
define variable v-option-sale-negative-check-on as logical no-undo init false .
define variable v-error-message        as character no-undo .
define variable v-real-chg-qnty        as decimal   no-undo .
define variable v-need-rsrv            as logical no-undo .
define variable v-neg-ask as logical   no-undo .
define variable v-mark                 as logical no-undo .
do
on error undo, return error return-value
:
  define variable v-root-node          like ub.gds-prt.node-code no-undo .
  define variable v-goods-serial       as logical no-undo .
  define variable v-goods-twounit      as logical no-undo .
  define variable v-reserv-pl-code     as logical no-undo initial ? .
  define variable v-density            as decimal no-undo .
  define variable v-sign               as decimal no-undo .
  define buffer buf_doc-pl for ub.doc-pl .
  if (valid-handle(parparentproc) <> true)
  or lookup( "mainmenu_getcntxt", parparentproc:internal-entries ) = 0
  then do:
        assign
        v-cntxt-db-num = g#db-num
        v-cntxt-userid = g#userid
        .
  end.
  else do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  end.
  if not available rsrv-gds-dtl
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задан буфер признака строки (gds-dtl)" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-doc-code   = rsrv-gds-dtl.doc-code
    v-artic      = rsrv-gds-dtl.artic
    v-prod-type  = rsrv-gds-dtl.prod-type
    v-prod-code  = rsrv-gds-dtl.prod-code
    v-prt-code   = rsrv-gds-dtl.prt-code
    v-input-qnty = chg-qnty
  .
  find ub.trn-doc no-lock
    where ub.trn-doc.doc-code = v-doc-code
    no-error .
  if not available ub.trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-obj-type  = ub.trn-doc.obj-type
    v-obj-code  = ub.trn-doc.obj-code
  .
  v-mark = yes .
  run check-input-parameters in this-procedure
    ( buffer ub.trn-doc
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке входных параметров" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  define variable first-qnty as decimal no-undo .
  find ub.goods no-lock
    where ub.goods.artic     = v-artic
      and ub.goods.prod-type = v-prod-type
      and ub.goods.prod-code = v-prod-code
    no-error .
  if not available ub.goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись товар" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if ub.goods.cost-calc <> 'FIFO':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Механизм расчета учетной цены товара отличается от" 'FIFO':U skip
      "Резервирование товара недопустимо" skip
      "Документ" v-doc-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Метод расчета" ub.goods.cost-calc skip
      view-as alert-box error .
    assign
      chg-qnty = 0
    .
    undo, return error return-value .
  end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,input  'serial=request':u
  ,output v-goods-serial
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      'serial=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  ub.goods.artic
  ,input  ub.goods.prod-type
  ,input  ub.goods.prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      'twounit=request':u skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,output v-root-node
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении корневого признака" skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,input  v-root-node
  ,buffer ub.gds-obj
  ,buffer ub.prt-obj
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании информации о товаре на фирме" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if not v-mark then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input v-obj-type
  ,input v-obj-code
  ,input v-artic
  ,input v-prod-type
  ,input v-prod-code
  ,input v-root-node
  ,input ''
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" v-obj-type v-obj-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Проверка целостности товара до резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  end.
  find ub.doc-line no-lock
    where ub.doc-line.doc-code  = v-doc-code
      and ub.doc-line.artic     = v-artic
      and ub.doc-line.prod-type = v-prod-type
      and ub.doc-line.prod-code = v-prod-code
    .
  define variable v-reserv-base as decimal no-undo initial 0 .
  define variable v-reserv-rubl as decimal no-undo initial 0 .
  if ub.trn-doc.status_ = 'запрос':U
  then do:
    return .
  end.
  if ub.trn-doc.doc-type = 'при':U
  and (ub.trn-doc.internal = no
        or (ub.trn-doc.internal        = yes
            and ub.trn-doc.discnt-type = 'прво':U
          )
      )
  and cost-base > 0
  and cost-rubl > 0
  then do:
    assign
      v-reserv-base = cost-base
      v-reserv-rubl = cost-rubl
    .
  end.
  else do:
    if ub.goods.gds-type <> 'т':U
    then do:
      assign
        v-reserv-base = ub.gds-obj.price-base
        v-reserv-rubl = ub.gds-obj.price-rubl
      .
    end.
    else do:
      if  ub.gds-obj.last-base > 0
      and ub.gds-obj.last-rubl > 0
      then do:
        assign
          v-reserv-base = ub.gds-obj.last-base
          v-reserv-rubl = ub.gds-obj.last-rubl
        .
      end.
    end.
  end.
  if v-reserv-base = ?
  then do:
    assign
      v-reserv-base = 0
    .
  end.
  if v-reserv-rubl = ?
  then do:
    assign
      v-reserv-rubl = 0
    .
  end.
  if ub.trn-doc.ext-doc-type <> 'vt':U
  then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitqnty in g#library
  (input ''
  ,input ub.goods.artic
  ,input ub.goods.prod-type
  ,input ub.goods.prod-code
  ,input ''
  ,input chg-qnty
  ) no-error .
    if error-status :error
    then do:
      if v-option-no-message = false
      then do:
        message
          "Не прошел контроль количества товара" skip
          "Попробуйте ввести другое количество" skip
          "Для штучного и серийного товаров резервируемое количество должно быть целым" skip
          "Документ" v-doc-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          ub.goods.gds-name skip
          "Запрошено количество для резервирования" chg-qnty skip
          view-as alert-box information .
      end.
      assign
        chg-qnty = 0
      .
      return .
    end.
  end.
  if  ub.trn-doc.doc-type = 'при':U
  and ub.trn-doc.internal = no
  then do:
    if  v-rename-part-code = true
    and v-old-part-code <> v-create-part-code
    then do:
      run rename-part-code in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input ub.doc-line.doc-code
        ,input ub.doc-line.doc-code
        ,input v-old-part-code
        ,input v-create-part-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры rename-part-code" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    run trg/partsupd.p
      (input parparentproc
      ,input ub.doc-line.doc-code
      ,input ub.doc-line.obj-type
      ,input ub.doc-line.obj-code
      ,input ub.doc-line.artic
      ,input ub.doc-line.prod-type
      ,input ub.doc-line.prod-code
      ,input false
      ,input v-partsupd-action
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  if  chg-qnty = 0
  and p-action = 'reserv':U
  and v-goods-twounit = false
  then do:
    run cost-calc in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка расчета средней учетной цены" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    return .
  end.
  define variable v-can-edit-inv-on as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnat in g#library
  (input  ub.trn-doc.doc-type
  ,input  ub.trn-doc.internal
  ,input  ub.trn-doc.discnt-type
  ,input  ub.trn-doc.status_
  ,input  ub.trn-doc.flag_
  ,input  ub.trn-doc.ext-doc-type
  ,input  'can-edit-inv-on=request'
  ,output v-can-edit-inv-on
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак складского документа" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-can-edit-inv-on <> "true":u
  then do:
    define variable v-inv-on as logical no-undo .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,input  'inv-on=request'
  ,output v-inv-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признаки товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-inv-on = true
    then do:
      if v-option-no-message = false
      then do:
        message
          "Артикул" v-artic v-prod-type v-prod-code skip
          ub.goods.gds-name skip
          "сейчас находится в инвентаризации" skip
          "Редактирование резервов невозможно" skip
          view-as alert-box .
      end.
      assign
        chg-qnty = 0
      .
      return .
    end.
  end.
  if ub.goods.gds-type <> 'т':U
  then do:
    if  v-reserv-base > 0
    and v-reserv-rubl > 0
    then do:
      assign
        cost-base = v-reserv-base
        cost-rubl = v-reserv-rubl
      .
      return .
    end.
    else do:
      if v-option-no-message = false
      then do:
        message
          "Не определена учетная цена для услуги." skip
          "Артикул" ub.goods.artic ub.goods.gds-name skip
          "производитель" ub.goods.prod-type ub.goods.prod-code skip
          "Резервирование услуги с нулевой учетной ценой невозможно." skip
          view-as alert-box information .
      end.
      assign
        chg-qnty = 0
      .
      undo, return error "Не определена учетная цена для услуги." + chr(10)
                        + substitute("Артикул &1 &2", ub.goods.artic, ub.goods.gds-name) + chr(10)
                        + substitute("производитель &1 &2", ub.goods.prod-type, ub.goods.prod-code) + chr(10)
                        + "Резервирование услуги с нулевой учетной ценой невозможно." + chr(10)
        .
    end.
  end.
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
    define variable v-new-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-new-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-new-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-new-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-new-total-parts-price-cli      as decimal no-undo .   define variable v-new-total-parts-price-base     as decimal no-undo .   define variable v-new-total-parts-price-rubl     as decimal no-undo .   define variable v-new-total-parts-transport-base as decimal no-undo .   define variable v-new-total-parts-transport-rubl as decimal no-undo .   define variable v-new-total-parts-other-base     as decimal no-undo .   define variable v-new-total-parts-other-rubl     as decimal no-undo .
  define variable v-free-parts-qnty       as decimal no-undo .
  define variable v-free-parts-fact-qnty  as decimal no-undo .
  define variable v-free-parts-cli-qnty   as decimal no-undo .
  define variable v-free-parts-price-base as decimal no-undo .
  define variable v-free-parts-price-rubl as decimal no-undo .
  define variable v-out-parts-qnty        as decimal no-undo .
  define variable v-out-parts-fact-qnty   as decimal no-undo .
  define variable v-out-parts-cli-qnty    as decimal no-undo .
  define variable v-out-parts-price-base  as decimal no-undo .
  define variable v-out-parts-price-rubl  as decimal no-undo .
  define variable v-new-free-parts-qnty       as decimal no-undo .
  define variable v-new-free-parts-fact-qnty  as decimal no-undo .
  define variable v-new-free-parts-cli-qnty   as decimal no-undo .
  define variable v-new-free-parts-price-base as decimal no-undo .
  define variable v-new-free-parts-price-rubl as decimal no-undo .
  define variable v-new-out-parts-qnty        as decimal no-undo .
  define variable v-new-out-parts-fact-qnty   as decimal no-undo .
  define variable v-new-out-parts-cli-qnty    as decimal no-undo .
  define variable v-new-out-parts-price-base  as decimal no-undo .
  define variable v-new-out-parts-price-rubl  as decimal no-undo .
  assign
    first-qnty = chg-qnty
  .
  define variable free-prt      as decimal no-undo .
  case p-action :
    when 'reserv':U
    then do:
      run partrqst in this-procedure
        (input  ub.doc-line.doc-code
        ,input  ub.doc-line.obj-type
        ,input  ub.doc-line.obj-code
        ,input  ub.doc-line.artic
        ,input  ub.doc-line.prod-type
        ,input  ub.doc-line.prod-code
                ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при сборе информации по партиям" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run rsrgdsck in this-procedure
        (input  ub.doc-line.doc-code
        ,input  ub.trn-doc.doc-type
        ,input  ub.doc-line.obj-type
        ,input  ub.doc-line.obj-code
        ,input  ub.doc-line.artic
        ,input  ub.doc-line.prod-type
        ,input  ub.doc-line.prod-code
        ,output v-free-parts-qnty
        ,output v-free-parts-fact-qnty
        ,output v-free-parts-cli-qnty
        ,output v-free-parts-price-base
        ,output v-free-parts-price-rubl
        ,output v-out-parts-qnty
        ,output v-out-parts-fact-qnty
        ,output v-out-parts-cli-qnty
        ,output v-out-parts-price-base
        ,output v-out-parts-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке зарезервированных количеств" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if can-do('рас,спи':U, ub.trn-doc.doc-type)
      and ub.goods.gds-type       = 'т':U
      and ((ub.trn-doc.status_    = 'накл':U
            and ub.trn-doc.flag_  = no)
            or ub.trn-doc.status_ = 'касс':U
          )
      then do:
        define variable v-need-check-free-qnty as logical no-undo .
        assign
          v-need-check-free-qnty = (ub.trn-doc.discnt-type <> 'касс':U
                                    or
                                    v-option-sale-negative-check-on
                                    )
        .
        if v-need-check-free-qnty
        then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,input  v-prt-code
  ,buffer ub.prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно найти признак на объекте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            free-prt = ub.prt-obj.free-qnty
          .
          if free-prt < first-qnty
          then do:
            define variable v-action as integer no-undo .
            if first-qnty > 0
            then do:
              assign
                v-action = 3
              .
            end.
            else do:
              assign
                v-action = 1
              .
            end.
            define variable v-can-fix        as logical no-undo .
            define variable v-fix-first-qnty as decimal no-undo .
            assign
              v-can-fix        = false
              v-fix-first-qnty = 0
            .
            if  free-prt < 0
            and v-total-parts-fact-qnty > abs(free-prt)
            then do:
              assign
                v-action         = 2
                v-can-fix        = true
                v-fix-first-qnty = free-prt
              .
            end.
            if  free-prt   >= 0
            and first-qnty >= 0
            then do:
              assign
                v-action         = 2
                v-can-fix        = true
                v-fix-first-qnty = min(free-prt, first-qnty)
              .
            end.
            if ub.goods.negative-rest = true
            then do:
              if v-negative-check = 0
              then do:
                run gbl/d-askw.w
                  (input  "Проверка отрицательных остатков"
                  ,input  "Артикул " + string(ub.goods.artic) + " "
                            + string(ub.goods.prod-type) + " " + string(ub.goods.prod-code) + chr(10)
                          + string(ub.goods.gds-name) + chr(10)
                          + "Свободно " + string(free-prt) + chr(10)
                          + "После резервирования товар уйдет в отрицательные остатки" + chr(10)
                          + substitute("Объект &1 &2", v-obj-type, v-obj-code) + chr(10)
                  ,input "|^"
                  ,input  "Резерв" + "|"
                          + "Положительное"
                            + (if v-can-fix then "" else "^disable") + "|"
                          + "Отмена"
                  ,input  "Зарезервировать " + string(first-qnty) + chr(10)
                            + "После резервирования:" + chr(10)
                            + " Свободное количество составит "
                            + string(free-prt - first-qnty) + chr(10)
                            + " Количество по документу составит "
                            + string(v-total-parts-fact-qnty + first-qnty)
                            + "|"
                          + (if v-can-fix then
                              "Зарезервировать " + string(v-fix-first-qnty) + chr(10)
                              + "После резервирования:" + chr(10)
                              + "Свободное количество составит "
                              + string(free-prt - v-fix-first-qnty) + chr(10)
                              + "Количество по документу составит "
                              + string(v-total-parts-fact-qnty + v-fix-first-qnty)
                              else "Даже если удалить строчку документа" + chr(10)
                                  + "свободное количество будет отрицательным" ) + "|"
                          + "Отмена резервирования" + chr(10)
                            + "Свободное количество составит "
                            + string(free-prt) + chr(10)
                            + "Количество по документу составит "
                            + string(v-total-parts-fact-qnty)
                  ,input 2
                  ,input 3
                  ,output v-action
                  ).
              end.
              else do:
                case v-negative-check
                :
                  when 1
                  then do:
                    assign
                      v-action = 1
                    .
                  end.
                  when 2
                  then do:
                    if v-can-fix = true
                    then do:
                      assign
                        v-action = 2
                      .
                    end.
                    else do:
                      assign
                        v-action = 3
                      .
                    end.
                  end.
                  when 3
                  then do:
                    assign
                      v-action = 3
                    .
                  end.
                  otherwise do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Внутренняя ошибка" skip
                      "Неизвестное значение v-negative-check" v-negative-check skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                end.
              end.
            end.
            else do:
              if v-action = 2 and first-qnty <> v-fix-first-qnty then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ub.trn-doc.obj-type
  ,input ub.trn-doc.obj-code
  ,input 'nakl_par':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
                      for each thbjattr_thbj-attr :
                          if thbjattr_thbj-attr.prop-code = 'neg-ask' then v-neg-ask = thbjattr_thbj-attr.property-value-logical .
                      end.
                  if v-neg-ask = true then do:
                     message "По товару запрещены отрицательные остатки, "  Skip
                     "нельзя зарезирвировать полностью указанное количество!"
                     view-as alert-box information .
                  end.
              end.
            end.
            case v-action :
              when 1
              then do:
              end.
              when 2
              then do:
                assign
                  first-qnty = v-fix-first-qnty
                .
              end.
              when 3
              then do:
                assign
                  first-qnty = 0
                .
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестное значение переменной v-action" v-action skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
          end.
        end.
      end.
      assign
        chg-qnty = first-qnty
      .
      define variable v-rsrv-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rsrvtype in g#library
  (input  ub.trn-doc.doc-code
  ,output v-rsrv-type
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа резервирования" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      case v-rsrv-type :
        when 'rsrv-pri-doc':U
        then do:
          run rsrv-pri-doc in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-pri-doc" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when 'rsrv-pri-fact':U
        then do:
          run rsrv-pri-fact in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-pri-fact" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when 'rsrv-doc':U
        then do:
          if v-reserv-pl-code = ?
          then do:
            run plgdsfnd in this-procedure
              (input  true
              ,input  v-obj-type
              ,input  v-obj-code
              ,input  ub.goods.gds-code
              ,output v-reserv-pl-code
              ,output v-pl-code
              ) no-error .
            if error-status :error
            then do:
              if error-status :get-message(1) <> ""
              or v-option-no-message = false
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при вызове процедуры plgdsfnd" skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
              undo, return error return-value .
            end.
          end.
          run rsrv-doc in this-procedure
            (input  parparentproc
            ,input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  recid(ub.trn-doc)
            ,input  recid(ub.doc-line)
            ,input  v-reserv-base
            ,input  v-reserv-rubl
            ,input  v-partscr-prompt-price
            ,input  ub.trn-doc.ext-doc-type
            ,input  v-reserv-single-part
            ,input  v-in-code
            ,input  v-part-code
            ,input  v-reserv-pl-code
            ,input  v-pl-code
            ,input  v-goods-serial
            ,input  v-goods-twounit
            ,input  v-purch-code-list
            ,input  chg-qnty
            ,input  (ub.trn-doc.doc-type = 'инв':U)
            ,output v-real-chg-qnty
            ) no-error .
          if error-status :error
          then do:
            if error-status :get-message(1) <> ""
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры rsrv-doc" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
            undo, return error return-value .
          end.
          assign
            v-error-message = return-value
          .
        end.
        when 'rsrv-fact':U
        then do:
          run rsrv-fact in this-procedure
            no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры rsrv-fact" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение метода резервирования" skip
            "v-rsrv-type" v-rsrv-type skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
      run partrqst in this-procedure
        (input  ub.doc-line.doc-code
        ,input  ub.doc-line.obj-type
        ,input  ub.doc-line.obj-code
        ,input  ub.doc-line.artic
        ,input  ub.doc-line.prod-type
        ,input  ub.doc-line.prod-code
                ,output v-new-total-parts-qnty   ,output v-new-total-parts-fact-qnty   ,output v-new-total-parts-cli-qnty   ,output v-new-total-parts-fact-cli-qnty   ,output v-new-total-parts-price-cli   ,output v-new-total-parts-price-base   ,output v-new-total-parts-price-rubl   ,output v-new-total-parts-transport-base   ,output v-new-total-parts-transport-rubl   ,output v-new-total-parts-other-base   ,output v-new-total-parts-other-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при сборе информации по партиям" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        chg-qnty = v-new-total-parts-fact-qnty - v-total-parts-fact-qnty
      .
      if chg-qnty <> first-qnty
      and v-option-no-message = false
      then do:
        assign
          v-error-message = substitute( "Артикул: &1 (&2)&3", ub.goods.artic, ub.goods.gds-name, chr(10) )
                            + substitute( "производитель: &1 &2&3", ub.goods.prod-type, ub.goods.prod-code, chr(10) )
                            + substitute( "баркод: &1 &2 ", p-b-code, chr(10) )
                            + (if v-pl-code <> ? and v-pl-code <> 0 then substitute( "Место хранения: &1&2", v-pl-code, chr(10) ) else "" )
                            + substitute( "&2Количество &1 недоступно.&2", first-qnty, chr(10) )
                            + substitute( "Удалось зарезервировать &1.&2&2", chg-qnty, chr(10) )
                            + substitute( "&1", v-error-message )
        .
        message
          v-error-message skip
          view-as alert-box information .
      end.
      run trndocrs-need-rsrv in this-procedure
        (input  ub.trn-doc.doc-type
        ,input  ub.doc-line.artic
        ,input  ub.doc-line.prod-type
        ,input  ub.doc-line.prod-code
        ,output v-need-rsrv
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
          "Документ" ub.trn-doc.doc-type skip
          "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-need-rsrv
      and ((ub.trn-doc.status_    = 'накл':U
            and ub.trn-doc.flag_  = no)
            or ub.trn-doc.status_ = 'касс':U
          )
      then do:
        run rsrgdsck in this-procedure
          (input  ub.doc-line.doc-code
          ,input  ub.trn-doc.doc-type
          ,input  ub.doc-line.obj-type
          ,input  ub.doc-line.obj-code
          ,input  ub.doc-line.artic
          ,input  ub.doc-line.prod-type
          ,input  ub.doc-line.prod-code
          ,output v-new-free-parts-qnty
          ,output v-new-free-parts-fact-qnty
          ,output v-new-free-parts-cli-qnty
          ,output v-new-free-parts-price-base
          ,output v-new-free-parts-price-rubl
          ,output v-new-out-parts-qnty
          ,output v-new-out-parts-fact-qnty
          ,output v-new-out-parts-cli-qnty
          ,output v-new-out-parts-price-base
          ,output v-new-out-parts-price-rubl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке зарезервированных количеств" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          chg-qnty = (v-new-free-parts-qnty - v-free-parts-qnty )
        .
        run trndocrs-clear in this-procedure
          .
        run trndocrs-gds-dtl-accum in this-procedure
          (input v-prt-code
          ,input chg-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
            "Артикул" ub.goods.artic ub.goods.gds-name skip
            "производитель" ub.goods.prod-type ub.goods.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          assign
            chg-qnty = 0
          .
          undo, return error return-value .
        end.
        if v-reserv-pl-code = true then do:
          find first buf_doc-pl
            where buf_doc-pl.obj-type = ub.doc-line.obj-type
              and buf_doc-pl.obj-code = ub.doc-line.obj-code
              and buf_doc-pl.pl-code  = v-pl-code
              and buf_doc-pl.out-code = ub.doc-line.doc-code
              and buf_doc-pl.gds-code = ub.goods.gds-code
            no-error .
          if not available buf_doc-pl then do:
            message
              vss-workfile vss-revision vss-description skip
              "В документе отсутствует место хранения." skip
              "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              "место хранения" v-pl-code
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.
          if absolute( buf_doc-pl.doc-qnty ) <> absolute( v-input-qnty ) and not is-gas(ub.goods.gds-code) then do:
            message
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              "Резервировать можно только полное кол-во по doc-pl." skip
              "Дорезервирование не допускается!" skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.
          if chg-qnty <> v-input-qnty then do:
            if v-option-no-message = false then do:
              message
                "Артикул" ub.goods.artic ub.goods.gds-name skip
                "производитель" ub.goods.prod-type ub.goods.prod-code skip
                "Количество " v-input-qnty " недоступно." skip
                view-as alert-box error .
            end.
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.
          if ub.trn-doc.doc-type = 'инв':U then do:
            assign
              chg-cli-qnty = buf_doc-pl.cli-doc-qnty * buf_doc-pl.doc-qnty / v-input-qnty
            .
          end.
          else do:
            assign
              chg-cli-qnty = buf_doc-pl.cli-doc-qnty  * absolute(v-input-qnty) / v-input-qnty
            .
          end.
          run trndocrs-pl-gds-accum in this-procedure
            ( input v-pl-code
             ,input chg-qnty
             ,input chg-cli-qnty
             ,input 0.0
             ,input 0.0
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
              "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
              "Артикул" ub.goods.artic ub.goods.gds-name skip
              "производитель" ub.goods.prod-type ub.goods.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            assign
              chg-qnty = 0
            .
            undo, return error return-value .
          end.
        end.
        run trndocrs in this-procedure
          (input ub.doc-line.doc-code
          ,input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.artic
          ,input ub.doc-line.prod-type
          ,input ub.doc-line.prod-code
          ,input chg-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs" skip
            "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
            "Артикул" ub.goods.artic ub.goods.gds-name skip
            "производитель" ub.goods.prod-type ub.goods.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          assign
            chg-qnty = 0
          .
          undo, return error return-value .
        end.
      end.
    end.
    when 'reserv-create':U
    then do:
      if ub.trn-doc.doc-type <> 'инв':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Создание резервов компенсации отрицательных партий возможно только для документа инвентаризации." skip
          "Документ ub.trn-doc.doc-code: " ub.trn-doc.doc-code skip
          "Тип документа ub.trn-doc.doc-type:" ub.trn-doc.doc-type skip
          "Действие p-action:" p-action skip
          view-as alert-box .
        assign
          chg-qnty = 0
        .
        undo, return error return-value .
      end.
      assign
        chg-qnty = 0
      .
      define variable v-abs-reserv-qnty as decimal no-undo .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,input  'place-rsrv=request'
  ,output v-reserv-pl-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута на объекта" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run rsrvincr in this-procedure
        (input  parparentproc
        ,input  v-cntxt-db-num
        ,input  v-cntxt-userid
        ,input  recid(ub.trn-doc)
        ,input  recid(ub.doc-line)
        ,input  v-reserv-base
        ,input  v-reserv-rubl
        ,input  v-partscr-prompt-price
        ,input  ub.trn-doc.ext-doc-type
        ,input  v-reserv-single-part
        ,input  v-in-code
        ,input  v-part-code
        ,input  v-reserv-pl-code
        ,input  v-pl-code
        ,input  v-goods-serial
        ,input  v-goods-twounit
        ,output v-abs-reserv-qnty
        ) no-error.
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      assign
        chg-qnty = v-abs-reserv-qnty
      .
    end.
  end.
  run delete-empty-parts in this-procedure .
  if  ub.trn-doc.doc-type = 'при':U
  and ub.trn-doc.internal = no
  then do:
    run trg/partsupd.p
      (input parparentproc
      ,input ub.doc-line.doc-code
      ,input ub.doc-line.obj-type
      ,input ub.doc-line.obj-code
      ,input ub.doc-line.artic
      ,input ub.doc-line.prod-type
      ,input ub.doc-line.prod-code
      ,input false
      ,input v-partsupd-action
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  run cost-calc in this-procedure .
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input v-obj-type
  ,input v-obj-code
  ,input v-artic
  ,input v-prod-type
  ,input v-prod-code
  ,input v-root-node
  ,input ''
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности товара" skip
      "Объект" v-obj-type v-obj-code skip
      "Артикул" v-artic v-prod-type v-prod-code skip
      "Проверка целостности товара после резервирования" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end.
procedure rename-part-code :
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-in-code       as character no-undo .
  define input  parameter p-out-code      as character no-undo .
  define input  parameter p-old-part-code as character no-undo .
  define input  parameter p-new-part-code as character no-undo .
  define buffer buf_new_parts for ub.parts .
  define buffer buf_old_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    find first buf_new_parts
      where buf_new_parts.obj-type   = p-obj-type
        and buf_new_parts.obj-code   = p-obj-code
        and buf_new_parts.artic      = p-artic
        and buf_new_parts.prod-type  = p-prod-type
        and buf_new_parts.prod-code  = p-prod-code
        and buf_new_parts.in-code    = p-in-code
        and buf_new_parts.out-code   = p-out-code
        and buf_new_parts.part-code  = p-new-part-code
      no-error .
    if available buf_new_parts
    then do:
      undo, return error substitute("Уже существует партия с кодом &1"
                                   ,p-new-part-code
                                   )
        .
    end.
    find first buf_old_parts
      where buf_old_parts.obj-type   = p-obj-type
        and buf_old_parts.obj-code   = p-obj-code
        and buf_old_parts.artic      = p-artic
        and buf_old_parts.prod-type  = p-prod-type
        and buf_old_parts.prod-code  = p-prod-code
        and buf_old_parts.in-code    = p-in-code
        and buf_old_parts.out-code   = p-out-code
        and buf_old_parts.part-code  = p-old-part-code
      no-error .
    if not available buf_old_parts
    then do:
      undo, return error substitute("Не найдена партия с кодом &1"
                                   ,p-old-part-code
                                   )
        .
    end.
    assign
      buf_old_parts.part-code = p-new-part-code
    .
  end.
end procedure.
procedure delete-empty-parts :
  define buffer buf_parts        for ub.parts .
  define buffer buf_free-parts   for ub.parts .
  define buffer buf_output-parts for ub.parts .
  do
  on error undo, return error return-value
  :
    for each buf_parts
      where buf_parts.obj-type  = ub.doc-line.obj-type
        and buf_parts.obj-code  = ub.doc-line.obj-code
        and buf_parts.artic     = ub.doc-line.artic
        and buf_parts.prod-type = ub.doc-line.prod-type
        and buf_parts.prod-code = ub.doc-line.prod-code
        and buf_parts.out-code  = ub.doc-line.doc-code
    on error undo, return error return-value
    :
      find first buf_free-parts
        where buf_free-parts.obj-type   = buf_parts.obj-type
          and buf_free-parts.obj-code   = buf_parts.obj-code
          and buf_free-parts.artic      = buf_parts.artic
          and buf_free-parts.prod-type  = buf_parts.prod-type
          and buf_free-parts.prod-code  = buf_parts.prod-code
          and buf_free-parts.in-code    = buf_parts.in-code
          and buf_free-parts.out-code   = 'free-zone':U
          and buf_free-parts.part-code  = buf_parts.part-code
        no-error .
      find first buf_output-parts
        where buf_output-parts.obj-type   = buf_parts.obj-type
          and buf_output-parts.obj-code   = buf_parts.obj-code
          and buf_output-parts.artic      = buf_parts.artic
          and buf_output-parts.prod-type  = buf_parts.prod-type
          and buf_output-parts.prod-code  = buf_parts.prod-code
          and buf_output-parts.in-code    = buf_parts.in-code
          and buf_output-parts.out-code   = 'out-zone':U
          and buf_output-parts.part-code  = buf_parts.part-code
        no-error .
      if  available buf_free-parts
      and buf_free-parts.qnty      = 0
      and buf_free-parts.fact-qnty = 0
      then do:
        delete buf_free-parts .
      end.
      if available buf_output-parts
      and buf_output-parts.qnty      = 0
      and buf_output-parts.fact-qnty = 0
      then do:
        delete buf_output-parts .
      end.
      if  buf_parts.qnty        = 0
      and buf_parts.fact-qnty   = 0
      then do:
        delete buf_parts .
      end.
    end.
  end.
end procedure.
procedure rsrv-pri-doc :
  define variable v-vat-type as character no-undo .
  define variable v-vat-pc   as decimal   no-undo .
  define variable v-slt-type as character no-undo .
  define variable v-slt-pc   as decimal   no-undo .
  define variable out-rest   as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if v-goods-serial = true
    then do:
      return .
    end.
    if (chg-qnty > 0
    or v-goods-twounit = true)
    and not is-gas(ub.goods.gds-code)
    then do:
      if v-goods-twounit = true
      then do:
        if v-cli-qnty = ?
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Для ювелирных изделий необходимо задать клиентское количество" skip
            "Документ" v-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "v-cli-qnty" v-cli-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      run partscr_get-default-values in this-procedure
        (buffer ub.doc-line
        ,output v-vat-type
        ,output v-vat-pc
        ,output v-slt-type
        ,output v-slt-pc
        ) .
      if v-vat-type = 'без':U then
      assign
        ub.doc-line.vat-pc = 0
        v-vat-pc = 0
      .
      if v-slt-type = 'без':U then
      assign
        ub.doc-line.slt-pc = 0
        v-slt-pc = 0
      .
      run partscr in this-procedure
        (input  parparentproc
        ,input  v-cntxt-db-num
        ,input  v-cntxt-userid
        ,input
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-type else ub.trn-doc.obj-type )
        ,input
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-code else ub.trn-doc.obj-code )
        ,input  v-create-part-code
        ,input  v-create-cst-code
        ,input  v-create-ps
        ,input  v-create-dop
        ,input  v-reserv-base
        ,input  v-reserv-rubl
        ,input  v-vat-type
        ,input  v-vat-pc
        ,input  v-slt-type
        ,input  v-slt-pc
        ,input  chg-qnty
        ,input  v-partscr-prompt-price
        ,input  v-cli-qnty
        ,input  v-last-date
        ,input  v-hold-date
        ,input  v-pl-code
        ,buffer ub.doc-line
        ,buffer ub.parts
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      if v-hold-code-parent <> ""
      then do:
        run holdprts-create-parts-supp in this-procedure
          (input v-hold-code-parent
          ,input v-hold-part-code
          ,input ub.parts.in-code
          ,input ub.parts.artic
          ,input ub.parts.prod-type
          ,input ub.parts.prod-code
          ,input ub.parts.part-code
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при копировании атрибутов партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    else do:
      if was-created-part-code = yes then do:
        find first ub.parts
             where ub.parts.obj-type  = ub.doc-line.obj-type
               and ub.parts.obj-code  = ub.doc-line.obj-code
               and ub.parts.artic     = ub.doc-line.artic
               and ub.parts.prod-type = ub.doc-line.prod-type
               and ub.parts.prod-code = ub.doc-line.prod-code
               and ub.parts.in-code   = ub.doc-line.doc-code
               and ub.parts.out-code  = ub.doc-line.doc-code
               and ub.parts.part-code = v-create-part-code    no-error.
        if available ub.parts then do:
          assign
            out-rest = abs( chg-qnty )
          .
          if ub.parts.qnty      >= abs( chg-qnty ) and
             ub.parts.fact-qnty >= abs( chg-qnty ) then do:
            assign
              ub.parts.qnty      = ub.parts.qnty - out-rest
              ub.parts.fact-qnty = ub.parts.qnty
              chg-qnty           = chg-qnty      + out-rest
            .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run qntycalc in g#library
  (input  'cli-qnty'
  ,input  ub.parts.cli-base-rate
  ,input  ub.parts.cli-qnty
  ,input  ub.parts.qnty
  ,output ub.parts.cli-qnty
  ,output ub.parts.qnty
  ) no-error .
            if error-status :error
            then do:
              message
                "Невозможно пересчитать количество по ТТН" skip
                "Документ" ub.parts.out-code skip
                "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
                "Партия" ub.parts.part-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          else do:
            message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                    "Невозможно выполнить резервирование по партии" skip( 0 )
                    "Объект" ub.parts.obj-type ub.parts.obj-code skip( 0 )
                    "Документ" ub.parts.out-code skip( 0 )
                    "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip( 0 )
                    "Партия" ub.parts.part-code "  (" ub.parts.in-code ")" skip( 0 )
                    "Запрошенное количество для резервирования:" chg-qnty skip( 0 )
                    "Количество товара в партии:" ub.parts.fact-qnty skip( 1 )
            view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      if abs( chg-qnty ) > 0 then do:
        for each ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.in-code   = ub.doc-line.doc-code
            and ub.parts.out-code  = ub.doc-line.doc-code
        on error undo, return error return-value
        :
          assign
            out-rest = min(ub.parts.qnty, abs(chg-qnty) )
          .
          assign
            ub.parts.qnty      = ub.parts.qnty - out-rest
            ub.parts.fact-qnty = ub.parts.qnty
            chg-qnty           = chg-qnty      + out-rest
          .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run qntycalc in g#library
  (input  'cli-qnty'
  ,input  ub.parts.cli-base-rate
  ,input  ub.parts.cli-qnty
  ,input  ub.parts.qnty
  ,output ub.parts.cli-qnty
  ,output ub.parts.qnty
  ) no-error .
          if error-status :error
          then do:
            message
              "Невозможно пересчитать количество по ТТН" skip
              "Документ" ub.parts.out-code skip
              "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
              "Партия" + string(ub.parts.part-code) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if chg-qnty = 0
          then do:
            leave.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure rsrv-pri-fact :
  define variable v-vat-type as character no-undo .
  define variable v-vat-pc   as decimal   no-undo .
  define variable v-slt-type as character no-undo .
  define variable v-slt-pc   as decimal   no-undo .
  define variable out-rest   as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if chg-qnty = 0
    then do:
      return.
    end.
    if v-goods-serial = true
    then do:
      return .
    end.
    if v-goods-twounit = true
    then do:
    end.
    if chg-qnty > 0
    then do:
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.in-code   = ub.doc-line.doc-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.fact-qnty < ub.parts.qnty
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next .
        end.
        assign
          out-rest = min(ub.parts.qnty - ub.parts.fact-qnty, abs(chg-qnty))
        .
        assign
          ub.parts.fact-qnty = ub.parts.fact-qnty + out-rest
          chg-qnty           = chg-qnty           - out-rest
        .
        if chg-qnty = 0
        then do:
          leave.
        end.
      end.
      if chg-qnty > 0
      and not is-gas(ub.goods.gds-code)
      then do:
        run partscr_get-default-values in this-procedure
          (buffer ub.doc-line
          ,output v-vat-type
          ,output v-vat-pc
          ,output v-slt-type
          ,output v-slt-pc
          ) .
        run partscr in this-procedure
          (input  parparentproc
          ,input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-type else ub.trn-doc.obj-type )
          ,input
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-code else ub.trn-doc.obj-code )
          ,input  v-create-part-code
          ,input  v-create-cst-code
          ,input  v-create-ps
          ,input  v-create-dop
          ,input  v-reserv-base
          ,input  v-reserv-rubl
          ,input  v-vat-type
          ,input  v-vat-pc
          ,input  v-slt-type
          ,input  v-slt-pc
          ,input  chg-qnty
          ,input  v-partscr-prompt-price
          ,input  0
          ,input  v-last-date
          ,input  v-hold-date
          ,input  v-pl-code
          ,buffer ub.doc-line
          ,buffer ub.parts
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании партии" skip
            "Документ" ub.doc-line.doc-code skip
            "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    else do:
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.in-code   = ub.doc-line.doc-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.fact-qnty > 0
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next .
        end.
        assign
          out-rest = min(ub.parts.fact-qnty, abs(chg-qnty))
        .
        assign
          ub.parts.fact-qnty = ub.parts.fact-qnty - out-rest
          chg-qnty           = chg-qnty           + out-rest
        .
        if chg-qnty = 0
        then do:
          leave.
        end.
      end.
    end.
  end.
end procedure.
procedure cost-calc :
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  do
  on error undo, return error return-value
  :
    run partrqst in this-procedure
      (input  ub.doc-line.doc-code
      ,input  ub.doc-line.obj-type
      ,input  ub.doc-line.obj-code
      ,input  ub.doc-line.artic
      ,input  ub.doc-line.prod-type
      ,input  ub.doc-line.prod-code
            ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        cost-base = v-total-parts-price-base / v-total-parts-fact-qnty
        cost-rubl = v-total-parts-price-rubl / v-total-parts-fact-qnty
      .
    end.
    else do:
      assign
        cost-base = v-reserv-base
        cost-rubl = v-reserv-rubl
      .
    end.
  end.
end procedure.
procedure rsrv-fact :
  do
  on error undo, return error return-value
  :
    if chg-qnty = 0
    then do:
      return.
    end.
    if chg-qnty < 0
    then do:
      for each ub.parts
        where ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
          and ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.status_ = no
          and ub.parts.fact-qnty > ub.parts.qnty
      on error undo, return error return-value
      :
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        and v-pl-code <> ub.parts.pl-code
        then do:
          next .
        end.
        if ub.parts.fact-qnty - ub.parts.qnty >= abs(chg-qnty)
        then do:
          assign
            ub.parts.fact-qnty = ub.parts.fact-qnty - abs(chg-qnty)
            chg-qnty           = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
          return.
        end.
        else do:
          assign
            chg-qnty           = chg-qnty  + ( ub.parts.fact-qnty - ub.parts.qnty)
            ub.parts.fact-qnty = ub.parts.qnty
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
        end.
      end.
      if  v-reserv-pl-code = yes
      and v-pl-code <> ?
      and v-pl-code <> 0
      then do:
        find last ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.pl-code   = v-pl-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty > 0
        use-index pi
        no-error .
      end.
      else do:
        release ub.parts .
      end.
      if not available ub.parts
      then do:
        find last ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty > 0
          use-index pi
          .
      end.
      do while chg-qnty < 0
      :
        if ub.parts.fact-qnty >= abs(chg-qnty)
        then do:
          assign
            ub.parts.fact-qnty = ub.parts.fact-qnty - abs(chg-qnty)
            chg-qnty           = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
          leave.
        end.
        else do:
          assign
            chg-qnty           = chg-qnty  + ub.parts.fact-qnty
            ub.parts.fact-qnty = 0
          .
          if v-goods-twounit <> true
          then do:
            if ub.parts.cli-base-rate <> 0
            then do:
              assign
                ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
              .
            end.
            else do:
              assign
                ub.parts.cli-qnty = 0
              .
            end.
          end.
        end.
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        then do:
          find prev ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.pl-code   = v-pl-code
              and ub.parts.status_   = no
              and ub.parts.fact-qnty > 0
            use-index pi
            no-error .
        end.
        else do:
          release ub.parts .
        end.
        if not available ub.parts
        then do:
          find prev ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.status_   = no
              and ub.parts.fact-qnty > 0
            use-index pi
            .
        end.
      end.
    end.
    else do:
      if  v-reserv-pl-code = yes
      and v-pl-code <> ?
      and v-pl-code <> 0
      then do:
        find first ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.pl-code   = v-pl-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty < ub.parts.qnty
        use-index pi
        no-error .
      end.
      else do:
        find first ub.parts
          where ub.parts.obj-type  = ub.doc-line.obj-type
            and ub.parts.obj-code  = ub.doc-line.obj-code
            and ub.parts.artic     = ub.doc-line.artic
            and ub.parts.prod-type = ub.doc-line.prod-type
            and ub.parts.prod-code = ub.doc-line.prod-code
            and ub.parts.out-code  = ub.doc-line.doc-code
            and ub.parts.status_   = no
            and ub.parts.fact-qnty < ub.parts.qnty
          use-index pi
          no-error.
      end.
      if available parts
      then do:
        do while chg-qnty > 0
        :
          if ub.parts.qnty - ub.parts.fact-qnty >= chg-qnty
          then do:
            assign
              ub.parts.fact-qnty = ub.parts.fact-qnty + chg-qnty
              chg-qnty           = 0
            .
            if v-goods-twounit <> true
            then do:
              if ub.parts.cli-base-rate <> 0
              then do:
                assign
                  ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
                .
              end.
              else do:
                assign
                  ub.parts.cli-qnty = 0
                .
              end.
            end.
            leave.
          end.
          else do:
            assign
              chg-qnty           = chg-qnty  - (ub.parts.qnty - ub.parts.fact-qnty)
              ub.parts.fact-qnty = ub.parts.qnty
            .
            if v-goods-twounit <> true
            then do:
              if ub.parts.cli-base-rate <> 0
              then do:
                assign
                  ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
                .
              end.
              else do:
                assign
                  ub.parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  v-reserv-pl-code = yes
          and v-pl-code <> ?
          and v-pl-code <> 0
          then do:
            find next ub.parts
              where ub.parts.obj-type  = ub.doc-line.obj-type
                and ub.parts.obj-code  = ub.doc-line.obj-code
                and ub.parts.artic     = ub.doc-line.artic
                and ub.parts.prod-type = ub.doc-line.prod-type
                and ub.parts.prod-code = ub.doc-line.prod-code
                and ub.parts.out-code  = ub.doc-line.doc-code
                and ub.parts.pl-code   = v-pl-code
                and ub.parts.status_   = no
                and ub.parts.fact-qnty < ub.parts.qnty
              use-index pi
              no-error .
          end.
          else do:
            find next ub.parts
              where ub.parts.obj-type  = ub.doc-line.obj-type
                and ub.parts.obj-code  = ub.doc-line.obj-code
                and ub.parts.artic     = ub.doc-line.artic
                and ub.parts.prod-type = ub.doc-line.prod-type
                and ub.parts.prod-code = ub.doc-line.prod-code
                and ub.parts.out-code  = ub.doc-line.doc-code
                and ub.parts.status_   = no
                and ub.parts.fact-qnty < ub.parts.qnty
              use-index pi
              no-error.
          end.
          if not available ub.parts
          then do:
            leave.
          end.
        end.
      end.
      if chg-qnty > 0
      then do:
        if  v-reserv-pl-code = yes
        and v-pl-code <> ?
        and v-pl-code <> 0
        then do:
          find first ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.pl-code   = v-pl-code
              and ub.parts.status_   = no
            use-index pi
            .
        end.
        else do:
          find first ub.parts
            where ub.parts.obj-type  = ub.doc-line.obj-type
              and ub.parts.obj-code  = ub.doc-line.obj-code
              and ub.parts.artic     = ub.doc-line.artic
              and ub.parts.prod-type = ub.doc-line.prod-type
              and ub.parts.prod-code = ub.doc-line.prod-code
              and ub.parts.out-code  = ub.doc-line.doc-code
              and ub.parts.status_   = no
            use-index pi
            .
        end.
        assign
          parts.fact-qnty = parts.fact-qnty + chg-qnty
          chg-qnty        = 0
        .
        if v-goods-twounit <> true
        then do:
          if ub.parts.cli-base-rate <> 0
          then do:
            assign
              ub.parts.cli-qnty = ub.parts.fact-qnty / ub.parts.cli-base-rate
            .
          end.
          else do:
            assign
              ub.parts.cli-qnty = 0
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure check-input-parameters :
  define parameter buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    define variable ind                    as integer no-undo .
    define variable v-num-entries-p-action as integer no-undo .
    if p-action = ""
    or p-action = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Не задан параметр вызова p-action." skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-create-part-code = ""
      v-create-cst-code  = buf_trn-doc.cst-code
      v-partscr-prompt-price = 'prompt=enable':u
    .
    assign
      v-reserv-single-part = false
      v-in-code            = ""
      v-part-code          = ""
    .
    define variable v-purch-code-list-type as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'purchcodelist':U ,
                       output v-purch-code-list ,
                       output v-purch-code-list-type )  .
    if v-purch-code-list = '1,2,3,4':U
    then do:
      assign
        v-purch-code-list = "":u
      .
    end.
    define variable v-rsrv-doc-list      as character no-undo .
    define variable v-rsrv-doc-list-type as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'rsrv-doc-list':U ,
                       output v-rsrv-doc-list ,
                       output v-rsrv-doc-list-type )  .
    if v-rsrv-doc-list = ''
    then do:
      run partlist_use-set in this-procedure
        (input  false
        ) .
    end.
    else do:
      run partlist_use-set in this-procedure
        (input  true
        ) .
      run partlist_clear in this-procedure
        .
      define variable v-rsrv-doc-list-index       as integer   no-undo .
      define variable v-rsrv-doc-list-num-entries as integer   no-undo .
      assign
        v-rsrv-doc-list-num-entries = num-entries(v-rsrv-doc-list, chr(44))
      .
      do v-rsrv-doc-list-index = 1 to v-rsrv-doc-list-num-entries
      :
        define buffer rsrv_buf_trn-doc for ub.trn-doc .
        find first rsrv_buf_trn-doc no-lock
          where rsrv_buf_trn-doc.doc-code = entry(v-rsrv-doc-list-index
                                                 ,v-rsrv-doc-list
                                                 ,chr(44)
                                                 )
          no-error .
        if not available rsrv_buf_trn-doc
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при анализе входящих параметров" skip
            "В списке документов задан несуществующий документ" skip
            "Документ" buf_trn-doc.doc-code skip
            "Атрибут" 'rsrv-doc-list':U skip
            "Номер элемента" v-rsrv-doc-list-index skip
            "Документ для резервирования" entry(v-rsrv-doc-list-index
                                                 ,v-rsrv-doc-list
                                                 ,chr(44)
                                                 ) skip
          view-as alert-box error .
          undo, return error return-value .
        end.
        define buffer rsrv_buf_doc-line for ub.doc-line .
        find first rsrv_buf_doc-line no-lock
          where rsrv_buf_doc-line.doc-code  = rsrv_buf_trn-doc.doc-code
            and rsrv_buf_doc-line.artic     = v-artic
            and rsrv_buf_doc-line.prod-type = v-prod-type
            and rsrv_buf_doc-line.prod-code = v-prod-code
          no-error .
        if available rsrv_buf_doc-line
        then do:
          define buffer rsrv_buf_parts for ub.parts .
          for each rsrv_buf_parts no-lock
            where rsrv_buf_parts.obj-type  = rsrv_buf_trn-doc.obj-type
              and rsrv_buf_parts.obj-code  = rsrv_buf_trn-doc.obj-code
              and rsrv_buf_parts.artic     = rsrv_buf_doc-line.artic
              and rsrv_buf_parts.prod-type = rsrv_buf_doc-line.prod-type
              and rsrv_buf_parts.prod-code = rsrv_buf_doc-line.prod-code
              and rsrv_buf_parts.out-code  = rsrv_buf_trn-doc.doc-code
          on error undo, return error return-value
          :
            if rsrv_buf_parts.fact-qnty > 0
            then do:
              run partlist_append_part in this-procedure
                (input  rsrv_buf_parts.in-code
                ,input  rsrv_buf_parts.part-code
                ,input  rsrv_buf_parts.qnty
                ) .
            end.
          end.
        end.
      end.
    end.
    assign
      v-last-date = ?
    .
    assign
      v-num-entries-p-action = num-entries(p-action)
    .
    do ind = 2 to v-num-entries-p-action
    :
      define variable v-option       as character no-undo .
      define variable v-option-key   as character no-undo .
      define variable v-option-value as character no-undo .
      assign
        v-option = entry(ind, p-action)
      .
      if v-option = ""
      or v-option = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова резервирования" skip
          "В качестве параметров резервирования задана пустая или неопределенная опция" skip
          "v-option" v-option skip
          "p-action" p-action skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-option-key = entry(1, v-option, "=" )
      .
      case v-option-key :
        when 'no-message':U
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-reject':u
          .
        end.
        when 'no-msg-create':U
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-create':u
          .
        end.
        when 'no-msg-no-chk-acta-cr':U
        then do:
          assign
            v-option-no-message = true
            v-partscr-prompt-price = 'prompt=disable-create,check-right=false':u
          .
        end.
        when 'plcode':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания складского места необходимо указать строку" skip
              "" 'plcode':U + "=<plcode>" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define variable s-pl-code as character no-undo .
          assign
            s-pl-code = entry(2, v-option, "=" )
          .
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,input  'place-rsrv=request'
  ,output v-reserv-pl-code
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении атрибута на объекта" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if v-reserv-pl-code = false
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка задания параметров вызова резервирования" skip
              "Товар не привязан к местам хранения" skip
              "Но для товара задано место хранения" skip
              "pl-code" s-pl-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-reserv-pl-code = true
            v-pl-code        = integer(s-pl-code) no-error
          .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания складского места необходимо указать строку" skip
              "" 'plcode':U + "=<plcode>" skip
              "" s-pl-code + "не может быть преобразовано к целому числу" skip
              "v-option" v-option skip
              "p-action" p-action skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        when 'copy-cst':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания параметров партии (ГТД, код партии) необходимо указать строку" skip
              "" 'copy-cst':U + "=<recid_исходной_партии>" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          define buffer buf_orig-parts for ub.parts .
          find first buf_orig-parts no-lock
            where recid(buf_orig-parts) = integer(v-option-value)
            no-error .
          if not available buf_orig-parts
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Было запрошено копирование параметров параметров партии (ГТД, код партии)" skip
              "Исходная партия с указателем" v-option-value "не была найдена" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-create-part-code = buf_orig-parts.part-code
            v-create-cst-code  = buf_orig-parts.cst-code
          .
          if  v-create-part-code = ""
          then do:
            define buffer buf_orig-trn-doc for ub.trn-doc .
            find first buf_orig-trn-doc no-lock
              where buf_orig-trn-doc.doc-code = buf_orig-parts.out-code
              no-error .
            if not available buf_orig-trn-doc
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при задании параметров вызова резервирования" skip
                "Было запрошено копирование параметров параметров партии (ГТД, код партии)" skip
                "Задана партия с номером" recid(buf_orig-parts) skip
                "Не найден документ к которому привязана партия" skip
                "Документ" buf_orig-parts.out-code skip
                "v-option" v-option skip
                "p-action" p-action skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            if buf_orig-trn-doc.ext-doc-type <> 'ie':U
            then do:
              assign
                v-create-part-code = "#":U + buf_orig-parts.in-code
              .
            end.
          end.
        end.
        when 'cst-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода ГТД необходимо указать строку" skip
              "" 'cst-code':U + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-cst-code = str-decode(v-option-value, "")
          .
        end.
        when 'ps':u
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода ГТД необходимо указать строку" skip
              "" 'cst-code':U + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-ps = str-decode(v-option-value, "")
          .
          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.
        when 'dop':u
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания DOP необходимо указать строку" skip
              "" 'cst-code':U + "=цена производителя" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-dop = str-decode(v-option-value, "")
          .
          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.
        when 'contract-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода контракта необходимо указать строку" skip
              "" 'contract-code':U + "=Код контракта" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-contract-code = integer(v-option-value)
          .
          assign
            v-partsupd-action = v-partsupd-action
                              + (if v-partsupd-action <> "" then "," else "")
                              + v-option
          .
        end.
        when 'rsrv-single-part':U
        then do:
          if num-entries(v-option, "=") <> 1
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода документа необходимо указать строку" skip
              "" 'rsrv-single-part':U skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-reserv-single-part = true
          .
        end.
        when 'rsrv-in-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода документа необходимо указать строку" skip
              "" 'rsrv-in-code':U + "=Код документа" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-in-code = str-decode(v-option-value, "")
          .
        end.
        when 'rsrv-part-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" 'rsrv-part-code':U + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-part-code = str-decode(v-option-value, "")
          .
        end.
        when 'old-part-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" 'old-part-code':U + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-rename-part-code = true
            v-old-part-code    = str-decode(v-option-value, "")
          .
        end.
        when 'cre-part-code':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" 'cre-part-code':U + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-create-part-code = str-decode(v-option-value, "")
            was-created-part-code = yes
          .
        end.
        when 'cli-qnty':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания клиентского количества необходимо указать строку" skip
              "" 'cst-code':U + "=Код ГТД" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-cli-qnty = decimal(v-option-value)
          .
        end.
        when 'hold-code-parent':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" 'hold-code-parent':U + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-code-parent = str-decode(v-option-value, "")
          .
          if v-hold-code-parent <> ""
          then do:
            run holdprts-get-part-code in this-procedure
              (input  buf_trn-doc.doc-code
              ,output v-create-part-code
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении номера партии" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
        when 'part-code-parent':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания кода партии необходимо указать строку" skip
              "" 'part-code-parent':U + "=Код партии" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-part-code = str-decode(v-option-value, "")
          .
        end.
        when 'purch-code-list':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" 'purch-code-list':U + "=Список типов приобретения" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-purch-code-list = str-decode(v-option-value, "")
          .
        end.
        when 'last-date':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" 'last-date':U + "=Дата срока годности до" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-last-date = date(v-option-value)
          .
        end.
        when 'hold-date':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания списка типов приобретения необходимо указать строку" skip
              "" 'hold-date':U + "=Дата прихода МФ" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          assign
            v-hold-date = date(v-option-value)
          .
        end.
        when 'negative-check':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания типа отрицательной проверки необходимо указать строку" skip
              "" 'part-code-parent':U + "=Тип проверки" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-option-value = entry(2, v-option, "=" )
          .
          define variable v-ind as integer   no-undo .
          if  v-option-value <> "1"
          and v-option-value <> "2"
          and v-option-value <> "3"
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Неизвестное значение типа отрицательной проверки" skip
              "Допустимые значения 1,2,3" skip
              "" 'part-code-parent':U + "=Тип проверки" skip
              "v-option" v-option skip
              "p-action" p-action skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            v-negative-check = integer(v-option-value)
          .
        end.
        when 'sale-negative-check-on':u
        then do:
          assign
            v-option-sale-negative-check-on = true
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Неизвестная опция." v-option skip
            "p-action" p-action skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
    if  p-b-code <> ?
    and p-b-code <> 0
    and p-b-code <> -1
    then do:
      find ub.bar-code no-lock
        where ub.bar-code.b-code = p-b-code
        no-error.
      if not available ub.bar-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова резервирования" skip
          "Недопустимый параметр вызова бар-код партии." skip
          "Документ" v-doc-code skip
          "Артикул" v-artic v-prod-type v-prod-code skip
          "b-code" p-b-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-reserv-single-part = true
        v-in-code            = ub.bar-code.in-code
        v-part-code          = ub.bar-code.part-code
      .
      define buffer buf_parts-attr for ub.parts-attr  .
          find first buf_parts-attr no-lock where
               buf_parts-attr.gds-code  = ub.bar-code.gds-code  and
               buf_parts-attr.part-code = ub.bar-code.part-code  and
               buf_parts-attr.in-code =   ub.bar-code.in-code
               no-error .
                if error-status :error then DO:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "Нет атрибута партиии для"
                      ub.bar-code.gds-code  skip
                      ub.bar-code.part-code skip
                      ub.bar-code.in-code   skip
                      view-as alert-box error
                    .
                end.
           else do:
           assign
            v-in-code   = buf_parts-attr.orig-in-code
            v-part-code = buf_parts-attr.orig-part-code
           .
           end.
    end.
    assign
      p-action = entry(1, p-action)
    .
    if  p-action <> 'reserv':U
    and p-action <> 'reserv-create':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Недопустимый параметр вызова p-action." skip
        "Значение p-action: "  p-action  skip
        "Допустимые значения:" skip
        "" 'reserv':U skip
        "" 'reserv-create':U skip
        view-as alert-box error .
      assign
        chg-qnty = 0
      .
      undo, return error return-value .
    end.
    if chg-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Количество для резервирования имеет неопределенное значение" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-check-qnty like ub.doc-line.doc-qnty no-undo .
    assign
      v-check-qnty = chg-qnty
    .
    if v-check-qnty <> chg-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Запрошено резервирование дробного количества" skip
        "Запрошено резервирование" chg-qnty skip
        "После округления это составит" v-check-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
