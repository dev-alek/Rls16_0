block-level on error undo, throw.
/*

$Revision: 71d18cf8f6ea, 2244, rls $
$Author: druban $
$Date: Wed Dec 25 15:24:00 2019 +0300 $
$Workfile: r-km7.p $
$Archive: rep/r-km7.p $

сведения о показаниях счетчиков ККМ и выручке КМ-7

Автор: Комаров Иван Сергеевич
Дата создания: 06/30/10
Author: Ivan Komarov
Creation date: 06/30/10

Автор1: Белоусов Илья Александрович

*/

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


define variable vss-revision    as character no-undo initial "$Revision: 71d18cf8f6ea, 2244, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-km7.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-km7.p $":U .
define variable vss-description as character no-undo initial "сведения о показаниях счетчиков ККМ и выручке КМ-7".

define variable g#report-num              as integer              no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/getcntxt.i  def }
{ gbl/cur-time.i     }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ rep/km7xl.i        }
{ str/lib-trn.i      }
{ str/valddnst.i def }
{ gbl/cd-attr.i      }
{ cmp/abbr-nc.i      }
{ rep/reprumpr.i print-plain-text,print-printer,print-xlt }
{ rep/r-sym.i        }
{ rep/fmtcli.i       }
{ rep/torgconf.i     }


&glob format-km-gold "X(194)"

define TEMP-TABLE temp-str no-undo
  FIELD   cash-num        as integer
  FIELD   kkm-code-reg    as character
  FIELD   kkm-code-prod   as character
  FIELD   z-number        as integer
  FIELD   summ-begin      as character
  FIELD   summ-end        as character
  FIELD   obj-type        as character
  FIELD   obj-code        as integer
  FIELD   chk-date        as DATE
  FIELD   chk-time        as integer
  FIELD   shift           as integer
  INDEX pi  IS PRIMARY
        chk-date
        chk-time
/*
  INDEX pi  IS PRIMARY UNIQUE
        obj-type
        obj-code
        pay-desk
        chk-date
        shift
*/
.

define stream Out-Stream.

define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .
define buffer buf_chk-doc      FOR ub.chk-doc.
define buffer buf_chk-doc-pred FOR ub.chk-doc.
define buffer buf_chk-pay      FOR ub.chk-pay.
define buffer buf_firm         FOR ub.firm.
define buffer buf_obj-list     FOR obj-list.
DEFINE BUFFER buf_cash-desk    FOR ub.cash-desk.

define variable v-summ-begin    AS decimal no-undo.
define variable v-summ-end      AS decimal no-undo.
define variable v-summ-total    AS decimal no-undo.
define variable v-summ-return   AS decimal no-undo.


define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable v-kop           as integer               no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .

define variable Line            as character             no-undo .
define variable UndLine         as character             no-undo .
define variable empty-str09-10  as character             no-undo .
define variable empty-str09-12  as character             no-undo .
define variable empty-str09-14  as character             no-undo .
define variable empty-str20-8   as character             no-undo .
define variable empty-str15-5   as character             no-undo .
define variable empty-str15-9   as character             no-undo .
define variable empty-str15-11  as character             no-undo .
define variable empty-str15-13  as character             no-undo .

define variable v-boss          as character             no-undo .
define variable v-post          as character             no-undo .
define variable v-cashier       as character             no-undo .
define variable PropisSumAll    as character format "x(100)" no-undo .
define variable PropisSumAll-2  as character format "x(100)" no-undo .
define variable abbr            as character             no-undo .
define variable v-kkm-code-reg  as character             no-undo .
define variable v-kkm-code-prod as character             no-undo .
define variable v-par-code      as character             no-undo .
define variable v-par-type      as character             no-undo .
define variable v-outprncd      as character             no-undo .
define variable v-pril-kass     as character             no-undo .
define variable v-pril-kass1    as character             no-undo .
define variable v-pril-kass2    as character             no-undo .
define variable v-pril-kass_    as character             no-undo .
define variable v-z-num         as character             no-undo .

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

define FRAME km-frame
      sym1                    no-label format "X(1)"            space(0)
      temp-str.cash-num       no-label format "99999"           space(0)
      sym3                    no-label format "X(1)"            space(0)
      temp-str.kkm-code-prod  no-label format "X(16)"           space(0)
      sym2                    no-label format "X(1)"            space(0)
      temp-str.kkm-code-reg   no-label format "X(16)"           space(0)
      Sym4                    no-label format "X(1)"            space(0)
      temp-str.z-number       no-label format "9999999999"      space(0)
      sym5                    no-label format "X(1)"            space(0)
      empty-str15-5           no-label format "x(18)"           space(0)
      sym6                    no-label format "X(1)"            space(0)
      temp-str.summ-begin     no-label format "x(18)"           space(0)
      sym7                    no-label format "X(1)"            space(0)
      temp-str.summ-end       no-label format "x(18)"           space(0)
      sym8                    no-label format "X(1)"            space(0)
      empty-str20-8           no-label format "x(18)"           space(0)
      sym9                    no-label format "X(1)"            space(0)
      empty-str15-9           no-label format "x(11)"           space(0)
      sym10                   no-label format "X(1)"            space(0)
      empty-str09-10          no-label format "x(9)"            space(0)
      sym11                   no-label format "X(1)"            space(0)
      empty-str15-11          no-label format "x(11)"           space(0)
      sym12                   no-label format "X(1)"            space(0)
      empty-str09-12          no-label format "x(9)"            space(0)
      sym13                   no-label format "X(1)"            space(0)
      empty-str15-13          no-label format "x(11)"           space(0)
      sym14                   no-label format "X(1)"            space(0)
      empty-str09-14          no-label format "x(9)"            space(0)
      sym15                   no-label format "X(1)"            space(0)

     HEADER
"+---------------------------------------+----------+--------------------------------------------------------+------------------+-----------------------------------------------------------------+" skip
"|                Номер                  |Порядковый|                     Показания                          |                  |                   В том числе по отделам (секциям)              |" skip
"+-----+---------------------------------+номер кон-+------------------+-------------------------------------+                  +-----------+---------+-----------+---------+-----------+---------+" skip
"|     |       контрольно-кассовой       |трольного |                  |        суммирующих денежных         |                  |отдел(секция)_______ |отдел(секция)_______ |отдел(секция)_______ |" skip
"|     |             машины              |счетчика  |                  |              счетчиков              |      Выручка     +-----------+---------+-----------+---------+-----------+---------+" skip
"|     +----------------+----------------+ (отчета  |    контрольного  +------------------+------------------+     согласно     |           |Подтвер- |           |Подтвер- |           |Подтвер- |" skip
"|     |                |                |фискальной|     счетчика     |                  |                  |    показаниям    |  выручка  |ждаю.Под-|  выручка  |ждаю.Под-|  выручка  |ждаю.Под-|" skip
"|Кассы|                |                | памяти)  |      (отчета     |     на начало    |     на конец     |     счетчика     |  в сумме  |пись зав.|  в сумме  |пись зав.|  в сумме  |пись зав.|" skip
"|     | Производителя  |Регистрационный | на конец |     фискальной   |    рабочего дня  |   рабочего дня   |     в сумме,     |  руб.коп. |отделом  |  руб.коп. |отделом  |  руб.коп. |отделом  |" skip
"|     |                |                | рабочего |      памяти)     |      (смены)     |      (смены)     |     руб.коп.     |           |(секцией)|           |(секцией)|           |(секцией)|" skip
"|     |                |                |дня(смены)|                  |                  |                  |                  |           |         |           |         |           |         |" skip
"+-----+----------------+----------------+----------+------------------+------------------+------------------+------------------+-----------+---------+-----------+---------+-----------+---------+" skip
      with width {&DOS_CW_2} down stream-io no-box no-underline no-labels .

/* число прописью */
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr as character no-undo .

  run rep/wp-qnty.p ( input p-dec, output Pr ).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION. /* f-wp-qnty */



/* main block */
do on error undo, return error
   :
   run get-report-num  in parparentproc (output  g#report-num).
   output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
   output close.

   if session:set-wait-state("compiler") then.

   { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }
   run km7xl-init in this-procedure .
   { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */

   assign
     UndLine = fill("_", 230)
     Line    = fill("-", 230)
   .
   find first obj-list no-lock no-error.
   if not AVAILABLE obj-list THEN DO:
      RETURN.
   END.

   find first This_Object  WHERE This_Object.obj-type = obj-list.obj-type
                             AND This_Object.obj-code = obj-list.obj-code
                           no-lock.

   find first clients      WHERE clients.obj-type     = {&cmp}
                             AND clients.obj-code     = This_Object.host-code
                           no-lock.

   find first buf_firm where buf_firm.firm-code = clients.obj-code
                       no-lock
                       .

   /* по строкам документа */
   { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
   /* сначала заполняем таблицу */
   for each buf_cash-desk
      where buf_cash-desk.obj-code = This_Object.obj-code
      no-lock :
      { rep/km7.i }
   end.
   for each temp-str no-lock
         by temp-str.cash-num
         by temp-str.z-num
                     :
       assign v-z-num = (if v-z-num = "" then string(temp-str.z-num) else (v-z-num + "," + string(temp-str.z-num))).

   end.

   /* Шапка */
   run PrintTitul in this-procedure .

   /*на каждой странице */
   FORM with frame km-frame .

   /* тело */
   for each temp-str no-lock
         by temp-str.cash-num
         by temp-str.z-num
                     :
       run print-line in this-procedure .
   end.
   PUT STREAM Out-Stream
       Line format {&format-km-gold} .

   display stream Out-Stream
          "          ИТОГО" @ temp-str.summ-end
          "    X   "        @ empty-str09-10
          "    X   "        @ empty-str09-12
          sym8 sym9 sym10 sym11 sym12 sym13 sym14
   with FRAME km-frame.
   PUT STREAM Out-Stream
       "+------------------+-----------+---------+-----------+---------+-----------+"  AT 109 SKIP
   .

   /* Подвал */

   run PrintPodval in this-procedure .

   output stream Out-Stream CLOSE .
   { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
   run km7xl-close in this-procedure .

   define variable disabledoptions   as integer   no-undo .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   DisabledOptions = 8.
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
    if p-xls THEN DO:
      if p-report-id = "74/2070" then do:
        RUN reprumpr_print-xlt ( input p-dir-name
                                ,input '' /*нет печати по расписанию в XLt*/
                                ,input substitute("km-7_&1&2_&3&4&5_&6.xls"
                                                  , obj-list.obj-type
                                                  , obj-list.obj-code
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
      if p-report-id = "74/2070" then do:
        run reprumpr_print-plain-text in this-procedure ( input p-dir-name
                                                          ,input '' /*нет печати по расписанию в TXT*/
                                                          ,input substitute("km-7_&1&2_&3&4&5_&6.txt"
                                                                          , obj-list.obj-type
                                                                          , obj-list.obj-code
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
        , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input  ReportFontNum
        , output v-user-action
        , output v-printed
        ) .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  end.
end. /* main block */

/* *************************************************************************************************** */



procedure print-line :
  do on error undo, return error return-value :
     { rep/km71.i km-frame }
  end.
end procedure. /* print-line */



procedure PrintTitul :

define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
define variable v-object-addr   as character    no-undo.
define variable v-r-index       as integer      no-undo.
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
  assign v-pril-kass = "Z " + v-z-num + " от " + string(x-date-start) + "г".

  if length(v-pril-kass) > 18 then do:
    assign
    v-pril-kass1 = substring(v-pril-kass, 1, 18)
    v-pril-kass2 = substring(v-pril-kass, 19 )
    v-r-index = r-index(v-pril-kass1 , ",")
    .

    assign
    v-pril-kass_ = substring(v-pril-kass1, (v-r-index + 1))
    v-pril-kass1 = substring(v-pril-kass1, 1, v-r-index)
    v-pril-kass2 = v-pril-kass_ + v-pril-kass2
    .
  end.
  else do:
    assign v-pril-kass1 = v-pril-kass.
  end.

   /* Excel  */
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_organization}
       , input v-organization
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_object}
       , input v-object
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_OKPO}
       , input t-okpo
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_INN}
       , input t-inn
   ).

   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_docDate}
       , input string( today, "99/99/9999")
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_docTime}
       , input string( TIME, "HH:MM:SS")
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_pril_kass1}
       , input string( v-pril-kass1 )
   ).
   run km7xl-write-cell-data in this-procedure (
       input {&km7xl-h_pril_kass2}
       , input string( v-pril-kass2 )
   ).


   /* Text */
   PUT STREAM Out-Stream
                                                                                              "Унифицированная форма № КМ-7"          AT 158 skip
                                                                                              "Утверждена постановлением Госкомстата" AT 158 skip
                                                                                              "России от 25.12.98 г. № 132"           AT 158 skip
                                                                                                                 "+----------------+" AT 177 skip
                                                                                                                 "|      Код       |" AT 177 skip
                                                                                                                 "+----------------+" AT 177 skip
                                                                                                    "Форма по ОКУД|     0330107    |" AT 164 skip
       space(5) v-organization format "X(140)"                                                                   "+----------------+" AT 177 skip
       space(5) Line           format "X(140)"  "по {&abbr_okpo_allshift}" format "X(7)" AT 167 "|"  AT 177 t-okpo format "X(16)" "|" AT 194 skip
       space(30) "организация, адрес, номер телефона" format "X(120)"                                            "+----------------+" AT 177 skip

       space(5) v-object format "X(120)"                                    "{&abbr_inn_allshift}|" AT 174  t-INN format "X(15)"  "|" AT 194 skip
       space(5)                                                                           Line format  "X(140)"  "+----------------+" AT 177 skip
       space(35) "структурное подразделение" format "x(85)"                                 "Вид деятельности" AT 161 "| " AT 177 "|" AT 194 skip
                                                                                                                 "+----------------+" AT 177 skip
                                                                                    "Вид деятельности по ОКДП" AT 153 "| " AT 177 "|" AT 194 skip
                                                                                                                 "+----------------+" AT 177 skip
                                                                                                     "Вид операции|                |" AT 165 skip
                                                                                                                 "+----------------+" AT 177 skip
                            "+----------------+----------------+-----------------+" AT 101 "Приложение"   AT 158                             skip
                     "| Номер документа|Дата составления|Время составления|" AT 101 "к кассовым отчетам " AT 158
                                                     substitute("_&1&2", v-pril-kass1, fill("_", 17 - length(v-pril-kass1))) format "X(18)"  skip
                            "+----------------+----------------+-----------------+" AT 101 "(номер, дата)" AT 180 skip
                            "|"    AT 101
                     "|   " AT 118 STRING(TODAY, "99/99/9999") format "x(10)" AT 122 "|" AT 135 STRING(time,"HH:MM:SS") AT 138 "   |  " AT 150

                                               substitute("_&1&2", v-pril-kass2, fill("_", 35 - length(v-pril-kass2))) format "X(36)" AT 158 skip
       space(90) "СВЕДЕНИЯ" "+----------------+----------------+-----------------+" AT 101 skip
       space(64) "О ПОКАЗАНИЯХ СЧЕТЧИКОВ КОНТРОЛЬНО-КАССОВЫХ МАШИН И ВЫРУЧКЕ ОРГАНИЗАЦИИ"  skip
   .
END. /* do on error */
end procedure. /* PrintTitul */


procedure PrintPodval :
do on error undo, return error return-value  :

   run /*wp-rub.p*/ rep/wp-qnty.p ( TRUNCATE(v-summ-return,0), output PropisSumAll /*, output abbr*/ ).
   if PropisSumAll = ''
   Then PropisSumAll = 'Ноль'.
   ASSIGN
      v-kop = ABSOLUTE(INTEGER((v-summ-return - TRUNCATE(v-summ-return,0)) * 100))
   .

   define variable v-length       AS integer no-undo.
   define variable v-spase-pos-r  AS integer no-undo.
   define variable v-out-str      AS character no-undo EXTENT 2.
   define variable v-out-str-ex   AS character no-undo EXTENT 2.
   define variable o-head-position AS character no-undo.    /* Должность */
   define variable o-director     AS character no-undo.     /* кто указан в фин настройках */
   define variable v-head-position AS character no-undo.    /* Должность на русском */
   define variable v-director     AS character no-undo.     /* ФИО директора*/
   define variable o-cassir       as integer no-undo.       /* psn-code кассира */
   define variable v-cassir       as character no-undo.    /* ФИО кассира (если возможно - менеджера) */
   define buffer   buf_shop       FOR ub.shop.
   define buffer   buf_store      FOR ub.store.
   define buffer   buf_thbj-attr  FOR ub.thbj-attr.
   define buffer   buf_sysconf    FOR ub.sysconf.
   define buffer   buf_shift-staff FOR ub.shift-staff.
   
   

   v-out-str[1] =  PropisSumall + " {&abbr_rub}. " + STRING(v-kop,"99") + " {&abbr_kop}.".
   v-length = LENGTH(v-out-str[1]).
   if v-length > 110
   THEN DO:
      ASSIGN
         v-spase-pos-r   = R-INDEX(SUBSTRING(v-out-str[1], 1, 110)," ")
         v-out-str[2] = SUBSTRING(v-out-str[1], v-spase-pos-r + 1)
         v-out-str[1] = SUBSTRING(v-out-str[1], 1, v-spase-pos-r - 1)
      .
   END.

   v-out-str-ex[1] = PropisSumall.
   v-length = LENGTH(v-out-str-ex[1]).
   if v-length > 30
   THEN DO:
      ASSIGN
         v-spase-pos-r   = R-INDEX(SUBSTRING(v-out-str-ex[1], 1, 30)," ")
         v-out-str-ex[2] = SUBSTRING(v-out-str-ex[1], v-spase-pos-r + 1)
         v-out-str-ex[1] = SUBSTRING(v-out-str-ex[1], 1, v-spase-pos-r - 1)
      .
   END.

/* Взято из finfnoco.p, узнается фио и должность руководителя */
      define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
      mCashBook = new ibs.th.ref.cashbookstorage () .
      o-head-position = mCashBook:getSinglRule(0 /* tt-fin-doc.CashBookId */, This_Object.obj-type, This_Object.obj-code, "ManagerPosition") .
      o-director      = mCashBook:getSinglRule(0 /* tt-fin-doc.CashBookId */, This_Object.obj-type, This_Object.obj-code, "ManagerFIO") .
/*      o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .*/
      delete object mCashBook no-error .

      case o-head-position:
        when '1':U then do:
          v-head-position = "Директор".
        end.
        when '2':U then do:
          v-head-position = "Управляющий".
        end.
        when '0':U then do:
            for first buf_sysconf where buf_sysconf.host-code = This_Object.host-code:
            v-head-position = buf_sysconf.head-position.
            end.
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
        end.
      end case.
      
    for first buf_shift-staff
    where buf_shift-staff.obj-type    = {&shop}
      and buf_shift-staff.obj-code    = This_Object.obj-code
      and buf_shift-staff.shift-date  = x-date-start
      and buf_shift-staff.shift-num   = x-shift-alone
      and buf_shift-staff.staff-role  = yes
    :
        v-cassir = buf_shift-staff.name.  
    end.
    if v-cassir = "" then do:
        for first buf_shift-staff
    where buf_shift-staff.obj-type    = {&shop}
      and buf_shift-staff.obj-code    = This_Object.obj-code
      and buf_shift-staff.shift-date  = x-date-start
      and buf_shift-staff.shift-num   = x-shift-alone
    :
        v-cassir = buf_shift-staff.name.  
    end.
    end.
 
   
   /* Excel */
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-it_Summ}
       , input v-summ-total
   ).
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-it_s_Summ_2}
       , input v-out-str-ex[2]
   ).
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-it_s_Summ_1}
       , input v-out-str-ex[1]
   ).
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-f_post}
       , input v-head-position
   ).
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-f_boss}
       , input v-director
   ).
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-f_cashier}
       , input v-cassir
   ). 
   run km7xl-write-cell-data in this-procedure (
         input {&km7xl-it_kop}
       , input v-kop
   ).
end.
    
/*Подставим подчеркивания, если поля пустые*/
if v-head-position = "" then v-head-position = "____________________".
if v-director      = "" then v-director      = "_________________________".
if v-cassir        = "" then v-cassir        = "_________________________".

      
   /* TEXT */
   PAGE STREAM Out-Stream.
   PUT STREAM Out-Stream
       "Выдано покупателям (клиентам) по возвращенным ими чекам (ошибочно пробитым чекам) согласно акту в сумме " v-out-str[1] format "x(60)" Skip
       v-out-str[2]  format "x(180)" SKIP
       "Руководитель"
/*       UndLine format "X(20)" AT 15*/
       v-head-position format "X(20)" AT 15
       UndLine format "X(20)" AT 37
/*       UndLine format "X(25)" AT 59*/
       v-director format "X(30)" AT 59
       "Старший кассир" AT 90
       UndLine format "X(20)" AT 105
       v-cassir format "X(25)" AT 127 SKIP
       "(должность)" format "X(15)" AT 20  "(подпись)" format "X(10)" AT 42  "(расшифровка подписи)" format "X(25)" AT 61
       "(подпись)" format "X(10)" AT 110  "(расшифровка подписи)" format "X(25)" AT 129 SKIP
       "Печатать с оборотом. Подписи печатать на обороте." AT 120
   .

end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure. /* on-same-page */