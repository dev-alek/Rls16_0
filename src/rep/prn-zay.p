block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prn-zay.p $
$Archive: rep/prn-zay.p $

Печать заявки на оплату

Автор: Демин Алексей Сергеевич
Дата создания: 12/22/05
Author: Alexey Demin
Creation date: 12/22/05

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter p-recid          as recid        no-undo.
define input parameter p-type            as character no-undo .  /* fo или plat */
define input parameter p-from-forms      as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prn-zay.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/prn-zay.p $":U .
define variable vss-description as character no-undo init "Печать заявки на оплату".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
/*  { rep/fmtcli.i   }*/
/*  { gbl/clntattr.i }*/
/*  { str/trdcalib.i }*/
/*  { rep/torgconf.i }*/

define variable g#report-num as integer   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .

do
on error undo, return error
:



  run get-report-num  in parParentProc ( output g#report-num ).
  run get-quest-print in parParentProc ( output g#quest-print ).

/*  { str/getctxtp.i def }*/
/*  { str/getctxtp.i get }*/

  run waitfram-show in this-procedure ("Ждите печатаю...").

  define variable  Line as character no-undo .
  define variable  Line1 as character no-undo .
  Line = fill("-", 150).
  Line1 = fill("_", 150).
  define variable v-name as character no-undo .
  define variable v-date as character no-undo .
  define variable v-num  as character no-undo .
  define variable v-sum  as decimal   no-undo .
  define variable v-cli  as character no-undo .
  define variable v-bank as character no-undo .
  define variable v-bank1 as character no-undo .
  define variable v-nazn as character no-undo .
  define variable v-str-sum as character no-undo .
  define variable v-contr as character no-undo .
  define variable v-rub as character no-undo .

  define buffer buf_fin-ob   for fin-ob.
  define buffer buf_fin-doc  for fin-doc.
  define buffer buf_contract for contract.

  if p-type = "fo" then do:
    find first buf_fin-ob no-lock where recid(buf_fin-ob) = p-recid .
    find first buf_contract no-lock
      where buf_contract.host-code = buf_fin-ob.host-code
        and buf_contract.contract-code = buf_fin-ob.contract-code
    no-error .
    assign
      v-name  = buf_fin-ob.payer-name
      v-date  = string(buf_fin-ob.pay-date,"99/99/9999")
      v-num   = buf_fin-ob.prn-doc-code
      v-sum   = buf_fin-ob.sum-rubl
      v-cli   = buf_fin-ob.receiver-name
      v-bank  = buf_contract.cli-bank-name
      v-bank1 = "БИК " + buf_contract.cli-bik + {&comma-char} + " р/с "  + buf_contract.cli-r-schet
      v-nazn  = ""
    .
  end.
  else do:
    find first buf_fin-doc no-lock where recid(buf_fin-doc) = p-recid .
    find first buf_contract no-lock
      where buf_contract.host-code = buf_fin-doc.host-code
        and buf_contract.contract-code = buf_fin-doc.contract-code
    no-error .
    assign
      v-name = buf_fin-doc.payer-name
      v-date = string(buf_fin-doc.pay-date,"99/99/9999")
      v-num  = buf_fin-doc.prn-doc-code
      v-sum  = buf_fin-doc.sum-rubl
      v-cli  = buf_fin-doc.receiver-name
      v-bank = buf_fin-doc.receiver-bank-name + {&comma-char} + {&space-char} + buf_fin-doc.receiver-bank-city
              + ( if buf_fin-doc.receiver-dop2 = "":U then "":U else ( {&comma-char} + {&space-char} + buf_fin-doc.payer-dop2 ))
      v-bank1 = "БИК " + buf_fin-doc.receiver-bik + {&comma-char} + " р/с "  + buf_fin-doc.receiver-r-schet
      v-nazn = replace( buf_fin-doc.naznach-plat, "@", "":U )
    .
  end.
  if available buf_contract then assign v-contr = buf_contract.contract-prn-code .
  else                           assign v-contr = "" .

  run rep/wp-rub.p ( v-sum, output v-str-sum, output v-rub ) .

/*    date_string = cur-time-print() .*/
  run prn-lib-open-stream  in this-procedure ( input parParentProc, input {&CS_PS}, input yes, input no ) .

  PUT  STREAM PrnLibStream
    SPACE(5) CAPS("Заявка на оплату")  format "x(100)" SKIP
    SPACE(35)  v-name format "x(100)" SKIP
    Line1              format "x(135)" SKIP(2)
    "   Генеральный директор_______________________________________       Главный бухгалтер________________________________________"    format "x(135)" SKIP(2)
    SPACE(70)  "Заявка на платеж №"  format "x(50)" SKIP
    Line              format "x(135)" SKIP
    "| Дата платежа |          № договора          | № счет-фактуры (или счета) |           Сумма Платежа           | Статья бюджета (код) |" skip
    Line              format "x(135)" SKIP
    "| " v-date format "X(12)" " | "  v-contr  format "X(28)" " | "  v-num  format "X(26)"  " | "  v-sum format "->,>>>,>>>,>>>,>>>,>>>,>>>,>>9.99"   " |                      |"  SKIP
    Line              format "x(135)" SKIP(2)
    Line              format "x(135)" SKIP
    "| Получатель: | "  v-cli  format "X(118)" "|"   SKIP
    Line              format "x(135)" SKIP(2)
    Line              format "x(135)" SKIP
    "| Банковские реквизиты получателя: | "  v-bank  format "X(97)" "|"   SKIP
    Line              format "x(135)" SKIP
    "| "  v-bank1  format "X(132)" "|"   SKIP
    Line              format "x(135)" SKIP
    "| Сумма платежа: | "  v-str-sum  format "X(115)" "|"   SKIP
    Line              format "x(135)" SKIP
    "|" "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "| Назначение платежа: | "  v-nazn  format "X(110)" "|"   SKIP
    Line              format "x(135)" SKIP
    "|" "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "|" "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "| Примечания:      | "    "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "|" "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "| Отв.исполнитель: |                       |                         | Тел.:                         |                                |" skip
    Line              format "x(135)" SKIP
    "| Подразделение:   |" "|" at 135  SKIP
    Line              format "x(135)" SKIP
    "| Руководитель подразделения: " "|" at 135  SKIP
    Line              format "x(135)" SKIP(2)
    Line              format "x(135)" SKIP
    "| Дата оплаты |   № п/п  |      Курс      |               Суммы оплаты RUR            |                 Сумма оплаты USD              |" skip
    Line              format "x(135)" SKIP
    "|             |          |                |                                           |                                               |" skip
    Line              format "x(135)" SKIP(2)
    "<       >_________________  200  г."  SKIP(2)
    "Сдано в _____________________________________________________ банк         <       >_____________________  200 г." skip(2)
    "Ответственный работник бухгалтерии"
  .

  run waitfram-hide in this-procedure .
  output  STREAM PrnLibStream CLOSE.
  if p-from-forms then do:
    { rep/q-print.i 0 }
  end.
  else do:
  run prn-lib-prn-file in this-procedure ( input parParentProc, input 0  ).
  end.
END .