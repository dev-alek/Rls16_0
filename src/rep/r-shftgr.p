block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shftgr.p $
$Archive: rep/r-shftgr.p $

ñìåííûé îò÷åò - ãåíåðàöèÿ òàáëèöû äëÿ ãðóïï ÒÍÏ (ÞÊÎÑ ëèñò 3)

Àâòîð: Óõàíîâ Äìèòðèé Þðüåâè÷
Äàòà ñîçäàíèÿ: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter pobj-type   like ub.shift-obj.obj-type   no-undo .
define input parameter pobj-code   like ub.shift-obj.obj-code   no-undo .
define input parameter pshift-date like ub.shift-obj.shift-date no-undo .
define input parameter pshift-num  like ub.shift-obj.shift-num  no-undo .
define input parameter pClassify   as   character               no-undo .
define input parameter pSortType   as   character               no-undo .
define input parameter ptog-lavel  as   logical                 no-undo .
define input parameter pvar-lavel  as   integer                 no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shftgr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shftgr.p $":U .
define variable vss-description as character no-undo initial "ñìåííûé îò÷åò - ãåíåðàöèÿ òàáëèöû äëÿ ãðóïï ÒÍÏ (ÞÊÎÑ ëèñò 3)":U .

{ cmp/str-glbl.i        }
{ cmp/r-page1.i         }
{ rep/icm-3df.i  shared }
{ rep/r-shftgr.i        }

define variable loc-classify  as   integer              no-undo .
define variable curr-grp-code like ub.gds-grp.node-code no-undo .
define variable for-grp-name  like ub.gds-grp.node-name no-undo .

case pClassify :
  when "totals":U
  then do:
    assign
      loc-classify = - 1
    .
  end.
  when "no-classify":U
  then do:
    assign
      loc-classify = 1
    .
  end.
  when "n-level":U
  then do:
    assign
      loc-classify = pvar-lavel
    .
  end.
  when "t-level":U
  then do:
    assign
      loc-classify = 0
    .
  end.
end case. /* pClassify */

/* ñîçäàäèì òàáëèöó ãðóïï */
for each t-3
:
  delete t-3 .
end.
if loc-classify = - 1
then do:
  create t-3 .
  assign t-3.grp-code  = 0
         t-3.serv-name = "":U
         t-3.grp-name  = ( if X-selectgood = {&g-grp} then "ÈÒÎÃÎ ÏÎ ÂÑÅÌ ÂÛÁÐÀÍÍÛÌ ÃÐÓÏÏÀÌ" else "ÈÒÎÃÎ ÏÎ ÂÑÅÌ ÃÐÓÏÏÀÌ" )
  .
  return .
end.
if X-selectgood = {&g-grp}
then do:
  for each tmp#grp no-lock
  :
    run grplib-get-full-name in this-procedure
      (  input tmp#grp.node-code
      , output for-grp-name
      ) .
    case loc-Classify :
      when 1
      then do:
        create t-3 .
        assign t-3.grp-code  = tmp#grp.node-code
               t-3.serv-name = for-grp-name
               t-3.grp-name  = tmp#grp.grp-name
        .
      end.
      when  0 or
      when -1
      then do:
        if tmp#grp.is-term = yes
        then do:
          create t-3 .
          assign t-3.grp-code  = tmp#grp.node-code
                 t-3.serv-name = for-grp-name
                 t-3.grp-name  = tmp#grp.grp-name
          .
        end.
        else do:
          run t-level in this-procedure ( input tmp#grp.node-code ) no-error .
        end.
      end.
      when pvar-lavel
      then do:
        if tmp#grp.lvl-num >= pvar-lavel or
         ( tmp#grp.lvl-num <  pvar-lavel and
           tmp#grp.is-term  = yes )
        then do:
          create t-3 .
          assign t-3.grp-code  = tmp#grp.node-code
                 t-3.serv-name = for-grp-name
                 t-3.grp-name  = tmp#grp.grp-name
          .
        end.
        else
        run n-level in this-procedure(tmp#grp.node-code, pvar-lavel) no-error.
      end.
    end case. /* loc-Classify */
  end. /* for each tmp#grp */
end. /* X-selectgood = {&g-grp} */
else do:
  for each ub.gds-grp no-lock
  :
    assign
      curr-grp-code = ub.gds-grp.node-code
    .
    run grplib-get-full-name in this-procedure
      (  input gds-grp.node-code
      , output for-grp-name
      ) .
    case loc-Classify :
      when 1
      then do:
        if ub.gds-grp.lvl-num <> 1
        then do:
          next .
        end.
      end.
      when 0
      then do:
        IF not ub.gds-grp.is-term
        then do:
          next .
        end.
      end.
      when pvar-lavel
      then do:
        if ub.gds-grp.lvl-num > pvar-lavel or
         ( ub.gds-grp.lvl-num < pvar-lavel and
           ub.gds-grp.is-term = no )
        then do:
          next .
        end.
      end.
    end case. /* loc-Classify */
    create t-3 .
    assign t-3.grp-code  = curr-grp-code
           t-3.serv-name = for-grp-name
           t-3.grp-name  = ub.gds-grp.node-name
    .
  end. /* for each ub.gds-grp */
end. /* X-selectgood <> {&g-grp} */

