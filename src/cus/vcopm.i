/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура проверки : если расчет заказа обязателен  и это тот самый клиент

Автор: Чернова Светлана Александровна
Дата создания: 06/15/10
Author: Svetlana Chernova
Creation date: 06/15/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ver-clients-calc :

define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-method   as character no-undo .
define output parameter p-error    as logical   no-undo .

define variable v-not-corr-op as character no-undo .
define variable v-type as character no-undo .

  do
  on error undo, return error return-value
  :

 p-error = false .
 v-not-corr-op  = 'no' .

 run clntattr-value (
    input   p-obj-type
  , input   p-obj-code
  , input   {&attr-not-corr-op}
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes' and  p-method = ""  then do:
    assign v-not-corr-op = 'no' .
    run clntattr-value (
    input   p-cli-type
  , input   p-cli-code
  , input   {&attr-not-corr-op}
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes'  and  p-method = ""  then p-error = true .
  end.
  end.
end procedure. /* ver-clients-calc */

procedure ver-ord-line :
define input parameter  p-doc-code like ub.ord-doc.doc-code no-undo .
define output parameter p-error    as logical               no-undo .

define variable v-longchar          as longchar  no-undo .
define variable v-err-ext           as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code        as character no-undo .
define variable v-ok                as logical   no-undo .
define variable v-nabor             as logical   no-undo .

define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc  for ub.ord-doc.
v-err-ext  = false .
find first buf_ord-doc no-lock
  where buf_ord-doc.doc-code = p-doc-code no-error.
  if not available buf_ord-doc then do:
  end.
  else do:
for each buf_ord-line of buf_ord-doc
  break by buf_ord-line.cli-art :   /* проверки по строкам */

 /* Проверка спецификации */

/*   if buf_ord-doc.contract-code > 0 and  /*g#type*/ buf_ord-doc.doc-type = {&o-p}  then do:*/
/*      { str/ckcntspc.i*/
/*        buf_ord-doc.host-code*/
/*        buf_ord-doc.contract-code*/
/*        buf_ord-line.gds-code*/
/*        buf_ord-line.price-cli*/
/*        buf_ord-doc.VAT-type*/
/*        buf_ord-line.VAT-pc*/
/*        FALSE*/
/*        no-error*/
/*      }*/
/*      if error-status :error then do:*/
/*        assign*/
/*          v-err-ext = true*/
/*          v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + {&new-line}*/
/*        .*/
/*      end.*/
/*  end.*/

/* проверка ИЖТ */
    if buf_ord-doc.doc-type <> {&p-o}  and
       buf_ord-doc.doc-type <> {&f-p}  then do:
       var-ok-assort-pol = true .
       v-event-code = buf_ord-doc.doc-type + "-" .
            { gbl/goassizt.i
              v-event-code
              buf_ord-line.gds-code
              buf_ord-doc.obj-type
              buf_ord-doc.obj-code
              false
              var-ok-assort-pol
              var-mess-assort-pol
            }
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + {&new-line} .
           end.
    end.

    if  buf_ord-doc.cli-type = {&shop} or
           buf_ord-doc.cli-type = {&stock} then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + buf_ord-doc.doc-type + "-" .
            { gbl/goassizt.i
              v-event-code
              buf_ord-line.gds-code
              buf_ord-doc.cli-type
              buf_ord-doc.cli-code
              false
              var-ok-assort-pol
              var-mess-assort-pol
            }
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + {&new-line} .
           end.
       end.

    if buf_ord-doc.doc-type = {&P-O}  then do:
        var-ok-assort-pol = true .
        v-event-code = buf_ord-doc.doc-type + "-" .
        { gbl/goassmat.i
          buf_ord-line.gds-code
          buf_ord-doc.obj-type
          buf_ord-doc.obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + {&new-line} .
        end.
    end.

  /*
  /* проверка на букет */
   run ver-gds-flor ( input buf_ord-line.gds-code , output v-nabor ) no-error .
   if v-nabor    = true then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute("Артикул &1 &2&3 Является набором (букет) !!! Удалите его из списка товаров ! {&5} ", buf_ord-line.artic, buf_ord-line.prod-type, buf_ord-line.prod-code, {&new-line}) .
   end.

  /* Проверка строк и признаков */
  t-sum = 0.
  for each tmp#zakaz-dtl where
      tmp#zakaz-dtl.artic     = tmp#zakaz.artic and
      tmp#zakaz-dtl.prod-type = tmp#zakaz.prod-type and
      tmp#zakaz-dtl.prod-code = tmp#zakaz.prod-code  :
      t-sum = t-sum + tmp#zakaz-dtl.qnty.
   end.

   if t-sum > tmp#zakaz.qnty then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute ("Количество по признакам больше чем по строке товара ! &1 &2&3 &4 (количества по признакам=&5 и по строке=&6)&7" ,tmp#zakaz.artic, tmp#zakaz.prod-type ,tmp#zakaz.prod-code, tmp#zakaz.gds-name ,t-sum,  tmp#zakaz.qnty, {&new-line}) .
   end.

/* Проверка внешних артикулов  */
define buffer bf2_ext-artic for ub.ext-artic  .
define buffer bf2_goods for ub.goods  .
define buffer bf3_goods for ub.goods  .
define buffer bf2_tmp#zakaz for tmp#zakaz  .

    if tmp#zakaz.cli-art <> "" then do:
        for each bf2_ext-artic where
                 bf2_ext-artic.cli-type  = loc-cli-type  and
                 bf2_ext-artic.cli-code  = loc-cli-code  and
                 bf2_ext-artic.ext-artic = tmp#zakaz.cli-art   :

          if     bf2_ext-artic.gds-code     = tmp#zakaz.gds-code
          or     bf2_ext-artic.status_   = {&deleted-status} then next.
          leave.
        end.

        if available bf2_ext-artic then do:
          find first bf2_goods no-lock where
                    bf2_goods.gds-code = bf2_ext-artic.gds-code no-error .
          find first bf3_goods no-lock where
                    bf3_goods.gds-code =  tmp#zakaz.gds-code no-error .

                    v-err-ext = true .
                    v-longchar = v-longchar +
                    substitute( "Для данного контрагента уже есть товар &1 &2&3 &4 с таким же внешним артикулом &5 как у &6 &7&8 &9"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , tmp#zakaz.cli-art
                  , tmp#zakaz.artic
                  , tmp#zakaz.prod-type
                  , tmp#zakaz.prod-code
                  , bf3_goods.gds-name
                  ) +  {&new-line}.
        end.
    end.

    if last-of (tmp#zakaz.cli-art) then do:
       if tmp#zakaz.cli-art <> "" then do:
        for each bf2_tmp#zakaz where
                 bf2_tmp#zakaz.cli-art = tmp#zakaz.cli-art and
                 bf2_tmp#zakaz.gds-code <> tmp#zakaz.gds-code break by bf2_tmp#zakaz.cli-art :
                find first bf2_goods no-lock where
                          bf2_goods.gds-code = bf2_tmp#zakaz.gds-code
                          no-error .
                    v-err-ext = true .
                    if first-of(bf2_tmp#zakaz.cli-art) then do:
                        v-longchar = v-longchar +
                        substitute( "В заказе есть повторяющиеся атрикулы Поставщика &1 товар &2 &3&4 &5:&6"
                      , tmp#zakaz.cli-art
                      , tmp#zakaz.artic
                      , tmp#zakaz.prod-type
                      , tmp#zakaz.prod-code
                      , tmp#zakaz.gds-name
                      ,  {&new-line}).
                    end.
                    v-longchar = v-longchar +
                    substitute( "- такой же атрикул поставщика у товара &1 &2&3 &4 &5"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , {&new-line} ).
        end.
       end.
    end.
    */
  end.
  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      return error .
    end.
  end.
end procedure.