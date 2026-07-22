/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06
*/
&if "{1}" = "new shared" or "{1}" = "shared" &then
  &if "{2}" = "" &then
  define {1} temp-table  tt-tax no-undo
  &else
  define {1} temp-table  {2} no-undo
  &endif
&else
  &if "{2}" = "" &then
  define temp-table  tt-tax no-undo
  &else
  define temp-table  {2} no-undo
  &endif
&endif
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
&IF "{3}" = "FULL" &THEN
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
&else
index tax-code is unique primary tax-code.
&endif
&IF "{1}" = "OUTPUT" &THEN
  &if "{2}" = "" &then
  DEFINE OUTPUT PARAMETER TABLE FOR tt-tax.
  &else
  DEFINE OUTPUT PARAMETER TABLE FOR {2}.
  &endif
&ENDIF
&IF "{1}" = "INPUT" &THEN
  &if "{2}" = "" &then
  DEFINE INPUT PARAMETER TABLE FOR tt-tax.
  &else
  DEFINE INPUT PARAMETER TABLE FOR {2}.
  &endif
&ENDIF