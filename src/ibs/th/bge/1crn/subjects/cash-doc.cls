/*

$Revision: 870fbceb5a42, 3029, rls $
$Author: Ostroukhov $
$Date: Пт апр 29 17:03:42 2022 +0300 $
$Workfile: cash-doc.cls $
$Archive: ibs/th/bge/1crn/subjects/cash-doc.cls $

Экспорт сообщения с накладаной в 1С ERPRN cash-doc

Автор: Елена Шкляр
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.cash-doc implements iexpsubject:

  
  { cmp/str-glbl.i class }
  { gbl/xmlchar.i CLASS}
  { ibs/th/ref/Coins_Bank_tt.i }
  define temp-table tt-fin-doc like ub.c-fin-doc .
  define temp-table tt-fin-doc-tax like ub.c-fin-doc-tax .
  define temp-table tt-fin-doc-attr no-undo
    field fin-doc      as integer
    field sumka        as character
    field banknote     as character
    field bank-resive  as integer
    field bank-deposit as integer
    field pin          as character
    field source_      as character
    field contr-kb     as character init ?
    index pi fin-doc
    .
  
  define property Msg as character no-undo
    get.
    private set.

  define property InitSecTag as character no-undo init "cash"
    get.
    private set.
      
  define public property sendTableName  as character  no-undo init "fin-doc"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define property fin-doc as character no-undo
    get.
    set.

  define property del_f  as integer no-undo
    get.
    set.

  define variable sw     as handle    no-undo.
  define variable v-type as character no-undo .
  define variable CSJson as longchar  no-undo .
  
  method public void CrContentToSW (insw as handle):
  define buffer buf_fin-doc       for ub.fin-doc .
  define buffer buf_fin-doc-attr  for ub.fin-doc-attr .
  define buffer buf_fin-doc-tax   for ub.fin-doc-tax .
  define buffer buf_c-fin-doc     for ub.c-fin-doc .
  define buffer buf_c-fin-doc-tax for ub.c-fin-doc-tax .
  define buffer buf_CashBook      for ub.CashBook .
    
    sw = insw .    

    /* взятие документа для выгрузки: сам документ, либо история документа */
    find first buf_fin-doc no-lock where buf_fin-doc.fin-doc-code = INTEGER (fin-doc) no-error .
    if AVAILABLE buf_fin-doc then 
    do:
      sendOldRowid  = rowid(buf_fin-doc).
      create tt-fin-doc .
      BUFFER-COPY buf_fin-doc to tt-fin-doc .
      for each buf_fin-doc-tax no-lock where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code:
        create tt-fin-doc-tax .
        BUFFER-COPY buf_fin-doc-tax to tt-fin-doc-tax .
      end.  
    end.
    else 
    do:
      find FIRST buf_c-fin-doc no-lock where buf_c-fin-doc.fin-doc-code = INTEGER (fin-doc) no-error .
      if AVAILABLE buf_c-fin-doc then 
      do:
        sendOldRowid  = rowid(buf_c-fin-doc).
        create tt-fin-doc .
        BUFFER-COPY buf_c-fin-doc to tt-fin-doc .
        for first buf_c-fin-doc-tax no-lock where buf_c-fin-doc-tax.fin-doc-code = buf_c-fin-doc.fin-doc-code:
          create tt-fin-doc-tax .
          BUFFER-COPY buf_c-fin-doc-tax to tt-fin-doc-tax .
        end.  
      end.
      else 
      do:
        Msg = "Нет финансового документа с номером " + fin-doc .
        return error Msg.
      end.
    
    end.    
    /* end_of взятие документа для выгрузки */
    
    case tt-fin-doc.fin-doc-type:
      when {&income-cash} then 
        v-type = "1".
      when {&expense-cash} then 
        v-type = "2".
      when ? then 
        v-type = "".   
    end.  
    
    sw:start-element ("cash-doc") .
    sw:write-data-element ("doc-code", string-mth(tt-fin-doc.fin-doc-code)).
    sw:write-data-element ("num", if tt-fin-doc.prn-doc-code = ? then "" else string(tt-fin-doc.prn-doc-code)).
    sw:write-data-element ("del-f", string(del_f)).
    
    /* обязательность 0-1 */
    find first buf_CashBook no-lock where buf_CashBook.id = tt-fin-doc.CashBookId no-error .
    if available buf_CashBook then do :
      if buf_CashBook.ext-code > "" then
        sw:write-data-element ("type-kb", buf_CashBook.ext-code). /* Код типа кассовой книги (Строка) */
      find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code 
      and buf_fin-doc-attr.attr-code = "contr-kb" no-error .
      if available (buf_fin-doc-attr) then 
      do:
         find first tt-fin-doc-attr where tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code no-error .
         if not available (tt-fin-doc-attr) then 
         do:
            create tt-fin-doc-attr .
            assign
               tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code 
            .
         end.
         find first cashbook where cashbook.id eq int(buf_fin-doc-attr.attr-value)
         no-lock no-error.
         if available  cashbook
         then   
            assign
              tt-fin-doc-attr.contr-kb = CashBook.ext-code. 
            .
       end.
    end .
    find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code 
      and buf_fin-doc-attr.attr-code = "pre-vedom" no-error .
    if available (buf_fin-doc-attr) then 
    do:
      find first tt-fin-doc-attr where tt-fin-doc-attr.sumka = entry (1,buf_fin-doc-attr.attr-value,";") no-error .
      if not available (tt-fin-doc-attr) then 
      do:
        create tt-fin-doc-attr .
        assign
          tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code 
          .
      end.  
      assign
        tt-fin-doc-attr.sumka = entry (1,buf_fin-doc-attr.attr-value,";")
        tt-fin-doc-attr.bank-deposit = integer(entry(2,buf_fin-doc-attr.attr-value,";"))
        tt-fin-doc-attr.bank-resive  = integer(entry (3,buf_fin-doc-attr.attr-value,";"))
        tt-fin-doc-attr.pin          = entry(4,buf_fin-doc-attr.attr-value,";")
        tt-fin-doc-attr.source_      = if tt-fin-doc.CashBookId = 0 then "Поступления от продажи товаров" else "Прочие поступления"
        .
    end.    
    find first buf_fin-doc-attr no-lock where buf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and buf_fin-doc-attr.host-code = tt-fin-doc.host-code 
      and buf_fin-doc-attr.attr-code = "cover_sheet" no-error .
    if available (buf_fin-doc-attr) then 
    do:
      find first tt-fin-doc-attr where tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code no-error .
      if not available (tt-fin-doc-attr) then 
      do:
        create tt-fin-doc-attr .
        assign
          tt-fin-doc-attr.fin-doc = buf_fin-doc-attr.fin-doc-code 
          .
      end.  
      assign
        tt-fin-doc-attr.banknote = buf_fin-doc-attr.attr-value 
        .
    end.
    
    sw:write-data-element ("date", if tt-fin-doc.doc-date = ? then "" else ISO-DATE (tt-fin-doc.doc-date)).
    sw:write-data-element ("shift-date", if tt-fin-doc.shift-date = ? then "" else ISO-DATE (tt-fin-doc.shift-date)).
    sw:write-data-element ("shift-num", string-mth(tt-fin-doc.shift-num)).
    sw:write-data-element ("type", v-type).
    
    /* далее обязательность 0-1 */
/*    if available buf_CashBook then do :                                                                                              */
/*      if buf_CashBook.Credit > "" then                                                                                               */
/*        sw:write-data-element ("kredit", buf_CashBook.Credit). /* Номер счета в графе «Кредит» при формировании ПКО и РКО (Строка) */*/
/*      if buf_CashBook.Debit > "" then                                                                                                */
/*        sw:write-data-element ("debit", buf_CashBook.Debit). /* Номер счета в графе «Дебит» при формировании ПКО и РКО (Строка) */   */
/*    end .                                                                                                                            */
    if v-type = "1"
    then do :
      if tt-fin-doc.cor-acc-value > "" then
        sw:write-data-element ("kredit", tt-fin-doc.cor-acc-value). /* Номер счета в графе «Кредит» при формировании ПКО и РКО (Строка) */
      if tt-fin-doc.cor-acc1-value > "" then
        sw:write-data-element ("debit", tt-fin-doc.cor-acc1-value). /* Номер счета в графе «Дебит» при формировании ПКО и РКО (Строка) */
    end .
    if v-type = "2"
    then do :
      if tt-fin-doc.cor-acc-value > "" then
        sw:write-data-element ("kredit", tt-fin-doc.cor-acc1-value). /* Номер счета в графе «Кредит» при формировании ПКО и РКО (Строка) */
      if tt-fin-doc.cor-acc1-value > "" then
        sw:write-data-element ("debit", tt-fin-doc.cor-acc-value). /* Номер счета в графе «Дебит» при формировании ПКО и РКО (Строка) */
    end .
    
    sw:write-data-element ("sum", string-mth(tt-fin-doc.sum-doc)).
    if v-type = "1" then 
    do:
      sw:write-data-element ("contr-name", if tt-fin-doc.payer-name = ? then "" else string(tt-fin-doc.payer-name)).
      sw:write-data-element ("contr-code", string-mth(tt-fin-doc.payer-code)).
    end.
    else 
    do:
      sw:write-data-element ("contr-name", if tt-fin-doc.receiver-name = ? then "" else string(tt-fin-doc.receiver-name)).
      sw:write-data-element ("contr-code", string-mth(tt-fin-doc.receiver-code)).
    end.
    sw:write-data-element ("doc-osn", if tt-fin-doc.naznach-plat = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.naznach-plat))).
    sw:write-data-element ("pril", xmlchar-encode-1c(tt-fin-doc.enclosure)).
    sw:write-data-element ("nds-str", if tt-fin-doc.including = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.including))).
    sw:write-data-element ("operator", if tt-fin-doc.user-name-doc = ? then "" else user-name(tt-fin-doc.user-name-doc)).
    sw:write-data-element ("idty-doc", if tt-fin-doc.payer-dop1 = ? then "" else xmlchar-encode-1c(string(tt-fin-doc.receiver-passport))).

    find first tt-fin-doc-attr no-lock where tt-fin-doc-attr.fin-doc = tt-fin-doc.fin-doc-code no-error .
    if available (tt-fin-doc-attr) then do:
       if     tt-fin-doc-attr.sumka ne ?
          and tt-fin-doc-attr.sumka ne ""
       then
          sw:write-data-element ("sumka", xmlchar-encode-1c(tt-fin-doc-attr.sumka)).
/*       if     tt-fin-doc-attr.banknote ne ?                                     */
/*          and tt-fin-doc-attr.banknote ne ""                                    */
/*       then                                                                     */
/*          sw:write-data-element ("banknote",  string(tt-fin-doc-attr.banknote)).*/
       if     tt-fin-doc-attr.bank-resive ne ?
          and tt-fin-doc-attr.bank-resive ne 0
       then do:
          for first ub.fin-bank no-lock where ub.fin-bank.host-code = tt-fin-doc.host-code and
                                               ub.fin-bank.code-bank = tt-fin-doc-attr.bank-resive:
          sw:write-data-element ("bank-resive",  string(ub.fin-bank.bik)).
          end.
       end.


/*       if     tt-fin-doc-attr.bank-deposit ne ?                                                     */
/*          and tt-fin-doc-attr.bank-deposit ne 0                                                     */
/*       then do:                                                                                     */
/*          for first ub.fin-bank no-lock where ub.fin-bank.host-code = tt-fin-doc.host-code and      */
/*                                               ub.fin-bank.code-bank = tt-fin-doc-attr.bank-deposit:*/
/*          sw:write-data-element ("bank-deposit", string(ub.fin-bank.bik)).                          */
/*          end.                                                                                      */
/*       end.                                                                                         */
/*       if     tt-fin-doc-attr.pin ne ?                                       */
/*          and tt-fin-doc-attr.pin ne ""                                      */
/*       then                                                                  */
/*          sw:write-data-element ("pin",  string(tt-fin-doc-attr.pin)).       */
       if     tt-fin-doc-attr.source_ ne ?
          and tt-fin-doc-attr.source_ ne ""
       then
          sw:write-data-element ("source",  string(tt-fin-doc-attr.source_)).
    end.
    
    find first tt-fin-doc-attr no-lock where tt-fin-doc-attr.fin-doc = tt-fin-doc.fin-doc-code no-error .
    if     available tt-fin-doc-attr
       and tt-fin-doc-attr.contr-kb ne ?
    then do:
       sw:write-data-element ("contr-kb",  tt-fin-doc-attr.contr-kb).
    end. 
    sw:start-element ("ndss") .
    for each tt-fin-doc-tax no-lock where tt-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code:
      sw:start-element ("nds") .
      sw:write-data-element ("sum", string-mth(tt-fin-doc-tax.sum-line-doc)).
      sw:write-data-element ("nds-code", string-mth(tt-fin-doc-tax.vat-pc)).
      sw:write-data-element ("sum-nds", string-mth(tt-fin-doc-tax.sum-vat-line-doc)).
      sw:end-element ("nds") .
    end.
   
    sw:end-element ("ndss")  .  
    sw:END-ELEMENT ("cash-doc") .  
    
  end method. /* end_of CrContentToSW */
  
  method private character string-mth (inValue as decimal):
    
    def var v-str as character no-undo.
    
    if inValue = ?
      then v-str = "0".
    
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
    else v-str = string (inValue).
    return v-str.
    
  end.
  
  method private character  user-name   (v-user-code as character):
    define variable v-user-name as character no-undo .
      
    define buffer buf_user-account for ub.user-account .
      
    find first buf_user-account no-lock
      where buf_user-account.user-id = v-user-code
      no-error .
    if not available buf_user-account
      then 
    do:
      assign
        v-user-name = string(v-user-code)
        .
    end.
    else 
    do:
      assign
        v-user-name = buf_user-account.nik
        .
    end.
    return v-user-name.
  end.    
end class.