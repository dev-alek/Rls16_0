/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица описывающая report-header

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/13/09
Author: Bakhtadze Natalya
Creation date: 07/13/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(tmpcxmlr_i) = 0 &then

&glob tmpcxmlr_i

&if "{1}" = "tables-def" or "{1}" = "tables-def,dataset-def" &then

define {3} temp-table report-header{2} no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.

define {3} temp-table report-parameters{2} no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.

define {3} temp-table report-errors{2} no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.

define {3} temp-table report-destination{2} no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.


&endif

&if "{1}" = "dataset-def"  or "{1}" = "tables-def,dataset-def" &then

define dataset reportheaderType{2} for report-header{2}, report-parameters{2}, report-errors{2}, report-destination{2}
data-relation r1 for report-header{2}, report-parameters{2}
relation-fields (report-id, report-id) nested
data-relation r2 for report-header{2}, report-errors{2}
relation-fields (report-id, report-id) nested
data-relation r3 for report-header{2}, report-destination{2}
relation-fields (report-id, report-id) nested
.

&endif

&endif

/* $Workfile$ e n d */