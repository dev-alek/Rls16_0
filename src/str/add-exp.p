block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: add-exp.p $
$Archive: str/add-exp.p $

Размазывание транспортных и прочих расходов по строкам накладной.

Автор: Чернова Светлана Александровна
Дата создания: 03/27/06
Author: Svetlana Chernova
Creation date: 03/27/06

1) сумме приходных цен
2) количеств (в учет. ед.изм.)
3) количеств (в ед.изм. поставщика)
4) весу

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: add-exp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/add-exp.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ gbl/lineattr.i }
{ cmp/r-pril.i   }
&scop part ub.doc-line.price
&scop v-screen  ' экран':L
&scop v-printer ' принтер':L

define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like ub.trn-doc.doc-code   no-undo.
define input parameter partot-other  like ub.trn-doc.tot-transp  no-undo.
define input parameter partot-transp like ub.trn-doc.tot-transp no-undo.
define variable v-insalepr as logical   no-undo .
define variable varhost-code like ub.trn-doc.obj-code no-undo.
define variable v-method as character no-undo .
define variable varvalue as character no-undo .
define variable vartype  as character no-undo .
define variable  partot-other-base  like ub.trn-doc.tot-transp  no-undo.
define variable  partot-transp-base like ub.trn-doc.tot-transp no-undo.
define variable  partot-other-rubl  like ub.trn-doc.tot-transp  no-undo.
define variable  partot-transp-rubl like ub.trn-doc.tot-transp no-undo.
define variable v-ves     as decimal   no-undo  init 0.
define variable v-wt-base as decimal   no-undo init 0 .
define variable g#report-num as integer   no-undo .
define stream  errStream  .
define variable v-old-other as character no-undo .
define variable v-old-other-type as character no-undo .
define variable v-old-other-rubl as decimal   no-undo .
define variable v-old-other-base as decimal   no-undo .
define variable v-old-tr-rubl as decimal   no-undo .
define variable v-old-tr-base as decimal   no-undo .


run get-report-num   in parParentProc ( output g#report-num ) .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .


find first ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-lock no-error.
{ gbl/hostcode.i ub.trn-doc.obj-type ub.trn-doc.obj-code varhost-code}

if not available ub.trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.

   { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-m-inc}
      varvalue
      vartype
      }
   if int(varvalue) > 0 then do:
     assign
       v-method = varvalue.
   end.
   else do:
     assign
       v-method = "1".
   end.


if v-method = "4" then do:

    { cmp/open-out.i stream  errStream  " " }
    v-exis = false .

   for each ub.doc-line no-lock where ub.doc-line.doc-code = pardoc-code :
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


if partot-other  = ? then partot-other  = 0.
if partot-transp = ? then partot-transp = 0.

assign
  partot-other-rubl  =  partot-other
  partot-transp-rubl =  partot-transp
  partot-other-base  =  partot-other-rubl   * ub.trn-doc.base-scale / ub.trn-doc.base-rate
  partot-transp-base =  partot-transp-rubl  * ub.trn-doc.base-scale / ub.trn-doc.base-rate
  .


tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :
   for each ub.doc-line
     where ub.doc-line.doc-code = pardoc-code
   :
       find first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                              ub.goods.prod-type = ub.doc-line.prod-type and
                              ub.goods.prod-code = ub.doc-line.prod-code no-lock.
       find first ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.

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
                                " Недопустимы транспортные и прочие расходы.".
       end.
       if ub.doc-line.transport-rubl = ? then ub.doc-line.transport-rubl = 0.
       if ub.doc-line.transport-base = ? then ub.doc-line.transport-base = 0.
       if ub.doc-line.other-rubl     = ? then ub.doc-line.other-rubl     = 0.
       if ub.doc-line.other-base     = ? then ub.doc-line.other-base     = 0.
       if ub.units.type = {&weight} then do:
           v-wt-base = ub.doc-line.fact-qnty.
       end.
       else do:
         v-wt-base = ub.goods.wt-base * ub.doc-line.fact-qnty.
        end.
        run lineattr-value in this-procedure (
            ub.doc-line.doc-code ,
            ub.goods.gds-code    ,
            {&lineattr-old_other-ras} ,
            output v-old-other       ,
            output v-old-other-type
            ) no-error .
        if error-status :error then do:
          v-old-other-rubl = 0 .
          v-old-other-base = 0 .
          v-old-tr-rubl    = 0 .
          v-old-tr-base    = 0 .
        end.
        else do:
          v-old-other-rubl = decimal ( entry ( 1 , v-old-other,{&delim-par} )) no-error .
          v-old-other-base = decimal ( entry ( 2 , v-old-other,{&delim-par} )) no-error .
          v-old-other-rubl = decimal ( entry ( 3 , v-old-other,{&delim-par} )) no-error .
          v-old-other-base = decimal ( entry ( 4 , v-old-other,{&delim-par} )) no-error .
        end.
        ub.doc-line.other-rubl = ub.doc-line.other-rubl - v-old-other-rubl .
        ub.doc-line.other-base = ub.doc-line.other-base - v-old-other-base .
        ub.doc-line.transport-rubl = ub.doc-line.transport-rubl - v-old-tr-rubl .
        ub.doc-line.transport-base = ub.doc-line.transport-base - v-old-tr-base .
  case v-method :
  when "1"  then do:
             /*Для того, чтобы программа могла запускаться n раз при коректировке,
               перед первичным закрытием налоги равны 0*/
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl .
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base .
             ub.doc-line.transport-base = ub.doc-line.price-base * partot-transp / ub.trn-doc.tot-sale              .
             ub.doc-line.transport-rubl = ub.doc-line.price-rubl * partot-transp / ub.trn-doc.tot-sale              .
             ub.doc-line.other-base     = ub.doc-line.price-base * partot-other  / ub.trn-doc.tot-sale              .
             ub.doc-line.other-rubl     = ub.doc-line.price-rubl * partot-other  / ub.trn-doc.tot-sale              .
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl .
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.
  when "2"  then do:
             /*Для того, чтобы программа могла запускаться n раз при коректировке,
               перед первичным закрытием налоги равны 0*/
             ub.doc-line.price-rubl     =  ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl .
             ub.doc-line.price-base     =  ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base .
             ub.doc-line.transport-base = (ub.doc-line.fact-qnty * partot-transp-base / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.transport-rubl = (ub.doc-line.fact-qnty * partot-transp-rubl / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.other-base     = (ub.doc-line.fact-qnty * partot-other-base  / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.other-rubl     = (ub.doc-line.fact-qnty * partot-other-rubl  / ub.trn-doc.fact-qnty ) / ub.doc-line.fact-qnty .
             ub.doc-line.price-rubl     =  ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl .
             ub.doc-line.price-base     =  ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base .
  end.
  when "3"  then do:
       assign
             /*Для того, чтобы программа могла запускаться n раз при коректировке,
               перед первичным закрытием налоги равны 0*/
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base
             ub.doc-line.transport-base = (ub.doc-line.cli-qnty * partot-transp-base / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.transport-rubl = (ub.doc-line.cli-qnty * partot-transp-rubl / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.other-base     = (ub.doc-line.cli-qnty * partot-other-base  / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.other-rubl     = (ub.doc-line.cli-qnty * partot-other-rubl  / ub.trn-doc.cli-qnty ) / ub.doc-line.fact-qnty
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.

  when "4"  then do:
       assign
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl - ub.doc-line.transport-rubl - ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base - ub.doc-line.transport-base - ub.doc-line.other-base
             ub.doc-line.transport-base = (v-wt-base *  partot-transp-base / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.transport-rubl = (v-wt-base *  partot-transp-rubl / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.other-base     = (v-wt-base *  partot-other-base  / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.other-rubl     = (v-wt-base *  partot-other-rubl  / v-ves ) / ub.doc-line.fact-qnty
             ub.doc-line.price-rubl     = ub.doc-line.price-rubl + ub.doc-line.transport-rubl + ub.doc-line.other-rubl
             ub.doc-line.price-base     = ub.doc-line.price-base + ub.doc-line.transport-base + ub.doc-line.other-base.
  end.


  end case.
  run lineattr-write in this-procedure (
      ub.doc-line.doc-code ,
      ub.goods.gds-code    ,
      {&lineattr-old_other-ras} ,
      string(ub.doc-line.other-rubl ) + {&delim-par} + string(ub.doc-line.other-base ) + {&delim-par} +
      string(ub.doc-line.transport-rubl ) + {&delim-par} + string(ub.doc-line.transport-base )
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка "
        view-as alert-box error
      .
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