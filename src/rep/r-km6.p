block-level on error undo, throw.
/*

$Revision: 71d18cf8f6ea, 2244, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:00 2019 +0300 $
$Workfile: r-km6.p $
$Archive: rep/r-km6.p $

сведения о показаниях счетчиков ККМ и выручке КМ-6

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

define temp-table tt-cash-desk no-undo like ub.cash-desk.

define input parameter parparentproc            as widget-handle           no-undo .
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

define input parameter p-plain-txt              as logical                 no-undo .
define input parameter p-xls                    as logical                 no-undo .
define input parameter p-dir-name               as character               no-undo .

define input parameter table for tt-cash-desk .

define variable vss-revision    as character no-undo initial "$Revision: 71d18cf8f6ea, 2244, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-km6.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-km6.p $":U .
define variable vss-description as character no-undo initial "сведения о показаниях счетчиков ККМ и выручке КМ-6".

define variable g#report-num              as integer              no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i     }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ str/lib-trn.i      }
{ str/valddnst.i def }
{ gbl/cd-attr.i      }
{ cmp/abbr-nc.i      }

{ rep/fmtcli.i       }
{ rep/torgconf.i     }
{ trg/factord.i  }
{ ref/fd-attr.i }
{ rep/reprumpr.i print-plain-text,print-printer,print-xlt }
{ rep/r-sym.i        }
{ rep/km6xl.i        }
{ rep/fostatok.i  &arh-name = "arh-fin-doc-schet-nal-obj" }
{ str/farh-def.i }
{ gbl/std-func.i }

{ gbl/getcntxt.i get }

&glob format-km-gold "X(183)"

define temp-table temp-str no-undo
   field cash-num        as integer
   field z-number        as integer
   field chk-num         as integer
   field zero-counter    as integer
   field summ-begin      as character
   field summ-end        as character
   field summ-sale       as decimal
   field summ-nal        as decimal
   field summ-return     as decimal
   field person          as character
   field chk-date        as date
   field chk-time        as integer
   field chk-time-1      as integer
   field chk-time-2      as integer
   field shift-date      as date
   field shift-num       as integer
   field chk-shift-open-time as logical /* используется в km6.i для условия заполнения chk-time-1 */
   
  INDEX pi  IS PRIMARY
        chk-date
        chk-time
        .

define stream Out-Stream.

define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .
define buffer buf_sale-clients for ub.clients .
define buffer buf_chk-pay      for ub.chk-pay.
define buffer buf_cash-desk    for ub.cash-desk.
define buffer buf_firm         for ub.firm.
define buffer buf_tt-cash-desk for tt-cash-desk.
define buffer buf_obj-list     for obj-list.
define buffer buf_z_chk-doc-pred for ub.chk-doc.
define buffer buf_z_chk-doc    for ub.chk-doc.
define buffer buf_chk-doc      for ub.chk-doc.
define buffer buf_fin-doc      for ub.fin-doc.
define buffer buf_arh-fin-doc-schet-nal-obj for ub.arh-fin-doc-schet-nal-obj .
define buffer buf_sysconf      for ub.sysconf.
define buffer buf_shift-cash   for ub.shift-cash.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-pay-attr for ub.chk-pay-attr.

define variable sum1-shift      as decimal initial 0     no-undo .
define variable sum2-shift      as decimal initial 0     no-undo .
define variable v-summ-total    as decimal initial 0     no-undo .
define variable v-summ-return   as decimal initial 0     no-undo .
define variable v-sum-begin     as decimal initial 0     no-undo .
define variable v-sum-end       as decimal initial 0     no-undo .
define variable Fact-order-1    like ub.stk-tot.Fact-order no-undo.
define variable Fact-order-2    like ub.stk-tot.Fact-order no-undo.
define variable v-pko-num       as character             no-undo .
define variable v-pko-date      as date                  no-undo .
DEFINE VARIABLE v-fin-doc-shift-name-num AS CHARACTER NO-UNDO.

define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable v-kop           as integer               no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .

define variable Line            as character             no-undo .
define variable UndLine         as character             no-undo .
define variable empty-str09-2   as character             no-undo .
define variable empty-str09-3   as character             no-undo .
define variable empty-str09-10  as character             no-undo .
define variable v-person        as character             no-undo .

define variable v-boss          as character             no-undo .
define variable v-post          as character             no-undo .
define variable v-cashier       as character             no-undo .
define variable PropisSumAll    as character             no-undo .
define variable PropisSumAll-2  as character             no-undo .
define variable v-kkm-code-reg  as character             no-undo .
define variable v-kkm-code-prod as character             no-undo .
define variable v-kkm-model     as character             no-undo .
define variable v-kkm-type      as character             no-undo .
define variable v-kkm-programm  as character             no-undo .
define variable v-outprncd      as character             no-undo .
define variable v-kkm-num       as character             no-undo .

define variable v-par-code      as character             no-undo .
define variable v-par-type      as character             no-undo .
define variable v-base-code     as integer               no-undo .
define variable v-curr-r-b      as character             no-undo .
define variable v-PrintTitul    as integer               no-undo .
define variable sheet-list      as character             no-undo .
define variable sheet-list-copy-from   as character      no-undo .
define variable v-start         as logical   initial yes no-undo .
define variable v-obj-code      as integer               no-undo .
define variable v-is-cash-list as character no-undo. /* Список кодов оплаты наличными */
define variable v-itogo-sum-sale as decimal no-undo.
define variable v-itogo-sum as decimal no-undo.
define variable v-itogo-nal as decimal no-undo.
define variable v-i as integer no-undo.
define variable v-ii as integer no-undo.
define variable v-txt-1 as character no-undo.
define variable v-txt-2 as character no-undo.

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

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */

run get-report-num  in parparentproc (output  g#report-num).
{ gbl/basecode.i
    v-cntxt-host-code-obj
    v-base-code
}
 { gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} and v-base-code <> 0 then printrubl = no .

 for each temp-str :
    delete temp-str.
 end.

define FRAME km-frame
      sym1                    no-label format "X(1)"            space(0)
      temp-str.z-number       no-label format "9999999999"      space(0)

      sym2                    no-label format "X(1)"            space(0)
      empty-str09-2           no-label format "X(8)"            space(0)

      sym3                    no-label format "X(1)"            space(0)
      empty-str09-3           no-label format "X(8)"            space(0)

      Sym4                    no-label format "X(1)"            space(0)
      temp-str.zero-counter   no-label format ">>>>>>>>>>>>>>>" space(0)

      sym5                    no-label format "X(1)"            space(0)
      temp-str.summ-begin     no-label format "x(15)"           space(0)

      sym6                    no-label format "X(1)"            space(0)
      temp-str.summ-end       no-label format "x(15)"           space(0)

      sym7                    no-label format "X(1)"            space(0)
      temp-str.summ-sale      no-label format "->>>,>>>,>>9.99" space(0)

      sym8                    no-label format "X(1)"            space(0)
      temp-str.summ-return    no-label format "->>>,>>>,>>9.99" space(0)

      sym9                    no-label format "X(1)"            space(0)
      temp-str.person         no-label format "x(18)"           space(0)

      sym10                   no-label format "X(1)"            space(0)
      empty-str09-10          no-label format "x(7)"            space(0)

      sym11                   no-label format "X(1)"            space(0)

     HEADER
"+----------+-----------------+-----------------------------------------------+-------------------------------+--------------------------+" skip
"|Порядковый|                 |                                               |                               |    Заведующий отделом    |" skip
"|номер кон-|       Номер     |                     Показания                 |       Сумма, руб. коп.        |          (секцией)       |" skip
"|трольного +--------+--------+---------------+---------------+---------------+---------------+---------------+------------------+-------+" skip
"|счетчика  |        |        | контрольного  |     суммирующего денежного    |               |               |                  |       |" skip
"|(отчета   |        |        |счетчика (отче-|            счетчика           |               |     денег     |                  |       |" skip
"|фискальной|        |        |та фискальной  +---------------+---------------+  выручки за   |  возвращенная |                  |       |" skip
"|памяти)   |        |        |памяти),   ре- |               |               | рабочий день  |  покупателям  |      фамилия     |       |" skip
"|на конец  | отдела | секции |гистрирующего  |   на начало   |   на конец    |    (смену)    | (клиентам) по |        и.,о      |подпись|" skip
"|рабочего  |        |        |количество пе- | рабочего дня  | рабочего дня  |  по счетчику  | неиспользован-|                  |       |" skip
"|дня       |        |        |реводов сумми- |   (смены)     |    (смены)    |               |  ным кассовым |                  |       |" skip
"|(смены)   |        |        |рующих счетчи- |               |               |               |     чекам     |                  |       |" skip
"|          |        |        |ков на нули    |               |               |               |               |                  |       |" skip
"+----------+--------+--------+---------------+---------------+---------------+---------------+---------------+------------------+-------+" skip
  with width {&DOS_CW_2} down stream-io no-box no-underline no-labels .

/* число прописью */
FUNCTION f-wp-qnty returns character ( input p-dec as decimal ) :
  define variable pr as character no-undo .
  define variable abbr as character no-undo.

  
  run rep/wp-rub.p ( input p-dec, output Pr, output abbr).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION. /* f-wp-qnty */
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_fin-doc FOR ub.fin-doc, OUTPUT v-fin-doc-shift-name-num AS character)  FORWARD.

/* main block */
do on error undo, return error
   :

   if session:set-wait-state("compiler") then.

/* Получим список кодов наличной оплаты */
for each buf_cash-pay where buf_cash-pay.is-cash:
    v-is-cash-list = v-is-cash-list + string(buf_cash-pay.cdpay-code) + ','.
end.

/* Теперь заполняем таблицу */

for each buf_obj-list
  no-lock:
   assign
      v-obj-code = buf_obj-list.obj-code
   .
  for each tt-cash-desk  no-lock
     where tt-cash-desk.obj-code = buf_obj-list.obj-code
  break
  by tt-cash-desk.db-num
  by tt-cash-desk.obj-code
  by tt-cash-desk.pos-type
  by tt-cash-desk.cash-num
    :
      /* по строкам документа */
      { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

      /* сначала заполняем таблицу */
      { rep/km6.i }
    if not can-find(first temp-str where temp-str.cash-num = tt-cash-desk.cash-num) then next.
    assign
      sheet-list = sheet-list + (if sheet-list = '' then '' else {&comma-char}) + substitute("ККМ&1", tt-cash-desk.cash-num)
      sheet-list-copy-from = sheet-list-copy-from + (if sheet-list-copy-from = '' then '' else {&comma-char}) + "Template"
    .
  end.
end.
find first temp-str no-error.
if not available temp-str then do:
  &scop my-message "Не было чеков за выбранный период!!"
  if p-batch > 0 then do:
    {&display-message}.
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input p-report-id
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
    RETURN.
  end.
  else do:
    {&display-message}.
    return.
  end.
end.

{ cmp/open-out.i STREAM Out-Stream " " }
for each tt-cash-desk
      no-lock by tt-cash-desk.cash-num
      :
  if session:set-wait-state("compiler") then.

    if not can-find(first temp-str where temp-str.cash-num = tt-cash-desk.cash-num) then next.
    run km6xl-init in this-procedure (
                                       input v-start
                                      ,input substitute("ККМ&1", tt-cash-desk.cash-num)
                                      ,input sheet-list
                                      ,input sheet-list-copy-from
                                      ).
    v-start = no.

   assign
      UndLine = fill("_", 137)
      Line    = fill("-", 137)
      sum2-shift = 0
      v-PrintTitul = 0
      v-boss            = ""
      PropisSumAll      = ""
      PropisSumAll-2    = ""
      v-kkm-code-reg    = ""
      v-kkm-code-prod   = ""
      v-kkm-model       = ""
      v-kkm-type        = ""
    .


   FIND FIRST buf_cash-desk WHERE buf_cash-desk.cash-num = tt-cash-desk.cash-num
                              AND buf_cash-desk.db-num   = tt-cash-desk.db-num
                              AND buf_cash-desk.obj-code = tt-cash-desk.obj-code
                              AND buf_cash-desk.pos-type = tt-cash-desk.pos-type
                            NO-LOCK
                            NO-ERROR
                            .
   FIND first This_Object  WHERE This_Object.obj-type = {&shop}
                       AND This_Object.obj-code = tt-cash-desk.obj-code
                     NO-LOCK.
   FIND first ub.clients  WHERE ub.clients.obj-type   = {&cmp}
                       AND ub.clients.obj-code     = This_Object.host-code
                     NO-LOCK.

   find first buf_firm where buf_firm.firm-code = ub.clients.obj-code
                       no-lock
                       .
   assign
      v-boss          = buf_firm.director
      v-kkm-code-reg  = buf_cash-desk.registration-code
      v-kkm-code-prod = buf_cash-desk.serial-code
      v-kkm-model     = buf_cash-desk.fr-type
      v-kkm-programm  = (if tt-cash-desk.pos-type = {&cd-type-ibm-xml}
                         or tt-cash-desk.pos-type = {&cd-type-ibm}
                        then  (if tt-cash-desk.cash-os = "LINUX"
                                then "UniFO-L V 4.0.K"
                                else "UniFO-IBS V 4.0.K" )
                        else '')
   .

   /*на каждой странице */
   form with frame km-frame .

   /* по строкам документа */
   { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

   assign
   v-itogo-sum = 0
   v-itogo-sum-sale = 0
   v-itogo-nal = 0.
   
   for each temp-str no-lock
      where temp-str.cash-num = tt-cash-desk.cash-num
         by temp-str.z-number
                     :
   if v-PrintTitul = 0 then do:
   /* Шапка */
        run PrintTitul in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)).
      assign v-PrintTitul = 1.
   end.
   /* тело */
      run print-line in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)).
      v-itogo-sum-sale = v-itogo-sum-sale + temp-str.summ-sale.
      v-itogo-sum = v-itogo-sum + temp-str.summ-sale - temp-str.summ-return.
      v-itogo-nal = v-itogo-nal + temp-str.summ-nal - temp-str.summ-return.
   end.
/*   PUT STREAM Out-Stream              */
/*       Line format {&format-km-gold} .*/
       
   display stream Out-Stream
          "          ИТОГО" @ temp-str.summ-end
          sym7 sym8 sym9
          v-itogo-sum-sale @ temp-str.summ-sale
          sum2-shift @ temp-str.summ-return
   with FRAME km-frame.
   PUT STREAM Out-Stream
       "+---------------+---------------+"  AT 78 SKIP
   .

   /* Подвал */
   run on-same-page in this-procedure (input 10) .

   run PrintPodval in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)).
   page stream Out-Stream .
end.

   output stream Out-Stream CLOSE .
   { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
   run km6xl-close in this-procedure .

   define variable disabledoptions as integer   no-undo .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   DisabledOptions = 7.
   ReportFontNum = 7.
  if p-batch > 0 then do:
    /*сразу печатаем на принтер проверка на q-print внутри*/
    run reprumpr_print-printer in this-procedure ( input ReportFontNum /*font*/
                                                  ,input 0 /*flags*/
                                                  ) no-error.
    if error-status:error then do:
      &scop my-message "Печать на принтер завершилась ошибкой..."
      {&display-message}.
    end.
    IF p-xls THEN DO:
      if p-report-id = "73/2069" then do:
        RUN reprumpr_print-xlt ( input p-dir-name
                                ,input '' /*нет печати по расписанию в XLt*/
                                ,input substitute("km-6_&1&2_&3&4&5_&6.xls"
                                                  , {&shop}
                                                  , v-obj-code
                                                  , string(year(X-date-end), "9999")
                                                  , string(month(X-date-end), "99")
                                                  , string(day(X-date-end), "99")
                                                  , X-shift-end)
                                ,input DisabledOptions /*p-disable-option*/
                                ,input ReportFontNum /*p-font-number*/
                                  ) .
      end.
      if error-status:error then do:
        &scop my-message return-value
        {&display-message}.
      end.
    END.
    if p-plain-txt then do:
      if p-report-id = "73/2069" then do:
        run reprumpr_print-plain-text in this-procedure ( input p-dir-name
                                                          ,input '' /*нет печати по расписанию в TXT*/
                                                          ,input substitute("km-6_&1&2_&3&4&5_&6.txt"
                                                                          , {&shop}
                                                                          , v-obj-code
                                                                          , string(year(X-date-end), "9999")
                                                                          , string(month(X-date-end), "99")
                                                                          , string(day(X-date-end), "99")
                                                                          , X-shift-end)
                                                          ,input DisabledOptions /*p-disable-option*/
                                                          ,input ReportFontNum /*p-font-number*/
                                                          ) no-error.
      end.
      if error-status:error then do:
        &scop my-message return-value
        {&display-message}.
      end.
    end.
  end.
  else do:
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   os-rename
     value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
     value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
   .
    run gbl/prnfilen.w
        ( input  ""
        , input  DisabledOptions
                        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
                        , input ReportFontNum
                        , output v-user-action
                        , output v-printed
                        ) .
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  end.
end. /* main block */

/* *************************************************************************************************** */



procedure print-line :
  do on error undo, return error return-value :
     define input parameter p-sheet-name as character no-undo .
     { rep/km61.i km-frame }
  end.
end procedure. /* print-line */



procedure PrintTitul :
define input parameter p-sheet-name as character no-undo .

define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
define variable v-object-addr   as character    no-undo.
define variable v-shift-name    as character    no-undo.

do on error undo, return error return-value  :
   /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
   for each thbjattr_thbj-attr :
       if thbjattr_thbj-attr.prop-code = {&attr-prt-glob_outprncd} then v-outprncd  = string( thbjattr_thbj-attr.property-value-logical) .
   end.

   { rep/r-cliprp.i }

  Case This_Object.obj-type :
    when {&shop} then do:
      find first ub.shop
      where ub.shop.obj-code = This_Object.obj-code
        no-error.
        if available ub.shop then do:
          assign v-object-addr = ub.shop.addres1.
        end.
    end.
    when {&stock} then do:
      find first ub.store
      where ub.store.obj-code = This_Object.obj-code
        no-error.
        if available ub.store then do:
          assign v-object-addr = ub.store.addres1.
        end.
    end.
  end case.
  if x-tog-shift then do:
    assign v-shift-name = substitute("№&1 от &2", string(x-shift-alone), string(x-date-start)) .
  end.

  if v-outprncd = "yes" then
  do:
   assign
      v-organization = string( CAPS( ub.clients.obj-name )  + " (" + string(ub.clients.obj-code) + ") " ) + t-addres + " " + t-phone
      v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ") " ) + v-object-addr
   .
  end.
  else do:
    assign
      v-organization = string( CAPS( ub.clients.obj-name ) ) + " " + t-addres + " " + t-phone
      v-object       = string( CAPS( This_Object.obj-name ) ) + " " + v-object-addr
    .
  end.

   assign
       v-kkm-num = "(" + trim(string(temp-str.cash-num)) + ")"
   .

   /* Excel */
   v-ii = num-entries(v-organization, " ") + 1.
   if v-ii = 1 then /* Если в v-organization содержится одно огромное слово > 87 символов, то ничего не переносим на другую строку. */
   do:
     v-txt-1 = v-organization.
   end.
   else
   do:
     if length(v-organization) > 78 then
     do:
       do v-i = 1 to v-ii + 1:
         v-txt-1 = v-txt-1 + (if v-txt-1 = "" then "" else " ") + entry(v-i, v-organization, " ").
         if length(v-txt-1) + 1 + length(entry((v-i + 1), v-organization, " ")) > 78 then /* поместится-ли с текущими блоками - следующий (+1)? Если нет, то оставляем текущие в v-txt-1 */
         do:
           leave.
         end.
       end.
       v-txt-2 = substring(v-organization, length(v-txt-1) + 2).
     end.
     else
       do:
         v-txt-1 = v-organization.
       end.
   end.

   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_organization}
                       )
       , input /*v-organization*/ v-txt-1
   ).

   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_organization2}
                       )
       , input v-txt-2
   ).

   /* Сброс, иначе, для очередной Кассы (кол-во Касс может меняться) - будут циклические вычисления! */
   v-txt-1 = "".
   v-txt-2 = "".

   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_object}
                       )
       , input v-object
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_Docdate}
                       )
       , input string(x-date-start, "99/99/9999")
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_DocTime1}
                       )
       , input string( temp-str.chk-time-1, "HH:MM:SS")
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_DocTime2}
                       )
       , input string( temp-str.chk-time-2, "HH:MM:SS")
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_descname}
                       )
       , input SUBSTITUTE((if v-kkm-model = "" then "&2"
                                               else "&1, &2"),
                          v-kkm-model, v-kkm-num)
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_KKM_prog}
                       )
       , input v-kkm-programm
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_KKM_reg}
                       )
       , input v-kkm-code-reg
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_KKM_prod}
                       )
       , input v-kkm-code-prod
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_OKPO}
                       )
       , input t-okpo
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_INN}
                       )
       , input t-inn
   ).
   run km6xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-h_shift}
                       )
       , input v-shift-name
   ).

   /* Text */
   PUT STREAM Out-Stream
                                                                                      "Унифицированная форма N КМ-6"              AT 100 skip
                                                                                      "Утверждена постановлением Госкомстата"     AT 100 skip
                                                                                      "России от 25.12.98 г. N 132      "         AT 100 skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                                                         "|      Код       |"     AT 120 skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                                            "Форма по ОКУД|     0330106    |"     AT 107 skip
       space(5) v-organization format "X(100)"                                                           "+----------------+"     AT 120 skip
       space(5) UndLine      format "X(100)" "по {&abbr_okpo_allshift}" format "X(7)" AT 113 "|" AT 120 t-okpo format "X(16)" "|" AT 137 skip
       space(35) "организация, адрес, номер телефона" format "X(80)"                                     "+----------------+"     AT 120 skip
       space(5) v-object format "X(100)" "{&abbr_inn_allshift}| " AT 117                                t-INN format "X(15)"  "|" AT 137 skip
       space(5) UndLine format  "X(80)"                                                                  "+----------------+"     AT 120 skip
       space(35) "структурное подразделение" format "x(45)"                                              "|                |"     AT 120 skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                       "Вид деятельности по ОКДП"  AT 96 "| "      AT 120 "|"     AT 137 skip
                                                                     "+----------------+----------------+"                        AT 103 skip
      "Контрольно-кассовая машина " v-kkm-model v-kkm-num
                                                               "Номер | производителя  |"     AT 97 v-kkm-code-prod format "x(16)" "|"  skip
                                                                     "+----------------+----------------+"                        AT 103 skip
       substitute("Прикладная программа___&1&2", v-kkm-programm, fill("_", 32 - length(v-kkm-programm) )) format "X(55)"
                                                                     "| регистрационный|"     AT 103 v-kkm-code-reg format "x(16)" "|"   skip
                                                                     "+----------------+----------------+"                        AT 103 skip
                                                                                                   "Кассир|                |"     AT 114 skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                              "Смена|" AT 115 v-shift-name format "X(16)" "|"            skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                                             "Вид операции|                |"     AT 108 skip
                                                                                                         "+----------------+"     AT 120 skip
                                                                     "+-------------+----------------+-------------------------+" AT 80  skip
                                                                     "|    Номер    |      Дата      |   Время работы, ч. мин  |" AT 80  skip
                                                                     "|  документа  |   составления  |      с     |     по     |" AT 80  skip
                                                                     "+-------------+----------------+------------+------------+" AT 80  skip
 space(54) "СПРАВКА-ОТЧЕТ"                              "|" AT 80 "|" AT 94 x-date-start AT 98 "|" AT 111 STRING(temp-str.chk-time-1,"HH:MM:SS") AT 114
                                                                                               "|" AT 124 STRING(temp-str.chk-time-2,"HH:MM:SS") AT 127
                                                                                                                              "|" AT 137 skip
 space(49) "КАССИРА-ОПЕРАЦИОНИСТА"                                   "+-------------+----------------+------------+------------+" AT 80  skip
   .

END. /* do on error */
end procedure. /* PrintTitul */

procedure PrintPodval :
do on error undo, return error return-value  :

   define input parameter p-sheet-name AS character no-undo .
   define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
   define variable o-head-position     AS character no-undo.     /* Должность */
   define variable o-director          AS character no-undo.     /* кто указан в фин настройках */
   define variable v-head-position     AS character no-undo.     /* Должность на русском */
   define variable v-director          AS character no-undo.     /* ФИО директора*/
   define variable o-cassir            AS integer no-undo.       /* psn-code старшего кассира */
   define variable v-cassir            AS character no-undo.     /* ФИО старшего кассира*/
   define variable o-cassir-op         AS integer no-undo.       /* psn-code кассира-операциониста */
   define variable v-cassir-op         AS character no-undo.     /* ФИО кассира-операциониста*/
   define buffer   buf_shop            FOR ub.shop.
   define buffer   buf_store           FOR ub.store.
   define buffer   buf_thbj-attr       FOR ub.thbj-attr.
   define buffer   buf_sysconf         FOR ub.sysconf.
   define buffer   buf_shift-staff     FOR ub.shift-staff.
   
/* Взято из finfnoco.p, узнается фио и должность руководителя */

      
      
      
   
      
    for first buf_shift-staff
    where buf_shift-staff.obj-type    = {&shop}
      and buf_shift-staff.obj-code    = This_Object.obj-code
      and buf_shift-staff.shift-date  = x-date-start
      and buf_shift-staff.shift-num   = x-shift-alone
      and buf_shift-staff.staff-role  = yes
    :
        v-cassir = buf_shift-staff.name.  
    end.
    
    if v-cassir = "" 
    then do:
       for first buf_shift-staff
       where buf_shift-staff.obj-type    = {&shop}
       and buf_shift-staff.obj-code    = This_Object.obj-code
       and buf_shift-staff.shift-date  = x-date-start
       and buf_shift-staff.shift-num   = x-shift-alone
       and buf_shift-staff.staff-role  = no
       :
           v-cassir = buf_shift-staff.name.  
       end.
    end.
    
    for last buf_shift-staff
       where buf_shift-staff.obj-type    = {&shop}
       and buf_shift-staff.obj-code    = This_Object.obj-code
       and buf_shift-staff.shift-date  = x-date-start
       and buf_shift-staff.shift-num   = x-shift-alone
       and buf_shift-staff.staff-role  = no
       :
          v-cassir-op = buf_shift-staff.name.  
    end.

    if v-cassir = v-cassir-op then v-cassir-op = "".

      run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-f_cashier}
                       )
       , input v-cassir-op
   ).   
   
      run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-f_senior_cashier}
                       )
       , input v-cassir
   ).            

   /* Добавил 21.01.2015г Арн. (Обращение Заказчика за №16448) - было: не отобр суммы в Ексель, а только на экране. */
   run km6xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-it_Summ}
                       )
       , input v-itogo-sum-sale
   ).

   run km6xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-it_Summ_return}
                       )
       , input sum2-shift
   ).

   assign v-pko-num = "" .
    run fostatok in this-procedure (
         input   This_Object.host-code
        ,input   This_Object.obj-code
        ,input   This_Object.obj-type
        ,input   x-tog-shift
        ,input   x-date-start - 1
        ,input   date('')
        ,input   X-shift-alone
        ,input   X-shift-alone
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   0
        ,output  v-sum-begin
        ,output  Fact-order-1)
        no-error .
    run fostatok in this-procedure (
         input   This_Object.host-code
        ,input   This_Object.obj-code
        ,input   This_Object.obj-type
        ,input   x-tog-shift
        ,input   x-date-start
        ,input   x-date-start
        ,input   X-shift-alone
        ,input   X-shift-alone
        ,input   yes /*xTog-obj*/
        ,input   0 /*p-curr-code*/
        ,input   0
        ,output  v-sum-end
        ,output  Fact-order-2)
        no-error .

        for each buf_arh-fin-doc-schet-nal-obj no-lock
        where buf_arh-fin-doc-schet-nal-obj.host-code         = This_Object.host-code
          and buf_arh-fin-doc-schet-nal-obj.obj-type          = This_Object.obj-type
          and buf_arh-fin-doc-schet-nal-obj.obj-code          = This_Object.obj-code
          and buf_arh-fin-doc-schet-nal-obj.cli-type          = {&cmp}
          and buf_arh-fin-doc-schet-nal-obj.cli-code          = This_Object.host-code
          and buf_arh-fin-doc-schet-nal-obj.fin-code-acc      = 0
          and buf_arh-fin-doc-schet-nal-obj.curr-code         = 0
          and buf_arh-fin-doc-schet-nal-obj.fin-ext-doc-type  = "":U
          and buf_arh-fin-doc-schet-nal-obj.calc-curr-code    = 0
          and buf_arh-fin-doc-schet-nal-obj.sum-type          = (if x-tog-shift then {&arh-fin-doc-schet-nal-obj-shift-obj} else {&arh-fin-doc-schet-nal-obj-obj} )
          and buf_arh-fin-doc-schet-nal-obj.fact-order       > fact-order-1
          and buf_arh-fin-doc-schet-nal-obj.fact-order       <= fact-order-2
          and x-date-start = ( if x-tog-shift then buf_arh-fin-doc-schet-nal-obj.shift-date else buf_arh-fin-doc-schet-nal-obj.fact-date )   /*в 15-0 поля shift-date нет */
           use-index pi :
          find first buf_fin-doc
                  where buf_fin-doc.host-code         = This_Object.host-code
                    and buf_fin-doc.fin-doc-code      = buf_arh-fin-doc-schet-nal-obj.fin-doc-code
                    and buf_fin-doc.obj-type          = This_Object.obj-type
                    and buf_fin-doc.obj-code          = This_Object.obj-code
                    and buf_fin-doc.status_           = {&fact}
                    and buf_fin-doc.fin-ext-doc-type = {&income-cash}
                  no-error.
                  if available buf_fin-doc then do :
                    mCashBook = new ibs.th.ref.cashbookstorage () .
      
                    o-head-position = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "ManagerPosition") .
                    o-director      = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "ManagerFIO") .
                    
                    delete object mCashBook no-error .
                     
                    case o-head-position:
                      when '0':U then do:
                        for first buf_sysconf no-lock where buf_sysconf.host-code = This_Object.host-code :
                          v-head-position = buf_sysconf.head-position.
                        end.
                      end.
                      when '1':U then do:
                        v-head-position = "Директор" .
                      end.  
                      otherwise do :
                        v-head-position = "Управляющий" .
                      end.
                    end case.
                    case o-director:
                      when '1':U then do:
                        if This_Object.obj-type = {&shop} then do:
                          find first buf_shop no-lock where
                                    buf_shop.obj-code = This_Object.obj-code no-error .
                          if available buf_shop then do:
                            v-director = buf_shop.director.
                          end.
                        end.
                        if This_Object.obj-type = {&stock} then do:
                          find first buf_store no-lock where
                                    buf_store.obj-code = This_Object.obj-code no-error .
                          if available buf_store then do:
                            v-director = buf_store.store-boss.
                          end.
                        end.
                      end. /*when 'dir_obj' then do:*/
                      when '0':U then do:
                        v-director = buf_firm.director.
                      end .
                    end case.
                    find first buf_sysconf no-lock
                          where buf_sysconf.host-code = This_Object.host-code
                          no-error.
                      if available buf_sysconf
                      and buf_fin-doc.payer-type = buf_sysconf.sale-type
                      and buf_fin-doc.payer-code = buf_sysconf.sale-code
                      then do:   /*контрагент-реализация*/

                      if v-pko-num = "" then 
                      do :
                        assign 
                          v-pko-num = buf_fin-doc.prn-doc-code .
                      end.
                      else 
                      do :
                        assign 
                          v-pko-num = v-pko-num + "," + buf_fin-doc.prn-doc-code .
                      end.
                          v-pko-date = get-shift(BUFFER buf_fin-doc, OUTPUT v-fin-doc-shift-name-num) .
                    end.
                  end.
    end.

   /* TEXT */
   
   PUT STREAM Out-Stream
       "Итого выручка в сумме " f-wp-qnty(v-itogo-nal) format "X(82)"  skip
/*       STRING(PropisSumall + " {&abbr_rub}. " + STRING(v-kop,"99") + " {&abbr_kop}.", "x(150)") format "x(150)" SKIP*/
       "Принята и оприходована по кассе," SKIP
       'по приходному кассовому ордеру № __' substitute("___&1&2", v-pko-num, fill("_", 32 - length(v-pko-num) )) format "X(35)"
   .

   /* Добавил 21.01.2015г Арн. (Обращение Заказчика за №16448) - было: не отобр суммы в Ексель, а только на экране. */
   run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-f_post}
                       )
       , input v-head-position
   ).      
   
         run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-f_boss}
                       )
       , input v-director
   ). 
   
   run km6xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-it_s_Summ_1}
                       )
       , input f-wp-qnty(v-itogo-nal)
   ).

   if v-pko-date <> ? then do :
      PUT STREAM Out-Stream
          ' от "' string(Day(v-pko-date)) format "x(2)" '" '
          substitute("__&1&2", MonthNameRusGen(Month(v-pko-date)), fill("_", 9 - length(string(MonthNameRusGen(Month(v-pko-date)))) )) format "x(11)" ' '
          string(Year(v-pko-date)) format "x(4)" ' г.' skip
      .

    /* Excel */
 
      run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-f-day-date}
                          )
          , input Day(v-pko-date)
      ).
      run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-f-month-date}
                          )
          , input MonthNameRusGen(Month(v-pko-date))
      ).
      run km6xl-write-cell-data in this-procedure (
            input substitute("&1_&2"
                          , p-sheet-name
                          , {&km6xl-f-year-date}
                          )
          , input Year(v-pko-date)
      ).
   end.
   else do :
      PUT STREAM Out-Stream
          ' от ' '"___"___________ _______ г.' SKIP
          .
   end.
   
   /*Подставим подчеркивания, если поля пустые*/
if v-head-position = "" then v-head-position = UndLine.
if v-director      = "" then v-director      = UndLine.
if v-cassir        = "" then v-cassir        = UndLine.
if v-cassir-op     = "" then v-cassir-op     = UndLine.

   PUT STREAM Out-Stream
       "Сдана в банк ________________________________________________________________________________" SKIP
       '___________________________________________________________________ "___"___________ _______ ' SKIP
       'Квитанция №__________________ от "___"___________ _______ г.' SKIP
       "" SKIP
       space(5) "Старший кассир"
                                            UndLine format "X(20)" AT 39 v-cassir format "X(35)" AT 70 skip
                                            "(подпись)" format "X(25)" AT 44 "(расшифровка подписи)" format "X(25)" AT 73 skip
       space(5) "Кассир-операционист"
                                            UndLine format "X(20)" AT 39 v-cassir-op format "X(35)" AT 70 skip
                                            "(подпись)" format "X(20)" AT 44 "(расшифровка подписи)" format "X(25)" AT 73 skip
       space(5) "Руководитель"
       v-head-position format "X(15)" AT 21 UndLine format "X(20)" AT 39 v-director format "X(35)" AT 70 skip
       "(должность)" format "X(15)" AT 21   "(подпись)" format "X(20)" AT 44 "(расшифровка подписи)" format "X(25)" AT 73 skip
/*       "" skip                                                       */
/*       "" skip                                                       */
/*       "Печатать с оборотом. Подписи печатать на обороте." AT 65 skip*/
   .
     /*Excel*/

   run km6xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                       , p-sheet-name
                       , {&km6xl-f-pko-num}
                       )
       , input v-pko-num
   ).


end.
end procedure. /* PrintPodval */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-shift Dialog-Frame
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_fin-doc FOR ub.fin-doc, OUTPUT p-shift-name-num AS CHARACTER) :
define variable v-fin-doc-shift-name-num as character no-undo.
define variable v-fin-doc-shift-name as character no-undo .
IF buf_fin-doc.shift-date = ? THEN DO:
   RETURN ?.
END.
 { str/shiftnam.i
     buf_fin-doc.obj-type
     buf_fin-doc.obj-code
     buf_fin-doc.shift-date
     buf_fin-doc.shift-num
     v-fin-doc-shift-name
     v-fin-doc-shift-name-num
     no-error
  }

ASSIGN
p-shift-name-num = v-fin-doc-shift-name-num
 .
RETURN buf_fin-doc.shift-date.   /* Function return value. */

END FUNCTION.

PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure. /* on-same-page */