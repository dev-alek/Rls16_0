block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: addsuper.p $
$Archive: str/addsuper.p $

Вкручивание Дополнительных расходов в учетную цену

Автор: Чернова Светлана Александровна
Дата создания: 12/19/07
Author: Svetlana Chernova
Creation date: 12/19/07

1) сумме приходных цен
2) количеств (в учет. ед.изм.)
3) количеств (в ед.изм. поставщика)
4) весу

*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addsuper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/addsuper.p $":U .
define variable vss-description as character no-undo init "Вкручивание Дополнительных расходов в учетную цену".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ cmp/r-pril.i   }
{ gbl/lineattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
&scop part ub.doc-line.price
&scop v-screen  ' экран':L
&scop v-printer ' принтер':L


define variable v-insalepr as logical   no-undo .
define variable v-method as character no-undo .
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define variable v-ves     as decimal   no-undo  init 0.
define variable v-wt-base as decimal   no-undo init 0 .
define variable g#report-num as integer   no-undo .

define stream  errStream  .

define variable v-gds-code as integer   no-undo .
define variable v-old-other as character no-undo .
define variable v-old-other-type as character no-undo .
define variable v-NEW-other as character no-undo .
define variable v-NEW-other-type as character no-undo .
define variable v-old-other-rubl as decimal   no-undo .
define variable v-old-other-base as decimal   no-undo .

define variable v-old-tr-rubl as decimal   no-undo .
define variable v-old-tr-base as decimal   no-undo .

define variable v-NEW-other-rubl as decimal   no-undo .
define variable v-NEW-other-base as decimal   no-undo .

define variable v-delta-base  as decimal   no-undo .
define variable v-delta-rubl  as decimal   no-undo .

run get-report-num   in parParentProc ( output g#report-num ) .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .

find first ub.add-doc no-lock where
           ub.add-doc.doc-code = p-doc-code no-error .
if error-status :error then return error substitute("Нет документа ДопРасхода  &1" ,p-doc-code ) .

define variable v-method-4 as logical   no-undo .

v-method-4 = false .
for each  ub.add-line no-lock where
          ub.add-line.doc-code = ub.add-doc.doc-code :
    find first ub.gds-add-charges no-lock where
               ub.gds-add-charges.gds-code = ub.add-line.gds-code and
               ub.gds-add-charges.algoritm = '4' no-error .
     if available ub.gds-add-charges then  do:
        v-method-4 = true .
        leave.
     end.
end.

define variable   v-tot-sale  as decimal   no-undo .
define variable   v-fact-qnty  as decimal   no-undo .
define variable   v-cli-qnty  as decimal   no-undo .
define variable vv-dl as decimal   no-undo .
assign
  v-tot-sale  = 0
  v-fact-qnty = 0
  v-cli-qnty  = 0
  vv-dl = 0
.
for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code :
  for each ub.trn-doc no-lock where
           ub.trn-doc.doc-code = ub.add-trn.trn-doc-code :
           vv-dl = 0 .
           for each ub.doc-line no-lock where
                    ub.doc-line.doc-code = ub.trn-doc.doc-code :
             vv-dl = vv-dl + ( ub.doc-line.price-cli * ub.doc-line.cli-qnty) * ub.trn-doc.exch-rate  / ub.trn-doc.exch-scale .
           end.
    v-tot-sale  = v-tot-sale  + vv-dl  .
    v-fact-qnty = v-fact-qnty + ub.trn-doc.fact-qnty  .
    v-cli-qnty  = v-cli-qnty  + ub.trn-doc.cli-qnty   .
  end.
end.



if v-method-4 = true then do:
    { cmp/open-out.i stream  errStream  " " }
    v-exis = false .
   for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
       each ub.doc-line no-lock where ub.doc-line.doc-code = ub.add-trn.trn-doc-code :
       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.
       find first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base  .

       if  ub.units.type = {&weight} then do:
           v-wt-base = ub.doc-line.fact-qnty.
       end.
       else do:
         v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
         if v-wt-base = ? or v-wt-base = 0 then do:
            Put  stream  errStream /*unformatted */
                         ub.goods.artic " " ub.goods.gds-code " " ub.goods.gds-name  skip .
            v-exis = true.
         end.
       end.
       v-ves =  v-ves + v-wt-base  .

   end.
    /* есть err */
    if v-exis = true then do:
        define variable v-user-action   as character no-undo .
        define variable v-printed       as logical no-undo .
          message
          "Обнаружены товары без проставленного веса за штуку ! " skip
          "Вы можете просмотреть и распечатать их список . "      skip
          "Редактирование веса в карточке товара . "      skip
          view-as alert-box error .

      Output stream errStream   close .
        run gbl/prnfilen.w
          (input  "Товары без веса"
          ,input  0
          ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
          ,input 7
          ,output v-user-action
          ,output v-printed
          ) .

          if not ( lookup( {&v-screen}, v-user-action ,";")  > 0 or
                    lookup( {&v-printer}, v-user-action ,";")  > 0  ) then do:
                      message "Внимание , вы не просмотрели список товаров ! "  .
                    end.
          return error.
    end.
end.

tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
/* Для того, чтобы программа могла запускаться n раз при коректировке,
   перед первичным закрытием налоги равны 0 */
  for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
      each ub.doc-line exclusive-lock   where ub.doc-line.doc-code = ub.add-trn.trn-doc-code :
            { gbl/gds-code.i
              ub.doc-line.artic
              ub.doc-line.prod-type
              ub.doc-line.prod-code
              v-gds-code
            }

        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            v-gds-code    ,
            {&lineattr-NEW_other-ras} ,
            output v-NEW-other       ,
            output v-NEW-other-type
            ) no-error .
        v-NEW-other-rubl = decimal ( entry(1,v-NEW-other,{&delim-par})) no-error .
        v-NEW-other-base = decimal ( entry(2,v-NEW-other,{&delim-par})) no-error .

        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            v-gds-code    ,
            {&lineattr-old_other-ras} ,
            output v-old-other       ,
            output v-old-other-type
            ) no-error .
         if error-status :error or v-old-other = "" then
         assign
            v-old-other-rubl = 0
            v-old-other-base = 0
            v-old-tr-rubl = 0
            v-old-tr-base = 0
         .
         else do:
            v-old-other-rubl = decimal ( entry(1,v-old-other,{&delim-par})) no-error .
            v-old-other-base = decimal ( entry(2,v-old-other,{&delim-par})) no-error .
            v-old-tr-rubl    = decimal ( entry(3,v-old-other,{&delim-par})) no-error .
            v-old-tr-base    = decimal ( entry(4,v-old-other,{&delim-par})) no-error .
            if v-old-other-rubl = ? then v-old-other-rubl = 0 .
            if v-old-other-base = ? then v-old-other-base = 0 .
            if v-old-tr-rubl    = ? then v-old-tr-rubl = 0 .
            if v-old-tr-base    = ? then v-old-tr-base = 0 .
        end.

      assign
        ub.doc-line.transport-rubl = ub.doc-line.transport-rubl  -  v-old-tr-rubl
        ub.doc-line.transport-base = ub.doc-line.transport-base  -  v-old-tr-base
        ub.doc-line.other-rubl = ub.doc-line.other-rubl  -  v-NEW-other-rubl -  v-old-other-rubl
        ub.doc-line.other-base = ub.doc-line.other-base  -  v-NEW-other-base -  v-old-other-base

        ub.doc-line.price-rubl = ub.doc-line.price-rubl  -  v-NEW-other-rubl -  v-old-other-rubl -  v-old-tr-rubl
        ub.doc-line.price-base = ub.doc-line.price-base  -  v-NEW-other-base -  v-old-other-base -  v-old-tr-base
      .
  end.

  for each ub.add-line no-lock where
           ub.add-line.doc-code = p-doc-code ,
           first ub.gds-add-charges no-lock where
                 ub.gds-add-charges.gds-code = ub.add-line.gds-code and
                 ub.gds-add-charges.cost-include = true
           :
   for each ub.add-trn no-lock where
            ub.add-trn.doc-code = p-doc-code ,
       each ub.doc-line exclusive-lock where
            ub.doc-line.doc-code = ub.add-trn.trn-doc-code
            :

       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.

       find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.

       { gbl/gdsobjat.i
         ub.doc-line.obj-type
         ub.doc-line.obj-code
         ub.doc-line.artic
         ub.doc-line.prod-type
         ub.doc-line.prod-code
         "'insalepr=request'":U
         v-insalepr
       }
       if v-insalepr = true then do:
          undo tr, return error "В накладной " + string(ub.doc-line.doc-code) + " имеется товар " + string(ub.goods.artic) + " "
                                + string(ub.goods.prod-type) + " " + string(ub.goods.prod-code) + " принимаемый по продажной цене." +
                                " Недопустимы  прочие расходы.".

       end.

       if ub.doc-line.other-rubl     = ? then ub.doc-line.other-rubl     = 0.
       if ub.doc-line.other-base     = ? then ub.doc-line.other-base     = 0.
       if  ub.units.type = {&weight} then do:
           v-wt-base = ub.doc-line.fact-qnty.
          end.
          else do:
            v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
          end.

        assign
          v-delta-base = 0
          v-delta-rubl = 0
        .

        case ub.gds-add-charges.algoritm :
            when "1"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( ub.doc-line.price-base * ub.add-line.sum-rubl  / v-tot-sale)
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( ub.doc-line.price-rubl * ub.add-line.sum-rubl  / v-tot-sale)
                        v-delta-base =  ub.doc-line.price-base * ub.add-line.sum-rubl  / v-tot-sale
                        v-delta-rubl =  ub.doc-line.price-rubl * ub.add-line.sum-rubl  / v-tot-sale

                    .

            end.
            when "2"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( ub.add-line.sum-base  / v-fact-qnty )
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( ub.add-line.sum-rubl  / v-fact-qnty )
                        v-delta-base =  ub.add-line.sum-base  / v-fact-qnty
                        v-delta-rubl =  ub.add-line.sum-rubl  / v-fact-qnty
                        .
            end.
            when "3"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + (( ub.doc-line.cli-qnty * ub.add-line.sum-base  / v-cli-qnty ) / ub.doc-line.fact-qnty )
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + (( ub.doc-line.cli-qnty * ub.add-line.sum-rubl  / v-cli-qnty ) / ub.doc-line.fact-qnty )
                        v-delta-base = ( ub.doc-line.cli-qnty * ub.add-line.sum-base  / v-cli-qnty ) / ub.doc-line.fact-qnty
                        v-delta-rubl = ( ub.doc-line.cli-qnty * ub.add-line.sum-rubl  / v-cli-qnty ) / ub.doc-line.fact-qnty
                        .
            end.
            when "4"  then do:
                  assign
                        ub.doc-line.other-base = ub.doc-line.other-base + ( v-wt-base * ub.add-line.sum-base  / v-ves) / ub.doc-line.fact-qnty
                        ub.doc-line.other-rubl = ub.doc-line.other-rubl + ( v-wt-base * ub.add-line.sum-rubl  / v-ves) / ub.doc-line.fact-qnty
                        v-delta-base = ( v-wt-base * ub.add-line.sum-base  / v-ves ) / ub.doc-line.fact-qnty
                        v-delta-rubl = ( v-wt-base * ub.add-line.sum-rubl  / v-ves ) / ub.doc-line.fact-qnty

                    .
            end.
        end case.
        run add-d-part
          (input ub.doc-line.doc-code
          ,input p-doc-code
          ,input ub.goods.gds-code
          ,input ub.gds-add-charges.gds-code
          ,input ub.add-line.cli-type
          ,input ub.add-line.cli-code
          ,input ub.add-line.contract-code
          ,input ub.add-line.host-code
          ,input ub.add-line.vat-pc
          ,input v-delta-base
          ,input v-delta-rubl
          ) no-error.
        if error-status:error then do:
          undo tr, return error substitute(" Ошибка создания партий по дополнительному расходу в учетной цене &1 &2" , return-value , error-status :get-message(1)   ) .
        end.
  end.
 end.
   for each ub.add-trn no-lock where ub.add-trn.doc-code = p-doc-code,
       first ub.trn-doc no-lock  where
             ub.trn-doc.doc-code = ub.add-trn.trn-doc-code :
       for each ub.doc-line exclusive-lock where
                ub.doc-line.doc-code = ub.trn-doc.doc-code :
              { gbl/gds-code.i
                ub.doc-line.artic
                ub.doc-line.prod-type
                ub.doc-line.prod-code
                v-gds-code
              }
            run lineattr-write in this-procedure (
                ub.doc-line.doc-code ,
                v-gds-code    ,
                {&lineattr-new_other-ras} ,
                string(ub.doc-line.other-rubl) + {&delim-par} + string(ub.doc-line.other-base)
                ) .

            run lineattr-value in this-procedure (
                ub.doc-line.doc-code ,
                v-gds-code    ,
                {&lineattr-old_other-ras} ,
                output v-old-other       ,
                output v-old-other-type
                ) no-error .
                if error-status :error or  v-old-other = ""  then
                assign
                  v-old-other-rubl = 0
                  v-old-other-base = 0
                  v-old-tr-rubl = 0
                  v-old-tr-base = 0
                .
                else do:
                  v-old-other-rubl = decimal ( entry(1,v-old-other,{&delim-par})) no-error .
                  v-old-other-base = decimal ( entry(2,v-old-other,{&delim-par})) no-error .
                  v-old-tr-rubl = decimal ( entry(3,v-old-other,{&delim-par})) no-error .
                  v-old-tr-base = decimal ( entry(4,v-old-other,{&delim-par})) no-error .
                  if v-old-other-rubl = ? then v-old-other-rubl = 0 .
                  if v-old-other-base = ? then v-old-other-base = 0 .
                  if v-old-tr-rubl    = ? then v-old-tr-rubl = 0 .
                  if v-old-tr-base    = ? then v-old-tr-base = 0 .
                end.

            ub.doc-line.price-rubl = ub.doc-line.price-rubl + ub.doc-line.other-rubl + v-old-other-rubl + v-old-tr-rubl.
            ub.doc-line.price-base = ub.doc-line.price-base + ub.doc-line.other-base + v-old-other-base + v-old-tr-base.
            ub.doc-line.other-rubl = ub.doc-line.other-rubl + v-old-other-rubl.
            ub.doc-line.other-base = ub.doc-line.other-base + v-old-other-base.
            ub.doc-line.transport-rubl = ub.doc-line.transport-rubl  +  v-old-tr-rubl .
            ub.doc-line.transport-base = ub.doc-line.transport-base  +  v-old-tr-base .
          /* обновление информации в партиях документа */
          run trg/partsupd.p
            (input parparentproc
            ,input ub.trn-doc.doc-code   /* p-doc-code        */
            ,input ub.trn-doc.obj-type   /* p-obj-type        */
            ,input ub.trn-doc.obj-code   /* p-obj-code        */
            ,input ub.doc-line.artic     /* p-artic           */
            ,input ub.doc-line.prod-type /* p-prod-type       */
            ,input ub.doc-line.prod-code /* p-prod-code       */
            ,input true               /* l-update-doc-line */
            ,input ""                 /* p-update-parts-info */
            ) no-error.
          if error-status:error then do:
            undo tr, return error "Ошибка при редактировании партий.".
          end.
      end.
      run gbl/calc-trn.p (input parparentproc, input recid(ub.trn-doc)) no-error.
      if error-status:error then undo tr, return error.
   end.
end.


procedure add-d-part :
define input  parameter p-trn-doc-code  as character no-undo .
define input  parameter p-add-doc-code  as character no-undo .
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-add-gds-code  as integer   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-vat-pc        as decimal   no-undo .
define input  parameter p-delta-base    as decimal   no-undo .
define input  parameter p-delta-rubl    as decimal   no-undo .

define buffer buf_parts-add for ub.parts-add .
define buffer buf_add-doc   for ub.add-doc   .
define buffer buf_add-line  for ub.add-line  .
define buffer buf_add-trn   for ub.add-trn   .
define buffer buf_contract for ub.contract  .
define variable varcr-incfo as logical   no-undo .
define variable varundef as logical   no-undo .


  do
  on error undo, return error return-value
  :
find first buf_parts-add exclusive-lock where
          buf_parts-add.in-code      =  p-trn-doc-code  and
          buf_parts-add.gds-code     =  p-gds-code      and
          buf_parts-add.part-code    =  ''              and
          buf_parts-add.add-doc-code =  p-add-doc-code  and
          buf_parts-add.add-gds-code =  p-add-gds-code  and
          buf_parts-add.cli-type     =  p-cli-type      and
          buf_parts-add.cli-code     =  p-cli-code      and
          buf_parts-add.host-code    =  p-host-code     and
          buf_parts-add.contract-code = p-contract-code no-error .
      if not available buf_parts-add then do:
        create buf_parts-add .
      end.
      assign
        buf_parts-add.in-code      =  p-trn-doc-code
        buf_parts-add.gds-code     =  p-gds-code
        buf_parts-add.part-code    =  ''
        buf_parts-add.add-doc-code =  p-add-doc-code
        buf_parts-add.add-gds-code =  p-add-gds-code
        buf_parts-add.cli-type     =  p-cli-type
        buf_parts-add.cli-code     =  p-cli-code
        buf_parts-add.host-code    =  p-host-code
        buf_parts-add.contract-code = p-contract-code
        buf_parts-add.sum-base      = p-delta-base
        buf_parts-add.sum-rubl      = p-delta-rubl
        buf_parts-add.sum-other-base = p-vat-pc
        buf_parts-add.sum-other-rubl = p-delta-rubl
      .

      find first buf_contract no-lock where
                buf_contract.host-code     = p-host-code    and
                buf_contract.contract-code = p-contract-code
                no-error .
      if available buf_contract then do:
         /* По ФО */
          if lookup (buf_contract.usl-opl, {&o-postavka}) > 0 then do:
            assign
              varcr-incfo = yes.
          end.
          if buf_contract.usl-opl = {&contr-pay-nodef} then do:
            assign
              varundef = yes.
          end.

        find first buf_add-doc exclusive-lock where
                  buf_add-doc.doc-code = p-add-doc-code no-error .

        if varcr-incfo = yes then do:
          assign
            buf_add-doc.need-incfo = 1
            .
        end.
        else do:
          if varundef = yes  and buf_add-doc.need-incfo <> 1 then do:
            assign
              buf_add-doc.need-incfo = 2
              .
          end.
        end.
      /* По счет-фактуре */
     if (buf_contract.gen-factur = 1  or
         buf_contract.gen-factur = 11 or
         buf_contract.gen-factur = 101 or
         buf_contract.gen-factur = 111 ) then do:
       assign  buf_add-doc.need-factur = 1 .
     end.
    end.
  end.

end procedure. /* add-d-part */