block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wcdoc.p $
$Archive: rep/r-wcdoc.p $

Печатная форма движение материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-c-wth-doc-recid as recid.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wcdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wcdoc.p $":U .
define variable vss-description as character no-undo init "Печатная форма движение материальных ценностей".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ rep/p-fmt.i }

do
on error undo, return error
:

&scop left-margin 5
&scop right-margin 130
&scop max-width 124
&scop tab-stop1 44
&scop max-width-from-tab1 86
&scop tab-stop2 60
&scop max-width-from-tab2 70
&scop tab-stop3 80
&scop tab-stop4 100

/*----S----- Таблица --------------------------------*/
&GLOB P-S 40
&GLOB P-X 65        /*длина линии*/
&GLOB P-X0 63       /*длина внутренней линии = длина линии - 2*/
&GLOB P-C1-FX  19   /*ширина 1-й колонки*/
&GLOB P-E     {&P-S} + 64
&GLOB P-C2-S  {&P-S} + 21
&GLOB P-C3-S  {&P-S} + 25
&GLOB P-C4-S  {&P-S} + 38
&GLOB P-C5-S  {&P-S} + 42
/*----E----- Таблица --------------------------------*/

/*дополняет строку слева пробелами для печати по центру*/
&scop extend-temp-string-to-center ~
  assign v-temp-position = center-field( {&left-margin}, {&right-margin}, length(v-temp-string) )~
         v-temp-string   = fill(" ", v-temp-position - 1) + v-temp-string.


/*----S----- Блок описания переменных ---------------*/
def buffer buf_c-wth-doc  for ub.c-wth-doc.
def buffer buf_c-wth-line for ub.c-wth-line.
def buffer buf_c-wth-dtl  for ub.c-wth-dtl.
def buffer buf_clients  for ub.clients.
define buffer buf_host for ub.clients.


define variable v-organization  like ub.clients.obj-name no-undo.
define variable v-org-to        as char no-undo.
define variable v-org-from      as char no-undo.
define variable v-operator      like ub.clients.obj-name no-undo.
define variable v-deliver       like ub.clients.obj-name no-undo.
define variable v-receiver      like ub.clients.obj-name no-undo.
define variable v-temp-string   as char no-undo.
define variable v-temp-position as int  no-undo.
define variable v-single-line   as char no-undo.

assign v-single-line = fill("-", {&max-width}).
/*----E----- Блок описания переменных ---------------*/


if session:set-wait-state("compiler") then.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).



find first buf_c-wth-doc no-lock
     where recid( buf_c-wth-doc ) = p-c-wth-doc-recid
.
find first buf_clients no-lock    /* Ищем организацию в clients */
    where buf_clients.obj-type = buf_c-wth-doc.obj-type
      and buf_clients.obj-code = buf_c-wth-doc.obj-code
.

find first buf_host no-lock    /* Ищем организацию в clients */
    where buf_host.obj-type = {&cmp}
      and buf_host.obj-code = buf_c-wth-doc.host-code
.

assign
  v-organization = buf_clients.obj-name
.
/*---S------- На каждый c-wth-line выводится отдельный документ ------------*/
for each buf_c-wth-line no-lock
     where buf_c-wth-line.doc-code = buf_c-wth-doc.doc-code
       AND buf_c-wth-line.corr-user-db-num = buf_c-wth-doc.corr-user-db-num
       AND buf_c-wth-line.chip-num = buf_c-wth-doc.chip-num
break by buf_c-wth-line.wth-code
:
    /*---S---- Если документ не первый, выводится "продолжение на..." и новая страница ---*/
    if not first(buf_c-wth-line.wth-code)
    then do:
      FORM HEADER
          v-single-line format "X({&max-width})" AT 1 SKIP
          "Продолжение - на следующей странице" AT 30 SKIP
          with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
      VIEW STREAM PrnLibStream FRAME BottomFrame .
      PAGE STREAM PrnLibStream.
    end.
    /*---E---- Если документ не первый, выводится "продолжение на..." и новая страница ---*/
    find first ub.wth-place
         where ub.wth-place.host-code = buf_c-wth-doc.host-code
           and ub.wth-place.obj-type  = buf_c-wth-doc.obj-type
           and ub.wth-place.obj-code  = buf_c-wth-doc.obj-code
           and ub.wth-place.w-p-code  = buf_c-wth-line.w-p-code
    no-error.

    find first buf_clients no-lock    /* Ищем оператора в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_c-wth-doc.operator
    .
    assign
      v-operator = buf_clients.obj-name
    .
    find first buf_clients no-lock    /* Ищем того, кто передал, в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_c-wth-doc.deliver
    .
    assign
      v-deliver = buf_clients.obj-name
    .

    find first buf_clients no-lock    /* Ищем того, кто получил, в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_c-wth-doc.receiver
    .
    assign
      v-receiver = buf_clients.obj-name
    .

    find first buf_clients no-lock     /* Получатель и Источник поступления */
        where buf_clients.obj-type = buf_c-wth-doc.obj-type
          and buf_clients.obj-code = buf_c-wth-doc.obj-code
    .
    if buf_c-wth-doc.doc-type = {&income}
    then assign
            v-org-from = buf_c-wth-doc.cli-name
            v-org-to   = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
    .
    else assign
            v-org-from = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
            v-org-to   = buf_c-wth-doc.cli-name
    .
  /*---S----- Шапка документа ------------------------*/

    assign
        v-temp-string = "УДАЛЕННЫЙ Д О К У М Е Н Т   №  " + string(buf_c-wth-doc.doc-code)
    .
    {&extend-temp-string-to-center}

    put stream PrnLibStream
        skip
        buf_host.obj-name
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) )
                          format "X(12)"   at right-field({&right-margin} - 5, 12)
        skip
          buf_clients.obj-name
        skip(2)
            v-temp-string format "X({&right-margin})"
        skip
        "движения материальных ценностей"
                          format "X(31)"   at center-field( {&left-margin}, {&right-margin}, 31 )
        skip(2)
        space ({&left-margin}) "Смена: "
        buf_c-wth-doc.shift-name format "X(12)"
        " от "
        buf_c-wth-doc.shift-date format "99/99/9999"
    .
    find first ub.wealth no-lock
        where ub.wealth.wth-code = buf_c-wth-line.wth-code
    .

    put stream PrnLibStream
        skip(1)
        space ({&left-margin}) "Наименование материальных ценностей: "
        space({&tab-stop1} - 37) wealth.wth-name      format "X(65)"
        skip
        space ({&left-margin}) "Источник поступления: "
        space({&tab-stop1} - 22) v-org-from           format "X(65)"
        skip
        space ({&left-margin}) "Получатель: "
        space({&tab-stop1} - 12) v-org-to             format "X(65)"
        skip
        space ({&left-margin}) "Сумма движения материальных ценностей: "
        space({&tab-stop1} - 39) (if buf_c-wth-doc.status_ = {&fact}
                                  then buf_c-wth-line.fact-sum
                                  else buf_c-wth-line.doc-sum)       format "z,zzz,zzz,zz9.99"
    .

  /*---E----- Шапка документа ------------------------*/

  /*---S---- Строим таблички по номиналам -----------*/

        find first  buf_c-wth-dtl no-lock
            where buf_c-wth-dtl.doc-code = buf_c-wth-line.doc-code
              and buf_c-wth-dtl.wth-code = buf_c-wth-line.wth-code
              and buf_c-wth-dtl.corr-user-db-num = buf_c-wth-line.corr-user-db-num
              and buf_c-wth-dtl.chip-num = buf_c-wth-line.chip-num
        no-error.
        if available buf_c-wth-dtl        /*Если есть разбивка по номиналам*/
        then do:
            put stream PrnLibStream
                skip(1)
                space ({&left-margin}) "Расшифровка суммы: "
            .
            for each ub.wth-par no-lock
               where ub.wth-par.wth-code = buf_c-wth-line.wth-code
            break by ub.wth-par.par-feat
            :
                find first buf_c-wth-dtl no-lock
                     where buf_c-wth-dtl.doc-code = buf_c-wth-line.doc-code
                       and buf_c-wth-dtl.wth-code = buf_c-wth-line.wth-code
                       and buf_c-wth-dtl.w-p-code = buf_c-wth-line.w-p-code
                       and buf_c-wth-dtl.par-code = ub.wth-par.par-code
                       and buf_c-wth-dtl.corr-user-db-num = buf_c-wth-line.corr-user-db-num
                       and buf_c-wth-dtl.chip-num = buf_c-wth-line.chip-num
                no-error.
                if first-of(ub.wth-par.par-feat)
                then do:
                    if not first(ub.wth-par.par-feat)
                    then do:
                        put stream PrnLibStream
                          skip
                            v-single-line format "X({&P-X})" at {&P-S}
                          skip(2)
                        .
                    end.
                    put stream PrnLibStream
                        skip
                        v-single-line format "X({&P-X})" at {&P-S}
                      skip
                        space ({&left-margin} + 15)
                        wth-par.par-feat format "X(15)"
                        "|" at {&P-S}
                        "Номинал" at center-field({&P-S}, {&P-C2-S}, 7)
                        "|" at {&P-C2-S}
                        "|" at {&P-C3-S}
                        "Количество" at center-field({&P-C3-S}, {&P-C4-S}, 10)
                        "|" at {&P-C4-S}
                        "|" at {&P-C5-S}
                        "Сумма" at center-field({&P-C5-S}, {&P-E}, 10)
                        "|" at {&P-E}
                    .
                end.

                put stream PrnLibStream
                  skip
                    "|"  at {&P-S}
                    v-single-line format "X({&P-X0})"
                    "|"
                  skip
                    "|" at {&P-S}
                    string(ub.wth-par.par-val, "z,zzz,zz9") + " " + string(ub.wth-par.par-unit)
                                        format "X({&P-C1-FX})"
                    "|" at {&P-C2-S}
                    "x" at center-field({&P-C2-S}, {&P-C3-S}, 1)
                    "|" at {&P-C3-S}
                .
                if available buf_c-wth-dtl
                then put stream PrnLibStream
                    buf_c-wth-dtl.doc-sum / ub.wth-par.par-rate at center-field({&P-C3-S}, {&P-C4-S}, 10)
                .
                put stream PrnLibStream
                    "|" at {&P-C4-S}
                    "=" at center-field({&P-C4-S}, {&P-C5-S}, 1)
                    "|" at {&P-C5-S}
                .
                if available buf_c-wth-dtl
                then put stream PrnLibStream
                    buf_c-wth-dtl.doc-sum format "zzz,zzz,zz9.99" at center-field({&P-C5-S}, {&P-E}, 15)
                .
                put stream PrnLibStream
                    "|" at {&P-E}
                .
                if available buf_c-wth-dtl
                then accumulate
                  buf_c-wth-dtl.doc-sum (total)
                .
            end.
            put stream PrnLibStream
              skip
                v-single-line format "X({&P-X})" at {&P-S}
                "Итого: " at right-field({&P-C5-S}, 7)
                space(5) (accum total buf_c-wth-dtl.doc-sum)
/*                (if buf_c-wth-doc.status_ = {&fact}*/
/*                          then buf_c-wth-doc.fact-sum*/
/*                          else buf_c-wth-doc.doc-sum) */
                              format "z,zzz,zzz,zz9.99"
            .
        end.
  /*---E---- Строим таблички по номиналам -----------*/

  /*---S---- Подписи внизу документа ----------------*/
    if line-counter( PrnLibStream ) + 8 > page-size( PrnLibStream )
    then page stream PrnLibStream.

    put stream PrnLibStream
        skip(2)
        space ({&left-margin}) "Документ составил:    "
        v-operator format "X(60)"
        "подпись _______________________________"
        skip(2)
        space ({&left-margin}) "ПЕРЕДАЛ          "
        v-deliver format "X(65)"
        "подпись _______________________________"
        skip(1)
        space ({&left-margin}) "ПОЛУЧИЛ          "
        v-receiver format "X(65)"
        "подпись _______________________________"
    .
  /*---E---- Подписи внизу документа ----------------*/

end.  /*for each buf_c-wth-line*/
/*---E------- На каждый c-wth-line выводится отдельный документ ------------*/

output stream PrnLibStream close.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

/*{ rep/q-print.i 4}*/
end.