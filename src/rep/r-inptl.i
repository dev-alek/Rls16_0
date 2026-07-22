/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Журнал поступивших нефтепродуктов за период, общая часть

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

*/

&if "{&type-prn}" = "weight":U &then
&scop prefix cli-
&scop sufix -cli
&else
&scop prefix
&scop sufix
&endif

assign
  v-tot-doc-qnty   = 0.0
  v-tot-fact-qnty  = 0.0
  v-tot-measure    = 0.0
  v-tot-difference = 0.0
.
for each ub.trn-doc
  where ub.trn-doc.obj-type = obj-list.obj-type
    and ub.trn-doc.obj-code = obj-list.obj-code
    and ub.trn-doc.status_  = {&fact}
    and ub.trn-doc.doc-type = {&income}
    and ub.trn-doc.internal = no
  , each ub.doc-line no-lock
  where ub.doc-line.doc-code   = ub.trn-doc.doc-code
    and ub.doc-line.artic      = gds-list.artic
    and ub.doc-line.prod-type  = gds-list.prod-type
    and ub.doc-line.prod-code  = gds-list.prod-code
on error undo, return error return-value
:

  do : /* фильтр по датам */
  if ( x-radio-task = 1 /* Запрос по календарным датам */
       and ub.trn-doc.fact-date >= x-date-start
       and ub.trn-doc.fact-date <= x-date-end
      )
      or
      ( x-radio-task = 2 /* Запрос по сменным датам */
        and ub.trn-doc.shift-date >= x-date-start
        and ub.trn-doc.shift-date <= x-date-end
      )
      or
      ( x-radio-task = 3 /* Запрос по сменным датам c указанием смен */
        and ( ub.trn-doc.shift-date >  x-date-start
              or ( ub.trn-doc.shift-date = x-date-start
                   and  ub.trn-doc.shift-num >= x-shift-start
                  )
            )
        and ( ub.trn-doc.shift-date <  x-date-end
              or ( ub.trn-doc.shift-date = x-date-end
                   and  ub.trn-doc.shift-num <= x-shift-end
                 )
            )
      )
      or
      ( x-radio-task = 4 /* Запрос по конкретной смене в диапазоне сменных суток */
        and ub.trn-doc.shift-date >= x-date-start
        and ub.trn-doc.shift-num   = x-shift-start
        and ub.trn-doc.shift-date <= x-date-end
        and ub.trn-doc.shift-num   = x-shift-end
      )
  then do:
    /* подходит, будем просчитывать */
  end.
  else do:
    next .
  end.
  end . /* end_of фильтр по датам */
  
  find first ub.clients-attr no-lock
    where ub.clients-attr.obj-type   = ub.trn-doc.cli-type
      and ub.clients-attr.obj-code   = ub.trn-doc.cli-code
      and ub.clients-attr.attr-code  = {&attr-shftrep2}
      and ub.clients-attr.attr-value = "yes":U
    no-error .
  if available ub.clients-attr then do:
    next . /* пропускаем тех.пролив */
  end.

  /* Атрибуты линии */
  find first car-num-attr no-lock
    where car-num-attr.doc-code  = ub.doc-line.doc-code
      and car-num-attr.attr-code = {&trdcattr-car-num}             
    no-error .
  find first car-vol-attr no-lock
    where car-vol-attr.doc-code  = ub.doc-line.doc-code
      and car-vol-attr.gds-code  = gds-list.gds-code
      and car-vol-attr.attr-code = "car-vol":U
    no-error .
  find first tests-attr no-lock
    where tests-attr.doc-code    = ub.doc-line.doc-code
      and tests-attr.gds-code    = gds-list.gds-code
      and tests-attr.attr-code   = "tests":U
    no-error .
    
  /* температура по секциям:
     ttn-temp = -1 для n = 1,
     ttn-temp = -1 {&delim-par} 1...n для n > 1
  */
  find first doc-line-attr no-lock
       where doc-line-attr.doc-code  = ub.doc-line.doc-code 
         and doc-line-attr.gds-code  = gds-list.gds-code
         and doc-line-attr.attr-code = "n":U no-error .
  if available doc-line-attr then
    v-num-sections = integer (doc-line-attr.attr-value) no-error .
  else v-num-sections = 1 .
  
  v-temperature = ? .
  for each doc-line-attr no-lock
     where doc-line-attr.doc-code  = ub.doc-line.doc-code
       and doc-line-attr.gds-code  = gds-list.gds-code :
    if entry(1, doc-line-attr.attr-code, {&delim-par}) = "ttn-temp":U then do :
      if num-entries (doc-line-attr.attr-code, {&delim-par}) > 1 then do :
        v-n-section = integer (  entry(2, doc-line-attr.attr-code, {&delim-par})  ) no-error .
        if v-n-section = 1 then do :
          v-temperature = decimal (doc-line-attr.attr-value) no-error .
          leave .
        end .
      end .
      else do :
        v-temperature = decimal (doc-line-attr.attr-value) no-error .
        leave .
      end .
    end .
  end .
      

  /* Сверки */
  find first bef-rvs-doc no-lock
    where bef-rvs-doc.out-code   = ub.trn-doc.doc-code
      and bef-rvs-doc.rvs-type   = {&rvs-before-doc}
    no-error .
  find first aft-rvs-doc no-lock
    where aft-rvs-doc.out-code   = ub.trn-doc.doc-code
      and aft-rvs-doc.rvs-type   = {&rvs-after-doc}
    no-error .

  for each ub.doc-pl no-lock
    where ub.doc-pl.out-code = ub.doc-line.doc-code
      and ub.doc-pl.gds-code = gds-list.gds-code
  on error undo, return error return-value
  :
    if available bef-rvs-doc then do:
      find first bef-rvs-line no-lock
        where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code
          and bef-rvs-line.obj-type = bef-rvs-doc.obj-type
          and bef-rvs-line.obj-code = bef-rvs-doc.obj-code
          and bef-rvs-line.pl-code  = ub.doc-pl.pl-code
          and bef-rvs-line.gds-code = gds-list.gds-code
        no-error .
    end. /* available bef-rvs-doc */
    if available aft-rvs-doc then do:
      find first aft-rvs-line no-lock
        where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code
          and aft-rvs-line.obj-type = aft-rvs-doc.obj-type
          and aft-rvs-line.obj-code = aft-rvs-doc.obj-code
          and aft-rvs-line.pl-code  = ub.doc-pl.pl-code
          and aft-rvs-line.gds-code = gds-list.gds-code
        no-error .
    end. /* available aft-rvs-doc */

    assign
      v-ind = v-ind + 1 /* считаем количество обработанных строк */
    .
    run waitfram-show in this-procedure
      ( input "Печать журнала поступивших нефтепродуктов за период. Обработано строк: "
            + trim( string( v-ind, "->,>>>,>>>,>>9":U ) ) + "..."
      ) .

    assign
      varshift-id   = ( if x-radio-task <= 2 then string( ub.trn-doc.fact-date  )
                                              else string( ub.trn-doc.shift-name ) ) + ":" +
                                                  string( ub.trn-doc.shift-date )
      v-doc-qnty    = ub.doc-pl.{&prefix}doc-qnty
      v-fact-qnty   = ub.doc-pl.{&prefix}fact-qnty
      varinaccuracy = ub.doc-pl.{&prefix}doc-qnty * v-pogresh
      varmeasure    = ( if available bef-rvs-line and
                          available aft-rvs-line
                        then ( aft-rvs-line.measure-{&prefix}qnty - bef-rvs-line.measure-{&prefix}qnty )
                        else ? )
      vardifference = varmeasure - ub.doc-pl.{&prefix}doc-qnty
      v-tot-doc-qnty   = v-tot-doc-qnty   + v-doc-qnty
      v-tot-fact-qnty  = v-tot-fact-qnty  + v-fact-qnty
      v-tot-measure    = v-tot-measure    + varmeasure
      v-tot-difference = v-tot-difference + vardifference
    .

    { gbl/usrnick.i
      ub.trn-doc.creid
      v-oper-name
    }

    display stream PrnLibStream
      sym1  varshift-id
      sym2  v-oper-name
      sym3  ub.trn-doc.doc-code
      sym4  ( if available car-num-attr then          car-num-attr.attr-value   else ? ) @ car-num-attr.attr-value
      sym5  ( if available car-vol-attr then decimal( car-vol-attr.attr-value ) else ? ) @ varvol-attr
      sym6  v-doc-qnty
      sym7  ub.doc-pl.pl-code
      sym8  ( if available bef-rvs-line then bef-rvs-line.state-level-petrol    else ? ) @ bef-rvs-line.state-level-petrol
      sym9  ( if available aft-rvs-line then aft-rvs-line.state-level-petrol    else ? ) @ aft-rvs-line.state-level-petrol
      sym10 v-fact-qnty
      sym11 varmeasure
      sym12 varinaccuracy
      sym13 vardifference
      sym14 ( if available tests-attr   then tests-attr.attr-value              else ? ) @ tests-attr.attr-value
      sym15 ub.doc-line.fact-density
/*      sym16 ub.doc-line.temperature 20/V-2019 заменено на температуру из первой секции */
      sym16 v-temperature @ ub.doc-line.temperature
      sym17
      sym18
    with frame doc-line-frm{&sufix} .
    down stream PrnLibStream 1 with frame doc-line-frm{&sufix} .
  end. /* for each ub.doc-pl */
end. /* for each ub.trn-doc */

if v-ind > 0 then do:
  put stream PrnLibStream unformatted v-line skip .
end.

display stream PrnLibStream
  "ИТОГО"          @ varshift-id
  "ЗА"             @ v-oper-name
  "ПЕРИОД"         @ ub.trn-doc.doc-code
  v-tot-doc-qnty   @ v-doc-qnty
  v-tot-fact-qnty  @ v-fact-qnty
  v-tot-measure    @ varmeasure
  v-tot-difference @ vardifference
  with frame doc-line-frm{&sufix} .
down stream PrnLibStream 1 with frame doc-line-frm{&sufix} .


/* $Workfile$   E n d */