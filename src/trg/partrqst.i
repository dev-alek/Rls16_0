/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Суммарная информация по всем зарезервированным партиям строки документа

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&glob partrqst-var ~
  define variable ~{&partrqst-prefix~}qnty           like ub.parts.qnty      no-undo . ~
  define variable ~{&partrqst-prefix~}fact-qnty      like ub.parts.fact-qnty no-undo . ~
  define variable ~{&partrqst-prefix~}cli-qnty       like ub.parts.cli-qnty  no-undo . ~
  define variable ~{&partrqst-prefix~}fact-cli-qnty  like ub.parts.cli-qnty  no-undo . ~
  define variable ~{&partrqst-prefix~}price-cli      as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}price-base     as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}price-rubl     as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}transport-base as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}transport-rubl as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}other-base     as decimal no-undo . ~
  define variable ~{&partrqst-prefix~}other-rubl     as decimal no-undo .

&glob partrqst-param ~
  ,output ~{&partrqst-prefix~}qnty ~
  ,output ~{&partrqst-prefix~}fact-qnty ~
  ,output ~{&partrqst-prefix~}cli-qnty ~
  ,output ~{&partrqst-prefix~}fact-cli-qnty ~
  ,output ~{&partrqst-prefix~}price-cli ~
  ,output ~{&partrqst-prefix~}price-base ~
  ,output ~{&partrqst-prefix~}price-rubl ~
  ,output ~{&partrqst-prefix~}transport-base ~
  ,output ~{&partrqst-prefix~}transport-rubl ~
  ,output ~{&partrqst-prefix~}other-base ~
  ,output ~{&partrqst-prefix~}other-rubl

procedure partrqst :

  /*
  Суммарная информация по всем зарезервированным партиям строки документа

  Внимание - для товара, учитываемого по средней учетной цене
  полученные суммы p-total-parts-price-base, p-total-parts-price-rubl
  должны быть получены из фактического количества и средней учетной цены товара

  */

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

end procedure. /* partrqst */

/* $Workfile$ e n d */