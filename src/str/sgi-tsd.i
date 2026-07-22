/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обход веток товаров при выгрузке в файл ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/30/03
Author: Bakhtadze Natalya
Creation date: 07/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*здесь то что для товара надо определить один раз*/

if  v-is-artic
and index({1}.artic , chr(int(v-delim))) > 0 then do:
  assign
  v-artic-delim = 1
  .
end.
{ gbl/gdsbcode.i {1}.gds-code ? main-b-code no-error }
find first buf_prod no-lock where
          buf_prod.obj-type = {1}.prod-type
      AND buf_prod.obj-code = {1}.prod-code
      no-error .
if avail buf_prod then do:
  assign
  for-prod-name = buf_prod.obj-name
  .
end.
else do:
  assign
  for-prod-name = buf_prod.obj-type + string(buf_prod.obj-code)
  .
end.
/*
for-price = ?.
run tax-val in this-procedure
  ({1}.artic,
        {1}.prod-type,
        {1}.prod-code,
        {1}.unit-base,
        {2},
        ub.units.type,
        ?, /*parrec-id */
        g#news , /*paris-log*/
        rdtaxcd ,
        vattaxcd,
        exctaxcd,
        no,
        ub.shop.host-code, /* код фирмы*/
        {&shop}, /*parobj-type   тип объекта*/
        i-obj-code,
        ?, /*parroad-tax   дорожный налог*/
        ?, /*parexcise     акциз*/
        output prichina,
        input-output for-price
        ) no-error  .
if error-status:error then do:
  error-status:error = no.
  message "Ошибка при определении налогов на товар "
          {1}.artic {1}.prod-type {1}.prod-code
          prichina
  view-as alert-box ERROR.
  return.
end.
if return-value = "error" then do:
  message prichina view-as alert-box ERROR.
  return error.
end.
*/
if LOOKUP({&petrolium}, ub.units.type) > 0 and
    LOOKUP({&divisional}, ub.units.type) > 0 AND
    {1}.gds-type = {&gds-goods}
then do:
      petrol-trk = yes.
end.
else petrol-trk = no.

/*конец блока определения того что для твоара надо узнать один раз на все бар-коды*/

/* $Workfile$ e n d */