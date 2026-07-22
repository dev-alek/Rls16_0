block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-defect.p $
$Archive: rep/r-defect.p $

Отчет по ФиБ.

Автор: Чернова Светлана Александровна
Дата создания: 12/18/09
Author: Svetlana Chernova
Creation date: 12/18/09

*/

define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
define input parameter p-classificator  as character        no-undo.
define input parameter p-sort-type      as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-defect.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-defect.p $":U .
define variable vss-description as character no-undo init "Отчет по ФиБ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/f-fdec.i   }
{ trg/partslib.i }
{ gbl/cur-time.i }
{ gbl/godendo.i  }
{ rep/rep-bt.i   }
{ rep/lkp-font.i }
{ gbl/paramls.i  }

define temp-table temp_result-line no-undo
    field line-order      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field prod-string   as character
    field in-code       as character
    field fact-date     as date
    field part-code     as character
    field gds-code      as integer
    field b-code        as integer
    field gds-name      as character
    field grp-name      as character
    field supp-string   as character
    field supp-name     as character
    field class-order   as integer
    field pl-name       as character
    field last-date     as date
    field free-qnty     as decimal
    field obj-type      as character
    field obj-code      as integer
    field price-prod    as decimal
    field price-prodvat as decimal
    field prodvat       as decimal
    field price-sale    as decimal
    field price-rubl    as decimal

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
define variable v-data-present                  as logical      no-undo.

&scoped-define left-margin 5
&scoped-define right-margin 200
&scoped-define max-width 193
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

&scoped-define tab-stop1 22

/*----S----- Таблица --------------------------------*/
&scoped-define P-S 0
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
&scoped-define P-C10-S {&P-S} + 170
&scoped-define P-C11-S {&P-S} + 184
&scoped-define P-E     {&P-S} + 195

/*----E----- Таблица --------------------------------*/

define stream out-stream .

define variable v-fib-line-counter          as integer      no-undo.
define variable v-fib-single-line           as character    no-undo.
define variable v-fib-first-line-printed    as logical      no-undo.
define variable v-fib-class-order   as integer      no-undo.

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
define variable v-customer as logical   no-undo .

define stream  macr_excel .
    /* создаем временный файл */
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = 1    .
    num#str# = 0 .


do
on error undo, return error
:
    { rep/repfrm.i def   }
    { rep/repfrm.i on 20 }
    assign
        v-fib-line-counter  = 0
        v-fib-single-line   = fill( "-", {&P-X} )
        v-fib-class-order   = 0
    .
    v-customer = false .
    find first g#customer no-error .
    if available g#customer then  v-customer = true .

    run cur-time in this-procedure (
          output v-today
        , output v-time
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
                    , input p-classificator
                ).
            end.        /* for each buf_goods */
            end.        /* for each buf_goods */
        end.        /* when 1 */
        when {&g-grp}
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
                        , input p-classificator
                    ).
                    end.
                end.        /* for each buf_goods */
            end.        /* for each buf_temp_prod */
        end.        /* when 2 */
        when {&g-prod}
        then do:        /* Товары выбирать по группам */
            for each buf_temp_goods-grp
            on error undo, return error
            :
                for each buf_goods no-lock
                   where buf_goods.grp-code = buf_temp_goods-grp.node-code
                on error undo, return error
                :
                    for each obj-list :
                    run fill-result-line in this-procedure (
                          input obj-list.obj-type
                        , input obj-list.obj-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
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
                    , input p-classificator
                ).
                end.
            end.
        end.        /* when 4 */
    end case.       /* case x-SelectGood */
    run check-data-presence in this-procedure (
        output v-data-present
    ).
    if v-data-present = yes
    then do:
        { cmp/open-out.i stream out-stream " " ReportPageHeight }
        form header
            space({&P-S}) v-fib-single-line format "X({&P-X})"
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
            substitute("Нет ФиБ партий" )
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
                by buf_temp_result-line.gds-code
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
        ,input "1,2,3,4,5,6,7,9,10,11"
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
define input parameter p-classificator  as character        no-undo.
define buffer buf_parts for ub.parts  .


define variable v-supp-string   as character    no-undo.
define variable v-supp-name     as character    no-undo.
define variable v-pl-name       as character    no-undo.

define variable v-class1-key    as character    no-undo.
define variable v-class1-value  as character    no-undo.
define variable v-class2-key    as character    no-undo.
define variable v-class2-value  as character    no-undo.
define variable v-cur-dn        as character no-undo .
define variable v-cur-rt        as decimal   no-undo .
define variable v-cur-ex        as decimal   no-undo .


define buffer buf_goods                 for ub.goods.
define buffer buf_pl-gds                for ub.pl-gds.
define buffer buf_place                 for ub.place.
define buffer buf_supp_clients          for ub.clients.
define buffer buf_temp_parts            for temp-parts.
define buffer buf_temp_result-line      for temp_result-line.
define buffer buf_temp_classificator    for temp_classificator.

do
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
    cycle-parts-of-goods:
    for each buf_temp_parts where
             buf_temp_parts.fact-date >= x-Date-Start and
             buf_temp_parts.fact-date <= x-Date-End
    on error undo, return error
    :
        if v-customer then do:
           find first g#customer where
                      g#customer.obj-code = buf_temp_parts.supp-code and
                      g#customer.obj-type = buf_temp_parts.supp-type no-error .
           if not available g#customer then next cycle-parts-of-goods.
        end.


        if buf_temp_parts.defect = logical({&FiB})
        then do:
            assign
                v-fib-line-counter = v-fib-line-counter + 1
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
            create buf_temp_result-line.
            assign
                buf_temp_result-line.line-order     = v-fib-line-counter * 10
                buf_temp_result-line.artic          = p-artic
                buf_temp_result-line.prod-type      = p-prod-type
                buf_temp_result-line.prod-code      = p-prod-code
                buf_temp_result-line.prod-string    = substitute( "&1 &2", p-prod-type, p-prod-code )
                buf_temp_result-line.in-code        = buf_temp_parts.in-code
                buf_temp_result-line.fact-date      = buf_temp_parts.fact-date
                buf_temp_result-line.supp-string    = v-supp-string
                buf_temp_result-line.supp-name      = v-supp-name
                buf_temp_result-line.part-code      = buf_temp_parts.part-code
                buf_temp_result-line.gds-code       = buf_goods.gds-code
                buf_temp_result-line.gds-name       = buf_goods.gds-name
                buf_temp_result-line.grp-name       = buf_goods.grp-name
                buf_temp_result-line.last-date      = buf_temp_parts.last-date
                buf_temp_result-line.free-qnty      = buf_temp_parts.free-qnty
                buf_temp_result-line.obj-type       = p-obj-type
                buf_temp_result-line.obj-code       = p-obj-code
                buf_temp_result-line.price-rubl     = buf_temp_parts.price-rubl
            .
              find first buf_parts no-lock where
                    buf_parts.obj-type  = buf_temp_parts.obj-type  and
                    buf_parts.obj-code  = buf_temp_parts.obj-code  and
                    buf_parts.artic     = buf_temp_parts.artic     and
                    buf_parts.prod-type = buf_temp_parts.prod-type and
                    buf_parts.prod-code = buf_temp_parts.prod-code and
                    buf_parts.in-code   = buf_temp_parts.in-code   and
                    buf_parts.out-code  = buf_temp_parts.out-code  and
                    buf_parts.part-code = buf_temp_parts.part-code
                    no-error .
              if available buf_parts then do:


                  { gbl/partppric.i
                    buf_parts
                    buf_temp_result-line.price-prod
                    buf_temp_result-line.price-prodvat
                    buf_temp_result-line.prodvat
                  }

                  { gbl/partbcod.i
                    buf_parts
                    buf_temp_result-line.b-code
                    no-error
                  }
              end.
            { gbl/bcodeprc.i
                buf_temp_result-line.obj-type
                buf_temp_result-line.obj-code
                buf_temp_result-line.b-code
                0
                0
                v-cur-dn
                buf_temp_result-line.price-sale
                v-cur-rt
                v-cur-ex
                no-error }


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
                    v-fib-class-order = v-fib-class-order + 1
                .
                create buf_temp_classificator.
                assign
                    buf_temp_classificator.class-order  = v-fib-class-order
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
            { rep/repfrm.i disp v-fib-line-counter reportname }
        end.        /* if */
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

 tmp#stroka = "" .
    put stream out-stream unformatted
        skip(1)
        skip space( {&tab-stop1} )
        ReportName
        skip
    .

    str1 = tmp#stroka .
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
          ( 12    ,       /* p-size */
            true  ,       /* p-bold   */
            false ,       /* p-italic */
            ?     ,       /* p-color  */
            num#str# ,    /* p-row    */
            num#col# ,    /* p-col    */
            ? ,           /* p-row-2  */
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
            v-fib-single-line   format "X({&P-X})"
        skip space({&P-S})  "|"
            "Бар-Код"               at ({&P-S} + 2)
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
            "Остаток"               at center-field({&P-C8-S}, {&P-C9-S}, 10)
            "|"                     at {&P-C9-S}
            "Объект"                at {&P-C9-S} + 2
            "|"                     at {&P-C10-S}
            "ПН"                    at center-field({&P-C10-S}, {&P-E}, 4)
            "|"                     at {&P-C11-S}
            "Дата ПН"               at center-field({&P-C11-S}, {&P-E}, 4)
            "|"                     at {&P-E}
        skip space({&P-S})
            "|" v-fib-single-line format "X({&P-X0})" "|"
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
            buf_temp_result-line.free-qnty       format "->>>>>>9.99"
            "|"                     at {&P-C9-S}
            substitute("&1&2" , buf_temp_result-line.obj-type ,buf_temp_result-line.obj-code )   format "X(10)"
            "|"                     at {&P-C10-S}
            buf_temp_result-line.in-code         format "X(13)"
            "|"                     at {&P-C11-S}
            buf_temp_result-line.fact-date       format "99/99/9999"
            "|"                     at {&P-E}
    .

  num#str# = num#str# + 1 .
  num#col# =  1 .
  run macr_excel_char ( buf_temp_result-line.b-code     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.artic        , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.prod-string  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.gds-name     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.supp-string  , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.supp-name    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.part-code    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_dec  ( buf_temp_result-line.free-qnty    , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_char ( substitute("&1&2" , buf_temp_result-line.obj-type ,buf_temp_result-line.obj-code)  , num#str#,  num#col# )              . num#col# = num#col# + 1 .
  run macr_excel_char ( buf_temp_result-line.in-code, num#str#, num#col#  ). num#col# = num#col# + 1 .
  run macr_excel_char ( string ( buf_temp_result-line.fact-date, "99/99/9999"), num#str#, num#col#  ). num#col# = num#col# + 1 .
  run macr_excel_dec  ( buf_temp_result-line.price-rubl , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_dec  ( buf_temp_result-line.price-sale , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  run macr_excel_dec  ( buf_temp_result-line.price-prod , num#str# , num#col#  ) . num#col# = num#col# + 1 .
  v-summi = v-summi + buf_temp_result-line.free-qnty .
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
    if v-fib-first-line-printed = no
    then do:
        assign
            v-fib-first-line-printed = yes
        .
    end.        /* if v-fib-first-line-printed = no */
    else do:
        put stream out-stream
            skip space({&P-S})
                "|" v-fib-single-line format "X({&P-X0})" "|"
        .
    end.        /* NOT ( if v-fib-first-line-printed = no ) */
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
                "|" v-fib-single-line format "X({&P-X0})" "|"
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
            v-fib-single-line   format "X({&P-X})" skip
    .
    put stream out-stream unformatted  " Итого "  v-summi skip.

        num#str# = num#str# + 1 .
        num#col# =  1 .
        var-1 = num#str# .
        var-2 = num#col# .
        run macr_excel_char ( "ИТОГО"     , num#str# , num#col#  ) . num#col# = num#col# + 1 .
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