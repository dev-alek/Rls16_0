block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-km3.p $
$Archive: rep/r-km3.p $

сведения о показаниях счетчиков ККМ и выручке КМ-3

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

Автор1: Белоусов Илья Александрович

*/

define temp-table tt-cash-desk no-undo like ub.cash-desk.
/* параметры должны быть НАВЕРХУ!!!!*/
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
DEFINE INPUT PARAMETER p-date                   as date                    no-undo .
define input parameter is-doc                   as logical                 no-undo .
define input parameter p-plain-txt              as logical                 no-undo .
define input parameter p-xls                    as logical                 no-undo .
define input parameter p-dir-name               as character               no-undo .
DEFINE INPUT PARAMETER TABLE FOR tt-cash-desk .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-km3.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-km3.p $":U .
define variable vss-description as character no-undo initial "сведения о показаниях счетчиков ККМ и выручке КМ-3".

define variable g#report-num              as integer              no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/prn-lib.i      }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i     }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ str/lib-trn.i      }
{ gbl/cd-attr.i      }
{ cmp/abbr-nc.i      }

/*{ gbl/getsect.i  def }*/
{ gbl/chk-entr.i }
{ rep/reprumpr.i print-plain-text,print-printer,print-xlt }

{ rep/km3xl.i    }

{ str/shftnmef.i chk-doc shift-name}
{ rep/fmtcli.i       }
{ rep/torgconf.i }

&glob format-km "X(103)"
&glob format-km-rep "X(123)"
&Scop fld_delim ":!:!:!:":U
&Scop fld_01        "Номер! по !пор-!ядку"
&Scop fld_02        " ! Наименование ! отдела, секции ! "
&Scop fld_03        " ! Дата  ! смены ! "
&Scop fld_04        " ! Номер ! смены ! "
&Scop fld_05        " ! Номер ! кассы ! "
&Scop fld_06        " ! Номер ! чека !"
&Scop fld_07        " ! сумма чека ! {&abbr_rub}. {&abbr_kop}. ! "
&Scop fld_08        " Должность, ! фамилия, и., о. лица, ! разрешившего возврат ! денег по чеку "

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


run get-report-num  in parparentproc (output  g#report-num).

DEFINE TEMP-TABLE temp-str no-undo
  FIELD   num-pos        as INTEGER
  FIELD   section-name    as CHARACTER
  FIELD   shift-num       as integer
  FIELD   chk-num         as INTEGER
  FIELD   cash-num        as INTEGER
  FIELD   chk-tot         as DECIMAL
  FIELD   person          as CHARACTER
  field   obj-code        as integer
  field   chk-date        as date
  field   shift-date      as date
  INDEX pi  IS PRIMARY
        num-pos cash-num chk-num
  index irep /*нужен для моды ОТЧЕТ*/
  obj-code
  chk-date
  cash-num
  index irepshift /*нужен для моды ОТЧЕТ*/
  obj-code
  shift-date
  shift-num
  cash-num
  chk-num
.

define stream macr_excel .
define stream Out-Stream.

define buffer buf_clients      for ub.clients .
define buffer buf_person       for ub.person .
define buffer This_Object      for ub.clients .
define buffer buf_chk-doc      FOR ub.chk-doc.
define buffer buf_chk-doc-pred FOR ub.chk-doc.
define buffer buf_chk-pay      FOR ub.chk-pay.
DEFINE BUFFER buf_cash-desk    FOR ub.cash-desk.
define buffer buf_chk-gds      FOR ub.chk-gds.
define buffer buf_goods        FOR ub.goods.
define buffer buf_bar-code     FOR ub.bar-code.
define buffer buf_temp-str     FOR temp-str.
define buffer buf_sysconf      FOR ub.sysconf.
define buffer buf_firm         for ub.firm.
define buffer buf_shop         for ub.shop .
define buffer buf_store        for ub.store .
define buffer buf_obj-list     for obj-list .
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_shift-staff   for ub.shift-staff.


define variable sum2-shift      as decimal initial 0     no-undo .

define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable v-kop           as integer               no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .

define variable Line            as character             no-undo .
define variable UndLine         as character             no-undo .
define variable sym1            as character initial ":" no-undo .
define variable sym2            as character initial ":" no-undo .
define variable sym3            as character initial ":" no-undo .
define variable sym4            as character initial ":" no-undo .
define variable sym5            as character initial ":" no-undo .
define variable sym6            as character initial ":" no-undo .
define variable sym7            as character initial ":" no-undo .
define variable sym8            as character initial ":" no-undo .
define variable sym9            as character initial ":" no-undo .

define variable f-num-pos       as character             no-undo .
define variable f-section-name  as character             no-undo .
define variable f-shift-date    as character             no-undo .
define variable f-cash-num      as character             no-undo .
define variable f-shift-num     as character             no-undo .
define variable f-chk-num       as character             no-undo .
define variable f-chk-tot       as character             no-undo .
define variable f-person        as character             no-undo .

define variable v-boss          as character             no-undo .
define variable v-post          as character             no-undo .
define variable v-cashier       as character             no-undo .
define variable v-cashier-op    as character             no-undo .
define variable PropisSumAll    as character             no-undo .
define variable PropisSumAll-2  as character             no-undo .
define variable v-kkm-code-reg  as character             no-undo .
define variable v-kkm-code-prod as character             no-undo .
define variable v-kkm-model     as character             no-undo .
define variable v-kkm-type      as character             no-undo .
define variable v-outprncd      as character             no-undo .
define variable v-outR          as character             no-undo .
define variable v-director      as character             no-undo .
define variable v-sys-key       as character             no-undo .
define variable sheet-list      as character             no-undo .
define variable sheet-list-copy-from   as character      no-undo .
define variable v-start         as logical   initial yes no-undo .


define variable v-chk-tot      as decimal   no-undo.
define variable v-counter      as integer   no-undo initial 1.
define variable v-person       as character no-undo.
define variable v-have-petrol  as logical   no-undo initial no.
define variable v-have-pieces  as logical   no-undo initial no.
define variable v-have-servise as logical   no-undo initial no.
define variable v-is-pieces    as logical   no-undo initial no.
define variable v-is-petrol    as logical   no-undo initial no.
define variable igoods         as logical   no-undo initial no.

define variable v-par-code      as character             no-undo .
define variable v-par-type      as character             no-undo .
define variable v-file-name       as character no-undo .
define variable v-file-name-ind   as integer   no-undo .
define variable v-obj-type        as character no-undo .
define variable v-obj-code        as integer no-undo init -1.



  if is-doc then do :

    DEFINE FRAME km-frame-akt
          sym1                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.num-pos        column-label {&fld_01}:C5  format ">>>>>9"          space(0)

          sym2                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.section-name   column-label {&fld_02}:C30 format "X(30)"           space(0)

          sym3                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.shift-num      column-label {&fld_04}:C9  format "9999999"         space(0)

          Sym4                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.chk-num        column-label {&fld_06}:C7  format "9999999"         space(0)

          sym5                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.chk-tot        column-label {&fld_07}:C15 format "->>>,>>>,>>9.99" space(0)

          sym6                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.person         column-label {&fld_08}:C27 format "X(27)"           space(0)

          sym7                    column-label {&fld_delim}  format "X(1)"            space(0)

     HEADER
      Line format {&format-km} AT 1
      with width {&A4_CW0} down stream-io use-text NO-BOX.

  end.
  else do :
    assign
      v-file-name     = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
      v-file-name-ind = 1
    .
      DEFINE FRAME km-frame-rep

          sym1                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.num-pos        column-label {&fld_01}:C5  format ">>>>>9"          space(0)

          sym2                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.section-name   column-label {&fld_02}:C30 format "X(30)"           space(0)

          sym3                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.shift-date     column-label {&fld_03}:C10 format "99/99/9999"      space(0)

          sym4                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.shift-num      column-label {&fld_04}:C7  format "9999999"         space(0)

          Sym5                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.cash-num       column-label {&fld_05}:C7  format "9999999"         space(0)

          Sym6                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.chk-num        column-label {&fld_06}:C7  format "9999999"         space(0)

          sym7                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.chk-tot        column-label {&fld_07}:C15 format "->>>,>>>,>>9.99" space(0)

          sym8                    column-label {&fld_delim}  format "X(1)"            space(0)
          temp-str.person         column-label {&fld_08}:C30 format "x(30)"           space(0)

          sym9                    column-label {&fld_delim}  format "X(1)"            space(0)

        HEADER
          string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
          string( " , " ) format "X(3)" string(TIME, "HH:MM")
          string( "Страница" ) AT 105 PAGE-NUMBER( out-stream ) AT 115 FORMAT ">>>>9" SKIP

          Line format {&format-km-rep} AT 1
          with width {&DOS_CW} down stream-io use-text NO-BOX.

    assign
      sheetf.sheet-num = 1
      sheetf.Excel-Column-Lable = "Номер по порядку"                         + {&comma-char} +
                                  "Наименование отдела\секции"               + {&comma-char} +
                                  "Дата смены"                               + {&comma-char} +
                                  "Номер смены"                              + {&comma-char} +
                                  "Номер кассы"                              + {&comma-char} +
                                  "Номер чека"                               + {&comma-char} +
                                  "Сумма чека руб. коп."                     + {&comma-char} +
                                  "Должность\Ф.И.О. лица разрешившего возврат по чеку"
      sheetf.Sizes       = "8,30,10,7,6,8,12,30"
      Sheetf.ColFOrmat   = "1=@;2=@;3=dd/mm/yyyy;4=@;5=@;6=@;7=0.00;8=@"
      Make-excel = p-xls
      Make-excel-com = false
      .
      run rep/extitle.p ( 1 ).
  end.

/* число прописью */
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr   as character no-undo .
  define variable abbr as character no-undo .

  run rep/wp-rub.p ( input p-dec, output pr, output abbr ) .
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION. /* f-wp-qnty */

{ rep/repfrm.i def }   /* Показать окно информации о текущем процессе */

/* main block */
do on error undo, return error
   :

for each temp-str:
  delete temp-str.
end.

/*сколько будет актов надо знать ЗАРАНЕЕ!! поэтому СНАЧАЛА СОБИРАЕМ ВСЕ ДАННЫЕ*/
for each buf_obj-list
  no-lock :
for each tt-cash-desk  no-lock
       where tt-cash-desk.obj-code = buf_obj-list.obj-code
break
by tt-cash-desk.db-num
by tt-cash-desk.obj-code
by tt-cash-desk.pos-type
by tt-cash-desk.cash-num
  :


  /*на каждой странице */
  if session:set-wait-state("compiler") then.
  if p-batch > 0 then do:
    if p-report-id = "72/2068" then do:
    if first-of(tt-cash-desk.obj-code) then do:
        if v-obj-code = -1 then do:
          assign
          v-obj-type = {&shop}
          v-obj-code = tt-cash-desk.obj-code.
        end.
        else do:
          assign
          v-obj-type = ''
          v-obj-code = 0
          .
        end.
      end. /*if first-ohf(tt-cash-desk.obj-code) then do:*/
    end. /*if p-profile-id = 72 then do:*/
  end.
  if first-of(tt-cash-desk.obj-code) then do:
    /*проходим по всем возможным чекам - все равно индекса нет по номеру кассы в 15.0*/

    /* по строкам документа */
    { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

    /* сначала заполняем таблицу */
    { rep/km3.i }
  end.
  if not can-find(first temp-str where temp-str.cash-num = tt-cash-desk.cash-num) then next.
  assign
  sheet-list = sheet-list + (if sheet-list = '' then '' else {&comma-char}) + substitute("ККМ&1", tt-cash-desk.cash-num)
  sheet-list-copy-from = sheet-list-copy-from + (if sheet-list-copy-from = '' then '' else {&comma-char}) + "Template"
  .
end.
end.
find first temp-str no-error.
if not available temp-str then do:
  &scop my-message "Не было возвратов за выбранный период!!"
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
    if is-doc then do:
      {&display-message}.
      return.
    end.
  end.
end.

   { cmp/open-out.i STREAM Out-Stream " " "{&CS_PS}" }

/*Печать шапки отчета*/
if not is-doc then do :
  run PrintTitulReport in this-procedure.
end.

 for each tt-cash-desk  no-lock
by tt-cash-desk.db-num
by tt-cash-desk.obj-code
by tt-cash-desk.pos-type
by tt-cash-desk.cash-num
   :
  if session:set-wait-state("compiler") then.


  if not can-find(first temp-str where temp-str.cash-num = tt-cash-desk.cash-num) then next.

 assign
    v-boss            = ""
    v-post            = ""
    v-cashier         = ""
    PropisSumAll      = ""
    PropisSumAll-2    = ""
    v-kkm-code-reg    = ""
    v-kkm-code-prod   = ""
    v-kkm-model       = ""
    v-kkm-type        = ""
    v-outprncd        = ""
    v-outR            = ""
    v-director        = ""
    v-sys-key         = ""
  .


  if is-doc then do:
     ASSIGN
      sum2-shift    = 0
      Lines_Counter = 0
      .
  end.
  if is-doc then do:
    run km3xl-init in this-procedure (
                                          input v-start
                                          ,input substitute("ККМ&1", tt-cash-desk.cash-num)
                                          ,input sheet-list
                                          ,input sheet-list-copy-from
                                          ).
    v-start = no.
   assign
     UndLine = fill("_", 106)
     Line    = fill("-", 106)
   .

    FIND FIRST buf_cash-desk
        WHERE buf_cash-desk.cash-num = tt-cash-desk.cash-num
                               AND buf_cash-desk.db-num   = tt-cash-desk.db-num
                               AND buf_cash-desk.obj-code = tt-cash-desk.obj-code
                               AND buf_cash-desk.pos-type = tt-cash-desk.pos-type
          NO-LOCK NO-ERROR .

    FIND    This_Object
      WHERE This_Object.obj-type = {&shop}
                       AND This_Object.obj-code = tt-cash-desk.obj-code
                     NO-LOCK.

    FIND    ub.clients
      WHERE ub.clients.obj-type     = {&cmp}
        AND ub.clients.obj-code     = This_Object.host-code
                     NO-LOCK.

   /* Шапка */
    run PrintTitul in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)).
   /*на каждой странице */
    FORM with frame km-frame-akt .
   /* по строкам документа */
   { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
   /* тело */
    for each temp-str no-lock where
    temp-str.cash-num = tt-cash-desk.cash-num
                     /*break by {&Sort-pole}*/
                     :
      run print-line in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)
                                        ,input is-doc
                                          ).
   end.
   Put stream Out-Stream Line format {&format-km} SKIP.
   display stream Out-Stream
            "    ИТОГО" @ temp-str.chk-num /*f-chk-num*/
            sum2-shift  @ temp-str.chk-tot /*f-chk-tot*/
          sym5 sym6
    with FRAME km-frame-akt.
   Put stream Out-Stream "+---------------+" /*format "x(17)"*/ AT 59 SKIP.
   /* Подвал */
    run on-same-page in this-procedure (input 18) .
    run PrintPodval in this-procedure (input substitute("ККМ&1", tt-cash-desk.cash-num)).
    hide frame km-frame-akt.
    PAGE stream out-stream.
  end. /*if is-doc then do :*/
  else do:
    assign
    v-start = no
    UndLine = fill("_", 125)
    Line    = fill("-", 125)
    .
    /* по строкам документа */
    { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */


    /* тело */
    for each temp-str no-lock
       where temp-str.cash-num = tt-cash-desk.cash-num
         and temp-str.obj-code = tt-cash-desk.obj-code
                      use-index irepshift
                      break by temp-str.shift-date by temp-str.shift-num by temp-str.cash-num by temp-str.chk-num
                      :
      run print-line in this-procedure ( input substitute("ККМ&1", tt-cash-desk.cash-num)
                                        ,input is-doc
                                          ).
    end.
    hide frame km-frame-rep.
  end.
end.

if is-doc then do:
  run km3xl-close in this-procedure .
end.
else do:
    {&PutExcel}
      "Итого:"  {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation} {&tabulation}
      sum2-shift
    .
    Put stream Out-Stream Line format {&format-km-rep} SKIP.
  Display stream Out-Stream
          "    ИТОГО" @ temp-str.chk-num
          sum2-shift  @ temp-str.chk-tot
          sym7 sym8
    with FRAME km-frame-rep.

 {&closeexcel}
end.

output stream out-stream close.

{ gbl/stopwork.i }

{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
    output stream Out-Stream CLOSE .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable v-orient-page as character no-undo .
  define variable disabledoptions   as integer   no-undo .


  if is-doc then do:
    assign
      DisabledOptions = 0
      ReportFontNum = 7
    .
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
        if p-report-id = "72/2068" then do:
          RUN reprumpr_print-xlt ( input p-dir-name
                                  ,input '' /*нет печати по расписанию в XLt*/
                                  ,input substitute("km-3_&1&2_&3&4&5_&6.xls"
                                                    , v-obj-type
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
        if p-report-id = "72/2068" then do:
          run reprumpr_print-plain-text in this-procedure ( input p-dir-name
                                                            ,input '' /*нет печати по расписанию в TXT*/
                                                            ,input substitute("km-3_&1&2_&3&4&5_&6.txt"
                                                                            , v-obj-type
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
          , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
          , input  ReportFontNum
          , output v-user-action
          , output v-printed
          ) .
    end.
  end. /*if is-doc then do:*/
  else do:
    run gbl/prnfilen.w
        (  input  ""
          ,input  DisabledOptions
          ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
          ,input  reportFontNum
          ,output v-user-action
          ,output v-printed
        ) .

    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  end. /*else if is-doc*/
end. /* main block */

/* *************************************************************************************************** */

procedure print-line :
define input parameter p-sheet-name as character no-undo .
define input parameter p-is-doc as logical no-undo .
  do on error undo, return error return-value :
    if p-is-doc then do :
     { rep/km31.i km-frame-akt is-doc }
    end.
    else do :
     { rep/km31.i km-frame-rep }
    end.
  end.
end procedure. /* print-line */

/* *************************************************************************************************** */


procedure PrintTitul :
define input parameter p-sheet-name as character no-undo .
define variable v-organization  as character no-undo.
define variable v-object        as character no-undo.
define variable v-kkm-code-prod as character no-undo .
define variable v-kkm-code-reg  as character no-undo .
define variable v-kkm-programm  as character no-undo .
define variable v-kkm-num       as character no-undo .
define variable v-par-type      as character no-undo .

do on error undo, return error return-value  :
   /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */

   { gbl/getsect.i run "''"  0 {&attr-prt-glob} }
   for each thbjattr_thbj-attr :
       if thbjattr_thbj-attr.prop-code = {&attr-prt-glob_outprncd} then v-outprncd  = string( thbjattr_thbj-attr.property-value-logical) .
   end.
   { gbl/getsect.i run "''"  0 {&attr-prt-obj} }
   for each thbjattr_thbj-attr :
       if thbjattr_thbj-attr.prop-code = {&attr-prt-obj_outR}      then v-outR      = string( thbjattr_thbj-attr.property-value-character) .
   end.

   /*Руководитель*/
   if v-outR = "no_print"
      then do:
         assign
            v-torgconf-main-boss = ""
            v-torgconf-main-boss-post = ""
         .
      end.
   if v-outR = "ruk_firm"
      then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = This_Object.host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-main-boss-post = buf_sysconf.head-position /*должность*/
            .
         end.
         find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
         and buf_clients.obj-code = This_Object.host-code
         .
         find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
         no-error.
         if available buf_firm
         then do:
            assign
               v-torgconf-main-boss = buf_firm.director           /*Фамилия*/
            .
         end.
      end.
   if v-outR = "dir_obj"
      then do:
         CASE This_Object.obj-type:
         WHEN {&shop}
         THEN DO:
            find first buf_shop no-lock
            where buf_shop.obj-code = This_Object.obj-code
            .
            assign
               v-torgconf-main-boss = buf_shop.director
            .
         END.

         WHEN {&stock}
         THEN DO:
            find first buf_store no-lock
            where buf_store.obj-code = This_Object.obj-code
            .
            assign
               v-torgconf-main-boss = buf_store.store-boss
            .
         END.
         OTHERWISE DO:
            assign
               v-torgconf-main-boss       = "":U
            .
         END.
         END CASE.
   end.
   assign v-director = v-torgconf-main-boss .
   { gbl/currsysk.i
      v-sys-key
      no-error
    }
  { rep/r-cliprp.i }
  if v-outprncd = "yes" then
    do:
      assign
      v-organization = string( CAPS( clients.obj-name )     + " (" + string(clients.obj-code) + ")" )
       v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
      .
    end.
    else do :
      assign
       v-organization = string( CAPS( ub.clients.obj-name ) )
       v-object       = string( CAPS( This_Object.obj-name ) )
       .
    end.

  if check-entry-with-mask( v-sys-key, "Pskov":U, {&comma-char} ) = true then do:
    find first ub.cli-grp where ub.cli-grp.node-code = This_object.grp-code
                          no-lock
                          no-error
                          .
         if available ub.cli-grp then do :
          assign v-object =  ub.cli-grp.node-name + " " + v-object .
         end.
    end.

  FIND FIRST buf_cash-desk WHERE buf_cash-desk.cash-num = tt-cash-desk.cash-num
                    AND buf_cash-desk.obj-code = This_Object.obj-code
                    AND Buf_cash-desk.db-num   = This_Object.db-num
                  NO-LOCK
                  NO-ERROR
                  .
   assign
    v-kkm-code-reg  = buf_cash-desk.registration-code
    v-kkm-code-prod = buf_cash-desk.serial-code
    v-kkm-model = buf_cash-desk.fr-type
    v-kkm-programm = (if tt-cash-desk.pos-type = {&cd-type-ibm-xml}
                      or tt-cash-desk.pos-type = {&cd-type-ibm}
                      then  (if tt-cash-desk.cash-os = "LINUX"
                              then "UniFO-L V 4.0.K"
                              else "UniFO-IBS V 4.0.K" )
                      else '')
    v-kkm-num = "(" + trim(string(tt-cash-desk.cash-num)) + ")"

   .


    /* Excel */
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                        , p-sheet-name
                        , {&km3xl-h_organization}
                        )
       , input v-organization
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-h_object}
                       )
       , input v-object
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                        , p-sheet-name
                        ,{&km3xl-h_docDate}
                        )
       , input string( p-date, "99/99/9999")
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                        , p-sheet-name
                        ,{&km3xl-h_OKPO}
                        )
       , input t-okpo
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                        , p-sheet-name
                        ,{&km3xl-h_INN}
                        )
       , input t-inn
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                        , p-sheet-name
                        ,{&km3xl-h_descname}
                        )
       , input (v-kkm-model + " " + v-kkm-num)
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-h_KKM_reg}
                       )
       , input v-kkm-code-reg
   ).
   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-h_KKM_prod}
                       )
       , input v-kkm-code-prod
   ).

   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-h_KKM_programm}
                       )
       , input v-kkm-programm
   ).

   find first buf_shop no-lock
        where buf_shop.obj-code = This_Object.obj-code no-error.
   if available buf_shop then do :
     v-post = entry(2,buf_shop.acct,"|") no-error.
     v-boss = entry(1,buf_shop.acct,"|") no-error.
   end.

   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-f_post}
                       )
       , input v-post
   ).

   run km3xl-write-cell-data in this-procedure (
       input substitute("&1_&2"
                       , p-sheet-name
                       ,{&km3xl-f_boss}
                       )
       , input v-boss
   ).


   /* Text */
   PUT STREAM Out-Stream
       "Унифицированная форма N КМ-3"              AT 68 skip
       "Утверждена постановлением Госкомстата"     AT 68 skip
       "России от 25.12.98 г. N 132      "         AT 68 skip
       "+----------------+"                        AT 86 skip
       "|      Код       |"                        AT 86 skip
       "+----------------+"                        AT 86 skip
       "Форма по ОКУД|     0330107    |"           AT 73 skip
       space(4) v-organization format "X(80)" "+----------------+" AT 86 skip
       space(4) Line           format "X(73)" "по {&abbr_okpo_allshift}" format "X(7)" AT 79 "|" AT 86 t-okpo format "X(16)" "|" AT 103 skip
       space(34) "организация" format "X(50)" "+----------------+" AT 86 skip

       space(4) v-object format "X(75)" "{&abbr_inn_allshift}|" AT 83  t-INN format "X(15)"  "|" AT 103 skip
       space(4) Line format  "X(70)"  "+----------------+" AT 86 skip
       space(34) "структурное подразделение" format "x(30)"                                "|                |" AT 86 skip
                                       "+----------------+" AT 86 skip
        "Вид деятельности" AT 70 "| " AT 86 "|" AT 103 skip
       "+----------------+----------------+"                         AT 69 skip
       "Контрольно-кассовая машина " v-kkm-model " " v-kkm-num  "| производителя  |" AT 69  v-kkm-code-prod format "x(16)" "|" AT 103 skip
       "+----------------+----------------+"                         AT 69 skip
       substitute("Прикладная программа___&1&2", v-kkm-programm, fill("_", 32 - length(v-kkm-programm) )) format "X(55)"
       "| регистрационный|" AT 69
       v-kkm-code-reg format "x(16)" "|"  AT 103 skip
       "+----------------+----------------+"                         AT 69 skip
       "Вид деятельности по ОКДП" AT 62 "| " AT 86 "|" AT 103 skip
                   "+----------------+"      AT 86 skip
             "Кассир|                |"      AT 80 skip
                   "+----------------+"      AT 86 skip
       "Вид операции|                |"      AT 74 skip
       "+----------------+----------------+" AT 46                    "+----------------+"      AT 86 skip
       "| Номер документа|Дата составления|" AT 46    "РУКОВОДИТЕЛЬ" AT 86 skip
       "+----------------+----------------+" AT 46 skip
       space(25) "АКТ" "|" AT 46 "|" AT 63 STRING(p-date, "99/99/9999") FORMAT "x(10)" AT 65 "|" AT 80 (if trim(v-post) = "" then "_____________________" else v-post) FORMAT "x(21)" AT 83 skip
       space(5) "О ВОЗВРАТЕ ДЕНЕЖНЫХ СУММ ПОКУПАТЕЛЯМ"  "+----------------+----------------+" AT 46  "должность" AT 86 skip
       space(5) "(КЛИЕНТАМ) ПО НЕИСПОЛЬЗОВАННЫМ КАССОВЫМ ЧЕКАМ" "_______" AT 83 (if trim(v-boss) = "" then "______________" else v-boss) FORMAT "x(14)" AT 92 SKIP
       space(5) "(в том числе по ошибочно пробитым кассовым чекам)" "подпись    расшифровка" AT 83 SKIP
       space(5)  "Настоящий акт составлен комиссией, которая установила:" "___ _______ ____г." AT 86 SKIP
   .
END. /* do on error */
end procedure. /* PrintTitul */
/*----------------*/
Procedure PrintTitulReport :

   PUT stream Out-Stream unformatted
   ReportName       skip
   " "              skip
   str1             skip
   str3             skip
   str4             skip
   ReportHeader     skip
   .

end procedure .
/*----------------*/
procedure PrintPodval :
define input parameter p-sheet-name as character no-undo .

do on error undo, return error return-value  :

   run rep/wp-qnty.p ( TRUNCATE(sum2-shift,0), output PropisSumall).
   if PropisSumAll = ''
   Then PropisSumAll = 'Ноль'.
   ASSIGN
      v-kop = ABSOLUTE(INTEGER((sum2-shift - TRUNCATE(sum2-shift,0)) * 100))
   .

   DEFINE VARIABLE v-length       AS INTEGER NO-UNDO.
   DEFINE VARIABLE v-spase-pos-r  AS INTEGER NO-UNDO.
   DEFINE VARIABLE v-out-str      AS CHARACTER NO-UNDO EXTENT 2.
   DEFINE VARIABLE v-out-str-ex   AS CHARACTER NO-UNDO EXTENT 2.

   v-out-str[1] = "на сумму " + PropisSumall + " {&abbr_rub}. " + STRING(v-kop,"99") + " {&abbr_kop}.".
   v-length = LENGTH(v-out-str[1]).
   IF v-length > 100
   THEN DO:
      ASSIGN
         v-spase-pos-r   = R-INDEX(SUBSTRING(v-out-str[1], 1, 100)," ")
         v-out-str[2] = SUBSTRING(v-out-str[1], v-spase-pos-r + 1)
         v-out-str[1] = SUBSTRING(v-out-str[1], 1, v-spase-pos-r - 1)
      .
   END.
   v-out-str-ex[1] = PropisSumall.
   v-length = LENGTH(v-out-str-ex[1]).
   IF v-length > 40
   THEN DO:
      ASSIGN
         v-spase-pos-r   = R-INDEX(SUBSTRING(v-out-str-ex[1], 1, 40)," ")
         v-out-str-ex[2] = SUBSTRING(v-out-str-ex[1], v-spase-pos-r + 1)
         v-out-str-ex[1] = SUBSTRING(v-out-str-ex[1], 1, v-spase-pos-r - 1)
      .
   END.

   for first buf_shift-staff
    where buf_shift-staff.obj-type    = {&shop}
      and buf_shift-staff.obj-code    = This_Object.obj-code
      and buf_shift-staff.shift-date  = x-date-start
      and buf_shift-staff.shift-num   = x-shift-alone
      and buf_shift-staff.staff-role  = yes
    :
        v-cashier = buf_shift-staff.name.
    end.

    if v-cashier = ""
    then do:
       for first buf_shift-staff
       where buf_shift-staff.obj-type    = {&shop}
       and buf_shift-staff.obj-code    = This_Object.obj-code
       and buf_shift-staff.shift-date  = x-date-start
       and buf_shift-staff.shift-num   = x-shift-alone
       and buf_shift-staff.staff-role  = no
       :
           v-cashier = buf_shift-staff.name.
       end.
    end.

    for last buf_shift-staff
       where buf_shift-staff.obj-type    = {&shop}
       and buf_shift-staff.obj-code    = This_Object.obj-code
       and buf_shift-staff.shift-date  = x-date-start
       and buf_shift-staff.shift-num   = x-shift-alone
       and buf_shift-staff.staff-role  = no
       :
          v-cashier-op = buf_shift-staff.name.
    end.

    if v-cashier = v-cashier-op then v-cashier-op = "".

   /* Excel */
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                          , p-sheet-name
                          ,{&km3xl-it_Summ}
                          )
       , input sum2-shift
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                          ,p-sheet-name
                          ,{&km3xl-it_s_Summ_1}
                          )
       , input v-out-str-ex[1]
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                           , p-sheet-name
                           ,{&km3xl-it_s_Summ_2}
                           )
       , input v-out-str-ex[2]
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                         , p-sheet-name
                         ,{&km3xl-it_kop}
                         )
       , input v-kop
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                         , p-sheet-name
                         ,{&km3xl-it_dir}
                         )
       , input v-director
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                         , p-sheet-name
                         ,{&km3xl-f_cashier}
                         )
       , input v-cashier
   ).
   run km3xl-write-cell-data in this-procedure (
         input substitute("&1_&2"
                         , p-sheet-name
                         ,{&km3xl-f_cashier_op}
                         )
       , input v-cashier-op
   ).
   PUT STREAM Out-Stream
       space(5) "Выдано покупателям (клиентам) по возвращенным ими чекам (ошибочно пробитым чекам) согласно акту" Skip
       space(5) v-out-str[1] FORMAT {&format-km} skip
       space(5) v-out-str[2] FORMAT {&format-km} skip
       space(5) "На указанную сумму следует уменьшить выручку кассы." skip(1)
       space(5) "Перечисленные   возвращенные   покупателями   (клиентами) чеки  (ошибочно  пробитые  чеки)" skip
       space(5) "погашены и прилагаются к акту. Приложение __________________________." skip
       space(5) "Члены комиссии:" skip
       space(5) "Заведующий отделом (секцией)"  v-director AT 80 format "X(25)"
       UndLine format "X(25)" AT 40 UndLine format "X(35)" AT 70 skip
       "(подпись)" format "X(25)" AT 48 "(расшифровка подписи)" format "X(25)" AT 78 skip

       "Старший кассир" AT 6
       UndLine format "X(25)" AT 40 UndLine format "X(35)" AT 70 skip
       "(подпись)" format "X(25)" AT 48 "(расшифровка подписи)" format "X(25)" AT 78 skip

       "Кассир-операционист" AT 6
       UndLine format "X(25)" AT 40 UndLine format "X(35)" AT 70 skip
       "(подпись)" format "X(25)" AT 48 "(расшифровка подписи)" format "X(25)" AT 78 skip

       UndLine format "X(25)" AT 6  UndLine format "X(25)" AT 40 UndLine format "X(35)" AT 70 skip
       "(должность)" format "X(25)" AT 13 "(подпись)" format "X(25)" AT 48  "(расшифровка подписи)" format "X(25)" AT 78 skip
       UndLine format "X(25)" AT 6 UndLine format "X(25)" AT 40 UndLine format "X(35)" AT 70 skip
       "(должность)" format "X(25)" AT 13 "(подпись)" format "X(25)" AT 48  "(расшифровка подписи)" format "X(25)" AT 78 skip
   .
end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .

  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream )
  then page stream Out-Stream .

END PROCEDURE. /* on-same-page */