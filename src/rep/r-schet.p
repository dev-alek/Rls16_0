block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-schet.p $
$Archive: rep/r-schet.p $

Печать счета Author: неизвестен, наследник Mkochetkov

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id   as recid          no-undo.
define input parameter p-mode   as character      no-undo.

  define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
  define variable vss-author      as character no-undo init "$Author: expertek $":U .
  define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  define variable vss-workfile    as character no-undo init "$Workfile: r-schet.p $":U .
  define variable vss-archive     as character no-undo init "$Archive: rep/r-schet.p $":U .
  define variable vss-description as character no-undo init "Печать счета".
  { cmp/vssrevis.i     }
  { cmp/str-glbl.i }
  { cmp/library.i }

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  { cmp/r-pril.i       }
  { rep/fmtcli.i       }
  { gbl/clntattr.i     }
  { str/trdcalib.i     }
  { rep/torgconf.i     }

  { str/getctxtp.i def }
  { str/getctxtp.i get }

DEFINE  BUFFER t-doc FOR trn-doc.
DEFINE  BUFFER buf_clients FOR clients.

DEFINE new shared  STREAM Out_Stream .

{ cmp/open-out.i STREAM Out_Stream " "}

def buffer      Our_Object for clients.
def buffer      Our_Host for clients.


FIND t-doc WHERE recid(t-doc) = rec_id  NO-LOCK NO-ERROR.

FIND buf_clients WHERE buf_clients.obj-type = t-doc.cli-type and
                                  buf_clients.obj-code = t-doc.cli-code NO-LOCK.
FIND Our_Object WHERE Our_Object.obj-type = t-doc.obj-type and
                                          Our_Object.obj-code = t-doc.obj-code NO-LOCK.
FIND Our_Host WHERE Our_Host.obj-type = {&cmp} and
                                          Our_Host.obj-code = t-doc.host-code NO-LOCK.



/*def buffer     bank_buf    for     bank .*/
def buffer     cli-pbank    for     clients .
def buffer     cli-obj    for     clients .

def var     LogRes       as      log            no-undo.

def var     s1               as      character             no-undo.
def var     s2               as      character             no-undo.
def var     Wrkr_name as      character             no-undo.
def var     Isp_name as      character             no-undo.


FIND Our_Host WHERE Our_Host.obj-type = {&cmp} AND Our_Host.obj-code = t-doc.host-code NO-LOCK.
FIND firm WHERE firm.firm-code = Our_Host.obj-code NO-LOCK.

  define variable v-curr-code as integer   no-undo .
  if printRubl = yes then assign v-curr-code = 0 .
  else do:  { gbl/basecode.i t-doc.host-code v-curr-code } end.

  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.

  PUT STREAM Out_Stream
    space(6) ( string( Our_Host.obj-name , "X(60)" ) +
    ( if v-torgconf-self-schet-exists then ( "Р/c " + v-torgconf-self-bank-r-schet + ' в "' + v-torgconf-self-bank-name + '" ' ) else " " ) )  format "X(130)" SKIP
    space(6) ( string( trim( firm.city ) + " " + string( firm.ind ) , "X(60)" ) +
    ( if v-torgconf-self-schet-exists then ( "к/с " + v-torgconf-self-bank-c-schet + ", БИК " + v-torgconf-self-bank-bik +
    ( if available firm then ( ", {&abbr_inn_allshift} " + trim( firm.inn ) ) else "" ) ) else " " ) )  format "X(130)" SKIP .

  PUT STREAM Out_Stream
    space(6) ( string( firm.addres1, "x(60)" ) +
    ( if available firm then ( "{&abbr_okonh_allshift} " + trim( string( firm.okonh, "x(61)" ) ) ) else "" ) ) format "X(131)" SKIP .

  if firm.addres2 <> "" then  PUT STREAM Out_Stream SPACE(6) firm.addres2 format "X(130)" SKIP .

  PUT STREAM Out_Stream SPACE(6)  "тел." + firm.phone + ", факс " + firm.fax format "X(130)" .

  PUT STREAM Out_Stream " " SKIP .

s1 = fill("-", 140).
FIND cli-obj WHERE cli-obj.obj-type = t-doc.obj-type AND
                                  cli-obj.obj-code = t-doc.obj-code NO-LOCK .
if p-mode <> "mag"
then do:
    PUT STREAM Out_Stream SPACE(22) s1 format "X(72)" SKIP .
    PUT STREAM Out_Stream
            SPACE(22) "Грузоотправитель : " + Our_Host.obj-name format "X(100)" SKIP
            space(41) cli-obj.obj-name format "X(90)" SKIP
            SPACE(22) s1 format "X(72)" SKIP
            SPACE(22) "Грузополучатель  : " + buf_clients.obj-name + "(" + string(buf_clients.obj-code) + ")" format "X(100)" SKIP
            SPACE(22) s1 format "X(72)" SKIP(1) .
    PUT STREAM Out_Stream
            ( if  t-doc.status_ = {&inquiry}
            then " З А П Р О С   N "
            else "С Ч Е Т       N " ) AT 32 format "X(17)"
                t-doc.doc-code format "X(10)" "  от  " t-doc.doc-date format "99.99.9999" SKIP
                s1 format "X(102)" SKIP.
    PUT STREAM Out_Stream SPACE(12)
            SPACE(12) "Плательщик   " + buf_clients.obj-name + "(" + string(buf_clients.obj-code) + ")" format "X(102)" SKIP
            SPACE(12) "Расч. счет  N                        ," format "X(36)" space(2)
                            "Банк                                      Гор. " format "X(50)" SKIP
            SPACE(12) s1 format "X(102)" SKIP
    SPACE(12)
    "Дата отпр.         способ отпр.             Сумма счета ___________   Квит/накл.  N"
    format "X(100)" SKIP
            SPACE(12) "Упаковка        число мест       вес        Отметка об оплате _____"
                    format "X(100)" SKIP(1) .
        PUT STREAM Out_Stream
            SPACE(12) s1 format "X(38)" " В Н И М А Н И Е " format "X(17)" s1 format "X(47)" SKIP .
    if t-doc.status_ <> {&inquiry} then
        PUT STREAM Out_Stream
            SPACE(23) "Срок оплаты до " + string( t-doc.fact-date, "99.99.9999" ) +
                    ". Товар по просроченным счетам отпускается" format "X(100)" SKIP
            SPACE(23) "по цене на момент прихода денег. Товар резервируется на " +
                ( if v-cntxp-rsrv-time = 0 then "2" else string(v-cntxp-rsrv-time, ">>9") ) + " дней."
                    format "X(100)" SKIP .
    else
        PUT STREAM Out_Stream
            SPACE(32) " ТОВАР  Н Е  З А Р Е З Е Р В И Р О В А Н." format "X(100)" SKIP .

    PUT STREAM Out_Stream SPACE(22) s1 format "X(70)" SKIP(1) .
    FIND pay-type WHERE pay-type.obj-code = t-doc.pay-code NO-LOCK NO-ERROR.
    PUT STREAM Out_Stream
        string( "вид оплаты   :" + ( if available pay-type then pay-type.obj-name else "?" ) ) AT 10 format "X(60)" SKIP
        string( "примечание   :" + ( if ( NOT can-do( {&fact}, t-doc.status_ ) OR LogRes ) AND NOT ( t-doc.PS BEGINS "@" ) then  t-doc.PS else " " ) ) AT 10 format "X(100)" SKIP .

end.        /* if p-mode <> "mag" */
else do:
    PUT STREAM Out_Stream
            skip(3)
            "С Ч Е Т       N "  AT 32 format "X(17)"
                "" format "X(10)" "  от  " t-doc.doc-date format "99.99.9999" SKIP(1)
        SPACE(12) "Плательщик   " + buf_clients.obj-name + "(" + string(buf_clients.obj-code) + ")" format "X(102)" SKIP.
end.        /* if p-mode = "mag" */

if p-mode <> "mag"
then do:
    run rep/outp-tbl.p ( parParentProc, rec_id, "no-print", "oldexp" ).
end.
else do:
    run rep/outp-tbl.p ( parParentProc, rec_id, "no-print,mag", "oldexp" ).
end.