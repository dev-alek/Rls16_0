block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00013000.p $
$Archive: cut/00013000.p $
Файл пирога обрезания. Относится к категории 13.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:

clients
c-clients
c-cli-hist
clients-attr
c-clients-attr
dis-thbj-rule
c-dis-thbj-rule
dis-thbj-rule-attr
cli-grp
c-cli-grp
cli-grp-attr
c-cli-grp-attr
cli-art
cli-gds
gds-obj
c-gds-obj
c-gds-obj-ref
prt-obj
varianty-delivery-gds-obj
c-varianty-delivery-gds-obj
firm
c-firm
shop
c-shop
store
c-store
thbj-attr
c-thbj-attr
person
c-person
staff
c-staff
staff-attr
rcs-country - частично
rcs-clients - частично
ext-classif - частично
ext-classif-attr - частично
c-ext-classif - частично
dis-grp-rule -  частично
c-dis-grp-rule -  частично
dis-grp-rule-attr -  частично
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00013000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00013000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 13.".
{ cmp/str-glbl.i }

define variable v-gds-code as integer no-undo .
define variable v-ii as integer no-undo .

define buffer old-clients   for src.clients.
define buffer new-clients   for dst.clients.
define buffer old-clients-attr   for src.clients-attr.
define buffer new-clients-attr   for dst.clients-attr.
define buffer old-c-clients   for src.c-clients.
define buffer new-c-clients   for dst.c-clients.
define buffer old-c-cli-hist  for src.c-cli-hist.
define buffer new-c-cli-hist  for dst.c-cli-hist.
define buffer old-c-clients-attr   for src.c-clients-attr.
define buffer new-c-clients-attr   for dst.c-clients-attr.
define buffer old-cli-grp   for src.cli-grp.
define buffer new-cli-grp   for dst.cli-grp.
define buffer old-c-cli-grp for src.c-cli-grp.
define buffer new-c-cli-grp for dst.c-cli-grp.
define buffer old-cli-grp-attr   for src.cli-grp-attr.
define buffer new-cli-grp-attr   for dst.cli-grp-attr.
define buffer old-c-cli-grp-attr for src.c-cli-grp-attr.
define buffer new-c-cli-grp-attr for dst.c-cli-grp-attr.
define buffer old-cli-art   for src.cli-art.
define buffer new-cli-art   for dst.cli-art.
define buffer old-cli-art-attr   for src.cli-art-attr.
define buffer new-cli-art-attr   for dst.cli-art-attr.

define buffer old-cli-gds   for src.cli-gds.
define buffer new-cli-gds   for dst.cli-gds.
define buffer old-cli-gds-attr   for src.cli-gds-attr.
define buffer new-cli-gds-attr   for dst.cli-gds-attr.
define buffer old-gds-obj   for src.gds-obj.
define buffer new-gds-obj   for dst.gds-obj.
define buffer old-c-gds-obj for src.c-gds-obj.
define buffer new-c-gds-obj for dst.c-gds-obj.
define buffer old-c-gds-obj-ref for src.c-gds-obj-ref.
define buffer new-c-gds-obj-ref for dst.c-gds-obj-ref.
define buffer old-prt-obj   for src.prt-obj.
define buffer new-prt-obj   for dst.prt-obj.
define buffer old-prt-obj-attr   for src.prt-obj-attr.
define buffer new-prt-obj-attr   for dst.prt-obj-attr.
define buffer old-firm      for src.firm.
define buffer new-firm      for dst.firm.
define buffer old-c-firm    for src.c-firm.
define buffer new-c-firm    for dst.c-firm.
define buffer old-shop      for src.shop.
define buffer new-shop      for dst.shop.
define buffer old-c-shop    for src.c-shop.
define buffer new-c-shop    for dst.c-shop.
define buffer old-store     for src.store.
define buffer new-store     for dst.store.
define buffer old-c-store   for src.c-store.
define buffer new-c-store   for dst.c-store.
define buffer old-thbj-attr      for src.thbj-attr.
define buffer new-thbj-attr      for dst.thbj-attr.
define buffer old-c-thbj-attr    for src.c-thbj-attr.
define buffer new-c-thbj-attr    for dst.c-thbj-attr.
define buffer old-dis-thbj-rule      for src.dis-thbj-rule.
define buffer new-dis-thbj-rule      for dst.dis-thbj-rule.
define buffer old-c-dis-thbj-rule    for src.c-dis-thbj-rule.
define buffer new-c-dis-thbj-rule    for dst.c-dis-thbj-rule.
define buffer old-dis-thbj-rule-attr for src.dis-thbj-rule-attr.
define buffer new-dis-thbj-rule-attr for dst.dis-thbj-rule-attr.
define buffer old-person    for src.person.
define buffer new-person    for dst.person.
define buffer old-c-person  for src.c-person.
define buffer new-c-person  for dst.c-person.
define buffer old-staff    for src.staff.
define buffer new-staff    for dst.staff.
define buffer old-c-staff  for src.c-staff.
define buffer new-c-staff  for dst.c-staff.
define buffer old-staff-attr  for src.staff-attr.
define buffer new-staff-attr  for dst.staff-attr.
define buffer old-trn-doc   for src.trn-doc.
define buffer new-sysconf   for src.sysconf.
define buffer new-c-sysconf for src.c-sysconf.
define buffer new-goods     for dst.goods.
define buffer own-firm      for src.firm.
define buffer old-rcs-country   for src.rcs-country.
define buffer new-rcs-country   for dst.rcs-country.
define buffer old-rcs-clients   for src.rcs-clients.
define buffer new-rcs-clients   for dst.rcs-clients.
define buffer old-ext-classif         for src.ext-classif.
define buffer new-ext-classif         for dst.ext-classif.
define buffer old-ext-classif-attr    for src.ext-classif-attr.
define buffer new-ext-classif-attr    for dst.ext-classif-attr.
define buffer old-c-ext-classif       for src.c-ext-classif.
define buffer new-c-ext-classif       for dst.c-ext-classif.
define buffer old-dis-grp-rule    for src.dis-grp-rule.
define buffer new-dis-grp-rule    for dst.dis-grp-rule.
define buffer old-c-dis-grp-rule  for src.c-dis-grp-rule.
define buffer new-c-dis-grp-rule  for dst.c-dis-grp-rule.
define buffer old-dis-grp-rule-attr for src.dis-grp-rule-attr.
define buffer new-dis-grp-rule-attr for dst.dis-grp-rule-attr.


define buffer old-varianty-delivery-gds-obj     for src.varianty-delivery-gds-obj  .
define buffer new-varianty-delivery-gds-obj     for dst.varianty-delivery-gds-obj  .
define buffer old-c-varianty-delivery-gds-obj   for src.c-varianty-delivery-gds-obj.
define buffer new-c-varianty-delivery-gds-obj   for dst.c-varianty-delivery-gds-obj.

&scop create-clients create new-clients. ~
                     buffer-copy old-clients to new-clients. ~
                     find first old-firm where old-firm.firm-code = new-clients.obj-code no-lock. ~
                     create new-firm. ~
                     buffer-copy old-firm to new-firm. ~
                     if varstay-history then do:                                                                     ~
                      _old-c-cli-hist:                                                                                 ~
                      for each old-c-cli-hist no-lock where                                                            ~
                              old-c-cli-hist.obj-type = new-clients.obj-type                                           ~
                          and old-c-cli-hist.obj-code = new-clients.obj-code                                           ~
                      on error undo, return error                                                                      ~
                      SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):  ~
                        create new-c-cli-hist.                                                                         ~
                        buffer-copy old-c-cli-hist to new-c-cli-hist.                                                  ~
                      end.                                                                                             ~
                      for each old-c-clients no-lock where                                                             ~
                                old-c-clients.obj-type = new-clients.obj-type                                          ~
                            and old-c-clients.obj-code = new-clients.obj-code                                          ~
                        on error undo, return error                                                                    ~
                        SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):~
                        create new-c-clients.                                                                          ~
                        buffer-copy old-c-clients to new-c-clients.                                                    ~
                      end.                                                                                             ~
                      for each old-c-firm no-lock where                                                                ~
                              old-c-firm.firm-code = new-clients.obj-code                                             ~
                      on error undo, return error                                                                      ~
                      SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):  ~
                        create new-c-firm.                                                                             ~
                        buffer-copy old-c-firm to new-c-firm.                                                          ~
                      end.                                                                                             ~
                      for each old-c-clients-attr no-lock where                                                        ~
                                old-c-clients-attr.obj-type = new-clients.obj-type                                     ~
                            and old-c-clients-attr.obj-code = new-clients.obj-code                                     ~
                      on error undo, return error                                                                      ~
                      SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):  ~
                        create new-c-clients-attr.                                                                     ~
                        buffer-copy old-c-clients-attr to new-c-clients-attr.                                          ~
                      end.                                                                                             ~
                    end.


do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.clients         override do: end.
on WRITE of dst.c-clients       override do: end.
on WRITE of dst.c-cli-hist      override do: end.
on WRITE of dst.cli-grp         override do: end.
on WRITE of dst.c-cli-grp       override do: end.
on WRITE of dst.cli-grp-attr         override do: end.
on WRITE of dst.c-cli-grp-attr       override do: end.
on WRITE of dst.cli-art         override do: end.
on WRITE of dst.cli-gds         override do: end.
on WRITE of dst.cli-art-attr         override do: end.
on WRITE of dst.cli-gds-attr         override do: end.

on WRITE of dst.clients-attr    override do: end.
on WRITE of dst.c-clients-attr  override do: end.
on WRITE of dst.gds-obj         override do: end.
on WRITE of dst.c-gds-obj       override do: end.
on WRITE of dst.c-gds-obj-ref   override do: end.
on WRITE of dst.prt-obj         override do: end.
on WRITE of dst.prt-obj-attr    override do: end.
on WRITE of dst.varianty-delivery-gds-obj       override do: end.
on WRITE of dst.c-varianty-delivery-gds-obj     override do: end.
on WRITE of dst.firm            override do: end.
on WRITE of dst.c-firm          override do: end.
on WRITE of dst.shop            override do: end.
on WRITE of dst.c-shop          override do: end.
on WRITE of dst.store           override do: end.
on WRITE of dst.c-store         override do: end.
on WRITE of dst.thbj-attr            override do: end.
on WRITE of dst.c-thbj-attr          override do: end.
on WRITE of dst.dis-thbj-rule            override do: end.
on WRITE of dst.c-dis-thbj-rule          override do: end.
on WRITE of dst.dis-thbj-rule-attr       override do: end.
on WRITE of dst.person          override do: end.
on WRITE of dst.c-person        override do: end.
on WRITE of dst.staff          override do: end.
on WRITE of dst.c-staff        override do: end.
on WRITE of dst.staff-attr     override do: end.
on WRITE of dst.rcs-country     override do: end.
on WRITE of dst.rcs-clients     override do: end.
on WRITE of dst.ext-classif   override do: end.
on WRITE of dst.ext-classif-attr override do: end.
on WRITE of dst.c-ext-classif override do: end.
on WRITE of dst.dis-grp-rule   override do: end.
on WRITE of dst.c-dis-grp-rule   override do: end.
on WRITE of dst.dis-grp-rule-attr   override do: end.


for each old-clients no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   if old-clients.obj-type = {&stock} or
      old-clients.obj-type = {&shop}  or
      old-clients.obj-type = {&prs}   then do:
      create new-clients.
      buffer-copy old-clients to new-clients.
   end.
   else do:
     {&create-clients}
   end.
end.
{ utl/00000002.i shop    }
{ utl/00000002.i store   }
{ utl/00000002.i thbj-attr }
{ utl/00000002.i dis-thbj-rule }
{ utl/00000002.i dis-thbj-rule-attr }
{ utl/00000002.i person  }
{ utl/00000002.i staff   }
{ utl/00000002.i staff-attr }
{ utl/00000002.i cli-grp }
{ utl/00000002.i cli-grp-attr }
for each old-clients-attr no-lock,
    first new-clients where new-clients.obj-type = old-clients-attr.obj-type and
                            new-clients.obj-code = old-clients-attr.obj-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-clients-attr.
   buffer-copy old-clients-attr to new-clients-attr.
end.
/*персонал*/
do v-ii = 1 to num-entries({&role-list}):
  for each old-rcs-country no-lock where old-rcs-country.id begins (entry(v-ii, {&role-list}) + {&delim-par}) :
    create new-rcs-country.
    buffer-copy old-rcs-country to new-rcs-country.
  end.
end.
/*записи по И Н Н*/
for each old-rcs-clients no-lock where old-rcs-clients.id begins 'inn' + {&delim-par},
    first new-clients no-lock where
          new-clients.obj-type = substring(old-rcs-clients.obj-type, 5)
      and new-clients.obj-code = old-rcs-clients.obj-code:
  create new-rcs-clients.
  buffer-copy old-rcs-clients to new-rcs-clients.
end.



if varstay-history then do:
  for each old-c-clients no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if old-c-clients.obj-type = {&cmp} then next. /*cmp уже выгрузили*/
    create new-c-clients.
    buffer-copy old-c-clients to new-c-clients.
  end.
  for each old-c-cli-hist no-lock where old-c-cli-hist.obj-type = {&shop}
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-c-cli-hist.
    buffer-copy old-c-cli-hist to new-c-cli-hist.
  end.
  for each old-c-cli-hist no-lock where old-c-cli-hist.obj-type = {&stock}
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-c-cli-hist.
    buffer-copy old-c-cli-hist to new-c-cli-hist.
  end.
  for each old-c-cli-hist no-lock where old-c-cli-hist.obj-type = {&prs}
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-c-cli-hist.
    buffer-copy old-c-cli-hist to new-c-cli-hist.
  end.
  for each old-c-clients-attr no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if old-c-clients-attr.obj-type = {&cmp} then next. /*cmp уже выгрузили*/
    create new-c-clients-attr.
    buffer-copy old-c-clients-attr to new-c-clients-attr.
  end.
  { utl/00000002.i c-shop    }
  { utl/00000002.i c-store   }
  { utl/00000002.i c-thbj-attr }
  { utl/00000002.i c-dis-thbj-rule }
  { utl/00000002.i c-person  }
  { utl/00000002.i c-staff   }
  { utl/00000002.i c-cli-grp }
  { utl/00000002.i c-cli-grp-attr }
end. /*if varstay-history*/
for each old-cli-art no-lock,
    first new-clients where new-clients.obj-type = old-cli-art.cli-type and
                            new-clients.obj-code = old-cli-art.cli-code no-lock,
      first new-goods where new-goods.artic     = old-cli-art.artic     and
                            new-goods.prod-type = old-cli-art.prod-type and
                            new-goods.prod-code = old-cli-art.prod-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-cli-art.
   buffer-copy old-cli-art to new-cli-art.
   { utl/00000002.i cli-art-attr  " where  ~
    old-cli-art-attr.artic     = old-cli-art.artic and ~
    old-cli-art-attr.cli-art   = old-cli-art.cli-art  and ~
    old-cli-art-attr.cli-code  = old-cli-art.cli-code and ~
    old-cli-art-attr.cli-type  = old-cli-art.cli-type  and ~
    old-cli-art-attr.prod-code = old-cli-art.prod-code and ~
    old-cli-art-attr.prod-type = old-cli-art.prod-type "  }

end.
for each old-cli-gds no-lock,
    first new-clients where new-clients.obj-type = old-cli-gds.cli-type and
                            new-clients.obj-code = old-cli-gds.cli-code no-lock,
      first new-goods where new-goods.artic     = old-cli-gds.artic     and
                            new-goods.prod-type = old-cli-gds.prod-type and
                            new-goods.prod-code = old-cli-gds.prod-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-cli-gds.
    buffer-copy old-cli-gds to new-cli-gds.
   { utl/00000002.i cli-gds-attr  " where  ~
    old-cli-gds-attr.host-code = old-cli-gds.host-code and ~
    old-cli-gds-attr.artic     = old-cli-gds.artic and ~
    old-cli-gds-attr.cli-code  = old-cli-gds.cli-code and ~
    old-cli-gds-attr.cli-type  = old-cli-gds.cli-type  and ~
    old-cli-gds-attr.prod-code = old-cli-gds.prod-code and ~
    old-cli-gds-attr.prod-type = old-cli-gds.prod-type "  }

end.
for each old-gds-obj no-lock,
    first new-goods no-lock where new-goods.gds-code  = old-gds-obj.gds-code
    by old-gds-obj.gds-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-gds-obj.
    buffer-copy old-gds-obj to new-gds-obj
    assign
    new-gds-obj.free-qnty = new-gds-obj.fact-qnty
    new-gds-obj.ov-on     = false
    new-gds-obj.inv-on    = false
    .
   if v-gds-code <> old-gds-obj.gds-code
   and  varstay-history
   then do:
     for each old-c-gds-obj no-lock where
             old-c-gds-obj.gds-code = old-gds-obj.gds-code on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
       create new-c-gds-obj.
       buffer-copy old-c-gds-obj to new-c-gds-obj.
     end.
     for each old-c-gds-obj-ref no-lock where
             old-c-gds-obj-ref.gds-code = old-gds-obj.gds-code on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
       create new-c-gds-obj-ref.
       buffer-copy old-c-gds-obj-ref to new-c-gds-obj-ref.
     end.
   end.
   v-gds-code = old-gds-obj.gds-code.
end.
for each old-varianty-delivery-gds-obj no-lock,
    first new-goods where new-goods.gds-code  = old-varianty-delivery-gds-obj.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-varianty-delivery-gds-obj.
  buffer-copy old-varianty-delivery-gds-obj to new-varianty-delivery-gds-obj.
end.
if varstay-history then do:
  for each old-c-varianty-delivery-gds-obj no-lock,
      first new-goods where new-goods.gds-code  = old-c-varianty-delivery-gds-obj.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-c-varianty-delivery-gds-obj.
    buffer-copy old-c-varianty-delivery-gds-obj to new-c-varianty-delivery-gds-obj.
  end.
end.


for each old-prt-obj no-lock,
    first new-goods where new-goods.artic     = old-prt-obj.artic     and
                          new-goods.prod-type = old-prt-obj.prod-type and
                          new-goods.prod-code = old-prt-obj.prod-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-prt-obj.
    buffer-copy old-prt-obj to new-prt-obj
    assign
      new-prt-obj.free-qnty = new-prt-obj.fact-qnty
    .
    for each old-prt-obj-attr no-lock where
            old-prt-obj-attr.artic      =  old-prt-obj.artic       and
            old-prt-obj-attr.prod-type  =  old-prt-obj.prod-type   and
            old-prt-obj-attr.prod-code  =  old-prt-obj.prod-code   and
            old-prt-obj-attr.obj-type   =  old-prt-obj.obj-type    and
            old-prt-obj-attr.obj-code   =  old-prt-obj.obj-code   :
      create new-prt-obj-attr.
      buffer-copy old-prt-obj-attr to new-prt-obj-attr.
    end.


end.
{ utl/00000002.i ext-classif   " where old-ext-classif.classif-subject = {&table_clients} " }
{ utl/00000002.i ext-classif-attr   " where old-ext-classif-attr.classif-subject = {&table_clients} " }
if varstay-history then do:
  { utl/00000002.i c-ext-classif   " where old-c-ext-classif.classif-subject = {&table_clients} " }
end.
{ utl/00000002.i ext-classif   " where old-ext-classif.classif-subject = {&table_cli-grp} " }
{ utl/00000002.i ext-classif-attr   " where old-ext-classif-attr.classif-subject = {&table_cli-grp} " }
if varstay-history then do:
  { utl/00000002.i c-ext-classif   " where old-c-ext-classif.classif-subject = {&table_cli-grp} " }
end.
{ utl/00000002.i dis-grp-rule   " where old-dis-grp-rule.classif-type = {&table_cli-grp} " }
{ utl/00000002.i dis-grp-rule-attr   " where old-dis-grp-rule-attr.classif-type = {&table_cli-grp} " }
if varstay-history then do:
  { utl/00000002.i c-dis-grp-rule   " where old-c-dis-grp-rule.classif-type = {&table_cli-grp} " }
end.

output stream str-gen close.
return "Произведен экспорт таблиц: clients c-clients c-cli-hist clients-attr c-clients-attr cli-grp c-cli-grp cli-grp-attr c-cli-grp-attr cli-art cli-gds gds-obj c-gds-obj prt-obj " +
" firm c-firm shop c-shop store c-store thbj-attr c-thbj-attr dis-thbj-rule c-dis-thbj-rule dis-thbj-rule-attr person c-person staff c-staff staff-attr" +
"varianty-delivery-gds-obj c-varianty-delivery-gds-obj rcs-country rcs-clients ext-classif c-ext-classif ext-classif-attr " .

end. /*do*/