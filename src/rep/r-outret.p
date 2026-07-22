block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-outret.p $
$Archive: rep/r-outret.p $

Документ расхода, возврата и списания короткий

Автор: Демин Алексей Сергеевич
Дата создания: 09/08/05
Author: Alexey Demin
Creation date: 09/08/05

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id       as recid        no-undo.
define input  parameter is-chek     as logical   no-undo .
define input parameter p-mode               as character        no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-outret.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-outret.p $":U .
define variable vss-description as character no-undo initial "Документ расхода и списания короткий":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ str/clcprtsl.i }
{ rep/tmp-tab.i  }
{ str/get-pr.i  def }
do
on error undo, return error
:

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { gbl/paramls.i  }
  { rep/outretxl.i }

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  define variable g#log as logical   no-undo .

  { str/getctxtp.i def }
  { str/getctxtp.i get }
  { gbl/getcntxt.i def }
  { gbl/getcntxt.i get }

  DEFINE VARIABLE base-type    AS CHARACTER NO-UNDO.

  define stream out_stream.

  define shared variable CostPrice    as logical          no-undo .
  define shared variable PrintScale   as logical          no-undo.
  define shared variable sort-gr      as logical          no-undo.
  define shared variable sort-name    as logical          no-undo.
  define shared variable print-graft  as logical   no-undo .

  define buffer t-doc         for ub.trn-doc.
  define buffer buf_clients   for ub.clients.
  define buffer Our_Object    for ub.clients.
  define buffer Our_Host      for ub.clients.
  define buffer cli-buf       for ub.clients.
  define buffer buf_goods     for ub.goods.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_gds-dtl   for ub.gds-dtl.
  define buffer buf_currency  for ub.currency.
  define buffer sch_clients   for ub.clients.
  define buffer buf_gds-prt   for ub.gds-prt.
  define buffer buf_pay-type  for ub.pay-type.

  define variable LogRes              as logical   init no    no-undo.
  define variable s1                  as character            no-undo.
  define variable s2                  as character            no-undo.
  define variable v-doc-code          as character            no-undo.
  define variable v-doc-date-string   as character            no-undo.

  define variable v-root-node as integer   no-undo .
  define variable empty-scale as logical   no-undo .
  define variable b-code      as integer   no-undo .

  define variable sym1 as char init ":" no-undo.
  define variable sym2 as char init ":" no-undo.
  define variable sym3 as char init ":" no-undo.
  define variable sym4 as char init ":" no-undo.
  define variable sym5 as char init ":" no-undo.
  define variable sym6 as char init ":" no-undo.
  define variable sym7 as char init ":" no-undo.
  define variable sym8 as char init ":" no-undo.
  define variable sym9 as char init ":" no-undo.
  define variable sym10 as char init ":" no-undo.
  define variable sym11 as char init ":" no-undo.

  define variable Line     as  char      no-undo.

  define variable Lines_Counter as integer     no-undo.
  define variable tb-code      as  char        no-undo.
  define variable gds_name     like ub.goods.gds-name .
  define variable Price        as  decimal     no-undo.
  define variable qnty         as  decimal     no-undo.
  define variable stoim        as  decimal     no-undo.
  define variable SLT-sum      as  decimal     no-undo.
  define variable VAT-sum      as  decimal     no-undo.

  define variable all-qnty         as  decimal     no-undo.
  define variable all-stoim        as  decimal     no-undo.
  define variable all-SLT-sum      as  decimal     no-undo.
  define variable all-VAT-sum      as  decimal     no-undo.

  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .
  define variable v-slt-pc     like ub.doc-line.slt-pc         no-undo .
  define variable v-form-name-2         as character init "oldexp"    no-undo.
  define variable v-host-code         as integer              no-undo.
  define variable boss-name    like ub.clients.obj-name  no-undo.
  define variable Wrkr_name    like ub.clients.obj-name  no-undo.

  define frame val
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п":C5 format ">>>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! ":C10 format "x(10)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! товара ":C34 format "X(49)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.!(Б.вал.) " format ">>>>>>>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format "->>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость!(Б.вал.) " format "->>>>>>>>>>>>9.99" space(0)
/*        sym9 column-label ":!:" format "X(1)" space(0)*/
/*        SLT-sum column-label "Сумма налога с!продаж(Б.вал.)" format "->>>>>>>>>9.99" space(0)*/
        sym10 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        string( "Накладная " + " N " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 120 format "X(13)" skip
        Line format "X(134)" at 1
  with width {&DOS_CW_2} down stream-io.

  define frame rubl
        sym1     column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п" format ">>>9" space(0)
        sym2     column-label ":!:" format "X(1)" space(0)
        tb-code  column-label "Код! ":C10 format "x(10)" space(0)
        sym3     column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4     column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! товара ":C32 format "X(47)" space(0)
        sym5     column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6    column-label ":!:" format "X(1)" space(0)
        Price   column-label "Цена за ед.!({&abbr_rub_allshift}) " format ">>>>,>>>,>>9.99" space(0)
        sym7    column-label ":!:" format "X(1)" space(0)
        qnty   column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym8    column-label ":!:" format "X(1)" space(0)
        stoim   column-label "Стоимость!({&abbr_rub_allshift}) " format "->>>,>>>,>>>,>>9.99" space(0)
/*        sym9    column-label ":!:" format "X(1)" space(0)*/
/*        SLT-sum column-label "Сумма налога!с продаж ({&abbr_rub_allshift})" format "->>>>>>>>>9.99" space(0)*/
        sym10   column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        string( "Накладная " + " N " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 120 format "X(13)" skip
        Line format "X(134)" at 1
  with width {&DOS_CW_2} down stream-io.

  find first t-doc no-lock  where recid( t-doc ) = rec_id  no-error.
  if not available t-doc  then do:
    message
        vss-workfile vss-revision vss-description    skip "Не найден документ для печати."
        skip return-value   skip trim(error-status :get-message(1))  trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box error.
    undo, return error .
  end.
  { gbl/hostcode.i  t-doc.obj-type   t-doc.obj-code   v-host-code }
  run torgconf-read in this-procedure (
      input v-form-name-2
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
  ) no-error.
  if error-status :error
  then do:
      message  vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров печати формы."  skip "Форма будет напечатана с параметрами по умолчанию." skip return-value
        skip trim(error-status :get-message(1))  trim(error-status :get-message(2))   trim(error-status :get-message(3))
      view-as alert-box error.
  end.
  /*Код фирмы - в переменной v-torgconf-self-host-code*/
  define variable v-curr-code as integer   no-undo .
  { gbl/basecode.i t-doc.host-code v-curr-code }
  find first buf_currency no-lock where buf_currency.curr-code = v-curr-code .

  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.

  define variable v-sort-prod         as character         no-undo.
  define variable v-par-type          as character         no-undo.

  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

  find first sch_clients no-lock
    where sch_clients.obj-type = t-doc.cli-type
      and sch_clients.obj-code = t-doc.cli-code .
  find first Our_Object no-lock where Our_Object.obj-type = t-doc.obj-type and Our_Object.obj-code = t-doc.obj-code .
  find first Our_Host   no-lock where Our_Host.obj-type = {&cmp}           and Our_Host.obj-code = v-torgconf-self-host-code .

  if v-torgconf-outnum = yes then  assign  v-doc-code = fill( " ", 10 ) .
  else                             assign  v-doc-code = t-doc.doc-code .

  if v-torgconf-outdate = yes then assign  v-doc-date-string = fill( " ", 10 ) .
  else  assign v-doc-date-string = string( t-doc.doc-date, "99.99.9999" ) + ( if t-doc.status_ = {&fact} then " (факт " + string( t-doc.fact-date, "99.99.9999" ) + ")" else "" ) .

  /* П Е Ч А Т Ь */
  { cmp/open-out.i stream Out_stream " " }
  run outretxl-init in this-procedure .

  form header  Line format "X(134)" at 1  skip "Продолжение - на следующей странице" at 30   skip
  with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box .
  view stream Out_stream frame Bottomframe .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ps-fact_print':U
    {&cntxt-firm}
    t-doc.host-code
    '':U
    0
    0
    0
    0
    false
    LogRes
  }

  run print-titul in this-procedure . /* печать шапки */

  if not PrintRubl then do:
    form with frame val .
  end.
  else do:
    form with frame rubl .
  end.
  if can-do( {&wayb} , t-doc.status_ ) and ( not t-doc.flag_ ) then put stream Out_stream "----------   Т Е С Т О В А Я   П Е Ч А Т Ь   ----------"  at 31 format "X(60)" skip(1) .
  if session:set-wait-state("compiler") then.
  assign
    Line = fill( "-", {&DOS_CW_2} )
    Lines_Counter = 0
  .
  /* печать строк */
  if v-sort-prod = "yes" then do:
    if sort-gr = yes then do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = t-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code) then    run print-prod in this-procedure .
          if  first-of( buf_goods.grp-name) then        run print-grp in this-procedure .
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        if print-graft = yes then do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_doc-line.artic
          :
            if  first-of( buf_doc-line.prod-code) then    run print-prod in this-procedure .
            if  first-of( buf_goods.grp-name) then        run print-grp in this-procedure .
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_doc-line.line-num
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = t-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code) then  run print-prod in this-procedure .
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        if print-graft = yes then do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_doc-line.artic
          :
            if  first-of( buf_doc-line.prod-code) then  run print-prod in this-procedure .
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_doc-line.line-num
          :
            if  first-of( buf_doc-line.prod-code) then  run print-prod in this-procedure .
            run print-line in this-procedure .
          end.
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
  end.        /* sort-prod = yes */
  else do:
    if sort-gr = yes then do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = t-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_goods.grp-name) then  run print-grp in this-procedure .
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        if print-graft = yes then do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.grp-name  by buf_doc-line.artic
          :
            if  first-of( buf_goods.grp-name) then  run print-grp in this-procedure .
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_goods.grp-name  by buf_doc-line.line-num
          :
            if  first-of( buf_goods.grp-name) then  run print-grp in this-procedure .
            run print-line in this-procedure .
          end.
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = t-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.gds-name
        :
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        if print-graft = yes then do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.artic
          :
            run print-line in this-procedure .
          end.
        end.
        else do:
          for each buf_doc-line
            where buf_doc-line.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
            break by buf_doc-line.line-num
          :
            run print-line in this-procedure .
          end.
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
  end.        /* sort-prod = yes */

  run print-itog in this-procedure .

  output stream Out_stream close.
  run outretxl-close in this-procedure .

  { rep/q-print.i 4 }

end.



procedure Print-prod :
  do on error undo, return error return-value :
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .

    if not printrubl then do:
      display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame val .
      down stream out_stream 1 with frame val .
      underline stream out_stream buf_goods.artic gds_name with frame val .
    end.
    else do:
      display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame rubl .
      down stream out_stream 1 with frame rubl .
      underline stream out_stream buf_goods.artic gds_name with frame rubl .
    end.
  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    if not printrubl then do:
      display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame val .
      down stream out_stream 1 with frame val .
      underline stream out_stream buf_goods.artic gds_name with frame val .
    end.
    else do:
      display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame rubl .
      down stream out_stream 1 with frame rubl .
      underline stream out_stream buf_goods.artic gds_name with frame rubl .
    end.
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
    if PrintRubl then do:
      { rep/r-outrt1.i rubl "r-outret" }
    end.
    else do:
      { rep/r-outrt1.i val "r-outret" }
    end.
  end.
end procedure. /* print-line */


procedure print-titul :

      define variable v-firm-string    as character    no-undo.

  do on error undo, return error return-value :
    
    
    
        if lookup( "SPAR":U, p-mode ) <> 0
         then do:
                put stream Out_stream space(10)
                skip "Форма Акта списания,"  at 135

                skip "Утверждена руководителем, " at 135

                skip "приказ №120 от 29.12.12г." at 135

                skip(1) .
                
       run outretxl-write-cell-data in this-procedure (
       input {&outretxl-h_docName}
         ,input "Форма Акта списания" 
                
                ).
   
       run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_docCode}
        , input "Утверждена руководителем : " 
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_cliTo}
        , input "приказ №120 от 29.12.12г. : " ).
 end.          
                   


  if is-chek then do:
    put stream Out_stream  "Т О В А Р Н Ы Й  Ч Е К  N " at 32 format "X(30)" .
    put stream Out_stream
                  v-doc-code                                                                      format "X(14)"
                  "  от  "
                  v-doc-date-string                                                               format "X(28)"
                  skip "Продавец : " at 10 format "X(20)"
                  skip v-torgconf-self-host-inn + " " + Our_Host.obj-name + ", " + Our_Object.obj-name + "(" + string(Our_Object.obj-code) + ")"                     at 12   format "X(108)"
                  skip "Адрес : " at 10 format "X(20)"
                  skip v-torgconf-self-host-addres          at 12   format "X(108)"
                  skip "Покупатель : " at 10 format "X(20)"
                  skip sch_clients.obj-name at 12 format "X(40)"
                  skip(1)
              .
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_docName}
        , input string("Т О В А Р Н Ы Й  Ч Е К  N ")
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_docCode}
        , input v-doc-code
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_docDate}
        , input v-doc-date-string
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_cliFrom}
        , input "Продавец : " + v-torgconf-self-host-inn + " " + Our_Host.obj-name + ", " + Our_Object.obj-name + "(" + string(Our_Object.obj-code) + ")"
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_cliTo}
        , input "Покупатель : " + sch_clients.obj-name
    ).
  end.
  else do:
    case t-doc.doc-type :
      when {&return} then do:
        if t-doc.internal then put stream Out_stream  "В Н У Т Р Е Н Н Е Е  ПЕРЕМЕЩЕНИЕ - В О З В Р А Т  N " at 22 format "X(60)" .
        else                   put stream Out_stream  "В О З В Р А Т Н А Я   Н А К Л А Д Н А Я   N " at 32 format "X(50)" .
        put stream Out_stream
                  v-doc-code                                                                      format "X(14)"
                  "  от  "
                  v-doc-date-string                                                               format "X(28)"
                  skip(2) "Отправитель :"                                                 at 10   format "X(20)"
                  skip string( sch_clients.obj-name + "(" + string(sch_clients.obj-code) + ")" )  at 12   format "X(108)"
                  skip "Получатель  : " at 10 format "X(20)"
                  skip Our_Host.obj-name + ", " + Our_Object.obj-name                     at 12   format "X(108)"
                  skip(1)
              .
        if t-doc.internal then
          run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docName}
            , input "В Н У Т Р Е Н Н Е Е  ПЕРЕМЕЩЕНИЕ - В О З В Р А Т  N "
          ).
        else
          run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docName}
            , input "В О З В Р А Т Н А Я   Н А К Л А Д Н А Я  N "
          ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docCode}
            , input v-doc-code
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docDate}
            , input v-doc-date-string
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliFrom}
            , input string( "Отправитель : " + sch_clients.obj-name + "(" + string(sch_clients.obj-code) + ")" )
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliTo}
            , input "Получатель  :" + Our_Host.obj-name + ", " + Our_Object.obj-name
        ).
        if CostPrice then do:
          put stream Out_stream space(10) "Указаны УЧЕТНЫЕ цены"      format "X(50)"  skip(2) .
          run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_CostPrice}
            , input "Указаны УЧЕТНЫЕ цены"
          ).
        end.
      end.
      when {&write-off} then do:
        put stream Out_stream
                  skip(1) "С П И С А Н И Е   N "                                          at 32   format "X(22)"
                  v-doc-code                                                                      format "X(14)"
                  "  от  "
                  v-doc-date-string                                                               format "X(28)"
                  skip(2) "Отправитель  :"                                                at 10   format "X(20)"
                  skip Our_Host.obj-name + ", " + Our_Object.obj-name                     at 12   format "X(108)"
                  skip "Получатель   :"                                                   at 10   format "X(20)"
                  skip sch_clients.obj-name                                                   at 12   format "X(108)"
              .
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docName}
            , input "С П И С А Н И Е  N "
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docCode}
            , input v-doc-code
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docDate}
            , input v-doc-date-string
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliFrom}
            , input string( "Отправитель : " + Our_Host.obj-name + ", " + Our_Object.obj-name )
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliTo}
            , input "Получатель  :" + sch_clients.obj-name
        ).
      end.
      when {&expense} then do:
        if  t-doc.internal then do:         /* ЭТО - требование !! */
          assign
            v-firm-string = substitute( "&1, ", Our_Host.obj-name )
          .
          put stream Out_stream "В Н У Т Р Е Н Н Е Е  ПЕРЕМЕЩЕНИЕ - Р А С Х О Д   N " at 22 format "X(55)"  v-doc-code format "X(14)" .
          run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docName}
            , input "В Н У Т Р Е Н Н Е Е  ПЕРЕМЕЩЕНИЕ - Р А С Х О Д  N "
          ).
        end.
        else do:
          assign
            v-firm-string = "":U
          .
          if t-doc.office then do:        /* услуга ! */
            put stream Out_stream "А К Т  П Р И Е М К И - П Е Р Е Д А Ч И  Р А Б О Т / У С Л У Г   N " at 22 format "X(70)"  v-doc-code format "X(14)" .
            run outretxl-write-cell-data in this-procedure (
                input {&outretxl-h_docName}
              , input "А К Т  П Р И Е М К И - П Е Р Е Д А Ч И  Р А Б О Т / У С Л У Г  N "
            ).
          end.
          else do:
            put stream Out_stream "Р А С Х О Д Н А Я   Н А К Л А Д Н А Я   N " at 32 format "X(45)" v-doc-code format "X(14)" .
            run outretxl-write-cell-data in this-procedure (
                input {&outretxl-h_docName}
              , input "Р А С Х О Д Н А Я   Н А К Л А Д Н А Я  N "
            ).
          end.
        end.
        put stream Out_stream
                  "  от  "  v-doc-date-string                                                     format "X(28)"
                  skip(1) "Отправитель  :"                                                at 10   format "X(20)"
                  skip Our_Host.obj-name + ", " + Our_Object.obj-name                     at 12   format "X(108)"
                  skip "Получатель   :"                                                   at 10   format "X(20)"
                  skip string( v-firm-string + sch_clients.obj-name + "(" + string(sch_clients.obj-code) + ")" )  at 12   format "X(108)"
                  skip(1)
              .
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docCode}
            , input v-doc-code
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_docDate}
            , input v-doc-date-string
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliFrom}
            , input "Отправитель : " + Our_Host.obj-name + ", " + Our_Object.obj-name
        ).
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_cliTo}
            , input string( "Получатель : " + sch_clients.obj-name + "(" + string(sch_clients.obj-code) + ")" )
        ).
        if CostPrice then do:
          put stream Out_stream space(10) "Указаны УЧЕТНЫЕ цены"      format "X(50)"  skip(2) .
          run outretxl-write-cell-data in this-procedure (
              input {&outretxl-h_CostPrice}
            , input "Указаны УЧЕТНЫЕ цены"
          ).
        end.
      end.
    end case .

    /* печать вида платежа и примечания */
    Find buf_pay-type Where buf_pay-type.Obj-code = T-doc.Pay-code No-lock No-error.
    Put Stream Out_Stream String( "Вид оплаты : " + ( If Available buf_pay-type Then buf_pay-type.Obj-name Else "?" ) ) At 10 Format "X(60)" Skip.
    run outretxl-write-cell-data in this-procedure (
        input {&outretxl-h_PayType}
      , input ( If Available buf_pay-type Then buf_pay-type.Obj-name Else "?" )
    ).
    If V-torgconf-outprim = No or t-doc.internal Then Do:
      Put Stream Out_Stream  String( "Примечание : " + ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " ) ) At 10 Format "X(100)" Skip .
      run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_PS}
        , input ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " )
      ).
    End.

    run torgconf-get-reason in this-procedure ( input t-doc.doc-code, input t-doc.reason-code,  input t-doc.doc-type ) .
    put stream Out_Stream
        space(5) string( "Основание: " + v-torgconf-reason ) at 10 format "X(100)" skip
    .
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-h_reason}
        , input v-torgconf-reason
    ).

  end.
  end.
end procedure. /* print-titul */


procedure print-itog :
  do on error undo, return error return-value :

      define variable v-oper-name    as character    no-undo.

    put stream out_stream Line format "X(134)" skip .
    if PrintRubl then do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim /*sym9 all-SLT-sum @ SLT-sum*/ sym10
      with frame rubl.
      down stream out_stream with frame rubl .
    end.
    else do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim /*sym9 all-SLT-sum @ SLT-sum*/ sym10
      with frame val.
      down stream out_stream with frame val .
    end.
    put stream out_stream Line format "X(134)" skip .

    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-it_qnty}
        , input string( all-qnty )
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-it_sum}
        , input string( all-stoim )
    ).

    if line-counter( Out_stream ) + 16 > page-size( Out_stream ) then  page stream Out_stream .

    put stream Out_stream skip(1) space(5) "Всего " format "x(8)" all-qnty format ">,>>>,>>9.<<<"
      space(2) "единицы" format "x(8)" space(2) Lines_Counter format ">,>>>,>>9" space(2) "наименований" format "x(13)"
                                              "на сумму"  all-stoim  format ">,>>>,>>>,>>>,>>9.99"  " "  ( if not PrintRubl then buf_currency.curr-abbr else "{&abbr_rub_allshift}" )
      skip(1).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-f_lineAmount}
        , input string( "Всего " + string(all-qnty,">,>>>,>>9.<<<") + " единицы " + string(Lines_Counter,">,>>>,>>9") + " наименований  на сумму " + string(all-stoim,">,>>>,>>>,>>>,>>9.99") + " " +  ( if not PrintRubl then buf_currency.curr-abbr else "{&abbr_rub_allshift}" ) )
    ).

    if v-torgconf-outdisc = no and not CostPrice then do:    /* скидку - показать ! */
      put stream Out_stream space(5) "Скидка " format "x(8)"
        ( if t-doc.tot-calc <> 0 and t-doc.discnt-pc = 0 then " " else string( string( t-doc.discnt-pc, "->>9.9" ) + "%" ) )
        space(2) "на сумму"                                                        format "x(10)"
        space(2) ( if not PrintRubl then t-doc.tot-calc else t-doc.discnt-rubl )   format "->>>,>>>,>>>,>>9.99"
        space(2) ( if not PrintRubl then buf_currency.curr-abbr else "{&abbr_rub_allshift}" )                    format "x(4)" skip(1)
      .
      if t-doc.discnt-pc <> 0 then
        run outretxl-write-cell-data in this-procedure (
              input {&outretxl-f_Skidka}
            , input string( "Скидка " + string( t-doc.discnt-pc, "->>9.9" ) + "%  на сумму  "  + string(( if not PrintRubl then t-doc.tot-calc else t-doc.discnt-rubl ),"->>>,>>>,>>>,>>9.99") )
        ).
    end.

    if can-do( {&fact} , t-doc.status_ ) or
       ( can-do( {&expense} , t-doc.doc-type ) and can-do( {&wayb_inquiry} , t-doc.status_ ) and
       ( not t-doc.internal ) ) then do:
      if not PrintRubl then run rep/wp.p (     input ParParentProc, input all-stoim, output s1, output s2 ) .
      else                  run rep/wp-rub.p (                      input all-stoim, output s1, output s2 ) .

      if can-do( {&return} , t-doc.doc-type ) then put stream Out_stream space(5) "Итого " format "x(6)" .
      else                                         put stream Out_stream space(5) "Итого к оплате " format "x(17)" .

      if v-torgconf-outdisc = no and not CostPrice then put stream Out_stream "( с учетом скидки ) " format "x(22)" .

      put stream Out_stream all-stoim format "->>>,>>>,>>>,>>9.99" space(1) trim(s2) format "x(4)".

      run outretxl-write-cell-data in this-procedure (
            input {&outretxl-f_SumAll}
          , input string( all-stoim,"->>>,>>>,>>>,>>9.99")
      ).
      run outretxl-write-cell-data in this-procedure (
            input {&outretxl-f_SumAllLiteral}
          , input s1
      ).

      put stream Out_stream skip(1) space(10) caps(s1) format "x(126)" skip(1) .
      put stream Out_stream  space(5)  "В том числе: " format "x(25)" skip.
      define variable str-nal as character no-undo .
      for each temp-nalog break by temp-nalog.slt-prc by temp-nalog.vat-prc:
        put stream Out_stream
            string( "НДС " + string( temp-nalog.vat-prc, ">>9.<<%")) at 10 format "X(12)"
            ":"  + string( temp-nalog.VAT-sum , "->>>,>>>,>>9.99" ) at 25 format "X(18)"   trim(s2)  " от суммы " format "X(10)"
             string( temp-nalog.from-sum , "->>>,>>>,>>9.99" )  at 65 format "X(16)"   trim(s2) skip
        .
        if str-nal <> "" then assign str-nal = str-nal + "\n" .
        assign
          str-nal = str-nal +
          string( "НДС " + string( temp-nalog.vat-prc, ">>9.<<%")) +  ":" + string( temp-nalog.VAT-sum , "->>,>>>,>>9.99" ) + " " + trim(s2) + " от суммы "
          + string( temp-nalog.from-sum , "->>>,>>>,>>9.99" ) + " " + trim(s2)
        .
      end.
      run outretxl-write-cell-data in this-procedure (
            input {&outretxl-f_Nalog}
          , input str-nal
      ).

      if is-chek then do:
        put stream Out_stream space(10)  "М П" format "x(60)"  "Подпись : " format "x(50)" skip(1) .
      end.
      else do:
        if can-do( {&expense} , t-doc.doc-type ) and ( not t-doc.internal )
            and ( ( can-do( {&inquiry} , t-doc.status_ )
            or ( can-do( {&wayb} , t-doc.status_ ) and t-doc.flag_ ) ) )
            or t-doc.status_ = {&fact}
        then do:
          if t-doc.office then do:
            put stream Out_stream  "Заказчик :    ______________/_____________ / " space(20)  "Исполнитель : ______________/_____________ /"  .
          end.
          else do:
            put stream Out_stream space(10)  "Сдал : " format "x(60)"  "Принял : " format "x(50)" skip(1) .
          end.
        end.
        else do:
          put stream Out_stream space(30) "--- Н Е   П О Д П И С Ы В А Т Ь ! ---" format "X(75)" skip(1) .
        end.
      end.
    end.
    run rep/get-psn.p
      (input t-doc.boss
      ,output boss-name
      ) .
    run rep/get-psn.p
      (input t-doc.wrkr
      ,output Wrkr_name
      ) .
    { gbl/usrnick.i
        t-doc.creid
        v-oper-name
    }
    if boss-name = ? then boss-name = " " .
    if Wrkr_name = ? then Wrkr_name = " " .
    put stream Out_stream "Документ оформил: " skip  "Оператор: "  v-oper-name  skip "Кладовщик: "  Wrkr_name skip "Менеджер: "  boss-name skip.


    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-f_OperName}
        , input v-oper-name
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-f_KladName}
        , input Wrkr_name
    ).
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-f_MngrName}
        , input boss-name
    ).
    put stream Out_stream space(65) ( if v-torgconf-outdate = no then string( t-doc.fact-date, "99/99/9999" ) else "" )  format "X(10)"  skip .
    run outretxl-write-cell-data in this-procedure (
          input {&outretxl-f_Date}
        , input ( if v-torgconf-outdate = no then string( t-doc.fact-date, "99/99/9999" ) else "" )
    ).
    hide stream Out_stream frame Bottomframe .
  end.
end procedure. /* print-itog */