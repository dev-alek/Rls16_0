block-level on error undo, throw.
/*

$Revision: 36493b7e3299, 155, rls $
$Author: EShklyar $
$Date: Tue Feb 17 18:03:53 2015 +0400 $
$Workfile: 00043002.p $
$Archive: cut/00043002.p $

Файл пирога обрезания. Относится к категории 43.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
trn-doc-sum
c-trn-doc-sum
doc-line-sum
c-doc-line-sum
parts-root
parts-supp
parts-attr
arh-trn-doc-contract

*/

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043002.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00043002.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 43.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }

define buffer old-trn-doc              for src.trn-doc.
define buffer new-trn-doc              for dst.trn-doc.
define buffer old-doc-line             for src.doc-line.
define buffer new-doc-line             for dst.doc-line.
define buffer old-parts                for src.parts.
define buffer new-parts                for dst.parts.
define buffer new-goods                for dst.goods.
define buffer old-clients              for src.clients.

define buffer old-trn-doc-sum          for src.trn-doc-sum.
define buffer new-trn-doc-sum          for dst.trn-doc-sum.
define buffer old-c-trn-doc-sum          for src.c-trn-doc-sum.
define buffer new-c-trn-doc-sum          for dst.c-trn-doc-sum.

define buffer old-doc-line-sum         for src.doc-line-sum.
define buffer new-doc-line-sum         for dst.doc-line-sum.
define buffer old-c-doc-line-sum       for src.c-doc-line-sum.
define buffer new-c-doc-line-sum       for dst.c-doc-line-sum.

define buffer old-parts-root           for src.parts-root.
define buffer new-parts-root           for dst.parts-root.

define buffer old-parts-root-attr           for src.parts-root-attr.
define buffer new-parts-root-attr           for dst.parts-root-attr.

define buffer old-parts-attr           for src.parts-attr     .
define buffer new-parts-attr           for dst.parts-attr     .

define buffer old-parts-supp           for src.parts-supp.
define buffer new-parts-supp           for dst.parts-supp.

define buffer old-parts-supp-attr          for src.parts-supp-attr.
define buffer new-parts-supp-attr          for dst.parts-supp-attr.


define buffer old-arh-trn-doc-contract      for src.arh-trn-doc-contract.
define buffer old-arh-trn-doc-contract-attr      for src.arh-trn-doc-contract-attr.
define buffer old-next-arh-trn-doc-contract for src.arh-trn-doc-contract.
define buffer new-arh-trn-doc-contract      for dst.arh-trn-doc-contract.
define buffer new-arh-trn-doc-contract-attr      for dst.arh-trn-doc-contract-attr.
define buffer old-parts-obj-attr for src.parts-obj-attr.
define buffer new-parts-obj-attr for dst.parts-obj-attr.
define buffer old-c-parts-obj-attr for src.c-parts-obj-attr.
define buffer new-c-parts-obj-attr for dst.c-parts-obj-attr.

define variable var-fact-order-docs as decimal no-undo .

if transaction then do:
  return error substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile ).
end.

do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.trn-doc-sum               override do: end.
  on WRITE of dst.c-trn-doc-sum               override do: end.
  on WRITE of dst.doc-line-sum              override do: end.
  on WRITE of dst.c-doc-line-sum            override do: end.
  on WRITE of dst.parts-root                override do: end.
  on WRITE of dst.parts-supp                override do: end.
  on WRITE of dst.parts-root-attr           override do: end.
  on WRITE of dst.parts-supp-attr           override do: end.
  on WRITE of dst.parts-attr                override do: end.
  on WRITE of dst.arh-trn-doc-contract      override do: end.
  on WRITE of dst.arh-trn-doc-contract-attr override do: end.
  on WRITE of dst.parts-obj-attr            override do: end.
  on WRITE of dst.c-parts-obj-attr          override do: end.



   { utl/00000002.i parts-supp   " no-lock , first new-goods where new-goods.artic = old-parts-supp.artic and new-goods.prod-type = old-parts-supp.prod-type and new-goods.prod-code = old-parts-supp.prod-code "   }
   { utl/00000002.i parts-supp-attr   " no-lock , first new-goods where new-goods.artic = old-parts-supp-attr.artic and new-goods.prod-type = old-parts-supp-attr.prod-type and new-goods.prod-code = old-parts-supp-attr.prod-code "   }

  define buffer buf_new-goods            for dst.goods        .


       for each new-parts no-lock
                on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :

/* похоже есть глюк progress при вызове (многократном) процедуры в версиях до 10-ой */
/* поэтому вместо запуска процедуры выполняем его тело и впоследствии можно вернуть назад */
/* начало процедуры copy-p-attr */
                find first buf_new-goods no-lock where
                      buf_new-goods.artic     =  new-parts.artic and
                      buf_new-goods.prod-type =  new-parts.prod-type and
                      buf_new-goods.prod-code =  new-parts.prod-code
                      no-error .

                for each old-parts-attr no-lock
                  where old-parts-attr.in-code = new-parts.in-code
                    and old-parts-attr.gds-code = buf_new-goods.gds-code
                    and old-parts-attr.part-code = new-parts.part-code
                on error undo, return error
                :

                  find first  new-parts-attr no-lock
                    where   new-parts-attr.in-code   =  old-parts-attr.in-code
                      and   new-parts-attr.gds-code  =  old-parts-attr.gds-code
                      and   new-parts-attr.part-code =  old-parts-attr.part-code
                    no-error  .
                  if not available new-parts-attr then do:
                    create new-parts-attr.
                    buffer-copy old-parts-attr to new-parts-attr
                    assign
                      new-parts-attr.fact-qnty = new-parts.fact-qnty
                      new-parts-attr.doc-qnty  = new-parts.qnty
                    .
                  end.
                end.
                for each old-parts-obj-attr no-lock
                  where old-parts-obj-attr.obj-type = new-parts.obj-type
                    and old-parts-obj-attr.obj-code = new-parts.obj-code
                    and old-parts-obj-attr.gds-code = buf_new-goods.gds-code
                    and old-parts-obj-attr.prt-code = new-parts.prt-code
                    and old-parts-obj-attr.in-code = new-parts.in-code
                    and old-parts-obj-attr.out-code = new-parts.out-code
                    and old-parts-obj-attr.part-code = new-parts.part-code
                on error undo, return error
                :
                    create new-parts-obj-attr.
                    buffer-copy old-parts-obj-attr to new-parts-obj-attr
                    .
                end.
                for each old-c-parts-obj-attr no-lock
                  where old-c-parts-obj-attr.obj-type = new-parts.obj-type
                    and old-c-parts-obj-attr.obj-code = new-parts.obj-code
                    and old-c-parts-obj-attr.gds-code = buf_new-goods.gds-code
                    and old-c-parts-obj-attr.prt-code = new-parts.prt-code
                    and old-c-parts-obj-attr.in-code = new-parts.in-code
                    and old-c-parts-obj-attr.out-code = new-parts.out-code
                    and old-c-parts-obj-attr.part-code = new-parts.part-code
                on error undo, return error
                :
                    create new-c-parts-obj-attr.
                    buffer-copy old-c-parts-obj-attr to new-c-parts-obj-attr
                    .
                end.


/* окончание процедуры copy-p-attr */
       end.

  for each new-trn-doc no-lock :
    for each old-trn-doc-sum no-lock  where
        old-trn-doc-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-trn-doc-sum.
        BUFFER-COPY old-trn-doc-sum to new-trn-doc-sum.
    end.
    if varstay-history then for each old-c-trn-doc-sum no-lock  where
        old-c-trn-doc-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-c-trn-doc-sum.
        BUFFER-COPY old-c-trn-doc-sum to new-c-trn-doc-sum.
    end.

    for each old-doc-line-sum no-lock  where
        old-doc-line-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-doc-line-sum.
        BUFFER-COPY old-doc-line-sum to new-doc-line-sum.
    end.
    if varstay-history then for each old-c-doc-line-sum no-lock  where
        old-c-doc-line-sum.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-c-doc-line-sum.
        BUFFER-COPY old-c-doc-line-sum to new-c-doc-line-sum.
    end.

    for each old-parts-root no-lock  where
        old-parts-root.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-parts-root.
        BUFFER-COPY old-parts-root to new-parts-root.
    end.
    for each old-parts-root-attr no-lock  where
        old-parts-root-attr.doc-code = new-trn-doc.doc-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        create new-parts-root-attr.
        BUFFER-COPY old-parts-root-attr to new-parts-root-attr.
    end.

  end.

  run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-docs).
  for each old-clients no-lock where old-clients.db-num <> ? on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    for each old-arh-trn-doc-contract no-lock  where
        old-arh-trn-doc-contract.obj-type = old-clients.obj-type and
        old-arh-trn-doc-contract.obj-code = old-clients.obj-code
        on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
        :
        find first new-trn-doc no-lock where new-trn-doc.doc-code = old-arh-trn-doc-contract.doc-code no-error.
        if available new-trn-doc then do:
          create new-arh-trn-doc-contract.
          BUFFER-COPY old-arh-trn-doc-contract to new-arh-trn-doc-contract.
        end.
        else do:
          find first old-next-arh-trn-doc-contract where old-next-arh-trn-doc-contract.host-code     = old-arh-trn-doc-contract.host-code     and
                                                         old-next-arh-trn-doc-contract.contract-code = old-arh-trn-doc-contract.contract-code and
                                                         old-next-arh-trn-doc-contract.cli-type      = old-arh-trn-doc-contract.cli-type      and
                                                         old-next-arh-trn-doc-contract.cli-code      = old-arh-trn-doc-contract.cli-code      and
                                                         old-next-arh-trn-doc-contract.obj-type      = old-arh-trn-doc-contract.obj-type      and
                                                         old-next-arh-trn-doc-contract.obj-code      = old-arh-trn-doc-contract.obj-code      and
                                                         old-next-arh-trn-doc-contract.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                                                         old-next-arh-trn-doc-contract.sum-type      = old-arh-trn-doc-contract.sum-type      and
                                                         old-next-arh-trn-doc-contract.fact-order    > old-arh-trn-doc-contract.fact-order    and
                                                         old-next-arh-trn-doc-contract.fact-order    <= var-fact-order-docs                   no-lock no-error.
          if not available old-next-arh-trn-doc-contract then do:
            create new-arh-trn-doc-contract.
            BUFFER-COPY old-arh-trn-doc-contract to new-arh-trn-doc-contract.
          end.
        end.

        find first old-arh-trn-doc-contract-attr no-lock  where
                    old-arh-trn-doc-contract-attr.host-code     = old-arh-trn-doc-contract.host-code     and
                    old-arh-trn-doc-contract-attr.contract-code = old-arh-trn-doc-contract.contract-code and
                    old-arh-trn-doc-contract-attr.cli-type      = old-arh-trn-doc-contract.cli-type      and
                    old-arh-trn-doc-contract-attr.cli-code      = old-arh-trn-doc-contract.cli-code      and
                    old-arh-trn-doc-contract-attr.obj-type      = old-arh-trn-doc-contract.obj-type      and
                    old-arh-trn-doc-contract-attr.obj-code      = old-arh-trn-doc-contract.obj-code      and
                    old-arh-trn-doc-contract-attr.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                    old-arh-trn-doc-contract-attr.sum-type      = old-arh-trn-doc-contract.sum-type      and
                    old-arh-trn-doc-contract-attr.fact-order    = old-arh-trn-doc-contract.fact-order
                    no-error.

        if available old-arh-trn-doc-contract-attr then do:
            find first new-arh-trn-doc-contract-attr no-lock  where
                        new-arh-trn-doc-contract-attr.host-code     = old-arh-trn-doc-contract.host-code     and
                        new-arh-trn-doc-contract-attr.contract-code = old-arh-trn-doc-contract.contract-code and
                        new-arh-trn-doc-contract-attr.cli-type      = old-arh-trn-doc-contract.cli-type      and
                        new-arh-trn-doc-contract-attr.cli-code      = old-arh-trn-doc-contract.cli-code      and
                        new-arh-trn-doc-contract-attr.obj-type      = old-arh-trn-doc-contract.obj-type      and
                        new-arh-trn-doc-contract-attr.obj-code      = old-arh-trn-doc-contract.obj-code      and
                        new-arh-trn-doc-contract-attr.ext-doc-type  = old-arh-trn-doc-contract.ext-doc-type  and
                        new-arh-trn-doc-contract-attr.sum-type      = old-arh-trn-doc-contract.sum-type      and
                        new-arh-trn-doc-contract-attr.fact-order    = old-arh-trn-doc-contract.fact-order
                        no-error.
                if not available new-arh-trn-doc-contract-attr then do:
                    create new-arh-trn-doc-contract-attr.
                    BUFFER-COPY old-arh-trn-doc-contract-attr to new-arh-trn-doc-contract-attr.
                end.

        end.

    end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: trn-doc-sum doc-line-sum parts-root parts-supp parts-attr arh-trn-doc-contract part-obj-attr c-parts-obj-attr.".
end.