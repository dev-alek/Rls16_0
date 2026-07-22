block-level on error undo, throw.
/*

$Revision: 074931e2893a, 3249, rls $
$Author: EShklyar $
$Date: 2023/01/27 13:45:25 $
$Workfile: pre-vedom.p $
$Archive: rep/pre-vedom.p $

Печать платежа  типа расход наличные

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code as integer no-undo .
define input parameter p-fin-doc-code as integer no-undo .
/*1 - Landscape 0 -portrait*/

&SCOP f-l MonthNameRusGen

define variable vss-revision    as character no-undo init "$Revision: 074931e2893a, 3249, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/01/27 13:45:25 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pre-vedom.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/pre-vedom.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа расход наличные".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/frmlib.i }
{ gbl/db-attr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ rep/html-conv.i }


define temp-table tt-coins no-undo XML-NODE-NAME "coins" serialize-name "coins"
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id desc.

define temp-table tt-banknots no-undo XML-NODE-NAME "banknots" serialize-name "banknots"
  field id       as integer
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id .
        
define temp-table tt-monets no-undo
  field id       as decimal
  field qnty     as decimal
  field sum-qnty as decimal
  index pi id .

define dataset ds-banknots XML-NODE-NAME "money" serialize-name  "money" for tt-banknots,
  tt-coins .

define variable hQueryCoins           as handle    no-undo .
define variable hQueryBanknot         as handle    no-undo .
define variable g#report-num          as integer   no-undo .
define variable g#quest-print         as logical   no-undo.


define variable Line                  as character no-undo .

define variable g#log                 as logical   no-undo .
define variable v-okud                as character no-undo .
define variable p-report-id           as character no-undo .
define variable v-file-name-rep-html  as character no-undo .
define variable v-file-name-rep-html1 as character no-undo .
define variable CSJson                as longchar  no-undo .
define variable CShtt                 as handle    no-undo .
define variable v-num-bag             as character no-undo .
define variable v-fin-doc-list        as character no-undo .
define variable v-shift-date          as date      no-undo .
define variable v-firm                as character no-undo .
define variable v-obj-name            as character no-undo .
define variable v-total-sum           as decimal   no-undo .
define variable ii                    as integer   no-undo .
define variable jj                    as integer   no-undo .
define variable v-debt-schet          as character no-undo .
define variable v-credit-schet        as character no-undo .
define variable v-inn                 as character no-undo .
define variable v-schet               as character no-undo .
define variable v-bank-code           as character no-undo .
define variable v-deposit-bank        as character no-undo .
define variable v-deposit-bank_name   as character no-undo .
define variable v-deposit-bank_bik    as character no-undo .
define variable v-recip-bank          as character no-undo .
define variable v-recip-bank_name1    as character no-undo .
define variable v-recip-bank_bik1     as character no-undo .
define variable v-schet1              as character no-undo .
define variable v-recip-bank_name2    as character no-undo .
define variable v-recip-bank_bik2     as character no-undo .
define variable v-schet2              as character no-undo .
define variable v-schetUB             as character no-undo .
define variable v-source              as character no-undo .
define variable v-source1             as character no-undo .
define variable v-total-rubl          as character no-undo .
define variable v-total-kop           as character no-undo .
define variable v-ii                  as character no-undo .
define variable name-page-obor        as character no-undo .
define variable name-page             as character no-undo .
define variable v-ok-cashGB           as logical   no-undo .
define variable v-ok-cashUB           as logical   no-undo .
define variable v-sum-cashGB          as decimal   no-undo .
define variable v-sum-cashUB          as decimal   no-undo .
define variable v-sum                 as character no-undo .
define variable v-simvol              as character no-undo .
define variable v-name-titul          as character no-undo .
define variable v-name-titul1         as character no-undo .
define variable v-cashier             as character no-undo .
define variable v-decimal             as decimal   no-undo . 
define variable v-pin                 as character no-undo .
define variable v-qr-code             as integer   no-undo .
define variable v-hist-name           as character no-undo .
define variable v-hist-code           as character no-undo .
define variable v-bank-kredit         as logical   no-undo .
define variable par-type              as character no-undo .
define stream Out-Stream.
define stream OutStr-html.

define buffer buf_fin-doc      for ub.fin-doc .
define buffer buf_fin-doc-attr for ub.fin-doc-attr .
define buffer buf_clients      for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_fin-bank     for ub.fin-bank .
do
  on error undo, return error return-value
  :
  find first ub.fin-doc no-lock where ub.fin-doc.fin-doc-code = p-fin-doc-code and ub.fin-doc.host-code = p-host-code no-error .
  v-shift-date = ub.fin-doc.shift-date .

  for first ub.fin-doc-attr no-lock where ub.fin-doc-attr.attr-code = "pre-vedom"
    and ub.fin-doc-attr.fin-doc-code = p-fin-doc-code and ub.fin-doc-attr.host-code = p-host-code:
    assign
      v-num-bag      = entry(1,ub.fin-doc-attr.attr-value,";") 
      v-deposit-bank = entry (2,ub.fin-doc-attr.attr-value,";")  
      v-recip-bank   = entry (3,ub.fin-doc-attr.attr-value,";") 
      .

    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(v-recip-bank) and ub.fin-bank.host-code = ub.fin-doc-attr.host-code:
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and 
        ub.fin-bank-attr.attr-code = "collect-qrcode" no-error .
      if available (ub.fin-bank-attr) then v-qr-code = integer(ub.fin-bank-attr.attr-value) .
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and 
        ub.fin-bank-attr.attr-code = "collect-debt" no-error .
      if available (ub.fin-bank-attr) then v-debt-schet = ub.fin-bank-attr.attr-value . 
      find first ub.fin-bank-attr no-lock where ub.fin-bank-attr.code-bank = ub.fin-bank.code-bank and ub.fin-bank-attr.host-code = ub.fin-bank.host-code and 
        ub.fin-bank-attr.attr-code = "collect-credit" no-error .
      if available (ub.fin-bank-attr) then v-credit-schet = ub.fin-bank-attr.attr-value .
    end.  

     
    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(v-deposit-bank) and ub.fin-bank.host-code = ub.fin-doc-attr.host-code:
      assign
        v-deposit-bank_name = ub.fin-bank.bank-name 
        v-deposit-bank_bik  = ub.fin-bank.bik .
    end.
    for each buf_fin-doc no-lock where buf_fin-doc.host-code = ub.fin-doc.host-code and buf_fin-doc.shift-date = ub.fin-doc.shift-date and buf_fin-doc.shift-name = ub.fin-doc.shift-name
      and buf_fin-doc.obj-code = ub.fin-doc.obj-code and buf_fin-doc.obj-type = ub.fin-doc.obj-type,
      first buf_fin-doc-attr no-lock where buf_fin-doc-attr.attr-code = "pre-vedom" and buf_fin-doc-attr.host-code = buf_fin-doc.host-code and entry(1,buf_fin-doc-attr.attr-value,";") = v-num-bag and
      buf_fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code:
      if buf_fin-doc.CashBookId <> 0 then 
      do:
        v-ok-cashUB = yes .
        v-decimal =  buf_fin-doc.sum-doc .
        v-sum-cashUB = v-sum-cashUB + v-decimal .
        v-pin = if v-pin = " " then entry(4,buf_fin-doc-attr.attr-value,";") else v-pin + "/" + entry(4,buf_fin-doc-attr.attr-value,";") .
        /* Счет смотрим в настройках по кассовой книге */
        for first ub.CashBook no-lock where ub.CashBook.id = buf_fin-doc.CashBookId:
          for each ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
            ub.CashBookRule.Code = "BankRecip-acct" and ub.CashBookRule.Status_ = 0:
            v-schet2 = ub.CashBookRule.RuleValue .                                                                     
          /*         else v-schet2 = ub.CashBookRule.RuleValue .*/
          end.
        end.        
      end.  
      else 
      do:
        v-ok-cashGB = yes .
        v-decimal =  buf_fin-doc.sum-doc .
        v-sum-cashGB = v-sum-cashGB + v-decimal .
        v-pin = if v-pin = " " then entry(4,buf_fin-doc-attr.attr-value,";") else v-pin + "/" + entry(4,buf_fin-doc-attr.attr-value,";") .
        /* Счет смотрим в настройках по кассовой книге */
        for first ub.CashBook no-lock where ub.CashBook.id = buf_fin-doc.CashBookId:
          for each ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
            ub.CashBookRule.Code = "BankRecip-acct" and ub.CashBookRule.Status_ = 0:
            v-schet1 = ub.CashBookRule.RuleValue .                                                                     
          /*         else v-schet2 = ub.CashBookRule.RuleValue .*/
          end.
        end.         
      end.  
      
      v-fin-doc-list = v-fin-doc-list + ";" + string(buf_fin-doc-attr.fin-doc-code) .
      v-total-sum = v-total-sum + buf_fin-doc.sum-doc .
      v-ii = entry(3,buf_fin-doc-attr.attr-value,";") .
      if lookup (v-ii,v-bank-code,";") = 0 then 
      do: 
        v-bank-code = v-bank-code + ";" + entry(3,buf_fin-doc-attr.attr-value,";") .
      end.
    end.  
    if v-ok-cashGB then v-source = "Поступления от продажи товаров" .
    if v-ok-cashUB then v-source1 = "Прочие поступления" .
    v-source = v-source + ", " + v-source1 .
    
    find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error .
    assign 
      v-cashier = if available ub.user-account then string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) else "".
  end.  
  v-schet = v-schet1 + "," + v-schet2 .
  v-schet = trim(v-schet,",") .
  if v-debt-schet = "" then v-credit-schet = v-schet .
  v-bank-code = trim (v-bank-code,";") .
  v-fin-doc-list = trim(v-fin-doc-list,";") .
  v-source = trim(v-source,", ") .
      
  do ii = 1 to num-entries (v-bank-code,";"):
    for first ub.fin-bank no-lock where ub.fin-bank.code-bank = integer(entry (ii,v-bank-code,";")) and ub.fin-bank.host-code = p-host-code:
      do jj = 1 to num-entries (v-schet,","):
        for first ub.fin-schet no-lock where ub.fin-schet.code-bank = ub.fin-bank.code-bank and ub.fin-schet.status_ = {&current-status} and
          ub.fin-schet.r-schet = entry (jj,v-schet,","):
          if v-recip-bank_name1 <> "" then 
          do:
            v-recip-bank_name2 = ub.fin-bank.bank-name . 
          end. 
          else v-recip-bank_name1 = ub.fin-bank.bank-name .
          if v-recip-bank_bik1 <> "" then 
          do: 
            v-recip-bank_bik2 = ub.fin-bank.bik . 
          end. 
          else v-recip-bank_bik1 = ub.fin-bank.bik .
        end.  
      end.
    end.
  end.  
  
  v-total-rubl = Sum-in-Words-Without-Dec(v-total-sum) .
  v-total-kop = string((v-total-sum - truncate(v-total-sum, 0)) * 100, "99":U) .

  do ii = 1 to num-entries(v-fin-doc-list,";"):
    empty temp-table tt-banknots .
    empty temp-table tt-coins .
    for first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = integer(entry(ii,v-fin-doc-list,";")) and buf_fin-doc-attr.host-code = p-host-code
      and buf_fin-doc-attr.attr-code = "cover_sheet":
      CSJson = buf_fin-doc-attr.attr-value .
      if CSJson <> "" and CSJson <> ? then 
      do:
        dataset ds-banknots:handle:read-json ("longchar",CSJson) .
      
        for each tt-banknots no-lock where tt-banknots.qnty <> 0:

          find first tt-monets exclusive-lock where tt-monets.id = tt-banknots.id no-error .
          if not available (tt-monets) then 
          do:
            create tt-monets .
            tt-monets.id = tt-banknots.id .
          end.  
          assign
            tt-monets.qnty     = tt-monets.qnty + tt-banknots.qnty
            tt-monets.sum-qnty = tt-monets.sum-qnty + tt-banknots.sum-qnty 
            .
        end.  
        for each tt-coins no-lock where tt-coins.qnty <> 0:
          find first tt-monets exclusive-lock where tt-monets.id = tt-coins.id no-error .
          if not available (tt-monets) then 
          do:
            create tt-monets .
            tt-monets.id = tt-coins.id .
          end.  
          assign
            tt-monets.qnty     = tt-monets.qnty + tt-coins.qnty
            tt-monets.sum-qnty = tt-monets.sum-qnty + tt-coins.sum-qnty 
            .
        end.     
      end.   
    end.  
  end.  

  find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = ub.fin-doc.host-code no-error .
  if available (buf_clients) then v-firm = buf_clients.obj-name .
  find first ub.firm no-lock where ub.firm.firm-code = ub.fin-doc.host-code no-error .
  v-inn = ub.firm.inn .
  
  find first buf_clients no-lock where buf_clients.obj-type = ub.fin-doc.obj-type and buf_clients.obj-code = ub.fin-doc.obj-code no-error .
  if available (buf_clients) then v-obj-name = buf_clients.obj-name .  
  
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-name},OUTPUT v-hist-name ,OUTPUT par-type) .
  
  if v-hist-name = "" then v-hist-name = v-obj-name .
  
  if v-qr-code = 1 then 
  do:
/*QR-код*/
    {gbl/base64.i}
    define variable qr-code     as character no-undo.
    define variable qr-code-out as character no-undo.
    qr-code = '<?xml version="1.0" encoding="windows-1251" standalone="yes"?>
<client_info><client_info_row>
<client_ink>8598123368358741900012</client_ink>
<client_ino>156885</client_ino>
<client_name>АЗС№02-136 БашнефтьРозница</client_name>
<client_organization_name>Общество с ограниченной ответственностью "Башнефть-Розница"</client_organization_name>
<client_address xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">Чишмы, Железнодорожная,1-1</client_address>
<client_inn>1831090630</client_inn>
<client_kpp>027801001</client_kpp>
<client_accounts>
<acc_num>40702810306000008673</acc_num>
<bic>048073601</bic>
<bank_name>БАШКИРСКОЕ ОТДЕЛЕНИЕ N8598 ПАО СБЕРБАНК Г.Уфа</bank_name>
</client_accounts>
<client_accounts>
<acc_num>40821810200000000015</acc_num>
<bic>044525880</bic>
<bank_name>БАНК "ВБРР" (АО) Г.Москва</bank_name>
</client_accounts>
<bank_name>БАШКИРСКОЕ ОТДЕЛЕНИЕ N8598 ПАО СБЕРБАНК Г.УФА</bank_name>
<bank_bic>048073601</bank_bic>
<debet_account xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>
</client_info_row></client_info>'.

    run base64-encode (qr-code,output qr-code-out).
    define variable v-arc as character no-undo .
    define variable v-cmd as character no-undo .  

    assign
      v-arc = search( "exe/qrgen.exe":U )
      .
    if v-arc = ? then 
    do:
      return error "Не найдена программа qrgen.exe" .
    end.   

    os-command silent value (v-arc + ' -size=128 -content="' + qr-code-out + '"' + ' -filename="c:\temp\qr-code"') .
  end.
  run get-report-num  (output g#report-num).
  
  do jj = 1 to 3:
    
    v-file-name-rep-html = session:temp-directory + string(g#report-num) + "_" + string (jj) + ".html".

    /*Проверить, что печатать*/

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

    /*Печать первый лист*/
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Ведомость_1">'skip
      .

    put stream OutStr-html unformatted
      '<thead>' skip.
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '</tr>' skip
      .

    case jj:
      when 1 then 
        do:
          v-name-titul = "Препроводительная ведомость к сумке" .
          v-name-titul1 = "ВЕДОМОСТЬ К СУМКЕ" .
        end. 
      when 2 then 
        do:
          v-name-titul = "" .
          v-name-titul1 = "НАКЛАДНАЯ К СУМКЕ" .
        end.
      when 3 then 
        do:
          v-name-titul = "" .
          v-name-titul1 = "КВИТАНЦИЯ К СУМКЕ" .
        end.     
    end case .
    if jj = 1 then 
    do:
      if v-pin <> "" then 
      do:
        put stream OutStr-html unformatted
          '<tr style="height: 45px;">' skip
          '<td></td>' skip
          '<td colspan="52" style="font-weight: bold;">ПИН ' + v-pin + '</td>' skip
          .
        if search( "C:\Temp\qr-code.png":U ) <> ? and v-qr-code = 1 then 
        do:  
          put stream OutStr-html unformatted   
            '<td rowspan="3" colspan="74" style="text-align: right;"><img src="C:\Temp\qr-code.png" width="130" height="130" alt=""/></td>'.
        end.
        else 
        do:  
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"></td>'.
        end.  
        put stream OutStr-html unformatted            
          '<td colspan="31"></td>' skip
          '</tr>' skip 
          '<tr><td colspan="53"></td>' skip
          '<td colspan="31"></td>' skip
          '</tr>' skip .
      end.    
      else 
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td></td>' skip
          '<td colspan="52"></td>' skip
          .
        if search( "C:\Temp\qr-code.png":U ) <> ? and v-qr-code = 1 then 
        do:  
          put stream OutStr-html unformatted   
            '<td rowspan="3" colspan="74" style="text-align: right;"><img src="C:\Temp\qr-code.png" width="130" height="130" alt=""/></td>'.
        end.
        else 
        do:  
          put stream OutStr-html unformatted
            '<td rowspan="3" colspan="74" style="text-align: right;"></td>'.
        end.  
        put stream OutStr-html unformatted
          '<td colspan="31"></td>' skip
          '</tr>' skip 
          '<tr><td colspan="53"></td>' skip
          '<td colspan="31"></td>' skip
          '</tr>' skip .
      
      end.  
    end.
    else 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="52"></td>' skip
        '<td rowspan="2" colspan="74" style="text-align: right;"></td>'
        '<td colspan="31"></td>' skip
        '</tr>' skip 
        '<tr><td colspan="53"></td>' skip
        '<td colspan="31"></td>' skip
        '</tr>' skip .

    end.  
    if jj <> 1 then 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="52"></td>' skip
        '<td rowspan="2" colspan="74" style="text-align: right;"></td>'
        '<td colspan="31"></td>' skip
        '</tr>' skip. 
    end.  
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="52" style="text-align: center; font-weight: bold;">' + v-name-titul + '</td>' skip
      '<td colspan="31" style="text-align: center; border: 1px solid black;">Код формы документа по ОКУД 0402300</td>' skip
      '</tr>' skip 
      '<tr><td colspan="158"></td></tr>' skip .
    
    
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="32" style="text-align: left; font-weight: bold;">' + v-name-titul1 + '</td>' skip
      '<td colspan="4"></td>' skip
      '<td colspan="5">№</td>' skip
      '<td colspan="15" style="text-align: center; border: 1px solid black;">' + if v-num-bag <> ? then v-num-bag + '</td>' else ""  + '</td>' skip
      '<td colspan="8"></td>' skip
      '<td colspan="50" style="text-align: center; border-bottom: 1px solid black;">' + if v-shift-date <> ? then string(v-shift-date) + '</td>' else ""  + '</td>' skip
      '<td colspan="12"></td>' skip
      '<td colspan="14" style="text-align: right; border-left: 1px solid black; border-top: 1px solid black;">Сумка №</td>' skip
      '<td colspan="16" style="text-align: center; border-top: 1px solid black; border-bottom: 1px solid black;">' + if v-num-bag <> ? then v-num-bag + '</td>' else ""  + '</td>' skip
      '<td colspan="1" style="text-align: center; border-top: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="32" style="text-align: center;"></td>' skip
      '<td colspan="4"></td>' skip
      '<td colspan="5"></td>' skip
      '<td colspan="15"></td>' skip
      '<td colspan="8"></td>' skip
      '<td colspan="50" style="text-align: center; font-size: 8px;">Дата</td>' skip
      '<td colspan="12"></td>' skip
      '<td colspan="31" style="text-align: right; border-left: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="69"></td>'
      '<td colspan="52" style="text-align: center;">ДЕБЕТ</td>' skip
      '<td colspan="36"></td>' skip
      '</tr>' skip
      .
        
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="10" style="text-align: left;">От кого</td>' skip
      '<td colspan="57" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + v-hist-name + " " + v-firm + '</td>' skip
      '<td style="border-bottom: 1px solid black; border-top: 1px solid black;"></td>' skip
      '<td colspan="9" style="border-bottom: 1px solid black; border-top: 1px solid black;">счет №</td>' skip
      '<td colspan="43" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">' + v-debt-schet + '</td>' skip
      '<td colspan="37" style="text-align: right; border-left: 1px solid black; border-top: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .
    
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="67" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="52" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">КРЕДИТ</td>' skip
      '<td colspan="37" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; font-weight: bold;">' + string(v-total-sum) + '</td>' skip
      '</tr>' skip .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: left;">Получатель</td>' skip
      '<td></td>' skip
      '<td colspan="52" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black;">' + v-firm + '</td>' skip
      '<td style="border-bottom: 1px solid black; border-top: 1px solid black;"></td>' skip
      '<td colspan="9" style="border-bottom: 1px solid black;">счет №</td>' skip
      '<td colspan="43" style="text-align: center; border-bottom: 1px solid black; border-right: 1px solid black; border-top: 1px solid black;">' + v-credit-schet + '</td>' skip
      '<td colspan="37" style="text-align: right; border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
      '</tr>' skip .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="6" style="text-align: left;">ИНН</td>' skip
      '<td></td>' skip
      '<td colspan="36" style="text-align: center; border-bottom: 1px solid black;">' + v-inn + '</td>' skip
      '<td colspan="11" style="text-align: center;">Счет№</td>' skip
      '<td colspan="66" style="text-align: center; border-bottom: 1px solid black;">' + v-schet + '</td>' skip
      '<td colspan="37" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black;">Сумма цифрами</td>' skip
      '</tr>' skip .


    /*счетов может быть несколько*/
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="36" style="text-align: left;">Наименование банка-вносителя</td>' skip
      '<td></td>' skip
      '<td colspan="51" style="text-align: center; border-bottom: 1px solid black;">' + v-deposit-bank_name + '</td>' skip
      '<td></td>' skip
      '<td colspan="10">БИК</td>' skip
      '<td colspan="21" style="text-align: center; border-bottom: 1px solid black;">' + v-deposit-bank_bik + '</td>' skip
      '<td colspan="37" style="text-align: center; border: 1px solid black;">в том числе по символам:</td>' skip
      '</tr>' skip .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">Наименование банка-получателя</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">БИК</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">Счет№</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">символ</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">сумма</td>' skip
      '</tr>' skip .

    if v-ok-cashGB then 
    do: 
      v-sum = string(v-sum-cashGB) .
      v-simvol = "02" .
      v-schetUB = v-schet1 .
    end.
    else 
    do:
      v-sum = string(v-sum-cashUB) .
      v-simvol = "32" .
      v-schetUB = v-schet2 .
    end.        
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">' + v-recip-bank_name1 + '</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">' + v-recip-bank_bik1 + '</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">' + v-schetUB + '</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">' + v-simvol + '</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">' + string(v-sum) + '</td>' skip
      '</tr>' skip .

    if v-ok-cashUB and v-simvol <> "32" then 
    do: 
      v-sum = string(v-sum-cashUB) .
      v-simvol = "32" .
      v-schetUB = v-schet2 .
    end.
    else 
    do:
      v-sum = "" .
      v-simvol = "" .
      v-schetUB = "" .
    end.              
 
    put stream OutStr-html unformatted
      '<tr style="height: 20px;">' skip
      '<td colspan="74" style="text-align: left; border-bottom: 1px solid black;">' + v-recip-bank_name2 + '</td>' skip
      '<td colspan="10" style="border-bottom: 1px solid black; text-align: left;">' + v-recip-bank_bik2 + '</td>' skip
      '<td colspan="37" style="text-align: left; border-bottom: 1px solid black;">' + v-schetUB + '</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;">' + v-simvol + '</td>' skip
      '<td colspan="21" style="text-align: center; border: 1px solid black;">' + string(v-sum) + '</td>' skip
      '</tr>' skip .
        
    /*    put stream OutStr-html unformatted                                                                                 */
    /*      '<tr>' skip                                                                                                      */
    /*      '<td></td>' skip                                                                                                 */
    /*      '<td colspan="73" style="text-align: center; border-bottom: 1px solid black;"></td>' skip                        */
    /*      '<td colspan="10">БИК</td>' skip                                                                                 */
    /*      '<td colspan="37" style="text-align: center; border-bottom: 1px solid black;">' + v-recip-bank_bik + '</td>' skip*/
    /*      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip                               */
    /*      '<td colspan="21" style="text-align: center; border: 1px solid black;"></td>' skip                               */
    /*      '</tr>' skip .                                                                                                   */
    
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="25" style="text-align: left;">Сумма прописью</td>' skip
      '<td></td>' skip
      '<td colspan="94" style="border-bottom: 1px solid black;">' + v-total-rubl + '</td>' skip
      .
      
    if jj <> 2 then 
    do:
      put stream OutStr-html unformatted      
        '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
        '<td colspan="21" style="text-align: center; border: 1px solid black;"></td>' skip
        '</tr>' skip .
    end.
    else 
    do:
      put stream OutStr-html unformatted      
        '<td colspan="27" style="text-align: center; border: 1px solid black;">Шифр документа</td>' skip
        '<td colspan="10" style="text-align: center; border: 1px solid black;"></td>' skip
        '</tr>' skip .
    end.

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="130" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td colspan="6">руб.</td>' skip
      '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;">' + v-total-kop + '</td>' skip
      '<td colspan="6">коп.</td>' skip
      '<td></td>' skip
      '</tr>' skip .
      
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="20"></td>' skip
      '<td></td>' skip
      '<td colspan="108" style="text-align: center;"></td>' skip
      '<td colspan="6"></td>' skip
      '<td colspan="15" style="text-align: center; font-size: 8px;">(цифрами)</td>' skip
      '<td colspan="6"></td>' skip
      '<td></td>' skip
      '</tr>' skip .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="34" style="text-align: center;">Источник поступления</td>' skip
      '<td style="border-bottom: 1px solid black;"></td>' skip
      '<td colspan="122" style="border-bottom: 1px solid black;">' + v-source + '</td>' skip
      '</tr>' skip 
      '<tr><td colspan="158" style="height:17px;"></td></tr>' skip
      '<tr><td colspan="158" style="height:17px;"></td></tr>' skip.
 
    if jj <> 3 then 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9">Клиент</td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;">' + v-cashier + '</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '</tr>' skip
        .   
      
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9"></td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '</tr>'
        .
    end.  
    else 
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9">Клиент</td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;">' + v-cashier + '</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '</tr>' skip
        .   
      
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="9"></td>' skip
        '<td></td>' skip
        '<td colspan="22" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '</tr>'
        .

      put stream OutStr-html unformatted
        '<tr><td colspan="158" style="text-align: center; border-bottom: 1px solid black;"></td></tr>'
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="25">Опломбированную сумку №</td>' skip
        '<td></td>' skip
        '<td colspan="6" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;">инкассаторский работник</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" rowspan="2" style="text-align: center;">место печати (штампа)</td>' skip
        '</tr>' skip
        .   
      
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="25">без пересчета принял</td>' skip
        '<td></td>' skip
        '<td colspan="6" style="text-align: center;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center;">дата</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center;"></td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td></td>' skip
        '</tr>'
        .

      put stream OutStr-html unformatted
        '<tr><td colspan="158" style="text-align: center; height: 25px;"></td></tr>'
        '<tr>' skip
        '<td colspan="28" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="24" rowspan="2" style="text-align: center;">Сумка с объявленной суммой принята</td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="18" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="21" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '</tr>' skip.   
      
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="28" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td colspan="15" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td colspan="18" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="21" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '</tr>' skip.                
    end.  
    if jj = 2 then 
    do:  
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="49">Сумка с объявленной суммой принята</td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
        '<td colspan="15"></td>' skip
        '</tr>' skip
        .   
      
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td></td>' skip
        '<td colspan="49"></td>' skip
        '<td colspan="7"></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
        '<td></td>' skip
        '<td></td>' skip
        '<td colspan="23" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
        '<td></td>' skip
        '<td colspan="30" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
        '<td colspan="15"></td>' skip
        '</tr>' skip.
    end.

    put stream OutStr-html unformatted  
      '</thead>' skip
      '<tbody>' skip    
      .
    put stream OutStr-html unformatted
      '</tbody>' skip  
      '</table>' skip
      .


    /*печать оборотного листа*/
    put stream OutStr-html unformatted
      '<TABLE fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0" name="Ведомость_2">'skip
      .

    put stream OutStr-html unformatted
      '<thead>' skip.
    put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
    
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '<td style="width: 6px;"></td>' skip
      '</tr>' skip
      .
    if jj <> 3 then 
    do:  
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="158" style="text-align: center;">Опись сдаваемых наличных денег</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="158" ></td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">Номинал банкнот, монеты</th>' skip
        '<th colspan="52" style="text-align: center; font-weight: bold;">Количество сдаваемых банкнот, монеты (в листах, штуках)</th>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">Сумма цифрами</th>' skip
        '</tr>' skip
        . 
      put stream OutStr-html unformatted
        '<tr>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">1</th>' skip
        '<th colspan="52" style="text-align: center; font-weight: bold;">2</th>' skip
        '<th colspan="53" style="text-align: center; font-weight: bold;">3</th>' skip
        '</tr>' skip
        .


      /*заполнение таблицы циклом*/
      for each tt-monets by tt-monets.id:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="53" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-monets.id,"->>>>>>>>>>>9.99",2) + '" style="text-align: center; border: 1px solid black; font-size: 9px;">' + fnc-convert-dot-to-colon(tt-monets.id,"->>>>>>>>>>>9.99",2) + '</td>' skip
          '<td colspan="52" style="text-align: center; border: 1px solid black; font-size: 9px;">' + string(tt-monets.qnty) + '</td>' skip
          '<td colspan="53" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-monets.sum-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: center; border: 1px solid black; font-size: 9px;">' + fnc-convert-dot-to-colon(tt-monets.sum-qnty,"->>>>>>>>>>>9.99",2) + '</td>' skip
          '</tr>' skip
          .
      end.
    end.
    put stream OutStr-html unformatted
      '<tr><td colspAN="158"></td></tr>' skip
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="92">Акт вскрытия сумки и пересчета вложенных наличных денег</td>' skip
      '<td colspan="23"></td>' skip
      '<td colspan="30" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td colspan="12"></td>' skip
      '</tr>' skip 
      .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '<td colspan="72"></td>' skip
      '<td colspan="43"></td>' skip
      '<td colspan="30" style="text-align: center; font-size: 8px;">Дата</td>' skip
      '<td colspan="12"></td>' skip
      '</tr>' skip 
      .

    put stream OutStr-html unformatted
      '<tr style="height: 80px;">' skip
      '<td colspan="21" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Фактическая сумма цифрами</td>' skip
      '<td colspan="17" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сумма недостачи цифрами</td>' skip
      '<td colspan="21" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сумма излишка цифрами</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold;  border: 1px solid black;">Сомнительные денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold; border: 1px solid black;">Неплатежеспособные не имеющие признаков подделки денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '<td colspan="33" text_wrap="true" style="text-align: center; font-weight: bold; border: 1px solid black;">Имеющие признаки подделки денежные знаки (для банкнот Банка России - номинал, год образца, серия и номер; для монеты Банка России - номинал, год, чеканка, наименование монетного двора)</td>' skip
      '</tr>' skip
      . 
    
    put stream OutStr-html unformatted
      '<tr>' skip
      '<th colspan="21" style="text-align: center; font-weight: bold; border: 1px solid black;">1</th>' skip
      '<th colspan="17" style="text-align: center; font-weight: bold; border: 1px solid black;">2</th>' skip
      '<th colspan="21" style="text-align: center; font-weight: bold; border: 1px solid black;">3</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">4</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">5</th>' skip
      '<th colspan="33" style="text-align: center; font-weight: bold; border: 1px solid black;">6</th>' skip
      '</tr>' skip
      .


    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="21" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="21" rowspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      .

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      . 

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '<td colspan="33" style="text-align: center; border: 1px solid black; height: 20px;"></td>' skip
      '</tr>' skip
      . 

    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '<td colspan="17" style="border: 1px solid black;">Сумма цифрами</td>' skip
      '<td colspan="16" style="text-align: center; border: 1px solid black;"></td>' skip
      '</tr>' skip
      . 


    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="10">Клиент</td>' skip
      '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '<td colspan="19" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
      '<td></td>' skip
      '</tr>' skip
      .   
      
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(наименование должности)</td>' skip
      '<td></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="20" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '<td colspan="10"></td>' skip
      '<td colspan="14" style="text-align: center; font-size: 8px;">(личная подпись)</td>' skip
      '<td></td>' skip
      '<td colspan="19" style="text-align: center; font-size: 8px;">(фамилия, инициалы)</td>' skip
      '<td></td>' skip
      '</tr>' skip
      '</thead>' skip
      '<tbody>' skip    
      .
    put stream OutStr-html unformatted
      '</tbody>' skip  
      '</table>' skip
      .

    put stream OutStr-html unformatted
        
      '</body>' skip
      '</html>' skip
      .
    output stream OutStr-html close.
    if v-file-name-rep-html1 = "" then v-file-name-rep-html1 = v-file-name-rep-html .
    else v-file-name-rep-html1 =  v-file-name-rep-html1 + " " + v-file-name-rep-html .      
  
  end.
  
      

  
  run prn-lib-reportviewer in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-html1
    ,input "EXCEL:TRUE"
    ). 
    
    
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

end.    
    

/*    run rko2xl-close in this-procedure .*/
/*    if p-from-forms then do:                                                                        */
/*      { rep/q-print.i 0 }                                                                           */
/*    end. /*if from-forms*/                                                                          */
/*    else do:                                                                                        */
/*    if not p-append                                                                                 */
/*    then do:                                                                                        */
/*        os-delete                                                                                   */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        os-rename                                                                                   */
/*            value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )       */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        run prn-lib-prn-file in this-procedure (                                                    */
/*            input parParentProc                                                                     */
/*            , input 0                                                                               */
/*        ).                                                                                          */
/*        os-delete                                                                                   */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        os-delete                                                                                   */
/*            value( v-rko2xl-cell-file-name )                                                        */
/*        .                                                                                           */
/*    end.                                                                                            */
/*    end. /*else if from-forms*/                                                                     */
/*end.*/