block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00199000.p $
$Archive: cut/00199000.p $

Файл пирога обрезания. Относится к категории 199.

Обработка таблиц:
arh-fin-...

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00199000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00199000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 199.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }

define buffer old-arh-fin-doc-an              for src.arh-fin-doc-an.
define buffer bf_arh-fin-doc-an               for src.arh-fin-doc-an.
define buffer new-arh-fin-doc-an              for dst.arh-fin-doc-an.
define buffer old-arh-fin-doc-an-nal          for src.arh-fin-doc-an-nal.
define buffer bf_arh-fin-doc-an-nal           for src.arh-fin-doc-an-nal.
define buffer new-arh-fin-doc-an-nal          for dst.arh-fin-doc-an-nal.
define buffer old-arh-fin-doc-an-nal-obj      for src.arh-fin-doc-an-nal-obj.
define buffer bf_arh-fin-doc-an-nal-obj       for src.arh-fin-doc-an-nal-obj.
define buffer new-arh-fin-doc-an-nal-obj      for dst.arh-fin-doc-an-nal-obj.
define buffer old-arh-fin-doc-an-obj          for src.arh-fin-doc-an-obj.
define buffer bf_arh-fin-doc-an-obj           for src.arh-fin-doc-an-obj.
define buffer new-arh-fin-doc-an-obj          for dst.arh-fin-doc-an-obj.
define buffer old-arh-fin-doc-c-s-tax-nal-obj for src.arh-fin-doc-c-s-tax-nal-obj.
define buffer bf_arh-fin-doc-c-s-tax-nal-obj  for src.arh-fin-doc-c-s-tax-nal-obj.
define buffer new-arh-fin-doc-c-s-tax-nal-obj for dst.arh-fin-doc-c-s-tax-nal-obj.
define buffer old-arh-fin-doc-c-schet-tax-nal for src.arh-fin-doc-c-schet-tax-nal.
define buffer bf_arh-fin-doc-c-schet-tax-nal  for src.arh-fin-doc-c-schet-tax-nal.
define buffer new-arh-fin-doc-c-schet-tax-nal for dst.arh-fin-doc-c-schet-tax-nal.
define buffer old-arh-fin-doc-contr-s-nal-obj for src.arh-fin-doc-contr-s-nal-obj.
define buffer bf_arh-fin-doc-contr-s-nal-obj  for src.arh-fin-doc-contr-s-nal-obj.
define buffer new-arh-fin-doc-contr-s-nal-obj for dst.arh-fin-doc-contr-s-nal-obj.
define buffer old-arh-fin-doc-contr-s-tax-obj for src.arh-fin-doc-contr-s-tax-obj.
define buffer bf_arh-fin-doc-contr-s-tax-obj  for src.arh-fin-doc-contr-s-tax-obj.
define buffer new-arh-fin-doc-contr-s-tax-obj for dst.arh-fin-doc-contr-s-tax-obj.
define buffer old-arh-fin-doc-contr-schet     for src.arh-fin-doc-contr-schet.
define buffer bf_arh-fin-doc-contr-schet      for src.arh-fin-doc-contr-schet.
define buffer new-arh-fin-doc-contr-schet     for dst.arh-fin-doc-contr-schet.
define buffer old-arh-fin-doc-contr-schet-nal for src.arh-fin-doc-contr-schet-nal.
define buffer bf_arh-fin-doc-contr-schet-nal  for src.arh-fin-doc-contr-schet-nal.
define buffer new-arh-fin-doc-contr-schet-nal for dst.arh-fin-doc-contr-schet-nal.
define buffer old-arh-fin-doc-contr-schet-obj for src.arh-fin-doc-contr-schet-obj.
define buffer bf_arh-fin-doc-contr-schet-obj  for src.arh-fin-doc-contr-schet-obj.
define buffer new-arh-fin-doc-contr-schet-obj for dst.arh-fin-doc-contr-schet-obj.
define buffer old-arh-fin-doc-contr-schet-tax for src.arh-fin-doc-contr-schet-tax.
define buffer bf_arh-fin-doc-contr-schet-tax  for src.arh-fin-doc-contr-schet-tax.
define buffer new-arh-fin-doc-contr-schet-tax for dst.arh-fin-doc-contr-schet-tax.
define buffer old-arh-fin-doc-s-tax-nal-obj   for src.arh-fin-doc-s-tax-nal-obj.
define buffer bf_arh-fin-doc-s-tax-nal-obj    for src.arh-fin-doc-s-tax-nal-obj.
define buffer new-arh-fin-doc-s-tax-nal-obj   for dst.arh-fin-doc-s-tax-nal-obj.
define buffer old-arh-fin-doc-schet           for src.arh-fin-doc-schet.
define buffer bf_arh-fin-doc-schet            for src.arh-fin-doc-schet.
define buffer new-arh-fin-doc-schet           for dst.arh-fin-doc-schet.
define buffer old-arh-fin-doc-schet-nal       for src.arh-fin-doc-schet-nal.
define buffer bf_arh-fin-doc-schet-nal        for src.arh-fin-doc-schet-nal.
define buffer new-arh-fin-doc-schet-nal       for dst.arh-fin-doc-schet-nal.
define buffer old-arh-fin-doc-schet-nal-obj   for src.arh-fin-doc-schet-nal-obj.
define buffer bf_arh-fin-doc-schet-nal-obj    for src.arh-fin-doc-schet-nal-obj.
define buffer new-arh-fin-doc-schet-nal-obj   for dst.arh-fin-doc-schet-nal-obj.
define buffer old-arh-fin-doc-schet-obj       for src.arh-fin-doc-schet-obj.
define buffer bf_arh-fin-doc-schet-obj        for src.arh-fin-doc-schet-obj.
define buffer new-arh-fin-doc-schet-obj       for dst.arh-fin-doc-schet-obj.
define buffer old-arh-fin-doc-schet-tax       for src.arh-fin-doc-schet-tax.
define buffer bf_arh-fin-doc-schet-tax        for src.arh-fin-doc-schet-tax.
define buffer new-arh-fin-doc-schet-tax       for dst.arh-fin-doc-schet-tax.
define buffer old-arh-fin-doc-schet-tax-nal   for src.arh-fin-doc-schet-tax-nal.
define buffer bf_arh-fin-doc-schet-tax-nal    for src.arh-fin-doc-schet-tax-nal.
define buffer new-arh-fin-doc-schet-tax-nal   for dst.arh-fin-doc-schet-tax-nal.
define buffer old-arh-fin-doc-schet-tax-obj   for src.arh-fin-doc-schet-tax-obj.
define buffer bf_arh-fin-doc-schet-tax-obj    for src.arh-fin-doc-schet-tax-obj.
define buffer new-arh-fin-doc-schet-tax-obj   for dst.arh-fin-doc-schet-tax-obj.
define buffer old-arh-fin-ob-contr            for src.arh-fin-ob-contr.
define buffer bf_arh-fin-ob-contr             for src.arh-fin-ob-contr.
define buffer new-arh-fin-ob-contr            for dst.arh-fin-ob-contr.
define buffer old-arh-fin-ob-contr-obj        for src.arh-fin-ob-contr-obj.
define buffer bf_arh-fin-ob-contr-obj         for src.arh-fin-ob-contr-obj.
define buffer new-arh-fin-ob-contr-obj        for dst.arh-fin-ob-contr-obj.


define buffer new-arh-fin-doc-an-attr               for dst.arh-fin-doc-an-attr         .
define buffer new-arh-fin-doc-an-nal-attr           for dst.arh-fin-doc-an-nal-attr     .
define buffer new-arh-fin-doc-an-nal-obj-attr       for dst.arh-fin-doc-an-nal-obj-attr .
define buffer new-arh-fin-doc-an-obj-attr           for dst.arh-fin-doc-an-obj-attr     .
define buffer new-arh-fin-doc-contr-schet-attr      for dst.arh-fin-doc-contr-schet-attr.
define buffer new-arh-fin-doc-schet-attr            for dst.arh-fin-doc-schet-attr      .
define buffer new-arh-fin-doc-schet-nal-attr        for dst.arh-fin-doc-schet-nal-attr  .
define buffer new-arh-fin-doc-schet-obj-attr        for dst.arh-fin-doc-schet-obj-attr  .
define buffer new-arh-fin-doc-schet-tax-attr        for dst.arh-fin-doc-schet-tax-attr  .
define buffer new-arh-fin-ob-contr-attr             for dst.arh-fin-ob-contr-attr       .
define buffer new-arh-fin-ob-contr-obj-attr         for dst.arh-fin-ob-contr-obj-attr   .

define buffer old-arh-fin-doc-an-attr               for src.arh-fin-doc-an-attr         .
define buffer old-arh-fin-doc-an-nal-attr           for src.arh-fin-doc-an-nal-attr     .
define buffer old-arh-fin-doc-an-nal-obj-attr       for src.arh-fin-doc-an-nal-obj-attr .
define buffer old-arh-fin-doc-an-obj-attr           for src.arh-fin-doc-an-obj-attr     .
define buffer old-arh-fin-doc-contr-schet-attr      for src.arh-fin-doc-contr-schet-attr.
define buffer old-arh-fin-doc-schet-attr            for src.arh-fin-doc-schet-attr      .
define buffer old-arh-fin-doc-schet-nal-attr        for src.arh-fin-doc-schet-nal-attr  .
define buffer old-arh-fin-doc-schet-obj-attr        for src.arh-fin-doc-schet-obj-attr  .
define buffer old-arh-fin-doc-schet-tax-attr        for src.arh-fin-doc-schet-tax-attr  .
define buffer old-arh-fin-ob-contr-attr             for src.arh-fin-ob-contr-attr       .
define buffer old-arh-fin-ob-contr-obj-attr         for src.arh-fin-ob-contr-obj-attr   .


define variable var-fact-order-findoc as decimal no-undo.
on WRITE of dst.arh-fin-doc-an               override do: end.
on WRITE of dst.arh-fin-doc-an-nal           override do: end.
on WRITE of dst.arh-fin-doc-an-nal-obj       override do: end.
on WRITE of dst.arh-fin-doc-an-obj           override do: end.
on WRITE of dst.arh-fin-doc-c-s-tax-nal-obj  override do: end.
on WRITE of dst.arh-fin-doc-c-schet-tax-nal  override do: end.
on WRITE of dst.arh-fin-doc-contr-s-nal-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-s-tax-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet      override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-nal  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-obj  override do: end.
on WRITE of dst.arh-fin-doc-contr-schet-tax  override do: end.
on WRITE of dst.arh-fin-doc-s-tax-nal-obj    override do: end.
on WRITE of dst.arh-fin-doc-schet            override do: end.
on WRITE of dst.arh-fin-doc-schet-nal        override do: end.
on WRITE of dst.arh-fin-doc-schet-nal-obj    override do: end.
on WRITE of dst.arh-fin-doc-schet-obj        override do: end.
on WRITE of dst.arh-fin-doc-schet-tax        override do: end.
on WRITE of dst.arh-fin-doc-schet-tax-nal    override do: end.
on WRITE of dst.arh-fin-doc-schet-tax-obj    override do: end.
on WRITE of dst.arh-fin-ob-contr             override do: end.
on WRITE of dst.arh-fin-ob-contr-obj         override do: end.

on WRITE of  dst.arh-fin-doc-an-attr          override do: end.
on WRITE of  dst.arh-fin-doc-an-nal-attr      override do: end.
on WRITE of  dst.arh-fin-doc-an-nal-obj-attr  override do: end.
on WRITE of  dst.arh-fin-doc-an-obj-attr      override do: end.
on WRITE of  dst.arh-fin-doc-contr-schet-attr override do: end.
on WRITE of  dst.arh-fin-doc-schet-attr       override do: end.
on WRITE of  dst.arh-fin-doc-schet-nal-attr   override do: end.
on WRITE of  dst.arh-fin-doc-schet-obj-attr   override do: end.
on WRITE of  dst.arh-fin-doc-schet-tax-attr   override do: end.
on WRITE of  dst.arh-fin-ob-contr-attr        override do: end.
on WRITE of  dst.arh-fin-ob-contr-obj-attr    override do: end.

do
on error undo, return error return-value
:
  { utl/00000001.i }
run factord-end-day in this-procedure ( vardate-actual-findoc - 1, output var-fact-order-findoc).

&scop remove-table ~
  for each old-~{&arh-table-name~} no-lock on error undo, return error return-value : ~
    if old-~{&arh-table-name~}.fact-order > var-fact-order-findoc then do:            ~
      create new-~{&arh-table-name~}.                                                 ~
      buffer-copy old-~{&arh-table-name~} to new-~{&arh-table-name~}.                 ~
    end.                                                                              ~
    else do:                                                                          ~
      find first bf_~{&arh-table-name~} where ~{&find-where~} no-error.               ~
      if not available bf_~{&arh-table-name~} then do:                                ~
        create new-~{&arh-table-name~}.                                               ~
        buffer-copy old-~{&arh-table-name~} to new-~{&arh-table-name~}.               ~
      end.                                                                            ~
    end.                                                                              ~
  end.
  &scop arh-table-name arh-fin-doc-an
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code               and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet              and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type        and ~
                       bf_~{&arh-table-name~}.fin-code-an-uchet = old-~{&arh-table-name~}.fin-code-an-uchet       and ~
                       bf_~{&arh-table-name~}.fin-code-cel-nazn = old-~{&arh-table-name~}.fin-code-cel-nazn       and ~
                       bf_~{&arh-table-name~}.fin-code-cor-acc  = old-~{&arh-table-name~}.fin-code-cor-acc        and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code          and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-an-nal
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code               and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc            and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code               and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type        and ~
                       bf_~{&arh-table-name~}.fin-code-an-uchet = old-~{&arh-table-name~}.fin-code-an-uchet       and ~
                       bf_~{&arh-table-name~}.fin-code-cel-nazn = old-~{&arh-table-name~}.fin-code-cel-nazn       and ~
                       bf_~{&arh-table-name~}.fin-code-cor-acc  = old-~{&arh-table-name~}.fin-code-cor-acc        and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code          and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-an-nal-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code               and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc            and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code               and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type        and ~
                       bf_~{&arh-table-name~}.fin-code-an-uchet = old-~{&arh-table-name~}.fin-code-an-uchet       and ~
                       bf_~{&arh-table-name~}.fin-code-cel-nazn = old-~{&arh-table-name~}.fin-code-cel-nazn       and ~
                       bf_~{&arh-table-name~}.fin-code-cor-acc  = old-~{&arh-table-name~}.fin-code-cor-acc        and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code          and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-an-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code               and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type                and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code                and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type                and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code                and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet              and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type        and ~
                       bf_~{&arh-table-name~}.fin-code-an-uchet = old-~{&arh-table-name~}.fin-code-an-uchet       and ~
                       bf_~{&arh-table-name~}.fin-code-cel-nazn = old-~{&arh-table-name~}.fin-code-cel-nazn       and ~
                       bf_~{&arh-table-name~}.fin-code-cor-acc  = old-~{&arh-table-name~}.fin-code-cor-acc        and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code          and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type                and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order              and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-c-s-tax-nal-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-c-schet-tax-nal
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-s-nal-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-s-tax-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-schet
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-schet-nal
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-schet-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-contr-schet-tax
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-s-tax-nal-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-nal
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-nal-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-tax
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-tax-nal
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-code-acc      = old-~{&arh-table-name~}.fin-code-acc     and ~
                       bf_~{&arh-table-name~}.curr-code         = old-~{&arh-table-name~}.curr-code        and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-doc-schet-tax-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.code-schet        = old-~{&arh-table-name~}.code-schet       and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.VAT-pc            = old-~{&arh-table-name~}.VAT-pc           and ~
                       bf_~{&arh-table-name~}.SLT-pc            = old-~{&arh-table-name~}.SLT-pc           and ~
                       bf_~{&arh-table-name~}.with-vat          = old-~{&arh-table-name~}.with-vat         and ~
                       bf_~{&arh-table-name~}.with-slt          = old-~{&arh-table-name~}.with-slt         and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-ob-contr
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}
  &scop arh-table-name arh-fin-ob-contr-obj
  &scop find-where     bf_~{&arh-table-name~}.host-code         = old-~{&arh-table-name~}.host-code        and ~
                       bf_~{&arh-table-name~}.obj-type          = old-~{&arh-table-name~}.obj-type         and ~
                       bf_~{&arh-table-name~}.obj-code          = old-~{&arh-table-name~}.obj-code         and ~
                       bf_~{&arh-table-name~}.contract-code     = old-~{&arh-table-name~}.contract-code    and ~
                       bf_~{&arh-table-name~}.cli-type          = old-~{&arh-table-name~}.cli-type         and ~
                       bf_~{&arh-table-name~}.cli-code          = old-~{&arh-table-name~}.cli-code         and ~
                       bf_~{&arh-table-name~}.fin-ext-doc-type  = old-~{&arh-table-name~}.fin-ext-doc-type and ~
                       bf_~{&arh-table-name~}.calc-curr-code    = old-~{&arh-table-name~}.calc-curr-code   and ~
                       bf_~{&arh-table-name~}.sum-type          = old-~{&arh-table-name~}.sum-type         and ~
                       bf_~{&arh-table-name~}.fact-order        > old-~{&arh-table-name~}.fact-order       and ~
                       bf_~{&arh-table-name~}.fact-order       <= var-fact-order-findoc
  {&remove-table}


  { utl/00000002.i arh-fin-doc-an-attr    "  no-lock , first new-arh-fin-doc-an where ~
  new-arh-fin-doc-an.host-code         = old-arh-fin-doc-an-attr.host-code  and  ~
  new-arh-fin-doc-an.cli-type          = old-arh-fin-doc-an-attr.cli-type   and  ~
  new-arh-fin-doc-an.cli-code          = old-arh-fin-doc-an-attr.cli-code    and ~
  new-arh-fin-doc-an.code-schet        = old-arh-fin-doc-an-attr.code-schet   and ~
  new-arh-fin-doc-an.fin-ext-doc-type  = old-arh-fin-doc-an-attr.fin-ext-doc-type  and ~
  new-arh-fin-doc-an.fin-code-an-uchet = old-arh-fin-doc-an-attr.fin-code-an-uchet  and ~
  new-arh-fin-doc-an.fin-code-cel-nazn = old-arh-fin-doc-an-attr.fin-code-cel-nazn  and ~
  new-arh-fin-doc-an.fin-code-cor-acc  = old-arh-fin-doc-an-attr.fin-code-cor-acc  and ~
  new-arh-fin-doc-an.calc-curr-code    = old-arh-fin-doc-an-attr.calc-curr-code  and  ~
  new-arh-fin-doc-an.sum-type          = old-arh-fin-doc-an-attr.sum-type    and   ~
  new-arh-fin-doc-an.fact-order        = old-arh-fin-doc-an-attr.fact-order  " }

  { utl/00000002.i arh-fin-doc-an-nal-attr " no-lock , first new-arh-fin-doc-an-nal where ~
new-arh-fin-doc-an-nal.host-code         = old-arh-fin-doc-an-nal-attr.host-code         and  ~
new-arh-fin-doc-an-nal.cli-type          = old-arh-fin-doc-an-nal-attr.cli-type          and  ~
new-arh-fin-doc-an-nal.cli-code          = old-arh-fin-doc-an-nal-attr.cli-code          and  ~
new-arh-fin-doc-an-nal.fin-code-acc      = old-arh-fin-doc-an-nal-attr.fin-code-acc      and  ~
new-arh-fin-doc-an-nal.curr-code         = old-arh-fin-doc-an-nal-attr.curr-code         and  ~
new-arh-fin-doc-an-nal.fin-ext-doc-type  = old-arh-fin-doc-an-nal-attr.fin-ext-doc-type  and  ~
new-arh-fin-doc-an-nal.fin-code-an-uchet = old-arh-fin-doc-an-nal-attr.fin-code-an-uchet and  ~
new-arh-fin-doc-an-nal.fin-code-cel-nazn = old-arh-fin-doc-an-nal-attr.fin-code-cel-nazn and  ~
new-arh-fin-doc-an-nal.fin-code-cor-acc  = old-arh-fin-doc-an-nal-attr.fin-code-cor-acc  and  ~
new-arh-fin-doc-an-nal.calc-curr-code    = old-arh-fin-doc-an-nal-attr.calc-curr-code    and  ~
new-arh-fin-doc-an-nal.sum-type          = old-arh-fin-doc-an-nal-attr.sum-type          and  ~
new-arh-fin-doc-an-nal.fact-order        = old-arh-fin-doc-an-nal-attr.fact-order        " }

  { utl/00000002.i arh-fin-doc-an-nal-obj-attr " no-lock , first new-arh-fin-doc-an-nal-obj where ~
new-arh-fin-doc-an-nal-obj.host-code         = old-arh-fin-doc-an-nal-obj-attr.host-code          and  ~
new-arh-fin-doc-an-nal-obj.obj-type          = old-arh-fin-doc-an-nal-obj-attr.obj-type           and  ~
new-arh-fin-doc-an-nal-obj.obj-code          = old-arh-fin-doc-an-nal-obj-attr.obj-code           and  ~
new-arh-fin-doc-an-nal-obj.cli-type          = old-arh-fin-doc-an-nal-obj-attr.cli-type           and  ~
new-arh-fin-doc-an-nal-obj.cli-code          = old-arh-fin-doc-an-nal-obj-attr.cli-code           and  ~
new-arh-fin-doc-an-nal-obj.fin-code-acc      = old-arh-fin-doc-an-nal-obj-attr.fin-code-acc       and  ~
new-arh-fin-doc-an-nal-obj.curr-code         = old-arh-fin-doc-an-nal-obj-attr.curr-code          and  ~
new-arh-fin-doc-an-nal-obj.fin-ext-doc-type  = old-arh-fin-doc-an-nal-obj-attr.fin-ext-doc-type   and  ~
new-arh-fin-doc-an-nal-obj.fin-code-an-uchet = old-arh-fin-doc-an-nal-obj-attr.fin-code-an-uchet  and  ~
new-arh-fin-doc-an-nal-obj.fin-code-cel-nazn = old-arh-fin-doc-an-nal-obj-attr.fin-code-cel-nazn  and  ~
new-arh-fin-doc-an-nal-obj.fin-code-cor-acc  = old-arh-fin-doc-an-nal-obj-attr.fin-code-cor-acc   and  ~
new-arh-fin-doc-an-nal-obj.calc-curr-code    = old-arh-fin-doc-an-nal-obj-attr.calc-curr-code     and  ~
new-arh-fin-doc-an-nal-obj.sum-type          = old-arh-fin-doc-an-nal-obj-attr.sum-type           and  ~
new-arh-fin-doc-an-nal-obj.fact-order        = old-arh-fin-doc-an-nal-obj-attr.fact-order      " }

  { utl/00000002.i arh-fin-doc-an-obj-attr  " no-lock , first new-arh-fin-doc-an-obj where ~
new-arh-fin-doc-an-obj.host-code           = old-arh-fin-doc-an-obj-attr.host-code           and  ~
new-arh-fin-doc-an-obj.obj-type            = old-arh-fin-doc-an-obj-attr.obj-type            and  ~
new-arh-fin-doc-an-obj.obj-code            = old-arh-fin-doc-an-obj-attr.obj-code            and  ~
new-arh-fin-doc-an-obj.cli-type            = old-arh-fin-doc-an-obj-attr.cli-type            and  ~
new-arh-fin-doc-an-obj.cli-code            = old-arh-fin-doc-an-obj-attr.cli-code            and  ~
new-arh-fin-doc-an-obj.code-schet          = old-arh-fin-doc-an-obj-attr.code-schet          and  ~
new-arh-fin-doc-an-obj.fin-ext-doc-type    = old-arh-fin-doc-an-obj-attr.fin-ext-doc-type    and  ~
new-arh-fin-doc-an-obj.fin-code-an-uchet   = old-arh-fin-doc-an-obj-attr.fin-code-an-uchet   and  ~
new-arh-fin-doc-an-obj.fin-code-cel-nazn   = old-arh-fin-doc-an-obj-attr.fin-code-cel-nazn   and  ~
new-arh-fin-doc-an-obj.fin-code-cor-acc    = old-arh-fin-doc-an-obj-attr.fin-code-cor-acc    and  ~
new-arh-fin-doc-an-obj.calc-curr-code      = old-arh-fin-doc-an-obj-attr.calc-curr-code      and  ~
new-arh-fin-doc-an-obj.sum-type            = old-arh-fin-doc-an-obj-attr.sum-type            and  ~
new-arh-fin-doc-an-obj.fact-order          = old-arh-fin-doc-an-obj-attr.fact-order          " }

  { utl/00000002.i arh-fin-doc-contr-schet-attr  " no-lock , first new-arh-fin-doc-contr-schet where ~
new-arh-fin-doc-contr-schet.host-code          = old-arh-fin-doc-contr-schet-attr.host-code           and  ~
new-arh-fin-doc-contr-schet.contract-code      = old-arh-fin-doc-contr-schet-attr.contract-code       and  ~
new-arh-fin-doc-contr-schet.cli-type           = old-arh-fin-doc-contr-schet-attr.cli-type            and  ~
new-arh-fin-doc-contr-schet.cli-code           = old-arh-fin-doc-contr-schet-attr.cli-code            and  ~
new-arh-fin-doc-contr-schet.code-schet         = old-arh-fin-doc-contr-schet-attr.code-schet          and  ~
new-arh-fin-doc-contr-schet.fin-ext-doc-type   = old-arh-fin-doc-contr-schet-attr.fin-ext-doc-type    and  ~
new-arh-fin-doc-contr-schet.calc-curr-code     = old-arh-fin-doc-contr-schet-attr.calc-curr-code      and  ~
new-arh-fin-doc-contr-schet.sum-type           = old-arh-fin-doc-contr-schet-attr.sum-type            and  ~
new-arh-fin-doc-contr-schet.fact-order         = old-arh-fin-doc-contr-schet-attr.fact-order          " }

  { utl/00000002.i arh-fin-doc-schet-attr        " no-lock , first new-arh-fin-doc-schet where ~
new-arh-fin-doc-schet.host-code        = old-arh-fin-doc-schet-attr.host-code          and  ~
new-arh-fin-doc-schet.cli-type         = old-arh-fin-doc-schet-attr.cli-type           and  ~
new-arh-fin-doc-schet.cli-code         = old-arh-fin-doc-schet-attr.cli-code           and  ~
new-arh-fin-doc-schet.code-schet       = old-arh-fin-doc-schet-attr.code-schet         and  ~
new-arh-fin-doc-schet.fin-ext-doc-type = old-arh-fin-doc-schet-attr.fin-ext-doc-type   and  ~
new-arh-fin-doc-schet.calc-curr-code   = old-arh-fin-doc-schet-attr.calc-curr-code     and  ~
new-arh-fin-doc-schet.sum-type         = old-arh-fin-doc-schet-attr.sum-type           and  ~
new-arh-fin-doc-schet.fact-order       = old-arh-fin-doc-schet-attr.fact-order         " }

  { utl/00000002.i arh-fin-doc-schet-nal-attr    " no-lock , first new-arh-fin-doc-schet-nal where ~
new-arh-fin-doc-schet-nal.host-code         = old-arh-fin-doc-schet-nal-attr.host-code           and  ~
new-arh-fin-doc-schet-nal.cli-type          = old-arh-fin-doc-schet-nal-attr.cli-type            and  ~
new-arh-fin-doc-schet-nal.cli-code          = old-arh-fin-doc-schet-nal-attr.cli-code            and  ~
new-arh-fin-doc-schet-nal.fin-code-acc      = old-arh-fin-doc-schet-nal-attr.fin-code-acc        and  ~
new-arh-fin-doc-schet-nal.curr-code         = old-arh-fin-doc-schet-nal-attr.curr-code           and  ~
new-arh-fin-doc-schet-nal.fin-ext-doc-type  = old-arh-fin-doc-schet-nal-attr.fin-ext-doc-type    and  ~
new-arh-fin-doc-schet-nal.calc-curr-code    = old-arh-fin-doc-schet-nal-attr.calc-curr-code      and  ~
new-arh-fin-doc-schet-nal.sum-type          = old-arh-fin-doc-schet-nal-attr.sum-type            and  ~
new-arh-fin-doc-schet-nal.fact-order        = old-arh-fin-doc-schet-nal-attr.fact-order          " }

  { utl/00000002.i arh-fin-doc-schet-obj-attr    " no-lock , first new-arh-fin-doc-schet-obj where ~
new-arh-fin-doc-schet-obj.host-code         = old-arh-fin-doc-schet-obj-attr.host-code           and  ~
new-arh-fin-doc-schet-obj.obj-type          = old-arh-fin-doc-schet-obj-attr.obj-type            and  ~
new-arh-fin-doc-schet-obj.obj-code          = old-arh-fin-doc-schet-obj-attr.obj-code            and  ~
new-arh-fin-doc-schet-obj.cli-type          = old-arh-fin-doc-schet-obj-attr.cli-type            and  ~
new-arh-fin-doc-schet-obj.cli-code          = old-arh-fin-doc-schet-obj-attr.cli-code            and  ~
new-arh-fin-doc-schet-obj.code-schet        = old-arh-fin-doc-schet-obj-attr.code-schet          and  ~
new-arh-fin-doc-schet-obj.fin-ext-doc-type  = old-arh-fin-doc-schet-obj-attr.fin-ext-doc-type    and  ~
new-arh-fin-doc-schet-obj.calc-curr-code    = old-arh-fin-doc-schet-obj-attr.calc-curr-code      and  ~
new-arh-fin-doc-schet-obj.sum-type          = old-arh-fin-doc-schet-obj-attr.sum-type            and  ~
new-arh-fin-doc-schet-obj.fact-order        = old-arh-fin-doc-schet-obj-attr.fact-order          " }

  { utl/00000002.i arh-fin-doc-schet-tax-attr    " no-lock , first new-arh-fin-doc-schet-tax where ~
new-arh-fin-doc-schet-tax.host-code              = old-arh-fin-doc-schet-tax-attr.host-code        and  ~
new-arh-fin-doc-schet-tax.cli-type               = old-arh-fin-doc-schet-tax-attr.cli-type         and  ~
new-arh-fin-doc-schet-tax.cli-code               = old-arh-fin-doc-schet-tax-attr.cli-code         and  ~
new-arh-fin-doc-schet-tax.code-schet             = old-arh-fin-doc-schet-tax-attr.code-schet       and  ~
new-arh-fin-doc-schet-tax.fin-ext-doc-type       = old-arh-fin-doc-schet-tax-attr.fin-ext-doc-type and  ~
new-arh-fin-doc-schet-tax.calc-curr-code         = old-arh-fin-doc-schet-tax-attr.calc-curr-code   and  ~
new-arh-fin-doc-schet-tax.VAT-pc                 = old-arh-fin-doc-schet-tax-attr.VAT-pc           and  ~
new-arh-fin-doc-schet-tax.SLT-pc                 = old-arh-fin-doc-schet-tax-attr.SLT-pc           and  ~
new-arh-fin-doc-schet-tax.with-vat               = old-arh-fin-doc-schet-tax-attr.with-vat         and  ~
new-arh-fin-doc-schet-tax.with-slt               = old-arh-fin-doc-schet-tax-attr.with-slt         and  ~
new-arh-fin-doc-schet-tax.sum-type               = old-arh-fin-doc-schet-tax-attr.sum-type         and  ~
new-arh-fin-doc-schet-tax.fact-order             = old-arh-fin-doc-schet-tax-attr.fact-order       " }

  { utl/00000002.i arh-fin-ob-contr-attr    " no-lock , first new-arh-fin-ob-contr      where ~
new-arh-fin-ob-contr.host-code         = old-arh-fin-ob-contr-attr.host-code         and  ~
new-arh-fin-ob-contr.contract-code     = old-arh-fin-ob-contr-attr.contract-code     and  ~
new-arh-fin-ob-contr.cli-type          = old-arh-fin-ob-contr-attr.cli-type          and  ~
new-arh-fin-ob-contr.cli-code          = old-arh-fin-ob-contr-attr.cli-code          and  ~
new-arh-fin-ob-contr.fin-ext-doc-type  = old-arh-fin-ob-contr-attr.fin-ext-doc-type  and  ~
new-arh-fin-ob-contr.calc-curr-code    = old-arh-fin-ob-contr-attr.calc-curr-code    and  ~
new-arh-fin-ob-contr.sum-type          = old-arh-fin-ob-contr-attr.sum-type          and  ~
new-arh-fin-ob-contr.fact-order        = old-arh-fin-ob-contr-attr.fact-order         " }


  { utl/00000002.i arh-fin-ob-contr-obj-attr     " no-lock , first new-arh-fin-ob-contr-obj  where ~
new-arh-fin-ob-contr-obj.host-code          = old-arh-fin-ob-contr-obj-attr.host-code          and  ~
new-arh-fin-ob-contr-obj.obj-type           = old-arh-fin-ob-contr-obj-attr.obj-type           and  ~
new-arh-fin-ob-contr-obj.obj-code           = old-arh-fin-ob-contr-obj-attr.obj-code           and  ~
new-arh-fin-ob-contr-obj.contract-code      = old-arh-fin-ob-contr-obj-attr.contract-code      and  ~
new-arh-fin-ob-contr-obj.cli-type           = old-arh-fin-ob-contr-obj-attr.cli-type           and  ~
new-arh-fin-ob-contr-obj.cli-code           = old-arh-fin-ob-contr-obj-attr.cli-code           and  ~
new-arh-fin-ob-contr-obj.fin-ext-doc-type   = old-arh-fin-ob-contr-obj-attr.fin-ext-doc-type   and  ~
new-arh-fin-ob-contr-obj.calc-curr-code     = old-arh-fin-ob-contr-obj-attr.calc-curr-code     and  ~
new-arh-fin-ob-contr-obj.sum-type           = old-arh-fin-ob-contr-obj-attr.sum-type           and  ~
new-arh-fin-ob-contr-obj.fact-order         = old-arh-fin-ob-contr-obj-attr.fact-order         " }


   /*
  { utl/00000002.i arh-trn-doc-contract-attr     " no-lock , first new-arh-trn-doc-contract  where ~
new-arh-trn-doc-contract.host-code        = old-arh-trn-doc-contract.host-code       and  ~
new-arh-trn-doc-contract.contract-code    = old-arh-trn-doc-contract.contract-code   and  ~
new-arh-trn-doc-contract.cli-type         = old-arh-trn-doc-contract.cli-type        and  ~
new-arh-trn-doc-contract.cli-code         = old-arh-trn-doc-contract.cli-code        and  ~
new-arh-trn-doc-contract.obj-type         = old-arh-trn-doc-contract.obj-type        and  ~
new-arh-trn-doc-contract.obj-code         = old-arh-trn-doc-contract.obj-code        and  ~
new-arh-trn-doc-contract.ext-doc-type     = old-arh-trn-doc-contract.ext-doc-type    and  ~
new-arh-trn-doc-contract.sum-type         = old-arh-trn-doc-contract.sum-type        and  ~
new-arh-trn-doc-contract.fact-order       = old-arh-trn-doc-contract.fact-order      " }
     */
  output stream str-gen close.
  return "Произведен экспорт таблиц:  arh-fin-doc-an arh-fin-doc-an-nal arh-fin-doc-an-nal-obj arh-fin-doc-an-obj arh-fin-doc-c-s-tax-nal-obj arh-fin-doc-c-schet-tax-nal arh-fin-doc-contr-s-nal-obj arh-fin-doc-contr-s-tax-obj arh-fin-doc-contr-schet arh-fin-doc-contr-schet-nal arh-fin-doc-contr-schet-obj arh-fin-doc-contr-schet-tax arh-fin-doc-s-tax-nal-obj arh-fin-doc-schet arh-fin-doc-schet-nal arh-fin-doc-schet-nal-obj arh-fin-doc-schet-obj arh-fin-doc-schet-tax arh-fin-doc-schet-tax-nal arh-fin-doc-schet-tax-obj arh-fin-ob-contr arh-fin-ob-contr-obj.".
end.