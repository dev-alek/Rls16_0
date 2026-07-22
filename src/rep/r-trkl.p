block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-trkl.p $
$Archive: rep/r-trkl.p $

Требование в кладовую

Автор: Демин Алексей Сергеевич
Дата создания: 09/08/05
Author: Alexey Demin
Creation date: 09/08/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-trkl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-trkl.p $":U .
define variable vss-description as character no-undo init "Требование в кладовую.".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i   new }
{ gbl/prn-lib.i      }

do
on error undo, return error return-value
:
&scoped-define r-fbr-form-width-not-rb 127

define variable v-doc-code                          as character        no-undo.
define variable v-doc-date                          as date             no-undo.
define variable v-counter                           as integer          no-undo.
define variable v-line-string                       as character        no-undo.
define variable v-host-code                         as integer          no-undo.
define variable v-base-code                         as integer          no-undo.
define variable v-units-okei                        as integer          no-undo.

define variable v-sum-qnty                          as decimal          no-undo.

define variable v-prim                              as character     no-undo.
define variable v-artic                             as character     no-undo.
define variable v-gds-name                          as character     no-undo.
define variable v-unit-base                         as character     no-undo.
define variable v-barcode                           as character     no-undo.



define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.
define buffer buf_fbr-doc   for fbr-doc.
define buffer buf_fbr-line  for fbr-line.
define buffer buf_goods     for goods.
define buffer buf_units     for units.

define variable sym1 as character init ":"   no-undo.
define variable sym2 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.
define variable sym6 as character init ":"   no-undo.
define variable sym7 as character init ":"   no-undo.
define variable sym8 as character init ":"   no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define frame fbr-not-in-rb
    sym1                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-counter               column-label "!п/п  ! ! !------!1  !"                        format ">>9"            space(0)
    sym2                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-gds-name              column-label "                   Продукты        и !-----------------------------------------!           Наименование!-----------------------------------------!              2" format "X(41)"          space(0)
    sym3                    column-label "!|!|!|!"                                 format "X(1)"           space(0)
    v-barcode               column-label "товары    !-----------!    Код!-----------!   3  "                 format "X(10)" space(0)
    sym4                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-unit-base             column-label "   Единица!-------------!    Наиме-!   нование!-------------!      4"                   format "X(3)"           space(0)
    sym5                    column-label "!|!|!|!|"                                format "X(1)"           space(0)
    v-units-okei            column-label "измерения  !-------------!Код по  ! ОКЕИ   !-------------!5      "       format ">>>"          space(0)
    sym6                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
    v-sum-qnty              column-label " !Количество !--------------!6       "                   format ">>,>>9.999"     space(0)
    sym7                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
    v-prim                  column-label " !    Примечание!---------------------!        7"                   format "X(4)"          space(0)
    sym8                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)

    HEADER
    skip v-line-string format  "X({&r-fbr-form-width-not-rb})" AT 1
    with width {&A4_CW0} down stream-io NO-BOX.


run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock
     where recid(buf_trn-doc) = p-trn-doc-recid
no-error.
if not available buf_trn-doc
then do:
    message
        "Не найден документ для печати."
    view-as alert-box error.
    return error.
end.
{ gbl/hostcode.i
  buf_trn-doc.obj-type
  buf_trn-doc.obj-code
  v-host-code
}

run prn-lib-open-stream in this-procedure ( input p-mainmenu-handle, input {&CS_PS}, input yes, input no ).

session :set-wait-state( "COMPILER":U ).

 assign
    v-line-string = fill( "-", {&r-fbr-form-width-not-rb} )
.

assign
    v-doc-code      = buf_trn-doc.doc-code
    v-doc-date      = ( if buf_trn-doc.status_ = {&fact} then buf_trn-doc.fact-date else buf_trn-doc.doc-date )

 .
find first clients no-lock
     where clients.obj-type = buf_trn-doc.obj-type
       and clients.obj-code = buf_trn-doc.obj-code
.

put stream PrnLibStream
    "Унифицированная форма №ОП-3"
    skip
    "Утверждена постановлением Госкомстата" space (63) "_ _ _ _ _ _ _ _ _ _ _ _"
    skip
    "России от 25.12.98 № 132" space (75)  "|_ _ _ _ _ Код _ _ _ _ _|"
    skip
                           "Форма по ОКУД|_ _ _ _ _0330503_ _ _ _|" at 87
    skip
                                                      "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100

    skip
    string(  '"' + trim(clients.obj-name) + '"' ) format "X(40)"  at 35    "по ОКПО |_ _ _ _ _ _ _ _ _ _ _ _|" at 92
    skip
         "____________________________________"   at 29   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
    skip
        "предприятие (организация)" at 31       "Вид деятельности по ОКДП|_ _ _ _ _ _ _ _ _ _ _ _|" at 76
    skip
    string(  buf_trn-doc.obj-type + " " + string(buf_trn-doc.obj-code)  ) format "X(40)" at 10   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
    skip
     "____________________________________"    "Вид операции|_ _ _ _ _ _ _ _ _ _ _ _|" at 88
     skip
    "подразделение"
    skip
    string(  string(buf_trn-doc.cli-name) ) format "X(40)"  at 10
    skip
                 "___________________________"
    skip
          "подразделение получатель "
     skip
     "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"   at 90
     skip
     "|           Номер |Дата             |" at 89
     skip
     "|_ _ _ _документа |составления _ _ _|"   at 89
     skip
            "Требование в кладовую" at 50 space(18) "|_ _ _ _ _" (string(v-doc-code)) format "X(8)" at 99 "|_"   string( v-doc-date, "99/99/9999" ) format "x(10)"  at 110 "_ _ _|"
     skip(1)
     "Через кого___________________________________________________________" at 55
      skip
      "фамилия, имя, отчество" at 80

  .

    form with frame fbr-not-in-rb.


    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
                :
        assign
            v-counter = v-counter + 1
        .
        run print-doc-line in this-procedure (
              input recid( buf_doc-line )
            , input v-counter
            , input buf_doc-line.fact-qnty
            , input v-prim
            ).
    end.

    put stream PrnLibStream
        v-line-string format "X({&r-fbr-form-width-not-rb})"
         skip (2)
        "Затребовал заведующий производством:                ____________________                   //_________________"
         skip
        "подпись" at 60 "расшифровка подписи" at 95
        skip(1)
        "Отпуск разрешил:                                    ____________________ "
                skip(1)
        "Руководитель организации:         _____________              _________                    //_________________ "
         skip
          "должность" at 36  "подпись" at 64     "расшифровка подписи"  at 95
        skip(1)
           .

    hide   stream PrnLibStream frame Bottomframe .

    output stream PrnLibStream close.

    session :set-wait-state( "":U ).

    run prn-lib-prn-file in this-procedure ( input p-mainmenu-handle, input 0 ).
  end.

/*==========================================================================*/
procedure print-doc-line :
do
on error undo, return error
:
define input parameter p-doc-line-recid     as recid        no-undo.
define input parameter p-counter            as integer      no-undo.
define input parameter p-fact-qnty          as decimal      no-undo.
define input parameter p-prim               as character      no-undo.

define variable v-bar-code                  as character        no-undo.

define buffer buf_doc-line  for doc-line.
define buffer buf_goods     for goods.

find first buf_doc-line no-lock
    where recid( buf_doc-line ) = p-doc-line-recid
.
find first buf_goods no-lock
     where buf_goods.artic      = buf_doc-line.artic
       and buf_goods.prod-type  = buf_doc-line.prod-type
       and buf_goods.prod-code  = buf_doc-line.prod-code
.
{ gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }.

/*
find first buf_units no-lock
     where buf_units.unit-name = buf_goods.unit-base     no-error
.
*/

display stream PrnLibStream
  sym1 p-counter                                                  @ v-counter
  sym2 buf_goods.gds-name                                         @ v-gds-name
  sym3 string( v-bar-code )                                       @ v-barcode
  sym4 buf_goods.unit-base                                        @ v-unit-base
  sym5 /* string(buf_units.okei)                                     @ v-units-okei */
  sym6 p-fact-qnty                                                @ v-sum-qnty
  sym7 p-prim                                                     @ v-prim
  sym8
with frame fbr-not-in-rb.
down    stream PrnLibStream 1 with frame fbr-not-in-rb.

if line-counter( PrnLibStream ) + 2 > page-size( PrnLibStream )
then do:
  page stream PrnLibStream .
end.

end.
end procedure. /* print-fbr-line */

