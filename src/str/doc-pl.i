/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

доп. процедуры доя интерфейсов работы со складскими местами в документах

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/04/07
Author: Dmitry Ukhanov
Creation date: 10/04/07

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}":U = "def":U &then

  procedure disp-total :
    define input  parameter p-add-cli-qnty         like ub.doc-pl.cli-qnty         no-undo .
    define input  parameter p-add-doc-qnty         like ub.doc-pl.doc-qnty         no-undo .
    define input  parameter p-add-cli-doc-qnty     like ub.doc-pl.cli-doc-qnty     no-undo .
    define input  parameter p-add-fact-qnty        like ub.doc-pl.fact-qnty        no-undo .
    define input  parameter p-add-cli-fact-qnty    like ub.doc-pl.cli-fact-qnty    no-undo .
    define input  parameter p-add-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
    define input  parameter p-add-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .

    assign
      f-tot-doc-pl-cli-qnty         = p-add-cli-qnty
      f-tot-doc-pl-doc-qnty         = p-add-doc-qnty
      f-tot-doc-pl-cli-doc-qnty     = p-add-cli-doc-qnty
      f-tot-doc-pl-fact-qnty        = p-add-fact-qnty
      f-tot-doc-pl-cli-fact-qnty    = p-add-cli-fact-qnty
      f-tot-doc-pl-rest-af-qnty     = p-add-rest-af-qnty
      f-tot-doc-pl-cli-rest-af-qnty = p-add-cli-rest-af-qnty
    .
    for each tt-doc-pl no-lock
    :
      assign
        f-tot-doc-pl-cli-qnty         = f-tot-doc-pl-cli-qnty         + tt-doc-pl.cli-qnty
        f-tot-doc-pl-doc-qnty         = f-tot-doc-pl-doc-qnty         + tt-doc-pl.doc-qnty
        f-tot-doc-pl-cli-doc-qnty     = f-tot-doc-pl-cli-doc-qnty     + tt-doc-pl.cli-doc-qnty
        f-tot-doc-pl-fact-qnty        = f-tot-doc-pl-fact-qnty        + tt-doc-pl.fact-qnty
        f-tot-doc-pl-cli-fact-qnty    = f-tot-doc-pl-cli-fact-qnty    + tt-doc-pl.cli-fact-qnty
        f-tot-doc-pl-rest-af-qnty     = f-tot-doc-pl-rest-af-qnty     + tt-doc-pl.rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty = f-tot-doc-pl-cli-rest-af-qnty + tt-doc-pl.cli-rest-af-qnty
      .
    end.
    if f-tot-doc-pl-rest-af-qnty <> 0.0
      and f-tot-doc-pl-cli-rest-af-qnty <> 0.0
    then do:
      assign
        f-tot-doc-pl-rest-density = f-tot-doc-pl-cli-rest-af-qnty / f-tot-doc-pl-rest-af-qnty
      .
    end.
    else do:
      assign
        f-tot-doc-pl-rest-density = p-doc-line-rest-density
      .
    end.

    display
      f-tot-doc-pl-cli-qnty         when f-tot-doc-pl-cli-qnty         :visible = true
      f-tot-doc-pl-doc-qnty         when f-tot-doc-pl-doc-qnty         :visible = true
      f-tot-doc-pl-cli-doc-qnty     when f-tot-doc-pl-cli-doc-qnty     :visible = true
      f-tot-doc-pl-fact-qnty        when f-tot-doc-pl-fact-qnty        :visible = true
      f-tot-doc-pl-cli-fact-qnty    when f-tot-doc-pl-cli-fact-qnty    :visible = true
      f-tot-doc-pl-rest-af-qnty     when f-tot-doc-pl-rest-af-qnty     :visible = true
      f-tot-doc-pl-cli-rest-af-qnty when f-tot-doc-pl-cli-rest-af-qnty :visible = true
      f-tot-doc-pl-rest-density     when f-tot-doc-pl-rest-density     :visible = true
      with frame {&frame-name}
    .

    if f-tot-doc-pl-doc-qnty :visible = true
      and f-doc-line-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and f-tot-doc-pl-doc-qnty <> f-doc-line-doc-qnty
        )
        or
        ( p-upd-units = "cli":U
          and absolute( f-tot-doc-pl-doc-qnty - f-doc-line-doc-qnty ) > 0.001
        )
      then do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = 12
          f-doc-line-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = ?
          f-doc-line-doc-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-cli-doc-qnty :visible = true
      and f-doc-line-cli-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-doc-qnty - f-doc-line-cli-doc-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-doc-qnty <> f-doc-line-cli-doc-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = 12
          f-doc-line-cli-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = ?
          f-doc-line-cli-doc-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-cli-qnty :visible = true
      and f-doc-line-cli-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-qnty - f-doc-line-cli-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-qnty <> f-doc-line-cli-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = 12
          f-doc-line-cli-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = ?
          f-doc-line-cli-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-fact-qnty :visible = true
      and f-doc-line-fact-qnty :visible = true
    then do:
      if f-tot-doc-pl-fact-qnty <> f-doc-line-fact-qnty then do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = 12
          f-doc-line-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = ?
          f-doc-line-fact-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-cli-fact-qnty :visible = true
      and f-doc-line-cli-fact-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-fact-qnty - f-doc-line-cli-fact-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = 12
          f-doc-line-cli-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = ?
          f-doc-line-cli-fact-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-rest-af-qnty :visible = true
      and f-doc-line-rest-af-qnty :visible = true
    then do:
      if f-tot-doc-pl-rest-af-qnty <> f-doc-line-rest-af-qnty then do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = 12
          f-doc-line-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = ?
          f-doc-line-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.

    if f-tot-doc-pl-cli-rest-af-qnty :visible = true
      and f-doc-line-cli-rest-af-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-rest-af-qnty - f-doc-line-cli-rest-af-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = 12
          f-doc-line-cli-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = ?
          f-doc-line-cli-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.

  end procedure.

  procedure get-from-rvs :

    define input  parameter p-doc-code               like ub.trn-doc.doc-code                no-undo .
    define input  parameter p-gds-code               like ub.rvs-line.gds-code               no-undo .
    define input  parameter p-pl-code                like ub.rvs-line.pl-code                no-undo .
    define output parameter p-state-measure-qnty     like ub.rvs-line.state-measure-qnty     no-undo .
    define output parameter p-measure-qnty           like ub.rvs-line.measure-qnty           no-undo .
    define output parameter p-state-measure-cli-qnty like ub.rvs-line.state-measure-cli-qnty no-undo .
    define output parameter p-measure-cli-qnty       like ub.rvs-line.measure-cli-qnty       no-undo .
    define output parameter p-state-density          like ub.rvs-line.state-density          no-undo .
    define output parameter p-measure-density        like ub.rvs-line.density                no-undo .
    define output parameter p-label                  as   character                          no-undo .

    do
    on error  undo, return error substitute( "&1 (disp-from-rvs). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (disp-from-rvs). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (disp-from-rvs). endkey", vss-workfile )
    :
      define buffer rvs_trn-doc  for ub.trn-doc .
      define buffer bef_rvs-doc  for ub.rvs-doc  .
      define buffer aft_rvs-doc  for ub.rvs-doc  .
      define buffer bef_rvs-line for ub.rvs-line .
      define buffer aft_rvs-line for ub.rvs-line .

      assign
        p-state-measure-qnty     = 0
        p-measure-qnty           = 0
        p-state-measure-cli-qnty = 0
        p-measure-cli-qnty       = 0
        p-label                  = "":U
      .

      case buf_trn-doc.doc-type :
        when {&income} then do:
          for each bef_rvs-doc no-lock
            where bef_rvs-doc.out-code  = p-doc-code
              and bef_rvs-doc.rvs-type  = {&rvs-before-doc}
          :
            for each bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
            :  
              assign
                p-state-measure-qnty     = p-state-measure-qnty     - bef_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           - bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty - bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       - bef_rvs-line.measure-cli-qnty
              .
            end .
          end .
          for each aft_rvs-doc no-lock
            where aft_rvs-doc.out-code  = p-doc-code
              and aft_rvs-doc.rvs-type  = {&rvs-after-doc}
          :
            for each aft_rvs-line no-lock
              where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
                and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
                and aft_rvs-line.pl-code  = p-pl-code
                and aft_rvs-line.gds-code = p-gds-code
            :
              assign
                p-state-measure-qnty     = p-state-measure-qnty     + aft_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           + aft_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       + aft_rvs-line.measure-cli-qnty
              .
            end.
          end .
          assign
            p-state-density          = p-state-measure-cli-qnty / p-state-measure-qnty
            p-measure-density        = p-measure-cli-qnty / p-measure-qnty
          .
          assign
            p-label = "По сверкам":U
          .
        end.
        when {&inventory} then do:
          find first rvs_trn-doc no-lock
            where rvs_trn-doc.doc-code = p-doc-code
            .
          find first bef_rvs-doc no-lock
            where bef_rvs-doc.rvs-code = rvs_trn-doc.out-code
            no-error .
          if available bef_rvs-doc then do:
            assign
              p-label = "По сверке":U
            .
            find first bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
              no-error .
            if available bef_rvs-line then do:
              assign
                p-state-measure-qnty     = bef_rvs-line.state-measure-qnty
                p-measure-qnty           = bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = bef_rvs-line.measure-cli-qnty
                p-state-density          = bef_rvs-line.state-density
                p-measure-density        = bef_rvs-line.density
              .
            end.
          end.
        end.
      end case.

    end.

  end procedure. /* get-from-rvs */
&endif

&if "{1}":U = "init-tot":U &then
  define variable v-data-type as character no-undo .
  define variable is-petrol   as logical   no-undo .
  define variable is-pieces   as logical   no-undo .

  find first buf_goods no-lock
    where buf_goods.gds-code = {2}
  .
  assign
    f-units-base = "(" + trim( buf_goods.unit-base ) + ")"
    f-units-cli  = "(" + trim( buf_goods.unit-cli ) + ")"
    f-label-density = "Плотность"
  .

  assign
    f-doc-line-doc-density      = p-doc-line-doc-density
    f-doc-line-fact-density     = p-doc-line-fact-density
    f-doc-line-rest-density     = p-doc-line-rest-density
    f-doc-line-cli-qnty         = p-doc-line-cli-qnty
    f-doc-line-doc-qnty         = p-doc-line-doc-qnty
    f-doc-line-cli-doc-qnty     = p-doc-line-doc-cli-qnty
    f-doc-line-fact-qnty        = p-doc-line-fact-qnty
    f-doc-line-cli-fact-qnty    = p-doc-line-fact-cli-qnty
    f-doc-line-rest-af-qnty     = p-doc-line-rest-af-qnty
    f-doc-line-cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
  .

  { gbl/conf-rd.i
    "'is-ptrl':U"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    {3}
    v-data-type
    no-error
  }
  if error-status :error
    or v-data-type <> "L":U
    or lookup( {3}, "yes,no":U ) = 0
  then do:
    assign
      {3} = "no":U
    .
  end.
  if {3} = "yes":U then do:
    { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrol
      is-pieces
      no-error
    }
    if error-status :error
      or {3} <> "yes"
      or is-petrol <>  yes
      or is-pieces <>  no
    then do:
      assign
        {3} = "no":U
      .
    end.
    else do:
      assign
        {3} = "yes":U
      .
    end.
  end.
&endif

&if "{1}":U = "disp-total":U &then
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
&endif

&if "{1}":U = "disp-add-total":U &then
  run disp-total in this-procedure
    ( input loc-t-doc-pl.cli-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-qnty         else 0.0 )
     ,input loc-t-doc-pl.doc-qnty         - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.doc-qnty         else 0.0 )
     ,input loc-t-doc-pl.cli-doc-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-doc-qnty     else 0.0 )
     ,input loc-t-doc-pl.fact-qnty        - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.fact-qnty        else 0.0 )
     ,input loc-t-doc-pl.cli-fact-qnty    - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-fact-qnty    else 0.0 )
     ,input loc-t-doc-pl.rest-af-qnty     - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.rest-af-qnty     else 0.0 )
     ,input loc-t-doc-pl.cli-rest-af-qnty - (if available buf-upd_tt-doc-pl then buf-upd_tt-doc-pl.cli-rest-af-qnty else 0.0 )
    ).
&endif

&if "{1}":U = "enable-tot-fld":U &then

  if buf_goods.unit-base <> buf_goods.unit-cli then do:
    display
      f-units-cli
      with frame {&frame-name}.
    if {2} = "yes":U then do:
      display
        f-label-density
        with frame {&frame-name}.
    end.
  end.

  if buf_trn-doc.doc-type = {&income}
    and buf_trn-doc.internal = false
  then do:
    assign
      f-doc-line-cli-qnty :label in frame {&frame-name} = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
      f-tot-doc-pl-cli-qnty :label in frame {&frame-name} = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
    .
    display
      f-doc-line-cli-qnty
      f-tot-doc-pl-cli-qnty
      with frame {&frame-name}
    .
  end.

  case p-upd-field :
    when "rest":U
    or when "rest-fact":U
    then do:
      if p-upd-field = "rest":U then do:
        assign
/*        f-doc-line-rest-af-qnty       :bgcolor = 8*/
/*        f-doc-line-cli-rest-af-qnty   :bgcolor = 8*/
          f-tot-doc-pl-rest-af-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-rest-af-qnty :bgcolor = 8
          f-tot-doc-pl-rest-density     :bgcolor = 8
/*        f-doc-line-rest-density       :bgcolor = 8*/
        .
      end.
      else do:
        assign
/*        f-doc-line-fact-qnty       :bgcolor = 8*/
/*        f-doc-line-cli-fact-qnty   :bgcolor = 8*/
          f-tot-doc-pl-fact-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        .
      end.
      assign
/*        f-doc-line-fact-qnty          :label in frame {&frame-name} = substitute( "Разница" )*/
        f-tot-doc-pl-fact-qnty        :label in frame {&frame-name} = substitute( "Разница" )
/*        f-doc-line-rest-af-qnty       :row in frame {&frame-name}   = f-doc-line-doc-qnty :row in frame {&frame-name}*/
/*        f-doc-line-rest-af-qnty       :handle :side-label-handle :row in frame {&frame-name} = f-doc-line-doc-qnty :row in frame {&frame-name}*/
/*        f-doc-line-cli-rest-af-qnty   :row in frame {&frame-name}   = f-doc-line-rest-af-qnty :row in frame {&frame-name}*/
        f-tot-doc-pl-rest-af-qnty     :row in frame {&frame-name}   = f-tot-doc-pl-doc-qnty :row in frame {&frame-name}
        f-tot-doc-pl-rest-af-qnty     :handle :side-label-handle :row in frame {&frame-name} = f-tot-doc-pl-doc-qnty :row in frame {&frame-name}
        f-tot-doc-pl-cli-rest-af-qnty :row in frame {&frame-name}   = f-tot-doc-pl-rest-af-qnty :row in frame {&frame-name}
        f-tot-doc-pl-rest-density     :row in frame {&frame-name}   = f-tot-doc-pl-rest-af-qnty :row in frame {&frame-name}
/*        f-doc-line-rest-density       :row in frame {&frame-name}   = f-doc-line-rest-af-qnty :row in frame {&frame-name}*/
        rect-tot :height-chars in frame {&frame-name} = 3.5
        frame {&frame-name} :height-chars = frame {&frame-name} :height-chars - 3.5
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-density     when buf_goods.unit-base <> buf_goods.unit-cli
/*        f-doc-line-fact-qnty*/
/*        f-doc-line-cli-fact-qnty      when buf_goods.unit-base <> buf_goods.unit-cli*/
/*        f-doc-line-rest-af-qnty*/
/*        f-doc-line-cli-rest-af-qnty   when buf_goods.unit-base <> buf_goods.unit-cli*/
/*        f-doc-line-rest-density       when {2} = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli*/
/*        f-tot-doc-label        */
        with frame {&frame-name}.
        .
    end.
    when "doc":U then do:
      assign
        f-tot-doc-pl-doc-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-doc-qnty :bgcolor = 8
        f-doc-line-doc-qnty       :bgcolor = 8
        f-doc-line-cli-doc-qnty   :bgcolor = 8
        f-doc-line-doc-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when {2} = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
    when "fact":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-fact-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when {2} = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when {2} = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
    when "fact-doc":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-fact-qnty
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when {2} = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
  end case.

&endif

/* $Workfile$ e n d */