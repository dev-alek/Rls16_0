block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: incdstat.p $
$Archive: str/incdstat.p $

Действия с чеками инвентаризации при смене статуса документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/04
Author: Bakhtadze Natalya
Creation date: 12/28/04

*/

define input parameter parparentproc as widget-handle no-undo .
define parameter buffer t-doc for ub.trn-doc.
define input parameter p-direction as integer no-undo .
/*yes - закрыть no открыть*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: incdstat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/incdstat.p $":U .
define variable vss-description as character no-undo init "Действия с чеками инвентаризации при смене статуса документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
define variable add-sens as logical no-undo init no.
{ str/clc-exc.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ str/trdcalib.i }
{ str/lib-def.i }
{ str/tt-tax.i new  }
{ str/libbcrcn.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }

define variable line-mode as character no-undo init ? .
define variable i            as integer   no-undo.
define variable j            as integer   no-undo.
define variable b-c           as integer   no-undo.             /* обрабатываемый бар-код                           */
define variable scan-txt      as character no-undo.             /* имя обрабатываемого файла со сканера (с расширением) */
define variable is-all        as logical   no-undo.
define variable rate          as decimal   no-undo.             /* коэффициент для единиц из бар-кода        */
define variable g-type        as character no-undo init ?.      /* тип строк документа - товар / услуга */
define variable qnty-str      as character no-undo.             /* строка количества по данному бар-коду со сканера */
define variable bar-str       as character no-undo.             /* строка для чтения бар-кода из файла              */
define variable part-list     as character no-undo initial "".  /* список бар-кодов партий для привязки места       */
define variable varscales-pref      as character no-undo.
define variable varpgscales-pref      as character no-undo.
define variable varscales-pref-type as character no-undo.
def stream ggg.
define stream cur.
define stream log.                                             /* журнал сообщений */
define stream ler.                                             /* журнал ошибок из журнала сообщений*/
define stream err.                                             /* журнал ошибок */
define frame a
    i format ">>>>9" label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".

{ str/bc-res.i "all" "log" }
{ str/scr-neb.i }
{ str/anlz-bc.i new }
define temp-table tt-bar-code-doc no-undo
field b-c      as integer   /*бар-код  */
field scn-qnty as decimal   /*кол-во   */
index pi is primary b-c.
/*Для запоминания старых значений doc-line и наката инкремента на шапку накладной*/
define temp-table old-doc-line no-undo like doc-line.

/*для запоминания строк, котореы не были обработаны ранее - когда чек включался в статусе {&permitted}
  или когда включенные в статусе {&wayb} при переводе статуса
*/

define temp-table tt-chk-gds no-undo like ub.chk-gds.
define variable p-chk-gds-rid-list as character no-undo .
define variable p-call-handle  as handle no-undo .
define variable p-ii as integer no-undo .
define variable p-ii-ok as integer no-undo .
define variable v-curr-r-b  as character no-undo .
define variable cas-shft    as logical no-undo init no.
define variable chk-amount as integer.
define variable p-day-only  as logical no-undo .
define variable p-rid-list as character no-undo . /*список recid chk-doc если по нескольким */
define variable p-is-all as logical no-undo init no. /*прибавлять количество по товару*/


define buffer X_chk-doc for ub.chk-doc.
DEFINE QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~} view-as alert-box ERROR

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure

{ str/inc-invr.i }

{ str/sclspref.i varscales-pref varpgscales-pref }

p-call-handle  = this-procedure:handle .
is-all = no.

run proc-main in this-procedure ( input t-doc.status_, input t-doc.flag, input p-direction ) no-error .
if error-status:error then undo, return error return-value .

procedure proc-next-c-d :

  do
  on error undo, return error
  :
  end.

end procedure. /* proc-next-c-d */

procedure display-chk :
define input parameter p-chk-amount as integer no-undo .

  do
  on error undo, return error
  :

  end.

end procedure. /* display-chk */

procedure  display-processed:
define input parameter p-ii as integer no-undo .

  do
  on error undo, return error
  :

  end.

end procedure. /* display-processed */

procedure display-processed-ok :
define input parameter p-ii-ok as integer no-undo .

  do
  on error undo, return error
  :

  end.

end procedure. /*  display-processed-ok  */

procedure display-message :
define input parameter p-message as character no-undo .

  do
  on error undo, return error
  :

  end.

end procedure. /*  display-processed-ok  */