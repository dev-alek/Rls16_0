/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контекст разбора и создания чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/25/08
Author: Bakhtadze Natalya
Creation date: 07/25/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/dr-flddf.i }

&if "{1}" = "tt-wd" &then

/*таблица строк на который НЕ НАДО размазывать скидку на ИТОГ/ПОДИТОГ*/
define temp-table {2}tt-wd no-undo
field doc-code like ub.chk-doc.doc-code
field record-type like ub.chk-discnt.record-type
field line-type like ub.chk-discnt.line-type
field discnt-id like ub.chk-discnt.discnt-id
field line-num like ub.chk-gds.line-num
field wd-sum   like ub.chk-doc.netto /*сумма которая не участвуем в предоставлении скидки на итог*/
index pi is primary
line-num
.
&endif

&if "{1}" = "dis-card-mask" &then
define temp-table {2}dis-card-mask no-undo
like ub.dis-card-mask
.
&endif

&if "{1}" = "temp-table" &then
define {3} temp-table {2}  no-undo
&scop field_ field
&scop no-undo_
&scop prefix
&endif

&if "{1}" = "vars" &then
&scop field_ define variable
&scop no-undo_ no-undo .
&scop prefix {2}
&endif

&if "{1}" = "temp-table" or "{1}" = "vars" &then
/*заполняются не в libchkvl_create-context!*/
{&field_} {&prefix}parparentproc       as widget-handle           {&no-undo_}
{&field_} {&prefix}p-log-handle        as handle                  {&no-undo_}
{&field_} {&prefix}p-log-file-name     as character               {&no-undo_}
{&field_} {&prefix}view-log            as logical                 {&no-undo_}
{&field_} {&prefix}ll                  as integer                 {&no-undo_}
{&field_} {&prefix}tt-wd-bh            as handle                  {&no-undo_}
{&field_} {&prefix}pos-type            as character               {&no-undo_}
{&field_} {&prefix}cash-num            as integer                 {&no-undo_}

/*общие*/
{&field_} {&prefix}obj-type            as character init {&shop}  {&no-undo_}
{&field_} {&prefix}obj-code            as integer                 {&no-undo_}
{&field_} {&prefix}db-num              as integer                 {&no-undo_}
{&field_} {&prefix}r-b                 as character               {&no-undo_}
{&field_} {&prefix}host-code           as integer                 {&no-undo_}
{&field_} {&prefix}base-code           as integer                 {&no-undo_}
{&field_} {&prefix}cre-pay             as integer                 {&no-undo_}
{&field_} {&prefix}is-catering         as logical                 {&no-undo_}
{&field_} {&prefix}is-cdinv            as logical                 {&no-undo_}
{&field_} {&prefix}is-ptrl             as logical                 {&no-undo_}
{&field_} {&prefix}is-wth              as logical                 {&no-undo_}
/*закачивать чеки в продажу и резервировать после закрытия чека*/
{&field_} {&prefix}process-sale        as logical                 {&no-undo_}
/*использоватеь маски ДК для разбора и хранения чеков привзяанных к неперсонифицированным маскам картам*/
{&field_} {&prefix}dc-mask             as logical                 {&no-undo_}
/*использоватеь маски ДК для разбора и хранения чеков привязанных к персонифицированным картам*/
{&field_} {&prefix}card-by-mask        as logical                 {&no-undo_}
{&field_} {&prefix}sclspref            as character               {&no-undo_}
{&field_} {&prefix}scpgpref            as character               {&no-undo_}
{&field_} {&prefix}scpgpref-pre        as character               {&no-undo_}
{&field_} {&prefix}doc-prt             as logical                 {&no-undo_}
/*использовать смены на объекте в целом*/
{&field_} {&prefix}shift-on            as logical                 {&no-undo_}
/*использовать смены на кассе для данного объекта*/
{&field_} {&prefix}cas-shft            as logical                 {&no-undo_}
/*время начала пересменки в секундах при параметре виртуальных смен= 2 - интеллектуально*/
{&field_} {&prefix}t-shft              as integer                 {&no-undo_}
/*использовать виртуальные смены*/
{&field_} {&prefix}v-shft              as integer                 {&no-undo_}
/*читаем ли бензиновые чеки*/
{&field_} {&prefix}ptrl-check          as logical                 {&no-undo_}
/*читаем ли аннулированные чеки*/
{&field_} {&prefix}annu-check          as logical                 {&no-undo_}
/*читаем ли чеки z-отчета*/
{&field_} {&prefix}z-check             as logical                 {&no-undo_}


/*нудны только для разбора чеков*/
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
{&field_} {&prefix}hnum                as logical                 {&no-undo_}
/*разрешен чек со 100 скидкой*/
{&field_} {&prefix}is-100-discnt       as logical                 {&no-undo_}
/*нулевой кассир - для некоторых чеков магии не преисылается код кассира*/
{&field_} {&prefix}zero-cashier        as integer                 {&no-undo_}
/*точность представления - кол-во знаков после зап*/
{&field_} {&prefix}rnd-znak            as integer                 {&no-undo_}
/*брать курсы из спула или из BO*/
{&field_} {&prefix}cas-curs            as logical                 {&no-undo_}

/*нужны только для кассы IBS*/
{&field_} {&prefix}nam-2str            as logical                 {&no-undo_}
{&field_} {&prefix}nam-artc            as logical                 {&no-undo_}
{&field_} {&prefix}cod-pcod            as logical                 {&no-undo_}
{&field_} {&prefix}name-2cd            as character               {&no-undo_}
{&field_} {&prefix}how-temp-disc       as character               {&no-undo_}
{&field_} {&prefix}nalc                as integer                 {&no-undo_}
{&field_} {&prefix}rmethod-type        as character               {&no-undo_}
{&field_} {&prefix}rmethod-coeff       as decimal                 {&no-undo_}
{&field_} {&prefix}serial-code         as character               {&no-undo_}
{&field_} {&prefix}salesman-mandatory  as integer                 {&no-undo_}
{&field_} {&prefix}sales-man           as integer                 {&no-undo_}
{&field_} {&prefix}salesman-psn-code   as integer                 {&no-undo_}
{&field_} {&prefix}pos-type-for-discnt as character               {&no-undo_}
{&field_} {&prefix}manual-discnt       as integer                 {&no-undo_}
{&field_} {&prefix}is-grp-totals       as logical                 {&no-undo_}
{&field_} {&prefix}is-gds-totals       as logical                 {&no-undo_}
/*по закрытым чекам */
{&field_} {&prefix}cash-counter        as decimal                 {&no-undo_}
/*в текущем чеке*/
{&field_} {&prefix}pre-cash-counter    as decimal                 {&no-undo_}
{&field_} {&prefix}qnty-change         as logical                 {&no-undo_}
{&field_} {&prefix}log-level           as integer                 {&no-undo_}
{&field_} {&prefix}chk-discnt-table    as handle                  {&no-undo_}
&if "{1}" = "temp-table" &then
help {&dr-flddf_cntxt_chk-discnt-table}
&endif
{&field_} {&prefix}chk-gds-table       as handle                  {&no-undo_}
&if "{1}" = "temp-table" &then
help {&dr-flddf_cntxt_chk-gds-table}
&endif
{&field_} {&prefix}chk-pay-table       as handle                  {&no-undo_}
&if "{1}" = "temp-table" &then
help  {&dr-flddf_cntxt_chk-pay-table}
&endif
{&field_} {&prefix}z-number            as integer                 {&no-undo_}
{&field_} {&prefix}shift-num           as integer                 {&no-undo_}
{&field_} {&prefix}shift-date          as date                    {&no-undo_}
{&field_} {&prefix}shift-name          as character               {&no-undo_}
{&field_} {&prefix}emulator-mode       as integer                 {&no-undo_}
/*когда = 0 тогда НЕ ЭМУЛЯТОР!!!!*/


/*нужны для IBM*/
/*спец суммовые групп касса IBM IBm-XML*/
{&field_} {&prefix}ibmgroup            as logical                 {&no-undo_}


&endif

&if "{1}" = "temp-table" &then
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
&endif

&if  "{1}" = "vars=temp-table" &then

&scop left-prefix {2}
&scop right-prefix {3}
assign
/*заполняются не в libchkvl_create-context!*/
{&left-prefix}parparentproc                      =  {&right-prefix}parparentproc
{&left-prefix}p-log-handle                       =  {&right-prefix}p-log-handle
{&left-prefix}p-log-file-name                    =  {&right-prefix}p-log-file-name
{&left-prefix}view-log                           =  {&right-prefix}view-log
{&left-prefix}ll                                 =  {&right-prefix}ll
{&left-prefix}tt-wd-bh                           =  {&right-prefix}tt-wd-bh
{&left-prefix}pos-type                           =  {&right-prefix}pos-type
{&left-prefix}cash-num                           =  {&right-prefix}cash-num


{&left-prefix}obj-type                           =  {&right-prefix}obj-type
{&left-prefix}db-num                             =  {&right-prefix}db-num
{&left-prefix}obj-code                           =  {&right-prefix}obj-code

/*общие*/
{&left-prefix}r-b                                =  {&right-prefix}r-b
{&left-prefix}host-code                          =  {&right-prefix}host-code
{&left-prefix}base-code                          =  {&right-prefix}base-code
{&left-prefix}cre-pay                            =  {&right-prefix}cre-pay
{&left-prefix}is-catering                        =  {&right-prefix}is-catering
{&left-prefix}is-cdinv                           =  {&right-prefix}is-cdinv
{&left-prefix}is-ptrl                            =  {&right-prefix}is-ptrl
{&left-prefix}is-wth                             =  {&right-prefix}is-wth
{&left-prefix}dc-mask                            =  {&right-prefix}dc-mask
{&left-prefix}card-by-mask                       =  {&right-prefix}card-by-mask
{&left-prefix}sclspref                           =  {&right-prefix}sclspref
{&left-prefix}scpgpref                           =  {&right-prefix}scpgpref
{&left-prefix}scpgpref-pre                       =  {&right-prefix}scpgpref-pre
{&left-prefix}doc-prt                            =  {&right-prefix}doc-prt
{&left-prefix}shift-on                           =  {&right-prefix}shift-on
{&left-prefix}cas-shft                           =  {&right-prefix}cas-shft
{&left-prefix}t-shft                             =  {&right-prefix}t-shft
{&left-prefix}v-shft                             =  {&right-prefix}v-shft
{&left-prefix}ptrl-check                         =  {&right-prefix}ptrl-check
{&left-prefix}annu-check                         =  {&right-prefix}annu-check
{&left-prefix}z-check                            =  {&right-prefix}z-check

/*нужны только для разбора чеков*/
{&left-prefix}hnum                               =  {&right-prefix}hnum
{&left-prefix}is-100-discnt                      =  {&right-prefix}is-100-discnt
{&left-prefix}zero-cashier                       =  {&right-prefix}zero-cashier
{&left-prefix}rnd-znak                           =  {&right-prefix}rnd-znak
{&left-prefix}cas-curs                           =  {&right-prefix}cas-curs

/*нужны только для кассы IBS не заполняются в libchkvl_create-context*/
{&left-prefix}nam-2str                           =  {&right-prefix}nam-2str
{&left-prefix}nam-artc                           =  {&right-prefix}nam-artc
{&left-prefix}cod-pcod                           =  {&right-prefix}cod-pcod
{&left-prefix}name-2cd                           =  {&right-prefix}name-2cd
{&left-prefix}how-temp-disc                      =  {&right-prefix}how-temp-disc
{&left-prefix}nalc                               =  {&right-prefix}nalc
{&left-prefix}serial-code                        =  {&right-prefix}serial-code
{&left-prefix}salesman-mandatory                 =  {&right-prefix}salesman-mandatory
{&left-prefix}sales-man                          =  {&right-prefix}sales-man
{&left-prefix}salesman-psn-code                  =  {&right-prefix}salesman-psn-code
{&left-prefix}pos-type-for-discnt                =  {&right-prefix}pos-type-for-discnt
{&left-prefix}manual-discnt                      =  {&right-prefix}manual-discnt
{&left-prefix}is-grp-totals                      =  {&right-prefix}is-grp-totals
{&left-prefix}is-gds-totals                      =  {&right-prefix}is-gds-totals
{&left-prefix}chk-discnt-table                   =  {&right-prefix}chk-discnt-table
{&left-prefix}chk-gds-table                      =  {&right-prefix}chk-gds-table
{&left-prefix}chk-pay-table                      =  {&right-prefix}chk-pay-table
{&left-prefix}z-number                           =  {&right-prefix}z-number
{&left-prefix}shift-num                          =  {&right-prefix}shift-num
{&left-prefix}shift-date                         =  {&right-prefix}shift-date
{&left-prefix}shift-name                         =  {&right-prefix}shift-name
{&left-prefix}emulator-mode                      =  {&right-prefix}emulator-mode



/*нужны для IBM не заполняются в libchkvl_create-context*/
{&left-prefix}ibmgroup                           =  {&right-prefix}ibmgroup
.

&endif


/* $Workfile$ e n d */