/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Общие определения для процедур журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} variable    cashdesc-num    AS    INTEGER         no-undo.
DEFINE {1} variable    saleman-num     AS    INTEGER         no-undo.

DEFINE {1}    variable prodtot_flag       AS    LOGICAL      no-undo.
DEFINE {1}    variable grouptot_flag     AS    LOGICAL       no-undo.
DEFINE {1}    variable OneLinePrinted  AS    LOGICAL     no-undo.
DEFINE {1}    variable my-Set_val_TYPE AS INTEGER No-undo.

DEFINE {1}    variable Rs-sort-str as character no-undo.
DEFINE {1}    variable Rs-by-str as character no-undo.
DEFINE {1}    variable Rs-cass-str as character no-undo.
DEFINE {1}    variable cas-num-str as character no-undo.
DEFINE {1}    variable rs-saleman-str as character no-undo.
DEFINE {1}    variable saleman-str as character no-undo.
DEFINE {1}    variable v-num-chk as integer no-undo.


define Shared variable cas-shft as logical no-undo init no.
define shared variable call-point as char no-undo.

{ gbl/prn-lib.i "{1}" }

define {1} variable Line                as      char    no-undo.
define {1} variable cash_string     as      char    no-undo.
define {1} variable sale_string     as      char    no-undo.
define {1} variable date_string     as      char    no-undo.
/*имя товара + признак*/

define {1} variable NotInc as log no-undo.

define {1} variable namebuf1     as      char    no-undo.
define {1} variable namebuf2     as      char    no-undo.
define {1} variable prodbuf1     as      char    no-undo.
define {1} variable prodbuf2     as      char    no-undo.

define {1} variable stat as logical no-undo.

define {1} variable pcnt  as   decimal  no-undo .
define {1} variable SHBySalers as logical no-undo.
define {1} variable Shrs-seller-cashier as character no-undo .
define {1} variable SHRS-BY as integer no-undo.
define {1} variable SHt-twounit as logical no-undo.
define {1} variable SHRS-SOrt as character no-undo.
define {1} variable SHOnly_tot as logical no-undo.
define variable counter as integer no-undo .
define variable v-seller-cashier-1 as character no-undo .
assign
v-seller-cashier-1 = (if shrs-seller-cashier = "seller"
                      then "Итого прод-ц "
                      else "Итого кассир ").

{ rep/lhstprex.i gds-list-hist }

/* $Workfile$ e n d */