/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедуры создания временных таблиц для групп в сменном отчете

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

{ ref/grplibfn.i }

procedure t-level :
  define input parameter loc-node-code like ub.gds-grp.node-code no-undo .

  define buffer loc-gds-grp for ub.gds-grp .

  define variable loc-grp-name as character no-undo .

  for each loc-gds-grp no-lock where
           loc-gds-grp.upper-code = loc-node-code
  :
    if loc-gds-grp.is-term = no
    then do:
      run t-level in this-procedure ( input loc-gds-grp.node-code ) no-error .
    end.
    else do:
      run grplib-get-full-name in this-procedure
        (  input loc-gds-grp.node-code
        , output loc-grp-name
        ) .
      create t-3 .
      assign t-3.grp-code  = loc-gds-grp.node-code
             t-3.serv-name = loc-grp-name
             t-3.grp-name  = loc-gds-grp.node-name
      .
    end.
  end. /* for each loc-gds-grp */
end procedure. /* t-level */

procedure n-level :
  define input parameter loc-node-code like ub.gds-grp.node-code no-undo .
  define input parameter locvar-lavel  as   integer              no-undo .

  define buffer loc-gds-grp for ub.gds-grp .

  define variable loc-grp-name as character no-undo .

  for each loc-gds-grp no-lock where
           loc-gds-grp.upper-code = loc-node-code
  :
    run grplib-get-full-name in this-procedure
      (  input loc-gds-grp.node-code
      , output loc-grp-name
      ) .
    if loc-gds-grp.lvl-num  > locvar-lavel or
     ( loc-gds-grp.lvl-num <  locvar-lavel and
       loc-gds-grp.is-term <> yes )
    then do:
      run n-level in this-procedure
        ( input loc-gds-grp.node-code
        , input locvar-lavel
        ) no-error .
    end.
    else do:
      create t-3 .
      assign t-3.grp-code = loc-gds-grp.node-code
             t-3.serv-name = loc-grp-name
             t-3.grp-name = loc-gds-grp.node-name
      .
    end.
  end. /* for each loc-gds-grp */
end procedure. /* n-level */

/* $Workfile$   E n d */

