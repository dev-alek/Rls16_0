block-level on error undo, throw.

/*

$Revision: 95acbc8cdeb8, 3449, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:33 $
$Workfile: r-cashbk.p $
$Archive: rep/r-cashbk.p $

Кассовая книга

Автор: Комаров Иван Сергеевич
Дата создания: 02/02/10
Author: Ivan Komarov
Creation date: 02/02/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-cashbook               as character               no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .
define input parameter p-titul                  as logical                 no-undo .

define variable vss-revision    as character no-undo init "$Revision: 95acbc8cdeb8, 3449, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cashbk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-cashbk.p $":U .
define variable vss-description as character no-undo init "Кассовая книга".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ rep/f-fdec.i   }
{ gbl/cur-time.i }
{ gbl/prn-lib.i  }
{ ref/grplib.i   }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ rep/r-sale.i   }
{ trg/factord.i  }
define variable g#report-num as integer no-undo .
{ gbl/paramls.i  }
{ rep/ostatok.i  }
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" } /* Fact-order и остатки на дату ПО ФИН АРХИВАМ */
{ rep/ost-line.i }
{ str/farh-def.i }
{ cmp/trg-def.i  }
{ gbl/db-attr.i }
{ gbl/std-func.i }
{ rep/html-conv.i }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable v-cntxt-obj-name as character no-undo .

define temp-table temp-fin-doc no-undo
  FIELD host-code     as integer
  FIELD prn-doc-code  as character
  FIELD fin-doc-code  as integer
  FIELD fin-doc-type  as character
  FIELD payer         as character
  FIELD receiver      as character
  FIELD cor-acc       as character
  FIELD sum-rubl      as decimal
  field ostatok-begin as decimal
  field sum-income    as decimal
  field sum-expense   as decimal
  FIELD obj-code      as integer
  FIELD obj-type      as character
  FIELD sheet-num     as integer
  field cashbook_id   as integer
  field cashbook      as character
  INDEX pi is primary unique sheet-num host-code obj-code obj-type fin-doc-code cashbook_id
  .

define temp-table temp-fin-sum no-undo
  FIELD host-code   as integer
  field ostatok     as decimal
  field sum-income  as decimal
  field sum-expense as decimal
  FIELD obj-code    as integer
  FIELD obj-type    as character
  FIELD sheet-num   as integer
  field cashbook_id as integer
  INDEX pi is primary unique sheet-num host-code obj-code obj-type cashbook_id
  .

define buffer buf_clients                   for ub.clients .
define buffer buf_obj-list                  for obj-list .
define buffer buf_fin-doc                   for ub.fin-doc .
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_shift-obj                 for ub.shift-obj .
define buffer buf_day-shift-obj             for ub.shift-obj .
define buffer buf_cashbook                  for ub.CashBook .
define buffer buf_temp-fin-doc              for temp-fin-doc .

define variable v-count        as integer   no-undo .
define variable v-str          as integer   no-undo .
define variable v-firm         as character no-undo .
define variable v-object       as character no-undo .
define variable v-host-code    as integer   no-undo .
define variable v-date-start   AS DATE      FORMAT "99/99/9999" no-undo .
define variable v-date-end     AS DATE      FORMAT "99/99/9999" no-undo .
define variable v-date-start1  AS DATE      FORMAT "99/99/9999" no-undo .
define variable v-date-end1    AS DATE      FORMAT "99/99/9999" no-undo .
define variable v-date-page    as date      no-undo .

define variable v-shift-start  AS integer   no-undo .
define variable v-shift-end    AS integer   no-undo .
define variable f-prn-doc-code as character no-undo.
define variable f-payer        as character no-undo .
define variable f-corr-acc     as character no-undo .
define variable v-kolvo-pko    as integer   no-undo .
define variable v-kolvo-rko    as integer   no-undo .
define variable v-pko-propis   as character no-undo .
define variable v-rko-propis   as character no-undo .
define variable v-saldo        as decimal   no-undo .
define variable v-sum-i        as decimal   no-undo .
define variable v-sum-e        as decimal   no-undo .
define variable v-ost-begin    as decimal   no-undo .
define variable v-sum-begin    as decimal   no-undo .
define variable sum            as decimal   no-undo .
define variable sum1           as decimal   no-undo .
define variable v-tab110       as character no-undo .
define variable v-num-page     as integer   no-undo .
define variable x-store-code   like ub.clients.obj-code no-undo.
define variable x-store-type   like ub.clients.obj-type no-undo.
define variable v-payer        as character no-undo .
define variable Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable Fact-order-0   like ub.stk-tot.Fact-order no-undo.
define variable date_          as date      no-undo .
define variable par-type       as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define variable v-alter-code as character no-undo .
define variable v-file-name-rep-html  as character no-undo .
define variable v-file-name-rep-html1 as character no-undo .
define variable v-ind                 as integer   no-undo .
define variable num#col#              as integer   no-undo .
define variable str10                 as character no-undo .
define variable Counter1              as integer   no-undo .
define variable v-num-obj             as integer   no-undo .
define variable v-page                as integer   no-undo .
define variable v-strok               as integer   no-undo .
define variable v-strok1              as integer   no-undo .
define variable v-strok2              as integer   no-undo .
define variable v-date-name           as character no-undo .
define variable v-date-name-full      as character no-undo .
define variable v-obj-name            as character no-undo .
define variable v-shift-on            as logical   no-undo .
define variable v-cashier             as character no-undo .
define variable v-sheet-num           as integer   init 1 no-undo .

define variable v-user-action         as character no-undo .
define variable v-printed             as logical   no-undo .
define variable disabledoptions       as integer   no-undo .
define variable v-orient-page         as character no-undo .
define variable v-obj-type            as character no-undo .
define variable v-obj-code            as integer   no-undo init -1.
define variable v-hist-name           as character no-undo .
define variable v-hist-code           as character no-undo .

define variable ii                    as integer   no-undo .

define stream  macr_excel .
define stream  out-stream .

define variable v-file-name            as character no-undo .
define variable v-file-name-ind        as integer   no-undo .
define variable v-line                 as character no-undo .

define variable v-shift-name           as character format "X(2)" no-undo.        /* TH #3077 */
define variable v-shift-name-min       as character format "X(2)" no-undo.    /* TH #3077 */
define variable v-shift-name-max       as character format "X(2)" no-undo.    /* TH #3077 */
define variable v-shift-num-min        as integer   no-undo.                     /* TH #3077 */
define variable v-shift-num-max        as integer   no-undo.                     /* TH #3077 */
define variable v-multy-shift          as logical   no-undo.                       /* TH #3077 */
define variable v-shift-multydate      as logical   no-undo.                   /* TH #3077 */
define variable v-date-start-multydate as date      no-undo.                 /* TH #3077 */
define variable shift-alone            as logical   no-undo.                         /* TH #3077 */

define variable o-head-position        as character no-undo .
define variable o-director             as character no-undo .
define variable o-snr-accnt            as character no-undo .
define variable v-head-position        as character no-undo .
define variable v-director             as character no-undo .
define variable v-snr-accnt            as character no-undo .
define buffer buf_shop  for ub.shop .
define buffer buf_store for ub.store .
define buffer buf_firm  for ub.firm .
define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .

define buffer buf_sysconf for ub.sysconf .

find first buf_clients
  where buf_clients.obj-type = {&cmp}
  and   buf_clients.obj-code = v-cntxt-host-code-obj
  no-lock
  .

find first buf_sysconf no-lock where buf_sysconf.host-code = buf_clients.obj-code no-error .
find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
                
assign 
  v-firm = buf_clients.obj-name  .

find first ub.firm no-lock where ub.firm.firm-code = buf_clients.obj-code no-error .
for each obj-list by obj-list.obj-name:
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-name},OUTPUT v-hist-name ,OUTPUT par-type) .
  if v-obj-code = -1 then 
  do:
    assign
      v-obj-type = obj-list.obj-type
      v-obj-code = obj-list.obj-code.
  end.
  else 
  do:
    assign
      v-obj-type = ''
      v-obj-code = 0
      .
  end.
  assign
    v-shift-on = yes
    .
  if x-tog-shift then 
  do :
    { gbl/objat.i
        obj-list.obj-type
        obj-list.obj-code
        "'shift-on=request'"
        v-shift-on
        no-error
        }
    if error-status :error
      then 
    do:
         &scop my-message substitute("&1 &2 &3&4" +  ~
                                       "Невозможно определить тип сменный/не сменный&4" + ~
                                       "для заданного объекта.&4" + ~
                                       "Объект: &5&6&4&7&4&8"  ~
                                       ,vss-workfile  ~
                                       ,vss-revision  ~
                                       ,vss-description ~
                                       ,~{&new-line~} ~
                                       ,obj-list.obj-type  ~
                                       ,obj-list.obj-code ~
                                       , return-value   ~
                                       ,error-status:get-message(1) )
      {&display-message}.
      undo, return error .
    end.
    if v-shift-on = no
      then 
    do:
          &scop my-message substitute("Неверно задан тип объекта &1&2&3"  + ~
                                      "Объект не сменный." ~
                                      ,obj-list.obj-type ~
                                      ,obj-list.obj-code ~
                                      , ~{&new-line~} )
      {&display-message}.
      undo, return error .
    end.
  end.

  if v-shift-on or x-tog-shift = no then 
  do :
    if v-obj-name <> "" then 
    do :
      assign
        v-obj-name = v-obj-name + ", " + obj-list.obj-name
        .
    end.
    else 
    do :
      assign
        v-obj-name = obj-list.obj-name
        .
    end.
  end.
end. /* for each obj-list by obj-list.obj-name: */
    
find first obj-list
  where obj-list.obj-type = v-cntxt-obj-type
  and obj-list.obj-code = v-cntxt-obj-code
  no-error.

if available obj-list then 
do:
  assign 
    v-cntxt-obj-name = obj-list.obj-name.
end.

assign
  v-date-start1 = x-date-start
  v-date-end1   = x-date-end
  .

if p-cashbook = "" then 
do:
  for each buf_cashbook where buf_cashbook.Status_ = 0 no-lock:
    if p-cashbook <> "" then
      p-cashbook = p-cashbook + {&delim-cmd} + string(buf_cashbook.id) .
    else  p-cashbook = string(buf_cashbook.id) .
  end.  
end.   
/*Касссовые книги*/

do ii = 1 to num-entries (p-cashbook,{&delim-cmd}):

  /*Печать титульного листа по кассовой книге*/

  mCashBook = new ibs.th.ref.cashbookstorage () .
  define variable v-ok as logical no-undo .
        if v-cntxt-db-num = 0 then 
      do:
         /*чтобы не мешало на исходниках*/
         run utl/checkStructDb.p (15, output v-ok) no-error.
         if v-ok 
         then do:
            find first buf_CashBook no-lock where buf_CashBook.id = 0 no-error .
            if available (buf_CashBook) then 
            do:
               run utl/fin-doc-nom.p(parparentproc,int64(entry(ii,p-cashbook,{&delim-cmd})),x-Date-Start). 
            end.   
         end.
      end.
      else
  run utl/fin-doc-nom.p(parparentproc,int64(entry(ii,p-cashbook,{&delim-cmd})),x-Date-Start).
  o-head-position = mCashBook:getSinglRule(integer(entry(ii,p-cashbook,{&delim-cmd})), v-obj-type, v-obj-code, "ManagerPosition") .
  o-director      = mCashBook:getSinglRule(integer(entry(ii,p-cashbook,{&delim-cmd})), v-obj-type, v-obj-code, "ManagerFIO") .
  o-snr-accnt     = mCashBook:getSinglRule(integer(entry(ii,p-cashbook,{&delim-cmd})), v-obj-type, v-obj-code, "BuhFIO") .
      
  delete object mCashBook no-error .

  case o-head-position:
    when '0':U then 
      do:
        v-head-position = buf_sysconf.head-position.
      end.
    when '1':U then 
      do:
        v-head-position = "Директор".
      end.
    when '2' then 
      do:
        v-head-position = "Управляющий".
      end.  
    otherwise 
    do :
      v-head-position = o-head-position .
    end. 
        
  end case.
  case o-director:
    when '1':U then 
      do:
        if v-obj-type = {&shop} then 
        do:
          find first buf_shop no-lock where
            buf_shop.obj-code = v-obj-code no-error .
          if available buf_shop then 
          do:
            v-director = buf_shop.director.
          end.
        end.
        if v-obj-type = {&stock} then 
        do:
          find first buf_store no-lock where
            buf_store.obj-code = v-obj-code no-error .
          if available buf_store then 
          do:
            v-director = buf_store.store-boss.
          end.
        end.
      end. /*when 'dir_obj' then do:*/
    when '0':U then 
      do:
        v-director = buf_firm.director.
      end.
    otherwise 
    do:
      v-director = o-director .
    end.  
  end case.
  case o-snr-accnt:
    when '1':U then 
      do:
        if v-obj-type = {&shop} then 
        do:
          find first buf_shop no-lock where
            buf_shop.obj-code = v-obj-code no-error .
          if available buf_shop then 
          do:
            v-snr-accnt = entry(1,buf_shop.acct,"|").
          end.
        end.
        if v-obj-type = {&stock} then 
        do:
          v-snr-accnt = ''.
        end.
      end.
    when '2':U then 
      do:
        v-snr-accnt = buf_sysconf.snr-accnt.
      end.
    otherwise 
    do:
      v-snr-accnt = o-snr-accnt .
    end.  
  end case.
   


  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-html = session:temp-directory + string(p-report-id) + "_" + string (entry(ii,p-cashbook,{&delim-cmd})) + ".html".     

  output stream OutStr-html to value(v-file-name-rep-html) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
                        
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    '<body>' skip
    .
  if X-SelectObject = {&obj-firm} then 
  do :
    assign  
      str1 = "Организация: " + v-firm.
  end.
  else 
  do :
    assign  
      str1 = v-obj-name.
  end.

  if x-tog-shift then 
  do :

    if v-shift-multydate = yes and v-date-start-multydate <> ? then
    do:
      v-multy-shift = no.
    end.

    if v-multy-shift = yes then
    do:
      v-date-name = v-date-name + ". Смена c " + v-shift-name-min + " (" + string(v-shift-num-min) + ")" + " по " + v-shift-name-max + " (" + string(v-shift-num-max) + ")".
      .
    end.
    if v-multy-shift = no then
    do:
      v-date-name = v-date-name + ". Смена " + v-shift-name-min + " (" + string(v-shift-num-min) + ")".
      .
      if v-shift-multydate = yes and v-date-start-multydate <> ? then
      do:
        v-date-name = v-date-name + " от " + string(v-date-start-multydate) + ".".
        .
      end.
    end.
  end. /* if x-tog-shift then do : */

  if v-date-start1 = v-date-end1 then 
  do:
    v-date-name-full =  "за " + string(day(v-date-end1)) + " " + MonthNameRusGen(MONTH(v-date-end1)) + " " + string(year(v-date-end1)) + "г." .
  end.
  else 
  do:  
    if MonthNameRusGen(MONTH(v-date-start1)) = MonthNameRusGen(MONTH(v-date-end1)) and string(day(v-date-start1)) <> string(day(v-date-end1)) then 
    do:
      v-date-name-full =  "за " + string(day(v-date-start1)) + " - " + string(day(v-date-end1)) + " " + MonthNameRusGen(MONTH(v-date-end1)) + " " + string(year(v-date-end1)) + "г." .
    end.
    else 
    do:
      v-date-name-full =  "c " + string(day(v-date-start1)) + " " + MonthNameRusGen(MONTH(v-date-start1)) + " " + string(year(v-date-start1)) + " по " + string(day(v-date-end1)) + " " + MonthNameRusGen(MONTH(v-date-end1)) + " " + string(year(v-date-end1)) + "г." .
    end.
  
  end.
  find first buf_cashbook no-lock where buf_cashbook.id = integer((entry(ii,p-cashbook,{&delim-cmd}))) no-error .
  v-num-page = 0 .

  define variable v-shift-num as integer no-undo .
  find first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = buf_cashbook.id and ub.CashBookRule.Code = "uchet"
  and ub.CashBookRule.Obj-code = v-obj-code and ub.CashBookRule.Obj-type = v-obj-type no-error .
  if available (ub.CashBookRule) and ub.CashBookRule.RuleValue = "1" then do:
        /*Смены*/
  do v-date-page = date("01/01/" + string(year(v-date-start1))) to v-date-start1:

   for each ub.shift-obj no-lock where ub.shift-obj.obj-code = v-obj-code and ub.shift-obj.obj-type = v-obj-type and ub.shift-obj.shift-date = v-date-page:
    if ub.shift-obj.shift-date = x-date-End and ub.shift-obj.shift-num > x-Shift-End then leave .
    if can-find (first ub.fin-doc no-lock where ub.fin-doc.obj-code = v-obj-code and ub.fin-doc.obj-type = v-obj-type and ub.fin-doc.cashbookid = buf_cashbook.id
      and ub.fin-doc.shift-date = ub.shift-obj.shift-date and ub.fin-doc.shift-name = ub.shift-obj.shift-name and ub.fin-doc.shift-num = ub.shift-obj.shift-num) then
    do:  
      v-num-page = v-num-page + 1 .
    end.
  end.
  end.
     v-num-page = v-num-page - 1.
  end. 
  
  else do:
       /*Календарные даты*/
  do v-date-page = date("01/01/" + string(year(v-date-start1))) to v-date-start1 - 1:
    if can-find (first ub.fin-doc no-lock where ub.fin-doc.obj-code = v-obj-code and ub.fin-doc.obj-type = v-obj-type and ub.fin-doc.cashbookid = buf_cashbook.id
      and ub.fin-doc.fact-date = v-date-page) then
    do:
      v-num-page = v-num-page + 1 .
    end.
  end.     
  end.   
  if p-titul then 
  do:
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="Титульный лист КК ' + string(entry(ii,p-cashbook,{&delim-cmd})) + '">'skip
      .
    put stream OutStr-html unformatted
      '<thead>' skip
      '<tr class="set_columns">' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '<td style="width: 120px;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="3"></td>' skip
      '<td colspan="2" style="text-align:right;">Унифицированная форма № КО-4</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="3"></td>' skip
      '<td colspan="2" style="text-align:right;">Утверждена постановлением Госкомстата</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="3"></td>' skip
      '<td colspan="2" style="text-align:right;">России от 18.08.98 г. № 88</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="5" style="height:30px;"></td>' skip
      '</tr>' skip            
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="4"></td>' skip
      '<td style="text-align:center;  border:1px solid black;">Коды</td>' skip
      '</tr>' skip
      '<tr style="height:30px;">' skip
      '<td colspan="2"></td>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="2" style="text-align: right;">Форма по ОКУД </td>' skip
      '<td style="text-align:center;  border:1px solid black; font-weight: bold;">0310004</td>' skip
      '</tr>' skip
      '<tr style="height:30px;">' skip
      '<td></td>' skip
      '<td colspan="4" style="text-align: center; border-bottom:1px solid black;">' + v-firm + '</td>' skip
      '<td style="text-align: right;">по ОКПО </td>' skip
      '<td style="text-align:center;  border:1px solid black; font-weight: bold;">' + string(ub.firm.okpo) + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="4" style="text-align: center; font-size: 8px;">организация</td>' skip
      '<td style="text-align: right;"></td>' skip
      '<td rowspan="2" style="text-align:center;  border:1px solid black; font-weight: bold;">' + string (v-hist-code) + '</td>' skip
      '</tr>' skip  
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="4" style="text-align: center; border-bottom:1px solid black;">' + if v-hist-name <> "" then v-hist-name + '</td>' else v-obj-name + '</td>' skip
      '<td style="text-align: right;"></td>' skip
      '</tr>' skip     
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="4" style="text-align: center; font-size: 8px;">структурное подразделение</td>' skip
      '<td style="text-align: right;"></td>' skip
      '<td colspan="2"></td>' skip
      '</tr>' skip     
      '<tr>' skip
      '<td colspan="7" style="height:50px;"></td>' skip
      '</tr>' skip       
      '<tr>' skip
      '<td colspan="7" style="text-align:center;  font-weight: bold;">Кассовая книга по ' + buf_cashbook.CashBookName + '</td>' skip
      '</tr>' skip       
      '<tr>' skip
      '<td colspan="7" style="text-align:center;  font-weight: bold;">' + string (v-date-name-full) + '</td>' skip
      '</tr>' skip       
      '</thead>' skip
      '<tbody>' skip
      .

    put stream OutStr-html unformatted
      '</tbody>' skip  
      '</table>' skip
      .
  end.
  assign
    date_      = v-date-start1
    v-date-end = v-date-end1
    .
    
  do v-date-start = date_ to (v-date-end) :
    for each    temp-fin-doc :
      delete temp-fin-doc.
    end.

    assign
      v-shift-num-min        = 0
      v-shift-num-max        = 0
      v-shift-name-min       = ""
      v-shift-name-max       = ""
      v-shift-multydate      = no
      v-date-start-multydate = ?
      .
    if x-shift-start = x-shift-end and x-date-start = x-date-end then
    do:
      shift-alone = yes.
    end.
    else
    do:
      shift-alone = no.
    end.


    if v-date-start = x-date-start then
    do:
      /*===================1*/
      find first buf_day-shift-obj /* ====================== Фильтр смен верхний */
        where buf_day-shift-obj.shift-date = v-date-start /* Исследуем дату из цикла выше - do while v-date-start <> (v-date-end + 1) */
        and buf_day-shift-obj.obj-type = v-cntxt-obj-type
        and buf_day-shift-obj.obj-code = v-cntxt-obj-code                                                
        and buf_day-shift-obj.shift-num >= x-shift-start
        no-lock no-error.                   
      if available buf_day-shift-obj then
      do:
        v-shift-num-min = buf_day-shift-obj.shift-num.
        v-shift-name-min = buf_day-shift-obj.shift-name.
      end.

    end. /* if v-date-start = x-date-start then do: */
    else
    do: /* s */
      /*================2*/       
      find first buf_day-shift-obj /*==================== Фильтр смен серединный мин*/
        where buf_day-shift-obj.shift-date = v-date-start /* Исследуем дату из цикла выше - do while v-date-start <> (v-date-end + 1) */                                           
        and buf_day-shift-obj.obj-type = v-cntxt-obj-type
        and buf_day-shift-obj.obj-code = v-cntxt-obj-code
        no-lock no-error.

      if available buf_day-shift-obj then
      do:
        v-shift-num-min = buf_day-shift-obj.shift-num.
        v-shift-name-min = buf_day-shift-obj.shift-name.
      end.
      else
      do: /* v */
        find last buf_day-shift-obj
          where buf_day-shift-obj.shift-date <= v-date-start /* Исследуем дату из цикла выше - do while v-date-start <> (v-date-end + 1) */                                           
          and buf_day-shift-obj.obj-type = v-cntxt-obj-type
          and buf_day-shift-obj.obj-code = v-cntxt-obj-code
          and buf_day-shift-obj.close-date >= v-date-start
          no-lock no-error. 
        do: /* t */
          if available buf_day-shift-obj then
          do:
            v-shift-num-min = buf_day-shift-obj.shift-num.
            v-shift-name-min = buf_day-shift-obj.shift-name.
                                                        
            v-date-start-multydate = buf_day-shift-obj.shift-date.
            v-shift-multydate = yes.
          end. 
        end. /* t */
      end. /* v */
    end. /* s */                                         
    /*==============3*/ 
    find last buf_day-shift-obj /*=================================== Фильтр смен серединный макс */
      where buf_day-shift-obj.obj-type = v-cntxt-obj-type
      and buf_day-shift-obj.obj-code = v-cntxt-obj-code
      and buf_day-shift-obj.shift-date = v-date-start
      and (if v-date-start = x-date-end 
      then  buf_day-shift-obj.shift-num <= x-shift-end else true)
      no-lock no-error.
    do:
      if available buf_day-shift-obj then
      do: /* n */
        if v-shift-num-min < v-shift-num-max then
        do:
          v-multy-shift = yes.
        end.
        else
        do:
          if v-shift-num-min = 0 and buf_day-shift-obj.shift-num > 0 then /* Состояние, куда попадаем, если задаём несуществующий номер смены, который больше других существующих в данной дате (есть 1 и 2 смены, а мы задали 5 смену). */
          do:
            v-shift-num-min = 0.
            v-shift-num-max = 0.
            v-shift-name-min = "".
            v-shift-name-max = "".
          end.
          else
          do:
            v-shift-num-max = buf_day-shift-obj.shift-num.
            v-shift-name-max = buf_day-shift-obj.shift-name.
          end.
        end.
      end. /* n */
    end.
    if shift-alone = yes then
    do:
      if v-shift-num-min > 0 and v-shift-num-max = 0 then
      do:
        v-shift-num-min = 0.
        v-shift-num-max = 0.
        v-shift-name-min = "".
        v-shift-name-max = "".
        v-multy-shift = no.
      end.
    end.
    else
    do:
      if v-shift-num-min = v-shift-num-max then
      do:
        v-multy-shift = no.
      end.
      else
      do:
        v-multy-shift = yes.
      end.
    end.

    assign
      v-strok     = 0
      v-strok1    = 0
      v-strok2    = 0
      v-ost-begin = 0
      .
    if v-date-start = x-date-end   then v-shift-end   = x-shift-end.
    if v-date-start = x-date-start then v-shift-start = x-shift-start.
    assign
      v-date-name = string(day(v-date-start)) + " " + MonthNameRusGen(MONTH ( v-date-start )) + " " + string(year(v-date-start))
      .
    run report-exec in this-procedure (input v-date-start, input integer(entry(ii,p-cashbook,{&delim-cmd})) ).
  
    find first temp-fin-doc no-lock where temp-fin-doc.cashbook_id = integer(entry(ii,p-cashbook,{&delim-cmd})) no-error .
    if available (temp-fin-doc) then 
    do: 

      v-num-page = v-num-page + 1 .
      /*    v-num-page = string(v-date-start - date("01/01/" + string(year(v-date-start))) + 1).    /* За нумерацию листов отчёта - берётся кол-во дней от начала Uода до тек.даты. */*/
      /*Печать*/
      put stream OutStr-html unformatted
        '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="KK_' + string(entry(ii,p-cashbook,{&delim-cmd})) + "_за_" + string (v-date-start,"99.99.99") + '">'skip
        .
      put stream OutStr-html unformatted
        '<thead>' skip
        '<tr class="set_columns">' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 260px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '<td style="width: 120px;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="5">' + " Касса за " + v-date-name + v-tab110 + '</td>' skip
        '<td style="text-align: right;">' + "Лист " + string(v-num-page) + '</td>' skip
        '</tr>' skip
        '</thead>' skip
        '<tbody>' skip
        .
        
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th colspan="2" style="width: 120px; align: center;">Номер документа</th>' skip
        '<th style="width: 260px; align: center;">От кого получено или кому выдано</th>' skip
        '<th text_wrap="true" style="width: 120px; align: center;">Номер коррес-пондирующего счета, субсчета</th>' skip
        '<th style="width: 120px; align: center;">Приход, руб.коп.</th>' skip
        '<th style="width: 120px; align: center;">Расход, руб.коп.</th>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="2" style="text-align: center;">1</td>' skip
        '<td style="text-align: center;">2</td>' skip
        '<td style="text-align: center;">3</td>' skip
        '<td style="text-align: center;">4</td>' skip
        '<td style="text-align: center;">5</td>' skip
        '</tr>' skip
        .

      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="3" style="text-align: right;">Остаток на начало дня</td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">' + if available (temp-fin-doc) then string(temp-fin-doc.ostatok-begin, "->>>>>>>>9.99") + '</td>' else "" + '</td>' skip
        '<td style="text-align: center;">Х</td>' skip
        '</tr>' skip
        .
      if x-TOG-Shift then 
      do:
        FIND last ub.shift-staff No-LOCK WHERE
          ub.shift-staff.obj-type   = temp-fin-doc.obj-type AND
          ub.shift-staff.obj-code   = temp-fin-doc.obj-code AND
          ub.shift-staff.shift-date = v-date-end AND
          ub.shift-staff.shift-num  = v-shift-end AND
          ub.shift-staff.staff-role = no and
          ub.shift-staff.next-shift = no AND
          ub.shift-staff.psn-num    >= 0 No-ERROR.
      end.
      else 
      do:
        FIND last ub.shift-staff No-LOCK WHERE
          ub.shift-staff.obj-type   = temp-fin-doc.obj-type AND
          ub.shift-staff.obj-code   = temp-fin-doc.obj-code AND
          ub.shift-staff.shift-date = v-date-end AND
          ub.shift-staff.staff-role = no and
          ub.shift-staff.next-shift = no AND
          ub.shift-staff.psn-num    >= 0 No-ERROR.
      end.  
      assign 
        v-cashier = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".

      for each buf_temp-fin-doc where buf_temp-fin-doc.cashbook_id = temp-fin-doc.cashbook_id by buf_temp-fin-doc.fin-doc-type:
        if buf_temp-fin-doc.fin-doc-type = {&income-cash} then v-payer = buf_temp-fin-doc.payer.  
        else v-payer = buf_temp-fin-doc.receiver .
        if v-payer = ? then v-payer = "" . 
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="2" style="text-align: center;">' + buf_temp-fin-doc.prn-doc-code + '</td>' skip
          '<td text_wrap="true" style="text-align: center;">' + if v-payer <> ? then v-payer + '</td>' else " " + '</td>' skip
          '<td text_wrap="true" style="text-align: center;">' + buf_temp-fin-doc.cor-acc + '</td>' skip
          '<td text_wrap="true" style="text-align: center;">' + if buf_temp-fin-doc.fin-doc-type = {&income-cash} then string(buf_temp-fin-doc.sum-rubl, "->>>>>>>>9.99")  + '</td>' else "         -" + '</td>' skip
          '<td text_wrap="true" style="text-align: center;">' + if buf_temp-fin-doc.fin-doc-type = {&expense-cash} then string(buf_temp-fin-doc.sum-rubl, "->>>>>>>>9.99")  + '</td>' else "         -" + '</td>' skip
          '</tr>' skip
/*          '<tr>' skip   */ 
          .
      end.

      find first temp-fin-sum no-lock where temp-fin-sum.cashbook_id = temp-fin-doc.cashbook_id no-error .
      put stream OutStr-html unformatted   
        '<tr>' skip          
        '<td colspan="3" style="text-align: right;">Итого за день</td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">' + if available (temp-fin-sum) then string(temp-fin-sum.sum-income, "->>>>>>>>9.99") + '</td>' else "" + '</td>' skip
        '<td style="text-align: center;">' + if available (temp-fin-sum) then string(temp-fin-sum.sum-expense, "->>>>>>>>9.99") + '</td>' else "" + '</td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td text_wrap="true" colspan="3" style="text-align: right;">Остаток на конец дня</td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">' + if available (temp-fin-sum) then string((temp-fin-sum.ostatok), "->>>>>>>9.99") + '</td>' else "" + '</td>' skip
        '<td style="text-align: center;">Х</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td text_wrap="true" colspan="3" style="text-align: right;">в том числе:</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">Х</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td text_wrap="true" colspan="3" style="text-align: right;">национальная валюта (Российский рубль):</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">Х</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td text_wrap="true" colspan="3" style="text-align: right;">в том числе на заработную плату, выплаты социального характера и стипендии</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td style="text-align: center;">Х</td>' skip
        '</tr>' skip      
        .        
    
      assign
        v-kolvo-pko  = 0 
        v-kolvo-rko  = 0 
        v-pko-propis = ""
        v-rko-propis = ""
        .
      for each buf_temp-fin-doc where buf_temp-fin-doc.cashbook_id = temp-fin-doc.cashbook_id:
        if buf_temp-fin-doc.fin-doc-type = {&income-cash} then v-kolvo-pko = v-kolvo-pko + 1 .
        else v-kolvo-rko = v-kolvo-rko + 1 .
      end.      
      run rep/wp-qnty.p ( input v-kolvo-pko, output v-pko-propis ).
            
      if v-pko-propis = '' then 
      do :
        v-pko-propis = 'Ноль'.
      end.
            
      run rep/wp-qnty.p ( input v-kolvo-rko, output v-rko-propis ).
            
      if v-rko-propis = '' then 
      do :
        v-rko-propis = 'Ноль'.
      end.
    
       
      put stream OutStr-html unformatted

        '<tfoot>' skip
        '<tr>' skip         
        '<td colspan="3" style="text-align: right;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td colspan="2" style="height: 30px;">Кассир</td>' skip
        '<td style="text-align: center;">_________________</td>' skip
        '<td></td>' skip
        '<td colspan="2" style="text-align: center; border-bottom:1px solid black;">' + v-cashier + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="2"></td>' skip
        '<td style="text-align: center;">подпись</td>' skip
        '<td></td>' skip
        '<td colspan="2" style="text-align: center;">расшифровка подписи</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="4">Записи в кассовой книге проверил и документы в количестве</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="4">' + v-pko-propis + " приходных и " + v-rko-propis + " расходных получил." + '</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '</tr>' skip 
        '<tr>' skip
        '<td colspan="2">Бухгалтер</td>' skip
        '<td style="text-align: center;">_________________</td>' skip
        '<td></td>' skip
        '<td colspan="2" style="text-align: center; border-bottom:1px solid black;">' + v-snr-accnt + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="2"></td>' skip
        '<td style="text-align: center;">подпись</td>' skip
        '<td></td>' skip
        '<td colspan="2" style="text-align: center;">расшифровка подписи</td>' skip
        '</tr>' skip

        '</tfoot>' skip
        .        
      put stream OutStr-html unformatted
        '</tbody>' skip  
        '</table>' skip
        .
      assign
/*        v-date-start = v-date-start + 1*/
/*        v-sheet-num  = v-sheet-num + 1 */
        v-kolvo-pko  = 0
        v-kolvo-rko  = 0
        .

    end.        
  end. /* do while v-date-start <> (v-date-end + 1) : */
 
  if p-titul then 
  do:
    /* Конец основного цикла */     
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="ПЛ_КК ' + string(entry(ii,p-cashbook,{&delim-cmd})) + '">'skip
      .
    put stream OutStr-html unformatted
      '<thead>' skip
      '<tr>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 60px;"></td>' skip
      '<td style="width: 20px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 60px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 20px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 60px;"></td>' skip
      '<td style="width: 20px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 60px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '<td style="width: 20px;"></td>' skip
      '<td style="width: 160px;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2" style="height: 30px;"></td>' skip
      '<td colspan="6">В этой книге пронумеровано и</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2"></td>' skip
      '<td colspan="6">прошнуровано ' + string (v-num-page) + ' листов.</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="3" style="text-align: center;">М.П.(штампа)</td>' skip
      '<td colspan="5"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2" style="font-weight: bold; text-align: right;">Руководитель организации  </td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center; border-bottom:1px solid black;">' + v-head-position + '</td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center; border-bottom:1px solid black;"></td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center; border-bottom:1px solid black;">' + v-director + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="3"></td>' skip
      '<td style="text-align: center;">должность</td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;">подпись</td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;">расшифровка подписи</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="2" style="text-align: right; font-weight: bold;">Главный бухгалтер  </td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center; border-bottom:1px solid black;"></td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center; border-bottom:1px solid black;">' + v-snr-accnt + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="4"></td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;">подпись</td>' skip
      '<td style="text-align: center;"></td>' skip
      '<td style="text-align: center;">расшифровка подписи</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td style="text-align: right;"></td>' skip
      '<td style="text-align: left;">' + "<<" + '</td>' skip
      '<td style="text-align: left;">' + ">>" + '</td>' skip
      '<td style="border-bottom:1px solid black;"></td>' skip
      '<td style="text-align: right;">г.</td>' skip
      '<td colspan="3"></td>' skip
      '</tr>' skip
      '</tfoot>' skip
      .  


    put stream OutStr-html unformatted
      '</thead>' skip
      '</table>' skip
      .
  end.                
  put stream OutStr-html unformatted
        
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close. 

  if v-file-name-rep-html1 = "" then v-file-name-rep-html1 = v-file-name-rep-html .
  else v-file-name-rep-html1 =  v-file-name-rep-html1 + " " + v-file-name-rep-html .
end.
/*Как сделать, чтобы листы открывались во вкладках reportview*/                                                                     
run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-html1
  ).                 
   


/*--------------------------------------*/
procedure report-exec :
  define input  parameter p-date        as date    no-undo .
  define input parameter p-cash-book as integer no-undo .

  assign
    v-ost-begin = 0
    v-num-obj   = 0
    .
  empty temp-table temp-fin-sum .
  empty temp-table temp-fin-doc .

  for each buf_obj-list no-lock :
    { gbl/hostcode.i buf_obj-list.obj-type buf_obj-list.obj-code v-host-code }
    assign
      fact-order-1 = 0
      fact-order-2 = 0
      v-sum-begin  = 0
      v-shift-on   = yes
      .

    find first buf_cashbook no-lock where buf_cashbook.id = p-cash-book no-error .
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_obj-list.obj-code
      ,input   buf_obj-list.obj-type
      ,input   x-tog-shift
      ,input   p-date - 1
      ,input   date('')
      ,input   ( if p-date <> x-date-start then 0 else x-shift-start )
      ,input   X-shift-end
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   buf_cashbook.id
      ,output  v-sum-begin
      ,output  Fact-order-1)
      no-error .
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_obj-list.obj-code
      ,input   buf_obj-list.obj-type
      ,input   x-tog-shift
      ,input   p-date
      ,input   x-date-end
      ,input   X-shift-end
      ,input   X-shift-end
      ,input   yes /*xTog-obj*/
      ,input   0 /*p-curr-code*/
      ,input   buf_cashbook.id
      ,output  sum1
      ,output  Fact-order-2)
      no-error .
        
    for each buf_arh-fin-doc-schet-nal-obj no-lock
      where buf_arh-fin-doc-schet-nal-obj.host-code         = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.obj-type          = buf_obj-list.obj-type
      and buf_arh-fin-doc-schet-nal-obj.obj-code          = buf_obj-list.obj-code
      and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
      and buf_arh-fin-doc-schet-nal-obj.cli-code          = v-host-code
      and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
      and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
      and buf_arh-fin-doc-schet-nal-obj.cashbookid        = integer(entry(ii,p-cashbook,{&delim-cmd})) 
      and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
      and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
      and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
      and buf_arh-fin-doc-schet-nal-obj.fact-order       >= fact-order-1
      and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
      and p-date = ( if x-tog-shift then buf_arh-fin-doc-schet-nal-obj.shift-date else buf_arh-fin-doc-schet-nal-obj.fact-date )   /*в 15-0 поля shift-date нет */
      use-index pi :
      if x-TOG-Shift then 
      do:
        if buf_arh-fin-doc-schet-nal-obj.shift-date = x-Date-Start and buf_arh-fin-doc-schet-nal-obj.shift-num < x-Shift-Start then next .
        if buf_arh-fin-doc-schet-nal-obj.shift-date = x-date-End   and buf_arh-fin-doc-schet-nal-obj.shift-num > x-Shift-End then next .
      end.  

      find first buf_fin-doc
        where buf_fin-doc.host-code         = v-host-code
        and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
        and buf_fin-doc.CashBookId        = buf_arh-fin-doc-schet-nal-obj.cashbookid
        and buf_fin-doc.obj-type          = buf_obj-list.obj-type
        and buf_fin-doc.obj-code          = buf_obj-list.obj-code
        and buf_fin-doc.status_           = {&fact}
        and (buf_fin-doc.fin-ext-doc-type = {&income-cash}
        or buf_fin-doc.fin-ext-doc-type   = {&expense-cash} )
        no-error.
      if available buf_fin-doc then 
      do :
                    &scop fin-doc-obj-type buf_fin-doc.obj-type
                    &scop fin-doc-obj-code buf_fin-doc.obj-code
        if buf_fin-doc.trn-doc-code = {&fin-doc-cash-book-name} then 
        do:
          find first temp-fin-doc
            where temp-fin-doc.host-code    = v-host-code
            and temp-fin-doc.obj-code     = buf_obj-list.obj-code
            and temp-fin-doc.obj-type     = buf_obj-list.obj-type
            and temp-fin-doc.cashbook_id  = buf_cashbook.id
            and temp-fin-doc.fin-doc-code = buf_fin-doc.fin-doc-code
            use-index pi no-error .
          if not available temp-fin-doc
            then 
          do :
            create temp-fin-doc.
            assign
              temp-fin-doc.obj-code      = buf_obj-list.obj-code
              temp-fin-doc.obj-type      = buf_obj-list.obj-type
              temp-fin-doc.host-code     = v-host-code
              temp-fin-doc.cashbook      = if available (buf_cashbook) then buf_cashbook.CashBookName else "Основная деятельность"
              temp-fin-doc.cashbook_id   = if available (buf_cashbook) then buf_cashbook.id else 0
              temp-fin-doc.ostatok-begin = v-sum-begin
              temp-fin-doc.fin-doc-code  = buf_fin-doc.fin-doc-code
              .
          end.
          assign
            temp-fin-doc.sheet-num    = v-sheet-num
            temp-fin-doc.prn-doc-code = buf_fin-doc.prn-doc-code
            temp-fin-doc.payer        = buf_fin-doc.payer-name
            temp-fin-doc.receiver     = buf_fin-doc.receiver-name
            temp-fin-doc.cor-acc      = buf_fin-doc.cor-acc-value
            temp-fin-doc.fin-doc-type = buf_fin-doc.fin-doc-type
            temp-fin-doc.sum-rubl     = buf_fin-doc.sum-doc
              
            .
          if temp-fin-doc.fin-doc-type = {&income-cash} then temp-fin-doc.sum-income = temp-fin-doc.sum-income + temp-fin-doc.sum-rubl .
          else temp-fin-doc.sum-expense = temp-fin-doc.sum-expense + temp-fin-doc.sum-rubl .
              
          find first temp-fin-sum where 
            temp-fin-sum.host-code    = temp-fin-doc.host-code
            and temp-fin-sum.obj-code     = temp-fin-doc.obj-code
            and temp-fin-sum.obj-type     = temp-fin-doc.obj-type
            and temp-fin-sum.cashbook_id  = temp-fin-doc.cashbook_id
            use-index pi no-error .
          if not available (temp-fin-sum) then 
          do:
            create temp-fin-sum .
            assign
              temp-fin-sum.host-code   = temp-fin-doc.host-code
              temp-fin-sum.obj-code    = temp-fin-doc.obj-code
              temp-fin-sum.obj-type    = temp-fin-doc.obj-type
              temp-fin-sum.cashbook_id = temp-fin-doc.cashbook_id
              .
          end.   
          assign
            temp-fin-sum.sum-expense = temp-fin-sum.sum-expense + temp-fin-doc.sum-expense
            temp-fin-sum.sum-income  = temp-fin-sum.sum-income + temp-fin-doc.sum-income
            temp-fin-sum.ostatok     = temp-fin-doc.ostatok-begin + temp-fin-sum.sum-income - temp-fin-sum.sum-expense
            .
              
        end.
      end.
    end.
  end. /*buf_list-object*/
  
  release buf_fin-doc .
  
end procedure . /*report-exec*/

PROCEDURE get-report-num :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.
