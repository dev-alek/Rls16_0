block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendstpl.p $
$Archive: str/sendstpl.p $

Пересылка стоплистов на кассы одного

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/06/07
Author: Bakhtadze Natalya
Creation date: 07/06/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendstpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendstpl.p $":U .
define variable vss-description as character no-undo init "Пересылка стоплистов на кассы одного магазина".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable i-obj-code like ub.clients.obj-code no-undo.
define variable p-stop-list-code as character no-undo.
define variable action as character no-undo init "U":U.

{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }

&scop view-log   ~{ str/cdviewlg.i   ~
                   "'!!!При отсылке информации на кассы произошли ошибки!!!'" ~
                   "'send-cd.txt'" ~}   ~
                    return

define variable ii as integer no-undo.
define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_stop-list for ub.stop-list.

/*выбор кнопки*/
define variable v-num as integer no-undo.
DEFINE VARIABLE var-report-num as integer no-undo .


assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
p-stop-list-code = entry(2, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

find first buf_stop-list no-lock where
          buf_stop-list.classif-type = {&table_Dis-card}
       and buf_stop-list.stop-list-code = p-stop-list-code no-error .
if not available buf_stop-list then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входного параметра p-stop-list-code&1:не найден стоп-лист с таким номером"
                        ,p-stop-list-code
                        )               ).
  assign
  v-view-log = yes.
  {&view-log}.

end.

assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.

FIND ub.shop WHERE ub.shop.obj-code = i-obj-code NO-LOCK .
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK .


run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка на кассы &1&2 стоплистов", {&shop}, i-obj-code)
                                              ).
RUN SENDING in this-procedure ( input p-stop-list-code ) no-error.
{&sending-error}.


{&viewlog}.

/*PROCEDURE putc-cli.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-sl.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cysl.i }

/*PROCEDURE SENDING.*/
{ str/cd-sedsl.i }