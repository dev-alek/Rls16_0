block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00193000.p $
$Archive: cut/00193000.p $

Файл пирога обрезания. Относится к категории 193.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:

wealth
c-wealth
wealth-attr
wth-gds
c-wth-gds
wth-gds-attr
c-wth-gds-attr
wth-ser
c-wth-ser
wth-ser-attr
c-wth-ser-attr
wth-par
c-wth-par
wth-par-attr
wth-obj
c-wth-obj
wth-obj-attr
wth-pobj
c-wth-pobj
wth-pobj-attr
wth-place
c-wth-place
wth-place-attr
c-wth-hist
wth-doc
wth-doc-attr
wth-line
wth-line-attr
wth-dtl
wth-dtl-attr
wth-parts
wth-parts-attr
chk-doc
c-chk-doc
chk-doc-attr
chk-pay
c-chk-pay
chk-pay-attr
wth-gds
c-wth-gds
wth-gds-attr
c-wth-gds-attr
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00193000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00193000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 193.".

define buffer old-wealth         for src.wealth.
define buffer new-wealth         for dst.wealth.
define buffer old-c-wealth       for src.c-wealth.
define buffer new-c-wealth       for dst.c-wealth.
define buffer old-wealth-attr    for src.wealth-attr.
define buffer new-wealth-attr    for dst.wealth-attr.
define buffer old-wth-gds        for src.wth-gds.
define buffer new-wth-gds        for dst.wth-gds.
define buffer old-c-wth-gds      for src.c-wth-gds.
define buffer new-c-wth-gds      for dst.c-wth-gds.
define buffer old-wth-gds-attr   for src.wth-gds-attr.
define buffer new-wth-gds-attr   for dst.wth-gds-attr.
define buffer old-c-wth-gds-attr for src.c-wth-gds-attr.
define buffer new-c-wth-gds-attr for dst.c-wth-gds-attr.
define buffer old-wth-ser        for src.wth-ser.
define buffer new-wth-ser        for dst.wth-ser.
define buffer old-c-wth-ser      for src.c-wth-ser.
define buffer new-c-wth-ser      for dst.c-wth-ser.
define buffer old-wth-ser-attr   for src.wth-ser-attr.
define buffer new-wth-ser-attr   for dst.wth-ser-attr.
define buffer old-c-wth-ser-attr for src.c-wth-ser-attr.
define buffer new-c-wth-ser-attr for dst.c-wth-ser-attr.
define buffer old-wth-par        for src.wth-par.
define buffer new-wth-par        for dst.wth-par.
define buffer old-c-wth-par      for src.c-wth-par.
define buffer new-c-wth-par      for dst.c-wth-par.
define buffer old-wth-par-attr   for src.wth-par-attr.
define buffer new-wth-par-attr   for dst.wth-par-attr.
define buffer old-wth-obj        for src.wth-obj.
define buffer new-wth-obj        for dst.wth-obj.
define buffer old-c-wth-obj      for src.c-wth-obj.
define buffer new-c-wth-obj      for dst.c-wth-obj.
define buffer old-wth-obj-attr   for src.wth-obj-attr.
define buffer new-wth-obj-attr   for dst.wth-obj-attr.
define buffer old-wth-pobj       for src.wth-pobj.
define buffer new-wth-pobj       for dst.wth-pobj.
define buffer old-c-wth-pobj     for src.c-wth-pobj.
define buffer new-c-wth-pobj     for dst.c-wth-pobj.
define buffer old-wth-pobj-attr  for src.wth-pobj-attr.
define buffer new-wth-pobj-attr  for dst.wth-pobj-attr.
define buffer old-wth-place      for src.wth-place.
define buffer new-wth-place      for dst.wth-place.
define buffer old-c-wth-place    for src.c-wth-place.
define buffer new-c-wth-place    for dst.c-wth-place.
define buffer old-wth-place-attr for src.wth-place-attr.
define buffer new-wth-place-attr for dst.wth-place-attr.
define buffer old-c-wth-hist     for src.c-wth-hist.
define buffer new-c-wth-hist     for dst.c-wth-hist.
define buffer old-wth-doc        for src.wth-doc.
define buffer new-wth-doc        for dst.wth-doc.
define buffer old-wth-doc-attr   for src.wth-doc-attr.
define buffer new-wth-doc-attr   for dst.wth-doc-attr.
define buffer old-wth-line       for src.wth-line.
define buffer new-wth-line       for dst.wth-line.
define buffer old-wth-line-attr  for src.wth-line-attr.
define buffer new-wth-line-attr  for dst.wth-line-attr.
define buffer old-wth-dtl        for src.wth-dtl.
define buffer new-wth-dtl        for dst.wth-dtl.
define buffer old-wth-dtl-attr   for src.wth-dtl-attr.
define buffer new-wth-dtl-attr   for dst.wth-dtl-attr.
define buffer old-wth-parts      for src.wth-parts.
define buffer new-wth-parts      for dst.wth-parts.
define buffer old-wth-parts-attr for src.wth-parts-attr.
define buffer new-wth-parts-attr for dst.wth-parts-attr.
define buffer old-chk-doc  for src.chk-doc.
define buffer new-chk-doc  for dst.chk-doc.
define buffer old-chk-doc-attr  for src.chk-doc-attr.
define buffer new-chk-doc-attr  for dst.chk-doc-attr.
define buffer old-c-chk-doc-attr  for src.c-chk-doc-attr.
define buffer new-c-chk-doc-attr  for dst.c-chk-doc-attr.
define buffer old-chk-pay   for src.chk-pay .
define buffer new-chk-pay   for dst.chk-pay .
define buffer old-chk-pay-attr   for src.chk-pay-attr .
define buffer new-chk-pay-attr   for dst.chk-pay-attr .
define buffer old-c-chk-doc  for src.c-chk-doc.
define buffer new-c-chk-doc  for dst.c-chk-doc.
define buffer old-c-chk-pay   for src.c-chk-pay .
define buffer new-c-chk-pay   for dst.c-chk-pay.
define buffer new-goods      for dst.goods.



define buffer new-db      for dst.db .
define buffer new-clients    for dst.clients.

define variable varactual-goods  as logical no-undo.
define variable v-temp-date as date no-undo .
define variable v-fact-order as decimal no-undo .
define variable find-fact-order  as decimal no-undo .
define temp-table temp-new-wth-line no-undo like dst.wth-line.

define stream LogStream.

{ cmp/str-glbl.i }
{ utl/tt-objs.i }


do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.wealth          override do: end.
on WRITE of dst.c-wealth        override do: end.
on WRITE of dst.wealth-attr     override do: end.
on WRITE of dst.wth-gds         override do: end.
on WRITE of dst.c-wth-gds       override do: end.
on WRITE of dst.wth-gds-attr    override do: end.
on WRITE of dst.c-wth-gds-attr  override do: end.
on WRITE of dst.wth-ser         override do: end.
on WRITE of dst.c-wth-ser       override do: end.
on WRITE of dst.wth-ser-attr    override do: end.
on WRITE of dst.c-wth-ser-attr  override do: end.
on WRITE of dst.wth-par         override do: end.
on WRITE of dst.c-wth-par       override do: end.
on WRITE of dst.wth-par-attr    override do: end.
on WRITE of dst.wth-obj         override do: end.
on WRITE of dst.c-wth-obj       override do: end.
on WRITE of dst.wth-obj-attr    override do: end.
on WRITE of dst.wth-pobj        override do: end.
on WRITE of dst.c-wth-pobj      override do: end.
on WRITE of dst.wth-pobj-attr   override do: end.
on WRITE of dst.wth-place       override do: end.
on WRITE of dst.c-wth-place     override do: end.
on WRITE of dst.wth-place-attr  override do: end.
on WRITE of dst.c-wth-hist      override do: end.
on WRITE of dst.wth-doc         override do: end.
on WRITE of dst.wth-doc-attr    override do: end.
on WRITE of dst.wth-line        override do: end.
on WRITE of dst.wth-line-attr   override do: end.
on WRITE of dst.wth-dtl         override do: end.
on WRITE of dst.wth-dtl-attr    override do: end.
on WRITE of dst.wth-parts       override do: end.
on WRITE of dst.wth-parts-attr  override do: end.
on write of dst.chk-doc         override do: end.
on write of dst.chk-doc-attr    override do: end.
on write of dst.chk-pay         override do: end.
on write of dst.chk-pay-attr    override do: end.
on write of dst.c-chk-doc       override do: end.
on write of dst.c-chk-pay       override do: end.




  /*Перегрузка wealth*/
{ utl/00000002.i wealth }
if varstay-history then do:
  { utl/00000002.i c-wealth }
end.
{ utl/00000002.i wealth-attr }
{ utl/00000002.i wth-ser }
{ utl/00000002.i wth-ser-attr }
if varstay-history then do:
  { utl/00000002.i c-wth-ser }
  { utl/00000002.i c-wth-ser-attr }
end.
{ utl/00000002.i wth-par }
if varstay-history then do:
  { utl/00000002.i c-wth-par }
end.
{ utl/00000002.i wth-par-attr }
{ utl/00000002.i wth-obj }
if varstay-history then do:
  { utl/00000002.i c-wth-obj }
end.
{ utl/00000002.i wth-obj-attr }
{ utl/00000002.i wth-pobj }
if varstay-history then do:
  { utl/00000002.i c-wth-pobj }
end.
{ utl/00000002.i wth-pobj-attr }
{ utl/00000002.i wth-place }
if varstay-history then do:
  { utl/00000002.i c-wth-hist }
end.
for each old-wth-gds no-lock
on error undo, return error
:
    find first new-goods no-lock
          where new-goods.gds-code     = old-wth-gds.gds-code
    no-error.
    if available new-goods
    then do:
        create new-wth-gds.
        buffer-copy old-wth-gds to new-wth-gds.
    end.
end.        /* for each old-wth-gds */
for each old-wth-gds-attr no-lock
on error undo, return error
:
    find first new-goods no-lock
          where new-goods.gds-code     = old-wth-gds-attr.gds-code
    no-error.
    if available new-goods
    then do:
        create new-wth-gds-attr.
        buffer-copy old-wth-gds-attr to new-wth-gds-attr.
    end.
end.        /* for each old-wth-gds-attr */
if varstay-history then do:
  for each old-c-wth-gds no-lock
  on error undo, return error
  :
      find first new-goods no-lock
            where new-goods.gds-code     = old-c-wth-gds.gds-code
      no-error.
      if available new-goods
      then do:
          create new-c-wth-gds.
          buffer-copy old-c-wth-gds to new-c-wth-gds.
      end.
  end.        /* for each old-c-wth-gds */
  for each old-c-wth-gds-attr no-lock
  on error undo, return error
  :
      find first new-goods no-lock
            where new-goods.gds-code     = old-c-wth-gds-attr.gds-code
      no-error.
      if available new-goods
      then do:
          create new-c-wth-gds-attr.
          buffer-copy old-c-wth-gds-attr to new-c-wth-gds-attr.
      end.
  end.        /* for each old-c-wth-gds-attr */
end.

if vardate-actual-docs <> ? then  do:
  v-temp-date = vardate-actual-docs  - 1 .
end.
else  do:
  v-temp-date = today .
end.
assign
v-fact-order =  integer(v-temp-date) + 0.97 + 3 * 0.0000000001
find-fact-order =  integer(v-temp-date) + 0.99
.

if vardate-actual-docs <> ? then do:
  for each new-db no-lock
  ,each new-clients no-lock
    where new-clients.db-num = new-db.db-num
  :
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = new-clients.obj-type and
                                tt-objs.obj-code = new-clients.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
      for each old-wth-doc where
              old-wth-doc.host-code = new-clients.host-code
          and old-wth-doc.obj-type = new-clients.obj-type
          and old-wth-doc.obj-code = new-clients.obj-code
          and old-wth-doc.status_ = {&fact}
          and old-wth-doc.fact-date >= vardate-actual-docs  no-lock
      use-index stat-fact
      on error undo, return error
      :
      create new-wth-doc.
      buffer-copy old-wth-doc to new-wth-doc.

        run copy-body in this-procedure ( input new-wth-doc.doc-code).
      end. /*for each old-wth-doc where old-wth-doc.obj-type  = new-clients.obj-type and*/
        /* перемещение партий свободной зоны */
/*

INDEX-FIELD "obj-type" ASCENDING
INDEX-FIELD "obj-code" ASCENDING
INDEX-FIELD "w-p-code" ASCENDING
INDEX-FIELD "wth-code" ASCENDING
INDEX-FIELD "par-code" ASCENDING
INDEX-FIELD "in-code" ASCENDING
INDEX-FIELD "out-code" ASCENDING
INDEX-FIELD "ser-code" ASCENDING
INDEX-FIELD "db-num" ASCENDING
INDEX-FIELD "fact-rangeFrom" ASCENDING
INDEX-FIELD "fact-rangeTo" ASCENDING

wth-parts

beg-dt
cli-code
cli-type
contract-code
db-num
doc-code
doc-rangeFrom
doc-rangeTo
end-dt
ext-doc-type
fact-date
fact-num
fact-order
fact-qnty
fact-rangeFrom
fact-rangeTo
gds-code
host-code
in-code
in-obj-code
in-obj-type
obj-code
obj-type
out-code
out-obj-code
out-obj-type
par-code
price-base
price-rubl
qnty-doc
sale-obj-code
sale-obj-type
ser-code
shift-date
shift-num
stts
supp-code
supp-type
type
VAT-pc
w-p-code
wth-code

*/
        for each new-wth-gds no-lock
        :
        /*зона погашения*/
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = {&put-zone}
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
        /*зона покупателя*/
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = {&cli-zone}
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
        /*свободная зона*/
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type = new-clients.obj-type
            and old-wth-parts.obj-code = new-clients.obj-code
            and old-wth-parts.wth-code = new-wth-gds.wth-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = {&free-code}
        on error undo, return error
        :
           create new-wth-parts.
           buffer-copy old-wth-parts to new-wth-parts.
        end.
      end.

    end. /*if vardate-actual-docs <> ? then do:*/
    /*надо создать инвентаризацию по тем wth-pobj, которых нет в в документах новой БД*/
    for each temp-new-wth-line:
      delete temp-new-wth-line.
    end.
    for each old-wth-pobj
      where old-wth-pobj.host-code = new-clients.host-code
        and old-wth-pobj.obj-type  = new-clients.obj-type
        and old-wth-pobj.obj-code  = new-clients.obj-code
     on error undo, return error:
      find last old-wth-line no-lock where
                old-wth-line.obj-type   = new-clients.obj-type
            and old-wth-line.obj-code   = new-clients.obj-code
            and old-wth-line.w-p-code   = old-wth-pobj.w-p-code
            and old-wth-line.wth-code   = old-wth-pobj.wth-code
            and old-wth-line.fact-date  < vardate-actual-docs
            and old-wth-line.status_ = {&fact}  use-index stat-cld-pl no-error.
      create temp-new-wth-line.
      if available old-wth-line then buffer-copy old-wth-line
      except doc-code ext-doc-type fact-date fact-order shift-date shift-num credate creid doc-sum bef-sum aft-sum
      to temp-new-wth-line.
      buffer-copy old-wth-pobj
      using
      host-code
      obj-code
      obj-type
      wth-code
      w-p-code
      to temp-new-wth-line
      .
      if available old-wth-line then
      assign
      temp-new-wth-line.bef-sum = old-wth-line.income-pl - old-wth-line.incass-pl
      temp-new-wth-line.aft-sum = temp-new-wth-line.bef-sum
      .
      else do:
        assign
        temp-new-wth-line.bef-sum = 0
        temp-new-wth-line.aft-sum = 0
        .
      end.
    end. /*    for each old-wth-pobj*/

    find first temp-new-wth-line no-error.
    if available temp-new-wth-line then do:
      main-block:
      do
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        /*создаем шапку*/
        create dst.wth-doc.
        assign
        dst.wth-doc.cli-name   = new-clients.obj-name
        dst.wth-doc.doc-code   = "1-" + new-clients.obj-type  + string( new-clients.obj-code)
        dst.wth-doc.host-code  = new-clients.host-code
        dst.wth-doc.obj-type   = new-clients.obj-type
        dst.wth-doc.obj-code   = new-clients.obj-code
        dst.wth-doc.cli-type   = {&cmp}
        dst.wth-doc.cli-code   = new-clients.host-code
        dst.wth-doc.doc-date   = v-temp-date
        dst.wth-doc.fact-date  = v-temp-date
        dst.wth-doc.fact-order = v-fact-order
        dst.wth-doc.fact-num   = 3
        dst.wth-doc.shift-date = ?
        dst.wth-doc.shift-num  = ?
        dst.wth-doc.operator   = 0
        dst.wth-doc.deliver    = 0
        dst.wth-doc.receiver   = 0
        dst.wth-doc.inv-prs4   = 0
        dst.wth-doc.inv-prs5   = 0
        dst.wth-doc.doc-type   = {&inventory}
        dst.wth-doc.ext-doc-type = {&WDEDT_Inv}
        dst.wth-doc.auto-fill  = no
        dst.wth-doc.exter_     = yes
        dst.wth-doc.inter_     = no
        dst.wth-doc.PS         = "Инвентаризация создана в процессе обрезания базы (по остаткам на МХ МЦ на объекте) "
        dst.wth-doc.status_    = {&fact}
        dst.wth-doc.creid      = USERID("dst")
        dst.wth-doc.credate    = v-temp-date
        .
        for each temp-new-wth-line
        on error undo, return error :
           create new-wth-line.
           buffer-copy temp-new-wth-line
           to new-wth-line.
           buffer-copy  dst.wth-doc
           using credate creid doc-code ext-doc-type fact-date fact-order shift-date shift-num obj-type obj-code status_
           to  new-wth-line.
           assign
           dst.wth-doc.bef-sum = dst.wth-doc.bef-sum + temp-new-wth-line.bef-sum
           dst.wth-doc.aft-sum = dst.wth-doc.aft-sum + temp-new-wth-line.aft-sum
           .
        end. /*for each temp-*/
      end. /*doe*/
    end. /*if availabel temp-new-wth-line*/
  end. /*for each new-db no-lock, each clients.*/
  if vardate-output-zone <> ? then do:
    for each new-db no-lock
    ,each new-clients no-lock
      where new-clients.db-num = new-db.db-num
    :
      for each new-wth-gds no-lock
      :
        /*зона уничтожения*/
        for each old-wth-parts no-lock
          where old-wth-parts.obj-type  = new-clients.obj-type
            and old-wth-parts.obj-code  = new-clients.obj-code
            and old-wth-parts.gds-code = new-wth-gds.gds-code
            and old-wth-parts.out-code = {&output-code}
        on error undo, return error
        :
          if old-wth-parts.fact-date >= vardate-output-zone  then do:
            create new-wth-parts.
            buffer-copy old-wth-parts to new-wth-parts.
          end.
        end. /*for each old-wth-parts no-lock*/
      end. /*      for each new-wth-gds no-lock*/
    end. /*    for each new-db no-lock*/
  end. /*if vardate-output-zone <> ? then do:*/
end.

output stream str-gen close.
return "Произведен экспорт таблиц: wealth c-wealth wealth-attr wth-ser wth-ser-attr c-wth-ser c-wth-ser-attr wth-gds c-wth-gds wth-gds-attr c-wth-gds-attr wth-par c-wth-par wth-part-attr ~
wth-obj c-wth-obj wth-obj-attr wth-place c-wth-place wth-place-attr wht-pobj c-wth-pobj wth-pobj-attr ~
wth-doc wth-doc-attr wth-line wth-line-attr wth-dtl wth-dtl-attr wth-parts wth-parts-attr chk-doc c-chk-doc chk-doc-attr chk-pay c-chk-pay chk-pay-attr chk-par c-chk-par chk-par-attr ".
end. /*do*/

procedure copy-body :
define input parameter p-doc-code as character no-undo .

for each old-wth-line
  where old-wth-line.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-line.
    buffer-copy old-wth-line to new-wth-line.
end.
for each old-wth-doc-attr
  where old-wth-doc-attr.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-doc-attr.
    buffer-copy old-wth-doc-attr to new-wth-doc-attr.
end.
for each old-wth-line-attr
  where old-wth-line-attr.doc-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-line-attr.
    buffer-copy old-wth-line-attr to new-wth-line-attr.
end.
for each old-wth-dtl
  where old-wth-dtl.doc-code  = p-doc-code no-lock
on error undo, return error
:
  create new-wth-dtl.
  buffer-copy old-wth-dtl to new-wth-dtl.
end.
for each old-wth-dtl-attr
  where old-wth-dtl-attr.doc-code  = p-doc-code no-lock
on error undo, return error
:
  create new-wth-dtl-attr.
  buffer-copy old-wth-dtl-attr to new-wth-dtl-attr.
end.
for each old-wth-parts
  where old-wth-parts.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-parts.
    buffer-copy old-wth-parts to new-wth-parts.
end.
for each old-wth-parts-attr
  where old-wth-parts-attr.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-wth-parts-attr.
    buffer-copy old-wth-parts-attr to new-wth-parts-attr.
end.
for each old-chk-doc  no-lock
  where old-chk-doc.out-code = p-doc-code
on error undo, return error
:
    create new-chk-doc.
    buffer-copy old-chk-doc to new-chk-doc.
end.
for each old-c-chk-doc
  where  old-c-chk-doc.out-code = p-doc-code
  no-lock
on error undo, return error
:
    create new-c-chk-doc.
    buffer-copy old-c-chk-doc to new-c-chk-doc.
end.

for each old-chk-doc-attr no-lock
  where old-chk-doc-attr.out-code = p-doc-code
on error undo, return error
:
    create new-chk-doc-attr.
    buffer-copy old-chk-doc-attr to new-chk-doc-attr.
end.
for each old-c-chk-doc-attr no-lock
  where old-c-chk-doc-attr.out-code = p-doc-code
on error undo, return error
:
    create new-c-chk-doc-attr.
    buffer-copy old-c-chk-doc-attr to new-c-chk-doc-attr.
end.

for each old-chk-pay
  where old-chk-pay.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-chk-pay.
    buffer-copy old-chk-pay to new-chk-pay.
end.
for each old-c-chk-pay
  where old-c-chk-pay.out-code = p-doc-code no-lock
on error undo, return error
:
    create new-c-chk-pay.
    buffer-copy old-c-chk-pay to new-c-chk-pay.
end.
for each old-chk-pay-attr no-lock
  where old-chk-pay-attr.out-code = p-doc-code
on error undo, return error
:
    create new-chk-pay-attr.
    buffer-copy old-chk-pay-attr to new-chk-pay-attr.
end.

end procedure. /* copy-body */
