block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-z2zvit.p $
$Archive: rep/r-z2zvit.p $

сменный отчет АЗС (Украина): 2-я страница

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

&scop f-l Int2Char,addl-list

define input parameter p-parent-proc         as   widget-handle           no-undo.
define input parameter pobj-code             like ub.clients.obj-code     no-undo.
define input parameter pobj-type             like ub.clients.obj-type     no-undo.
define input parameter p-base-type           like ub.currency.curr-abbr   no-undo.
define input parameter p-base-code           like ub.currency.curr-code   no-undo.
define input parameter p-can-print           as   logical                 no-undo.
define input parameter p-sort-type           as   character               no-undo.
define input parameter pshift-date           like ub.shift-obj.shift-date no-undo.
define input parameter pshift-num            like ub.shift-obj.shift-num  no-undo.
define input parameter p-previous-shift-date as   date                    no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-z2zvit.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-z2zvit.p $":U.
define variable vss-description as character no-undo initial "сменный отчет АЗС (Украина)":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ str/lib-trn.i                 }
{ rep/real-2df.i shared treal-2 }
{ rep/icm-2df.i  shared         }
{ cmp/r-page1.i                 }
{ cmp/r-pril.i                  }
{ rep/r-sym.i                   }
{ rep/r-gl.i                    }
{ gbl/std-func.i {&f-l}         }
{ rep/real-2cr.i treal-2        }
{ gbl/prn-lib.i  shared         }
{ gbl/getsect.i def }

define variable pshift-date1           like ub.shift-obj.shift-date no-undo.
define variable pshift-num1            like ub.shift-obj.shift-num  no-undo.
assign
  pshift-date1 = pshift-date
  pshift-num1  = pshift-num
.

define variable pol1  as character no-undo.
define variable pol2  as character no-undo.
define variable pol3  as decimal   no-undo.
define variable pol4  as decimal   no-undo.
define variable pol5  as decimal   no-undo.
define variable pol6  as decimal   no-undo.
define variable pol7  as decimal   no-undo.
define variable pol8  as decimal   no-undo.
define variable pol9  as integer   no-undo.
define variable pol10 as decimal   no-undo.
define variable pol11 as decimal   no-undo.
define variable pol12 as decimal   no-undo.
define variable pol13 as decimal   no-undo.
define variable pol14 as decimal   no-undo.
define variable pol15 as decimal   no-undo.

define variable p-host-code       as integer   no-undo.
define variable v-param-shft-qty  as character no-undo.
define variable v-param-data-type as character no-undo.
define variable jndex             as integer   no-undo initial 0.
define variable o-pol2            as character no-undo.
define variable v_shift-name      as character no-undo.
define variable v_shift-name-num  as character no-undo.

define buffer bf_goods               for ub.goods.
define buffer bf_place               for ub.place.
define buffer control_rvs-doc        for ub.rvs-doc.
define buffer control_rvs-line-pump  for ub.rvs-line-pump.
define buffer current_rvs-doc        for ub.rvs-doc.
define buffer current_rvs-line       for ub.rvs-line.
define buffer current_rvs-line-pump  for ub.rvs-line-pump.
define buffer previous_rvs-doc       for ub.rvs-doc.
define buffer previous_rvs-line      for ub.rvs-line.
define buffer previous_rvs-line-pump for ub.rvs-line-pump.

define frame FRAME-2
                             space( 0 ) sym1  format "x(1)":U space( 0 )
  pol1  format "x(8)":U      space( 0 ) sym2  format "x(1)":U space( 2 )
  pol2  format "x(2)":U      space( 1 ) sym3  format "x(1)":U space( 3 )
  pol3  format ">>>>9":U     space( 2 ) sym4  format "x(1)":U space( 2 )
  pol4  format ">>9":U       space( 1 ) sym5  format "x(1)":U space( 1 )
  pol5  format ">>>9.99":U   space( 0 ) sym6  format "x(1)":U space( 1 )
  pol6  format ">>>>>9.99":U space( 1 ) sym7  format "x(1)":U space( 0 )
  pol7  format "->>>>9.99":U space( 0 ) sym8  format "x(1)":U space( 0 )
  pol8  format "->>>>9.99":U space( 0 ) sym9  format "x(1)":U space( 1 )
  pol9  format ">9":U        space( 0 ) sym10 format "x(1)":U space( 0 )
  pol10 format ">>>>>9.99":U space( 1 ) sym11 format "x(1)":U space( 1 )
  pol11 format ">>>>>9.99":U space( 1 ) sym12 format "x(1)":U space( 0 )
  pol12 format ">>9.99":U    space( 0 ) sym13 format "x(1)":U space( 0 )
  pol13 format ">>9.99":U    space( 0 ) sym14 format "x(1)":U space( 0 )
  pol14 format "->>>>9.99":U space( 0 ) sym15 format "x(1)":U space( 0 )
  pol15 format "->>>>9.99":U space( 0 ) sym16 format "x(1)":U space( 0 )
with width {&DOS_CW_2} down stream-io use-text no-labels no-box.

form header
  skip( 4 )
  { rep/r-z2zvit.i }
with frame TopFrame width {&DOS_CW_2} page-top no-labels no-box.

{ rep/r-shfth.i  proc-def }
{ rep/f-fdec.i            }
{ rep/r-shftfo.i          }
{ rep/r-zmzvit.i " " 2    }

define buffer bf_zz2 for tt-zz2.

{ gbl/hostcode.i
    pobj-type
    pobj-code
    p-host-code
    no-error
}
{ str/shiftnam.i
    pobj-type
    pobj-code
    pshift-date
    pshift-num
    v_shift-name
    v_shift-name-num
    no-error
}

{ gbl/getsect.i run pobj-type pobj-code {&attr-report-obj}}
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'shft-qty'  then v-param-shft-qty  = thbjattr_thbj-attr.property-value-character .
  end.

  if lookup( v-param-shft-qty, "system,state":U ) = 0 then do:
     assign  v-param-shft-qty = "system":U.
  end.


find first current_rvs-doc no-lock where
           current_rvs-doc.obj-type   = pobj-type    and
           current_rvs-doc.obj-code   = pobj-code    and
           current_rvs-doc.shift-date = pshift-date  and
           current_rvs-doc.shift-num  = pshift-num   and
           current_rvs-doc.status_    = {&fact}      and
           current_rvs-doc.rvs-type   = {&rvs-shift} no-error.
if not available current_rvs-doc then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Не найдена сверка типа" '"' + {&rvs-shift} + '"' skip( 0 )
          "Объект:" pobj-type   pobj-code        skip( 0 )
          "Смена"   pshift-date v_shift-name-num skip( 1 )
  view-as alert-box error.
  return error.
end.

if available previous-shift-obj then do:
  find first previous_rvs-doc no-lock where
             previous_rvs-doc.obj-type   = pobj-type                     and
             previous_rvs-doc.obj-code   = pobj-code                     and
             previous_rvs-doc.shift-date = previous-shift-obj.shift-date and
             previous_rvs-doc.shift-num  = previous-shift-obj.shift-num  and
             previous_rvs-doc.status_    = {&fact}                       and
             previous_rvs-doc.rvs-type   = {&rvs-shift}                  no-error.
end.

for each current_rvs-line no-lock where
         current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
         current_rvs-line.obj-type = current_rvs-doc.obj-type and
         current_rvs-line.obj-code = current_rvs-doc.obj-code
break by current_rvs-line.gds-code
      by current_rvs-line.pl-code
:
  find first bf_goods no-lock where
             bf_goods.gds-code = current_rvs-line.gds-code no-error.
  { gbl/gdsbcode.i bf_goods.gds-code ? v-bar-code }
  find first bf_place no-lock where
             bf_place.obj-code = current_rvs-line.obj-code and
             bf_place.obj-type = current_rvs-line.obj-type and
             bf_place.pl-code  = current_rvs-line.pl-code  no-error.

  if available previous_rvs-doc then do:
    find first previous_rvs-line no-lock where
               previous_rvs-line.rvs-code = previous_rvs-doc.rvs-code and
               previous_rvs-line.obj-code = current_rvs-line.obj-code and
               previous_rvs-line.obj-type = current_rvs-line.obj-type and
               previous_rvs-line.pl-code  = current_rvs-line.pl-code  and
               previous_rvs-line.gds-code = current_rvs-line.gds-code no-error.
  end. /* if available previous_rvs-doc */

  for each current_rvs-line-pump no-lock where
           current_rvs-line-pump.rvs-code = current_rvs-line.rvs-code and
           current_rvs-line-pump.obj-code = current_rvs-line.obj-code and
           current_rvs-line-pump.obj-type = current_rvs-line.obj-type and
           current_rvs-line-pump.pl-code  = current_rvs-line.pl-code  and
           current_rvs-line-pump.gds-code = current_rvs-line.gds-code
  break by current_rvs-line-pump.pump-code
        by current_rvs-line-pump.nozzle-code
  :
    if first-of( current_rvs-line-pump.pump-code ) then do:
      assign pol10 = 0
             pol11 = 0
             pol12 = 0
             pol14 = 0
             pol15 = 0.
    end. /* if first-of( current_rvs-line-pump.pump-code ) */

    assign pol10 = pol10 + current_rvs-line-pump.state-mh-cnt.
    if available previous_rvs-doc then do:
      find first previous_rvs-line-pump no-lock where
                 previous_rvs-line-pump.rvs-code    = previous_rvs-doc.rvs-code         and
                 previous_rvs-line-pump.obj-code    = current_rvs-line.obj-code         and
                 previous_rvs-line-pump.obj-type    = current_rvs-line.obj-type         and
                 previous_rvs-line-pump.pl-code     = current_rvs-line.pl-code          and
                 previous_rvs-line-pump.gds-code    = current_rvs-line.gds-code         and
                 previous_rvs-line-pump.pump-code   = current_rvs-line-pump.pump-code   and
                 previous_rvs-line-pump.nozzle-code = current_rvs-line-pump.nozzle-code no-error.
      if available previous_rvs-line-pump then do:
        assign pol11 = pol11 + previous_rvs-line-pump.state-mh-cnt.
      end.
    end. /* if available previous_rvs-doc */

    if not available previous_rvs-doc       or
       not available previous_rvs-line-pump then do:
      for each  control_rvs-doc no-lock where
                control_rvs-doc.obj-type          = current_rvs-doc.obj-type          and
                control_rvs-doc.obj-code          = current_rvs-doc.obj-code          and
                control_rvs-doc.shift-date        = current_rvs-doc.shift-date        and
                control_rvs-doc.shift-num         = current_rvs-doc.shift-num         and
                control_rvs-doc.status_           = {&fact}                           and
                control_rvs-doc.rvs-type          = {&rvs-control}
        , first control_rvs-line-pump no-lock where
                control_rvs-line-pump.rvs-code    = control_rvs-doc.rvs-code          and
                control_rvs-line-pump.gds-code    = current_rvs-line.gds-code         and
                control_rvs-line-pump.obj-code    = current_rvs-line.obj-code         and
                control_rvs-line-pump.obj-type    = current_rvs-line.obj-type         and
                control_rvs-line-pump.pl-code     = current_rvs-line.pl-code          and
                control_rvs-line-pump.pump-code   = current_rvs-line-pump.pump-code   and
                control_rvs-line-pump.nozzle-code = current_rvs-line-pump.nozzle-code
             by control_rvs-doc.fact-order        :
        assign pol11 = pol11 + control_rvs-line-pump.state-mh-cnt.
        leave.
      end. /* for each control_rvs-doc */
    end. /* if not available previous_rvs-doc or not available previous_rvs-line-pump */

    if last-of( current_rvs-line-pump.pump-code ) then do:
      assign pol12 = pol10 - pol11
             pol14 = 0
             pol15 = 0.

      find first tt-zz2 where
                 tt-zz2.gds-code  = current_rvs-line-pump.gds-code  and
                 tt-zz2.pl-code   = current_rvs-line-pump.pl-code   and
                 tt-zz2.pump-code = current_rvs-line-pump.pump-code no-error.
      if not available tt-zz2 then do:
        assign jndex = jndex + 1.
        create tt-zz2.
        assign tt-zz2.gds-code  = bf_goods.gds-code
               tt-zz2.artic     = bf_goods.artic
               tt-zz2.prod-type = bf_goods.prod-type
               tt-zz2.prod-code = bf_goods.prod-code
               tt-zz2.gds-name  = bf_goods.gds-name
               tt-zz2.b-code    = v-bar-code
               tt-zz2.reservoir = ( if available bf_place then trim( bf_place.loc1 ) else "??" )
               tt-zz2.pl-code   = current_rvs-line-pump.pl-code
               tt-zz2.pump-code = current_rvs-line-pump.pump-code
               tt-zz2.order     = jndex.
      end. /* if not available tt-zz2 */

      assign tt-zz2.shift-stop  = pol10
             tt-zz2.shift-start = pol11
             tt-zz2.mh-real     = pol12.
    end. /* if last-of( current_rvs-line-pump.pump-code ) */
  end. /* for each current_rvs-line-pump */
end. /* for each current_rvs-line */

for each tt-zz2 no-lock
break by tt-zz2.gds-code
      by tt-zz2.pl-code
      by tt-zz2.pump-code
:
  if first-of( tt-zz2.pl-code ) then do:
    assign pol13 = 0.
  end. /* if first-of( tt-zz2.pl-code ) */

  assign pol13 = pol13 + tt-zz2.mh-real.

  if last-of( tt-zz2.pl-code ) then do:
    find first current_rvs-line no-lock where
               current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
               current_rvs-line.obj-type = current_rvs-doc.obj-type and
               current_rvs-line.obj-code = current_rvs-doc.obj-code and
               current_rvs-line.pl-code  = tt-zz2.pl-code           and
               current_rvs-line.gds-code = tt-zz2.gds-code          no-error.
    find first bf_zz2 where
               bf_zz2.gds-code = tt-zz2.gds-code and
               bf_zz2.pl-code  = tt-zz2.pl-code  use-index pl-order no-error.
    assign bf_zz2.mh-total    = pol13
           bf_zz2.level-total = current_rvs-line.state-level-total * 10
           bf_zz2.level-water = current_rvs-line.state-level-water * 10
           bf_zz2.pipe-line   = current_rvs-line.state-add-qnty
           bf_zz2.shift-qnty  = ( if v-param-shft-qty = "state":U then current_rvs-line.state-measure-qnty
                                                                  else current_rvs-line.system-qnty        )
           pol13              = 0.
  end. /* if last-of( tt-zz2.pl-code ) */

  if last-of( tt-zz2.gds-code ) then do:
    find first current_rvs-line no-lock where
               current_rvs-line.rvs-code = current_rvs-doc.rvs-code and
               current_rvs-line.obj-type = current_rvs-doc.obj-type and
               current_rvs-line.obj-code = current_rvs-doc.obj-code and
               current_rvs-line.pl-code  = tt-zz2.pl-code           and
               current_rvs-line.gds-code = tt-zz2.gds-code          no-error.
    find first bf_zz2 where
               bf_zz2.gds-code = tt-zz2.gds-code use-index gds-order no-error.
    assign bf_zz2.differ-qnty = ( if v-param-shft-qty = "state":U then current_rvs-line.state-measure-qnty
                                                                  else current_rvs-line.system-qnty        )
                              - current_rvs-line.system-qnty.
  end. /* if last-of( current_rvs-line.gds-code ) */
end. /* for each tt-zz2 */

assign pol1  = "":U
       pol2  = "":U
       pol3  = 0
       pol4  = 0
       pol5  = 0
       pol6  = 0
       pol7  = 0
       pol8  = 0
       pol9  = 0
       pol10 = 0
       pol11 = 0
       pol12 = 0
       pol13 = 0
       pol14 = 0
       pol15 = 0.

/* собственно печать */
if p-can-print = yes then do:
  view stream PrnLibStream frame TopFrame.

  for each tt-zz2 no-lock
  break by tt-zz2.gds-code
        by tt-zz2.pl-code
        by tt-zz2.pump-code
  :
    assign pol1  = tt-zz2.gds-name
           pol2  = tt-zz2.reservoir
           pol3  = tt-zz2.level-total
           pol4  = tt-zz2.level-water
           pol5  = tt-zz2.pipe-line
           pol6  = tt-zz2.shift-qnty
           pol7  = ( if tt-zz2.differ-qnty > 0 then tt-zz2.differ-qnty else 0 )
           pol8  = ( if tt-zz2.differ-qnty < 0 then tt-zz2.differ-qnty else 0 )
           pol9  = tt-zz2.pump-code
           pol10 = tt-zz2.shift-stop
           pol11 = tt-zz2.shift-start
           pol12 = tt-zz2.mh-real
           pol13 = tt-zz2.mh-total
           pol14 = tt-zz2.delta-prc
           pol15 = tt-zz2.delta-qnty.
    display stream PrnLibStream sym1
                                sym9
                                sym10
                                sym11
                                sym12
                                sym13
                                sym14
                                sym15
                                sym16
    with frame FRAME-2.

    if first-of( tt-zz2.gds-code ) then do:
      assign o-pol2 = pol2.
      display stream PrnLibStream pol1                sym2
                                  pol2                sym3
                                  pol3 when pol3 <> ? sym4
                                  pol4 when pol4 <> ? sym5
                                  pol5 when pol5 <> ? sym6
                                  pol6                sym7
                                  pol7 when pol7 >  0 sym8
                                  pol8 when pol8 <  0 sym9
      with frame FRAME-2.
        {&PutExcel} pol1  {&tabulation}
                    pol2  {&tabulation}.
          if pol3 <> ? then do:
        {&PutExcel} pol3  {&tabulation}.
          end.
          else do:
        {&PutExcel}       {&tabulation}.
          end.
          if pol4 <> ? then do:
        {&PutExcel} pol4  {&tabulation}.
          end.
          else do:
        {&PutExcel}       {&tabulation}.
          end.
          if pol5 <> ? then do:
        {&PutExcel} pol5  {&tabulation}.
          end.
          else do:
        {&PutExcel}       {&tabulation}.
          end.
        {&PutExcel} pol6  {&tabulation}.
          if pol7  > 0 then do:
        {&PutExcel} pol7  {&tabulation}.
          end.
          else do:
        {&PutExcel}       {&tabulation}.
          end.
          if pol8 <  0 then do:
        {&PutExcel} pol8  {&tabulation}.
          end.
          else do:
        {&PutExcel}       {&tabulation}.
          end.
    end. /* if first-of( tt-zz2.gds-code ) */
    else do:
      {&PutExcel}       {&tabulation}.
        if pol12 <> 0 then do:
      {&PutExcel} pol2  {&tabulation}.
        end.
        else do:
      {&PutExcel}       {&tabulation}.
        end.
      {&PutExcel}       {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}.
    end.

    display stream PrnLibStream pol2  when pol2  <> o-pol2
                                sym2  when pol2  <> o-pol2
                                sym3  when pol2  <> o-pol2
                                pol9
                                pol10
                                pol11
                                pol12 when pol12 <> 0
                                pol13
                                pol14
                                pol15
    with frame FRAME-2.
    down stream PrnLibStream with frame FRAME-2.

    {&PutExcel} pol9  {&tabulation}
                pol10 {&tabulation}
                pol11 {&tabulation}.
      if pol12 <> 0 then do:
    {&PutExcel} pol12 {&tabulation}.
      end.
      else do:
    {&PutExcel}       {&tabulation}.
      end.
    {&PutExcel} pol13 {&tabulation}
                pol14 {&tabulation}
                pol15 {&new-line}.

    if last( tt-zz2.gds-code ) then do:
      /* ******************************************** *\
      underline stream PrnLibStream sym1  pol1
                                    sym2  pol2
                                    sym3  pol3
                                    sym4  pol4
                                    sym5  pol5
                                    sym6  pol6
                                    sym7  pol7
                                    sym8  pol8
                                    sym9  pol9
                                    sym10 pol10
                                    sym11 pol11
                                    sym12 pol12
                                    sym13 pol13
                                    sym14 pol14
                                    sym15 pol15 sym16
      with frame FRAME-2.
      \* ******************************************** */
      put stream PrnLibStream unformatted
        "----------------------------------------------------------------------------------------------------------------------------------------" skip.
    end. /* last( tt-zz1.gds-code ) */
  end. /* for each tt-zz2 */
end. /* if can-print */