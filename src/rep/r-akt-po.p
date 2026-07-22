block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-akt-po.p $
$Archive: rep/r-akt-po.p $

Печать акта  переоценки

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id              as recid        no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-akt-po.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-akt-po.p $":U .
def var vss-description as character no-undo init "Печать акта и протокола переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }


do
on error undo, return error
:

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .


  define variable v-sort-prod         as character         no-undo.
  define variable v-par-type          as character         no-undo.

  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

  define buffer buf_clients for clients.
  define buffer buf_parts   for parts .
  define buffer buf_trn-doc for trn-doc .
  define buffer buf2_trn-doc for trn-doc .
  define buffer buf_goods   for goods .

  def shared var sort-gr      as logical no-undo.
  def shared var sort-name    as logical no-undo.

  def var v-single-line       as char    no-undo.

  def var sym1  as char init ":"   no-undo.
  def var sym2  as char init ":"   no-undo.
  def var sym3  as char init ":"   no-undo.
  def var sym4  as char init ":"   no-undo.
  def var sym4_1  as char init ":"   no-undo.
  def var sym5  as char init ":"   no-undo.
  def var sym6  as char init ":"   no-undo.
  def var sym7  as char init ":"   no-undo.
  def var sym8  as char init ":"   no-undo.
  def var sym9  as char init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  def var sym11 as char init ":"   no-undo.

  define variable all-qnty as decimal   no-undo .
  define variable all-sum1 as decimal   no-undo .
  define variable all-sum2 as decimal   no-undo .
  define variable s-isp    as character no-undo .

  DEFINE temp-table gds-prop no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as  integer
    field   gds-name         as  char
    field   grp-name         as  char
    field   b-code           as  integer
    field   qnty             as  decimal
    field   zen1             as  decimal
    field   sum1             as  decimal
    field   zen2             as  decimal
    field   sum2             as  decimal
    field   del              as  decimal
    field   prc              as  decimal
    field   number           as  character 
    field   date-pn          as  date format "99/99/9999"
    field   party            as  character  format "X(25)"   
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
 .

  def var v-doc-num          like trn-doc.doc-code    no-undo.
  def var v-doc-date         like trn-doc.doc-date    no-undo.

  find first buf_trn-doc no-lock  where recid(buf_trn-doc) = rec_id .

  assign
    v-doc-num  = buf_trn-doc.doc-code
    v-doc-date = buf_trn-doc.doc-date
  .

  for each parts-root no-lock where parts-root.doc-code = buf_trn-doc.doc-code :
    create gds-prop .
    find first buf_goods where buf_goods.gds-code = parts-root.gds-code no-lock .
    find first buf_parts no-lock
      where buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.part-code = parts-root.part-code
        and buf_parts.in-code   = parts-root.in-code
        and buf_parts.out-code  = buf_trn-doc.doc-code
        and buf_parts.obj-code  = buf_trn-doc.obj-code
        and buf_parts.obj-type  = buf_trn-doc.obj-type
      no-error .

    if PrintRubl then assign gds-prop.zen2 = buf_parts.price-rubl .
    else              assign gds-prop.zen2 = buf_parts.price-base .

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  gds-prop.b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.

    assign
      gds-prop.artic     = buf_goods.artic
      gds-prop.prod-type = buf_goods.prod-type
      gds-prop.prod-code = buf_goods.prod-code
      gds-prop.part-code = parts-root.part-code
      gds-prop.in-code   = parts-root.in-code
      gds-prop.gds-code  = buf_goods.gds-code
      gds-prop.gds-name  = buf_goods.gds-name
      gds-prop.qnty      = buf_parts.fact-qnty
      gds-prop.grp-name  = buf_goods.grp-name
      gds-prop.sum2      = buf_parts.fact-qnty * gds-prop.zen2
    .
    find first buf_goods where buf_goods.gds-code = parts-root.orig-gds-code no-lock .
    find first buf_parts no-lock
      where buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.part-code = parts-root.orig-part-code
        and buf_parts.in-code   = parts-root.orig-in-code
        and buf_parts.out-code  = buf_trn-doc.doc-code
        and buf_parts.obj-code  = buf_trn-doc.obj-code
        and buf_parts.obj-type  = buf_trn-doc.obj-type
      no-error .
      
     find first buf2_trn-doc no-lock
         where buf2_trn-doc.doc-code = buf_parts.in-code no-error.  
      if available buf2_trn-doc then
     
               assign
               gds-prop.number    = buf2_trn-doc.doc-code
               gds-prop.date-pn   = buf2_trn-doc.fact-date
               gds-prop.party     = STRING(gds-prop.number) + " от " + STRING(gds-prop.date-pn)
               . 
      . 
         
         

    if PrintRubl then assign gds-prop.zen1 = buf_parts.price-rubl .
    else              assign gds-prop.zen1 = buf_parts.price-base .
    assign
      gds-prop.sum1 = gds-prop.qnty * gds-prop.zen1
      gds-prop.del  = gds-prop.sum2 - gds-prop.sum1
      gds-prop.prc  = gds-prop.del * 100 / gds-prop.sum1
    .
  end.


  def stream out-stream .

  define frame f-doc1
        sym1              column-label ":!:"                       format "X(1)"
        gds-prop.b-code   column-label "Код! "                     format ">>>>>>>>>>>>9"
        sym2              column-label ":!:"                       format "X(1)"
        gds-prop.artic    column-label "Артикул! "                 format "X(16)"
        sym3              column-label ":!:"                       format "X(1)"
        gds-prop.gds-name column-label "Название товара! "         format "X(16)"
        sym4              column-label ":!:"                       format "X(1)"
        gds-prop.party    column-label "Партия! "                  format "X(25)"
        sym4_1            column-label ":!:"                       format "X(1)"
        gds-prop.qnty     column-label "Количество! "              format "->>>>>>>>9.<<"
        sym5              column-label ":!:"                       format "X(1)"
        gds-prop.zen1     column-label "Старая уч.!цена ({&abbr_rub_allshift})"     format "->>>>>>>9.99"
        sym6              column-label ":!:"                       format "X(1)"
        gds-prop.sum1     column-label "Сумма в учет.!ценах({&abbr_rub_allshift})"     format "->>>>>>>>>>>9.99"
        sym7              column-label ":!:"                       format "X(1)"
        gds-prop.zen2     column-label "Новая уч.!цена ({&abbr_rub_allshift})"      format "->>>>>>>9.99"
        sym8              column-label ":!:"                       format "X(1)"
        gds-prop.sum2     column-label "Новая сумма в!уч. ценах({&abbr_rub_allshift})" format "->>>>>>>>>>>9.99"
        sym9              column-label ":!:"                       format "X(1)"
        gds-prop.del      column-label "Сумма  !разницы ({&abbr_rub_allshift})"     format "->>>>>>>>9.99"
        sym10             column-label ":!:"                       format "X(1)"
        gds-prop.prc      column-label "Процент!разницы"          format "->>>>9.9%"
        sym11             column-label ":!:"                       format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт переоценки " ) at 50 format "X(20)" v-doc-num format "X(10)" " от " v-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X(190)" at 1
    with width {&DOS_CW} down stream-io use-text .

  define frame f-doc2
        sym1              column-label ":!:"                         format "X(1)"
        gds-prop.b-code   column-label "Код! "                       format ">>>>>>>>>>>>9"
        sym2              column-label ":!:"                         format "X(1)"
        gds-prop.artic    column-label "Артикул! "                   format "X(16)"
        sym3              column-label ":!:"                         format "X(1)"
        gds-prop.gds-name column-label "Название товара! "           format "X(16)"
        sym4              column-label ":!:"                         format "X(1)"
        gds-prop.party    column-label "Партия! "                    format "X(25)"
        sym4_1            column-label ":!:"                         format "X(1)"
        gds-prop.qnty     column-label "Количество! "                format "->>>>>>>>9.<<"
        sym5              column-label ":!:"                         format "X(1)"
        gds-prop.zen1     column-label "Старая уч.!цена (Б.Вал)"     format "->>>>>>>9.99"
        sym6              column-label ":!:"                         format "X(1)"
        gds-prop.sum1     column-label "Сумма в учет.!ценах(Б.Вал)"     format "->>>>>>>>>>>9.99"
        sym7              column-label ":!:"                         format "X(1)"
        gds-prop.zen2     column-label "Новая уч.!цена (Б.Вал)"      format "->>>>>>>9.99"
        sym8              column-label ":!:"                         format "X(1)"
        gds-prop.sum2     column-label "Новая сумма в!уч. ценах(Б.Вал)" format "->>>>>>>>>>>9.99"
        sym9              column-label ":!:"                         format "X(1)"
        gds-prop.del      column-label "Сумма раз-!ницы (Б.Вал)"     format "->>>>>>>>9.99"
        sym10             column-label ":!:"                         format "X(1)"
        gds-prop.prc      column-label "Процент!разницы"            format "->>>>9.9%"
        sym11             column-label ":!:"                         format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт переоценки " ) at 50 format "X(20)" v-doc-num format "X(10)" " от " v-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X(190)" at 1
    with width {&DOS_CW} down stream-io use-text .

  { gbl/working.i }

  assign   v-single-line = fill("-", 190) .

  { cmp/open-out.i stream out-stream " " {&LS_PS_A4}}

  find first  buf_clients no-lock where buf_clients.obj-type = {&cmp}  and buf_clients.obj-code = buf_trn-doc.host-code .
  put stream out-stream space(50) buf_clients.obj-name format "x(70)" skip(2) .

  put stream out-stream space(25) string( "А К Т  переоценки учетной цены по остаткам товара поставщика "
     + buf_trn-doc.cli-name + " (" + buf_trn-doc.cli-type + '#' + string(buf_trn-doc.cli-code) + ")  N "
     + v-doc-num + " от " + string(v-doc-date,"99/99/9999") )    format "x(180)"    skip(1)
    .

  form header
            v-single-line format "X(190)" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
  view stream out-stream frame bottomframe .


  /*======================== Шапка сформирована ==========================*/

  /*---S-------  Строки для документа --------------*/

  if PrintRubl then form with frame f-doc1 .
  else              form with frame f-doc2 .

  if v-sort-prod = "yes" then do:
    if sort-gr then do:
      if sort-name then do:
        for each gds-prop break by gds-prop.prod-type by gds-prop.prod-code by gds-prop.grp-name by gds-prop.gds-name :
          if  first-of( gds-prop.prod-code) then do:
            run print-prod in this-procedure .
          end.
          if  first-of( gds-prop.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each gds-prop break by gds-prop.prod-type by gds-prop.prod-code by gds-prop.grp-name by gds-prop.artic :
          if  first-of( gds-prop.prod-code) then do:
            run print-prod in this-procedure .
          end.
          if  first-of( gds-prop.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
    end.
    else do:
      if sort-name then do:
        for each gds-prop break by gds-prop.prod-type by gds-prop.prod-code by gds-prop.gds-name :
          if  first-of( gds-prop.prod-code) then do:
            run print-prod in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each gds-prop break by gds-prop.prod-type by gds-prop.prod-code by gds-prop.artic  :
          if  first-of( gds-prop.prod-code) then do:
            run print-prod in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
    end.
  end.
  else do:
    if sort-gr then do:
      if sort-name then do:
        for each gds-prop break by gds-prop.grp-name by gds-prop.gds-name  :
          if  first-of( gds-prop.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each gds-prop break by gds-prop.grp-name by gds-prop.artic :
          if  first-of( gds-prop.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.
    end.
    else do:
      if sort-name then do:
        for each gds-prop break by gds-prop.gds-name :
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each gds-prop break by gds-prop.artic :
          run print-line in this-procedure .
        end.
      end.
    end.
  end.
  put stream out-stream v-single-line format "X(190)" skip .

  if PrintRubl then do:
    display stream out-stream
      sym1   sym2   sym3  sym4_1 "ИТОГО:" @ gds-prop.gds-name
      sym4   all-qnty               @ gds-prop.qnty
      sym5   sym6   all-sum1        @ gds-prop.sum1
      sym7   sym8   all-sum2        @ gds-prop.sum2
      sym9   (all-sum2 - all-sum1) @ gds-prop.del
      sym10  ((all-sum2 - all-sum1) * 100 / all-sum1) @ gds-prop.prc
      sym11
    with frame f-doc1 .
    down stream out-stream with frame f-doc1 .
  end.
  else do:
    display stream out-stream
      sym1   sym2   sym3  sym4_1 "ИТОГО:" @ gds-prop.gds-name
      sym4   all-qnty               @ gds-prop.qnty
      sym5   sym6   all-sum1        @ gds-prop.sum1
      sym7   sym8   all-sum2        @ gds-prop.sum2
      sym9   (all-sum2 - all-sum1) @ gds-prop.del
      sym10  ((all-sum2 - all-sum1) * 100 / all-sum1) @ gds-prop.prc
      sym11
    with frame f-doc2 .
    down stream out-stream with frame f-doc2 .
  end.
  hide stream out-stream frame Bottomframe .

  if line-counter( out-stream ) + 6 > page-size( out-stream ) then  page stream out-stream .

  find first  buf_clients no-lock where buf_clients.obj-type = {&prs}  and buf_clients.obj-code = buf_trn-doc.agnt no-error .
  if available buf_clients then assign s-isp = buf_clients.obj-name .
  else                          assign s-isp = "" .

  put stream out-stream v-single-line format "X(190)" skip(2)
             space(10) "Подписи сторон : "    format "X(60)" skip
             space(10) "Зав. складом/Зав. секцией : _____________________" format "X(70)"  "От поставщика : _____________________" format "X(70)" skip(2)
             space(20) "Исполнитель : " s-isp  /*format "X(70)" */ skip
            .

  output stream out-stream close.

  { gbl/stopwork.i }

  { rep/q-print.i 8}

end.


procedure print-grp :
  do
  on error undo, return error return-value
  :
    if PrintRubl then do:
      display stream out-stream  sym1  gds-prop.grp-name @ gds-prop.gds-name  sym11  with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream  sym1  gds-prop.grp-name @ gds-prop.gds-name  sym11  with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure. /* print-grp */


procedure print-prod :
  do
  on error undo, return error return-value
  :
    find first buf_clients where buf_clients.obj-type = gds-prop.prod-type and buf_clients.obj-code = gds-prop.prod-code no-lock .

    if PrintRubl then do:
      display stream out-stream  sym1  buf_clients.obj-name @ gds-prop.gds-name  sym11  with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream  sym1  buf_clients.obj-name @ gds-prop.gds-name  sym11  with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure. /* print-grp */


procedure print-line :
  do
  on error undo, return error return-value
  :
    assign
      all-qnty = all-qnty + gds-prop.qnty
      all-sum1 = all-sum1 + gds-prop.sum1
      all-sum2 = all-sum2 + gds-prop.sum2
    .
    if PrintRubl then do:
      display stream out-stream
        sym1   gds-prop.b-code
        sym2   gds-prop.artic
        sym3   gds-prop.gds-name
        sym4_1 gds-prop.party
        sym4   gds-prop.qnty
        sym5   gds-prop.zen1
        sym6   gds-prop.sum1
        sym7   gds-prop.zen2
        sym8   gds-prop.sum2
        sym9   gds-prop.del
        sym10   gds-prop.prc
        sym11
      with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream
        sym1   gds-prop.b-code
        sym2   gds-prop.artic
        sym3   gds-prop.gds-name
        sym4_1 gds-prop.party
        sym4   gds-prop.qnty
        sym5   gds-prop.zen1
        sym6   gds-prop.sum1
        sym7   gds-prop.zen2
        sym8   gds-prop.sum2
        sym9   gds-prop.del
        sym10  gds-prop.prc
        sym11
      with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure. /* print-line */