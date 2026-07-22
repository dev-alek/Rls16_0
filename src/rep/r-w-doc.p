block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-w-doc.p $
$Archive: rep/r-w-doc.p $

Печатная форма движение материальных ценностей

Автор: Демин Алексей Сергеевич
Дата создания: 09/05/07
Author: Alexey Demin
Creation date: 09/05/07

Input:

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-doc-code       as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-w-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-w-doc.p $":U .
define variable vss-description as character no-undo init "Печатная форма движение материальных ценностей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ str/getctxtp.i def }

define stream out-stream .

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
def buffer buf_wth-doc  for ub.wth-doc.
def buffer buf_wth-line for ub.wth-line.
def buffer buf_wth-dtl  for ub.wth-dtl.
def buffer buf_clients  for ub.clients.
define buffer buf_host for ub.clients.


def var v-organization  like ub.clients.obj-name no-undo.
def var v-org-to        as char no-undo.
def var v-org-from      as char no-undo.
def var v-operator      like ub.clients.obj-name no-undo.
def var v-deliver       like ub.clients.obj-name no-undo.
def var v-receiver      like ub.clients.obj-name no-undo.
def var v-temp-string   as char no-undo.
def var v-temp-position as int  no-undo.
def var v-single-line   as char no-undo.

do
on error undo, return error
:
run get-report-num in parparentproc (
    output g#report-num
).
run get-quest-print in parparentproc (
    output g#quest-print
).
{ str/getctxtp.i get }
{ gbl/working.i }
{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

assign v-single-line = fill("-", {&max-width}).

find first buf_wth-doc no-lock
     where buf_wth-doc.doc-code = p-doc-code
.
find first buf_clients no-lock    /* Ищем организацию в clients */
    where buf_clients.obj-type = buf_wth-doc.obj-type
      and buf_clients.obj-code = buf_wth-doc.obj-code
.

find first buf_host no-lock    /* Ищем организацию в clients */
    where buf_host.obj-type = {&cmp}
      and buf_host.obj-code = buf_wth-doc.host-code
.

assign
  v-organization = buf_clients.obj-name
.
/*---S------- На каждый wth-line выводится отдельный документ ------------*/
for each buf_wth-line no-lock
     where buf_wth-line.doc-code = buf_wth-doc.doc-code
break by buf_wth-line.wth-code
:
    /*---S---- Если документ не первый, выводится "продолжение на..." и новая страница ---*/
    if not first(buf_wth-line.wth-code)
    then do:
      FORM HEADER
          v-single-line format "X({&max-width})" AT 1 SKIP
          "Продолжение - на следующей странице" AT 30 SKIP
          with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
      VIEW STREAM out-stream FRAME BottomFrame .
      PAGE STREAM out-stream.
    end.
    /*---E---- Если документ не первый, выводится "продолжение на..." и новая страница ---*/
    find first ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
           and ub.wth-place.obj-type  = buf_wth-doc.obj-type
           and ub.wth-place.obj-code  = buf_wth-doc.obj-code
           and ub.wth-place.w-p-code  = buf_wth-line.w-p-code
    no-error.

    find first buf_clients no-lock    /* Ищем оператора в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_wth-doc.operator
    no-error.
    assign
      v-operator = if available buf_clients then buf_clients.obj-name else '':U
    .
    find first buf_clients no-lock    /* Ищем того, кто передал, в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_wth-doc.deliver
    no-error.
    assign
      v-deliver = if available buf_clients then buf_clients.obj-name else '':U
    .

    find first buf_clients no-lock    /* Ищем того, кто получил, в clients */
        where buf_clients.obj-type = {&prs}
          and buf_clients.obj-code = buf_wth-doc.receiver
    no-error.
    assign
      v-receiver = if available buf_clients then  buf_clients.obj-name else '':U
    .

    find first buf_clients no-lock     /* Получатель и Источник поступления */
        where buf_clients.obj-type = buf_wth-doc.obj-type
          and buf_clients.obj-code = buf_wth-doc.obj-code
    .
    if buf_wth-doc.doc-type = {&income}
    then assign
            v-org-from = buf_wth-doc.cli-name
            v-org-to   = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
    .
    else assign
            v-org-from = buf_clients.obj-name + (if available wth-place
                                                    and wth-place.w-p-name <> ?
                                                 then ", " + wth-place.w-p-name else "")
            v-org-to   = buf_wth-doc.cli-name
    .
  /*---S----- Шапка документа ------------------------*/

    assign
        v-temp-string = "Д О К У М Е Н Т   №  " + string(buf_wth-doc.doc-code)
    .
    {&extend-temp-string-to-center}

    put stream out-stream
        skip
        buf_host.obj-name
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) )
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
        buf_wth-doc.shift-name format "X(12)"
        " от "
        buf_wth-doc.shift-date format "99/99/9999"
    .
    find first ub.wealth no-lock
        where ub.wealth.wth-code = buf_wth-line.wth-code
    .

    put stream out-stream
        skip(1)
        space ({&left-margin}) "Наименование материальных ценностей: "
        space({&tab-stop1} - 37) ub.wealth.wth-name      format "X(65)"
        skip
        space ({&left-margin}) "Источник поступления: "
        space({&tab-stop1} - 22) v-org-from           format "X(65)"
        skip
        space ({&left-margin}) "Получатель: "
        space({&tab-stop1} - 12) v-org-to             format "X(65)"
        skip
        space ({&left-margin}) "Сумма движения материальных ценностей: "
        space({&tab-stop1} - 39) (if buf_wth-doc.status_ = {&fact}
                                  then buf_wth-line.fact-sum
                                  else buf_wth-line.doc-sum)       format "z,zzz,zzz,zz9.99"
    .

  /*---E----- Шапка документа ------------------------*/

  /*---S---- Строим таблички по номиналам -----------*/

        find first  buf_wth-dtl no-lock
            where buf_wth-dtl.doc-code = buf_wth-line.doc-code
              and buf_wth-dtl.wth-code = buf_wth-line.wth-code
        no-error.
        if available buf_wth-dtl        /*Если есть разбивка по номиналам*/
        then do:
            put stream out-stream
                skip(1)
                space ({&left-margin}) "Расшифровка суммы: "
            .
            for each ub.wth-par no-lock
               where ub.wth-par.wth-code = buf_wth-line.wth-code
            break by ub.wth-par.par-feat
            :
                find first buf_wth-dtl no-lock
                     where buf_wth-dtl.doc-code = buf_wth-line.doc-code
                       and buf_wth-dtl.wth-code = buf_wth-line.wth-code
                       and buf_wth-dtl.w-p-code = buf_wth-line.w-p-code
                       and buf_wth-dtl.par-code = ub.wth-par.par-code
                no-error.
                if first-of(ub.wth-par.par-feat)
                then do:
                    if not first(ub.wth-par.par-feat)
                    then do:
                        put stream out-stream
                          skip
                            v-single-line format "X({&P-X})" at {&P-S}
                          skip(2)
                        .
                    end.
                    put stream out-stream
                        skip
                        v-single-line format "X({&P-X})" at {&P-S}
                      skip
                        space ({&left-margin} + 15)
                        ub.wth-par.par-feat format "X(15)"
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

                put stream out-stream
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
                if available buf_wth-dtl
                then put stream out-stream
                    buf_wth-dtl.doc-sum / ub.wth-par.par-rate at center-field({&P-C3-S}, {&P-C4-S}, 10)
                .
                put stream out-stream
                    "|" at {&P-C4-S}
                    "=" at center-field({&P-C4-S}, {&P-C5-S}, 1)
                    "|" at {&P-C5-S}
                .
                if available buf_wth-dtl
                then put stream out-stream
                    buf_wth-dtl.doc-sum format "zzz,zzz,zz9.99" at center-field({&P-C5-S}, {&P-E}, 15)
                .
                put stream out-stream
                    "|" at {&P-E}
                .
                if available buf_wth-dtl
                then accumulate
                  buf_wth-dtl.doc-sum (total)
                .
            end.
            put stream out-stream
              skip
                v-single-line format "X({&P-X})" at {&P-S}
                "Итого: " at right-field({&P-C5-S}, 7)
                space(5) (accum total buf_wth-dtl.doc-sum)
/*                (if buf_wth-doc.status_ = {&fact}*/
/*                          then buf_wth-doc.fact-sum*/
/*                          else buf_wth-doc.doc-sum) */
                              format "z,zzz,zzz,zz9.99"
            .
        end.
  /*---E---- Строим таблички по номиналам -----------*/

  /*---S---- Подписи внизу документа ----------------*/
    if line-counter( out-stream ) + 8 > page-size( out-stream )
    then page stream out-stream.

    put stream out-stream
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

end.  /*for each buf_wth-line*/
/*---E------- На каждый wth-line выводится отдельный документ ------------*/

output stream out-stream close.
{ gbl/stopwork.i }
{ rep/q-print.i 4}

end.