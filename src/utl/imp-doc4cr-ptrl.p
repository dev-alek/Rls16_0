/*

$Revision: 022d9db987b8, 3255, rls $
$Author: EShklyar $
$Date: 2023/01/27 13:45:26 $
$Workfile: imp-doc4cr-ptrl.p $
$Archive: utl/imp-doc4cr-ptrl.p $

Импорт накладных. Создание документов.

Автор: Молотков Сергей
Дата создания: 24/09/18
Author: Molotkov Sergey
Creation date: 24/09/18

*/
block-level on error undo, throw.

{utl/imp-parts-ptrl.i }
{str/trdcalib.i}

/* parparentproc пробрасывается :
в str/copy-in.i для передачи
  в str/copy-inh.i
  и
  в str/clcintrn.i
в gbl/calc-trn.p для передачи
  в str/calc-in.i
в str/trn-stat.p для вызова
  "get-db-num":U
  и
  "get-userid":U,
  и для передачи
  в gbl/gtplmrgn.i,
  в gbl/partmrgn.i,
  в str/delnabor.i,
  в str/add-scal.i,
  в str/add-exp.p,
  в str/addsuper.p,
  в str/addclos.p,
  в str/in-pr.p,
  в cus/rcvsttr.p,
  в str/copy-in.i,
  в str/lnfactqt.i,
  в gbl/calc-trn.p (для проброса в str/calc-in.i),
  в cus/ord-mrz.p,
  в str/saledc.p,
  в str/rv-out.p,
  в str/fl-out.p,
  в str/raspdelv.p,
  в str/fltransp.p,
  в str/parts-pc.p,
  в str/deadprts.p,
  в str/vtrecalc.p,
  в cus/edocsord.p,
  в str/trn-open.p,
  в str/genbfotr.p,
  в str/rvs-stat.p,
  в str/rvsclose.i
*/
define input  parameter parparentproc    as handle no-undo .
// define input parameter p-parent-handle  as handle no-undo . 24/IX-2018 - не используется
define input  parameter p-log-handle     as handle no-undo .
define input  parameter p-log-filename   as character no-undo .
define input  parameter p-obj-code       as integer no-undo .
define input  parameter p-obj-type       as character no-undo .
define input  parameter p-is-close       as logical no-undo . // true - закрывать созданные документы; ещё не работает: всегда false
define input  parameter p-osn-fname      as character no-undo .
define input  parameter p-art-fname      as character no-undo .
define input  parameter p-retry-fname    as character no-undo .
define input  parameter table for tt-imp-parts-ptrl.
define output parameter p-count-err      as integer no-undo .
define output parameter p-count-err1     as integer no-undo . /* - нет соответствий по товарам */
define output parameter p-count-err2     as integer no-undo . /* - нет соответствий по поставщикам */


define variable vss-revision    as character no-undo init "$Revision: 022d9db987b8, 3255, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/01/27 13:45:26 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-doc4cr-ptrl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-doc4cr-ptrl.p $":U .
define variable vss-description as character no-undo init "Импорт накладных. Создание документов.".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ ref/extclass.i }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ cmp/gds-list.i gds-list def }
{ str/doc-code.i }
{ str/lib-def.i  }
{ cmp/df-sub.i   }
{ cmp/thth150.i }


define temp-table temp_parts no-undo like ub.parts
/* 14/IX-2018 - не используется. Присвоения перенаправлены в старые поля - artic + prod_type + prod_code
  field new_artic     as character
  field new_prod-type as character
  field new_prod-code as integer
*/
  field cli-qnty1     as decimal
  field fact-qnty1    as decimal
  field qnty1         as decimal  
  field new-cli-type  as character
  field new-cli-code  as integer
  index pi is primary
supp-type
supp-code
host-code
contract-code
VAT-type
VAT-PC
prod-type
prod-code
artic
price-cli
part-code
fact-date
.

define temp-table temp-line no-undo
  field num           as integer
  field supp-type     as character
  field supp-code     as integer
  field host-code     as integer
  field contract-code as integer
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field part-code     as character
  field vat-type      as character
  field vat-pc        as decimal
  field price-rubl    as decimal
  field fact-qnty     as decimal
  field cli-qnty      as decimal
  field new-cli-type  as character
  field new-cli-code  as integer
  field pl-code       as integer
  index pi is primary
  supp-type
  supp-code
  host-code
  contract-code
  vat-type
  vat-pc
  artic
  prod-type
  prod-code
  part-code
  price-rubl
  num
.

define temp-table temp-2exists no-undo
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field doc-code  as character
  index pi is unique primary
  doc-code
  artic
  prod-type
  prod-code
.

define temp-table tt-trn-close no-undo
  field trn-code as character
.

define temp-table tt-gds no-undo
  field gds-code as integer
.



define temp-table tt-trn-doc   no-undo like ub.trn-doc .
define temp-table tt2-doc-line no-undo like lib-trn_ret-line .
define temp-table tt-doc-line  no-undo like ub.doc-line
  field pl-code as integer
.
define temp-table tt-gds-dtl   no-undo like ub.gds-dtl .
define temp-table tt-parts     no-undo like ub.parts.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr .
define temp-table gds-list1    no-undo like gds-list .

define variable v-f-cli-code as integer   no-undo .
define variable new_obj-code   as integer   no-undo .
define variable new_obj-type   as character no-undo .
define variable new_host-code  as integer   no-undo .
define variable new_purch-code as integer no-undo .
define variable v-tti as integer   no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-ii          as integer   no-undo .

define buffer new_ext-classif for ub.ext-classif  .
define buffer new_line        for temp-line  .
define buffer buf2_temp_parts for temp_parts  .
define buffer old_contract-specif for ub.contract-specif  .
define buffer buf_shop        for ub.shop .

define variable local-trace-on as logical no-undo .
local-trace-on = false .

define variable p-from-version as character initial {&thth150-from-version} no-undo .

&glob display-message  run write-log-and-file in p-log-handle ( 1, p-log-filename, 1, ~{&my-message~} )


&scop my-message substitute("Перенос партий свободной зоны из &1 в 16.0 ...", p-from-version)
{&display-message}.


  /* 29/X-2018 накладные разрешается вкачивать только в объект текущей БД */    
  define variable v-db-num as integer   no-undo .
  { gbl/objdbnum.i
     p-obj-type
     p-obj-code
     v-db-num
  }
  if v-db-num <> ibs.th.gbl.gbl-var:g#db-num then do :
    &scop my-message substitute("Накладные разрешается вкачивать только в объект текущей БД. Номер текущей базы данных &1, номер базы данных выбранного объекта &2", ibs.th.gbl.gbl-var:g#db-num, v-db-num) 
    {&display-message}.
    undo, throw new Progress.Lang.AppError ({&my-message}) .
  end .

  if p-is-close then do :
    /* скопировано из trn-tri.i */
    if not can-find (first ub.pay-type where ub.pay-type.obj-code = v-cntxp-in-pay) then do:
      &scop my-message substitute("В настройках объекта &1 указан вид оплаты прихода &2, который отсутствует в справочнике.", p-obj-code, v-cntxp-in-pay) 
      {&display-message}.
      undo, throw new Progress.Lang.AppError ({&my-message}) .
    end .
  end .


/* ----- перекодировка их xxx-15_0 в наш xxx_16_0 ----- */
define stream fosnid.
define temp-table w-osn no-undo
  field supp-type-15_0 as character
  field supp-code-15_0 as integer
  field supp-code-16_0 as integer
.
// 19/IX-2018 сопоставление товаров потребовалось переделать с артикулов на коды товаров 
define temp-table w-gds no-undo
  field gds-code-15_0 as integer
  field gds-code-16_0 as integer
.

/* ----- коды поставщиков ----- */
&scop my-message substitute("чтение файла соответствия поставщиков &1", p-osn-fname)
{&display-message}.

  file-info:file-name = p-osn-fname .
  if file-info:file-type = ? then do :
    &scop my-message substitute("Отсутствует файл для импорта &1", p-osn-fname) 
    {&display-message}.
    undo, throw new Progress.Lang.AppError ({&my-message}) .
  end .
input stream fosnid from value (p-osn-fname).
repeat:
  define variable v-osn-15 as character no-undo .
  define variable v-osn-16 as integer no-undo .
  define variable v-error  as logical no-undo .
  import stream fosnid delimiter ';' v-osn-15 v-osn-16.
  create w-osn.
    w-osn.supp-type-15_0 =         substring(v-osn-15, 1, 3) no-error .
    if error-status:error then v-error = true .
    w-osn.supp-code-15_0 = integer(substring(v-osn-15, 4)) no-error .
    if error-status:error then v-error = true .
    w-osn.supp-code-16_0 =                   v-osn-16 no-error .
if v-error then do:
    &scop my-message substitute("Не правильная кодировка в файле для импорта &1", p-osn-fname) 
    {&display-message}.  
end.   
end.
input stream fosnid close.
/* для импорта напрямую в w-osn последняя пустая строка в импортируемом файле:
find w-osn where w-osn.supp-code-16_0 = 0 and w-osn.supp-code-15_0 = 0 no-error.
if available w-osn then delete w-osn.
*/

/* ----- коды товаров ----- */
&scop my-message substitute("чтение файла соответствия товаров &1", p-art-fname)
{&display-message}.
input stream fosnid from value (p-art-fname).
repeat:
  create w-gds.
  import stream fosnid delimiter ';' w-gds.
end.
input stream fosnid close.
find w-gds where w-gds.gds-code-16_0 = 0 and w-gds.gds-code-15_0 = 0 no-error.
if available w-gds then delete w-gds.


  /* p-obj-type и p-obj-code заданы для целевой системы; информация об исходной системе не требуется */
  assign
    new_obj-type = p-obj-type
    new_obj-code = p-obj-code
  .  
  find first buf_shop no-lock where buf_shop.obj-code = new_obj-code no-error .
  if available buf_shop then do:
    new_purch-code = if buf_shop.purch-code > 0 then buf_shop.purch-code else {&bef-repayment-code} .
  end .
  else new_purch-code = {&bef-repayment-code} .

    { gbl/hostcode.i
      new_obj-type
      new_obj-code
      new_host-code
      }
    { gbl/objdtget.i
      new_obj-type
      new_obj-code
      to-day
      no-error
    }
  

    empty temp-table temp-line no-error .
    EMPTY TEMP-TABLE temp_parts no-error .
    empty temp-table tt-parts .


define stream f-err-lines .
if p-retry-fname > '' then . else do :
  p-retry-fname = substitute("&1imp-parts-ptrl.err", ibs.th.gbl.gbl-inipar:logDir ) .
end .
output stream f-err-lines to value(p-retry-fname) .  
run create_temp_parts in this-procedure
   (new_obj-code
  , new_obj-type
  , new_host-code
  , output p-count-err
  , output p-count-err1
  , output p-count-err2
  ).
output stream f-err-lines close .
  
/* импорт шапки */
empty temp-table tt-trn-close .
run import-hed in this-procedure no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка при импорте ПН  &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
      return error  .
    end.

  /* 29/X-2018 сначала всё импортируем, потом всё закрываем. */
  for each tt-trn-close :

    { str/tdat-wrt.i                                    
       tt-trn-close.trn-code
       {&trdcattr-is-auto-trn}
       "yes" 
    no-error}
    
    &scop my-message substitute(" Закрытие документа &1 на ФАКТ" , tt-trn-close.trn-code )
    {&display-message}.
    run clos-trn2 in this-procedure (tt-trn-close.trn-code) no-error .
    if not can-find (first trn-doc where trn-doc.doc-code = tt-trn-close.trn-code
                                     and trn-doc.status_  = {&fact}) then do:
      &scop my-message substitute("Не удалось закрыть на факт ПН &1 &2 &3" ,tt-trn-close.trn-code , return-value , error-status :get-message(1) )
      {&display-message}.
     end.
  end .
  for each tt-gds:
    
    find first ub.goods-attr where ub.goods-attr.gds-code = tt-gds.gds-code and ub.goods-attr.attr-code = {&attr-ptrl-without-rvs} no-error.
    if available (ub.goods-attr)
      then delete ub.goods-attr.
    
  end.

  &scop my-message substitute("При переносе остатков по топливу отвергнуто &1 записей. Из них:", p-count-err )
  {&display-message}.
  &scop my-message substitute("  нет соответствий по товарам &1", p-count-err1 )
  {&display-message}.
  &scop my-message substitute("  нет соответствий по поставщикам &1", p-count-err2 )
  {&display-message}.
  &scop my-message substitute("  прочие ошибки &1", p-count-err - p-count-err2 - p-count-err1 )
  {&display-message}.



define stream f-tgds .
/* 25/IX-2018 при вызове из load-from-15_0.w создать выходную строку по прочитанным полям */
function getImpRow returns character private (buffer buf_tt-parts for tt-imp-parts-ptrl) :
define variable v-imp-row as character no-undo .
  v-imp-row =    
          substitute("&1;", buf_tt-parts.artic) +
          ";" +
          substitute("&1;", buf_tt-parts.part-code) +
          substitute("&1;", buf_tt-parts.in-code) +
          substitute("&1;", buf_tt-parts.gds-code) +
          substitute("&1;", buf_tt-parts.price-rubl) +
          substitute("&1;", buf_tt-parts.fact-qnty) +
          ";" + 
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.vat-tax-value) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.name-gtd) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.srok-god) +
          ";" +
          ";" +
          substitute("&1;", buf_tt-parts.supp-code) +
          substitute("&1;", buf_tt-parts.supp-type) +
          substitute("&1;", buf_tt-parts.cont-prn-code) +
          substitute("&1;", buf_tt-parts.pl-loc1) +
          substitute("&1;", buf_tt-parts.cli-qnty)
  .
  return v-imp-row .
end function .          
procedure create_temp_parts private :
define input  parameter p-obj-code  as integer no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-host-code as integer no-undo .
define output parameter p-count-err as integer no-undo .
define output parameter p-count-err1 as integer no-undo .
define output parameter p-count-err2 as integer no-undo .
define variable v-last-date as date no-undo .
define variable v-artic     as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer no-undo .
define variable v-contract-code as integer no-undo .
define variable new_cli-type  as character no-undo .
define variable new_cli-code  as integer   no-undo .
define variable new_gds-code  as integer no-undo .
define variable v-is-supp-err as logical no-undo .
define variable v-is-cont-err as logical no-undo .
define variable v-is-good-err as logical no-undo .
define variable v-my-message  as character no-undo .
define variable v-today       as date no-undo .
define buffer buf_tt-parts    for tt-imp-parts-ptrl .
define buffer buf_goods       for ub.goods .
define buffer buf_goods-attr  for ub.goods-attr .
define buffer buf_contract for ub.contract .
define buffer new_clients  for ub.clients .

  &scop my-message v-my-message
  
  assign
    p-count-err  = 0
    p-count-err1 = 0
    p-count-err2 = 0
    v-today = today
  .
  
  for each buf_tt-parts
  break by buf_tt-parts.supp-code
        by buf_tt-parts.cont-prn-code
        by buf_tt-parts.gds-code
  :
    if first-of (buf_tt-parts.supp-code) then do:
      /* Если у партии не указан код поставщика - такую строку считать ошибочной и не обрабатывать.
         Код фиктивного контрагента не использовать. */
      if buf_tt-parts.supp-type = ""
      or buf_tt-parts.supp-type = {&stock}
      or buf_tt-parts.supp-type = {&shop} then assign
        v-my-message  = substitute ("Фиктивный контрагент &1 &2", buf_tt-parts.supp-type, buf_tt-parts.supp-code )
        v-is-supp-err = true
      .
      else do :
        /* поиск соответствия старого cli-type+cli-code p-from-version версии в 16.0 */
        find first w-osn where w-osn.supp-code-15_0 = buf_tt-parts.supp-code
                           and w-osn.supp-type-15_0 = buf_tt-parts.supp-type no-error .
        if available w-osn then do:
          assign
            new_cli-type = {&cmp} /*            new_cli-type = buf_tt-parts.supp-type*/
            new_cli-code = w-osn.supp-code-16_0
          .
          v-is-supp-err = not can-find (first new_clients
                                        where new_clients.obj-type = new_cli-type
                                          and new_clients.obj-code = new_cli-code) .
          if v-is-supp-err then v-my-message = substitute("ошибка (новый клиент &1 &2)", new_cli-type , new_cli-code) .
        end .
        else assign
          v-my-message  = substitute ( "Отсутствует код поставщика &1 &2 в файле соответствия &3"
                                     , buf_tt-parts.supp-type, buf_tt-parts.supp-code, p-osn-fname )
          v-is-supp-err = true
        .
      end .
      
      

      
      if v-is-supp-err then do :
        /* Ошибку выводить в лог-файл, а строку ошибки выводить в отдельный файл, пригодный для повторного импорта, как есть.
           Работу по остальным строкам продолжать. */
        {&display-message}.
      end .
    end . /* end_of first_of_tt-parts.supp-code */
    if v-is-supp-err then do :
      /* @NOTE надо отсечь все строки с этим поставщиком, а не только первую */
      if buf_tt-parts.imp-row > "" then 
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err2 = p-count-err2 + 1 .
      next .
    end .
      
    if first-of (buf_tt-parts.cont-prn-code) then do:
      find first buf_contract no-lock
           where buf_contract.contract-prn-code = buf_tt-parts.cont-prn-code 
           and buf_contract.cli-type = new_cli-type
           and buf_contract.cli-code = new_cli-code no-error .
      if available buf_contract then assign
        v-contract-code = buf_contract.contract-code
        v-is-cont-err   = false
      .
      else do :
        /* 24/XII-2018  При отсутствии договора искать любой похожий, а при полном отсутствии отвергать партию. */
        v-my-message  = substitute (
          "Предупреждение. Отсутствует договор № &2 (вер.15) по поставщику &3 в вер.16. Товар &1 в вер.15",
          buf_tt-parts.gds-code, buf_tt-parts.cont-prn-code, new_cli-code ) .
        {&display-message}.
        assign
          v-contract-code = 0
          v-is-cont-err   = true
        .
        for each buf_contract no-lock
           where buf_contract.cli-type = new_cli-type
             and buf_contract.cli-code = new_cli-code
              by buf_contract.contract-date-beg descending :
          if buf_contract.contract-date-end < v-today then . else do :
            v-my-message  = substitute (
              "Предупреждение. Вместо договора № &2 (вер.15) по поставщику &3 в вер.16 используется договор &4 (код=&5). Товар &1 в вер.15&6",
              buf_tt-parts.gds-code, buf_tt-parts.cont-prn-code, new_cli-code,
              buf_contract.contract-prn-code, buf_contract.contract-code, {&new-line} ) .
            {&display-message}.
            assign
              v-contract-code = buf_contract.contract-code
              v-is-cont-err   = false
            .
            leave .
          end .
        end .
        /* 28/IV-2018 Ошибку выводить в лог-файл, как и в случае отвергнутого поставщика. */
        if v-is-cont-err then do :
          /* 05/VI-2019  нестыковочка: по техпроливу нет договора,
                         поэтому отсутствие договора в топливе считать допустимым */
          v-is-cont-err = false.
          v-my-message  = substitute (
            "Предупреждение. Отсутствует действующий договор на дату &3 по поставщику &2 в вер.16. Товар &1 в вер.15&4",
            buf_tt-parts.gds-code, new_cli-code, v-today, {&new-line} ) .
          {&display-message}.
        end .
      end.

    end . /* end_of first_of_tt-parts.cont-prn-code */
    /* 26/IV-2018  Товары с ненайденным договором надо отображать в логе.
       24/XII-2018 Отвергать партию при отсутствии договора.
       05/VI-2019  Ничего этого не надо, т.к. топливо можно импортировать без договора.    
    */
    /*
    if v-is-cont-err then do :
      if buf_tt-parts.imp-row > "" then 
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err2 = p-count-err2 + 1 . /* отсутствие договора считаем как несоответствие по поставщикам */
      next .
    end .
    */

    if first-of (buf_tt-parts.gds-code) then do:
      /* поиск соответствия старого gds-code из версии p-from-version в новых кодах версии 16.0 */
      find first w-gds where w-gds.gds-code-15_0 = buf_tt-parts.gds-code no-error .
      if available w-gds then do :
        new_gds-code = w-gds.gds-code-16_0 .
        find first buf_goods no-lock
             where buf_goods.gds-code = new_gds-code no-error .
        if available buf_goods then assign
          v-artic     = buf_goods.artic
          v-prod-type = buf_goods.prod-type
          v-prod-code = buf_goods.prod-code
          v-is-good-err = false
        .
        else assign
          v-artic     = ""
          v-prod-type = ""
          v-prod-code = 0
          v-is-good-err = true
          v-my-message  = substitute ("Отсутствует товар с кодом &1 в справочнике товаров БД вер.16", new_gds-code )
        .
      end .
      else assign
        v-my-message  = substitute ("Отсутствует код товара &1 из вер.15 в файле соответствия &2", buf_tt-parts.gds-code, p-art-fname )
        v-is-good-err = true
      .
      
      DEFINE VARIABLE pltn AS DECIMAL .
      pltn = ROUND ((buf_tt-parts.cli-qnty / buf_tt-parts.fact-qnty), 4 ) .
      IF (buf_tt-parts.cli-qnty / buf_tt-parts.fact-qnty  > 1 ) THEN DO:
      MESSAGE 'плотность более 1, остатки с такой плотностью не переносятся.' pltn VIEW-AS ALERT-BOX.
      v-is-good-err = TRUE. 
      p-count-err = p-count-err + 1 .
      v-is-cont-err = TRUE.
      v-my-message  = substitute ("Ошибка. Плотность &1, остатки с такой плотностью не переносятся, код товара &2", pltn, new_gds-code ).
      END.
      
      /* 28/IV-2018 Ошибку выводить в лог-файл, как и в случае отвергнутого поставщика. */
      if v-is-good-err then do :
        {&display-message}.
      end .
    end .
    /* 26/IV-2018  Партии с ненайденным товаром надо отвергать */
    if v-is-good-err then do :
      if buf_tt-parts.imp-row > "" then 
        put stream f-err-lines unformatted buf_tt-parts.imp-row skip .
      else
        put stream f-err-lines unformatted getImpRow(buffer buf_tt-parts) skip .
      p-count-err = p-count-err + 1 .
      p-count-err1 = p-count-err1 + 1 .
      next .
    end .
    /* 26/IV-2018  Товары с ненайденным договором надо отображать в логе */
    /* 05/VI-2019  Для топлива товар можно импортировать без договора. Не надо отображать.    
    if v-is-cont-err then do :
      v-my-message  = substitute ("Отсутствует договор № &1 в целевой БД. Товар &2 будет загружен без указания договора.",
                                  buf_tt-parts.cont-prn-code, new_gds-code ) .
      {&display-message}.
    end .
    */
    if buf_tt-parts.srok-god = "" then v-last-date = 01/01/2001 .
                                  else v-last-date = date(buf_tt-parts.srok-god) no-error .
    do :
    find first ub.place no-lock where ub.place.obj-type = p-obj-type
      and ub.place.obj-code = p-obj-code
      and ub.place.loc1 = buf_tt-parts.pl-loc1 no-error .
      
    if not available (ub.place) then next .
    find first temp_parts where 
          temp_parts.new-cli-code = new_cli-code
      and temp_parts.artic = v-artic
      and temp_parts.prod-type  = v-prod-type
      and temp_parts.prod-code  = v-prod-code
      and temp_parts.contract-code = v-contract-code
      and temp_parts.pl-code = ub.place.pl-code
          no-error.
    if available (temp_parts)
    then do:
      assign
        temp_parts.fact-qnty1 = temp_parts.fact-qnty1 + buf_tt-parts.fact-qnty
        temp_parts.cli-qnty1 = temp_parts.cli-qnty1 + buf_tt-parts.cli-qnty
      .
        temp_parts.cli-base-rate = temp_parts.fact-qnty1 / temp_parts.cli-qnty1.
      next.
    end.
      
    create temp_parts.
    assign
      temp_parts.artic      = v-artic // 19/IX-2018 поле из импорта buf_tt-parts.artic игнорируется
      temp_parts.prod-type  = v-prod-type
      temp_parts.prod-code  = v-prod-code
      /* 14/IX-2018 - не используются
      temp_parts.new_artic     = buf_tt-parts.artic
      temp_parts.new_prod-type = v-prod-type
      temp_parts.new_prod-code = v-prod-code
      */

      temp_parts.obj-type   = p-obj-type
      temp_parts.obj-code   = p-obj-code
      temp_parts.host-code  = p-host-code 

      temp_parts.supp-code  = new_cli-code
      temp_parts.supp-type  = new_cli-type
      temp_parts.new-cli-type = new_cli-type
      temp_parts.new-cli-code = new_cli-code
      temp_parts.contract-code = v-contract-code
//  field cont-prn-code like ub.contract.contract-prn-code

      temp_parts.in-code    = buf_tt-parts.in-code // temp_parts.in-code используется для распределения партий по накладным; далее после записи документа в БД перезатирается номером созданного документа внутри стандартных процедур
//      temp_parts.out-code создаётся пустым и потом заполняется номером документа, в который внесён товар по данной партии 
      temp_parts.part-code  = buf_tt-parts.part-code // Код, определяющий конкретную партию внутри одного прихода

//  field gds-code      as integer - в таблице parts не предусмотрено поле gds-code

      temp_parts.price-rubl = buf_tt-parts.price-rubl // вместо price-cli используется price-rubl
      temp_parts.fact-qnty1  = buf_tt-parts.fact-qnty
      temp_parts.cli-qnty1   = buf_tt-parts.cli-qnty
      temp_parts.VAT-type   = {&inc-VAT}
      temp_parts.VAT-pc     = buf_tt-parts.vat-tax-value
      temp_parts.cst-code   = buf_tt-parts.name-gtd
      temp_parts.last-date  = v-last-date
      temp_parts.cli-base-rate = temp_parts.fact-qnty1 / temp_parts.cli-qnty1
      temp_parts.pl-code = ub.place.pl-code
    .
    end .
  /*
остались незаполненными:
whole-send-news;integer;->,>>>,>>9;Отправилась в новости целой записью;;0;Признак отправки в новости из текущей бд;50;;0;;false;false;;;;;;;;;;;;
price-base;decimal;->>,>>9.99;Цена (вал);Цена (вал);0;$учетная цена в базовой валюте из внешних приходов`Price(cur)`Pret (val.);260;10;0;;false;false;;;;;;;;;;;;
qnty;decimal;->>,>>>,>>9.999;По док-ту;По док-ту;0;Количество товара по док-ту в учетных единицах измерения`On doc`Pe act   ;280;3;0;;true;false;;;;;;;;;;;;
fact-date;date;99/99/99;;;;Дата внешней приходной накладной`External income way-bill date;310;;0;;false;false;;;;;;;;;;;;
fact-num;integer;->,>>>,>>9;;;0;порядковый номер закрытия по факту in-code`sequence number of closing by fact in-code;320;;0;;false;false;;;;;;;;;;;;
PS;character;X(50);Описание;Описание;;описание партии (изделия с серийным номером)`Descript`Legenda ;360;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
pay-code;integer;99999;&Оплата;Оплата;;`&Paym.`&Plata ;370;;0;;false;false;;;;;;;;;;;;
status_;logical;yes/no;;;no;yes для закрытых по факту накладых`yes for notes closed by fact;380;;0;;false;false;;;;;;;;;;;;
rsrv-free;logical;yes/no;;;no;yes - резерв и свободная зона, no - резерв и расходная зона , ? - все остальное`yes - stock and free area, no - stock and expense area , ? - the rest;420;;0;;false;false;;;;;;;;;;;;
doc-type;character;X(8);Тип;Тип;;тип документа, на который зарезервирована или закрыта партия. Используется для пометки партий в browse. Не тип документа, породившего партию.`Typ`Tip;430;;0;;true;false;;;;;;;;;;1251;RUSSIAN_I;
cli-qnty;decimal;->>,>>>,>>9.999;По ТТН;По ТТН;0;Фактическое количество товара в единицах измерения поставщика`On GTW`Pe NTT;440;3;0;;false;false;;;;;;;;;;;;
pl-code;integer;999999999;Бар-код;;0;`Bar-cod`Bar-cod;450;;0;;true;false;;;;;;;;;;;;
exch-code;integer;>>9;Валюта;Валюта;;код валюты поставщика`CRC.`Valuta;470;;0;;false;false;;;;;;;;;;;;
cli-base-rate;decimal;>>,>>9.<<<<;Коэффициент;Коэффициент;0;`Coefficient`Coeficient ;490;10;0;;true;false;;;;;;;;;;;;
SLT-pc;decimal;>9.9<%;Налог с продаж;Налог с продаж;0;`Sales tax`Impoz pe vinz ;500;10;0;;false;false;;;;;;;;;;;;
is-supp;logical;yes/no;;;no;yes - создана внешней ПН, no - другим документом`yes - created by external DN, no- by other docum;520;;0;;false;false;;;;;;;;;;;;
real-qnty;decimal;->>,>>>,>>9.999;Реальное количество;Реальное количество;;Реальное количество товара в учетных единицах измерения, зарезервированное из положительных партий расходной или свободной зоны (в отличие от вновь созданных партий по данному документу)`Real quantity`Cant-tea reala     ;530;3;0;;false;false;;;;;;;;;;;;
SLT-type;character;X(8);НП;НП;;способ расчета НП`ST`Impoz pe vinz ;540;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
road-tax-base;decimal;->,>>>,>>9.99;Дорожный налог(вал);;;$`Road tax (shaft)`Tarif de drum(val) ;570;10;0;;false;false;;;;;;;;;;;;
road-tax-rubl;decimal;->,>>>,>>9.99;Дорожный налог(руб);;;$`Road tax (nc)`Tarif de drum(nc)  ;580;10;0;;false;false;;;;;;;;;;;;
transport-base;decimal;->,>>>,>>9.99;Транспортные расходы(вал);;;$`Transport expenditures (shaft)`Transport cheltueli(val) ;590;10;0;;false;false;;;;;;;;;;;;
transport-rubl;decimal;->,>>>,>>9.99;Транспортные расходы(руб);;;$`Transport expenditures (nc)`Transport cheltueli( nc) ;600;10;0;;false;false;;;;;;;;;;;;
other-base;decimal;->,>>>,>>9.99;Прочие расходы(вал);;;$`Other expenditures (shaft)`Diverse chelt (val);610;10;0;;false;false;;;;;;;;;;;;
other-rubl;decimal;->,>>>,>>9.99;Прочие расходы(руб);;;$`Other expenditures (nc)`Diverse chelt  (nc);620;10;0;;false;false;;;;;;;;;;;;
purch-code;integer;9;Тип приобретения;;;Тип приобретерия;630;;0;;false;false;;;;;;;;;;;;
mark-db-num;integer;>>>>9;БД акцизной марки;БД акцизной марки;0;Номер БД, где была создана запись акцизной или специальной марки;650;;0;;false;false;;;;;;;;;;;;
mark-code;integer;999999999;Код акцизной марки;Код акцизной марки;0;Внутренний код акцизной или специальной марки;660;;0;;false;false;;;;;;;;;;;;
alc-bottling-date;date;99/99/9999;Дата разлива;Дата разлива;;Дата разлива алкогольной продукции;670;;0;;false;false;;;;;;;;;;;;
alc-ref-ab-path;character;X(255);Справки А,Б;Справки А,Б;;Путь к файлу справок А,Б для алкогольной продукции;680;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
alc-quality-certif-path;character;X(255);Удостоверение качества;Удостоверение качества;;Путь к файлу удостоверения качества для алкогольной продукции;690;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
alc-certif-path;character;X(255);Сертификат соответствия;Сертификат соответствия;;Путь к файлу сертификата соответствия для алкогольной продукции;700;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
alc-imp-code;integer;99999;Код импортера;;0;Код импортера;710;;0;;true;false;;;;;;;;;;;;
alc-imp-type;character;X(3);Тип импортера;Тип;;Тип импортера;720;;0;;true;false;;;;;;;;;;1251;RUSSIAN_I;
hold-date;date;99/99/99;;;;Дата создания МФ или МО родительского документа;730;;0;;false;false;;;;;;;;;;;;
dop;character;x(8);;;;;740;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
price-prod;decimal;>>,>>9.99;Цена производителя;Цена производителя;0;$Цена производителя`Price(prod)`Pret ();750;10;0;;false;false;;;;;;;;;;;;
prt-code;integer;>>>>>>9;Признак;Признак;0;Код узла дерева признаков.`Nomenclature number`N nomenclator   ;751;;0;;true;false;;;;;;;;;;;;
defect;logical;yes/no;;;no;;761;;0;;false;false;;;;;;;;;;;;
price-prod-vat;decimal;->>,>>9.99;Цена производителя;Цена производителя;0;Цена производителя с НДС;771;2;0;;false;false;;;;;;;;;;;;
  */

    do : /* 28/IV-2018 перенести создание партий tt-parts из import-hed() сюда */
    end .

  end . /* end_of for_each_tt-parts */
// output stream f-tgds close .

  if p-count-err > 0 then do :
    v-my-message  = substitute (
      "Строки с ошибками выведены в файл &1. Файл предназначен для повторного импорта в ручном режиме"
    , p-retry-fname ) .
    {&display-message}.
  end .
  
if local-trace-on then do:
 define variable dsXmlFileName as character no-undo .
 dsXmlFileName = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "temp_parts").
 temp-table temp_parts:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end .
&undefine my-message
end procedure . /* create_temp_parts */


procedure import-hed :
define variable v-qnty-fact as decimal   no-undo .
define variable v-qnty-cli  as decimal   no-undo .
define variable v-num       as integer   no-undo .

define variable dsXmlFileName as character no-undo .
define variable dsLineCount   as integer no-undo .

// Message "Обработка файла" p-in-file view-as alert-box .
do on error undo, return error substitute("ошибка &1 &2", error-status:get-message(1) , return-value) :
  assign
  v-qnty-fact = 0
  v-qnty-cli  = 0
  dsLineCount = 0
  .
  &scop my-message substitute("Подготовка партий..."  )
  {&display-message}.

  for each temp_parts break
   by temp_parts.supp-type
   by temp_parts.supp-code
   by temp_parts.host-code
   by temp_parts.contract-code
   by temp_parts.VAT-type 
   by temp_parts.VAT-PC
   by temp_parts.prod-type
   by temp_parts.prod-code
   by temp_parts.artic
   by temp_parts.price-rubl
/* 21/V-2018 - с разной ценой ложится в разные накладные;
               с разными номерами партий ложится в одну накладную.
   by temp_parts.part-code*/
   by temp_parts.pl-code
  :
    dsLineCount = dsLineCount + 1 .  
    do : /* 16/IV-2018 перенос создания партий из create-nakl() */
    create tt-parts.
    assign
      /* 14/IX-2018 - поля new_prod-type, new_prod-code и new_artic заменены на свои аналоги без new_
      tt-parts.prod-type      = temp_parts.new_prod-type
      tt-parts.prod-code      = temp_parts.new_prod-code
      tt-parts.artic          = temp_parts.new_artic
      */
      tt-parts.prod-type      = temp_parts.prod-type
      tt-parts.prod-code      = temp_parts.prod-code
      tt-parts.artic          = temp_parts.artic
      
      tt-parts.obj-type       = new_obj-type
      tt-parts.obj-code       = new_obj-code
      tt-parts.host-code      = new_host-code
      tt-parts.supp-type      = temp_parts.new-cli-type
      tt-parts.supp-code      = temp_parts.new-cli-code

      tt-parts.price-base     = temp_parts.price-rubl
      tt-parts.price-rubl     = temp_parts.price-rubl
      tt-parts.price-cli      = temp_parts.price-rubl
      tt-parts.cli-base-rate  = 1

      tt-parts.qnty           = temp_parts.fact-qnty1
      tt-parts.fact-qnty      = temp_parts.fact-qnty1
      tt-parts.cli-qnty       = temp_parts.cli-qnty1
    
      tt-parts.VAT-pc         = temp_parts.vat-pc
      tt-parts.VAT-type       = temp_parts.vat-type
      tt-parts.SLT-pc         = 0
      tt-parts.SLT-type       = {&without-slt}
      tt-parts.road-tax-base  = 0
      tt-parts.road-tax-rubl  = 0
      tt-parts.transport-base = 0
      tt-parts.transport-rubl = 0
      tt-parts.other-base     = 0
      tt-parts.other-rubl     = 0
    
      tt-parts.PS             = ""
    
      tt-parts.fact-date      = ? // источник заполнения new_trn-doc.fact-date отсутствует 
      tt-parts.fact-num       = 0
      // tt-parts.pay-code заполняется непосредственно в tt-trn-doc
      tt-parts.rsrv-free      = ?
      tt-parts.pl-code        = 0
      tt-parts.exch-code      = 0
      tt-parts.is-supp        = yes
      tt-parts.last-date      = ?
      tt-parts.purch-code     = ? // источник заполнения new_trn-doc.purch-code отсутствует
      tt-parts.contract-code  = temp_parts.contract-code
    
      /* внутри create-nakl() выполнится привязка партий к сознанной по ним накладной */
      tt-parts.doc-type       = {&income}
      tt-parts.part-code      = temp_parts.part-code + temp_parts.out-code
      tt-parts.in-code        = temp_parts.in-code // в исходной версии - new_trn-doc.doc-code
      tt-parts.out-code       = "" // new_trn-doc.doc-code
      tt-parts.cst-code       = ""
      tt-parts.status_        = no
      tt-parts.cli-base-rate  = temp_parts.cli-base-rate
      tt-parts.pl-code        = temp_parts.pl-code
     no-error. 
     if error-status:error then do:
         message 'ошибка импорта' tt-parts.artic temp_parts.in-code temp_parts.out-code view-as alert-box.
         end.
    end .
    
    v-qnty-fact = v-qnty-fact + temp_parts.fact-qnty1  .
    v-qnty-cli  = v-qnty-cli  + temp_parts.cli-qnty1  . // - не заполняется

    if last-of ( temp_parts.price-rubl )
    or last-of ( temp_parts.pl-code )
    then do:
      /* 28/IV-2018 - добавить вместе с объединением партий с разной ценой в одну накладную
      if temp_parts.price-rubl <= 0  or temp_parts.price-rubl = ? then do:
        &scop my-message substitute("Цена &2   = &1 Пропускаю " , temp_parts.price-rubl  , temp_parts.artic )
        {&display-message}.
        next.
      end.
      if v-qnty-fact <= 0 then do:
        &scop my-message substitute("Количество &2   = &1 Пропускаю " , v-qnty-fact  , temp_parts.artic )
        {&display-message}.
        next.
      end.
      */
      create temp-line .
      assign
      temp-line.supp-type     = temp_parts.supp-type
      temp-line.supp-code     = temp_parts.supp-code
      temp-line.host-code     = temp_parts.host-code
      temp-line.contract-code = temp_parts.contract-code
      temp-line.vat-type      = temp_parts.vat-type
      temp-line.vat-pc        = temp_parts.vat-pc
      temp-line.prod-type     = temp_parts.prod-type
      temp-line.prod-code     = temp_parts.prod-code
      temp-line.artic         = temp_parts.artic
      temp-line.price-rubl    = temp_parts.price-rubl
      temp-line.pl-code       = temp_parts.pl-code
// 21/V-2018 temp-line.part-code     = temp_parts.part-code
//  field num           as integer
      temp-line.fact-qnty     = v-qnty-fact
      temp-line.cli-qnty      = v-qnty-cli
      temp-line.new-cli-type  = temp_parts.new-cli-type
      temp-line.new-cli-code  = temp_parts.new-cli-code
      v-qnty-fact = 0
      v-qnty-cli  = 0
      .
    end.
if local-trace-on then do:
 dsXmlFileName = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt_parts", string(dsLineCount, "9999999")).
 temp-table tt-parts:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end.
  end. /* for each temp_parts break*/

  &scop my-message substitute("обработано &1 партий", dsLineCount  )
  {&display-message}.

  /* связка полей temp-line.prod-type + prod-code + artic меняется на temp-line.num;
     поля temp_parts.price-rubl и temp_parts.part-code из признаков разделения по накладным исключены */
  for each temp-line  break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.prod-type
  by temp-line.prod-code
  by temp-line.artic
  :
    if first-of (temp-line.artic) then do:
      v-num = 0 .
    end.
    v-num = v-num + 1 .
    temp-line.num = v-num .
  end.
if local-trace-on then do:
 dsXmlFileName = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "temp_line").
 temp-table temp-line:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
end.


  for each temp-line break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.num
  :
    if first-of (temp-line.num) then do:
      empty temp-table tt-trn-doc .
      empty temp-table tt2-doc-line .
      empty temp-table tt-doc-line .
      empty temp-table tt-gds-dtl .
      for each lib-trn_ret-doc :
        delete lib-trn_ret-doc.
      end.
      for each lib-trn_ret-line :
        delete lib-trn_ret-line      .
      end.
      for each lib-trn_ret-line-attr :
        delete lib-trn_ret-line.
      end.
      for each lib-trn_ret-dtl :
        delete lib-trn_ret-dtl.
      end.
      for each lib-trn_ret-parts :
        delete lib-trn_ret-parts .
      end.
      run create-nakl in this-procedure  ( temp-line.num, temp-line.new-cli-type, temp-line.new-cli-code ) .
    end.
  end.

end. /*doe*/
end procedure. /* import-contr */

/* 19/IV-2018 - перекодировку через внешние классификаторы не используем:
                внешние классификаторы задаются в ГБД, а перекодировка уникальна для УБД
                
25/IX-2018 - и имена классификаторов тоже не используем                
define variable v-f-cli-type as character no-undo .
v-f-cli-type = {&cmp} .

define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .
case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.
                
procedure uni-k :
define input  parameter p-uniq-key-rec as character no-undo .
define input  parameter p-table as character no-undo .
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-gds-code as integer   no-undo .
do
on error undo, return error substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  case p-table :
    when {&table_clients} then do:
      if entry(1, p-uniq-key-rec, {&delim-key}) = {&table_clients} then do:
        assign
        p-obj-type = entry(2, p-uniq-key-rec, {&delim-key})
        p-obj-code = integer(entry(3, p-uniq-key-rec, {&delim-key}))
        p-gds-code = ?
        .
      end.
    end.
    when {&table_goods} then do:
      if entry(1, p-uniq-key-rec, {&delim-key}) = {&table_goods} then do:
        assign
        p-obj-type = ?
        p-obj-code = ?
        p-gds-code = integer(entry(2, p-uniq-key-rec, {&delim-key}))
        .
      end.
    end.
  end case.
end. /*doe*/
end procedure. /* uni-k */
*/

procedure create-nakl :
/* temp_parts и temp-line спозиционированны в вызывающей процедуре */
define input parameter p-num        as integer no-undo .
define input parameter new_cli-type as character no-undo .
define input parameter new_cli-code as integer no-undo . 
define variable n-d as character no-undo .
define variable v-ext-doc-type as character no-undo .
define buffer buf_goods for ub.goods .
define buffer buf_goods-attr  for ub.goods-attr .
define buffer new_trn-doc     for ub.trn-doc  .

do on error undo, return error return-value :
  run doc-code in this-procedure
    (input  "main":u,
     input  new_obj-type,
     input  new_obj-code,
     input  ?,
     output n-d ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при генерации номера документа &1 &2: &3 | &4" ,new_obj-type, new_obj-code, error-status:get-message(1), return-value )
    {&display-message}.
    undo, throw new Progress.Lang.AppError({&my-message}) .
  end.
  &scop my-message substitute("Создание ПН № &1 объект &2&3 контраг &4&5 &6" , n-d  , new_obj-type , new_obj-code ,  new_cli-type ,  new_cli-code , temp-line.contract-code )
  {&display-message}.

  assign
    v-ext-doc-type = {&TDEDT_Pri_Vnesh}
  .
    
  find first temp_parts where
             temp_parts.artic         = temp-line.artic     and
             temp_parts.prod-type     = temp-line.prod-type and
             temp_parts.prod-code     = temp-line.prod-code and
             temp_parts.supp-code     = temp-line.supp-code and
             temp_parts.supp-type     = temp-line.supp-type and
             temp_parts.host-code     = temp-line.host-code and
             temp_parts.vat-type      = temp-line.vat-type  and
             temp_parts.vat-pc        = temp-line.vat-pc    and
             temp_parts.contract-code = temp-line.contract-code  and
/*             temp_parts.part-code     = temp-line.part-code  and*/
             temp_parts.price-rubl    = temp-line.price-rubl no-error .
  if not available temp_parts then do:
    message "Parts not found" skip
 "artic:" temp-line.artic skip
 "prod-type:" temp-line.prod-type skip
 "prod-code:" temp-line.prod-code skip
 "supp-code:" temp-line.supp-code skip
 "supp-type:" temp-line.supp-type skip
 "host-code:" temp-line.host-code skip
 "vat-type:" temp-line.vat-type skip
 "vat-pc:" temp-line.vat-pc skip
 "contract-code:" temp-line.contract-code skip
 "part-code:" temp-line.part-code skip
 "price-rubl:" temp-line.price-rubl skip
    view-as alert-box.
    return. 
  end .

  
  do : /* create_tt-trn-doc */
  create  tt-trn-doc.
  buffer-copy temp_parts to tt-trn-doc
  assign
    tt-trn-doc.status_       = "temp"
    tt-trn-doc.doc-code      = n-d
    tt-trn-doc.doc-date      = to-day
    tt-trn-doc.cli-type      = new_cli-type
    tt-trn-doc.cli-code      = new_cli-code
    tt-trn-doc.obj-type      = new_obj-type
    tt-trn-doc.obj-code      = new_obj-code
    tt-trn-doc.host-code     = new_host-code
    tt-trn-doc.contract-code = temp-line.contract-code
    tt-trn-doc.doc-type      = {&income}
    tt-trn-doc.internal      = false
    tt-trn-doc.cr-db-num     = ibs.th.gbl.gbl-var:g#db-num
    tt-trn-doc.office        = false
    tt-trn-doc.fact-num      = 0
    tt-trn-doc.PS            = "Перенос остатков"
    tt-trn-doc.creid         = ibs.th.gbl.gbl-var:g#userid
    tt-trn-doc.flag_         = false
    tt-trn-doc.ext-doc-type  = v-ext-doc-type
    tt-trn-doc.discnt-type   = ""
    tt-trn-doc.ret-supp      = false
    tt-trn-doc.pay-code      = v-cntxp-in-pay
    tt-trn-doc.purch-code    = new_purch-code
    tt-trn-doc.SLT-type      = {&without-slt} // ранее это значение присвоилось во все tt-parts.SLT-type, но не в temp_parts
  .
  if tt-trn-doc.exch-code = ? then tt-trn-doc.exch-code = 0 .
  
  { gbl/baserate.i
    new_host-code
    temp_parts.fact-date
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    no-error  }
  if tt-trn-doc.base-rate  = ? or tt-trn-doc.base-rate  = 0 then tt-trn-doc.base-rate  = 1 .
  if tt-trn-doc.base-scale = ? or tt-trn-doc.base-scale = 0 then tt-trn-doc.base-scale = 1 .

  if tt-trn-doc.exch-rate  = ? or tt-trn-doc.exch-rate  = 0 then tt-trn-doc.exch-rate  = 1 .
  if tt-trn-doc.exch-scale = ? or tt-trn-doc.exch-scale = 0 then tt-trn-doc.exch-scale = 1 .
  
  { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      tt-trn-doc.purch-code
      no-error }
  if error-status :error then do:
    &scop my-message substitute("Ошибка при генерации  документа1 &1 &2" , return-value , error-status :get-message(1) )
    {&display-message}.
    return error return-value .
  end.
  end . /* end_of create_tt-trn-doc */
  
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  if error-status :error then do:
    &scop my-message substitute("Ошибка при генерации  документа2 &1 &2" , return-value , error-status :get-message(1) )
    {&display-message}.
    return error return-value .
  end.

  assign
   new_trn-doc.contract-code = temp-line.contract-code /* уже было присвоено при создании tt-trn-doc */
   new_trn-doc.exch-rate   = tt-trn-doc.exch-rate
   new_trn-doc.exch-scale  = tt-trn-doc.exch-scale
   new_trn-doc.exch-date   = to-day
   new_trn-doc.exch-code   = tt-trn-doc.exch-code
   new_trn-doc.status_     = {&wayb}
   new_trn-doc.hold-doc-code-child   = "no-hold"
   new_trn-doc.hold-doc-code-parent  = "no-hold"
   new_trn-doc.print-rubl  = v-print-rubl
   
   /* 19/IX-2018  Для того, чтобы 1С мог отделить документы переноса остатков от обычных документов,
                   при импорте в код основания документа принудительно проставлять значение 24. */
   new_trn-doc.reason-code = 24  
  .
  
 define variable dsXmlFileName1 as character no-undo .
 define variable dsXmlFileName2 as character no-undo .
 define variable dsXmlFileName3 as character no-undo .
// dsXmlFileName1 = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "tt-doc-line0").
// dsXmlFileName2 = substitute("&1/&2.xml", ibs.th.gbl.gbl-inipar:logDir, "tt2-doc-line0").
  for each    new_line where
              new_line.supp-type      = temp_parts.supp-type     and
              new_line.supp-code      = temp_parts.supp-code     and
              new_line.host-code      = temp_parts.host-code     and
              new_line.vat-type       = temp_parts.vat-type      and
              new_line.vat-pc         = temp_parts.vat-pc        and
              new_line.contract-code  = temp_parts.contract-code and
              new_line.num            = p-num :
    if new_line.price-rubl <= 0  or new_line.price-rubl = ? then do:
      &scop my-message substitute("Цена &2   = &1 Пропускаю " , new_line.price-rubl  , new_line.artic )
      {&display-message}.
      next.
    end.
    if new_line.fact-qnty <= 0 then do:
      &scop my-message substitute("Количество &2   = &1 Пропускаю " , new_line.fact-qnty  , new_line.artic )
      {&display-message}.
      next.
    end.

  for each buf2_temp_parts no-lock where
        buf2_temp_parts.host-code      = temp_parts.host-code and
        buf2_temp_parts.price-rubl <> ? and
        buf2_temp_parts.price-rubl <> 0 and
        buf2_temp_parts.vat-type       = temp_parts.vat-type and
        buf2_temp_parts.contract-code  = temp_parts.contract-code and
        buf2_temp_parts.supp-type      = temp_parts.supp-type and
        buf2_temp_parts.supp-code      = temp_parts.supp-code and
        buf2_temp_parts.vat-pc         = temp_parts.vat-pc    and
        buf2_temp_parts.artic          = new_line.artic       and
        buf2_temp_parts.prod-type      = new_line.prod-type   and
        buf2_temp_parts.prod-code      = new_line.prod-code   and
/*        buf2_temp_parts.part-code      = new_line.part-code   and*/
        buf2_temp_parts.price-rubl     = new_line.price-rubl and
        buf2_temp_parts.pl-code        = new_line.pl-code
  :
    /*
    if can-find (first temp-2exists where
        temp-2exists.artic     = buf2_temp_parts.artic
    and temp-2exists.prod-type = buf2_temp_parts.prod-type
    and temp-2exists.prod-code = buf2_temp_parts.prod-code
    and temp-2exists.doc-code = n-d) then next .
    */

      /* 14/IX-2018 - поля new_prod-type, new_prod-code и new_artic заменены на свои аналоги без new_
    find first tt-doc-line exclusive-lock where
              tt-doc-line.doc-code       = n-d and
              tt-doc-line.artic          = buf2_temp_parts.new_artic   and
              tt-doc-line.prod-type      = buf2_temp_parts.new_prod-type and
              tt-doc-line.prod-code      = buf2_temp_parts.new_prod-code no-error .
    if not available tt-doc-line then do:
      find first buf_goods no-lock
           where buf_goods.artic     = buf2_temp_parts.new_artic
             and buf_goods.prod-type = buf2_temp_parts.new_prod-type
             and buf_goods.prod-code = buf2_temp_parts.new_prod-code no-error .
      */       
    find first tt-doc-line exclusive-lock where
              tt-doc-line.doc-code       = n-d and
              tt-doc-line.artic          = buf2_temp_parts.artic   and
              tt-doc-line.prod-type      = buf2_temp_parts.prod-type and
              tt-doc-line.prod-code      = buf2_temp_parts.prod-code no-error .
    if not available tt-doc-line then do:
      find first buf_goods no-lock
           where buf_goods.artic     = buf2_temp_parts.artic
             and buf_goods.prod-type = buf2_temp_parts.prod-type
             and buf_goods.prod-code = buf2_temp_parts.prod-code no-error .
      
      find first tt-gds where tt-gds.gds-code = buf_goods.gds-code no-error.
      if not available (tt-gds)
      then do:
        create tt-gds.
        tt-gds.gds-code = buf_goods.gds-code.
        find first buf_goods-attr where buf_goods-attr.gds-code = tt-gds.gds-code and buf_goods-attr.attr-code = {&attr-ptrl-without-rvs} no-error.
        if not available (buf_goods-attr)
        then do:
          create buf_goods-attr.
          buf_goods-attr.gds-code = tt-gds.gds-code.
          buf_goods-attr.attr-code = {&attr-ptrl-without-rvs}. 
          buf_goods-attr.attr-value = "yes".
        end.
      end.
      
      if not available buf_goods then next .
      create  tt-doc-line.
      assign
      tt-doc-line.doc-code       = n-d
      tt-doc-line.obj-type       = new_obj-type
      tt-doc-line.obj-code       = new_obj-code
      tt-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
      
      /* 14/IX-2018 - поля new_prod-type, new_prod-code и new_artic заменены на свои аналоги без new_
      tt-doc-line.artic          = buf2_temp_parts.new_artic
      tt-doc-line.prod-type      = buf2_temp_parts.new_prod-type
      tt-doc-line.prod-code      = buf2_temp_parts.new_prod-code
      */
      tt-doc-line.artic          = buf2_temp_parts.artic
      tt-doc-line.prod-type      = buf2_temp_parts.prod-type
      tt-doc-line.prod-code      = buf2_temp_parts.prod-code

      tt-doc-line.prt-root       = buf_goods.prt-root
      tt-doc-line.unit-cli       = buf_goods.unit-base
      tt-doc-line.slt-pc         = buf2_temp_parts.slt-pc
      tt-doc-line.vat-pc         = buf2_temp_parts.vat-pc
      tt-doc-line.ext-doc-type   = v-ext-doc-type
      tt-doc-line.price-base     = buf2_temp_parts.price-rubl
      tt-doc-line.price-cli      = buf2_temp_parts.price-rubl
      tt-doc-line.price-rubl     = buf2_temp_parts.price-rubl
      tt-doc-line.status_        = "temp"
      tt-doc-line.cli-qnty       = 0
      tt-doc-line.doc-qnty       = 0
      tt-doc-line.fact-qnty      = 0
      
      tt-doc-line.pl-code        = buf2_temp_parts.pl-code
      .
      create temp-2exists.
      assign
      temp-2exists.artic = buf2_temp_parts.artic
      temp-2exists.prod-type = buf2_temp_parts.prod-type
      temp-2exists.prod-code = buf2_temp_parts.prod-code
      temp-2exists.doc-code = n-d
      .
      release temp-2exists.
    end.
    assign
      tt-doc-line.cli-qnty  = tt-doc-line.cli-qnty  + buf2_temp_parts.cli-qnty1
      tt-doc-line.doc-qnty  = tt-doc-line.doc-qnty  + buf2_temp_parts.fact-qnty1
      tt-doc-line.fact-qnty = tt-doc-line.fact-qnty + buf2_temp_parts.fact-qnty1
    .

    assign
      tt-doc-line.cli-base-rate  = tt-doc-line.doc-qnty / tt-doc-line.cli-qnty
      tt-doc-line.doc-density    = tt-doc-line.cli-qnty / tt-doc-line.doc-qnty
      tt-doc-line.fact-density   = tt-doc-line.cli-qnty / tt-doc-line.fact-qnty
    .

    find first tt2-doc-line exclusive-lock where
              tt2-doc-line.doc-code       = n-d and
              tt2-doc-line.artic          = tt-doc-line.artic   and
              tt2-doc-line.prod-code      = tt-doc-line.prod-code and
              tt2-doc-line.prod-type      = tt-doc-line.prod-type  no-error .
    if not available tt2-doc-line then do:
      create  tt2-doc-line .
    end.
    BUFFER-COPY tt-doc-line to tt2-doc-line no-error.
    if error-status:error then do:
      message "buf-copy1 err" skip
      "doc-code:" n-d
      "artic:" tt-doc-line.artic
      view-as alert-box . 
    end .

    find first tt-gds-dtl exclusive-lock where
              tt-gds-dtl.doc-code   = n-d and
              tt-gds-dtl.prt-code   = tt-doc-line.prt-root and
              tt-gds-dtl.artic      = tt-doc-line.artic   and
              tt-gds-dtl.prod-code  = tt-doc-line.prod-code and
              tt-gds-dtl.prod-type  = tt-doc-line.prod-type  no-error .
    if not available tt-gds-dtl then do:
      create  tt-gds-dtl .
    end.
    buffer-copy  tt-doc-line  to  tt-gds-dtl
    assign
    tt-gds-dtl.prt-code  =  tt-doc-line.prt-root
    no-error .
    if error-status:error then do:
      message "buf-copy2 err" skip
      "doc-code:" n-d
      "artic:" tt-doc-line.artic
      view-as alert-box . 
    end .
    
// temp-table tt-doc-line:WRITE-XML ( "FILE", dsXmlFileName1, true, "UTF-8").
// temp-table tt2-doc-line:WRITE-XML ( "FILE", dsXmlFileName2, true, "UTF-8").
  end .

  
  
  end . /*for each    new_line where*/
if local-trace-on then do:
 dsXmlFileName1 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt-doc-line", n-d).
 temp-table tt-doc-line:WRITE-XML ( "FILE", dsXmlFileName1, true, "UTF-8").
 dsXmlFileName2 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt2-doc-line", n-d).
 temp-table tt2-doc-line:WRITE-XML ( "FILE", dsXmlFileName2, true, "UTF-8").
end .
  
  /* 16/IV-2018 создание партий перенесено до линий документов;
                здесь созданные партии привязываются к линиям */
  for each tt-doc-line :
    // pi линий:  doc-code artic prod-type prod-code
    // pi партий: obj-type obj-code artic prod-type prod-code in-code out-code part-code prt-code
    for each tt-parts
       where tt-parts.obj-type  = tt-doc-line.obj-type
         and tt-parts.obj-code  = tt-doc-line.obj-code
         and tt-parts.artic     = tt-doc-line.artic
         and tt-parts.prod-type = tt-doc-line.prod-type
         and tt-parts.prod-code = tt-doc-line.prod-code
         and tt-parts.supp-type     = new_trn-doc.cli-type
         and tt-parts.supp-code     = new_trn-doc.cli-code
         and tt-parts.contract-code = new_trn-doc.contract-code
         and tt-parts.vat-type      = new_trn-doc.vat-type
         and tt-parts.vat-pc        = tt-doc-line.vat-pc
         and tt-parts.price-rubl    = tt-doc-line.price-rubl
         and tt-parts.pl-code       = tt-doc-line.pl-code
    :
/*
@NOTE  Цикл tt-parts, при наличии в tt-parts одной удовлетворяющей записи, выполняет два шага для каждой tt2-doc-line.
       Оба шага становятся на одну и ту же запись в tt-parts.
       Вероятнее всего здесь обновляется индексное поле tt-parts.out-code, что сбивает с толку for-each.
message "parts -> doc-line" skip string(rowid(tt-parts)) string(rowid(tt2-doc-line)) view-as alert-box.
*/      
      tt-parts.out-code = tt-doc-line.doc-code no-error .
    end . // end_of for_each tt-parts
  end. /*  for each tt2-doc-line :*/
if local-trace-on then do:
 dsXmlFileName3 = substitute("&1/&2-&3.xml", ibs.th.gbl.gbl-inipar:logDir, "tt_parts-2", n-d).
 temp-table tt-parts:WRITE-XML ( "FILE", dsXmlFileName3, true, "UTF-8").
end .

  /* 26/IV-2018 внутри copy-in.i партии создаются по линиям документа tt2-doc-line;
                входная таблица tt-parts для создания партий не используется */
  { str/copy-in.i
    parParentProc
    recid(new_trn-doc)
    tt-trn-doc
    tt2-doc-line
    tt-doc-line-attr
    tt-gds-dtl
    tt-parts
    yes
    yes
    no
    yes
    this-procedure
    no-error }
  if error-status:error then do :
      &scop my-message substitute("Не удалось добавить товар в приходную накладную  (copy-in.i)! &1 &2" , return-value , error-status :get-message(1) )
      {&display-message}.
      return error return-value .
  end.
  v-ii = v-ii + 1.
  run gbl/calc-trn.p ( input parparentproc, input recid(new_trn-doc)) no-error.
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  assign
  new_trn-doc.tot-cli = new_trn-doc.tot-calc
  .
  
  if p-is-close then do :
  /* 29/X-2018 сначала всё импортируем, потом всё закрываем.
    &scop my-message substitute(" Закрытие документа &1 на ФАКТ" , new_trn-doc.doc-code )
    {&display-message}.
      run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
      find first new_trn-doc where new_trn-doc.doc-code = n-d  no-lock no-error .
      if new_trn-doc.status_ <> {&fact} then do:
    &scop my-message substitute("Не удалось закрыть на факт ПН &1 &2 &3" ,n-d , return-value , error-status :get-message(1) )
    {&display-message}.
      end.
  */
      create tt-trn-close .
      assign tt-trn-close.trn-code = new_trn-doc.doc-code .
  end .
end. /*doe*/
end procedure. /* create-nakl */


procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable varchg-inv as logical no-undo .
do
on error undo, return error return-value
:
/* 29/X-2018
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
*/
  run str/trn-stat.p (
    input  parparentproc  ,
    input  this-procedure ,
    input  {&close-fact} ,
    input  p-trn-code,
    input  false /* проверка старого возврата */ ,
    input  ibs.th.gbl.gbl-var:g#db-num,
    input  false /* проверка переоценки */,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list1 )
    no-error.
    if error-status:error then do :
        &scop my-message substitute(" Ошибка при закрытии документа &2 &1" , return-value , p-trn-code )
        {&display-message}.
    end.
end. /*doe*/
end procedure. /* clos-trn2 */
