/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/09
Author: Bakhtadze Natalya
Creation date: 01/29/09

*/

&if "{1}" = "tt" &then
define temp-table receipt no-undo
field exch_file_name as character
field exch_file_date as character
field file_proc_date as character
field error as character
field prot_file_name as character
index pi is unique primary
exch_file_name
.

define temp-table ne-receipt no-undo
field exch_file_name as character
field exch_file_date as character
field file_proc_date as character
index pi is unique primary
exch_file_name
.
&endif

&if "{1}" = "proc" &then
FUNCTION ora-rcpt_get-rcpt-name returns character ( input p-file-name as character):
/*p-file-name предполагается без пути*/
define variable v-file-name as character no-undo .
assign
v-file-name = substitute("&1-&2_&3"
                          ,entry(2, entry(1, p-file-name, "_"), "-")
                          ,entry(1, entry(1, p-file-name, "_"), "-")
                          ,entry(2, p-file-name, "_")) no-error.
if error-status:error then v-file-name = p-file-name.
return v-file-name.
END FUNCTION.
&endif

/* $Workfile$ e n d */