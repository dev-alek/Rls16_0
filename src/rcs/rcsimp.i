/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека импорта RCS

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define rcsimp-import-directory  'rcs-import-directory':u
&global-define rcsimp-export-directory  'rcs-export-directory':u
&global-define rcsimp-logfilename       'rcsimp.log'
&global-define export-oper-head-filename 'h'
&global-define export-oper-body-filename 'b'
&global-define export-day-filename 's'
&global-define export-bcod-filename 'x'
&global-define back-slash-char chr(92)


&global-define TabSpaces 4
&global-define LogLineSize 80

define stream dirstream.
define stream istream.
define stream ostream.

define variable v-first     as logical   init no        no-undo.

define temp-table temp_file no-undo
    field name as character
    field fullname as character
    field type as character
    index pi is primary unique name type
.
define temp-table temp_dir no-undo like temp_file.

define variable v-selected-object-start     as logical        no-undo.
define variable v-mail-parameters-start     as logical        no-undo.
define variable v-import-record-count       as integer        no-undo.
define variable v-mail-ReportType           as character      no-undo.
define variable v-mail-IDChannel            as character      no-undo.
define variable v-mail-ReportNumber         as character      no-undo.
define variable v-default-gds-grp-node-code as integer        no-undo.
define variable v-default-cli-grp-node-code as integer        no-undo.
define variable v-default-wrkr              as integer        no-undo.
define variable v-default-agnt              as integer        no-undo.
define variable v-default-boss              as integer        no-undo.
define variable v-unit-pieces               as character      no-undo.
define variable v-unit-divisional           as character      no-undo.
define variable v-unit-weight               as character      no-undo.

define variable v-selected-object-name      as character      no-undo.

define variable v-goods-parameter-dif-nam1  as logical  init yes no-undo.
define variable v-goods-parameter-dif-nam2  as logical  init no  no-undo.
define variable v-param-type                as character         no-undo.
define variable v-value-character           as character         no-undo.
define variable v-value-date                as date              no-undo.
define variable v-value-decimal             as decimal           no-undo.
define variable v-value-integer             as INTEGER           no-undo.
define variable v-value-logical             AS LOGICAL           no-undo.
define variable v-tth                       as handle            no-undo.


define temp-table temp_rcs-retail1bill          no-undo like rcs-retail1bill        .
define temp-table temp_rcs-retail1billitem      no-undo like rcs-retail1billitem    .
define temp-table temp_rcs-retail1subject       no-undo like rcs-retail1subject     .
define temp-table temp_rcs-retail1bank          no-undo like rcs-retail1bank        .
define temp-table temp_rcs-retail1attr          no-undo like rcs-retail1attr        .
define temp-table temp_rcs-retail1product       no-undo like rcs-retail1product     .
define temp-table temp_rcs-retail1price         no-undo like rcs-retail1price       .
define temp-table temp_rcs-retail1priceitem     no-undo like rcs-retail1priceitem   .
define temp-table temp_rcs-retail1barcode       no-undo like rcs-retail1barcode     .
define temp-table temp_rcs-retail1convolution   no-undo like rcs-retail1convolution .
define temp-table temp_rcs-retail1delete        no-undo like rcs-retail1delete      .


/* $Workfile$ e n d */