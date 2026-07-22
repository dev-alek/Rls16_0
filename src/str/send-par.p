block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-par.p $
$Archive: str/send-par.p $

Отсылка на кассу параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.cash-desk.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
define input parameter p-what-send as character no-undo.
*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-par.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-par.p $":U .
define variable vss-description as character no-undo init "Отсылка на кассу параметров".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable p-db-num   like ub.cash-desk.db-num no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable p-pos-type like ub.cash-desk.pos-type no-undo .
define variable p-cash-num like ub.cash-desk.cash-num no-undo .
define variable action     as character no-undo .
define variable p-section as character no-undo .
define variable p-what-send as character no-undo .
/*гдк хранить файлы неприкосоновеннхы ручнхы настроек может быть no TH NCR*/
define variable ncr-save-param               as character         no-undo init 'no'.
/*счетчик записей текущего пакета категорийных скидок NCR*/
define variable cr-ncr-dis-kat               as integer       no-undo .

define variable conf-attr as character no-undo .
define variable conf-par  as character no-undo .
define variable par-type as character no-undo .
define variable i-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define temp-table temp-talon-pay no-undo
field cdpay-code1 as integer
field cdpay-code2 as integer
field diap as character
field rank as integer
index pi is unique primary cdpay-code1
index pi2 cdpay-code2
index irank rank
.


define stream bar.
define stream plucash.
assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
p-pos-type = entry(3, p-parameter, {&delim-par})
p-cash-num = integer(entry(4, p-parameter, {&delim-par}))
action     = entry(5, p-parameter, {&delim-par})
p-what-send    = entry(6, p-parameter, {&delim-par})
p-section    = entry(7, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
i-obj-code = p-obj-code.
{ gbl/hostcode.i ~{&shop~} p-obj-code v-host-code }

{ bge/bgelib.i }
&glob xml-cd-doc-name 'config'
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ gbl/cd-attr.i }
{ str/defcncrd.i }
{ str/cp-isuse.i }

/*PROCEDURE putc-par*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-par.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cypar.i }

/*PROCEDURE SENDING.*/
{ str/cd-separ.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка параметров на кассу &1 &2 маг&3", p-pos-type, p-cash-num, p-obj-code)
                                          ).



RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке параметров на кассу &1 &2 маг&3"
                         , p-pos-type, p-cash-num, p-obj-code
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.
if v-view-log then return error .



procedure create-ncr-par :
/*обновление файлов p_regpar.dat */
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.


  do
  on error undo, return error
  :
    FIND FIRST buf_cash-ncr-dis-kat where
            buf_cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
    if not avail buf_cash-ncr-dis-kat then do:
      create buf_cash-ncr-dis-kat.
      error-status:error = false.
    end.
    buf_cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
    cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
    assign
    buf_cash-ncr-dis-kat.dis-kat  = 0
    buf_cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
    buf_cash-ncr-dis-kat.cd-subject-name  = p-subject-name
    .
  end.

end procedure. /* create-ncr-par */