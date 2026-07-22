/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие определения для все файлов отрытия запроса в Справочнике клиентов

{1} или пусто или "A" - для принадлежащих БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/04
Author: Bakhtadze Natalya
Creation date: 12/10/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input     parameter attr-option_   as character no-undo .
define input     parameter show-as        as character no-undo .
define input     parameter JoinType       as character no-undo .
define input     parameter Cli-Types      as character no-undo .
define input     parameter Curr-grp-name  as character no-undo .
define input     parameter NameOrCode     as character no-undo .
define input     parameter SupGds         as logical no-undo .
define input     parameter SupCOns        as logical no-undo .
define input     parameter SupServ        as logical no-undo .
define input     parameter BuyGds         as logical no-undo .
define input     parameter BuyCons        as logical no-undo .
define input     parameter BuyServ        as logical no-undo .
define input     parameter Wlim-Kr        as logical no-undo .
define input     parameter v-list-b       as logical   no-undo .

define input-output param  p-rid-list     as  character no-undo .
/*клиенты в выборке*/
define input parameter filter-point as character no-undo .
define input parameter filter-point0 as character no-undo .
define input parameter sort-column-name as character no-undo .
define output parameter p-filter-name   as character  no-undo .
define input-output parameter v-doc-rec as recid no-undo .

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Список клиентов  - открытие запроса".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ ref/t-l-b.i "shared" }

{ gbl/fltopend.i defproc }

DEFINE SHARED BUFFER X_clients FOR ub.clients.

&if "{1}" = "A" &then
DEFINE SHARED BUFFER X_clients-attr FOR ub.clients-attr.
&endif

DEFINE SHARED BUFFER x_temp-list-buyer FOR temp-list-buyer.


DEFINE SHARED QUERY CLi-List{1} FOR X_clients
&if "{1}" = "A" &then
, X_clients-attr
&endif
&if "{1}" = "B" &then
, x_temp-list-buyer
&endif
SCROLLING.


define variable v-list-cond as character no-undo.
def var l-query-was-opened as logical no-undo .
def var sort-column-phrase as character no-undo .
PROCEDURE Set-filter-name :
define input parameter v-filter-name as character no-undo .
  assign
  p-filter-name = v-filter-name
  .
END PROCEDURE.


run proc-main in this-procedure .

procedure proc-main :

  do
  on error undo, return error
  :


case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&glob flt-open-query-handle query cli-list{1}:handle

&glob flt-open-open-query OPEN QUERY CLi-List{1} FOR EACH X_clients no-lock

&glob flt-open-dyn_open-query  FOR EACH X_clients

&if "{1}" = "A" &then
&glob flt-open-open-query-tail , FIRST X_clients-attr NO-LOCK  WHERE  X_clients-attr.obj-type = X_clients.obj-type AND  ~
                                                                   X_clients-attr.obj-code = X_clients.obj-code AND  ~
                                                                   X_clients-attr.attr-code = attr-option_ AND ~
                                                                   X_clients-attr.attr-value = 'yes':U

&glob flt-open-dyn_open-query-tail substitute(', FIRST X_clients-attr NO-LOCK  WHERE  X_clients-attr.obj-type = X_clients.obj-type AND  ~
                                                                   X_clients-attr.obj-code = X_clients.obj-code AND  ~
                                                                   X_clients-attr.attr-code = &1&2&1 AND ~
                                                                   X_clients-attr.attr-value = &1yes&1', ~{&double-quote~}, attr-option_)

&else
&if "{1}" = "B" &then
&glob flt-open-open-query-tail , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))

&glob flt-open-dyn_open-query-tail substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))' ~
                                             ,v-list-b)
&else
&glob flt-open-open-query-tail
&endif
&endif


&glob flt-open-query-was-opened  l-query-was-opened

&glob flt-open-indexed-reposition indexed-reposition

&glob flt-open-sort-column-phrase sort-column-phrase

&glob flt-open-call-point filter-point

&glob flt-open-set-filter-name set-filter-name

&glob flt-open-query p-open-query

&glob flt-open-table-name ub.clients

&glob flt-open-search-option no-lock

&glob flt-open-find-next p-find-next

&glob flt-open-find-recid v-doc-rec

&glob flt-open-find-condition p-find-condition

&glob flt-open-find-buffer-def define buffer X_clients for clients.

&glob flt-open-find-buffer-name X_clients

&scop flt-open-debug-file

&glob flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

&glob current-browser Cli-List{1}

&glob cli-qor ( ~
  ( if SupGds = yes AND X_clients.sup-gds = yes     then yes else no ) OR    ~
  ( if SupCons = yes AND X_clients.sup-cons = yes     then yes else no ) OR  ~
  ( if BuyGds = yes AND X_clients.buy-gds = yes     then yes else no ) OR    ~
  ( if BuyCons = yes AND X_clients.buy-cons = yes     then yes else no ) OR  ~
  ( if BuyServ = yes AND X_clients.buy-serv = yes     then yes else no ) OR  ~
  ( if WLim-kr = yes AND X_clients.lim-kr <> 0    then yes else no )         ~
)

&glob cli-qord substitute('( ~
  ( if &1 = yes AND X_clients.sup-gds = yes     then yes else no ) OR    ~
  ( if &2 = yes AND X_clients.sup-cons = yes     then yes else no ) OR  ~
  ( if &3 = yes AND X_clients.buy-gds = yes     then yes else no ) OR    ~
  ( if &4 = yes AND X_clients.buy-cons = yes     then yes else no ) OR  ~
  ( if &5 = yes AND X_clients.buy-serv = yes     then yes else no ) OR  ~
  ( if &6 = yes AND X_clients.lim-kr <> 0    then yes else no )         ~
)',  SupGds, SupCons, BuyGds, BuyCons, BuyServ, WLim-kr)



/* для брауза B */
&glob cli-qorB ( ~
 ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR  ~
 ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR    ~
 ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR  ~
 ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR    ~
 ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR  ~
 ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR  ~
 ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ~
)

&glob cli-qorBd substitute('( ~
 ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR  ~
 ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR    ~
 ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR  ~
 ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR    ~
 ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR  ~
 ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR  ~
 ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) ~
)',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr)




/* $Workfile$ e n d */