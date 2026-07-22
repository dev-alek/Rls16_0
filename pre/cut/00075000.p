block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 4c8fe616231f, 2126, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:53 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00075000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00075000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 75.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-fin-bank           for src.c-fin-bank          .
define buffer old-c-fin-bank-attr      for src.c-fin-bank-attr     .
define buffer old-c-fin-code-an-uchet  for src.c-fin-code-an-uchet .
define buffer old-c-fin-code-cel-nazn  for src.c-fin-code-cel-nazn .
define buffer old-c-fin-code-cor-acc   for src.c-fin-code-cor-acc  .
define buffer old-c-fin-schet          for src.c-fin-schet         .
define buffer old-c-fin-schet-attr     for src.c-fin-schet-attr    .
define buffer old-fin-bank             for src.fin-bank            .
define buffer old-fin-bank-attr        for src.fin-bank-attr       .
define buffer old-fin-code-an-uchet    for src.fin-code-an-uchet   .
define buffer old-fin-code-cel-nazn    for src.fin-code-cel-nazn   .
define buffer old-fin-code-cor-acc     for src.fin-code-cor-acc    .
define buffer old-fin-code-an-uchet-attr    for src.fin-code-an-uchet-attr   .
define buffer old-fin-code-cel-nazn-attr    for src.fin-code-cel-nazn-attr   .
define buffer old-fin-code-cor-acc-attr     for src.fin-code-cor-acc-attr    .
define buffer old-fin-schet            for src.fin-schet           .
define buffer old-fin-schet-attr       for src.fin-schet-attr      .
define buffer old-cbr-bank             for src.cbr-bank          .
define buffer old-c-cbr-bank           for src.c-cbr-bank          .
define buffer old-cbr-bank-attr        for src.cbr-bank-attr     .
define buffer old-c-cbr-bank-attr      for src.c-cbr-bank-attr     .
define buffer old-CashBook             for src.CashBook        .
define buffer old-CashBookAttr         for src.CashBookAttr    .
define buffer old-CashBookRule         for src.CashBookRule    .
define buffer old-CashBookRuleAttr     for src.CashBookRuleAttr .
define buffer old-OperServ             for src.OperServ        .
define buffer old-OperServAttr         for src.OperServAttr    .
define buffer new-c-fin-bank           for dst.c-fin-bank          .
define buffer new-c-fin-bank-attr      for dst.c-fin-bank-attr     .
define buffer new-c-fin-code-an-uchet  for dst.c-fin-code-an-uchet .
define buffer new-c-fin-code-cel-nazn  for dst.c-fin-code-cel-nazn .
define buffer new-c-fin-code-cor-acc   for dst.c-fin-code-cor-acc  .
define buffer new-c-fin-schet          for dst.c-fin-schet         .
define buffer new-c-fin-schet-attr     for dst.c-fin-schet-attr    .
define buffer new-fin-bank             for dst.fin-bank            .
define buffer new-fin-bank-attr        for dst.fin-bank-attr       .
define buffer new-fin-code-an-uchet    for dst.fin-code-an-uchet   .
define buffer new-fin-code-cel-nazn    for dst.fin-code-cel-nazn   .
define buffer new-fin-code-cor-acc     for dst.fin-code-cor-acc    .
define buffer new-fin-code-an-uchet-attr    for dst.fin-code-an-uchet-attr   .
define buffer new-fin-code-cel-nazn-attr    for dst.fin-code-cel-nazn-attr   .
define buffer new-fin-code-cor-acc-attr     for dst.fin-code-cor-acc-attr    .
define buffer new-fin-schet            for dst.fin-schet           .
define buffer new-fin-schet-attr       for dst.fin-schet-attr      .
define buffer new-cbr-bank             for dst.cbr-bank            .
define buffer new-c-cbr-bank           for dst.c-cbr-bank          .
define buffer new-cbr-bank-attr        for dst.cbr-bank-attr       .
define buffer new-c-cbr-bank-attr      for dst.c-cbr-bank-attr     .
define buffer new-CashBook             for dst.CashBook        .
define buffer new-CashBookAttr         for dst.CashBookAttr    .
define buffer new-CashBookRule         for dst.CashBookRule    .
define buffer new-CashBookRuleAttr     for dst.CashBookRuleAttr .
define buffer new-OperServ             for dst.OperServ        .
define buffer new-OperServAttr         for dst.OperServAttr    .
define buffer buf_clients              for src.clients .
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
  on WRITE of dst.fin-bank            override do: end.
  on WRITE of dst.c-fin-bank          override do: end.
  on WRITE of dst.fin-bank-attr       override do: end.
  on WRITE of dst.c-fin-bank-attr     override do: end.
  on WRITE of dst.fin-code-an-uchet   override do: end.
  on WRITE of dst.fin-code-an-uchet-attr   override do: end.
  on WRITE of dst.c-fin-code-an-uchet override do: end.
  on WRITE of dst.fin-code-cel-nazn   override do: end.
  on WRITE of dst.fin-code-cel-nazn-attr   override do: end.
  on WRITE of dst.c-fin-code-cel-nazn      override do: end.
  on WRITE of dst.fin-code-cor-acc-attr    override do: end.
  on WRITE of dst.c-fin-code-cor-acc  override do: end.
  on WRITE of dst.fin-code-cor-acc    override do: end.
  on WRITE of dst.fin-schet           override do: end.
  on WRITE of dst.c-fin-schet         override do: end.
  on WRITE of dst.fin-schet-attr      override do: end.
  on WRITE of dst.c-fin-schet-attr    override do: end.
  on WRITE of dst.cbr-bank            override do: end.
  on WRITE of dst.c-cbr-bank          override do: end.
  on WRITE of dst.cbr-bank-attr       override do: end.
  on WRITE of dst.c-cbr-bank-attr     override do: end.
  on WRITE of dst.CashBook         override do: end.
  on WRITE of dst.CashBookAttr     override do: end.
  on WRITE of dst.CashBookRule     override do: end.
  on WRITE of dst.CashBookRuleAttr override do: end.
  on WRITE of dst.OperServ         override do: end.
  on WRITE of dst.OperServAttr     override do: end.
for each old-fin-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-bank.
   buffer-copy old-fin-bank to new-fin-bank.
end.
  if varstay-history then do:
for each old-c-fin-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-bank.
   buffer-copy old-c-fin-bank to new-c-fin-bank.
end.
  end.
for each old-fin-schet  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-schet.
   buffer-copy old-fin-schet to new-fin-schet.
end.
  if varstay-history then do:
for each old-c-fin-schet  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-schet.
   buffer-copy old-c-fin-schet to new-c-fin-schet.
end.
  end.
for each old-fin-schet-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-schet-attr.
   buffer-copy old-fin-schet-attr to new-fin-schet-attr.
end.
  if varstay-history then do:
for each old-c-fin-schet-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-schet-attr.
   buffer-copy old-c-fin-schet-attr to new-c-fin-schet-attr.
end.
  end.
for each old-fin-bank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-bank-attr.
   buffer-copy old-fin-bank-attr to new-fin-bank-attr.
end.
  if varstay-history then do:
for each old-c-fin-bank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-bank-attr.
   buffer-copy old-c-fin-bank-attr to new-c-fin-bank-attr.
end.
  end.
for each old-fin-code-an-uchet  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-an-uchet.
   buffer-copy old-fin-code-an-uchet to new-fin-code-an-uchet.
end.
for each old-fin-code-an-uchet-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-an-uchet-attr.
   buffer-copy old-fin-code-an-uchet-attr to new-fin-code-an-uchet-attr.
end.
  if varstay-history then do:
for each old-c-fin-code-an-uchet  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-code-an-uchet.
   buffer-copy old-c-fin-code-an-uchet to new-c-fin-code-an-uchet.
end.
  end.
for each old-fin-code-cel-nazn  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-cel-nazn.
   buffer-copy old-fin-code-cel-nazn to new-fin-code-cel-nazn.
end.
for each old-fin-code-cel-nazn-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-cel-nazn-attr.
   buffer-copy old-fin-code-cel-nazn-attr to new-fin-code-cel-nazn-attr.
end.
  if varstay-history then do:
for each old-c-fin-code-cel-nazn  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-code-cel-nazn.
   buffer-copy old-c-fin-code-cel-nazn to new-c-fin-code-cel-nazn.
end.
  end.
for each old-fin-code-cor-acc  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-cor-acc.
   buffer-copy old-fin-code-cor-acc to new-fin-code-cor-acc.
end.
for each old-fin-code-cor-acc-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-code-cor-acc-attr.
   buffer-copy old-fin-code-cor-acc-attr to new-fin-code-cor-acc-attr.
end.
  if varstay-history then do:
for each old-c-fin-code-cor-acc  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-fin-code-cor-acc.
   buffer-copy old-c-fin-code-cor-acc to new-c-fin-code-cor-acc.
end.
  end.
for each old-cbr-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-cbr-bank.
   buffer-copy old-cbr-bank to new-cbr-bank.
end.
  if varstay-history then do:
for each old-c-cbr-bank  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-cbr-bank.
   buffer-copy old-c-cbr-bank to new-c-cbr-bank.
end.
  end.
for each old-cbr-bank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-cbr-bank-attr.
   buffer-copy old-cbr-bank-attr to new-cbr-bank-attr.
end.
  if varstay-history then do:
for each old-c-cbr-bank-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-cbr-bank-attr.
   buffer-copy old-c-cbr-bank-attr to new-c-cbr-bank-attr.
end.
  end.
for each old-CashBook  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-CashBook.
   buffer-copy old-CashBook to new-CashBook.
end.
for each old-CashBookAttr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-CashBookAttr.
   buffer-copy old-CashBookAttr to new-CashBookAttr.
end.
  for each buf_clients no-lock
     where buf_clients.db-num >= 0
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
for each old-CashBookRule  where old-CashBookRule.Obj-type = buf_clients.obj-type
          and old-CashBookRule.Obj-code = buf_clients.obj-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-CashBookRule.
   buffer-copy old-CashBookRule to new-CashBookRule.
end.
    for each old-CashBookRule no-lock
       where old-CashBookRule.Obj-type = buf_clients.obj-type
         and old-CashBookRule.Obj-code = buf_clients.obj-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
for each old-CashBookRuleAttr  where old-CashBookRuleAttr.cashbookid = old-CashBookRule.cashbookid and old-CashBookRuleAttr.obj-type = old-CashBookRule.obj-type and old-CashBookRuleAttr.obj-code = old-CashBookRule.obj-code  and old-CashBookRuleAttr.code = old-CashBookRule.code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-CashBookRuleAttr.
   buffer-copy old-CashBookRuleAttr to new-CashBookRuleAttr.
end.
    end .
  end .
for each old-OperServ  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-OperServ.
   buffer-copy old-OperServ to new-OperServ.
end.
for each old-OperServAttr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-OperServAttr.
   buffer-copy old-OperServAttr to new-OperServAttr.
end.
output stream str-gen close.
  return "Произведен экспорт таблиц: fin-bank c-fin-bank fin-bank-attr c-fin-bank-attr ~
fin-code-an-uchet c-fin-code-an-uchet fin-code-cel-nazn c-fin-code-cel-nazn fin-code-cor-acc c-fin-code-cor-acc ~
fin-schet c-fin-schet fin-schet-attr c-fin-schet-attr cbr-bank c-cbr-bank cbr-bank-attr c-cbr-bank-attr ~
CashBook CashBookAttr CashBookRule CashBookRuleAttr OperServ OperServAttr .".
end.
