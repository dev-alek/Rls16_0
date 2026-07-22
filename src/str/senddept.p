block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: senddept.p $
$Archive: str/senddept.p $

Пересылка справочника подразделений - для АРМ ресторан

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/04/03
Author: Bakhtadze Natalya
Creation date: 12/04/03

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.db.db-num no-undo .
/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: senddept.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/senddept.p $":U .
def var vss-description as character no-undo init "Пересылка справочника подразделений - для АРМ ресторан".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable  p-db-num like ub.db.db-num no-undo .
/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable action     as character no-undo .

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
p-obj-type = entry(2, p-parameter, {&delim-par})
p-obj-code = integer(entry(3, p-parameter, {&delim-par}))
action     = entry(4, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error.

{ bge/bgelib.i }
&glob xml-cd-doc-name 'data'
{ str/cd-xml.i }
{ str/cdsnddef.i }

/*вспомогат*/
def var dops as character no-undo format "X(250)".
def var dopst as character no-undo format "X(1)".
define variable v-host-code as integer no-undo .

if not g#news
and not g#auto
then do:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-restaurant_work':U
  {&cntxt-firm}
  v-host-code
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if NOT glog then return .
end.


/*PROCEDURE putc-dept.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-30.i }


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyc30.i }

/*PROCEDURE SENDING.*/
{ str/cd-sen30.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &1 БД &2 информации о подразделениях и группах товаров", {&cd-type-MAGIA-XML}, p-db-num)
                                          ).



RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке информации о подразделениях и группах товаров на кассы  БД &1"
                         , p-db-num
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
"'send-cd.txt'" }