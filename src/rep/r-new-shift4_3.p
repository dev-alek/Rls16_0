block-level on error undo, throw.
/*

$Revision: ac2de8611dbf, 1057, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:33:18 2017 +0300 $
$Workfile: r-new-shift4_3.p $
$Archive: rep/r-new-shift4_3.p $

печать сменного отчета лист 4

Автор: Булгаков Андрей Николаевич
Дата создания: 04/12/06
Author: Andrew Bulgakoff
Creation date: 04/12/06

*/

define input parameter parparentproc         as   widget-handle       no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter v-report-name-html         as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-obj-type            like ub.clients.obj-type no-undo.
define input parameter p-obj-code            like ub.clients.obj-code no-undo.
define input parameter p-z-number-list       as   character           no-undo.
define input parameter p-previous-shift-date as   date                no-undo.
define input parameter p-param  as logical no-undo .

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: ac2de8611dbf, 1057, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Fri Oct 06 18:33:18 2017 +0300 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-new-shift4_3.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-new-shift4_3.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "$Печать сменного отчета - лист 4 $":U.


{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ rep/real-4df.i SHARED treal-4 }
{ rep/real-4df.i " " actreal-4 }
{ rep/icm-4df.i  "NEW SHARED" }
{ rep/real-4cr.i treal-4 }
{ rep/real-4cr.i actreal-4 }
{ rep/mat-4df.i "NEW SHARED" }

define shared stream  PrnLibstream.
define variable pol1 as character no-undo .
define variable pol2 as integer   no-undo .
define variable pol3 as decimal   no-undo .
define variable pol4 as character no-undo .
define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .
define variable pol7 as decimal   no-undo .
define variable pol8 as decimal   no-undo .
define variable pol9 as decimal   no-undo .
/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.

define variable line                 as character no-undo .
DEFINE VARIABLE areal-is-pay-qnty1   as decimal   no-undo.
DEFINE VARIABLE areal-is-pay-netto   as decimal   no-undo.
DEFINE VARIABLE areal-no-pay-qnty1   as decimal   no-undo.
DEFINE VARIABLE areal-no-pay-netto   as decimal   no-undo.
DEFINE VARIABLE areal-qnty1          as decimal   no-undo.
DEFINE VARIABLE areal-netto          as decimal   no-undo.
DEFINE VARIABLE v-total-is-pay-qnty1 as decimal   no-undo.
DEFINE VARIABLE v-total-is-pay-netto as decimal   no-undo.
DEFINE VARIABLE v-total-no-pay-qnty1 as decimal   no-undo.
DEFINE VARIABLE v-total-no-pay-netto as decimal   no-undo.
DEFINE VARIABLE v-total-qnty1        as decimal   no-undo.
DEFINE VARIABLE v-total-netto        as decimal   no-undo.
DEFINE VARIABLE a-qnty1              as decimal   no-undo.
DEFINE VARIABLE a-netto              as decimal   no-undo.
DEFINE VARIABLE loc-real-ii          as integer   no-undo.
DEFINE VARIABLE curr-real-ii         as integer   no-undo.
DEFINE VARIABLE jj                   as integer   no-undo.
DEFINE VARIABLE loc-jj               as integer   no-undo.
DEFINE VARIABLE main-line            as logical   no-undo.
DEFINE VARIABLE mat-line             as logical   no-undo.
DEFINE VARIABLE pay-line             as logical   no-undo.
DEFINE VARIABLE a-line               as logical   no-undo.
/*количество строк подлежащее выводу*/
DEFINE VARIABLE max-line             as integer   no-undo.
/*количество строк по услугам подлежащее выводу*/
DEFINE VARIABLE max-real             as integer   no-undo.
DEFINE VARIABLE rc                   as recid     no-undo.
DEFINE VARIABLE acii                 as integer   no-undo .
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift4 }

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


&scop All-sym5 sym1 sym2 sym3 sym4 sym5


/* строки отчета  */

/*к этому моменту должна быть уже заполнена таблица treal-4 - все записи с is-pay = yes - оплаченный расход*/
/*заполним таблицу treal-4 -  в части прочих расходов*/
/*соглашения по умолчанию*/
/*out-name = "Прочий докум.расход"    cpay-code = -1 ii = ? is-pay = no*/

run rep/r-shft4r.p
    (input p-obj-type,
    input p-obj-code,
    input X-date-Start,
    input X-Shift-Start,
    input X-date-End,
    input X-Shift-End,
    input p-previous-shift-date
    ) no-error.

/*шапка таблицы HTML*/
         
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
    substitute (
    '<tbody> <!-- Здесь начинается таблица отчета -->
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th colspan="3" style="text-align: center;">Информация об услуге</th>
                <th colspan="6" style="text-align: center;">Расшифровка реализации услуг</th>
            </tr>
            <tr>
                <th style="text-align: center;">Наименование услуги</th>
                <th style="text-align: center;">Код услуги</th>
                <th style="text-align: center;">Цена рознич. на конец смены</th>
                <th style="text-align: center;">Тип расхода (тип платежа)</th>
                <th style="text-align: center;">Кол-во</th>
                <th style="text-align: center;">Сумма</th>
                <th style="text-align: center;">Сумма скидки</th>
                <th style="text-align: center;">Сумма брутто</th>
                <th style="text-align: center;">Кол-во покупок</th>
            </tr>
            <tr>
                <th style="text-align: center;">4.1</th>
                <th style="text-align: center;">4.2</th>
                <th style="text-align: center;">4.3</th>
                <th style="text-align: center;">4.4</th>
                <th style="text-align: center;">4.5</th>
                <th style="text-align: center;">4.6</th>
                <th style="text-align: center;">4.7</th>
                <th style="text-align: center;">4.8</th>
                <th style="text-align: center;">4.9</th>
            </tr>
            '
    , chr(123), chr(125)
    ).

for each actreal-4:
    delete actreal-4.
end.



/*цикл по услугам*/
FOR EACH t-4 use-index pi:
    assign
        areal-is-pay-qnty1 = 0
        areal-is-pay-netto = 0
        areal-no-pay-qnty1 = 0
        areal-no-pay-netto = 0
        areal-qnty1        = 0
        areal-netto        = 0
        loc-real-ii        = 1
        curr-real-ii       = 1
        .

    /*чтобы прописать ii для тех у кого ii = ?*/
    FIND LAST treal-4 No-LOCK WHERE
        treal-4.gds-code = t-4.gds-code AND
        treal-4.is-pay = yes use-index vi No-ERROR.
    if avail treal-4 then
        assign
            loc-real-ii  = treal-4.ii + 1
            curr-real-ii = treal-4.ii + 1
            .
    /*родим записи таблицы treal-4 - подитоги*/
    IF can-find(first treal-4 WHERE
        treal-4.gds-code = t-4.gds-code) then 
    do:
        /*если есть вообще оплаченный расход*/
        FOR EACh  treal-4 where
            treal-4.gds-code = t-4.gds-code use-index pi:
            if treal-4.discnt-type = -99 then do:    
            assign
                areal-qnty1 = areal-qnty1 + treal-4.qnty1
                areal-netto = areal-netto + treal-4.netto
                .
            if treal-4.is-pay then
                assign
                    areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-4.qnty1
                    areal-is-pay-netto = areal-is-pay-netto + treal-4.netto
                    .
            else
                assign
                    rc                 = recid(treal-4)
                    curr-real-ii       = (if curr-real-ii = loc-real-ii AND /*первый проход*/
                         (loc-real-ii > 1  /*оплаченные были и есть неоплач раз мы здесь*/ OR
                          can-find(first treal-4 No-LOCK WHERE
                                         treal-4.gds-code = t-4.gds-code AND
                                         treal-4.is-pay = no AND
                                         recid(treal-4) <> rc)
                          )
                      then (curr-real-ii + 1)
                      else curr-real-ii
                     )
                    treal-4.ii         = curr-real-ii
                    curr-real-ii       = curr-real-ii + 1
                    areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-4.qnty1
                    areal-no-pay-netto = areal-no-pay-netto + treal-4.netto
                    .
            end.        
        END.
        if curr-real-ii > 2 then 
        do:
            /*treal-4 большей одной -просто счетчик еще раз перевелся*/
            /*рожаем запись ИТОГО ОПЛАЧ.РАСХОД*/
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-is-pay-qnty1,
                INPUT areal-is-pay-netto,
                INPUT "ИТОГО ОПЛАЧ.РАСХОД",
                INPUT yes,
                INPUT loc-real-ii) no-error.
            /*рожаем запись ИТОГО ПРОЧ.РАСХОДОВ*/
            /*если не было прочих расходов - переведем счетчик*/
            if loc-real-ii = curr-real-ii then
                curr-real-ii = curr-real-ii + 1.
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-no-pay-qnty1,
                INPUT areal-no-pay-netto,
                INPUT "ИТОГО ПРОЧ.РАСХОДОВ",
                INPUT no,
                INPUT curr-real-ii) no-error.
            curr-real-ii = curr-real-ii + 1.
            run create-treal-4 (
                INPUT t-4.gds-code,
                INPUT 0,
                INPUT 0,
                INPUT areal-qnty1,
                INPUT areal-netto,
                INPUT "ВСЕГО  РАСХОД",  /*пробелы не стирать!*/
                INPUT ?,
                INPUT curr-real-ii) no-error.
        END.
    END. /*if curr-real-ii > 2*/
    assign
        t-4.lines = MAX(curr-real-ii, 1)
        .
END. /*FOR EACH t-4*/

FOR EACH t-4 No-LOCK,
    EACH treal-4 No-LOCK WHERE
    treal-4.gds-code = t-4.gds-code
    BREAK BY treal-4.gds-code
    BY treal-4.is-pay descending
    BY treal-4.ii:
    assign
        pol1      = ""
        pol2      = 0
        pol3      = 0
        pol4      = ""
        pol5      = 0
        pol6      = 0
        pol7      = 0
        pol8      = 0
        pol9      = 0
        main-line = no
        pay-line  = no
        .
    IF FIRST-OF(treal-4.gds-code) then 
    do:
        assign
            pol1      = t-4.gds-name
            pol2      = t-4.main-code
            pol3      = t-4.last-price
            main-line = yes
            .
    END.
    assign
        pol4 = treal-4.out-name
        pol5 = treal-4.qnty1
        pol6 = treal-4.netto
        pol7 = treal-4.discount-sum
        pol8 = treal-4.brutto
        pol9 = treal-4.chk-qnty
        .
        if treal-4.discnt-type = -99 then do:
        assign
        a-netto   = a-netto + treal-4.netto
        a-qnty1   = a-qnty1 + treal-4.qnty1
        .
        end.

    if treal-4.cpay-code <> 0 and treal-4.discnt-type = -99 then 
    dO:
        /*создадим записи по подитогам по типам оплат*/
        FIND FIRST actreal-4 WHERE
            actreal-4.gds-code = 0 AND
            actreal-4.cpay-code = treal-4.cpay-code AND
            actreal-4.curr-code = treal-4.curr-code AND
            actreal-4.is-pay = treal-4.is-pay  NO-ERROR.
        if not avail actreal-4 then 
        do:
            acii = acii + 1.
            run create-actreal-4 (
                INPUT 0,
                INPUT treal-4.cpay-code,
                INPUT treal-4.curr-code,
                INPUT treal-4.qnty1,
                INPUT treal-4.netto,
                INPUT treal-4.out-name,
                INPUT treal-4.is-pay,
                INPUT acii) no-error.
        end.
        else
            assign
                actreal-4.qnty1 = actreal-4.qnty1 + treal-4.qnty1
                actreal-4.netto = actreal-4.netto + treal-4.netto
                .
    end.
    if pol5 <> 0 then 
    do:
        put stream OutStr-html unformatted
            substitute (
            '<tr>
                <td text_wrap="true">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td text_wrap="true">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
                <td style="text-align: right;">&8</td>
                <td style="text-align: right;">&9</td>
            </tr>    
                '
            ,
            if main-line = no then "" else string(pol1),
            if main-line = no then "" else string(pol2),
            if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
            pol4,
            string(pol5,"->>>>>>>>>>>9"),
            string(pol6,"->>>>>>>>>>>9.99"),
            if pol7 = 0 then "" else string(pol7,"->>>>>>>>>>>9.99"),
            if pol8 = 0 then "" else string(pol8,"->>>>>>>>>>>9.99"),
            if pol9 = 0 then "" else string(pol9,"->>>>>>>>>>>9.99")
            ).
    end.

    IF LAST(treal-4.gds-code) then 
    do:
        assign
            pol1 = "ВСЕГО РЕАЛИЗОВАНО УСЛУГ  :"
            pol5 = a-qnty1
            pol6 = a-netto
            .
        put stream OutStr-html unformatted
            substitute (
            '<tr>
                <th text_wrap="true" style="text-align: left">&1</th>
                <th></th>
                <th></th>
                <th></th>
                <th style="text-align: right;">&2</th>
                <th style="text-align: right;">&3</th>
                <th style="text-align: right;"></th>
                <th style="text-align: right;"></th>
                <th style="text-align: right;"></th>
            </tr>    
                '
            ,
            pol1,
            string(pol5,"->>>>>>>>>>>9"),
            string(pol6,"->>>>>>>>>>>9.99")
            ).

        if can-find(first actreal-4) then 
        do:
            pol4 = "     в том числе:".
            put stream OutStr-html unformatted
                substitute (
                '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td text_wrap="true" style="text-align: left;">&1</td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>    
                '
                ,
                pol4
                ).

            assign
                areal-is-pay-qnty1 = 0
                areal-is-pay-netto = 0
                areal-no-pay-qnty1 = 0
                areal-no-pay-netto = 0
                .
                
RELEASE actreal-4 no-error.
    
            FOR EACH actreal-4 No-LOCK
                BREAK
                BY actreal-4.gds-code
                By actreal-4.is-pay descending
                BY actreal-4.cpay-code descending
                BY actreal-4.curr-code:
                    
                if actreal-4.is-pay = yes then
                    assign
                        areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-4.qnty1
                        areal-is-pay-netto = areal-is-pay-netto + actreal-4.netto
                        .
                else
                    assign
                        areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-4.qnty1
                        areal-no-pay-netto = areal-no-pay-netto + actreal-4.netto
                        .
                assign
                    pol4 = actreal-4.out-name
                    pol5 = actreal-4.qnty1
                    pol6 = actreal-4.netto
                    pol7 = actreal-4.discount-sum
                    pol8 = actreal-4.brutto
                    pol9 = actreal-4.chk-qnty
                    .
                put stream OutStr-html unformatted
                    substitute (
                    '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td>&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
            </tr>    
                '
                    ,
                    pol4,
                    string(pol5,"->>>>>>>>>>>9"),
                    string(pol6,"->>>>>>>>>>>9.99"),
                    if pol7 = 0 then "" else string(pol7,"->>>>>>>>>>>9.99"),
                    if pol8 = 0 then "" else string(pol8,"->>>>>>>>>>>9.99"),
                    if pol9 = 0 then "" else string(pol9,"->>>>>>>>>>>9.99")
                    ).


                if last-of(actreal-4.is-pay) /*and actreal-4.is-pay <> ? */ then 
                do:
                    
                    if actreal-4.is-pay = yes then
                        assign
                            pol4 = "ИТОГО ОПЛАЧ.РАСХОД"
                            pol5 = areal-is-pay-qnty1
                            pol6 = areal-is-pay-netto
                            .
                    else
                        assign
                            pol4 = "ИТОГО ПРОЧ.РАСХОД"
                            pol5 = areal-no-pay-qnty1
                            pol6 = areal-no-pay-netto
                            .
                    put stream OutStr-html unformatted
                        substitute (
                        '<tr>
                <td></td>
                <td></td>
                <td></td>
                <td text_wrap="true">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
            </tr>    
                '
                        ,
                        pol4,
                        string(pol5,"->>>>>>>>>>>9"),
                        string(pol6,"->>>>>>>>>>>9.99")
                        ).          
                end. /*lasit-of(ctreal-4.is-pay) and is-pay <> ?*/
            END. /*FOR EACH actreal-4*/
        end.
    end. /*IF LAST(treal-4.gds-code) */
END.
output stream OutStr-html close.
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted                                                                     
    substitute (
    '
        </tbody>
        '                                                                                      
    , chr(123), chr(125)                                                                                                 
    ).                                                                                                    
output stream OutStr-html close.