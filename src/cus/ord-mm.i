/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

общий кусочек

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 03/17/04 1:38

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ord-mm :
 do
 on error undo, return error return-value
 :

define variable loc-sum-min as decimal no-undo .
define variable t-type as character no-undo .
define variable v-grop-max-stock as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-obj-AssMin as logical   no-undo .
define variable v-obj-igt     as character no-undo .
define variable loc-host-code as integer   no-undo .
define variable loc-obj-type  as character no-undo .
define variable loc-obj-code  as integer   no-undo .




for each tmp#zakaz :
      assign
        loc-sum-min = 0
        tmp#zakaz.min-stock = 0
        tmp#zakaz.max-stock = 0
        tmp#zakaz.service-order = 0
        tmp#zakaz.min-order = 0
        .

        case R-min-rest :
        when 1   then do:

            for each obj-list :
                assign
                  loc-obj-type = obj-list.obj-type
                  loc-obj-code = obj-list.obj-code
                .
                { gbl/gdsobjpr.i
                  loc-obj-type
                  loc-obj-code
                  ?
                  ?
                  ?
                  tmp#zakaz.gds-code
                  v-obj-AssMin
                  v-obj-igt
                  loc-sum-min
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order
                  }

                /* минимальный остаток */
                if G#type = {&f-p} or G#type = {&o-o} then
                   tmp#zakaz.min-stock =  (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                else tmp#zakaz.min-stock = tmp#zakaz.min-stock + (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .

                /* Уровень пост.присутстви  */
                if G#type = {&f-p} or G#type = {&o-o} then
                    tmp#zakaz.service-order = (if v-grop-level-always-presence <> ? then v-grop-level-always-presence else 0 ).
                else tmp#zakaz.service-order = tmp#zakaz.service-order + (if  v-grop-level-always-presence <> ? then  v-grop-level-always-presence else 0 ).

                /* минимальный заказ */
                if G#type = {&f-p} or G#type = {&o-o} then
                    tmp#zakaz.min-order = (if  v-grop-min-order <> ? then v-grop-min-order else 0 ).
                else tmp#zakaz.min-order = tmp#zakaz.min-order + (if v-grop-min-order <> ? then v-grop-min-order else 0 ).

                /* максимальный остаток */
                if G#type = {&f-p} or G#type = {&o-o} then
                     tmp#zakaz.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                else tmp#zakaz.max-stock = tmp#zakaz.max-stock + (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .

            end.
          end.

        when 2  then do:

            for each obj-list :
                 { gbl/hostcode.i obj-list.obj-type obj-list.obj-code loc-host-code }
                  assign
                  loc-obj-type = {&cmp}
                  loc-obj-code = loc-host-code
                .
                { gbl/gdsobjpr.i
                  loc-obj-type
                  loc-obj-code
                  ?
                  ?
                  ?
                  tmp#zakaz.gds-code
                  v-obj-AssMin
                  v-obj-igt
                  loc-sum-min
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order
                  }

                /* минимальный остаток */
                if G#type = {&f-p} or G#type = {&o-o} then
                   tmp#zakaz.min-stock =  (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .
                else tmp#zakaz.min-stock = tmp#zakaz.min-stock + (if  loc-sum-min <> ? then  loc-sum-min else 0 ) .

                /* Уровень пост.присутстви  */
                if G#type = {&f-p} or G#type = {&o-o} then
                    tmp#zakaz.service-order = (if v-grop-level-always-presence <> ? then v-grop-level-always-presence else 0 ).
                else tmp#zakaz.service-order = tmp#zakaz.service-order + (if  v-grop-level-always-presence <> ? then  v-grop-level-always-presence else 0 ).

                /* минимальный заказ */
                if G#type = {&f-p} or G#type = {&o-o} then
                    tmp#zakaz.min-order = (if  v-grop-min-order <> ? then v-grop-min-order else 0 ).
                else tmp#zakaz.min-order = tmp#zakaz.min-order + (if v-grop-min-order <> ? then v-grop-min-order else 0 ).

                /* максимальный остаток */
                if G#type = {&f-p} or G#type = {&o-o} then
                     tmp#zakaz.max-stock =  (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
                else tmp#zakaz.max-stock = tmp#zakaz.max-stock + (if  v-grop-max-stock <> ? then  v-grop-max-stock else 0 ) .
               leave.
            end.
          end.

    end case.

    if  r-min-rest3 then do:  /* сезон */
/*        tmp#zakaz.min-stock = 0 .*/

      for each ub.season no-lock where 
                  ub.season.sea-month-1 <= integer (DATE-sale-2) and
                  ub.season.sea-month-2 >= integer (DATE-sale-1):
        find first ub.season-attr where ub.season-attr.sea-code = ub.season.sea-code
          and ub.season-attr.db-num = ub.season.db-num
          and ub.season-attr.attr-code = {&seaattr-obj}
          and ub.season-attr.attr-value = tmp#zakaz.obj-type + string (tmp#zakaz.obj-code) no-error.
    
                find first ub.gds-season no-lock where
                ub.gds-season.gds-code = tmp#zakaz.gds-code and
                ub.gds-season.sea-code = ub.season.sea-code and
                ub.gds-season.db-num   = ub.season.db-num
                no-error .
        if available ub.season-attr and available ub.gds-season 
        then do:
          find first ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
            and ub.gds-season-attr.db-num = ub.gds-season.db-num
            and ub.gds-season-attr.gds-code = ub.gds-season.gds-code
            and ub.gds-season-attr.attr-code = {&gdsseaattr-season-coef}
            no-error.
          if available ub.gds-season-attr then tmp#zakaz.season-coef = decimal (ub.gds-season-attr.attr-value).
          tmp#zakaz.min-stock = ub.gds-season.min-stock .
          leave.
        end.
        else do:
                if available ub.gds-season then do:
            find first ub.gds-season-attr no-lock where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
              and ub.gds-season-attr.db-num = ub.gds-season.db-num
              and ub.gds-season-attr.gds-code = ub.gds-season.gds-code
              and ub.gds-season-attr.attr-code = {&gdsseaattr-season-coef}
              no-error.
            if available ub.gds-season-attr then tmp#zakaz.season-coef = decimal (ub.gds-season-attr.attr-value).
                  tmp#zakaz.min-stock = ub.gds-season.min-stock .
                end.
          end.
      end.
      if tmp#zakaz.season-coef = ? or tmp#zakaz.season-coef = 0 then assign tmp#zakaz.season-coef = 1.

    end.

end. /* for each tt */


 end. /* do */
end procedure. /* ord-mm */

/* $Workfile$ e n d */