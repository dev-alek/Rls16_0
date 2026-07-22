block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-cert.p $
$Archive: rep/r-cert.p $

Качественное удостоверение

Автор: Демин Алексей Сергеевич
Дата создания: 10/15/08
Author: Alexey Demin
Creation date: 10/15/08

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cert.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-cert.p $":U .
define variable vss-description as character no-undo init "Качественное удостоверение".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
&SCOP f-l Centering
{ gbl/std-func.i {&f-l} }
{ cmp/str-glbl.i }
{ rep/fmtcli.i   }
{ rep/torgconf.i }
{ cmp/library.i  }
{ gbl/paramls.i  }
{ cmp/breakstr.i }
{ ref/extclass.i }
{ ref/meatsemi.i meat-semi-finished ds }
{ ref/meatsemi.i " " proc }
{ gbl/key-rec.i }
{ rep/frmlib.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

define stream out-stream .

define variable sym1                as char     init ":" no-undo.
define variable sym2                as char     init ":" no-undo.
define variable sym3                as char     init ":" no-undo.
define variable sym4                as char     init ":" no-undo.
define variable sym5                as char     init ":" no-undo.
define variable sym6                as char     init ":" no-undo.
define variable sym7                as char     init ":" no-undo.
define variable sym8                as char     init ":" no-undo.
define variable sym9                as char     init ":" no-undo.
define variable sym10               as char     init ":" no-undo.
define variable sym11               as char     init ":" no-undo.

def buffer buf_trn-doc          for trn-doc.
def buffer buf_goods            for goods.
def buffer buf_clients          for clients.
def buffer buf_doc-line         for doc-line.

define variable v-date           as character    no-undo.
define variable v-manuf-date     as character    no-undo.
define variable v-protokol       as character    no-undo.
define variable v-protokol0      as character    no-undo.
define variable v-single-line    as character    no-undo.
define variable v-organization   as character    no-undo.
define variable v-h-num          as character    no-undo.
define variable str              as character    no-undo.
define variable str1             as character    no-undo.
define variable str2             as character    no-undo.
define variable v-adres          as character    no-undo.
define variable v-adres-u        as character    no-undo.
define variable v-adres-p        as character    no-undo.
define variable v-phone          as character    no-undo.
define variable v-sert           as character    no-undo.
define variable v-place          as decimal      no-undo.
define variable v-place-str      as character    no-undo.
define variable v-host-code      as integer      no-undo.
define variable v-curr-code      as integer      no-undo.
define variable v-ch             as logical init false   no-undo.
define variable v-number         as integer      no-undo.
define variable v-keeping0       as character    no-undo.
define variable v-keeping        as character    no-undo.
define variable kep              as character    no-undo.
define variable kep1             as character    no-undo.
define variable kep2             as character    no-undo.
define variable prot             as character    no-undo.
define variable prot1            as character    no-undo.
define variable prot2            as character    no-undo.
define variable v-gds-name       as character    no-undo.
define variable gds-name_        as character    no-undo.
define variable gds-name1        as character    no-undo.
define variable gds-name2        as character    no-undo.
define variable v-msf-name       as character    no-undo .
define variable v-uniq-key-rec   as character    no-undo .
define buffer buf_condition-keeping for ub.condition-keeping.
define buffer buf_parts for ub.parts.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clob-bind for ub.clob-bind.

define variable g#report-num     as integer      no-undo .
define variable g#quest-print    as logical      no-undo.
define variable g#log            as logical      no-undo.
{ rep/certxl.i   }
{ gbl/getcntxt.i def }


FUNCTION get-in-code-date RETURNS CHARACTER  ( input p-gds-code as integer
                                              ,input p-artic as character
                                              ,input p-prod-type as character
                                              ,input p-prod-code as integer
                                              ,input p-obj-type  as character
                                              ,input p-obj-code  as integer
                                              ,input p-in-code as character
                                              ,input p-out-code as character
                                              ,input p-part-code as character
                                               ) :
/*По  ПАРТИИ  выдает дату источника */
define buffer buf_parts-attr for ub.parts-attr  .

find first buf_parts-attr no-lock where
          buf_parts-attr.part-code = p-part-code
      and buf_parts-attr.in-code = p-in-code
      and buf_parts-attr.gds-code = p-gds-code  no-error .
if available buf_parts-attr then return string ( buf_parts-attr.fact-date, "99/99/9999" ) .
 else return "" .

END FUNCTION.


define frame f-doc
        sym1 column-label ":!:" format "X(1)" space(0)
v-gds-name column-label "Наименование продукта, группа, категория.!вид.подвид. термическое состояние":C50 format "X(50)" space(0)
        sym2 column-label ":!:!" format "X(1)" space(0)
v-manuf-date COLUMN-LABEL "Дата выработки/!упаковывания!время выработки!смотри на уп-ке":C15 format "X(15)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
buf_parts.fact-qnty COLUMN-LABEL "Масса нетто или!выход готового изделия":C22 format "->>,>>>,>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
v-place-str COLUMN-LABEL "Число мест/число единиц!потребительской упаковки":C24 format "X(15)" /*"->>,>>>,>>9.<<<"*/ space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
v-keeping COLUMN-LABEL "Срок годности/!условия хранения":C17 format "X(16)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
v-protokol COLUMN-LABEL "Протокол приемо-!сдаточный №, дата":C20 format "X(20)" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
v-sert COLUMN-LABEL "Технический документ!(ТУ,ОСТ)":C37 format "X(37)" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
    header
/*cur-time-print() at 5 format "X(35)"*/
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 160 format "X(13)" skip
        v-single-line format "X(193)" at 1
    with width {&DOS_CW} down stream-io use-text .


run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
assign
   v-single-line = fill("-", 230)
.
{ cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
  form header
            v-single-line format "X(191)" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box .
  view stream out-stream frame bottomframe .

find first buf_trn-doc no-lock where recid(buf_trn-doc) = p-trn-doc-recid.


{ gbl/hostcode.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    v-host-code
}
if printRubl = yes
then do:
    assign
        v-curr-code = 0
    .
end.
else do:
    { gbl/basecode.i
        v-host-code
        v-curr-code
    }
end.
run torgconf-get-self-param in this-procedure (
      input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
    , input v-curr-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров объекта документа."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box warning.
end.
assign
V-organization = substitute("&1. Юрид.адрес: &2. &3. &4"
                            , v-torgconf-self-host-name
                            , v-torgconf-self-host-addres
                            , (if v-torgconf-self-host-post-addres<>v-torgconf-self-host-addres  and  v-torgconf-self-host-post-addres  <> ''
                               then ("Почт.адрес: " + v-torgconf-self-host-post-addres)
                               else "")
                            , v-torgconf-self-host-phone
                            )
   v-h-num = substitute("КАЧЕСТВЕННОЕ УДОСТОВЕРЕНИЕ № &1 от &2 г. ", buf_trn-doc.doc-code, buf_trn-doc.doc-date)
v-adres = substitute("Юрид.адрес: &1. &2. &3."
                     ,v-torgconf-self-host-addres
                     ,(if v-torgconf-self-host-post-addres <> v-torgconf-self-host-addres and  v-torgconf-self-host-post-addres  <> ''
                       then ("Почт.адрес: " + v-torgconf-self-host-post-addres)
                       else "")
                     ,v-torgconf-self-host-phone
)
v-adres-u = substitute("Юрид.адрес: &1.", v-torgconf-self-host-addres)
v-adres-p = (if v-torgconf-self-host-post-addres <> v-torgconf-self-host-addres
             and v-torgconf-self-host-post-addres  <> ''
             then ("Почт.адрес: " + v-torgconf-self-host-post-addres)
             else "")
v-phone = v-torgconf-self-host-phone
v-organization = right-trim(v-organization, ". ")
v-adres = right-trim(v-adres, ". ")
.
put stream out-stream
  v-torgconf-self-host-name format "X(190)" skip
  /*v-adres format "X(190)" skip(1)*/
  v-adres-u format "X(190)" skip(0).
put stream out-stream
  v-adres-p format "X(190)" skip(0).
put stream out-stream
  v-phone format "X(190)" skip(1)
  Centering(v-h-num, 176 )  format "X(190)" .
run certxl-init in this-procedure .
run certxl-write-cell-data in this-procedure ( input {&certxl-h_org}  , input v-torgconf-self-host-name ).
/*run certxl-write-cell-data in this-procedure ( input {&certxl-h_adres}, input v-adres ).*/
run certxl-write-cell-data in this-procedure ( input {&certxl-h_adresu}, input string(v-adres-u, "x(150)")).
run certxl-write-cell-data in this-procedure ( input {&certxl-h_adresp}, input STRING(v-adres-p, "x(150)") ).
run certxl-write-cell-data in this-procedure ( input {&certxl-h_phone}, input v-phone ).
run certxl-write-cell-data in this-procedure ( input {&certxl-h_num}  , input v-h-num ).

run meatsemi_fill-msf in this-procedure ( input {&lookup}
                                        , buffer buf_clob-bind).


 for each buf_doc-line no-lock
 where buf_doc-line.doc-code = buf_trn-doc.doc-code
 ,each buf_parts no-lock where
          buf_parts.obj-type = buf_trn-doc.obj-type
      and buf_parts.obj-code = buf_trn-doc.obj-code
      and buf_parts.artic = buf_doc-line.artic
      and buf_parts.prod-type = buf_doc-line.prod-type
      and buf_parts.prod-code = buf_doc-line.prod-code
      and buf_parts.out-code = buf_trn-doc.doc-code :

  find first buf_goods no-lock
  where buf_goods.artic      = buf_parts.artic
  and buf_goods.prod-type    = buf_parts.prod-type
  and buf_goods.prod-code    = buf_parts.prod-code .
    /*ищем код по лкассификатору мясных полуфабрикатов*/
    v-uniq-key-rec = ''.
    run gen-key-rec in this-procedure ( input {&table_goods}
                                       ,input buffer buf_goods:handle
                                       ,output v-uniq-key-rec ).
    find first buf_ext-classif no-lock where
              buf_ext-classif.classif-subject = {&table_goods}
         and buf_ext-classif.classif-name = {&extclass_goods_msf}
          AND buf_ext-classif.db-num = - 1
          and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.

   if available buf_ext-classif then do:
     find first meat-semi-finished  where
              meat-semi-finished.node-code = buf_ext-classif.key#_one no-error.
     if available meat-semi-finished then do:
       v-msf-name = substitute("Группа - &1 п/ф, вид - &2 п/ф, подвид - &3, &4, &5"
                              , meat-semi-finished.group-name
                              , meat-semi-finished.kind-name
                              , trim(replace(replace(meat-semi-finished.subkind-name, "-", "")
                                        ,{&comma-char} + {&comma-char}, {&comma-char})
                                        ,{&comma-char})
                              , meat-semi-finished.category-name
                              , meat-semi-finished.termic-condition-name).
     end.
     else do:
       v-msf-name = ''.
     end.
    end.
    else do:
      v-msf-name = ''.
    end.
       assign
    v-place-str = Center-Field ( input string(round(buf_parts.fact-qnty / buf_goods.qnty-cart, 0))
                                ,INPUT 24
                                ,INPUT 24
                                ,INPUT {&space-char} )
         v-ch = false
    v-manuf-date  = get-in-code-date( buf_goods.gds-code
                              ,buf_goods.artic
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ,buf_trn-doc.obj-type
                              ,buf_trn-doc.obj-code
                              ,buf_parts.in-code
                              ,buf_trn-doc.doc-code
                              ,buf_parts.part-code
                              )
    .
    find first buf_condition-keeping no-lock where
            buf_condition-keeping.cond-keep-code = buf_goods.cond-keep-code no-error.
    assign
    v-keeping0 = ''
    v-keeping = ''
    v-protokol = ''
    v-protokol0 = ''
    kep = ''
    kep2 = ''
    prot = ''
    prot2 = ''

    .

    ASSIGN
    v-keeping0 = substitute("&1 сут./ &2"
                           , buf_goods.deadline
                           , (if available buf_condition-keeping
                             then substitute("&1 при t от &2 до &3 град C, влажности от &4 до &5 %"
                                            ,buf_condition-keeping.des
                                            ,buf_condition-keeping.t-mode-from
                                            ,buf_condition-keeping.t-mode-to
                                            ,buf_condition-keeping.h-mode-from
                                            ,buf_condition-keeping.h-mode-to
                                            )
                             else '')
                           )
    kep = v-keeping0
    gds-name_ = buf_goods.gds-name + {&space-char} + v-msf-name
    v-protokol0 = substitute("№ &1 от даты выработки", buf_parts.artic)
    prot = v-protokol0
       .
    assign
    v-place =round((buf_parts.fact-qnty)/(buf_goods.qnty-cart),0)
    .

    if length(buf_goods.sert) > 37
    or length(kep) > 17
    or length(gds-name_) > 50
    or length(prot) > 20
   then do:
         ASSIGN
      str = STRING(buf_goods.sert).
            str1 = breakstr( str,37, INPUT-OUTPUT str1, INPUT-OUTPUT str2 ).
      v-sert = str1.
      kep1 = breakstr( kep, 17,  INPUT-OUTPUT kep1, INPUT-OUTPUT kep2 ).
      v-keeping = kep1.
      gds-name1 = breakstr( gds-name_, 50,  INPUT-OUTPUT gds-name1, INPUT-OUTPUT gds-name2 ).
      prot1 = breakstr( prot, 20,  INPUT-OUTPUT prot1, INPUT-OUTPUT prot2 ).
      v-protokol = prot1.
      v-gds-name = gds-name1.
         display stream out-stream
      sym1
      v-gds-name
      sym2
      v-manuf-date
      sym3
      buf_parts.fact-qnty
      sym4
      v-place-str
      sym5
      v-keeping
      sym6
      v-protokol
      sym7
      v-sert
      sym8
      with frame f-doc .
                        DOWN STREAM out-stream 1 WITH FRAME f-doc.
      DO WHILE TRIM( str2 ) <> "":U
      or trim(kep2) <> ""
      or trim(prot2) <> ""
      or trim(gds-name2) <> ""     :
         ASSIGN
            str  = str2
            str1 = breakstr( str,37, INPUT-OUTPUT str1, INPUT-OUTPUT str2 )
        v-sert = str1.
        .
        ASSIGN
        kep  = kep2
        kep1 = breakstr( kep,17, INPUT-OUTPUT kep1, INPUT-OUTPUT kep2 )
        v-keeping = kep1.
        .
        ASSIGN
        prot  = prot2
        prot1 = breakstr( prot, 20, INPUT-OUTPUT prot1, INPUT-OUTPUT prot2 )
        v-protokol = prot1.
        .
        ASSIGN
        gds-name_  = gds-name2
        gds-name1 = breakstr( gds-name_,50, INPUT-OUTPUT gds-name1, INPUT-OUTPUT gds-name2 )
        v-gds-name = gds-name1.
         .

         display stream out-stream
        v-gds-name
        sym1
        sym2
        sym3
        sym4
        sym5
        v-keeping
        sym6
        v-protokol
        sym7
        v-sert
        sym8
        with frame f-doc .
                        DOWN STREAM out-stream 1 WITH FRAME f-doc.

         END.
   end.
   else do:
      assign
      v-sert = buf_goods.sert
      .
      display stream out-stream
      sym1
      buf_goods.gds-name + {&space-char} + v-msf-name @ v-gds-name
      sym2
      v-manuf-date
      sym3
      buf_parts.fact-qnty
      sym4
      v-place-str
      sym5
      v-keeping
      sym6
      v-protokol
      sym7
      v-sert
      sym8
      with frame f-doc .
              DOWN STREAM out-stream 1 WITH FRAME f-doc.
   end.

run certxl-Template-write-line-data (     input buf_goods.sert
                                        , input buf_goods.gds-name + {&space-char} + v-msf-name
                                        , input v-manuf-date
                                        , input buf_parts.fact-qnty
                                        , input v-place-str
                                        , input v-keeping0
                                        , input v-protokol0
                                      ) .

end.

run certxl-close in this-procedure .
put stream out-stream
v-single-line format "X(193)" skip(2)
          string('Продукция изготовлена в соответствии с  ГОСТ Р 52675-2006 "Полуфабрикаты мясные и мясосодержащие" и сертифицирована.')format "X(160)"  skip(2)
          string("") format "X(160)"  skip(2)
space(35) string("_______________          ______________              ______________") format "X(70)"  skip
space(35) string("   Должность                подпись                       Ф.И.О    ") format "X(70)"  skip(1)
space(50) string(" М.П.") format "X(5)" skip  .

hide stream out-stream frame bottomframe .

output stream out-stream close.
{ rep/q-print.i 8}

procedure round:  /* Округление число до целого в большую сторону*/
define input  parameter p-dec as decimal no-undo.
define output parameter p-int as decimal no-undo.
if p-dec - TRUNCATE (p-dec, 0) <> 0
then do:
    assign
      p-int = TRUNCATE (p-dec, 0) + 1
    .
end.
else do:
    assign
      p-int = p-dec
    .
end.
end procedure. /* round */

end.