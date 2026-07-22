block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: zeroinv.p $
$Archive: rep/zeroinv.p $

Пустографка

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 14/06/01
*/

define input parameter p-mainmenu-handle    as handle           no-undo .
define input parameter p-trn-doc-recid      as recid            no-undo .
define input parameter p-alldocs-handle     as character           no-undo .
define input parameter p-current-doc-only   as logical          no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: zeroinv.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/zeroinv.p $":U .
def var vss-description as character no-undo init "Пустографка".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new  }
{ rep/r-sym.i       }
{ gbl/waitfram.i    }
{ gbl/getcntxt.i def }

&scoped-define gds-name-length 30

&scoped-define fill-temp-table-current-doc ~
        find first temp_goods ~
             where temp_goods.artic     = buf_doc-line.artic ~
               and temp_goods.prod-type = buf_doc-line.prod-type ~
               and temp_goods.prod-code = buf_doc-line.prod-code ~
        no-error. ~
        if not available temp_goods ~
        then do: ~
            find first buf_goods no-lock ~
                 where buf_goods.artic      = buf_doc-line.artic ~
                   and buf_goods.prod-type  = buf_doc-line.prod-type ~
                   and buf_goods.prod-code  = buf_doc-line.prod-code ~
            no-error. ~
            create temp_goods no-error. ~
            assign ~
                temp_goods.obj-type         = buf_doc-line.obj-type ~
                temp_goods.obj-code         = buf_doc-line.obj-code ~
                temp_goods.artic            = buf_doc-line.artic ~
                temp_goods.prod-type        = buf_doc-line.prod-type ~
                temp_goods.prod-code        = buf_doc-line.prod-code ~
                temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 ) ~
                temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" ) ~
                temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" ) ~
                no-error. ~
        end. /*if not available*/

&scoped-define fill-temp-table-all-docs ~
            find first temp_goods ~
                 where temp_goods.artic     = buf_doc-line.artic ~
                   and temp_goods.prod-type = buf_doc-line.prod-type ~
                   and temp_goods.prod-code = buf_doc-line.prod-code ~
            no-error. ~
            if not available temp_goods ~
            then do: ~
                find first buf_goods no-lock ~
                     where buf_goods.artic      = buf_doc-line.artic ~
                       and buf_goods.prod-type  = buf_doc-line.prod-type ~
                       and buf_goods.prod-code  = buf_doc-line.prod-code ~
                . ~
                create temp_goods no-error. ~
                assign ~
                    temp_goods.artic      = buf_doc-line.artic ~
                    temp_goods.obj-code   = buf_doc-line.obj-code ~
                    temp_goods.obj-type   = buf_doc-line.obj-type ~
                    temp_goods.prod-code  = buf_doc-line.prod-code ~
                    temp_goods.prod-type  = buf_doc-line.prod-type ~
                    temp_goods.gds-code   = buf_goods.gds-code ~
                    temp_goods.gds-name   = buf_goods.gds-name ~
                no-error. ~
            end.        /* if not available temp_goods */

DEFINE BUFFER t-doc FOR trn-doc.
/*DEFINE SHARED QUERY br-docs FOR t-doc SCROLLING.*/

define shared variable  sort-name    as logical  no-undo.
define shared variable  sort-gr      as logical  no-undo.

define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.

define variable v-lines-counter     as int no-undo.
define variable v-br-docs-query     as handle    no-undo .
define variable v-t-doc-handle      as handle    no-undo .
define variable v-curr-query-rowid  as rowid     no-undo .

def temp-table temp_goods no-undo
    field obj-type      as character
    field obj-code      as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field gds-name      as character
    field full-grp-name as character

    index byart is primary unique artic prod-type prod-code
    index byname gds-name artic
    index bygrp full-grp-name
.

define stream OutStream.

define variable v-fact-qnty     as decimal      init 0  no-undo.
define variable v-line-string   as character            no-undo.
define variable v-doc-string    as character            no-undo.
define variable v-bar-code      as integer              no-undo.
define variable v-dif           as char                 no-undo.
define variable v-str           as char                 no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define buffer buf_goods     for goods.

/* ************** frame 1 для формы **************************************************************************** */
 DEFINE FRAME zapas
        v-lines-counter     column-label "№"            format ">>>>>>>9":C             space(0)
        sym1                column-label ":"            format "x(1)"                   space(0)
        GOODS.GDS-CODE      column-label "Код"          format ">>>>>>>>9"              space(0)
        sym2                column-label ":"            format "x(1)"                   space(0)
        Goods.artic         column-label "Артикул"      format "X(16)"                  space(0)
        sym3                column-label ":"            format "x(1)"                   space(0)
        Goods.gds-name      column-label "Наименование" format "X({&gds-name-length})"  space(0)
        sym4                column-label ":"            format "x(1)"                   space(0)
        Goods.unit-base     column-label "ед.изм"       format "X(6)"                   space(0)
        sym5                column-label ":"            format "x(1)"                   space(0)
        Gds-obj.fact-qnty   column-label "Кол-во уч."   format "->>>>>9.<<<"            space(0)
        sym6                column-label ":"            format "x(1)"                   space(0)
        bar-code.b-code     column-label "Бар-код"       format ">>>>>>>>>>>>>>>9":L16   space(0)
        sym7                column-label ":"            format "x(1)"                   space(0)
        Gds-obj.price-sale  column-label "Розн. цена"   format "->>>>>>>>9.<<"          space(0)
        sym8                column-label ":"            format "x(1)"                   space(0)
        v-fact-qnty         column-label "Факт. кол-во" format "->>>>>>>>>>"            space(0)
    HEADER
        cur-time-print()                                                        at 5    format "X(35)"
        string( "Объект " + string( v-cntxt-obj-type) + " " + string( v-cntxt-obj-code) )   at 48   format "X(13)"
        v-doc-string                                                            at 67   format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") )    at 111  format "X(17)"
    skip
        v-line-string  format "X(126)"  with width {&A4_CW0} down stream-io use-text NO-BOX.
/*===================================================================================================================*/
     run rep/zeroinvd.w ( output v-dif ) no-error.
    if error-status :error then do:
      assign
        v-dif = "all"
      .
    end.
    { gbl/working.i }
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    { cmp/open-out.i stream OutStream " " }
    case v-dif:
      when "all" then do:
        assign
          v-str = ""
        .
      end.
      when "shortage" then do:
        assign
          v-str = " (НЕДОСТАЧА)"
        .
      end.
      when "surplus" then do:
        assign
          v-str = " (ИЗЛИШКИ)"
        .
      end.
      when "coincidence" then do:
        assign
          v-str = " (СОВПАДЕНИЕ)"
        .
      end.
      when "zero-remainder" then do:
        assign
          v-str = " (НУЛЕВОЙ ОСТАТОК)"
        .
      end.
      otherwise do:
        assign
          v-str = ""
        .
      end.
    end case.

    put stream OutStream
        string( "СПИСОК ТОВАРОВ" + v-str ) AT 50 format "X(85)"
    skip(2).
    form with frame zapas .
    assign
        v-line-string = fill("-", 129)
    .
    form header
        v-line-string format "X(129)" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream OutStream frame BottomFrame .

if p-current-doc-only = yes
then do:
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
    assign
        v-doc-string = "По документу N " + buf_trn-doc.doc-code + " от " + string( buf_trn-doc.doc-date, "99/99/9999" )
    .
    case v-dif:
      when "all" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
        :
          {&fill-temp-table-current-doc}
        end.
      end.
      when "shortage" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty < 0
        :
          {&fill-temp-table-current-doc}
        end.
      end.
      when "surplus" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty > 0
        :
          {&fill-temp-table-current-doc}
        end.
      end.
      when "coincidence" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty = 0
        :
          {&fill-temp-table-current-doc}
        end.
      end.
      when "zero-remainder" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.doc-qnty = 0
          and buf_doc-line.cli-qnty = 0
        :
          {&fill-temp-table-current-doc}
        end.
      end.
      otherwise do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
        :
          {&fill-temp-table-current-doc}
        end.
      end.
    end case.
end.        /* p-current-doc-only = yes  */
else do:
    run get-doc-handles in this-procedure ( output v-br-docs-query ).

    assign
        v-doc-string        = ""
        v-t-doc-handle      = v-br-docs-query :get-buffer-handle()
        v-curr-query-rowid  = v-t-doc-handle :rowid
    .

    v-br-docs-query :get-first().
    do while not v-br-docs-query :query-off-end :
      find first t-doc no-lock
        where rowid(t-doc) = v-t-doc-handle :rowid
      no-error .
      if not available t-doc then do:
        message
          "Не найдена запись из списка документов"
        view-as alert-box error.
        return error .
      end.
      case v-dif:
        when "all" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
          :
              {&fill-temp-table-all-docs}
          end.
        end.
        when "shortage" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty < 0
          :
              {&fill-temp-table-all-docs}
          end.

        end.
        when "surplus" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty > 0
          :
              {&fill-temp-table-all-docs}
          end.
        end.
        when "coincidence" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty = 0
          :
              {&fill-temp-table-all-docs}
          end.
        end.
        when "zero-remainder" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.doc-qnty = 0
            and buf_doc-line.cli-qnty = 0
          :
              {&fill-temp-table-all-docs}
          end.
        end.
        otherwise do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
          :
              {&fill-temp-table-all-docs}
          end.
        end.
      end case.
      v-br-docs-query :get-next().
    end.
    v-br-docs-query :reposition-to-rowid( v-curr-query-rowid ) .
end.        /* NOT ( p-current-doc-only = yes  ) */

if sort-gr = yes
then do:

    if sort-name = no
    then do:
        for each temp_goods
        break by temp_goods.full-grp-name
              by temp_goods.artic
              by temp_goods.prod-type
              by temp_goods.prod-code
        :
            if first-of( temp_goods.full-grp-name )
            then do:
                run print-group-line in this-procedure (
                    input temp_goods.full-grp-name
                ).
            end.
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.        /* if sort-name = no  */
    else do:
        for each temp_goods
        break by temp_goods.full-grp-name
              by temp_goods.gds-name
        :
            if first-of( temp_goods.full-grp-name )
            then do:
                run print-group-line in this-procedure (
                    input temp_goods.full-grp-name
                ).
            end.
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.        /* NOT ( if sort-name = no  ) */
end.        /* if sort-gr = yes */
else do:
    if sort-name = no
    then do:
        for each temp_goods
        use-index byart
        :
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.        /* if sort-name = no  */
    else do:
        for each temp_goods
        use-index byname
        :
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.        /* NOT ( if sort-name = no  ) */
end.        /* NOT ( if sort-gr = yes ) */
HIDE   stream OutStream FRAME BottomFrame .
HIDE   STREAM OutStream FRAME ZAPAS .
Output stream OutStream close.
{ gbl/stopwork.i }
find first temp_goods no-lock no-error.
if available temp_goods then
do:
  { rep/q-print.i 0 }
end.
else do:
  message "Товаров удовлетворяющих условию не найдено!" view-as alert-box.
end.

/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
define input parameter p-artic      as character    no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.

    define variable v-gds-name-1    as character    no-undo.
    define variable v-gds-name-2    as character    no-undo.

    define buffer buf_temp_goods       for temp_goods.

    find first buf_temp_goods
         where buf_temp_goods.artic     = p-artic
           and buf_temp_goods.prod-type = p-prod-type
           and buf_temp_goods.prod-code = p-prod-code
    .
    find first goods
         where goods.artic      = buf_temp_goods.artic
           and goods.prod-type  = buf_temp_goods.prod-type
           and goods.prod-code  = buf_temp_goods.prod-code
    no-error.
    if available goods
    then do:
        assign
            v-lines-counter = v-lines-counter + 1
        .
        { rep/r-mess.i v-lines-counter 50 }
        find first gds-obj no-lock
             where gds-obj.gds-code = goods.gds-code
               and gds-obj.obj-type = v-cntxt-obj-type
               and gds-obj.obj-code = v-cntxt-obj-code
        no-error.
        { gbl/gdsbcode.i goods.gds-code ? v-bar-code  }
        run split-string in this-procedure (
              input goods.gds-name
            , input {&gds-name-length}
            , output v-gds-name-1
            , output v-gds-name-2
        ).
        display stream OutStream
            Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
            v-lines-counter
            goods.gds-code
            goods.artic
            v-gds-name-1        @ goods.gds-name
            goods.unit-base
            gds-obj.fact-qnty   when ( available gds-obj and ( available( t-doc ) and ( t-doc.status_ <>  {&wayb} and t-doc.status_ <>  {&g___new} ) ) )
            gds-obj.price-sale  when available gds-obj
            string( v-bar-code ) format "X(16)" @ bar-code.b-code
        with frame zapas.
        down stream  OutStream 1 with frame zapas.
        /* bar-code */
        for each bar-code no-lock
           where bar-code.gds-code = goods.gds-code
             and bar-code.in-code = ""
             and bar-code.part-code = ""
        :
            for each prod-bc no-lock
               where prod-bc.b-code = bar-code.b-code
            :
                display stream OutStream
                    Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
                    trim( prod-bc.b-str ) format "X(16)"    @ bar-code.b-code
                    v-gds-name-2  when  v-gds-name-2 <> ""  @ goods.gds-name
                with frame zapas .
                down stream  OutStream 1 with frame zapas.
                assign
                    v-gds-name-2 = ""
                .
            end.
        end. /* for each bar-code */
        if v-gds-name-2 <> ""
        then do:
            display stream OutStream
                Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
                v-gds-name-2        @ goods.gds-name
            with frame zapas.
            down stream  OutStream 1 with frame zapas.
        end.
        underline stream OutStream
            Sym1  Sym2 Sym3 Sym4 Sym5  Sym6  Sym7  Sym8
            v-lines-counter
            goods.gds-code
            goods.artic
            goods.unit-base
            goods.gds-name
            bar-code.b-code
            v-fact-qnty
            gds-obj.fact-qnty
            gds-obj.price-sale
        with frame zapas .
        down stream  OutStream 1 with frame zapas.
    end.
end.
end procedure. /* print-line */

/*==========================================================================*/
procedure print-group-line :
define input parameter p-full-grp-name  as character        no-undo.

do
on error undo, return error
:
    if line-counter( OutStream ) + 5 > page-size( OutStream )
    then do:
        page stream outstream.
    end.
    if v-lines-counter <> 0
    then do:
        down stream outstream 1 with frame zapas .
        put stream outstream
            skip (1)
        .
    end.
    else do:
        down stream outstream 1 with frame zapas .
    end.
    put stream outstream
            ": Группа: "
            p-full-grp-name format "X(100)"
            ":"
        skip v-line-string  format "X(126)"
    .
end.
end procedure. /* print-group-line */

/*==========================================================================*/
procedure split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.

    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.        /* if length( p-source-string ) <= p-split-length */
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos, p-split-length ) )
            .
        end.
    end.        /* NOT ( if length( p-source-string ) <= p-split-length ) */
end.
end procedure. /* split-string */

procedure get-doc-handles :
  define output parameter p-browse-query-handle  as handle    no-undo .

  define variable v-alldocs-handle as handle    no-undo .
do
on error undo, return error return-value
:
  assign
    v-alldocs-handle = widget-handle(p-alldocs-handle)
  .
  if valid-handle(v-alldocs-handle)
    and v-alldocs-handle :get-signature("get-browse-query-handle") <> ""
  then do:
    run get-browse-query-handle  in v-alldocs-handle ( output p-browse-query-handle  ).
  end.
end.

end procedure. /* get-doc-handles */