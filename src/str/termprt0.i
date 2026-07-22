/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


заполнений временной таблицы по одному товару {1} - gds-list или goods

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/04/05
Author: Bakhtadze Natalya
Creation date: 11/04/05


по одному признаку {2} bar-code
одному parts.in-code - {3} и  одному parts.part-code {4}
{5) shop или temp-shop
{6} {&shop} или i-obj-type
{7} shop.obj-code или i-obj-code

*/

/*кол-во параметров - 7  и поле cash-gds.b-str заполняться не будет*/
/*нужно ли посылать на кассу коды основных единиц измерения*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = {2}.unit-cli No-ERROR.
if ({5}.cd-bc-base or {5}.cd-loc-base) and (NOT petrol-trk
&if "{&bbc}" <> '':U &then
or v-notcd
&endif
)
then do:
  /*в таблицу cash-gds пишем только короткий код - при выводе на кассу будем размножать*/
      run asc-gds in this-procedure (
&if "{&bbc}" <> '':U &then
      input rs-list-method,
      input rs-status,
      input line-mode,
&endif
      buffer {1},
      buffer {2},
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input {6},
      input {7}
      )  no-error .
     if error-status:error then return error.
end.


/*вообще хоть какие-нибудь ДОПБК надо посылать*/
if {5}.cd-pb-base or {5}.cd-pb-alt or {5}.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = {2}.b-code 
              :
      if  ub.prod-bc.b-str = string( {2}.b-code )
          AND
          (
          ({1}.unit-base = {2}.unit-cli AND {5}.cd-loc-base) OR
          (NOT {1}.unit-base = {2}.unit-cli AND {5}.cd-loc-alt)
          ) AND
          (NOT petrol-trk
&if "{&bbc}" <> '':U &then
          or v-notcd
&endif
          )
          then NEXT.
    /*нужно ли посылать на кассу весовые коды и топливные*/
    if {5}.cd-sc-base AND
    (LOOKUP({&weight}, ub.units.type) > 0
    or
    LOOKUP({&petrolium}, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = {&loc-pg-code}
    )
    and
    {2}.unit-cli = {1}.unit-base then do:
      /*проверим - это и вправду весовой???*/
      if not ub.prod-bc.bc-on-type = {&loc-pg-code} then do:
        { gbl/prodbcat.i ub.prod-bc
        "(if LOOKUP({&weight}, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )"
        g#log no-error }
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
&if "{&bbc}" <> '':U &then
        input rs-list-method,
        input rs-status,
        input line-mode,
&endif
        buffer {1},
        buffer {2},
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input {6},
        input {7}
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    /*нужно ли посылать на кассу ДОПБК с основными единицами измерения*/
    /*нужно ли посылать на кассу ДОПБК с дополн единицами измерения*/
    if (({5}.cd-pb-base AND {2}.unit-cli = {1}.unit-base
    AND LOOKUP({&weight}, units.type) = 0
    and ub.prod-bc.bc-on-type <> {&loc-pg-code}
    ) OR
        ({5}.cd-pb-alt AND {2}.unit-cli <> {1}.unit-base)) then do:
      run asc-gds in this-procedure (
&if "{&bbc}" <> '':U &then
        input rs-list-method,
        input rs-status,
        input line-mode,
&endif
        buffer {1},
        buffer {2},
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input {6},
        input {7}
        ) no-error.
     if error-status:error then return error.
        /*вот в этом-то месте и пошлется ДОПБК  на бензину!*/
    end.
  END. /*FOR EACH ub.prod-bc*/
end.           /*if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base*/

if NOT petrol-trk
&if "{&bbc}" <> '':U &then
or v-notcd
&endif
then do:

/*обработк неосновных ед изм для данного признака {2}*/
  FOR EACH b-bc WHERE
            b-bc.gds-code = {1}.gds-code AND
            b-bc.node-code = {2}.node-code AND
            b-bc.part-code = {4} AND
            b-bc.in-code = {3} NO-LOCK :
    if  b-bc.unit-cli <> {1}.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    /*нужно ли посылать на кассу бар-коды дополн единиц измерения*/
    if {5}.cd-bc-alt or {5}.cd-loc-alt then do:
          run asc-gds in this-procedure (
&if "{&bbc}" <> '':U &then
            input rs-list-method,
            input rs-status,
            input line-mode,
&endif
            buffer {1},
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input {6},
            input {7}
            ) no-error.
     if error-status:error then return error.
     end. /*  if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt*/

     /*нужно ли посылать ДОП БК НА неосновные*/
     if {5}.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        /*если у bar-code такой же b-code и есть настройка на его пересылку то пропускаем*/
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND {5}.cd-loc-alt then NEXT.
        /*нужно ли посылать на кассу ДОПБК с дополн единицами измерения*/

        run asc-gds in this-procedure (
&if "{&bbc}" <> '':U &then
          input rs-list-method,
          input rs-status,
          input line-mode,
&endif
          buffer {1},
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input {6},
          input {7}
          ) no-error.
        if error-status:error then return error.
      END. /*FOR EACH ub.prod-bc*/
    end.           /*if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base*/
    end.
  END.

end. /*if not petrol-trk*/



 /* $Workfile$ e n d */