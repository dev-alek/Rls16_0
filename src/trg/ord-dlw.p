block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение строки заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.ord-line OLD BUFFER old_ord-line.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение строки заказа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }

define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_c-ord-line for ub.c-ord-line  .
define buffer buf_goods for ub.goods  .
define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .
define variable var-r-b as character no-undo .

define variable     varprice-cli                    like ub.doc-line.price-base no-undo .
define variable     varprice-cli-unit-base          like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax               like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp              like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp          like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs            like ub.doc-line.price-base no-undo .
define variable     varprice-slt                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt                 like ub.doc-line.price-base no-undo .
define variable     varprice-vat                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt             like ub.doc-line.price-base no-undo .
define variable     varprice-rubl                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-rubl          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-rubl         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-rubl     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-rubl       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-rubl            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-rubl        like ub.doc-line.price-base no-undo .
define variable     varprice-base                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-base          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-base         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-base     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-base       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-base            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-base        like ub.doc-line.price-base no-undo .



main-block :
do transaction
on error undo main-block, return error
:

run cur-time in this-procedure(output v-today, output start-time).
find first buf_ord-doc no-lock   where  buf_ord-doc.doc-code  =  ub.ord-line.doc-code no-error .
if available buf_ord-doc then do:

    if not  g#news
    and not g#auto
    and not g#esys
    then do:
        find first ub.units no-lock where
                    ub.units.unit-name = ub.ord-line.unit-cli  and
                    lookup({&pieces}, ub.units.type) > 0 no-error .
        if available ub.units then do:
            if ub.ord-line.cli-qnty - truncate(ub.ord-line.cli-qnty,0) > 0 then do:
                message "Количество в единицах поставщика " ub.ord-line.unit-cli
                "получилось дробным ! Исправить в меньшую сторону ? " view-as alert-box question
                buttons  yes-no
                update trg-ok as logical
                .
                if trg-ok then ub.ord-line.cli-qnty = truncate(ub.ord-line.cli-qnty,0) .
                else return .

            end.
        end.
    end.

    assign
      ub.ord-line.qnty       =   ub.ord-line.cli-qnty * ub.ord-line.cli-base-rate
      ub.ord-line.price-base =   ub.ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
      ub.ord-line.sum-rubl   =   ub.ord-line.price-rubl * ub.ord-line.qnty
      ub.ord-line.sum-base   =   ub.ord-line.price-base * ub.ord-line.qnty
      ub.ord-line.sum-cli    =   ub.ord-line.price-cli  * ub.ord-line.cli-qnty
    .

    if ub.ord-line.sum-vat = ? then ub.ord-line.sum-vat = 0.

    if buf_ord-doc.vat-type = {&without-vat} then  do:
       if ub.ord-line.vat-pc <> 0 then ub.ord-line.vat-pc = 0.
    end.
    if buf_ord-doc.slt-type = {&without-slt} then  do:
       if ub.ord-line.slt-pc <> 0 then ub.ord-line.slt-pc = 0.
    end.

   if buf_ord-doc.vat-type <> {&without-vat} and
      ub.ord-line.vat-pc <> 0 and
      ub.ord-line.sum-vat = 0 and
      ub.ord-line.qnty <> 0
   then do:
      { gbl/curr-r-b.i
        var-r-b
      }
      { str/in-vat.i
        "'zakaz':u"
        buf_ord-doc.base-rate
        buf_ord-doc.base-scale
        buf_ord-doc.exch-rate
        buf_ord-doc.exch-scale
        buf_ord-doc.vat-type
        buf_ord-doc.slt-type
        ub.ord-line.artic
        ub.ord-line.prod-type
        ub.ord-line.prod-code
        ub.ord-line.price-cli
        ub.ord-line.cli-base-rate
        ub.ord-line.price-rubl
        ub.ord-line.vat-pc
        ub.ord-line.slt-pc
        ub.ord-line.road-tax
        ub.ord-line.transport-rubl
        ub.ord-line.other-rubl
        varprice-cli
        varprice-cli-unit-base
        varprice-road-tax
        varprice-other-exp
        varprice-transport-exp
        varprice-without-abs
        varprice-slt
        varprice-no-slt
        varprice-vat
        varprice-no-vat-slt
        varprice-rubl
        varprice-road-tax-rubl
        varprice-other-exp-rubl
        varprice-transport-exp-rubl
        varprice-without-abs-rubl
        varprice-slt-rubl
        varprice-no-slt-rubl
        varprice-vat-rubl
        varprice-no-vat-slt-rubl
        varprice-base
        varprice-road-tax-base
        varprice-other-exp-base
        varprice-transport-exp-base
        varprice-without-abs-base
        varprice-slt-base
        varprice-no-slt-base
        varprice-vat-base
        varprice-no-vat-slt-base
        no-error
        }
        ub.ord-line.sum-vat    = if var-r-b = "rubl" then round(varprice-vat-rubl,2)
                                                     else round(varprice-vat-base,2)
        .
   end.
end.



find first buf_goods no-lock where
           buf_goods.artic = ub.ord-line.artic and
           buf_goods.prod-type = ub.ord-line.prod-type  and
           buf_goods.prod-code = ub.ord-line.prod-code no-error .
if available buf_goods then
assign
  ub.ord-line.gds-code = buf_goods.gds-code
.


  if new(ub.ORD-line) then do:
      create ub.c-ord-line.
      BUFFER-COPY ub.ord-line  TO ub.c-ord-line
      assign
        ub.c-ord-line.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        ub.c-ord-line.corr-time          = start-time
        ub.c-ord-line.corr-user-db-num   = g#db-num
        ub.c-ord-line.corr-user-name     = g#userid
        ub.c-ord-line.corr-date          = v-today
    .
  end.

define buffer old_c-ord-doc for ub.c-ord-doc.


  find first old_c-ord-doc no-lock  where
             old_c-ord-doc.doc-code  =  old_ord-line.doc-code
             no-error .
  if not error-status :error /*and  buf_ord-doc.status_ <> {&g___new} */ then do:
  if old_ord-line.qnty <> ub.ord-line.qnty or
     old_ord-line.cli-qnty <> ub.ord-line.cli-qnty or
     old_ord-line.cli-base-rate <> ub.ord-line.cli-base-rate or
     old_ord-line.price-base <> ub.ord-line.price-base or
     old_ord-line.price-rubl <> ub.ord-line.price-rubl or
     old_ord-line.price-cli <> ub.ord-line.price-cli
     then do:

        run cur-time in this-procedure ( output v-today
                                       , output start-time ) .
          create ub.c-ord-line.
          BUFFER-COPY old_ord-line  TO ub.c-ord-line
          assign
            ub.c-ord-line.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            ub.c-ord-line.corr-time          = start-time
            ub.c-ord-line.corr-user-db-num   = g#db-num
            ub.c-ord-line.corr-user-name     = g#userid
            ub.c-ord-line.corr-date          = v-today
        .
         if available buf_ord-doc then do:
          create ub.c-ord-doc.
          BUFFER-COPY buf_ord-doc  TO ub.c-ord-doc
          assign
            ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num
            ub.c-ord-doc.corr-time          = start-time
            ub.c-ord-doc.corr-user-db-num   = g#db-num
            ub.c-ord-doc.corr-user-name     = g#userid
            ub.c-ord-doc.corr-date          = v-today
        .
        end.
        else do:
          create ub.c-ord-doc.
          BUFFER-COPY old_ord-line TO ub.c-ord-doc
          assign
            ub.c-ord-doc.chip-num           = ub.c-ord-line.chip-num
            ub.c-ord-doc.corr-time          = start-time
            ub.c-ord-doc.corr-user-db-num   = g#db-num
            ub.c-ord-doc.corr-user-name     = g#userid
            ub.c-ord-doc.corr-date          = v-today
        .
        end.
     end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ord-line}
        , input ( buffer ub.ord-line:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.