block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00090000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00090000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 90.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer buf_old_fin-connect         for src.fin-connect        .
define buffer buf_old_c-fin-connect       for src.c-fin-connect      .
define buffer buf_old_fin-doc             for src.fin-doc            .
define buffer buf_old_fin-doc-attr        for src.fin-doc-attr       .
define buffer buf_old_fin-doc-tax         for src.fin-doc-tax        .
define buffer buf_old_fin-doc-tax-attr    for src.fin-doc-tax-attr   .
define buffer buf_old_c-fin-doc           for src.c-fin-doc          .
define buffer buf_old_c-fin-doc-attr      for src.c-fin-doc-attr     .
define buffer buf_old_c-fin-doc-tax       for src.c-fin-doc-tax      .
define buffer buf_old_fin-doc-obj         for src.fin-doc-obj        .
define buffer buf_old_fin-ob              for src.fin-ob             .
define buffer buf_old_fin-ob-attr         for src.fin-ob-attr        .
define buffer buf_old_fin-ob-tax          for src.fin-ob-tax         .
define buffer buf_old_fin-ob-tax-attr     for src.fin-ob-tax-attr    .
define buffer buf_old_fin-gds-part        for src.fin-gds-part       .
define buffer buf_old_fin-gds-part-attr   for src.fin-gds-part-attr  .
define buffer buf_old_c-fin-ob            for src.c-fin-ob           .
define buffer buf_old_c-fin-ob-attr       for src.c-fin-ob-attr      .
define buffer buf_old_c-fin-ob-tax        for src.c-fin-ob-tax       .
define buffer buf_old_c-fin-gds-part      for src.c-fin-gds-part     .
define buffer buf_old_fin-ob-before       for src.fin-ob-before      .
define buffer buf_old_fin-ob-tax-before   for src.fin-ob-tax-before  .
define buffer buf_old_fin-ob-trn          for src.fin-ob-trn         .
define buffer buf_old_fin-ob-cor-acc-lk   for src.fin-ob-cor-acc-lk  .
define buffer buf_old_fin-ob-schet-lk     for src.fin-ob-schet-lk    .
define buffer buf_old_fin-doc-cor-acc-lk  for src.fin-doc-cor-acc-lk .
define buffer buf_old_fin-doc-schet-lk    for src.fin-doc-schet-lk   .
define buffer buf_old_fin-statement       for src.fin-statement      .
define buffer buf_old_c-fin-statement     for src.c-fin-statement    .
define buffer buf_old_fin-statement-attr       for src.fin-statement-attr      .
define buffer buf_old_c-fin-statement-attr     for src.c-fin-statement-attr    .
define buffer buf_old_fin-statement-line       for src.fin-statement-line      .
define buffer buf_old_c-fin-statement-line     for src.c-fin-statement-line    .
define buffer buf_old_fin-statement-line-attr  for src.fin-statement-line-attr      .
define buffer buf_new_fin-connect         for dst.fin-connect        .
define buffer buf_new_c-fin-connect       for dst.c-fin-connect      .
define buffer buf_new_fin-doc             for dst.fin-doc            .
define buffer buf_new_fin-doc-attr        for dst.fin-doc-attr       .
define buffer buf_new_fin-doc-tax         for dst.fin-doc-tax        .
define buffer buf_new_fin-doc-tax-attr    for dst.fin-doc-tax-attr   .
define buffer buf_new_c-fin-doc           for dst.c-fin-doc          .
define buffer buf_new_c-fin-doc-attr      for dst.c-fin-doc-attr     .
define buffer buf_new_c-fin-doc-tax       for dst.c-fin-doc-tax      .
define buffer buf_new_fin-doc-obj         for dst.fin-doc-obj        .
define buffer buf_new_fin-ob              for dst.fin-ob             .
define buffer buf_new_fin-ob-attr         for dst.fin-ob-attr        .
define buffer buf_new_fin-ob-tax          for dst.fin-ob-tax         .
define buffer buf_new_fin-ob-tax-attr     for dst.fin-ob-tax-attr    .
define buffer buf_new_fin-gds-part        for dst.fin-gds-part       .
define buffer buf_new_fin-gds-part-attr   for dst.fin-gds-part-attr  .
define buffer buf_new_c-fin-ob            for dst.c-fin-ob           .
define buffer buf_new_c-fin-ob-attr       for dst.c-fin-ob-attr      .
define buffer buf_new_c-fin-ob-tax        for dst.c-fin-ob-tax       .
define buffer buf_new_c-fin-gds-part      for dst.c-fin-gds-part     .
define buffer buf_new_fin-ob-before       for dst.fin-ob-before      .
define buffer buf_new_fin-ob-tax-before   for dst.fin-ob-tax-before  .
define buffer buf_new_fin-ob-trn          for dst.fin-ob-trn         .
define buffer buf_new_fin-ob-cor-acc-lk   for dst.fin-ob-cor-acc-lk  .
define buffer buf_new_fin-ob-schet-lk     for dst.fin-ob-schet-lk    .
define buffer buf_new_fin-doc-cor-acc-lk  for dst.fin-doc-cor-acc-lk .
define buffer buf_new_fin-doc-schet-lk    for dst.fin-doc-schet-lk   .
define buffer buf_new_fin-statement       for dst.fin-statement      .
define buffer buf_new_c-fin-statement     for dst.c-fin-statement    .
define buffer buf_new_fin-statement-attr       for dst.fin-statement-attr      .
define buffer buf_new_c-fin-statement-attr     for dst.c-fin-statement-attr    .
define buffer buf_new_fin-statement-line       for dst.fin-statement-line      .
define buffer buf_new_c-fin-statement-line     for dst.c-fin-statement-line    .
define buffer buf_new_fin-statement-line-attr  for dst.fin-statement-line-attr      .
define buffer new-fin-connect-attr          for dst.fin-connect-attr            .
define buffer new-fin-doc-cor-acc-lk-attr   for dst.fin-doc-cor-acc-lk-attr     .
define buffer new-fin-doc-obj-attr          for dst.fin-doc-obj-attr            .
define buffer new-fin-doc-schet-lk-attr     for dst.fin-doc-schet-lk-attr       .
define buffer new-fin-ob-cor-acc-lk-attr    for dst.fin-ob-cor-acc-lk-attr      .
define buffer new-fin-ob-schet-lk-attr      for dst.fin-ob-schet-lk-attr        .
define buffer new-fin-ob-trn-attr           for dst.fin-ob-trn-attr             .
define buffer old-fin-connect-attr          for src.fin-connect-attr            .
define buffer old-fin-doc-cor-acc-lk-attr   for src.fin-doc-cor-acc-lk-attr     .
define buffer old-fin-doc-obj-attr          for src.fin-doc-obj-attr            .
define buffer old-fin-doc-schet-lk-attr     for src.fin-doc-schet-lk-attr       .
define buffer old-fin-ob-cor-acc-lk-attr    for src.fin-ob-cor-acc-lk-attr      .
define buffer old-fin-ob-schet-lk-attr      for src.fin-ob-schet-lk-attr        .
define buffer old-fin-ob-trn-attr           for src.fin-ob-trn-attr             .
DEFINE temp-table temp-del-yes no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY type host-code doc-code
.
DEFINE temp-table temp-del-no no-undo
  field host-code  as integer
  field doc-code   as character
  field type       as integer
  INDEX pi IS PRIMARY type host-code doc-code
.
DEFINE temp-table temp-cur no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY type host-code doc-code
.
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
  on WRITE of dst.fin-connect        override do: end.
  on WRITE of dst.c-fin-connect      override do: end.
  on WRITE of dst.fin-doc            override do: end.
  on WRITE of dst.fin-doc-attr       override do: end.
  on WRITE of dst.fin-doc-tax        override do: end.
  on WRITE of dst.fin-doc-tax-attr  override do: end.
  on WRITE of dst.c-fin-doc          override do: end.
  on WRITE of dst.c-fin-doc-attr     override do: end.
  on WRITE of dst.c-fin-doc-tax      override do: end.
  on WRITE of dst.fin-doc-obj        override do: end.
  on WRITE of dst.fin-ob             override do: end.
  on WRITE of dst.fin-ob-attr        override do: end.
  on WRITE of dst.fin-ob-tax         override do: end.
  on WRITE of dst.fin-ob-tax-attr    override do: end.
  on WRITE of dst.fin-gds-part       override do: end.
  on WRITE of dst.fin-gds-part-attr  override do: end.
  on WRITE of dst.c-fin-ob           override do: end.
  on WRITE of dst.c-fin-ob-attr      override do: end.
  on WRITE of dst.c-fin-ob-tax       override do: end.
  on WRITE of dst.c-fin-gds-part     override do: end.
  on WRITE of dst.fin-ob-before      override do: end.
  on WRITE of dst.fin-ob-tax-before  override do: end.
  on WRITE of dst.fin-ob-trn         override do: end.
  on WRITE of dst.fin-ob-cor-acc-lk  override do: end.
  on WRITE of dst.fin-ob-schet-lk    override do: end.
  on WRITE of dst.fin-doc-cor-acc-lk override do: end.
  on WRITE of dst.fin-doc-schet-lk   override do: end.
  on WRITE of dst.fin-statement      override do: end.
  on WRITE of dst.c-fin-statement    override do: end.
  on WRITE of dst.fin-statement-attr      override do: end.
  on WRITE of dst.c-fin-statement-attr    override do: end.
  on WRITE of dst.fin-statement-line      override do: end.
  on WRITE of dst.c-fin-statement-line    override do: end.
  on WRITE of dst.fin-statement-line-attr      override do: end.
on WRITE of dst.fin-connect-attr          override do: end.
on WRITE of dst.fin-doc-cor-acc-lk-attr   override do: end.
on WRITE of dst.fin-doc-obj-attr          override do: end.
on WRITE of dst.fin-doc-schet-lk-attr     override do: end.
on WRITE of dst.fin-ob-cor-acc-lk-attr    override do: end.
on WRITE of dst.fin-ob-schet-lk-attr      override do: end.
on WRITE of dst.fin-ob-trn-attr           override do: end.
  define variable is-del as logical   no-undo .
  for each buf_old_fin-ob no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    assign is-del = no .
    if  buf_old_fin-ob.fact-date <= vardate-actual-findoc then do:
      assign is-del = yes .
      if buf_old_fin-ob.con-stat < 2 then
      do:
          if buf_old_fin-ob.con-stat = 0  then
             assign is-del = yes .
          else assign is-del = no .
      end.
      else do:
        run CheckDel ( input buf_old_fin-ob.host-code, input buf_old_fin-ob.doc-code, input 0 , output is-del ) .
        if is-del = yes then do:
          for each temp-cur :
            find first temp-del-yes where
                        temp-del-yes.host-code = temp-cur.host-code and
                        temp-del-yes.doc-code  = temp-cur.doc-code  and
                        temp-del-yes.type      = temp-cur.type no-error .
            if not available temp-del-yes then do:
                create temp-del-yes.
                BUFFER-COPY temp-cur TO temp-del-yes no-error .
            end.
            delete temp-cur .
          end.
        end.
        else do:
          for each temp-cur :
            find first temp-del-no where
                        temp-del-no.host-code = temp-cur.host-code and
                        temp-del-no.doc-code  = temp-cur.doc-code  and
                        temp-del-no.type      = temp-cur.type no-error .
            if not available temp-del-no then do:
                create temp-del-no.
                BUFFER-COPY temp-cur TO temp-del-no no-error .
            end.
            delete temp-cur .
          end.
        end.
      end.
    end.
    if is-del = no then do:
      create buf_new_fin-ob.
      buffer-copy buf_old_fin-ob to buf_new_fin-ob.
      for each buf_old_fin-connect no-lock
        where buf_old_fin-connect.host-code   = buf_old_fin-ob.host-code
          and buf_old_fin-connect.fin-ob-code = buf_old_fin-ob.doc-code
        :
        create buf_new_fin-connect.
        buffer-copy buf_old_fin-connect to buf_new_fin-connect.
        if varstay-history = yes then do:
          for each buf_old_c-fin-connect no-lock
            where buf_old_c-fin-connect.host-code   = buf_old_fin-connect.host-code
              and buf_old_c-fin-connect.connect-code = buf_old_fin-connect.connect-code
            :
            create buf_new_c-fin-connect.
            buffer-copy buf_old_c-fin-connect to buf_new_c-fin-connect.
          end.
        end.
      end.
      for each buf_old_fin-ob-attr no-lock
        where buf_old_fin-ob-attr.host-code = buf_old_fin-ob.host-code
          and buf_old_fin-ob-attr.doc-code  = buf_old_fin-ob.doc-code
        :
        create buf_new_fin-ob-attr.
        buffer-copy buf_old_fin-ob-attr to buf_new_fin-ob-attr.
      end.
      for each buf_old_fin-ob-tax no-lock
        where buf_old_fin-ob-tax.host-code = buf_old_fin-ob.host-code
          and buf_old_fin-ob-tax.doc-code  = buf_old_fin-ob.doc-code
        :
        create buf_new_fin-ob-tax.
        buffer-copy buf_old_fin-ob-tax to buf_new_fin-ob-tax.
      end.
      for each buf_old_fin-ob-tax-attr no-lock
        where buf_old_fin-ob-tax-attr.host-code = buf_old_fin-ob.host-code
          and buf_old_fin-ob-tax-attr.doc-code  = buf_old_fin-ob.doc-code
        :
        create buf_new_fin-ob-tax-attr.
        buffer-copy buf_old_fin-ob-tax-attr to buf_new_fin-ob-tax-attr.
      end.
      for each buf_old_fin-gds-part no-lock
        where buf_old_fin-gds-part.host-code   = buf_old_fin-ob.host-code
          and buf_old_fin-gds-part.fin-ob-code = buf_old_fin-ob.doc-code
        :
        create buf_new_fin-gds-part.
        buffer-copy buf_old_fin-gds-part to buf_new_fin-gds-part.
      end.
      for each buf_old_fin-gds-part-attr no-lock
        where buf_old_fin-gds-part-attr.host-code   = buf_old_fin-ob.host-code
          and buf_old_fin-gds-part-attr.fin-ob-code = buf_old_fin-ob.doc-code
        :
        find first buf_new_fin-gds-part-attr no-lock where
          buf_new_fin-gds-part-attr.host-code   = buf_old_fin-gds-part-attr.host-code      and
          buf_new_fin-gds-part-attr.fin-ob-code = buf_old_fin-gds-part-attr.fin-ob-code    and
          buf_new_fin-gds-part-attr.obj-type    = buf_old_fin-gds-part-attr.obj-type       and
          buf_new_fin-gds-part-attr.obj-code    = buf_old_fin-gds-part-attr.obj-code       and
          buf_new_fin-gds-part-attr.gds-code    = buf_old_fin-gds-part-attr.gds-code       and
          buf_new_fin-gds-part-attr.in-code     = buf_old_fin-gds-part-attr.in-code        and
          buf_new_fin-gds-part-attr.part-code   = buf_old_fin-gds-part-attr.part-code      and
          buf_new_fin-gds-part-attr.out-code    = buf_old_fin-gds-part-attr.out-code       and
          buf_new_fin-gds-part-attr.doc-type    = buf_old_fin-gds-part-attr.doc-type      and
          buf_new_fin-gds-part-attr.attr-code   = buf_old_fin-gds-part-attr.attr-code    no-error .
         if not available buf_new_fin-gds-part-attr then do:
            create buf_new_fin-gds-part-attr.
            buffer-copy buf_old_fin-gds-part-attr to buf_new_fin-gds-part-attr.
         end.
      end.
      for each buf_old_fin-ob-trn no-lock
        where buf_old_fin-ob-trn.host-code = buf_old_fin-ob.host-code
          and buf_old_fin-ob-trn.doc-code  = buf_old_fin-ob.doc-code
        :
        find first dst.trn-doc no-lock where dst.trn-doc.doc-code = buf_old_fin-ob-trn.trn-doc-code no-error .
        if not available dst.trn-doc then next .
        create buf_new_fin-ob-trn.
        buffer-copy buf_old_fin-ob-trn to buf_new_fin-ob-trn.
      end.
      if varstay-history = yes then do:
        for each buf_old_c-fin-ob no-lock
          where buf_old_c-fin-ob.host-code = buf_old_fin-ob.host-code
            and buf_old_c-fin-ob.doc-code  = buf_old_fin-ob.doc-code
          :
          create buf_new_c-fin-ob.
          buffer-copy buf_old_c-fin-ob to buf_new_c-fin-ob.
          for each buf_old_c-fin-ob-attr no-lock
            where buf_old_c-fin-ob-attr.host-code = buf_old_c-fin-ob.host-code
              and buf_old_c-fin-ob-attr.doc-code  = buf_old_c-fin-ob.doc-code
              and buf_old_c-fin-ob-attr.chip-num  = buf_old_c-fin-ob.chip-num
            :
            create buf_new_c-fin-ob-attr.
            buffer-copy buf_old_c-fin-ob-attr to buf_new_c-fin-ob-attr.
          end.
          for each buf_old_c-fin-ob-tax no-lock
            where buf_old_c-fin-ob-tax.host-code = buf_old_c-fin-ob.host-code
              and buf_old_c-fin-ob-tax.doc-code  = buf_old_c-fin-ob.doc-code
              and buf_old_c-fin-ob-tax.chip-num  = buf_old_c-fin-ob.chip-num
            :
            create buf_new_c-fin-ob-tax.
            buffer-copy buf_old_c-fin-ob-tax to buf_new_c-fin-ob-tax.
          end.
          for each buf_old_c-fin-gds-part no-lock
            where buf_old_c-fin-gds-part.host-code   = buf_old_c-fin-ob.host-code
              and buf_old_c-fin-gds-part.fin-ob-code = buf_old_c-fin-ob.doc-code
              and buf_old_c-fin-gds-part.chip-num    = buf_old_c-fin-ob.chip-num
            :
            create buf_new_c-fin-gds-part.
            buffer-copy buf_old_c-fin-gds-part to buf_new_c-fin-gds-part.
          end.
        end.
      end.
    end.
  end.
  for each buf_old_fin-ob-before no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    if buf_old_fin-ob-before.status_ = 'факт':U or buf_old_fin-ob-before.doc-code <> ""  then next .
    find first dst.trn-doc no-lock where dst.trn-doc.doc-code = buf_old_fin-ob-before.trn-doc-code no-error .
    if not available dst.trn-doc then next .
    create buf_new_fin-ob-before.
    buffer-copy buf_old_fin-ob-before to buf_new_fin-ob-before.
    for each buf_old_fin-ob-tax-before no-lock
      where buf_old_fin-ob-tax-before.host-code   = buf_old_fin-ob-before.host-code
        and buf_old_fin-ob-tax-before.before-code = buf_old_fin-ob-before.before-code
      :
      create buf_new_fin-ob-tax-before.
      buffer-copy buf_old_fin-ob-tax-before to buf_new_fin-ob-tax-before.
    end.
  end.
  for each buf_old_fin-doc no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    assign is-del = no .
    if vardate-actual-findoc >= buf_old_fin-doc.fact-date  then do:
      if buf_old_fin-doc.con-stat < 2 then assign is-del = no .
      else do:
        find first temp-del-yes
          where temp-del-yes.host-code = buf_old_fin-doc.host-code
            and temp-del-yes.doc-code  = string(buf_old_fin-doc.fin-doc-code)
            and temp-del-yes.type      = 1
        no-error .
        if available temp-del-yes then is-del = yes .
      end.
    end.
    if is-del = no then do :
      create buf_new_fin-doc.
      buffer-copy buf_old_fin-doc to buf_new_fin-doc.
      for each buf_old_fin-doc-attr no-lock
        where buf_old_fin-doc-attr.host-code = buf_old_fin-doc.host-code
          and buf_old_fin-doc-attr.fin-doc-code  = buf_old_fin-doc.fin-doc-code
        :
        create buf_new_fin-doc-attr.
        buffer-copy buf_old_fin-doc-attr to buf_new_fin-doc-attr.
      end.
      for each buf_old_fin-doc-tax no-lock
        where buf_old_fin-doc-tax.host-code = buf_old_fin-doc.host-code
          and buf_old_fin-doc-tax.fin-doc-code  = buf_old_fin-doc.fin-doc-code
        :
        create buf_new_fin-doc-tax.
        buffer-copy buf_old_fin-doc-tax to buf_new_fin-doc-tax.
      end.
      for each buf_old_fin-doc-tax-attr no-lock
        where buf_old_fin-doc-tax-attr.host-code = buf_old_fin-doc.host-code
          and buf_old_fin-doc-tax-attr.fin-doc-code  = buf_old_fin-doc.fin-doc-code
        :
        create buf_new_fin-doc-tax-attr.
        buffer-copy buf_old_fin-doc-tax-attr to buf_new_fin-doc-tax-attr.
      end.
      for each buf_old_fin-doc-obj no-lock
        where buf_old_fin-doc-obj.host-code = buf_old_fin-doc.host-code
          and buf_old_fin-doc-obj.fin-doc-code  = buf_old_fin-doc.fin-doc-code
        :
        create buf_new_fin-doc-obj.
        buffer-copy buf_old_fin-doc-obj to buf_new_fin-doc-obj.
      end.
      if varstay-history = yes then do:
        for each buf_old_c-fin-doc no-lock
          where buf_old_c-fin-doc.host-code     = buf_old_fin-doc.host-code
            and buf_old_c-fin-doc.fin-doc-code  = buf_old_fin-doc.fin-doc-code
          :
          create buf_new_c-fin-doc.
          buffer-copy buf_old_c-fin-doc to buf_new_c-fin-doc.
          for each buf_old_c-fin-doc-attr no-lock
            where buf_old_c-fin-doc-attr.host-code    = buf_old_c-fin-doc.host-code
              and buf_old_c-fin-doc-attr.fin-doc-code = buf_old_c-fin-doc.fin-doc-code
              and buf_old_c-fin-doc-attr.corr-user-db-num = buf_old_c-fin-doc.corr-user-db-num
              and buf_old_c-fin-doc-attr.chip-num     = buf_old_c-fin-doc.chip-num
            :
            create buf_new_c-fin-doc-attr.
            buffer-copy buf_old_c-fin-doc-attr to buf_new_c-fin-doc-attr.
          end.
          for each buf_old_c-fin-doc-tax no-lock
            where buf_old_c-fin-doc-tax.host-code    = buf_old_c-fin-doc.host-code
              and buf_old_c-fin-doc-tax.fin-doc-code = buf_old_c-fin-doc.fin-doc-code
              and buf_old_c-fin-doc-tax.corr-user-db-num = buf_old_c-fin-doc.corr-user-db-num
              and buf_old_c-fin-doc-tax.chip-num     = buf_old_c-fin-doc.chip-num
            :
            create buf_new_c-fin-doc-tax.
            buffer-copy buf_old_c-fin-doc-tax to buf_new_c-fin-doc-tax.
          end.
        end.
      end.
    end.
  end.
  for each buf_old_fin-statement no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    assign is-del = no .
    if vardate-actual-findoc >= buf_old_fin-statement.fact-date  then do:
      create buf_new_fin-statement.
      buffer-copy buf_old_fin-statement to buf_new_fin-statement.
      for each buf_old_fin-statement-attr no-lock
        where buf_old_fin-statement-attr.host-code = buf_old_fin-statement.host-code
          and buf_old_fin-statement-attr.sttm-code  = buf_old_fin-statement.sttm-code
        :
        create buf_new_fin-statement-attr.
        buffer-copy buf_old_fin-statement-attr to buf_new_fin-statement-attr.
      end.
      for each buf_old_fin-statement-line no-lock
        where buf_old_fin-statement-line.host-code = buf_old_fin-statement.host-code
          and buf_old_fin-statement-line.sttm-code  = buf_old_fin-statement.sttm-code
        :
        create buf_new_fin-statement-line.
        buffer-copy buf_old_fin-statement-line to buf_new_fin-statement-line.
      end.
      for each buf_old_fin-statement-line-attr no-lock
        where buf_old_fin-statement-line-attr.host-code = buf_old_fin-statement.host-code
          and buf_old_fin-statement-line-attr.sttm-code  = buf_old_fin-statement.sttm-code
        :
        create buf_new_fin-statement-line-attr.
        buffer-copy buf_old_fin-statement-line-attr to buf_new_fin-statement-line-attr.
      end.
      if varstay-history = yes then do:
        for each buf_old_c-fin-statement no-lock
          where buf_old_c-fin-statement.host-code     = buf_old_fin-statement.host-code
            and buf_old_c-fin-statement.sttm-code  = buf_old_fin-statement.sttm-code
          :
          create buf_new_c-fin-statement.
          buffer-copy buf_old_c-fin-statement to buf_new_c-fin-statement.
          for each buf_old_c-fin-statement-attr no-lock
            where buf_old_c-fin-statement-attr.host-code    = buf_old_c-fin-statement.host-code
              and buf_old_c-fin-statement-attr.sttm-code = buf_old_c-fin-statement.sttm-code
              and buf_old_c-fin-statement-attr.corr-user-db-num = buf_old_c-fin-statement.corr-user-db-num
              and buf_old_c-fin-statement-attr.chip-num     = buf_old_c-fin-statement.chip-num
            :
            create buf_new_c-fin-statement-attr.
            buffer-copy buf_old_c-fin-statement-attr to buf_new_c-fin-statement-attr.
          end.
          for each buf_old_c-fin-statement-line no-lock
            where buf_old_c-fin-statement-line.host-code    = buf_old_c-fin-statement.host-code
              and buf_old_c-fin-statement-line.sttm-code = buf_old_c-fin-statement.sttm-code
              and buf_old_c-fin-statement-line.corr-user-db-num = buf_old_c-fin-statement.corr-user-db-num
              and buf_old_c-fin-statement-line.chip-num     = buf_old_c-fin-statement.chip-num
            :
            create buf_new_c-fin-statement-line.
            buffer-copy buf_old_c-fin-statement-line to buf_new_c-fin-statement-line.
          end.
        end.
      end.
    end.
  end.
  for each buf_old_fin-ob-cor-acc-lk no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    create buf_new_fin-ob-cor-acc-lk.
    buffer-copy buf_old_fin-ob-cor-acc-lk to buf_new_fin-ob-cor-acc-lk.
  end.
  for each buf_old_fin-ob-schet-lk no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    create buf_new_fin-ob-schet-lk.
    buffer-copy buf_old_fin-ob-schet-lk to buf_new_fin-ob-schet-lk.
  end.
  for each buf_old_fin-doc-cor-acc-lk no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    create buf_new_fin-doc-cor-acc-lk.
    buffer-copy buf_old_fin-doc-cor-acc-lk to buf_new_fin-doc-cor-acc-lk.
  end.
  for each buf_old_fin-doc-schet-lk no-lock
    on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
    create buf_new_fin-doc-schet-lk.
    buffer-copy buf_old_fin-doc-schet-lk to buf_new_fin-doc-schet-lk.
  end.
for each old-fin-connect-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-connect-attr.
   buffer-copy old-fin-connect-attr to new-fin-connect-attr.
end.
for each old-fin-doc-cor-acc-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-doc-cor-acc-lk-attr.
   buffer-copy old-fin-doc-cor-acc-lk-attr to new-fin-doc-cor-acc-lk-attr.
end.
for each old-fin-doc-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-doc-obj-attr.
   buffer-copy old-fin-doc-obj-attr to new-fin-doc-obj-attr.
end.
for each old-fin-doc-schet-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-doc-schet-lk-attr.
   buffer-copy old-fin-doc-schet-lk-attr to new-fin-doc-schet-lk-attr.
end.
for each old-fin-ob-cor-acc-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-ob-cor-acc-lk-attr.
   buffer-copy old-fin-ob-cor-acc-lk-attr to new-fin-ob-cor-acc-lk-attr.
end.
for each old-fin-ob-schet-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-ob-schet-lk-attr.
   buffer-copy old-fin-ob-schet-lk-attr to new-fin-ob-schet-lk-attr.
end.
for each old-fin-ob-trn-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-fin-ob-trn-attr.
   buffer-copy old-fin-ob-trn-attr to new-fin-ob-trn-attr.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: fin-connect c-fin-connect fin-doc fin-doc-attr fin-doc-tax fin-doc-tax-attr c-fin-doc c-fin-doc-attr c-fin-doc-tax fin-doc-obj fin-ob fin-ob-attr fin-ob-tax fin-gds-part c-fin-ob c-fin-ob-attr c-fin-ob-tax c-fin-gds-part fin-ob-before fin-ob-tax-before fin-ob-trn fin-ob-cor-acc-lk fin-ob-schet-lk fin-doc-cor-acc-lk fin-doc-schet-lk.".
end.
procedure CheckDel :
  do on error undo, return error return-value :
    define input  parameter p-host-code as integer   no-undo .
    define input  parameter p-doc-code  as character no-undo .
    define input  parameter p-type      as integer   no-undo .
    define output parameter p-is-del    as logical   no-undo .
    define buffer bf_fin-ob   for src.fin-ob .
    define buffer bf_fin-doc  for src.fin-doc .
    assign p-is-del = yes .
    find first temp-cur where
      temp-cur.host-code = p-host-code and
      temp-cur.doc-code  = p-doc-code  and
      temp-cur.type      = p-type     no-error .
      if  not available  temp-cur then do:
          create temp-cur .
          assign
            temp-cur.host-code = p-host-code
            temp-cur.doc-code  = p-doc-code
            temp-cur.type      = p-type
          .
    end.
    find first temp-del-yes
      where temp-del-yes.host-code = p-host-code
        and temp-del-yes.doc-code  = p-doc-code
        and temp-del-yes.type      = p-type
    no-error .
    if available temp-del-yes then do:
      assign p-is-del = yes .
      return .
    end.
    find first temp-del-no
      where temp-del-no.host-code = p-host-code
        and temp-del-no.doc-code  = p-doc-code
        and temp-del-no.type      = p-type
    no-error .
    if available temp-del-no then do:
      assign p-is-del = no .
      return .
    end.
    if p-type = 0 then do:
      for each buf_old_fin-connect no-lock
        where buf_old_fin-connect.host-code   = p-host-code
          and buf_old_fin-connect.fin-ob-code = p-doc-code
        :
        find first bf_fin-doc no-lock
          where bf_fin-doc.host-code    = buf_old_fin-connect.host-code
            and bf_fin-doc.fin-doc-code = buf_old_fin-connect.fin-doc-code
        no-error .
        if available bf_fin-doc then do:
          if ( bf_fin-doc.con-stat = 1  ) or bf_fin-doc.fact-date >= vardate-actual-findoc then do:
            assign p-is-del = no .
            return  .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = string(bf_fin-doc.fin-doc-code) and
                       temp-cur.type = 1
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-doc.fin-doc-code, input 1 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
    else do:
      for each buf_old_fin-connect no-lock
        where buf_old_fin-connect.host-code   = p-host-code
          and buf_old_fin-connect.fin-doc-code = integer (p-doc-code)
        :
        find first bf_fin-ob no-lock
          where bf_fin-ob.host-code = buf_old_fin-connect.host-code
            and bf_fin-ob.doc-code  = buf_old_fin-connect.fin-ob-code
        no-error .
        if available bf_fin-ob then do:
          if ( bf_fin-ob.con-stat = 1 and bf_fin-ob.fact-date < vardate-actual-findoc ) or bf_fin-ob.fact-date >= vardate-actual-findoc then do:
            assign p-is-del = no .
            return .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = bf_fin-ob.doc-code and
                       temp-cur.type = 0
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-ob.doc-code, input 0 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
  end.
end procedure.
