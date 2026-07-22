/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Константы и переменные отчетов

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/* -------------------------  КОНСТАНТЫ  ------------------- */
&global-define BarCode_Length 10
&global-define DOS_CW         235
&global-define DOS_CW_2       232     /* реально на формате А3 умещается 233 condenced-символа */
&global-define A4_LS          198     /* кол-во колонок A4 Landscape */
&global-define A4_CW0         136     /* формат A4 */
&global-define A4_CW          160
&global-define CS_PS          62      /* Current Stream Page Size ( in lines) */
&global-define CP_PS          63      /* Current Printer Page Size ( in lines) = CS_PS + 1 */
&global-define LS_PS_A4       43      /* Current Printer Page Size ( in lines) */
&global-define DF_Name        "rpt"
&global-define PLT_Name       "plt"   /* Price List Title */
&global-define OEMF_Name      "oem"
&global-define OEMF_Ext       ".txt"
&global-define MaxCashNum     10000   /* макс. номер кассы */
&global-define MaxSalemanNum  10000   /* макс. номер продавца */
&global-define MyWaitMess     'Подождите ...'

&if defined( rep_num ) = 0 &then
    &scop rep_num g#report-num
&endif
&global-define std-out-destin value( session :temp-directory + {&DF_Name} + trim( string( {&rep_num}, "->>>>>>>>>9":u ) ) )

&if "{1}" <> "class"
&then
/* --------------------------  ПЕРЕМЕННЫЕ  ----------------------------- */
define {1} shared variable PrintCopiesCounter as integer   no-undo initial 1 . /* кол-во печатаемых экземпляров */
define {1} shared variable RepPathName        as character no-undo .
define {1} shared variable PrintRubl          as logical   no-undo .
&endif
/* $Workfile$   E n d */