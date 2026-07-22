block-level on error undo, throw.
/*

$Revision: 20108dc8c1b8, 971, rls $
$Author: EShklyar $
$Date: Tue Apr 18 18:37:36 2017 +0300 $
$Workfile: r-sroki.p $
$Archive: rep/r-sroki.p $

Печать товаров с истекающими сроками годности.

Автор: Чернова Светлана Александровна
Дата создания: 11/20/09
Author: Svetlana Chernova
Creation date: 11/20/09

Автор1: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06

*/
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
define input parameter p-days-amount    as integer          no-undo.
define input parameter p-classificator  as character        no-undo.
define input parameter p-sort-type      as character        no-undo.
define input parameter p-empty-disabled as logical          no-undo.
define input parameter p-free as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 20108dc8c1b8, 971, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 18 18:37:36 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sroki.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sroki.p $":U .
define variable vss-description as character no-undo init "Печать товаров с истекающими сроками годности.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/f-fdec.i }
{ trg/partslib.i }
{ gbl/cur-time.i }
{ gbl/godendo.i  }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }
{ gbl/paramls.i  }
{ ref/grplibfn.i    }

define temp-table temp_result-line no-undo
    field line-order      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field prod-string   as character
    field in-code       as character
    field part-code     as character
    field gds-code      as integer
    field gds-name      as character
    field grp-name      as character
    field supp-string   as character
    field supp-name     as character
    field class-order   as integer
    field pl-name       as character
    field last-date     as date
    field free-qnty     as decimal
    field fact-qnty     as decimal
    field obj-type      as character
    field obj-code      as integer
    field b-code      as integer

    index pi is primary unique
        line-order
    index gds-code
        gds-code
    index artic
        artic
    index gds-name
        gds-name
    index class
        class-order
.
define temp-table temp_classificator no-undo
    field class-order   as integer
    field class-code    as character
    field class1-key    as character
    field class2-key    as character
    field class1-value  as character
    field class2-value  as character

    index pi is primary unique
        class-order
    index code
        class-code
        class1-key
        class2-key
.
define variable v-summi as decimal   no-undo .

&scoped-define left-margin 5
&scoped-define right-margin 200
&scoped-define max-width 193
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

&scoped-define tab-stop1 22

/*----S----- Таблица --------------------------------*/
&scoped-define P-S 2
&scoped-define P-X 195        /*длина линии*/
&scoped-define P-X0 193       /*длина внутренней линии = длина линии - 2*/

&scoped-define P-C3-X  35     /*ширина колонки названия товара*/

&scoped-define P-C2-S  {&P-S} + 11
&scoped-define P-C3-S  {&P-S} + 28
&scoped-define P-C4-S  {&P-S} + 42
&scoped-define P-C5-S  {&P-S} + 82
&scoped-define P-C6-S  {&P-S} + 96
&scoped-define P-C7-S  {&P-S} + 121
&scoped-define P-C8-S  {&P-S} + 142
&scoped-define P-C9-S  {&P-S} + 154
&scoped-define P-C10-S {&P-S} + 184
&scoped-define P-E     {&P-S} + 195

/*----E----- Таблица --------------------------------*/

define stream out-stream .

define variable v-r-sroki-line-counter          as integer      no-undo.
define variable v-r-sroki-single-line           as character    no-undo.
define variable v-r-sroki-first-line-printed    as logical      no-undo.
define variable v-r-sroki-class-order   as integer      no-undo.

define variable v-today         as date         no-undo.
define variable v-time          as integer      no-undo.
define variable v-last-date     as date         no-undo.


define buffer buf_goods                 for goods.
define buffer buf_temp_goods            for gds-list.
define buffer buf_temp_result-line      for temp_result-line.
define buffer buf_temp_classificator    for temp_classificator.
define buffer buf_temp_prod             for g#cli.
define buffer buf_temp_goods-grp        for tmp#grp.

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable tmp#stroka as character no-undo .
define variable num#col# as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .

define stream  macr_excel .
    /* создаем временный файл */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = 1    .
    num#str# = 0 .


do
on error undo, return error
:
    define variable v-data-present                  as logical      no-undo.
    { rep/repfrm.i def   }
    { rep/repfrm.i on 20 }
    assign
        v-r-sroki-line-counter  = 0
        v-r-sroki-single-line   = fill( "-", {&P-X} )
        v-r-sroki-class-order   = 0
    .


    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).

    run godendo-offset-to-date in this-procedure (
          input v-today
        , input p-days-amount
        , output v-last-date
    ).


    case x-SelectGood
    :
        when {&g-all}
        then do:        /* Выбирать по всем товарам */
            for each buf_goods no-lock
            on error undo, return error
            :
            for each obj-list :
                run fill-result-line in this-procedure (
                      input obj-list.obj-type
                    , input obj-list.obj-code
                    , input buf_goods.artic
                    , input buf_goods.prod-type
                    , input buf_goods.prod-code
                    , input p-days-amount
                    , input p-classificator
                ).
            end.        /* for each buf_goods */
            end.        /* for each buf_goods */
        end.        /* when 1 */
        when {&g-prod}
        then do:        /* Товары выбирать по поставщикам */
            for each buf_temp_prod
            on error undo, return error
            :
                for each buf_goods no-lock
                   where buf_goods.prod-type = buf_temp_prod.obj-type
                     and buf_goods.prod-code = buf_temp_prod.obj-code
                on error undo, return error
                :
                    for each obj-list :
                    run fill-result-line in this-procedure (
                          input obj-list.obj-type
                        , input obj-list.obj-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input p-days-amount
                        , input p-classificator
                    ).
                    end.
                end.        /* for each buf_goods */
            end.        /* for each buf_temp_prod */
        end.        /* when 2 */
        when {&g-grp}
        then do:        /* Товары выбирать по группам */
        define variable v-curr-grp-name               as character no-undo .
            for each buf_temp_goods-grp
            on error undo, return error
            :
          run grplib-get-full-name in this-procedure( input buf_temp_goods-grp.node-code, output v-curr-grp-name ) .
          for each buf_goods no-lock
            where buf_goods.grp-name begins v-curr-grp-name
/*          :                                                               */
/*                for each buf_goods no-lock                                */
/*                   where buf_goods.grp-code = buf_temp_goods-grp.node-code*/
                on error undo, return error
                :
                    for each obj-list :
                    run fill-result-line in this-procedure (
                          input obj-list.obj-type
                        , input obj-list.obj-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                        , input p-days-amount
                        , input p-classificator
                    ).
                    end.
                end.        /* for each buf_goods */
            end.        /* for each buf_temp_goods-grp */
        end.        /* when 3 */
        otherwise do:
            for each buf_temp_goods
            on error undo, return error
            :
                for each obj-list :
                run fill-result-line in this-procedure (
                      input obj-list.obj-type
                    , input obj-list.obj-code
                    , input buf_temp_goods.artic
                    , input buf_temp_goods.prod-type
                    , input buf_temp_goods.prod-code
                    , input p-days-amount
                    , input p-classificator
                ).
                end.
            end.
        end.        /* when >4 */
    end case.       /* case x-SelectGood */
    run check-data-presence in this-procedure (
        output v-data-present
    ).
    if v-data-present = yes
    then do:
        { cmp/open-out.i stream out-stream " " ReportPageHeight }
        form header
            space({&P-S}) v-r-sroki-single-line format "X({&P-X})"
            skip "Продолжение - на следующей странице" at 90
            with frame BottomFrame
                width {&DOS_CW_2}
                page-bottom
                no-labels
                no-box
        .
        view stream out-stream frame BottomFrame .
        run print-header in this-procedure.
    end.        /* v-data-present = yes */
    else do:
        message
            substitute("Нет товаров с истекающими сроками годности до &1" , string( v-last-date , "99/99/9999") )
        view-as alert-box information
        title "Нет строк для печати".
        undo, return .
    end.

    define variable old1 as character no-undo .
    define variable v-p as logical   no-undo .

    old1 = "".
    v-summi = 0.
    for each buf_temp_classificator
       where buf_temp_classificator.class-code = p-classificator
    on error undo, return error
    :
        if old1 <> buf_temp_classificator.class1-key then v-p = true .
        else v-p =  false .
        run print-classificator in this-procedure (
            input v-p ,
            input buf_temp_classificator.class-order
        ).

        case p-sort-type
        :
            when "sort-code":U
            then do:
                for each buf_temp_result-line
                   where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                by buf_temp_result-line.b-code
                on error undo, return error
                :
                    run print-line in this-procedure (
                        input buf_temp_result-line.line-order
                    ).
                end.        /* for each buf_temp_result-line */
            end.        /* when "sort-code":U */
            when "sort-artic":U
            then do:
                for each buf_temp_result-line
                   where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                by buf_temp_result-line.artic
                on error undo, return error
                :
                    run print-line in this-procedure (
                        input buf_temp_result-line.line-order
                    ).
                end.        /* for each buf_temp_result-line */
            end.        /* when "sort-artic":U */
            when "sort-name":U
            then do:
                for each buf_temp_result-line
                   where buf_temp_result-line.class-order = buf_temp_classificator.class-order
                by buf_temp_result-line.gds-name
                on error undo, return error
                :
                    run print-line in this-procedure (
                        input buf_temp_result-line.line-order
                    ).
                end. /* for each buf_temp_result-line */
            end.     /* when "sort-name":U */
        end case.    /* case p-sort-type */
        old1 = buf_temp_classificator.class1-key.
    end.   /* for each buf_temp_classificator */


    run print-footer in this-procedure .
    hide stream out-stream frame BottomFrame .
    output stream out-stream close.
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .

    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5,6,7,9,10"
        ) .

  run end-proc .
  Output stream Macr_Excel  close .

    { rep/repfrm.i off }
    define variable v-user-action           as character            no-undo.
    define variable v-printed               as logical              no-undo.
    define variable v-orient-page as character no-undo .
    define variable DisabledOptions as integer   no-undo .
    run How-name in this-procedure (
        input ReportPageHeight,
        input ReportPageWidth,
        output v-orient-page )
        .
    if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                   else DisabledOptions = 0 .


    run gbl/prnfilen.w (
          input "":U
        , input DisabledOptions
        , input string( session :temp-directory ) + {&DF_Name} + string( g#report-num )
        , input REportFontNum
        , output v-user-action
        , output v-printed
    ) .
end.


/*==========================================================================*/
procedure fill-result-line :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.
define input parameter p-days-amount    as integer          no-undo.
define input parameter p-classificator  as character        no-undo.

    define variable v-supp-string   as character    no-undo.
    define variable v-supp-name     as character    no-undo.
    define variable v-pl-name       as character    no-undo.

    define variable v-class1-key    as character    no-undo.
    define variable v-class1-value  as character    no-undo.
    define variable v-class2-key    as character    no-undo.
    define variable v-class2-value  as character    no-undo.

    define buffer buf_goods                 for goods.
    define buffer buf_pl-gds                for pl-gds.
    define buffer buf_place                 for place.
    define buffer buf_supp_clients          for clients.
    define buffer buf_temp_parts            for temp-parts.
    define buffer buf_temp_result-line      for temp_result-line.
    define buffer buf_temp_classificator    for temp_classificator.
do
for buf_goods
  , buf_place
  , buf_supp_clients
  , buf_temp_parts
  , buf_temp_result-line
  , buf_temp_classificator
on error undo, return error
:
    run partslib-init-temp-parts in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-artic
        , input p-prod-type
        , input p-prod-code
    ).


    find first buf_goods no-lock
         where buf_goods.artic     = p-artic
           and buf_goods.prod-type = p-prod-type
           and buf_goods.prod-code = p-prod-code
    .
    for each buf_pl-gds no-lock
       where buf_pl-gds.gds-code  = buf_goods.gds-code
         and buf_pl-gds.obj-type  = p-obj-type
         and buf_pl-gds.obj-code  = p-obj-code
    on error undo, return error
    :
        find first buf_place no-lock
             where buf_place.obj-type   = p-obj-type
               and buf_place.obj-code   = p-obj-code
               and buf_place.pl-code    = buf_pl-gds.pl-code
        no-error.
        if available buf_place
        then do:
            assign
                v-pl-name = v-pl-name
                            + ( if v-pl-name = "" then "" else "," )
                            + buf_place.pl-name
            .
        end.        /* if available buf_place */
    end.        /* for each buf_pl-gds */
    cycle-parts-of-goods:
    for each buf_temp_parts
    on error undo, return error
    :
        if p-empty-disabled = yes
        and buf_temp_parts.last-date = ?
        then do:
            undo cycle-parts-of-goods, next cycle-parts-of-goods.
        end.
        if p-days-amount = 0
        or buf_temp_parts.last-date <= v-last-date
        then do:
            assign
                v-r-sroki-line-counter = v-r-sroki-line-counter + 1
            .
            find first buf_supp_clients no-lock
                 where buf_supp_clients.obj-type = buf_temp_parts.supp-type
                   and buf_supp_clients.obj-code = buf_temp_parts.supp-code
            no-error.
            if available buf_supp_clients
            then do:
                assign
                    v-supp-string   = substitute( "&1 &2", buf_temp_parts.supp-type, buf_temp_parts.supp-code )
                    v-supp-name     = buf_supp_clients.obj-name
                .
            end.
            else do:
                assign
                    v-supp-string   = "нет"
                    v-supp-name     = ""
                .
            end.
            find first ub.bar-code no-lock where
                       ub.bar-code.gds-code   = buf_goods.gds-code and
                       ub.bar-code.in-code    = buf_temp_parts.in-code  and
                       ub.bar-code.part-code  = buf_temp_parts.part-code and
                       ub.bar-code.unit-cli   = buf_goods.unit-base
                       no-error .

            create buf_temp_result-line.
            assign
                buf_temp_result-line.line-order     = v-r-sroki-line-counter * 10
                buf_temp_result-line.artic          = p-artic
                buf_temp_result-line.prod-type      = p-prod-type
                buf_temp_result-line.prod-code      = p-prod-code
                buf_temp_result-line.prod-string    = substitute( "&1 &2", p-prod-type, p-prod-code )
                buf_temp_result-line.in-code        = buf_temp_parts.in-code
                buf_temp_result-line.supp-string    = v-supp-string
                buf_temp_result-line.supp-name      = v-supp-name
                buf_temp_result-line.part-code      = buf_temp_parts.part-code
                buf_temp_result-line.gds-code       = buf_goods.gds-code
                buf_temp_result-line.b-code         = if available ub.bar-code then ub.bar-code.b-code else 0
                buf_temp_result-line.gds-name       = buf_goods.gds-name
                buf_temp_result-line.grp-name       = buf_goods.grp-name
                buf_temp_result-line.pl-name        = v-pl-name
                buf_temp_result-line.last-date      = buf_temp_parts.last-date
                buf_temp_result-line.free-qnty      = buf_temp_parts.free-qnty
                buf_temp_result-line.fact-qnty      = buf_temp_parts.fact-qnty
                buf_temp_result-line.obj-type       = p-obj-type
                buf_temp_result-line.obj-code       = p-obj-code
            .
            case p-classificator
            :
                when "no-classify":U
                then do:
                    assign
                        v-class1-key   = ""
                        v-class1-value = ""
                        v-class2-key   = ""
                        v-class2-value = ""
                    .
                end.        /* when "no-classify":U */
                when "prod":U
                then do:
                    assign
                        v-class1-key   = substitute( "&1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                        v-class1-value = substitute( "Производитель: &1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                        v-class2-key   = ""
                        v-class2-value = ""
                    .
                end.        /* when "prod":U */
                when "grp-goods":U
                then do:
                    assign
                        v-class1-key   = buf_temp_result-line.grp-name
                        v-class1-value = substitute( "Группа: &1", buf_temp_result-line.grp-name )
                        v-class2-key   = ""
                        v-class2-value = ""
                    .
                end.        /* when "grp-goods":U */
                when "prod/grp-goods":U
                then do:
                    assign
                        v-class1-key   = substitute( "&1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                        v-class1-value = substitute( "Производитель: &1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                        v-class2-key   = buf_temp_result-line.grp-name
                        v-class2-value = substitute( "Группа: &1", buf_temp_result-line.grp-name )
                    .
                end.        /* when "prod/grp-goods":U */
                when "grp-goods/prod":U
                then do:
                    assign
                        v-class1-key   = buf_temp_result-line.grp-name
                        v-class1-value = substitute( "Группа: &1", buf_temp_result-line.grp-name )
                        v-class2-key   = substitute( "&1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                        v-class2-value = substitute( "Производитель: &1 &2", buf_temp_result-line.prod-type, buf_temp_result-line.prod-code )
                    .
                end.        /* when "grp-goods/prod":U */
            end case.       /* case p-classificator */
            find first buf_temp_classificator
                 where buf_temp_classificator.class-code   = p-classificator
                   and buf_temp_classificator.class1-key   = v-class1-key
                   and buf_temp_classificator.class2-key   = v-class2-key
            no-error.
            if not available buf_temp_classificator
            then do:
                assign
                    v-r-sroki-class-order = v-r-sroki-class-order + 1
                .
                create buf_temp_classificator.
                assign
                    buf_temp_classificator.class-order  = v-r-sroki-class-order
                    buf_temp_classificator.class-code   = p-classificator
                    buf_temp_classificator.class1-key   = v-class1-key
                    buf_temp_classificator.class2-key   = v-class2-key
                    buf_temp_classificator.class1-value = v-class1-value
                    buf_temp_classificator.class2-value = v-class2-value
                .
            end.
            assign
                buf_temp_result-line.class-order = buf_temp_classificator.class-order
            .
            { rep/repfrm.i disp v-r-sroki-line-counter reportname }
        end.        /* if p-days-amount = 0 */
    end.        /* for each buf_temp_parts */
end.
end procedure. /* fill-result-line */


/*==========================================================================*/
procedure check-data-presence :
define output parameter p-data-present  as logical          no-undo.

    define buffer buf_temp_result-line      for temp_result-line.
do
for buf_temp_result-line
on error undo, return error
:
    find first buf_temp_result-line
    no-error.
    if available buf_temp_result-line
    then do:
        assign
            p-data-present = yes
        .
    end.
    else do:
        assign
            p-data-present = no
        .
    end.
end.
end procedure. /* check-data-presence */
/*==========================================================================*/

procedure print-header :
define variable i as integer         no-undo .
do
on error undo, return error
:

if p-days-amount = 0 then tmp#stroka  = substitute("Отчет по товарам по срокам годности на &1 (без проверки срока)" ,string( v-today, "99/99/9999") ).
else tmp#stroka  = substitute ("Отчет по товарам по срокам годности на &1 (последний срок до &2)" , string( v-today, "99/99/9999") , string( v-last-date, "99/99/9999" ) ).
    put stream out-stream unformatted
        skip(1)
        skip space( {&tab-stop1} )
        tmp#stroka
        skip
    .

    str1 = tmp#stroka .
    if p-empty-disabled then str1 = str1 + " товары с указанным сроком годности" .
     put stream out-stream str2 at 1 format "x(200)"  skip .

     repeat i = 1 to num-entries(str4,chr(10)) :
       put stream out-stream  entry(i,str4,chr(10))  at 1 format "x(170)" skip .
     end.

     repeat i = 1 to num-entries(reportheader,chr(10)) :
       put stream out-stream  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip .

     end.

      num#str# = num#str# + 1 .
      num#col# =  1 .

      run macr_excel_char_with_format ( ReportNAme , num#str# , num#col#  ).
      run macr_cell_format
          ( 12    ,     /* p-size */
            true  ,     /*p-bold   */
            false ,     /*p-italic */
            ?     ,     /*p-color  */
            num#str# ,  /*p-row    */
            num#col# ,  /*p-col    */
            ? ,         /*p-row-2  */
            ?         ) . /*p-col-2 */



define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .

&scop var-print-n    do l-ii = 1 to num-entries( ~{&var-str-n} , "~{&new-line}"  )    :  ~
      l-len = length (entry( l-ii , ~{&var-str-n}  , "~{&new-line}")) .                 ~
      l-m = integer( l-len / 220 ) + 1 .                                                ~
      do l-jj = 1 to  l-m  :                                                            ~
          num#str# = num#str# + 1 .                                                     ~
          run macr_excel_char_with_format (                                             ~
              substring(entry( l-ii , ~{&var-str-n}  , "~{&new-line}") , (( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .~
      end.                                                                                                       ~
  end.

&scop var-str-n  str1
{&var-print-n }
&scop var-str-n  str2
{&var-print-n }
&scop var-str-n  str3
{&var-print-n }
&scop var-str-n  str4
{&var-print-n }
&scop var-str-n  reportheader
{&var-print-n }


  num#str# = num#str# + 1.
  num#col# = 1.

    put stream out-stream
        skip(1)
        space({&P-S})
            v-r-sroki-single-line   format "X({&P-X})"
        skip space({&P-S})  "|"
            "БарКод"                at center-field({&P-S} + 1, {&P-C2-S}, 3)
            "|"                     at {&P-C2-S}
            "Артикул"               at center-field({&P-C2-S}, {&P-C3-S}, 7)
            "|"                     at {&P-C3-S}
            "Производитель"         at center-field({&P-C3-S}, {&P-C4-S}, 13)
            "|"                     at {&P-C4-S}
            "Наименование товара"   at {&P-C4-S} + 2
            "|"                     at {&P-C5-S}
            "Поставщик"             at center-field({&P-C5-S}, {&P-C6-S}, 9)
            "|"                     at {&P-C6-S}
            "Имя поставщика"        at {&P-C6-S} + 2
            "|"                     at {&P-C7-S}
            "Партия"                at center-field({&P-C7-S}, {&P-C8-S}, 6)
            "|"                     at {&P-C8-S}
            "Количество"            at center-field({&P-C8-S}, {&P-C9-S}, 10)
            "|"                     at {&P-C9-S}
            "Объект и Место хранения"        at {&P-C9-S} + 2
            "|"                     at {&P-C10-S}
            "Дата"                  at center-field({&P-C10-S}, {&P-E}, 4)
            "|"                     at {&P-E}
        skip space({&P-S})
            "|" v-r-sroki-single-line format "X({&P-X0})" "|"
    .
    run proc-print-header.

end.
end procedure. /* print-header */


/*==========================================================================*/
procedure print-line :

define input parameter p-line-order     as integer          no-undo.

    define buffer buf_temp_result-line          for temp_result-line.
do
for buf_temp_result-line
on error undo, return error
:
    find first buf_temp_result-line
         where buf_temp_result-line.line-order = p-line-order
    .
    put stream out-stream
        skip space({&P-S}) "|"
            buf_temp_result-line.b-code        format "999999999"
            "|"                     at {&P-C2-S}
            buf_temp_result-line.artic           format "X(16)"
            "|"                     at {&P-C3-S}
            buf_temp_result-line.prod-string     format "X(13)"
            "|"                     at {&P-C4-S}
            buf_temp_result-line.gds-name        format "X(39)"
            "|"                     at {&P-C5-S}
            buf_temp_result-line.supp-string     format "X(13)"
            "|"                     at {&P-C6-S}
            buf_temp_result-line.supp-name       format "X(24)"
            "|"                     at {&P-C7-S}
            buf_temp_result-line.part-code       format "X(20)"
            "|"                     at {&P-C8-S}
            (if p-free then buf_temp_result-line.free-qnty else buf_temp_result-line.fact-qnty)       format "->>>>>>9.99"
            "|"                     at {&P-C9-S}
            substitute("&1&2 &3" , buf_temp_result-line.obj-type ,buf_temp_result-line.obj-code, buf_temp_result-line.pl-name )   format "X(29)"
            "|"                     at {&P-C10-S}
            buf_temp_result-line.last-date       format "99.99.9999"
            "|"                     at {&P-E}
    .

  num#str# = num#str# + 1 .
  num#col# =  1 .
  run macr_excel_char ( buf_temp_result-line.b-code       , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.artic        , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.prod-string  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.gds-name     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.supp-string  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.supp-name    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.part-code    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_dec  ( (if p-free then buf_temp_result-line.free-qnty else buf_temp_result-line.fact-qnty)    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( substitute("&1&2 &3" , buf_temp_result-line.obj-type ,buf_temp_result-line.obj-code, buf_temp_result-line.pl-name )  , num#str#,  num#col# )              . num#col# = num#col# + 1 .
  run macr_excel_char ( string ( buf_temp_result-line.last-date, "99/99/9999"), num#str#, num#col#  ). num#col# = num#col# + 1 .
  v-summi = v-summi + (if p-free then buf_temp_result-line.free-qnty else buf_temp_result-line.fact-qnty) .
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-classificator :
define input parameter p-one as logical   no-undo .
define input parameter p-class-order    as integer          no-undo.

    define buffer buf_temp_classificator        for temp_classificator.
do
for buf_temp_classificator
on error undo, return error
:
    find first buf_temp_classificator
         where buf_temp_classificator.class-order = p-class-order
    .
    if buf_temp_classificator.class-code = "no-classify":U
    then do:
        undo, return .
    end.

if p-one = true then do:
    if v-r-sroki-first-line-printed = no
    then do:
        assign
            v-r-sroki-first-line-printed = yes
        .
    end.        /* if v-r-sroki-first-line-printed = no */
    else do:
        put stream out-stream
            skip space({&P-S})
                "|" v-r-sroki-single-line format "X({&P-X0})" "|"
        .
    end.        /* NOT ( if v-r-sroki-first-line-printed = no ) */
    put stream out-stream
        skip space({&P-S})
                "|"
                buf_temp_classificator.class1-value format "X({&max-width})"
                "|"             at {&P-E}
    .


  num#str# = num#str# + 1 .
  num#col# =  1 .
  var-1 = num#str# .
  var-2 = num#col# .

  run macr_excel_char(  buf_temp_classificator.class1-value , num#str# , num#col#  ).  num#col# = num#col# + 1.
  run macr_cell_format
  ( 10    ,      /* p-size     */
    true  ,      /* p-bold     */
    true  ,      /* p-italic   */
    40    ,      /* p-color-bg */
    var-1 ,      /* p-row      */
    var-2 ,      /* p-col      */
    num#str# ,   /* p-row-2    */
    10 ) . /* p-col-2    */

end.

    if buf_temp_classificator.class2-key <> ""
    then do:
        put stream out-stream
            skip space({&P-S})
                "|" v-r-sroki-single-line format "X({&P-X0})" "|"
            skip space({&P-S})
                "|"
                buf_temp_classificator.class2-value format "X({&max-width})"
                "|"             at {&P-E}
        .
        num#str# = num#str# + 1 .
        num#col# =  1 .
        var-1 = num#str# .
        var-2 = num#col# .
        run macr_excel_char ( buf_temp_classificator.class2-value     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
        run macr_cell_format
        ( 10    ,      /* p-size     */
          true  ,      /* p-bold     */
          true  ,      /* p-italic   */
          33    ,      /* p-color-bg */
          var-1 ,      /* p-row      */
          var-2 ,      /* p-col      */
          num#str# ,   /* p-row-2    */
          10 ) . /* p-col-2    */


    end.

end.
end procedure. /* print-classificator */

/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:
    put stream out-stream
        skip space({&P-S})
            v-r-sroki-single-line   format "X({&P-X})" skip
    .
    put stream out-stream unformatted  " Итого количество: "  v-summi skip.

        num#str# = num#str# + 1 .
        num#col# =  1 .
        var-1 = num#str# .
        var-2 = num#col# .
        run macr_excel_char ( "ИТОГО"     , num#str# , num#col#  ) . num#col# = num#col# + 7 .
        run macr_excel_dec ( v-summi     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
        run macr_cell_format
        ( 10     ,      /* p-size     */
          true   ,      /* p-bold     */
          false  ,      /* p-italic   */
          ?    ,      /* p-color-bg */
          var-1 ,      /* p-row      */
          var-2 ,      /* p-col      */
          num#str# ,   /* p-row-2    */
          10 ) . /* p-col-2    */
end.
end procedure. /* print-footer */

{ rep/r-libmcr.i macr_excel         }