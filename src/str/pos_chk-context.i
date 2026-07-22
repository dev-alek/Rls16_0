/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контекст чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/08
Author: Bakhtadze Natalya
Creation date: 08/03/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "temp-table" &then
define {3} temp-table {2} no-undo  before-table {4}
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
{&field_} {&prefix}doc-code as character                                                                  {&no-undo_}
{&field_} {&prefix}obj-code as integer                                                                    {&no-undo_}
&if "{1}" = "temp-table" &then
help {&dr-flddf_doc_obj-code}
&endif
{&field_} {&prefix}direction as integer                                                                   {&no-undo_}
{&field_} {&prefix}rowid_ as rowid                                                                        {&no-undo_}
{&field_} {&prefix}chk-type as integer                                                                    {&no-undo_}
{&field_} {&prefix}prev-chk-type as integer                                                               {&no-undo_}
{&field_} {&prefix}lng as integer                                                                         {&no-undo_}
{&field_} {&prefix}lnp as integer                                                                         {&no-undo_}
{&field_} {&prefix}lnd as integer                                                                         {&no-undo_}
{&field_} {&prefix}lnc as integer                                                                         {&no-undo_}
{&field_} {&prefix}lnpp as integer                                                                        {&no-undo_}
{&field_} {&prefix}chk-date as date                                                                       {&no-undo_}
{&field_} {&prefix}chk-time as integer                                                                    {&no-undo_}
{&field_} {&prefix}current-date as date                                                                   {&no-undo_}
{&field_} {&prefix}current-time as integer                                                                {&no-undo_}
{&field_} {&prefix}bank-rate as decimal /*ЦБ*/                                                            {&no-undo_}
{&field_} {&prefix}bank-scale as integer                                                                  {&no-undo_}
/*приведенный курс*/
{&field_} {&prefix}base-rate as decimal                                                                   {&no-undo_}
help {&dr-flddf_doc_base-rate}
{&field_} {&prefix}cash-rate as decimal                                                                   {&no-undo_}
{&field_} {&prefix}cash-scale as integer                                                                  {&no-undo_}
/*в момент sub-total*/
{&field_} {&prefix}a-chk-date as date                                                                     {&no-undo_}
{&field_} {&prefix}a-chk-time as integer                                                                  {&no-undo_}
{&field_} {&prefix}a-bank-rate as decimal /*ЦБ*/                                                          {&no-undo_}
{&field_} {&prefix}a-bank-scale as integer                                                                {&no-undo_}
{&field_} {&prefix}a-base-rate as decimal                                                                 {&no-undo_}
{&field_} {&prefix}a-cash-rate as decimal                                                                 {&no-undo_}
{&field_} {&prefix}a-cash-scale as integer                                                                {&no-undo_}
{&field_} {&prefix}src-cli-type as character                                                              {&no-undo_}
{&field_} {&prefix}src-cli-code as integer                                                                {&no-undo_}
{&field_} {&prefix}src-d-mask as character                                                                {&no-undo_}
{&field_} {&prefix}src-d-card as character                                                                {&no-undo_}
{&field_} {&prefix}d-card as character                                                                    {&no-undo_}
{&field_} {&prefix}d-pcnt as decimal                                                                      {&no-undo_}
&if "{1}" = "temp-table" &then
help {&dr-flddf_doc_dc-d-pcnt}
&endif
{&field_} {&prefix}cash-d-pcnt as decimal                                                                 {&no-undo_}
&if "{1}" = "temp-table"  &then
help {&dr-flddf_doc_dc-cash-d-pcnt}
&endif
{&field_} {&prefix}category as integer                                                                    {&no-undo_}
&if "{1}" = "temp-table" &then
help {&dr-flddf_doc_dc-category}
&endif
{&field_} {&prefix}sales-man as integer                                                                   {&no-undo_}
{&field_} {&prefix}salesman-psn-code as integer                                                           {&no-undo_}
/*0=шапка 1 =товары 2=итог 3=платеж */
{&field_} {&prefix}step as integer                                                                        {&no-undo_}
{&field_} {&prefix}src-qnty as decimal                                                                    {&no-undo_}
 /*нетто товарное учитывает только скидки на товар  округленное до 2 знака**/
{&field_} {&prefix}gds-netto as decimal                                                                   {&no-undo_}
 /*нетто учитывает скидки на товар и на итог  округленное до 2 знака**/
{&field_} {&prefix}sub-netto as decimal                                                                   {&no-undo_}
/*общее нетто учитывает скидки на товар на итог на оплату округленное до 2 знака*/
{&field_} {&prefix}netto as decimal                                                                       {&no-undo_}
{&field_} {&prefix}all-pay-rubl as decimal                                                                  {&no-undo_}
{&field_} {&prefix}all-pay-base as decimal                                                                  {&no-undo_}
                                                                                                          {&no-undo_}
/*st-r-b отличается от netto тем что там не учитываются скидки на платеж*/
{&field_} {&prefix}st-r-b as decimal                                                                      {&no-undo_}
/*нетто без учета скидок на платеж -  sub-netto округленное по правилам RMETHOD*/
{&field_} {&prefix}st-rubl as decimal                                                                     {&no-undo_}
{&field_} {&prefix}st-base as decimal                                                                     {&no-undo_}
/*st-for-discnt-r-b отличается от st-r-b тем что там учитываются запреты скидкок на итог для товара*/
{&field_} {&prefix}st-for-discnt-r-b as decimal                                                           {&no-undo_}
help {&dr-flddf_doc_st-for-discnt-r-b}
/*сколько еще осталось заплатить на текущий момент округление до 2 знака*/
{&field_} {&prefix}to-pay-r-b  as decimal                                                                 {&no-undo_}
help {&dr-flddf_doc_to-pay-r-b}
{&field_} {&prefix}to-pay-rubl as decimal                                                                 {&no-undo_}
{&field_} {&prefix}to-pay-base as decimal                                                                 {&no-undo_}
{&field_} {&prefix}has-pay-r-b  as decimal                                                                 {&no-undo_}
{&field_} {&prefix}has-pay-rubl as decimal                                                                 {&no-undo_}
{&field_} {&prefix}has-pay-base as decimal                                                                 {&no-undo_}
{&field_} {&prefix}doc-qnty as decimal                                                                    {&no-undo_}
/*бруттог округленное до 2 знака*/
{&field_} {&prefix}src-tot-doc as decimal                                                                 {&no-undo_}
{&field_} {&prefix}src-tot-rubl as decimal                                                                 {&no-undo_}
{&field_} {&prefix}src-tot-base as decimal                                                                 {&no-undo_}
/*счетчик строк скидок*/                                                                                  {&no-undo_}
{&field_} {&prefix}discnt-id as integer                                                                   {&no-undo_}
/*дельта округления по всем товарным строкам - учитываются все округления  и цены и скидки*/
{&field_} {&prefix}gds-r as decimal                                                                       {&no-undo_}
/*дельта округления по товарным строкам и итогу */
{&field_} {&prefix}tot-r as decimal                                                                       {&no-undo_}
/*дельта округления по платежам */
{&field_} {&prefix}pay-r as decimal                                                                       {&no-undo_}
/*все дельты округления*/
{&field_} {&prefix}r-sums as decimal                                                                      {&no-undo_}
/*составляющие суммы скидок по компонентам*/
{&field_} {&prefix}gds-discnt as decimal                                                                  {&no-undo_}
{&field_} {&prefix}tot-discnt as decimal                                                                  {&no-undo_}
{&field_} {&prefix}pay-discnt as decimal                                                                  {&no-undo_}
{&field_} {&prefix}pay-discnt-rubl as decimal                                                             {&no-undo_}
{&field_} {&prefix}pay-discnt-base as decimal                                                             {&no-undo_}
/*gds-discnt + tot-discnt + pay-discnt*/
{&field_} {&prefix}discnt as decimal                                                                      {&no-undo_}
{&field_} {&prefix}sale-in-out as logical                                                                 {&no-undo_}
{&field_} {&prefix}is-petrol-check as logical                                                             {&no-undo_}
{&field_} {&prefix}recalc-gline-num as integer                                                            {&no-undo_}
help {&dr-flddf_doc_recalc-gline-num}
{&field_} {&prefix}recalc-pline-num as integer                                                            {&no-undo_}
help {&dr-flddf_doc_recalc-pline-num}
{&field_} {&prefix}manual-tot-discnt as decimal                                                           {&no-undo_}
{&field_} {&prefix}manual-tot-dis-type as integer                                                         {&no-undo_}
{&field_} {&prefix}manual-discnt-id as integer                                                            {&no-undo_}
{&field_} {&prefix}manual-discnt-ln as integer                                                            {&no-undo_}
{&field_} {&prefix}manual-discnt-sum as decimal                                                           {&no-undo_}
{&field_} {&prefix}getcheck as integer                                                                    {&no-undo_}
{&field_} {&prefix}with-atr1-sum as decimal                                                               {&no-undo_}
{&field_} {&prefix}change-sum as decimal                                                                  {&no-undo_}
{&field_} {&prefix}is-undo as logical                                                                     {&no-undo_}
{&field_} {&prefix}print-copy-num as integer                                                              {&no-undo_}
&endif

&if "{1}" = "temp-table" &then
index pi is unique primary
doc-code
.
&endif

&if  "{1}" = "vars=temp-table" &then

&scop left-prefix {2}
&scop right-prefix {3}
assign
{&left-prefix}doc-code                            = {&right-prefix}doc-code
{&left-prefix}direction                           = {&right-prefix}direction
{&left-prefix}rowid_                              = {&right-prefix}rowid_
{&left-prefix}chk-type                            = {&right-prefix}chk-type
{&left-prefix}prev-chk-type                       = {&right-prefix}prev-chk-type
{&left-prefix}lng                                 = {&right-prefix}lng
{&left-prefix}lnp                                 = {&right-prefix}lnp
{&left-prefix}lnd                                 = {&right-prefix}lnd
{&left-prefix}lnc                                 = {&right-prefix}lnc
{&left-prefix}lnpp                                = {&right-prefix}lnpp
{&left-prefix}chk-date                            = {&right-prefix}chk-date
{&left-prefix}chk-time                            = {&right-prefix}chk-time
{&left-prefix}current-date                        = {&right-prefix}current-date
{&left-prefix}current-time                        = {&right-prefix}current-time
{&left-prefix}bank-rate                           = {&right-prefix}bank-rate
{&left-prefix}bank-scale                          = {&right-prefix}bank-scale
{&left-prefix}base-rate                           = {&right-prefix}base-rate
{&left-prefix}cash-rate                           = {&right-prefix}cash-rate
{&left-prefix}cash-scale                          = {&right-prefix}cash-scale
{&left-prefix}a-chk-date                          = {&right-prefix}a-chk-date
{&left-prefix}a-chk-time                          = {&right-prefix}a-chk-time
{&left-prefix}a-bank-rate                         = {&right-prefix}a-bank-rate
{&left-prefix}a-bank-scale                        = {&right-prefix}a-bank-scale
{&left-prefix}a-base-rate                         = {&right-prefix}a-base-rate
{&left-prefix}a-cash-rate                         = {&right-prefix}a-cash-rate
{&left-prefix}a-cash-scale                        = {&right-prefix}a-cash-scale
{&left-prefix}src-cli-type                        = {&right-prefix}src-cli-type
{&left-prefix}src-cli-code                        = {&right-prefix}src-cli-code
{&left-prefix}src-d-mask                          = {&right-prefix}src-d-mask
{&left-prefix}src-d-card                          = {&right-prefix}src-d-card
{&left-prefix}d-card                              = {&right-prefix}d-card
{&left-prefix}d-pcnt                              = {&right-prefix}d-pcnt
{&left-prefix}cash-d-pcnt                         = {&right-prefix}cash-d-pcnt
{&left-prefix}category                            = {&right-prefix}category
{&left-prefix}sales-man                           = {&right-prefix}sales-man
{&left-prefix}salesman-psn-code                   = {&right-prefix}salesman-psn-code
{&left-prefix}step                                = {&right-prefix}step
{&left-prefix}gds-netto                           = {&right-prefix}gds-netto
{&left-prefix}sub-netto                           = {&right-prefix}sub-netto
{&left-prefix}netto                               = {&right-prefix}netto
{&left-prefix}all-pay-rubl                        = {&right-prefix}all-pay-rubl
{&left-prefix}all-pay-base                        = {&right-prefix}all-pay-base
{&left-prefix}st-r-b                              = {&right-prefix}st-r-b
{&left-prefix}st-rubl                             = {&right-prefix}st-rubl
{&left-prefix}st-base                             = {&right-prefix}st-base
{&left-prefix}st-for-discnt-r-b                   = {&right-prefix}st-for-discnt-r-b
{&left-prefix}to-pay-r-b                          = {&right-prefix}to-pay-r-b
{&left-prefix}to-pay-rubl                         = {&right-prefix}to-pay-rubl
{&left-prefix}to-pay-base                         = {&right-prefix}to-pay-base
{&left-prefix}has-pay-r-b                         = {&right-prefix}has-pay-r-b
{&left-prefix}has-pay-rubl                        = {&right-prefix}has-pay-rubl
{&left-prefix}has-pay-base                        = {&right-prefix}has-pay-base
{&left-prefix}src-qnty                            = {&right-prefix}src-qnty
{&left-prefix}doc-qnty                            = {&right-prefix}doc-qnty
{&left-prefix}src-tot-doc                         = {&right-prefix}src-tot-doc
{&left-prefix}src-tot-rubl                        = {&right-prefix}src-tot-rubl
{&left-prefix}src-tot-base                        = {&right-prefix}src-tot-base
{&left-prefix}discnt-id                           = {&right-prefix}discnt-id
{&left-prefix}gds-r                               = {&right-prefix}gds-r
{&left-prefix}tot-r                               = {&right-prefix}tot-r
{&left-prefix}pay-r                               = {&right-prefix}pay-r
{&left-prefix}r-sums                              = {&right-prefix}r-sums
{&left-prefix}gds-discnt                          = {&right-prefix}gds-discnt
{&left-prefix}tot-discnt                          = {&right-prefix}tot-discnt
{&left-prefix}pay-discnt                          = {&right-prefix}pay-discnt
{&left-prefix}pay-discnt-rubl                     = {&right-prefix}pay-discnt-rubl
{&left-prefix}pay-discnt-base                     = {&right-prefix}pay-discnt-base
{&left-prefix}discnt                              = {&right-prefix}discnt
{&left-prefix}sale-in-out                         = {&right-prefix}sale-in-out
{&left-prefix}is-petrol-check                     = {&right-prefix}is-petrol-check
{&left-prefix}recalc-from-line-num                = {&right-prefix}recalc-from-line-num
{&left-prefix}manual-tot-discnt                   = {&right-prefix}manual-tot-discnt
{&left-prefix}manual-tot-dis-type                 = {&right-prefix}manual-tot-dis-type
{&left-prefix}manual-discnt-id                    = {&right-prefix}manual-discnt-id
{&left-prefix}manual-discnt-ln                    = {&right-prefix}manual-discnt-ln
{&left-prefix}manual-discnt-sum                   = {&right-prefix}manual-discnt-sum
{&left-prefix}getcheck                            = {&right-prefix}getcheck
{&left-prefix}with-atr1-sum                       = {&right-prefix}with-atr1-sum
{&left-prefix}change-sum                          = {&right-prefix}change-sum
{&left-prefix}is-undo                             = {&right-prefix}is-undo
.

&endif


/* $Workfile$ e n d */