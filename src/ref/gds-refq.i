/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие запроса в справочнике товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/fltopend.i defproc }
{ gbl/waitfram.i "noprocess"}
{ ref/gds-attr.i }

/*ВНИМАНИЕ !! присутствуют опции  use-index при открытии запроса , т.к. прогресс неправильно
не находит подходящих индексов при использовании BY*/
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character no-undo .

PROCEDURE Set-filter-name :
define input parameter v-filter-name as character no-undo .
  assign
  p-filter-name = v-filter-name
  .
END PROCEDURE.


&if "{2}" = "assortment-matrix" &then
&scop table2    , gam-doc
&scop q-table2    , first gam-doc no-lock where ~
  gam-doc.gds-code = gob-doc.gds-code and ~
  gam-doc.asmg-status = 0 and ~
  gam-doc.obj-type = gob-doc.obj-type and ~
  gam-doc.obj-code = gob-doc.obj-code

&glob flt-open-open-query-tail   , first gam-doc no-lock where ~
  gam-doc.gds-code = gob-doc.gds-code and ~
  gam-doc.asmg-status = 0 and ~
  gam-doc.obj-type = gob-doc.obj-type and ~
  gam-doc.obj-code = gob-doc.obj-code


&scop q-table0    , first gam-doc no-lock

&else
&scop table2
&scop q-table2
&scop q-table0

&glob flt-open-open-query-tail

&endif



&if "{1}" = "goo-doc" &then
DEFINE SHARED QUERY br-gds FOR goo-doc {&table2} SCROLLING.
&glob flt-open-find-buffer-name goo-doc
&glob flt-open-open-query OPEN QUERY br-gds FOR EACH goo-doc no-lock
&glob flt-open-dyn_open-query  FOR EACH goo-doc no-lock
&glob flt-open-table-name goo-doc


&else
DEFINE SHARED QUERY br-gds FOR gob-doc {&table2} SCROLLING.

&glob flt-open-find-buffer-name gob-doc
&glob flt-open-open-query OPEN QUERY br-gds FOR EACH gob-doc no-lock
&glob flt-open-dyn_open-query FOR EACH gob-doc no-lock
&glob flt-open-table-name gob-doc

&endif

&glob flt-open-query-handle query br-gds:handle

&glob flt-open-query-was-opened  l-query-was-opened

&glob flt-open-indexed-reposition indexed-reposition

&glob flt-open-sort-column-phrase

&glob flt-open-call-point filter-point

&glob flt-open-set-filter-name set-filter-name

&glob flt-open-query p-open-query



&glob flt-open-search-option no-lock

&glob flt-open-find-next p-find-next

&glob flt-open-find-recid v-doc-rec

&glob flt-open-find-condition p-find-condition

&scop flt-open-debug-file

&glob flt-open-waitfram yes

define variable l-open-query as logical   no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable v-list-unit-name as character no-undo.
define variable v-list-gds-code-lgas as character no-undo.
define variable v-attr-type as character no-undo.
define variable v-attr-value as character no-undo.
CASE g-list :
  when "ptrl" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( {&petrolium}, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + {&delim-par}.
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, {&delim-par}) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas" then 
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + {&delim-par}.
      end.
    end.
    
    v-list-unit-name = right-trim(v-list-unit-name,{&delim-par}).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,{&delim-par}).
    
    { gbl/fltopend.i
      &where-cond = " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, {&delim-par}) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, {&delim-par}) > 0"
      &use-ind    = "  "
      &by         = " by goo-doc.artic ~
                      BY GOO-DOC.PROD-TYPE ~
                      BY goo-doc.prod-code " }

      /*
      OPEN QUERY br-gds
      FOR EACH goo-doc NO-LOCK
      {&q-table0} by goo-doc.artic
      BY GOO-DOC.PROD-TYPE
      BY goo-doc.prod-code
      indexed-reposition.
      */

    end.
  end.
  when "lgas" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( {&petrolium}, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + {&delim-par}.
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, {&delim-par}) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas" then 
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + {&delim-par}.
      end.
    end.
    
    v-list-unit-name = right-trim(v-list-unit-name,{&delim-par}).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,{&delim-par}).
    
    { gbl/fltopend.i
      &where-cond = " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, {&delim-par}) > 0 and lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, {&delim-par}) > 0"
      &use-ind    = "  "
      &by         = " by goo-doc.artic ~
                      BY GOO-DOC.PROD-TYPE ~
                      BY goo-doc.prod-code " }

      /*
      OPEN QUERY br-gds
      FOR EACH goo-doc NO-LOCK
      {&q-table0} by goo-doc.artic
      BY GOO-DOC.PROD-TYPE
      BY goo-doc.prod-code
      indexed-reposition.
      */

    end.
  end.
  when "ptrlsug" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( {&petrolium}, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + {&delim-par}.
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, {&delim-par}) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "metan" then 
      do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + {&delim-par}.
      end.
    end.
    
    v-list-unit-name = right-trim(v-list-unit-name,{&delim-par}).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,{&delim-par}).
    
    { gbl/fltopend.i
      &where-cond = " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, {&delim-par}) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, {&delim-par}) > 0"
      &use-ind    = "  "
      &by         = " by goo-doc.artic ~
                      BY GOO-DOC.PROD-TYPE ~
                      BY goo-doc.prod-code " }

      /*
      OPEN QUERY br-gds
      FOR EACH goo-doc NO-LOCK
      {&q-table0} by goo-doc.artic
      BY GOO-DOC.PROD-TYPE
      BY goo-doc.prod-code
      indexed-reposition.
      */

    end.
  end.
  when "only-np" then do:
    if a-n-c <> "context" OR NameContext = "" then do:
      for-title = "ВСЕ товары".
    for each ub.units no-lock where lookup( {&petrolium}, ub.units.type) > 0:
      v-list-unit-name = v-list-unit-name + ub.units.unit-name + {&delim-par}.
    end.
    for each ub.goods no-lock where lookup (ub.goods.unit-base, v-list-unit-name, {&delim-par}) > 0:
      run gds-attr-value in this-procedure
        (  input ub.goods.gds-code
          ,input {&attr-fuel-type}
          ,output v-attr-value
          ,output v-attr-type
         ) .
      if v-attr-value = "lgas"
      or v-attr-value = "metan"
      or v-attr-value = "propan"
      then do:
        v-list-gds-code-lgas = v-list-gds-code-lgas + string (ub.goods.gds-code) + {&delim-par}.
      end.
    end.
    
    v-list-unit-name = right-trim(v-list-unit-name,{&delim-par}).
    v-list-gds-code-lgas = right-trim(v-list-gds-code-lgas,{&delim-par}).
    
    { gbl/fltopend.i
      &where-cond = " goo-doc.stts = 0 and lookup (goo-doc.unit-base, v-list-unit-name, {&delim-par}) > 0 and not lookup (string(goo-doc.gds-code),v-list-gds-code-lgas, {&delim-par}) > 0"
      &use-ind    = "  "
      &by         = " by goo-doc.artic ~
                      BY GOO-DOC.PROD-TYPE ~
                      BY goo-doc.prod-code " }

      /*
      OPEN QUERY br-gds
      FOR EACH goo-doc NO-LOCK
      {&q-table0} by goo-doc.artic
      BY GOO-DOC.PROD-TYPE
      BY goo-doc.prod-code
      indexed-reposition.
      */

    end.
  end.
  when {&all} then do:
    &if "{1}" = "goo-doc" &then
      CASE g-stat :
        when {&current} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "Все текущие товары".
          { gbl/fltopend.i
            &where-cond = " goo-doc.stts = 0 "
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc No-LOCK WHERE
            goo-doc.stts = 0
                      /*222*/
            {&q-table0}
            by goo-doc.artic
            BY GOO-DOC.PROD-TYPE
            BY goo-doc.prod-code
            indexed-reposition.
            */

          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("Вce ТЕКУЩИЕ товары, содержащие в названии &1"
                                   , trim( NameContext, "*" ) ).

          { gbl/fltopend.i
            &where-cond = " goo-doc.stts = 0  and goo-doc.gds-name contains NameContext "
            &dyn_where-cond = " substitute('goo-doc.stts = 0  and goo-doc.gds-name contains &1&2&1', ~{&double-quote~}, NameContext )"
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                      goo-doc.stts = 0 AND
                      goo-doc.gds-name /* matches */ contains NameContext
                      {&q-table0} by goo-doc.artic
                      by goo-doc.prod-type
                      by goo-doc.prod-code
                      indexed-reposition.
           */
&endif
          end.
        end. /* when {&current} */
        when {&all} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "ВСЕ товары".

          { gbl/fltopend.i
            &where-cond = " true "
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK
            {&q-table0} by goo-doc.artic
            BY GOO-DOC.PROD-TYPE
            BY goo-doc.prod-code
            indexed-reposition.
            */

          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("ВСЕ товары, содержащие в названии &1"
                                  , trim( NameContext, "*" ) ).

          { gbl/fltopend.i
            &where-cond = " goo-doc.gds-name contains NameContext "
            &dyn_where-cond = " substitute('goo-doc.gds-name contains &1&2&1', ~{&double-quote~}, NameContext )"
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK  WHERE
                     goo-doc.gds-name /* matches */ contains NameContext
            {&q-table0} by goo-doc.artic
            by goo-doc.prod-type
            by goo-doc.prod-code
            indexed-reposition.
            */

&endif
          end.
        end. /* when {&all} */
        when {&deleted} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = "Все неактивные товары".
          { gbl/fltopend.i
            &where-cond = " goo-doc.stts <> 0 "
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.stts <> 0
            {&q-table0} by goo-doc.artic
            BY GOO-DOC.PROD-TYPE
            BY goo-doc.prod-code
            indexed-reposition.
            */

          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("Все НЕАКТИВНЫЕ товары, содержащие в названии &1"
                                   , trim( NameContext, "*" )) .
          { gbl/fltopend.i
            &where-cond = " goo-doc.stts <> 0 AND goo-doc.gds-name contains NameContext "
            &dyn_where-cond = " substitute(' goo-doc.stts <> 0 AND goo-doc.gds-name contains &1&2&1', ~{&double-quote~}, NameContext )"
            &use-ind    = "  "
            &by         = " by goo-doc.artic ~
                            BY GOO-DOC.PROD-TYPE ~
                            BY goo-doc.prod-code " }
            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                     goo-doc.stts <> 0 AND
                     goo-doc.gds-name /* matches */ contains NameContext
            {&q-table0} by goo-doc.artic
            by goo-doc.prod-type
            by goo-doc.prod-code
            indexed-reposition.
            */

&endif
          end.
        end. /* when {&deleted} */
      END CASE. /* CASE g-stat  */
    &else
      CASE g-cond :
        when {&g___object} then do:
           CASE g-stat :
            when {&current} then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту : &1&2 &3"
                                     , pobj-type
                                     , pobj-code
                                     , cur-obj.obj-name).
              CASE rs-sort :
                when {&Article} then do:
                { gbl/fltopend.i
                  &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 "
                  &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', {&double-quote}, pobj-type, pobj-code)"
                  &use-ind    = "  "
                  &by         = " by gob-doc.artic ~
                                  BY gob-doc.PROD-TYPE ~
                                  BY gob-doc.prod-code " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                            {1}.obj-type = pobj-type AND
                            {1}.obj-code = pobj-code AND
                            {1}.stts = 0
                  {&q-table2} by {1}.artic
                  BY {1}.PROD-TYPE
                  BY {1}.prod-code
                  indexed-reposition.
                  */
                end. /* when {&Article} t  */
                when {&price} then do:
                   RUN obj-price0 in this-procedure .
                end. /* when {&price}  */
              END CASE .
            end. /* when {&current} */
            when {&all} then do:
              for-title = substitute("ВСЕ товары по объекту : &1&2 &3"
                                     , pobj-type
                                     , pobj-code
                                     , cur-obj.obj-name).
              CASE rs-sort :
                when {&Article} then dO:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = "  "
                    &by         = " by gob-doc.artic ~
                                    BY gob-doc.PROD-TYPE ~
                                    BY gob-doc.prod-code " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.obj-type = pobj-type AND
                          {1}.obj-code = pobj-code
                  {&q-table2} by {1}.artic
                  BY {1}.PROD-TYPE
                  BY {1}.prod-code
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN obj-price in this-procedure .
                end.
              END CASE .
            end. /* when {&all}  */
            when {&deleted} then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 &3"
                                      , pobj-type
                                      , pobj-code
                                      , cur-obj.obj-name).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = "  "
                    &by         = " by gob-doc.artic ~
                                    BY gob-doc.PROD-TYPE ~
                                    BY gob-doc.prod-code " }
                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.stts <> 0
                  {&q-table2} by {1}.artic
                  BY {1}.PROD-TYPE
                  BY {1}.prod-code
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN obj-price-0.
                end.
              END CASE .
            end. /* when {&deleted}  */
          END CASE .
        end. /* when {&g___object}   */
        when {&fact} then dO:
          CASE g-stat :
            when {&current} then do:
              for-title = substitute("ТЕКУЩИЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty > 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty > 0 ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " use-index pi "
                    &by         = "  " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.fact-qnty > 0 and
                          {1}.stts = 0
                  use-index pi  {&q-table2}
                  indexed-reposition.
                  */
                 /*здесь и далее где есть indexed -reposition смотри в начало файла */

                end.
                when {&price} then do:
                  RUN fact-price0 in this-procedure .
                end.
                when {&Quantity} then dO:
                  RUN fact-qnty0 in this-procedure .
                end.
              END CASE .
            end. /* when {&current}   */
            when {&all} then do:
              for-title = substitute("ВСЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when {&Article} then dO:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty > 0 ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " use-index pi  "
                    &by         = " " }
                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.fact-qnty > 0
                          use-index pi
                          {&q-table2}
                  indexed-reposition
                  .
                  */
                end.
                when {&price} then dO:
                  RUN fact-price in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN fact-qnty in this-procedure .
                end.
              END CASE .
            end. /* when {&all}  */
            when {&deleted} then do:
              for-title = substitute("НЕАКТИВНЫЕ товары, имеющиеся в наличии по объекту &1&2 (факт остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when {&Article} then dO:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty > 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty > 0 ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " use-index pi  "
                    &by         = " " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.fact-qnty > 0 and
                          {1}.stts <> 0
                           use-index pi
                           {&q-table2}
                           indexed-reposition.
                  */
                end.
                when {&price} then dO:
                  RUN fact-price-0 in this-procedure .
                end.
                when {&Quantity} then dO:
                  RUN fact-qnty-0 in this-procedure .
                end.
              END CASE .
            end. /* when {&deleted}   */
          END CASE .
        end. /* when {&fact}  */
        when {&free} then dO:
          CASE g-stat :
            when {&current} then do:
              for-title =  substitute("ТЕКУЩИЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                       , pobj-type
                                       , pobj-code).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty > 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty > 0 ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " use-index pi  "
                    &by         = " " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.free-qnty > 0 and
                          {1}.stts = 0
                  use-index pi
                   {&q-table2}
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN free-price0 in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN free-qnty0 in this-procedure .
                end.
              END CASE .
            end. /* when {&current}  */
            when {&all} then do:
              for-title =  substitute("ВСЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                     , pobj-type
                                     , pobj-code).
              CASE rs-sort :
                when {&Article} then do:
                   { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " "
                    &by         = " by gob-doc.artic ~
                                    by gob-doc.prod-type ~
                                    by gob-doc.prod-code " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.free-qnty > 0
                  {&q-table2} by {1}.artic
                  BY {1}.PROD-TYPE
                  BY {1}.prod-code
                  indexed-reposition.
                  */
                end.
                when {&price} then dO:
                  RUN free-price in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN free-qnty in this-procedure .
                end.
              END CASE .
            end. /* when {&all}   */
            when {&deleted} then do:
              for-title = substitute("НЕАКТИВНЫЕ свободные товары по объекту &1&2 (свободный остаток > 0)"
                                      , pobj-type
                                      , pobj-code).
            CASE rs-sort :
                when {&Article} then do:
                   { gbl/fltopend.i
                    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 "
                    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty > 0 and gob-doc.stts <> 0  ' , {&double-quote}, pobj-type, pobj-code)"
                    &use-ind    = " "
                    &by         = " by gob-doc.artic ~
                                    by gob-doc.prod-type ~
                                    by gob-doc.prod-code " }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} WHERE
                          {1}.obj-type    = pobj-type and
                          {1}.obj-code   = pobj-code and
                          {1}.free-qnty > 0 and
                          {1}.stts <> 0 NO-LOCK
                  {&q-table2} by {1}.artic
                  BY {1}.PROD-TYPE
                  BY {1}.prod-code
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN free-price-0 in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN free-qnty-0 in this-procedure .
                end.
              END CASE .
            end. /* when {&deleted}  */
          END CASE .
        end. /* when {&free}    */
      END CASE .
    &endif
  end. /*when {&all} g-list*/
  when {&producer} then do:
    &if "{1}" = "goo-doc" &then
      CASE g-stat :
        when {&current} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("ТЕКУЩИЕ товары с производителем : &1"
                                       , g-producer.obj-name).
            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0 "
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0 ' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code and
                    goo-doc.stts = 0
            {&q-table0} by goo-doc.artic
            indexed-reposition
            .
            */
          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("ТЕКУЩИЕ товары с производителем : &1, содержащие в названии &2"
                                        ,g-producer.obj-name
                                        ,trim( NameContext, "*" ) ).

            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts = 0 ~
                            and goo-doc.gds-name contains NameContext"
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts = 0 ~
                            and goo-doc.gds-name contains &1&4&1' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, NameContext)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }
            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code and
                    goo-doc.stts = 0 and
                    goo-doc.gds-name contains NameContext
            {&q-table0} by goo-doc.artic
            indexed-reposition
            .
            */
&endif
          end.
        end.
        when {&all} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("ВСЕ товары с производителем : &1"
                                       , g-producer.obj-name).

            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code "
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 ' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }
            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code
            {&q-table0} by goo-doc.artic
            indexed-reposition.
            */
          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("ВСЕ товары с производителем : &1, содержащие в названии &2"
                                   , g-producer.obj-name
                                   , trim( NameContext, "*" ) ).

            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code  ~
                            and goo-doc.gds-name contains NameContext"
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 ~
                            and goo-doc.gds-name contains &1&4&1' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, NameContext)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }

            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code and
                    goo-doc.gds-name contains NameContext
            {&q-table0} by goo-doc.artic
            indexed-reposition.
            */
&endif
          end.
        end.
        when {&deleted} then do:
          if a-n-c <> "context" OR NameContext = "" then do:
            for-title = substitute("НЕАКТИВНЫЕ товары с производителем : &1"
                                , g-producer.obj-name).

            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0 "
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0 ' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }
            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc No-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code and
                    goo-doc.stts <> 0
            {&q-table0} by goo-doc.artic
            indexed-reposition.
            */
          end.
          else do:
&if "{&db-name_schema}" = "ub" &then
            for-title = substitute("НЕАКТИВНЫЕ товары с производителем : &1, содержащии в названии &2"
                                  , g-producer.obj-name
                                  , trim( NameContext, "*" ) ).
            { gbl/fltopend.i
            &where-cond = " goo-doc.prod-type = g-producer.obj-type and goo-doc.prod-code = g-producer.obj-code and goo-doc.stts <> 0 ~
                            and goo-doc.gds-name contains NameContext"
            &dyn_where-cond = " substitute('goo-doc.prod-type = &1&2&1 and goo-doc.prod-code = &3 and goo-doc.stts <> 0 ~
                            and goo-doc.gds-name contains &1&4&1' ~
                           , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, NameContext)"
            &use-ind    = " "
            &by         = " by goo-doc.artic "
                             }
            /*
            OPEN QUERY br-gds
            FOR EACH goo-doc No-LOCK WHERE
                    goo-doc.prod-type = g-producer.obj-type and
                    goo-doc.prod-code = g-producer.obj-code and
                    goo-doc.stts <> 0 and
                    goo-doc.gds-name contains NameContext
            {&q-table0} by goo-doc.artic
            indexed-reposition.
            */
&endif
          end.
        end.
      END CASE.
    &else
      CASE g-cond :
        when {&g___object} then do:
          CASE g-stat :
            when {&current} then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2 с производителем : &3"
                                          , pobj-type
                                          , pobj-code
                                          , g-producer.obj-name).
              CASE rs-sort :
                when {&Article} then do:

                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.stts = 0
                  {&q-table2} by {1}.artic
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN prod-obj-price0 in this-procedure .
                end.
              END CASE .
            end. /* when {&current}   */
            when {&all} then do:
              for-title = substitute("ВСЕ товары по объекту &1&2 с производителем : &3"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code
                  {&q-table2} by {1}.artic
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN prod-obj-price in this-procedure .
                end.
              END CASE .
            end. /* when {&all}   */
            when {&deleted} then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 с производителем : &3"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} NO-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.stts <> 0
                  {&q-table2} by {1}.artic
                  indexed-reposition.
                  */
                end.
                when {&price} then dO:
                  RUN prod-obj-price-0 in this-procedure .
                end.
              END CASE .
            end. /* when {&deleted}  */
          END CASE .
        end. /* when {&g___object}  */
        when {&fact} then do:
          CASE g-stat :
            when {&current} then do:
              for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " use-index pi"
                  &by         = " "
                                  }

                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.fact-qnty > 0 and
                          {1}.stts = 0
                  use-index pi
                  {&q-table2} indexed-reposition.
                  */
                end.
                when {&price} then dO:
                  RUN prod-fact-price0 in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN prod-fact-qnty0 in this-procedure .
                end.
              END CASE .
            end. /* when {&current}   */
            when {&all} then do:
              for-title = substitute("ВСЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-producer.obj-name ).
              CASE rs-sort :
                when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code  ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3  ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " use-index pi"
                  &by         = " "
                                  }
                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.fact-qnty > 0
                  use-index pi
                  {&q-table2} indexed-reposition.
                  */
                end.
                when {&price} then dO:
                  RUN prod-fact-price in this-procedure .
                end.
                when {&Quantity} then dO:
                  RUN prod-fact-qnty in this-procedure .
                end.
              END CASE .
            end. /* when {&all}   */
            when {&deleted} then do:
              for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 с производителем : &3 (факт остаток > 0)"
                                      , pobj-type
                                      , pobj-code
                                      , g-producer.obj-name).
              CASE rs-sort :
                when {&Article} then dO:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " use-index pi"
                  &by         = " "
                                  }
                  /*
                  OPEN QUERY br-gds
                  FOR EACH {1} No-LOCK WHERE
                          {1}.prod-type = g-producer.obj-type and
                          {1}.prod-code = g-producer.obj-code and
                          {1}.obj-type = pobj-type and
                          {1}.obj-code = pobj-code and
                          {1}.fact-qnty > 0 and
                          {1}.stts <> 0
                  use-index pi
                  {&q-table2} indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN prod-fact-price-0 in this-procedure .
                end.
                when {&Quantity} then dO:
                  RUN prod-fact-qnty-0 in this-procedure .
                end.
            END CASE .
          end. /* when {&deleted} */
        END CASE .
      end. /* when {&fact}   */
      when {&free} then dO:
        CASE g-stat :
          when {&current} then do:
            for-title = substitute("ТЕКУЩИЕ свободные товары по объекту &1&2 с производителем : &3"
                                        , pobj-type
                                        , pobj-code
                                        , g-producer.obj-name).
            CASE rs-sort :
              when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }

                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.prod-type = g-producer.obj-type and
                        {1}.prod-code = g-producer.obj-code and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0 and
                        {1}.stts = 0
                {&q-table2} by {1}.artic
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN prod-free-price0 in this-procedure .
              end.
              when {&Quantity} then dO:
                RUN prod-free-qnty0 in this-procedure .
              end.
            END CASE .
          end.
          when {&all} then do:
            for-title = substitute("ВСЕ свободные товары по объекту &1&2 с производителем : &3"
                                       , pobj-type
                                       , pobj-code
                                       , g-producer.obj-name).
            CASE rs-sort :
              when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3  ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} NO-LOCK WHERE
                        {1}.prod-type = g-producer.obj-type and
                        {1}.prod-code = g-producer.obj-code and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0
                {&q-table2} by {1}.artic
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN prod-free-price in this-procedure .
              end.
              when {&Quantity} then do:
                RUN prod-free-qnty in this-procedure .
              end.
            END CASE .
          end.
          when {&deleted} then do:
            for-title = substitute("НЕАКТИВНЫЕ свободные товары по объекту &1&2 с производителем : "
                                   , pobj-type
                                   , pobj-code
                                   , g-producer.obj-name).
            CASE rs-sort :
              when {&Article} then do:
                  { gbl/fltopend.i
                  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty > 0"
                  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty > 0 ' ~
                                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
                  &use-ind    = " "
                  &by         = " by gob-doc.artic "
                                  }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.prod-type = g-producer.obj-type and
                        {1}.prod-code = g-producer.obj-code and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0 and
                          {1}.stts <> 0
                  {&q-table2} by {1}.artic
                  indexed-reposition.
                  */
                end.
                when {&price} then do:
                  RUN prod-free-price-0 in this-procedure .
                end.
                when {&Quantity} then do:
                  RUN prod-free-qnty-0 in this-procedure .
                end.
              END CASE .
            end. /* when {&deleted}  */
          END CASE .   /* CASE g-stat :  */
        end. /* when {&free}  */
      END .   /* CASE g-cond : */
    &endif
  end. /* when {&producer} g-list*/
  when {&group} then dO:
    &if "{1}" = "goo-doc" &then
    CASE g-stat :
      when {&current} then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("ТЕКУЩИЕ товары группы : &1", g-grp).

          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp and goo-doc.stts = 0 "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 ', ~{&double-quote~}, g-grp)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }
          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK WHERE
                  goo-doc.grp-name begins g-grp and
                  goo-doc.stts = 0
          {&q-table0} by goo-doc.artic
          BY GOO-DOC.PROD-TYPE
          BY goo-doc.prod-code
          indexed-reposition.
          */
        end.
        else do:
&if "{&db-name_schema}" = "ub" &then
          for-title = substitute("ТЕКУЩИЕ товары группы : &1, содержащие в названии &2"
                                , g-grp
                                , trim( NameContext, "*" )).

          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp and goo-doc.stts = 0 and goo-doc.gds-name contains NameContext "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts = 0 and goo-doc.gds-name contains &1&3&1 ', ~{&double-quote~}, g-grp, NameContext)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }

          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK WHERE
                    goo-doc.grp-name begins g-grp and
                    goo-doc.stts = 0 and
                    goo-doc.gds-name  contains  NameContext
                    {&q-table0} by goo-doc.artic
                    by goo-doc.prod-type
                    by goo-doc.prod-code
                    indexed-reposition.
         */
&endif
        end.
      end.
      when {&all} then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("ВСЕ товары группы : &1", g-grp).
          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1 ', ~{&double-quote~}, g-grp)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }

          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK  WHERE
                  goo-doc.grp-name begins g-grp
          {&q-table0} by goo-doc.artic
          BY GOO-DOC.PROD-TYPE
          BY goo-doc.prod-code
          indexed-reposition.
          */
        end.
        else do:
&if "{&db-name_schema}" = "ub" &then
          for-title = substitute("ВСЕ товары группы : &1, содержащие в названии &2"
                                 , g-grp
                                 , trim( NameContext, "*" )).

          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp and goo-doc.gds-name contains NameContext "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.gds-name contains &1&3&1 ', ~{&double-quote~}, g-grp, NameContext)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }

          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK  WHERE
                  goo-doc.grp-name begins g-grp and
                  goo-doc.gds-name  contains  NameContext
          {&q-table0} by goo-doc.artic
          BY GOO-DOC.PROD-TYPE
          BY goo-doc.prod-code
          indexed-reposition.
          */
&endif
        end.
      end.
      when {&deleted} then do:
        if a-n-c <> "context" OR NameContext = "" then do:
          for-title = substitute("НЕАКТИВНЫЕ товары группы : &1", g-grp).

          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp and goo-doc.stts <> 0  "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 ', ~{&double-quote~}, g-grp)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }
          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK WHERE
                  goo-doc.grp-name begins g-grp and
                  goo-doc.stts <> 0
          {&q-table0} by goo-doc.artic
          BY GOO-DOC.PROD-TYPE
          BY goo-doc.prod-code
          indexed-reposition.
          */
        end.
        else do:
&if "{&db-name_schema}" = "ub" &then
          for-title = substitute("НЕАКТИВНЫЕ товары группы : &1, содержащие в названии &2"
                      , g-grp
                      , trim( NameContext, "*" )).

          { gbl/fltopend.i
          &where-cond = " goo-doc.grp-name begins g-grp and goo-doc.stts <> 0 and goo-doc.gds-name contains NameContext "
          &dyn_where-cond = " substitute('goo-doc.grp-name begins &1&2&1  and goo-doc.stts <> 0 and goo-doc.gds-name contains &1&3&1 ', ~{&double-quote~}, g-grp, NameContext)"
          &use-ind    = " "
          &by         = " by goo-doc.artic ~
                          by goo-doc.prod-type ~
                          by goo-doc.prod-code "
                          }
          /*
          OPEN QUERY br-gds
          FOR EACH goo-doc NO-LOCK WHERE
                  goo-doc.grp-name begins g-grp and
                  goo-doc.stts <> 0 and
                  goo-doc.gds-name  contains  NameContext
          {&q-table0} by goo-doc.artic
          BY GOO-DOC.PROD-TYPE
          BY goo-doc.prod-code
          indexed-reposition.
          */
&endif
        end.
      end.
    END CASE.
  &else
    CASE g-cond :
      when {&g___object} then do:
        CASE g-stat :
          when {&current} then do:
            for-title = substitute("ТЕКУЩИЕ товары по объекту : &1&2 , группа : &3"
                                    , pobj-type
                                    , pobj-code
                                    , g-grp).
            CASE rs-sort :
              when {&Article} then dO:

                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts = 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                                by gob-doc.prod-type ~
                                by gob-doc.prod-code "
                                }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} NO-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.stts = 0
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-obj-price0 in this-procedure .
              end.
            END CASE .
          end. /* when {&current}  */
          when {&all} then do:
            for-title = substitute("ВСЕ товары по объекту &1&2 , группа : "
                                     , pobj-type
                                     , pobj-code
                                     , g-grp).
            CASE rs-sort :
              when {&Article} then do:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                                by gob-doc.prod-type ~
                                by gob-doc.prod-code "
                                }

                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-obj-price in this-procedure .
              end.
            END CASE .
          end. /* when {&all}  */
          when {&deleted} then do:
            for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2 , группа : "
                                       , pobj-type
                                       , pobj-code
                                       , g-grp).
            CASE rs-sort :
              when {&Article} then do:

                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 and gob-doc.stts <> 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                                by gob-doc.prod-type ~
                                by gob-doc.prod-code "
                                }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} NO-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.stts <> 0
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-obj-price-0 in this-procedure .
              end.
            END CASE .
          end. /* when {&deleted} */
        END CASE .
      end.  /* when {&g___object}    */
      when {&fact} then dO:
        CASE g-stat :
          when {&current} then do:
            for-title = substitute("ТЕКУЩИЕ товары по объекту &1&2, группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when {&Article} then do:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " use-index pi"
                &by         = " "
                                }

                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.fact-qnty > 0 and
                        {1}.stts = 0
                use-index pi
                {&q-table2} indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-fact-price0 in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-fact-qnty0 in this-procedure .
              end.
            END CASE .
          end. /* when {&current}  */
          when {&all} then do:
            for-title = substitute("ВСЕ товары по объекту &1&2 , группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when {&Article} then do:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.fact-qnty > 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.fact-qnty > 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " use-index pi"
                &by         = " "
                                }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp AND
                        {1}.obj-type = pobj-type AND
                        {1}.obj-code = pobj-code AND
                        {1}.fact-qnty > 0
                use-index pi
                {&q-table2} indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-fact-price in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-fact-qnty in this-procedure .
              end.
            END CASE .
          end. /*when {&all}  */
          when {&deleted} then do:
            for-title = substitute("НЕАКТИВНЫЕ товары по объекту &1&2, группа : &3 (факт остаток > 0)"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when {&Article} then do:

                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " use-index pi"
                &by         = " "
                                }

                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.fact-qnty > 0 and
                        {1}.stts <> 0
                use-index pi
                {&q-table2} indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-fact-price-0 in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-fact-qnty-0 in this-procedure .
              end.
            END CASE .
          end.
        END CASE .
      end. /* when {&fact}   */
      when {&free} then dO:
        CASE g-stat :
          when {&current} then do:
            for-title = substitute("ТЕКУЩИЕ свободные товары на объекте : &1&2, группа : &3"
                                        , pobj-type
                                        , pobj-code
                                        , g-grp).
            CASE rs-sort :
              when {&Article} then dO:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.free-qnty > 0 and gob-doc.stts = 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.free-qnty > 0 and gob-doc.stts = 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                               by gob-doc.prod-type ~
                               by gob-doc.prod-code "
                                }

                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0 and
                        {1}.stts = 0
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-free-price0 in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-free-qnty0 in this-procedure .
              end.
            END CASE .
          end. /*when {&current}   */
          when {&all} then do:
            for-title =  substitute("ВСЕ свободные товары на объекте : &1&2, группа : &3"
                                         , pobj-type
                                         , pobj-code
                                         , g-grp).
            CASE rs-sort :
              when {&Article} then do:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.free-qnty > 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.free-qnty > 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                               by gob-doc.prod-type ~
                               by gob-doc.prod-code "
                                }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-free-price in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-free-qnty in this-procedure .
              end.
            END CASE .
          end. /*when {&all} */
          when {&deleted} then do:
            for-title =  substitute("НЕАКТИВНЫЕ свободные товары на объекте : &1&2, группа : &3"
                                         , pobj-type
                                         , pobj-code
                                         , g-grp).
            CASE rs-sort :
              when {&Article} then do:
                { gbl/fltopend.i
                &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                               and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 "
                &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                                and gob-doc.free-qnty > 0 and gob-doc.stts <> 0 ' ~
                                 , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
                &use-ind    = " "
                &by         = " by gob-doc.artic ~
                               by gob-doc.prod-type ~
                               by gob-doc.prod-code "
                                }
                /*
                OPEN QUERY br-gds
                FOR EACH {1} No-LOCK WHERE
                        {1}.grp-name begins g-grp and
                        {1}.obj-type = pobj-type and
                        {1}.obj-code = pobj-code and
                        {1}.free-qnty > 0 and
                        {1}.stts <> 0
                {&q-table2} by {1}.artic
                BY {1}.PROD-TYPE
                BY {1}.prod-code
                indexed-reposition.
                */
              end.
              when {&price} then do:
                RUN grp-free-price-0 in this-procedure .
              end.
              when {&Quantity} then do:
                RUN grp-free-qnty-0 in this-procedure .
              end.
            END CASE .
          end. /* when {&deleted}  */
        END CASE . /* CASE g-stat :  */
      end. /* when {&free}   */
    END CASE. /* CASE g-cond*/
  &endif
END . /*when {&group}  */
END CASE. /*case g-list*/
&if "{2}" <> "" &then
 for-title = trim(for-title) + " + Ассортиментная матрица"  .
&endif
return.

&if "{1}" = "gob-doc" &then
PROCEDURE obj-price0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0 ', {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    BY gob-doc.artic ~ " }

  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type = pobj-type AND
                               {1}.obj-code = pobj-code AND
                               {1}.stts = 0

    {&q-table2} by {1}.price-sale
    by {1}.artic
    indexed-reposition
    .
    */
END PROCEDURE.

PROCEDURE obj-price.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 ', {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    BY gob-doc.artic ~ " }
  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type = pobj-type AND
                               {1}.obj-code = pobj-code

                               {&q-table2} by {1}.price-sale
                               by {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE obj-price-0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0 ', {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    BY gob-doc.artic ~ " }

  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type = pobj-type AND
                               {1}.obj-code = pobj-code AND
                               {1}.stts <> 0
                               {&q-table2} by {1}.price-sale
                               by {1}.artic
                               indexed-reposition
                               .
   */
END PROCEDURE.

PROCEDURE fact-price0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-indFIRST    = " use-index obj-price "
    &by         = "  " }

  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.fact-qnty <> 0 AND
                               {1}.stts = 0
                               use-index obj-price
                               {&q-table2} indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE fact-qnty0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-indFIRST    = " use-index obj-qnty "
    &by         = "  " }

/*    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.fact-qnty <> 0 AND
                               {1}.stts = 0
                               use-index obj-qnty
                               {&q-table2} indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE fact-price.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic  " }

/*    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.fact-qnty <> 0
                               {&q-table2} by {1}.price-sale
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE fact-qnty.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.fact-qnty ~
                    by gob-doc.artic  " }

 /*   OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.fact-qnty <> 0
                               {&q-table2} by {1}.FACT-QNTY
                               BY {1}.ARTIC
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE fact-price-0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic  " }

  /*  OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.fact-qnty <> 0 AND
                               {1}.stts <> 0
                               {&q-table2} by {1}.price-sale
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE fact-qnty-0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.fact-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.fact-qnty ~
                    by gob-doc.artic  " }

/*    OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type = pobj-type AND
                               {1}.obj-code = pobj-code AND
                               {1}.fact-qnty <> 0 AND
                               {1}.stts <> 0
                               {&q-table2} by {1}.FACT-QNTY
                               BY {1}.ARTIC
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-price0.

  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic  " }

   /*OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.free-qnty <> 0 AND
                               {1}.stts = 0
                               {&q-table2} by {1}.price-sale
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-qnty0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts = 0 and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts = 0  and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic  " }

  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type = pobj-type AND
                               {1}.obj-code = pobj-code AND
                               {1}.free-qnty <> 0 AND
                               {1}.stts = 0
                               {&q-table2} by {1}.free-qnty
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-price.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3  and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic  " }

   /*
    OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.free-qnty <> 0
                               {&q-table2} by {1}.price-sale
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-qnty.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic  " }
  /*
    OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.free-qnty <> 0
                               {&q-table2} by {1}.free-qnty
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-price-0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic  " }

 /*   OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.free-qnty <> 0 AND
                               {1}.stts <> 0
                               {&q-table2} by {1}.price-sale
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE free-qnty-0.
  { gbl/fltopend.i
    &where-cond = " gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code  and gob-doc.stts <> 0 and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.obj-type = &1&2&1 and gob-doc.obj-code = &3 and gob-doc.stts <> 0  and gob-doc.free-qnty <> 0 ' , {&double-quote}, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic  " }

 /*   OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                               {1}.obj-type    = pobj-type AND
                               {1}.obj-code   = pobj-code AND
                               {1}.free-qnty <> 0 AND
                               {1}.stts <> 0
                               {&q-table2} by {1}.free-qnty
                               BY {1}.artic
                               indexed-reposition
                               .*/
END PROCEDURE.

PROCEDURE prod-obj-price0 .

  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                             {1}.prod-type = g-producer.obj-type AND
                             {1}.prod-code = g-producer.obj-code AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code AND
                             {1}.stts = 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-obj-price.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code  ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }

  /*OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                             {1}.prod-type = g-producer.obj-type AND
                             {1}.prod-code = g-producer.obj-code AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-obj-price-0 .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type AND
                             {1}.prod-code = g-producer.obj-code AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code AND
                             {1}.stts <> 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-price0 .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST    = " use-index obj-price"
  &by         = " "
                  }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                             {1}.prod-type = g-producer.obj-type AND
                             {1}.prod-code = g-producer.obj-code AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code AND
                             {1}.fact-qnty <> 0 AND
                             {1}.stts = 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-qnty0 .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST  = " use-index obj-qnty"
  &by         = " "
                  }

 /* OPEN QUERY br-gds FOR EACH {1} no-lock WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and
                             {1}.stts = 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-price .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code  ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3  ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST    = " use-index obj-price"
  &by         = " "
                  }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-qnty .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST = " use-index obj-qnty"
  &by         = " "
                  }

 /* OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-price-0 .
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST    = " use-index obj-price"
  &by         = " "
                  }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and {1}.stts <> 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-fact-qnty-0.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.fact-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.fact-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-indFIRST  = " use-index obj-qnty"
  &by         = " "
                  }

 /* OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                            {1}.prod-type = g-producer.obj-type and
                            {1}.prod-code = g-producer.obj-code and
                            {1}.obj-type = pobj-type and
                            {1}.obj-code = pobj-code and
                            {1}.fact-qnty <> 0 and
                            {1}.stts <> 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-free-price0.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }

  /*OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0 and
                             {1}.stts = 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic .*/
END PROCEDURE.

PROCEDURE prod-free-qnty0.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts = 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.free-qnty ~
                  by gob-doc.artic "
                  }

  /*OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0 and
                             {1}.stts = 0
                             {&q-table2} by {1}.free-qnty
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-free-price.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code  ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3  ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE prod-free-qnty.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code  ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3  ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.free-qnty ~
                  by gob-doc.artic "
                  }

 /* OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                            {1}.prod-type = g-producer.obj-type and
                            {1}.prod-code = g-producer.obj-code and
                            {1}.obj-type = pobj-type and
                            {1}.obj-code = pobj-code and
                            {1}.free-qnty <> 0
                            {&q-table2} by {1}.free-qnty
                            BY {1}.artic
                            indexed-reposition
                            .*/
END PROCEDURE.

PROCEDURE prod-free-price-0.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.price-sale ~
                  by gob-doc.artic "
                  }

 /* OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                            {1}.prod-type = g-producer.obj-type and
                            {1}.prod-code = g-producer.obj-code and
                            {1}.obj-type = pobj-type and
                            {1}.obj-code = pobj-code and
                            {1}.free-qnty <> 0 and
                            {1}.stts <> 0
                            {&q-table2} by {1}.price-sale
                            BY {1}.artic
                            indexed-reposition
                            .*/
END PROCEDURE.

PROCEDURE prod-free-qnty-0.
  { gbl/fltopend.i
  &where-cond = " gob-doc.prod-type = g-producer.obj-type and gob-doc.prod-code = g-producer.obj-code and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code and gob-doc.free-qnty <> 0"
  &dyn_where-cond = " substitute('gob-doc.prod-type = &1&2&1 and gob-doc.prod-code = &3 and gob-doc.stts <> 0 ~
                  and gob-doc.obj-type = &1&4&1 and gob-doc.obj-code = &5 and gob-doc.free-qnty <> 0 ' ~
                , ~{&double-quote~}, g-producer.obj-type, g-producer.obj-code, pobj-type, pobj-code)"
  &use-ind    = " "
  &by         = " by gob-doc.free-qnty ~
                  by gob-doc.artic "
                  }

  /*OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.prod-type = g-producer.obj-type and
                             {1}.prod-code = g-producer.obj-code and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0 and
                             {1}.stts <> 0
                             {&q-table2} by {1}.free-qnty
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-obj-price0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.stts = 0 ' ~
                      , ~{&double-quote~}, g-grp, pobj-type, pobj-code)"
    &use-ind    = " "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.stts = 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .
   */
END PROCEDURE.

PROCEDURE grp-obj-price.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = " "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic "
                    }


  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-obj-price-0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.stts <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = " "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and {1}.stts <> 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-fact-price0.

    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty <> 0 and gob-doc.stts = 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST    = " use-index obj-price"
    &by         = "  "
                    }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and
                             {1}.stts = 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-fact-qnty0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty > 0 and gob-doc.stts = 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST = " use-index obj-qnty "
    &by         = "  "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and
                             {1}.stts = 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-fact-price.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty > 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty > 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST  = " use-index obj-price"
    &by         = "  "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-fact-qnty.

    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST  = " use-index obj-qnty"
    &by         = "  "
                    }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-fact-price-0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty <> 0 and gob-doc.stts <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST    = " use-index obj-price"
    &by         = "  "
                    }

  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and
                             {1}.stts <> 0
                             use-index obj-price
                             {&q-table2} indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-fact-qnty-0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.fact-qnty > 0 and gob-doc.stts <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-indFIRST = " use-index obj-qnty"
    &by         = "  "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.fact-qnty <> 0 and
                             {1}.stts <> 0
                             use-index obj-qnty
                             {&q-table2} indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-free-price0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic ~
                    "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0 and
                             {1}.stts = 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic .
  */
END PROCEDURE.

PROCEDURE grp-free-qnty0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts = 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic ~
                    "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0 and
                             {1}.stts = 0
                             {&q-table2} by {1}.free-qnty
                             BY {1}.artic
                             indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-free-price.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0  "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic ~
                    "
                    }

   /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp and
                             {1}.obj-type = pobj-type and
                             {1}.obj-code = pobj-code and
                             {1}.free-qnty <> 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .
  */
END PROCEDURE.

PROCEDURE grp-free-qnty.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic ~
                    "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                            {1}.grp-name begins g-grp AND
                            {1}.obj-type = pobj-type AND
                            {1}.obj-code = pobj-code AND
                            {1}.free-qnty <> 0
                            {&q-table2} by {1}.free-qnty
                            BY {1}.artic
                            indexed-reposition
                            .*/
END PROCEDURE.

PROCEDURE grp-free-price-0.
    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.price-sale ~
                    by gob-doc.artic ~
                    "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code AND
                             {1}.free-qnty <> 0 AND
                             {1}.stts <> 0
                             {&q-table2} by {1}.price-sale
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.

PROCEDURE grp-free-qnty-0.

    { gbl/fltopend.i
    &where-cond = " gob-doc.grp-name begins g-grp and gob-doc.obj-type = pobj-type and gob-doc.obj-code = pobj-code ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 "
    &dyn_where-cond = " substitute('gob-doc.grp-name begins &1&2&1  and gob-doc.obj-type = &1&3&1 and gob-doc.obj-code = &4 ~
                    and gob-doc.free-qnty <> 0 and gob-doc.stts <> 0 ' ~
                      , ~{&double-quote~},                   g-grp, pobj-type, pobj-code)"
    &use-ind    = "  "
    &by         = " by gob-doc.free-qnty ~
                    by gob-doc.artic ~
                    "
                    }
  /*
  OPEN QUERY br-gds FOR EACH {1} no-lock  WHERE
                             {1}.grp-name begins g-grp AND
                             {1}.obj-type = pobj-type AND
                             {1}.obj-code = pobj-code AND
                             {1}.free-qnty <> 0 AND
                             {1}.stts <> 0
                             {&q-table2} by {1}.free-qnty
                             BY {1}.artic
                             indexed-reposition
                             .*/
END PROCEDURE.
&endif




/* $Workfile$ e n d */