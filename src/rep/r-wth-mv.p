block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wth-mv.p $
$Archive: rep/r-wth-mv.p $

Отчет по движению МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 10/23/07
Author: Polina Gridchina
Creation date: 10/23/07

Input:

Output:

*/

define input parameter p-wth-money as logical no-undo.
define input parameter p-wth-ser   as logical no-undo.
define input parameter p-wth-un    as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wth-mv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wth-mv.p $":U .
define variable vss-description as character no-undo init "Отчет по движению МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ rep/p-fmt.i }
{ cmp/r-page1.i }
{ str/wth-lib.i }
{ rep/rep-bt.i }

do
on error undo, return error
:

&scop left-margin 3
&scop right-margin 190
&scop max-width 185
&scop tab-stop1 44
&scop max-width-from-tab1 140
&scop tab-stop2 60
&scop max-width-from-tab2 120
&scop tab-stop3 80
&scop tab-stop4 100

/*----S----- Таблица --------------------------------*/
&GLOB P-S {&left-margin}
&GLOB P-X 180        /*длина линии*/
&GLOB P-X0 178       /*длина внутренней линии = длина линии - 2*/
&GLOB P-X1 29       /*длина внутренней линии от второй до четвертой колонки*/
&GLOB P-C1-FX  58   /*ширина 1-й колонки*/
&GLOB P-E     {&P-S} + {&P-X0} + 1
&GLOB P-C2-S  {&P-S} + 59
&GLOB P-C3-S  {&P-S} + 70
&GLOB P-C4-S  {&P-S} + 89
&GLOB P-C5-S  {&P-S} + 123
&GLOB P-C6-S  {&P-S} + 157

define variable sym1 as char init "|" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
define variable sym5 as char init ":" no-undo.
define variable sym6 as char init ":" no-undo.
define variable sym7 as char init "|" no-undo.

define variable v-wth-name like ub.wealth.wth-name    no-undo.
define variable v-doc-date like ub.wth-line.fact-date no-undo.
define variable v-chk-type as   char               no-undo.
define variable v-doc-code like ub.wth-doc.doc-code   no-undo.
define variable v-deliver  like ub.clients.obj-name   no-undo.
define variable v-receiver like ub.clients.obj-name   no-undo.
define variable v-sum      like ub.wth-line.fact-sum  no-undo.

def frame f-wth
        space(2)
        sym1 column-label "|" format "X(1)" space(1)
        v-wth-name COLUMN-LABEL "                      1" format "X(56)"
        sym2 column-label ":" format "X(1)" space(0)
        v-doc-date COLUMN-LABEL "    2" format "99/99/9999" space(0)
        sym3 column-label ":" format "X(1)" space(1)
        v-doc-code COLUMN-LABEL "        3" format "X(16)" space(1)
        sym4 column-label ":" format "X(1)" space(1)
        v-deliver  COLUMN-LABEL "             4" format "X(31)" space(1)
        sym5 column-label ":" format "X(1)" space(1)
        v-receiver COLUMN-LABEL "             5" format "X(31)" space(1)
        sym6 column-label ":" format "X(1)" space(1)
        v-sum      COLUMN-LABEL "6     " format "->>>,>>>,>>>,>>9.99" space(1)
        sym7 column-label "|" format "X(1)" space(1)
    with width {&DOS_CW} down stream-io
.

/*----E----- Таблица --------------------------------*/

/*----S----- Блок описания переменных ---------------*/
def temp-table tt-rep-doc     like ub.wth-line
  field chk-type like ub.chk-doc.chk-type
  field host-code like ub.wth-doc.host-code
  field doc-type like ub.wth-doc.doc-type
  field inter_ like ub.wth-doc.inter_
  field exter_ like ub.wth-doc.exter_
  field cli-name like ub.wth-doc.cli-name.
def buffer buf_tt-doc         for tt-rep-doc.
def buffer buf_wth-doc        for ub.wth-doc.
def buffer b_wth-doc          for ub.wth-doc.
def buffer buf_wth-line       for ub.wth-line.
def buffer buf_wth-dtl        for ub.wth-dtl.
def buffer buf_clients        for ub.clients.
def buffer buf_wth-place      for ub.wth-place.
def buffer buf_out_wth-place  for ub.wth-place.
define buffer buf_chk-doc   for ub.chk-doc.
define buffer buf_wealth      for ub.wealth.
def stream PrnLibStream .

define variable v-organization  like ub.clients.obj-name no-undo.
define variable v-org-to        as char no-undo.
define variable v-org-from      as char no-undo.
define variable v-temp-string   as char no-undo.
define variable v-line-count    as int  no-undo.
define variable v-single-line   as char no-undo.
define variable v-type-sum      as dec no-undo.  /*Сумма по типам документов*/
  /*---S----- Переменные для wth-lib.i ----------*/
define variable parstock-start  like ub.wth-line.income       no-undo.
define variable parstock-end    like ub.wth-line.income       no-undo.
define variable parincome       like ub.wth-line.income       no-undo.
define variable parincome-cassa like ub.wth-line.income-cassa no-undo.
define variable parincome-other like ub.wth-line.income-other no-undo.
define variable parincass       like ub.wth-line.incass       no-undo.
define variable parincass-bank  like ub.wth-line.incass-bank  no-undo.
define variable parincass-other like ub.wth-line.incass-other no-undo.
define variable parincass-cassa like ub.wth-line.incass-cassa no-undo.
  /*---E----- Переменные для wth-lib.i ----------*/
/*----E----- Блок описания переменных ---------------*/

/*---S----- Определения потока --------------*/
assign v-single-line = fill("-", {&max-width}).

if session:set-wait-state("compiler") then.
{ gbl/getcntxt.i get " " my-handle }

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


form header
    v-single-line format "x({&max-width})" at 1 skip
    "продолжение - на следующей странице" AT 30 SKIP
    with frame bottomframe width {&dos_cw} page-bottom no-labels no-box .
view stream PrnLibStream frame bottomframe .

/*---E----- Определения потока --------------*/

find first buf_clients no-lock    /* Ищем организацию в clients */
  where buf_clients.obj-type = v-cntxt-obj-type
    and buf_clients.obj-code = v-cntxt-obj-code
.
assign
v-organization = buf_clients.obj-name
.
/*---S----- Шапка документа ------------------------*/

case x-radio-task :
  when 1 then
     assign
        v-temp-string = "период с " + string(x-date-start) + " по " + string(x-date-end)
     .
  when 2 then
     assign
        v-temp-string = "сменные сутки c " + string(x-date-start) + " по " + string(x-date-end)
     .
  when 3 then
     assign
        v-temp-string = "сменные сутки и номера смен, со смены N"
                  + string(x-shift-start) + " " + string(x-date-start) + " по смену N"
                  + string(x-shift-end)   + " " + string(x-date-end)
     .
  when 4 then
     assign
        v-temp-string = "смену N" + string(x-shift-alone) + ", период с "
                        + string(x-date-start) + " по " + string(x-date-end)
     .
end case.

  put stream PrnLibStream
      skip
        space ({&left-margin})
        v-cntxt-host-name-obj format "X({&max-width-from-tab2})"
        string( "Страница " + string( page-number( PrnLibStream ), ">>9" ) )
                          format "X(12)"   at right-field({&right-margin} - 1, 12)
      skip
          space ({&left-margin})
          v-organization format "X({&max-width})"
      skip(2)
        "ОТЧЕТ ПО ДВИЖЕНИЮ МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ НА АЗК"
                          format "X(47)"   at center-field( {&left-margin}, {&right-margin}, 47 )
      skip(2)
        space ({&left-margin})
        "За " + v-temp-string
                          format "X({&max-width})"
  .

  put stream PrnLibStream
    skip
      v-single-line format "X({&P-X0})" at {&P-S} + 1
    skip
      "|" at {&P-S}
      "|" at {&P-C2-S}
      "Документ" at center-field({&P-C2-S}, {&P-C4-S}, 8)
      "|" at {&P-C4-S}
      "|" at {&P-C5-S}
      "|" at {&P-C6-S}
      "|" at {&P-E}
    skip
      "|" at {&P-S}
      " Наименование"
      "|" at {&P-C2-S}
      v-single-line format "X({&P-X1})" at {&P-C2-S} + 1
      "|" at {&P-C4-S}
      " Получено"
      "|" at {&P-C5-S}
      " Передано"
      "|" at {&P-C6-S}
      " Сумма"
      "|" at {&P-E}
    skip
      "|" at {&P-S}
      "|" at {&P-C2-S}
      "Дата" at center-field({&P-C2-S}, {&P-C3-S}, 4)
      "|" at {&P-C3-S}
      "Номер" at center-field({&P-C3-S}, {&P-C4-S}, 5)
      "|" at {&P-C4-S}
      " из"
      "|" at {&P-C5-S}
      " в"
      "|" at {&P-C6-S}
      "|" at {&P-E}
    skip
      "|" at {&P-S}
      v-single-line format "X({&P-X0})"
      "|"
  .
/*---E----- Шапка документа ------------------------*/

/*---S------- Печатаем строки документа ---------*/

form with frame f-wth .

case x-radio-task :
  when 1
  then do:
        for each b_wth-doc no-lock  /*Создаем временную таблицу по документам*/
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.fact-date >= x-date-start
            and b_wth-doc.fact-date <= x-date-end
            and b_wth-doc.status_   = {&fact}
           /* and b_wth-doc.borned    = no  */
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
        /*  message b_wth-doc.doc-code view-as alert-box.*/
           run r-wth-fill-tt in this-procedure.
        end.

        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
        by tt-rep-doc.fact-date   by tt-rep-doc.cli-name
        /*     and tt-rep-doc.shift-date >= x-*/
        /*     and tt-rep-doc.shift-date <= x-*/
        :
            { rep/r-wth-mv2.i 1 }
        end.
        { rep/r-wth-mv3.i 1 }

  end.
  when 2
  then do:
        for each b_wth-doc no-lock  /*Создаем временную таблицу по документам*/
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.shift-date >= x-date-start
            and b_wth-doc.shift-date <= x-date-end
            and b_wth-doc.status_   = {&fact}
           /* and b_wth-doc.borned    = no  */
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
           run r-wth-fill-tt in this-procedure.
        end.

        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type  by tt-rep-doc.shift-date
     /*   break by wealth.wth-code  by buf_wth-doc.shift-date by buf_wth-doc.doc-type */
                by tt-rep-doc.cli-name
        :
            { rep/r-wth-mv2.i 2 }
        end.
        { rep/r-wth-mv3.i 2 }
  end.
  when 3
  then do:
        for each b_wth-doc no-lock  /*Создаем временную таблицу по документам*/
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and ( b_wth-doc.shift-date > x-date-start
                  or ( b_wth-doc.shift-date = x-date-start
                       and b_wth-doc.shift-num >= x-shift-start
                     )
                )
            and ( b_wth-doc.shift-date < x-date-end
                  or ( b_wth-doc.shift-date = x-date-end
                       and b_wth-doc.shift-num <= x-shift-end
                     )
                )
            and b_wth-doc.status_   = {&fact}
           /* and b_wth-doc.borned    = no  */
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
           run r-wth-fill-tt in this-procedure.
        end.

        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
               by tt-rep-doc.shift-date   by tt-rep-doc.cli-name
        :
            { rep/r-wth-mv2.i 3 }
        end.
        { rep/r-wth-mv3.i 3 }

  end.
  when 4
  then do:
        for each b_wth-doc no-lock  /*Создаем временную таблицу по документам*/
          where b_wth-doc.obj-type  = buf_clients.obj-type
            and b_wth-doc.obj-code  = buf_clients.obj-code
            and b_wth-doc.shift-date >= x-date-start
            and b_wth-doc.shift-date <= x-date-end
            and b_wth-doc.shift-num = x-shift-alone
            and b_wth-doc.status_   = {&fact}
    /*        and (if x-date-start = x-date-end
                 then  b_wth-doc.borned    = no
                 else true)  */
           /* and b_wth-doc.borned    = no  */
          ,each buf_wth-line
          where buf_wth-line.doc-code = b_wth-doc.doc-code
          break by b_wth-doc.doc-code by buf_wth-line.wth-code by buf_wth-line.w-p-code
          :
                run r-wth-fill-tt in this-procedure.
        end.

        for each tt-rep-doc no-lock
          , each ub.wealth
          where ub.wealth.wth-code = tt-rep-doc.wth-code
          , each buf_wth-place
          where buf_wth-place.host-code = buf_clients.host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
            and buf_wth-place.w-p-code  = tt-rep-doc.w-p-code
        break by tt-rep-doc.wth-code by tt-rep-doc.w-p-code by tt-rep-doc.chk-type by tt-rep-doc.ext-doc-type
        by tt-rep-doc.shift-date   by tt-rep-doc.cli-name
        :
            assign
                x-shift-start   = x-shift-alone
                x-shift-end     = x-shift-alone
            .
                { rep/r-wth-mv2.i 4 }
        end.
        { rep/r-wth-mv3.i 4 }

  end.
end case.

put stream PrnLibStream
  skip
    v-single-line format "X({&P-X0})" at {&P-S} + 1
.
/*---E------- Печатаем строки документа ---------*/
/*      /*---S---- Подписи внизу документа ----------------*/*/
/*        if line-counter( PrnLibStream ) + 8 > page-size( PrnLibStream )*/
/*        then page stream PrnLibStream.*/

/*      /*---E---- Подписи внизу документа ----------------*/*/

hide stream PrnLibStream frame bottomframe .

output stream PrnLibStream close.
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).



end.
procedure r-wth-fill-tt:

      if b_wth-doc.doc-type = {&WDEDT_Dec} and b_wth-doc.doc-type = {&WDEDT_Dst_Cli} then return.  /*Документы декларации уничтожения клиентских талонов не учитываем*/
            create tt-rep-doc.
            buffer-copy buf_wth-line to tt-rep-doc.
            buffer-copy b_wth-doc using cli-name host-code inter_ doc-type ext-doc-type exter_ to tt-rep-doc.

            if b_wth-doc.source-type = {&wthd-cash-desk}
            then tt-rep-doc.chk-type = 99.
            else if b_wth-doc.auto-fill and b_wth-doc.borned = no then
            for first buf_chk-doc no-lock   /*если документ не порожденный, то определяем тип чека*/
             where buf_chk-doc.out-code = b_wth-doc.doc-code
             and buf_chk-doc.obj-type   = b_wth-doc.obj-type
             and buf_chk-doc.obj-code   = b_wth-doc.obj-code:
             tt-rep-doc.chk-type = buf_chk-doc.chk-type.
             tt-rep-doc.ext-doc-type = ''.
            end.
            else if b_wth-doc.auto-fill and b_wth-doc.borned = yes then   /*для порожденного документа тип определяет исходный документ*/
              for first buf_wth-doc no-lock where
                buf_wth-doc.doc-code = b_wth-doc.source-ref
                and buf_wth-doc.auto-fill = yes
             ,first buf_chk-doc no-lock   /*определяем тип чека*/
             where buf_chk-doc.out-code = buf_wth-doc.doc-code
             and buf_chk-doc.obj-type   = buf_wth-doc.obj-type
             and buf_chk-doc.obj-code   = buf_wth-doc.obj-code:
             tt-rep-doc.chk-type = buf_chk-doc.chk-type .
             tt-rep-doc.ext-doc-type = ''.

            end.
            else tt-rep-doc.chk-type = 99.
            if tt-rep-doc.chk-type = 7 then delete tt-rep-doc.  /*декларация*/

end procedure.
/*message*/
/*                  " 0. " + string( x-Date-Alone  )*/
/*  + {&new-line} + " 1. " + string( x-Date-End    )*/
/*  + {&new-line} + " 2. " + string( x-Date-Start  )*/
/*  + {&new-line} + " 3. " + string( x-Shift-Alone )*/
/*  + {&new-line} + " 4. " + string( x-Shift-End   )*/
/*  + {&new-line} + " 5. " + string( x-Shift-Start )*/
/*  + {&new-line} + " 5. " + string( x-TOG-Shift   )*/
/*  + {&new-line} + " 5. " + string( x-Radio-Task  )*/

/*  view-as alert-box.*/
/*return.*/