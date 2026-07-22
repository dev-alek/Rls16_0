/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для топливных документов прихода

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/26/08
Author: Dmitry Ukhanov
Creation date: 02/26/08

*/

&scoped-define vssseq {&sequence}


define variable vss-include-info{&vssseq} as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}":U = "def":U &then

  &if "{2}":U = "one-line":U &then

    { str/valddnst.i def           }
    { str/plgdsfnd.i parparentproc }
    { str/lib-rvs.i                }
    { str/rvsttdef.i rvs           }
    { ref/gds-attr.i }
    { str/is-gas.i }
    { str/is-sug.i }
    { str/placelib.i }
    { gbl/db-attr.i }
    
    define temp-table tt-rvs-line-pump-delta no-undo like ub.rvs-line-pump
      field deltaVol as decimal
      field density as decimal 
      field is-err as logical
      field find-pair as logical
    .
    
    define variable infoSectionsTotal       as class InfoSectionsTotal no-undo.
    define variable tanksForm               as class ibs.th.str.ptrl.forms.tanksections no-undo.
    define variable v-prt-autoent-obj-type as character    no-undo .
    define variable v-prt-autoent-obj-code as character    no-undo .
    define variable v-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
    define variable v-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
    define variable v-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
    define variable v-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
    define variable v-prt-fio              as character    no-undo .
    define variable v-prt-ptbotype         as character    no-undo .
    define variable v-prt-ptbocode         as character    no-undo .
    define variable was_setting            as logical      no-undo initial no .

    define variable ptoldfilvalue          as character    no-undo.
    define variable ptoldfiltype           as character    no-undo.
    define variable stfactplvalue          as character    no-undo initial ? .
    define variable stfactpltype           as character    no-undo initial ? .

    define variable varupd-fact-qnty       as logical      no-undo initial yes .
    define variable varrevision            as logical      no-undo initial no  .
    define variable varpercrev             as decimal      no-undo initial ?   .
    define variable varauto-tank           as logical      no-undo initial no  .
    define variable varpercauto            as decimal      no-undo initial ?   .
    define variable varinv                 as logical      no-undo initial no  .
    define variable varpercinv             as decimal      no-undo initial ?   .
    define variable varinv-set             as logical      no-undo initial no  .
    define variable varrn-algo             as logical      no-undo initial no  .
    define variable varrn-acc-ship         as decimal      no-undo .
    define variable varcar-num             as character    no-undo .
    
        
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-value2 as character no-undo.
    define variable v-ok as logical no-undo.
    
    define variable pl-rvd-dens as logical no-undo .
    define variable pl-rvd-lvl as logical no-undo .
    define variable pl-rvd-temp as logical no-undo .
    
    procedure return-rvs-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-pl-code             like ub.rvs-line.pl-code            no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-delta-mass-qnty     as decimal no-undo .
      define output parameter p-trk-err             as logical no-undo .

      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .
      define buffer bf_rvs-line-attr for ub.rvs-line-attr .
      define buffer buf_rvs-line-pump for ub.rvs-line-pump .
      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      
      empty temp-table tt-rvs-line-pump-delta .
      
      for each bf_bef_rvs-doc no-lock
        where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
          and bf_bef_rvs-doc.out-code = p-doc-code
      :
        for each bf_bef_rvs-line no-lock
          where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
            and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
            and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
            and bf_bef_rvs-line.gds-code = p-gds-code
        :
          if p-pl-code <> ?
            and p-pl-code <> bf_bef_rvs-line.pl-code
          then do:
            next .
          end.
          assign
            p-rvs-qnty-before     = p-rvs-qnty-before     + bf_bef_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-before = p-rvs-cli-qnty-before + bf_bef_rvs-line.state-measure-cli-qnty
          .
          
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bf_bef_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bf_bef_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bf_bef_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bf_bef_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bf_bef_rvs-line.gds-code
          :
            create tt-rvs-line-pump-delta .
            buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
            assign
              tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
              tt-rvs-line-pump-delta.density = (bf_bef_rvs-line.state-density / 2)
            .
            if tt-rvs-line-pump-delta.state-el-cnt = ?
            or tt-rvs-line-pump-delta.state-el-cnt <= 0
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
          end. /* for each bf_rvs-line-pump */
        end. /* for each bf_bef_rvs-line */
      end. /* for each bf_bef_rvs-doc */
      for each bf_aft_rvs-doc no-lock
        where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
          and bf_aft_rvs-doc.out-code = p-doc-code
      :
        for each bf_aft_rvs-line no-lock
          where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
            and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
            and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
            and bf_aft_rvs-line.gds-code = p-gds-code
        :
          if p-pl-code <> ?
            and p-pl-code <> bf_aft_rvs-line.pl-code
          then do:
            next .
          end.
          find first bf_rvs-line-attr no-lock
            where bf_rvs-line-attr.rvs-code = bf_aft_rvs-line.rvs-code
              and bf_rvs-line-attr.obj-type = bf_aft_rvs-line.obj-type
              and bf_rvs-line-attr.obj-code = bf_aft_rvs-line.obj-code
              and bf_rvs-line-attr.pl-code = bf_aft_rvs-line.pl-code
              and bf_rvs-line-attr.gds-code = p-gds-code 
              and bf_rvs-line-attr.attr-code = "delta-mass-qnty"
              no-error.
              
          if available (bf_rvs-line-attr)
          then p-delta-mass-qnty = decimal (bf_rvs-line-attr.attr-value).
          else p-delta-mass-qnty = 0.65. 
          assign
            p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
          .
          release bf_rvs-line-attr.
          
          for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = bf_aft_rvs-line.rvs-code
                                               and buf_rvs-line-pump.obj-type = bf_aft_rvs-line.obj-type
                                               and buf_rvs-line-pump.obj-code = bf_aft_rvs-line.obj-code
                                               and buf_rvs-line-pump.pl-code  = bf_aft_rvs-line.pl-code
                                               and buf_rvs-line-pump.gds-code = bf_aft_rvs-line.gds-code
          :
            find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                no-error .
            if not available tt-rvs-line-pump-delta
            then do :
              create tt-rvs-line-pump-delta .
              buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
              assign
                tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                tt-rvs-line-pump-delta.is-err = yes
              .
            end .
            else do :
              tt-rvs-line-pump-delta.find-pair = yes .
              if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
              then do :
                tt-rvs-line-pump-delta.is-err = yes .
              end .
              else do :
                tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                tt-rvs-line-pump-delta.density = tt-rvs-line-pump-delta.density + (bf_aft_rvs-line.state-density / 2) .
              end .
            end .
          end . /* for each bf_rvs-line-pump */
        end. /* for each bf_aft_rvs-line */
      end. /* for each _rvs-doc */
      
      p-trk-err = no .
      
      find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.is-err no-error .
      if available tt-rvs-line-pump-delta
      then do :
        p-trk-err = yes .
        return .
      end .
      
      for each tt-rvs-line-pump-delta :
        assign
          p-rvs-qnty-after     = p-rvs-qnty-after     + tt-rvs-line-pump-delta.deltaVol
          p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + (tt-rvs-line-pump-delta.deltaVol * tt-rvs-line-pump-delta.density)
        .
      end .
      
    end procedure. /* return-rvs-qnty */
    
    procedure return-rvs-sec-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-sec-name            as character                        no-undo .
      define  input parameter p-loc1                as character                        no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .

      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .
      define buffer bf_place        for ub.place .
      
      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
                                          and bf_bef_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 3
                                          and entry(2, bf_bef_rvs-doc.rvs-code, "-") = p-sec-name
                                          no-error .
      if not available bf_bef_rvs-doc
      then do :
        find first bf_bef_rvs-doc no-lock where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
                                            and bf_bef_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      if available bf_bef_rvs-doc
      then do :
        for first bf_place no-lock where bf_place.obj-type = bf_bef_rvs-doc.obj-type
                                     and bf_place.obj-code = bf_bef_rvs-doc.obj-code
                                     and bf_place.loc1     = p-loc1
                                     and bf_place.status_  = "",
        each bf_bef_rvs-line no-lock
          where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
            and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
            and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
            and bf_bef_rvs-line.gds-code = p-gds-code
            and bf_bef_rvs-line.pl-code  = bf_place.pl-code
        :
          assign
            p-rvs-qnty-before     = p-rvs-qnty-before     + bf_bef_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-before = p-rvs-cli-qnty-before + bf_bef_rvs-line.state-measure-cli-qnty
          .
        end. /* for each bf_bef_rvs-line */
      end. /* for each bf_bef_rvs-doc */
      
      find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
                                          and bf_aft_rvs-doc.out-code = p-doc-code
                                          and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 3 
                                          and entry(2, bf_aft_rvs-doc.rvs-code, "-") = p-sec-name
                                          no-error .
      if not available bf_aft_rvs-doc
      then do :
        find first bf_aft_rvs-doc no-lock where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
                                            and bf_aft_rvs-doc.out-code = p-doc-code
                                            and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 2
                                            no-error .
      end .
      if available bf_aft_rvs-doc
      then do :
        for first bf_place no-lock where bf_place.obj-type = bf_aft_rvs-doc.obj-type
                                     and bf_place.obj-code = bf_aft_rvs-doc.obj-code
                                     and bf_place.loc1     = p-loc1
                                     and bf_place.status_  = "",
        each bf_aft_rvs-line no-lock
          where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
            and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
            and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
            and bf_aft_rvs-line.gds-code = p-gds-code
            and bf_aft_rvs-line.pl-code  = bf_place.pl-code
        :
          assign
            p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
          .
        end. /* for each bf_aft_rvs-line */
      end. /* for each bf_aft_rvs-doc */
    end procedure. /* return-rvs-sec-qnty */

    procedure check-before :

      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .

      define buffer buf_goods         for ub.goods .
      define buffer bf_after_rvs-doc  for ub.rvs-doc  .
      define buffer bf_after_rvs-line for ub.rvs-line .

      do
      on error undo, return error substitute( "&1 (check-before). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .

        find first bf_after_rvs-doc no-lock
          where bf_after_rvs-doc.rvs-type = {&rvs-after-doc}
            and bf_after_rvs-doc.out-code = p-doc-code
          no-error .
        if available bf_after_rvs-doc then do:
          for each tt-doc-pl no-lock
          :
            if p-pl-code <> ?
              and tt-doc-pl.pl-code <> p-pl-code
            then do:
              next.
            end.

            find first bf_after_rvs-line no-lock
              where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
                and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
                and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
                and bf_after_rvs-line.pl-code  = tt-doc-pl.pl-code
                and bf_after_rvs-line.gds-code = p-gds-code
              no-error .
            if not available bf_after_rvs-line then do:
              message
                "По данному товару нет заготовки для сверки <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                view-as alert-box error .
              return error .
            end.
            if bf_after_rvs-line.state-measure-qnty <> ? then do:
              message
                "Уже задан фактический остаток в сверке <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
            if ptrlprop-olddens <> true
              and bf_after_rvs-line.state-density <> ?
              and buf_goods.unit-base <> buf_goods.unit-cli
            then do:
              message
                "Уже задана фактическая плотность в сверке <<после налива топлива>>"
                "по резервуару" tt-doc-pl.pl-code "."
                "Следует удалить сверки и создать их снова."
                view-as alert-box error .
              return error .
            end.
          end. /* for each tt-doc-pl */
        end. /* if available bf_after_rvs-doc */
        else do:
          message "Не создана сверка <<после налива топлива>>." view-as alert-box error .
          return error .
        end.
      end. /* on error */
    end procedure. /* check-before */

    procedure check-after :

      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define input  parameter p-pl-code  like ub.doc-pl.pl-code   no-undo .

      define buffer buf_before_rvs-doc  for ub.rvs-doc  .
      define buffer buf_before_rvs-line for ub.rvs-line .
      define buffer buf_place           for ub.place .
      
      define variable ii as integer no-undo .

      do
      on error undo, return error return-value
      :
        find first buf_before_rvs-doc no-lock
          where buf_before_rvs-doc.rvs-type = {&rvs-before-doc}
            and buf_before_rvs-doc.out-code = p-doc-code
          no-error .
        if available buf_before_rvs-doc then do:
          for each tt-doc-pl no-lock
          on error undo, return error return-value
          :
            
            if is-gas(p-gds-code) then next.
            
            run placelib_get-attr(input {&place-virtual}
                                 ,input tt-doc-pl.obj-code
                                 ,input tt-doc-pl.obj-type
                                 ,input tt-doc-pl.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
        
            is-vir = if (v-ok and logical(v-value)) then true else false.
            
            if is-vir then next.
            
            find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                           and buf_place.obj-code = tt-doc-pl.obj-code
                                           and buf_place.pl-code  = tt-doc-pl.pl-code
                                           no-error .
            
            run placelib_get-attr  (
               input {&place-com-tanks}
              ,input tt-doc-pl.obj-code
              ,input tt-doc-pl.obj-type
              ,input tt-doc-pl.pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            if  v-ok
            and v-value > ""
            then do :
              v-value = v-value + "," + buf_place.loc1 .
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                               and buf_place.obj-code = tt-doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  find first buf_before_rvs-line no-lock
                    where buf_before_rvs-line.rvs-code = buf_before_rvs-doc.rvs-code
                      and buf_before_rvs-line.obj-type = buf_before_rvs-doc.obj-type
                      and buf_before_rvs-line.obj-code = buf_before_rvs-doc.obj-code
                      and buf_before_rvs-line.pl-code  = buf_place.pl-code
                      and buf_before_rvs-line.gds-code = p-gds-code
                    no-error .
                  if not available buf_before_rvs-line then do:
                    message
                      "По данному товару нет заготовки для сверки <<до налива топлива>>"
                      "по резервуару" buf_place.pl-code "."
                      view-as alert-box error .
                    return error .
                  end.
                  if buf_before_rvs-line.state-measure-qnty = ?
                  then do:
                    message
                      "Не заполнены данные по резервуару №" buf_place.loc1
                      " в документе сверки «До»!"
                      view-as alert-box error .
                    return error .
                  end.
                end .
              end .
            end .
            else do :
              if p-pl-code <> ?
              and tt-doc-pl.pl-code <> p-pl-code
              then do:
                next.
              end.
              
              find first buf_before_rvs-line no-lock
                where buf_before_rvs-line.rvs-code = buf_before_rvs-doc.rvs-code
                  and buf_before_rvs-line.obj-type = buf_before_rvs-doc.obj-type
                  and buf_before_rvs-line.obj-code = buf_before_rvs-doc.obj-code
                  and buf_before_rvs-line.pl-code  = tt-doc-pl.pl-code
                  and buf_before_rvs-line.gds-code = p-gds-code
                no-error .
              if not available buf_before_rvs-line then do:
                message
                  "По данному товару нет заготовки для сверки <<до налива топлива>>"
                  "по резервуару" tt-doc-pl.pl-code "."
                  view-as alert-box error .
                return error .
              end.
              if buf_before_rvs-line.state-measure-qnty = ?
              then do:
                message
                  "Не задан фактический остаток в сверке <<до налива топлива>>"
                  "по резервуару" tt-doc-pl.pl-code "." skip
                  "Следует удалить сверки и создать их снова."
                  view-as alert-box error .
                return error .
              end.
              if buf_before_rvs-line.state-density = ?
              then do:
                message
                  "Не задана фактическая плотность в сверке <<до налива топлива>>"
                  "по резервуару" tt-doc-pl.pl-code "." skip
                  "Следует удалить сверки и создать их снова."
                  view-as alert-box error .
                return error .
              end.
            end .
          end. /* for each tt-doc-pl */
        end. /* if available buf_before_rvs-doc */
        else do:
          message "Не создана сверка <<до налива топлива>>." view-as alert-box error .
          return error .
        end.
      end. /* on error */
    end procedure. /* check-after */

    procedure action-rvs-line :

      define input parameter p-action      as   character           no-undo .
      define input parameter p-action-type as   character           no-undo .
      define input parameter p-rvs-type    like ub.rvs-doc.rvs-type no-undo .
      define output parameter p-pl-code      like ub.place.pl-code    no-undo .
      define buffer buf_doc-line for ub.doc-line.

      block_tr:
      do transaction
      on error  undo block_tr, return error substitute( "&1 (action-rvs-line). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo block_tr, return error substitute( "&1 (action-rvs-line). stop", vss-workfile )
      on endkey undo block_tr, return error substitute( "&1 (action-rvs-line). endkey", vss-workfile )
      :
        define variable v-rvs-code     like ub.rvs-doc.rvs-code no-undo .
        define variable v-act-name     as   character           no-undo .
        define variable v-log          as   logical             no-undo .
        define variable is-rvs-place   as   logical             no-undo .

        define variable varnum         as   integer             no-undo.
        define variable varcur-rvs     as   integer             no-undo.
        define variable v-today        as   date                no-undo.
        define variable v-time         as   integer             no-undo.
        define variable v-value        as character no-undo .
        define variable v-value2       as character no-undo .
        define variable v-ok           as logical   no-undo .
        define variable ii             as integer   no-undo .
        define variable v-com-vessel-rvs as logical no-undo init no .
        define variable v-com-vessel-is-meas as logical no-undo init no .
        define variable v-code         as character    no-undo.
        define variable is-com-tanks   as logical no-undo init no .
        define variable v-pump-err     as character no-undo init "":U .
        
        define variable v-pl-list      as character no-undo init "":U .

        define buffer buf_rvs-doc       for ub.rvs-doc .
        define buffer buf_rvs-line      for ub.rvs-line .
        define buffer buf_rvs-line-pump for ub.rvs-line-pump .
        define buffer buf_place         for ub.place .
        define buffer bf_pump-nozzle    for ub.pump-nozzle.
        define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
        define buffer bf_pl-gds         for ub.pl-gds.

        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-density         like ub.rvs-line.state-density          no-undo .
        define variable v-com-tank-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-com-tank-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-com-tank-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-com-tank-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-attr-type           as character no-undo .
        define variable v-attr-value          as character   no-undo .
        define variable v-delta-mass-qnty as decimal   no-undo .
        define variable v-com-tank-delta-mass-qnty as decimal   no-undo .
        
        define variable v-asi-ip  as character no-undo .
        define variable v-asi-port as character no-undo .
        define variable v-asi-type as character no-undo .
        
        define variable infoSecObj        as class InfoSection no-undo .
        define variable v-KPrvs-secs      as character no-undo .
        define variable v-KPrvs-doc-pl    as logical   no-undo .
        define variable v-trk-err         as logical   no-undo .
        define variable v-com-tanks-not-filled as logical no-undo init no .

        assign
          p-pl-code = ?
        .

        find first buf_rvs-doc exclusive-lock
          where buf_rvs-doc.rvs-type = p-rvs-type
            and buf_rvs-doc.out-code = t-doc.doc-code
          no-error .
        if not available buf_rvs-doc then do:
          message
            "Не зафиксированы книжные кол-ва и не созданы документы сверки по складскому документу." skip
            view-as alert-box error .
          undo block_tr, return error .
        end.

        if p-rvs-type <> {&rvs-after-doc}
          and p-rvs-type <> {&rvs-before-doc}
        then do:
          message
            "Ошибка задания параметров." skip
            "Неизвестный для документа прихода тип сверки." skip
            "Тип сверки" p-rvs-type skip
            "Код сверки" buf_rvs-doc.rvs-code skip
            view-as alert-box error .
          undo block_tr, return error .
        end.

        find first tt-doc-pl no-lock
          no-error .
        if not available tt-doc-pl then do:
          message
            substitute( "Товар &1 не распределен по местам хранения.", buf_goods.gds-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.

        assign
          p-pl-code      = ?
        .
        
        if p-action = {&lookup}
        then do :
          for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                          and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                          and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                          and buf_rvs-line.gds-code = tt-doc-pl.gds-code
          :
            assign
              p-pl-code      = buf_rvs-line.pl-code
              v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + "," 
            .
          end .
          if p-pl-code = ?
          then do :
            message
              "Не найдена строка сверки:" skip
              substitute( "товар &1", tt-doc-pl.gds-code ) skip
              substitute( "место хранения &1", tt-doc-pl.pl-code ) skip
              view-as alert-box error .
            undo block_tr, return error .
          end .
        end .
        else do :
          tt-doc-pl_ :
          for each tt-doc-pl no-lock
          on error undo block_tr, return error return-value
          :
            if not is-sug(tt-doc-pl.gds-code)
            then do :
              v-KPrvs-secs = "" .
              v-KPrvs-doc-pl = no .
              find first buf_place no-lock where buf_place.obj-type = t-doc.obj-type
                                             and buf_place.obj-code = t-doc.obj-code
                                             and buf_place.pl-code  = tt-doc-pl.pl-code
                                             .
              do ii = 1 to infoSectionsTotal:SectionNum : 
                infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
                if infoSecObj:ListTank = buf_place.loc1
                then do :
                  if infoSecObj:IsKP
                  then do :
                    v-KPrvs-doc-pl = yes .
                  end .
                  v-KPrvs-secs = v-KPrvs-secs + "," + infoSecObj:SectionName .
                end .
              end .
              v-KPrvs-secs = trim(v-KPrvs-secs, ",") .
              
              if v-KPrvs-doc-pl
              and num-entries(v-KPrvs-secs) >= 1
              then do :
                next tt-doc-pl_ .
              end .
            end .
            
            find first buf_rvs-line no-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                and buf_rvs-line.pl-code  = tt-doc-pl.pl-code
                and buf_rvs-line.gds-code = tt-doc-pl.gds-code
              no-error .
            if not available buf_rvs-line then do:
              message
                "Не найдена строка сверки:" skip
                substitute( "товар &1", tt-doc-pl.gds-code ) skip
                substitute( "место хранения &1", tt-doc-pl.pl-code ) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
            assign
              p-pl-code      = buf_rvs-line.pl-code
              v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + "," .
            .
            
            run placelib_get-attr  (
               input {&place-com-tanks}
              ,input t-doc.obj-code
              ,input t-doc.obj-type
              ,input tt-doc-pl.pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            
            if  v-ok
            and v-value > ""
            and p-action-type = "edit"
            then do :
              is-com-tanks = yes .
              
              find first buf_place no-lock
                where buf_place.obj-type = t-doc.obj-type
                  and buf_place.obj-code = t-doc.obj-code
                  and buf_place.pl-code  = tt-doc-pl.pl-code
              .
              
  /*            v-value = buf_place.loc1 + "," + v-value  .*/
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                               and buf_place.obj-code = tt-doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  find first buf_rvs-line no-lock
                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                      and buf_rvs-line.pl-code  = buf_place.pl-code
                      and buf_rvs-line.gds-code = tt-doc-pl.gds-code
                    no-error .
                  if not available buf_rvs-line
                  then do:
                    if t-doc.status_ <> {&fact}
                    then do :
                      message
                        "Не найдена строка сверки:" skip
                        substitute( "товар &1", tt-doc-pl.gds-code ) skip
                        substitute( "место хранения &1", buf_place.pl-code ) skip
                        view-as alert-box error .
                      undo block_tr, return error .
                    end .
                  end.
                  else do :
                    assign
                      p-pl-code      = buf_rvs-line.pl-code
                      v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + "," 
                    .
                  end .
                end .
              end .
            end .
              
          end. /* for each tt-doc-pl */
        end .
        
        assign v-pl-list = trim(v-pl-list, ",") .

        if num-entries(v-pl-list) > 1
        or p-pl-code = ?
        then do:
          run ref/pl-gds-list.w
            ( input v-pl-list
            , output p-pl-code
            ) no-error .
          if p-pl-code = ? 
          or p-pl-code = 0
          then do:
            message "Не выбрано место хранения " view-as alert-box .
            undo block_tr, return error .
          end.
          if error-status :error then do:
            message
              substitute( "Ошибка при выборе места хранения по товару &1.", buf_goods.gds-code ) skip
              return-value skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
          /*
          if is-com-tanks
          and p-pl-code <> ?
          then do :
            run ref/pl-gds-com-tanks.w
              ( input p-pl-code
              , output p-pl-code
              ) no-error .
            if p-pl-code = ? 
            or p-pl-code = 0
            then do:
              message "Не выбрано место хранения " view-as alert-box .
              undo block_tr, return error .
            end.
            if error-status :error then do:
              message
                substitute( "Ошибка при выборе места хранения по товару &1.", buf_goods.gds-code ) skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
          end .
          else do :
            run plgdsfnd in this-procedure
              ( input yes
              ,input buf_rvs-doc.obj-type
              ,input buf_rvs-doc.obj-code
              ,input buf_goods.gds-code
              ,output is-rvs-place
              ,output p-pl-code
              ) no-error .
            if error-status :error then do:
              message
                substitute( "Ошибка при выборе места хранения по товару &1.", buf_goods.gds-code ) skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
          end .
          */
        end. /* v-count-doc-pl > 1 */

        find first buf_rvs-line
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
            and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
            and buf_rvs-line.pl-code  = p-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          no-error.
        if not available buf_rvs-line then do:
          message
            substitute( "Не найдена строка сверки по резервуару &1", p-pl-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.

        case p-action :
          when {&update} then
          do:
            find buf_place no-lock
            where buf_place.obj-type = t-doc.obj-type
              and buf_place.obj-code = t-doc.obj-code
              and buf_place.pl-code  = p-pl-code
            .
                    
            if p-action-type = "meas" or buf_place.is-meas <> yes then /* ТН-3370 Арн 12.01.2015. (Строка Накл в режиме "Изменить") и меню pop-up (по кнопкам "Св.до" и "Св.после") = "Сверка резервуара" [он же парам="meas"] */
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_cr-revision':U /* Право на создание сверки */
              .
            end.
            else
            do:
              run placelib_get-attr  ( input {&place-rvd-dnsty}
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-dens = no.
              else pl-rvd-dens = logical(v-value) .
              
              run placelib_get-attr  ( input {&place-rvd-lvl}
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-lvl = no.
              else pl-rvd-lvl = logical(v-value) .
              
              run placelib_get-attr  ( input {&place-rvd-tmp}
                                        ,input buf_place.obj-code
                                        ,input buf_place.obj-type
                                        ,input buf_place.pl-code
                                        ,output v-value
                                        ,output v-ok      ) no-error.
              if not v-ok then pl-rvd-temp = no.
              else pl-rvd-temp = logical(v-value) .
              
              if buf_place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then do :
                assign
                  v-act-name = 'actn_rvs-on-doc_upd-revision':U /* Право на изменение сверки */
                .
              end .
              else do :
                assign
                  v-act-name = 'actn_rvs-control_upd-immeas':U /* Право на изменение сверки */
                .
              end .
            end.
/*            if infoSectionsTotal:IsKP                                                           */
/*            then do :                                                                           */
/*              assign                                                                            */
/*                v-act-name = 'actn_income_petrol-сommission':U /* Право на комиссионный приём */*/
/*              .                                                                                 */
/*            end .                                                                               */
            case p-rvs-type :
              when {&rvs-before-doc} then do:
                run check-before in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input p-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
              when {&rvs-after-doc} then do:
                run check-after in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input p-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
            end case .
          end.
          when {&lookup} then do:
            assign
              v-act-name = 'actn_rvs-on-doc_lookup':U
            .
          end.
        end case.

        if v-act-name <> "":U then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            v-act-name
            {&cntxt-object}
            buf_rvs-doc.host-code
            buf_rvs-doc.obj-type
            buf_rvs-doc.obj-code
            0
            0
            0
            true
            v-log
            no-error
          }
          if v-log <> yes then do:
            if infoSectionsTotal:IsKP
            and p-action = {&update}
            then do :
              message "По накладной установлен флаг комиссионного приема. Работа со сверками запрещена!" view-as alert-box .
            end .
            undo block_tr, return error .
          end.
        end.

        find first buf_rvs-line exclusive-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = t-doc.obj-type
            and buf_rvs-line.obj-code = t-doc.obj-code
            and buf_rvs-line.pl-code  = p-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          .

        case p-action-type :
          when "meas":U then do:
            for each tt-meas
            :
              delete tt-meas .
            end.
            
            for each tt-pump-nozzle
            :
              delete tt-pump-nozzle .
            end.
            
            find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = p-pl-code
              .
              
            run placelib_get-attr  (
               input {&place-com-tanks}
              ,input buf_rvs-doc.obj-code
              ,input buf_rvs-doc.obj-type
              ,input p-pl-code
              ,output v-value
              ,output v-ok      )
            no-error.
            if  v-ok
            and v-value > ""
            then do :
              v-com-vessel-rvs = yes .
              v-com-vessel-is-meas = no .
              v-value = v-value + "," + buf_place.loc1 .
              do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                               and buf_place.obj-code = buf_rvs-doc.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
/*                  run placelib_get-attr  ( input {&place-rvd-dnsty}      */
/*                                            ,input buf_place.obj-code    */
/*                                            ,input buf_place.obj-type    */
/*                                            ,input buf_place.pl-code     */
/*                                            ,output v-value2             */
/*                                            ,output v-ok      ) no-error.*/
/*                  if not v-ok then pl-rvd-dens = no.                     */
/*                  else pl-rvd-dens = logical(v-value2) .                 */
/*                                                                         */
/*                  run placelib_get-attr  ( input {&place-rvd-lvl}        */
/*                                            ,input buf_place.obj-code    */
/*                                            ,input buf_place.obj-type    */
/*                                            ,input buf_place.pl-code     */
/*                                            ,output v-value2             */
/*                                            ,output v-ok      ) no-error.*/
/*                  if not v-ok then pl-rvd-lvl = no.                      */
/*                  else pl-rvd-lvl = logical(v-value2) .                  */
/*                                                                         */
/*                  run placelib_get-attr  ( input {&place-rvd-tmp}        */
/*                                            ,input buf_place.obj-code    */
/*                                            ,input buf_place.obj-type    */
/*                                            ,input buf_place.pl-code     */
/*                                            ,output v-value2             */
/*                                            ,output v-ok      ) no-error.*/
/*                  if not v-ok then pl-rvd-temp = no.                     */
/*                  else pl-rvd-temp = logical(v-value2) .                 */
                  
                  if buf_place.is-meas
/*                  and not pl-rvd-dens*/
/*                  and not pl-rvd-lvl */
/*                  and not pl-rvd-temp*/
                  then do :
                    v-com-vessel-is-meas = yes .
                    create tt-meas .
                    assign
                      tt-meas.obj-type = buf_rvs-doc.obj-type
                      tt-meas.obj-code = buf_rvs-doc.obj-code
                      tt-meas.pl-code  = buf_place.pl-code
                      tt-meas.loc1     = buf_place.loc1
                    .
                    for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = buf_place.obj-type 
                                                         and bf_pl-pump-nozzle.obj-code = buf_place.obj-code
                                                         and bf_pl-pump-nozzle.pl-code  = buf_place.pl-code,
                    first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type 
                                                   and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code 
                                                   and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                                   and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
/*                                                   and bf_pump-nozzle.is-meas     = yes*/
                    :
                      create tt-pump-nozzle.
                      assign
                        tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                        tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                        tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                        tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                        tt-pump-nozzle.gds-code    = buf_goods.gds-code
                      .
                    end .
                  end .
                end .
                
              end .
              if not v-com-vessel-is-meas
              then do :
                message
                  substitute( 'Ни один из сообщающихся резервуаров не измеряется приборами.', buf_place.pl-code)
                  view-as alert-box error .
                undo block_tr, return error .
              end .
            end .
            else do :
              if buf_place.is-meas <> yes then do:
                message
                  substitute( 'Резервуар &1 не измеряется приборами.', buf_place.pl-code)
                  view-as alert-box error .
                undo block_tr, return error .
              end.
              if buf_place.loc1 = "":U
                or buf_place.loc1 = ?
              then do:
                message
                  substitute( 'Не указан локальный код на складском месте &1 .', buf_place.pl-code )
                  view-as alert-box error .
                undo block_tr, return error .
              end.
            
              create tt-meas .
              assign
                tt-meas.obj-type = t-doc.obj-type
                tt-meas.obj-code = t-doc.obj-code
                tt-meas.pl-code  = p-pl-code
              .
              for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = tt-meas.obj-type 
                                                   and bf_pl-pump-nozzle.obj-code = tt-meas.obj-code
                                                   and bf_pl-pump-nozzle.pl-code  = tt-meas.pl-code,
              first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type 
                                             and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code 
                                             and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                             and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
/*                                             and bf_pump-nozzle.is-meas     = yes*/
              :
                create tt-pump-nozzle.
                assign
                  tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                  tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                  tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                  tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                  tt-pump-nozzle.gds-code    = buf_goods.gds-code
                .
              end .
            end .  
            
            find first sys-ctrl no-lock.
            run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
            if trim(v-asi-ip) <> ''
            and trim(v-asi-port) <> ''
            and trim(v-asi-type) <> ''
            then do :
              case v-asi-type :
                when "1"
                then do :
                  varcur-rvs = 2 .
                end.
                when "2"
                then do :
                  varcur-rvs = 3 .
                end.
              end case .
            end.
            else do :
              if ptoldfilvalue = "yes":U then do:
                run gbl/d-askw.w
                  ( input "Выбор источника данных с информацией по резервуарам"
                  ,input "Будем читать текущие данные с резервуаров или возьмем данные из файла?"
                  ,input "|^"
                  ,input "Текущие данные|Из файлов|Отмена"
                  ,input "Запускается программа для обращения к датчикам резервуаров|Берутся уже сохраненные данные из файла|Ничего не делаем"
                  ,input 1
                  ,input 3
                  ,output varnum
                  ) .
                case varnum :
                  when 1 then do:
                    assign
                      varcur-rvs = 1
                    .
                  end.
                  when 2  then do:
                    assign
                      varcur-rvs = 0
                    .
                  end.
                  when 3 then do:
                    return .
                  end.
                end case. /* varnum */
              end.
              else do:
                assign
                  varcur-rvs = 1
                .
              end.
            end.

            { str/rvsplace.i
              t-doc.obj-type
              t-doc.obj-code
              yes
              varcur-rvs
              yes
              no
              tt-meas-file
              tt-meas
              no-error
            }
            if error-status :error then do:
              message
                "Ошибка при получении данных с приборов на резервуарах." skip( 0 )
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
            
            if v-com-vessel-rvs
            then do :
              for each buf_rvs-line exclusive-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                                     and buf_rvs-line.obj-type = t-doc.obj-type
                                                     and buf_rvs-line.obj-code = t-doc.obj-code
                                                     and buf_rvs-line.gds-code = buf_goods.gds-code,
              first tt-meas where tt-meas.pl-code = buf_rvs-line.pl-code
              :
                { str/fill1plc.i
                  t-doc.obj-type
                  t-doc.obj-code
                  buf_rvs-line.pl-code
                  recid(buf_rvs-line)
                  buf_rvs-line.rvs-prev-code
                  tt-meas
                  no-error
                }
                if error-status :error then do:
                  message
                    "Ошибка при заполнении данных с приборов на резервуарах." skip( 0 )
                    return-value skip
                    error-status :get-message(1) skip
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
                
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-p" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-p"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-t" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-t"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                
                find first rvs-line-attr exclusive-lock
                     where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                       and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                       and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                       and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                       and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                       and rvs-line-attr.attr-code = "input-type-l" no-error.
                if not available rvs-line-attr then do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-l"
                  .
                end.
                if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
                
                release rvs-line-attr no-error .
    
                run cur-time in this-procedure
                  ( output v-today
                  , output v-time
                  ) .
                { gbl/curobjdt.i
                  t-doc.obj-type
                  t-doc.obj-code
                  v-today
                }
    
                assign
                  buf_rvs-line.real-date = v-today
                  buf_rvs-line.real-time = v-time
                .
                
                if p-rvs-type = {&rvs-before-doc}
                then do:
                  v-prt-start-real-date = buf_rvs-line.real-date .
                  v-prt-start-real-time = buf_rvs-line.real-time .
                end.
                else do:
                  v-prt-end-real-date = buf_rvs-line.real-date .
                  v-prt-end-real-time = buf_rvs-line.real-time .
                end.
                
                find first tt-pump-nozzle no-error .
                if available tt-pump-nozzle
                then do :
                  if varcur-rvs = 1
                  or ptoldfilvalue <> "yes":u
                  then do :
                    { str/anls-pmp.i
                      parParentProc
                      t-doc.obj-type
                      t-doc.obj-code
                      yes
                      tt-pump-nozzle-file
                      tt-pump-nozzle
                      yes
                      ?
                      no
                      no-error
                    }
                  end.
                  else do :
                    { str/anls-pmp.i
                      parParentProc
                      t-doc.obj-type
                      t-doc.obj-code
                      yes
                      tt-pump-nozzle-file
                      tt-pump-nozzle
                      no
                      ?
                      no
                      no-error
                    }
                  end.
                end .
                for each tt-pump-nozzle :
                  find first tt-pump-nozzle-file where
                             tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                             tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                             tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                             tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                  if available tt-pump-nozzle-file
                  then
                  assign
                    tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                    tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                    tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                  .
                end. /* for each tt-pump-nozzle */
/*                for each tt-pump-nozzle where not (tt-pump-nozzle.meas-el-cnt > 0) :                                                                      */
/*                  v-pump-err = v-pump-err + "ТРК " + string(tt-pump-nozzle.pump-code) + " Пистолету " + string(tt-pump-nozzle.nozzle-code) + {&new-line} .*/
/*                end. /* for each tt-pump-nozzle */                                                                                                        */
/*                if v-pump-err > ""                                                                                                                        */
/*                then do :                                                                                                                                 */
/*                  message "Данные по:" + {&new-line} + v-pump-err + "Не получены." view-as alert-box .                                                    */
/*                end .                                                                                                                                     */
                
                for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
                  { str/fill1pmp.i
                    "recid( buf_rvs-line-pump )"
                    tt-pump-nozzle
                  }
                end .
                for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                            and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                            and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                            and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                            and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
                  assign
                    buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                    buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                  .
                end .
              end .
            end .
            else do :
              { str/fill1plc.i
                t-doc.obj-type
                t-doc.obj-code
                p-pl-code
                recid(buf_rvs-line)
                buf_rvs-line.rvs-prev-code
                tt-meas
                no-error
              }
              if error-status :error then do:
                message
                  "Ошибка при заполнении данных с приборов на резервуарах." skip( 0 )
                  return-value skip
                  error-status :get-message(1) skip
                  view-as alert-box error .
                undo block_tr, return error .
              end.
            
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-p" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-p"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-t" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-t"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              
              find first rvs-line-attr exclusive-lock
                   where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                     and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                     and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                     and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                     and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                     and rvs-line-attr.attr-code = "input-type-l" no-error.
              if not available rvs-line-attr then do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "input-type-l"
                .
              end.
              if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
              else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              
              release rvs-line-attr no-error .
  
              run cur-time in this-procedure
                ( output v-today
                , output v-time
                ) .
              { gbl/curobjdt.i
                t-doc.obj-type
                t-doc.obj-code
                v-today
              }
  
              assign
                buf_rvs-line.real-date = v-today
                buf_rvs-line.real-time = v-time
              .
              
              find first tt-pump-nozzle no-error .
              if available tt-pump-nozzle
              then do :
                if varcur-rvs = 1
                or ptoldfilvalue <> "yes":u
                then do :
                  { str/anls-pmp.i
                    parParentProc
                    t-doc.obj-type
                    t-doc.obj-code
                    yes
                    tt-pump-nozzle-file
                    tt-pump-nozzle
                    yes
                    ?
                    no
                    no-error
                  }
                end.
                else do :
                  { str/anls-pmp.i
                    parParentProc
                    t-doc.obj-type
                    t-doc.obj-code
                    yes
                    tt-pump-nozzle-file
                    tt-pump-nozzle
                    no
                    ?
                    no
                    no-error
                  }
                end.
              end .
              for each tt-pump-nozzle :
                find first tt-pump-nozzle-file where
                           tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                           tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                           tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                           tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                if available tt-pump-nozzle-file
                then
                assign
                  tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                  tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                  tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                .
              end. /* for each tt-pump-nozzle */
/*              for each tt-pump-nozzle where not (tt-pump-nozzle.meas-el-cnt > 0) :                                                                      */
/*                v-pump-err = v-pump-err + "ТРК " + string(tt-pump-nozzle.pump-code) + " Пистолету " + string(tt-pump-nozzle.nozzle-code) + {&new-line} .*/
/*              end. /* for each tt-pump-nozzle */                                                                                                        */
/*              if v-pump-err > ""                                                                                                                        */
/*              then do :                                                                                                                                 */
/*                message "Данные по:" + {&new-line} + v-pump-err + "Не получены." view-as alert-box .                                                    */
/*              end .                                                                                                                                     */
              
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                { str/fill1pmp.i
                  "recid( buf_rvs-line-pump )"
                  tt-pump-nozzle
                }
              end .
              for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                          and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                          and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                          and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                          and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                assign
                  buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                  buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                .
              end .
            end .
            
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .
            infoSectionsTotal:CalculateTotal().
            if p-rvs-type = {&rvs-before-doc}  then do:
              v-prt-start-real-date = buf_rvs-line.real-date .
              v-prt-start-real-time = buf_rvs-line.real-time .
            end.
            else do:
              v-prt-end-real-date = buf_rvs-line.real-date .
              v-prt-end-real-time = buf_rvs-line.real-time .
            end.
          end.
          when "edit":U then do:
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .

            if not error-status :error 
               and is-gas(buf_goods.gds-code) then do:
               
                run str/rvs-lin-mask.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,p-pl-code)) no-error.
            end.
            
            else do:
              if available buf_goods
              and is-sug(buf_goods.gds-code) then do:
                 
                  run str/rvs-lin-sug.w
                    (input  parparentproc
                    ,input  recid( buf_rvs-line )
                    ,input  p-action
                    ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                      ,buf_rvs-doc.rvs-code
                                      ,buf_goods.artic
                                      ,buf_goods.prod-type
                                      ,buf_goods.prod-code
                                      ,p-pl-code)) no-error.
              end.
              else do :
                run str/rvs-lin.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,p-pl-code)) no-error.
              end.
              
              if error-status :error then do:
              message
                  "Ошибка при редактировании строки сверки." skip
                  return-value skip
                  error-status :get-message(1) skip
                  view-as alert-box error .
                undo block_tr, return error .
              end.
              if return-value = "cancel":U
                and p-action <> {&lookup}
              then do:
                undo block_tr, return error .
              end.
              
              if p-action <> {&lookup}
              then do :
                run cur-time in this-procedure
                  ( output v-today
                  , output v-time
                  ) .
    
                assign
                  buf_rvs-line.real-date = v-today
                  buf_rvs-line.real-time = v-time
                .
                infoSectionsTotal:CalculateTotal().
                if p-rvs-type = {&rvs-before-doc}  then do:
                  v-prt-start-real-date = buf_rvs-line.real-date .
                  v-prt-start-real-time = buf_rvs-line.real-time .
                end.
                else do:
                  v-prt-end-real-date = buf_rvs-line.real-date .
                  v-prt-end-real-time = buf_rvs-line.real-time .
                end.
                
                for each tt-pump-nozzle
                :
                  delete tt-pump-nozzle .
                end.
                
                for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = buf_rvs-line.obj-type 
                                                     and bf_pl-pump-nozzle.obj-code = buf_rvs-line.obj-code
                                                     and bf_pl-pump-nozzle.pl-code  = buf_rvs-line.pl-code,
                first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type 
                                               and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code 
                                               and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                               and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
  /*                                             and bf_pump-nozzle.is-meas     = yes*/
                :
                  create tt-pump-nozzle.
                  assign
                    tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
                    tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
                    tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                    tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
                    tt-pump-nozzle.gds-code    = buf_goods.gds-code
                  .
                end .
                
                find first tt-pump-nozzle no-error .
                if not available tt-pump-nozzle
                then do :
                  assign
                    varcur-rvs = 3
                    error-status:error = no
                  .
                end .
                else do :
                  if ptoldfilvalue = "yes":U then do:
                    run gbl/d-askw.w
                      ( input "Выбор источника данных с информацией по ТРК"
                      ,input "Будем читать текущие данные с ТРК или возьмем данные из файла?"
                      ,input "|^"
                      ,input "Текущие данные|Из файлов|Отмена"
                      ,input "Запускается программа для обращения к датчикам резервуаров|Берутся уже сохраненные данные из файла|Ничего не делаем"
                      ,input 1
                      ,input 3
                      ,output varnum
                      ) .
                    case varnum :
                      when 1 then do:
                        assign
                          varcur-rvs = 1
                        .
                      end.
                      when 2  then do:
                        assign
                          varcur-rvs = 0
                        .
                      end.
                      when 3 then do:
                        assign
                          varcur-rvs = 3
                        .
                      end.
                    end case. /* varnum */
                  end.
                  else do:
                    assign
                      varcur-rvs = 1
                    .
                  end.
                end .
                  
                if varcur-rvs <> 3
                then do :
                  if varcur-rvs = 1
                  or ptoldfilvalue <> "yes":u
                  then do :
                    { str/anls-pmp.i
                      parParentProc
                      t-doc.obj-type
                      t-doc.obj-code
                      yes
                      tt-pump-nozzle-file
                      tt-pump-nozzle
                      yes
                      ?
                      no
                      no-error
                    }
                  end.
                  else do :
                    { str/anls-pmp.i
                      parParentProc
                      t-doc.obj-type
                      t-doc.obj-code
                      yes
                      tt-pump-nozzle-file
                      tt-pump-nozzle
                      no
                      ?
                      no
                      no-error
                    }
                  end.
                  
                  for each tt-pump-nozzle :
                    find first tt-pump-nozzle-file where
                               tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
                               tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
                               tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
                               tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
                    if available tt-pump-nozzle-file
                    then
                    assign
                      tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
                      tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
                      tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
                    .
                  end. /* for each tt-pump-nozzle */
  /*                for each tt-pump-nozzle where not (tt-pump-nozzle.meas-el-cnt > 0) :                                                                      */
  /*                  v-pump-err = v-pump-err + "ТРК " + string(tt-pump-nozzle.pump-code) + " Пистолету " + string(tt-pump-nozzle.nozzle-code) + {&new-line} .*/
  /*                end. /* for each tt-pump-nozzle */                                                                                                        */
  /*                if v-pump-err > ""                                                                                                                        */
  /*                then do :                                                                                                                                 */
  /*                  message "Данные по:" + {&new-line} + v-pump-err + "Не получены." view-as alert-box .                                                    */
  /*                end .                                                                                                                                     */
                  
                  for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                       and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                       and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                       and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                       and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                  :
                    { str/fill1pmp.i
                      "recid( buf_rvs-line-pump )"
                      tt-pump-nozzle
                    }
                  end .
                end .
                
                for each buf_rvs-line-pump exclusive-lock where buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                            and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                            and buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                            and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                            and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
                :
                  assign
                    buf_rvs-line-pump.state-el-cnt    = 0 when buf_rvs-line-pump.state-el-cnt = ?
                    buf_rvs-line-pump.state-mh-cnt    = 0 when buf_rvs-line-pump.state-mh-cnt = ?
                  .
                end .
              end .
            end.
            
            if error-status :error then do:
              message
                "Ошибка при редактировании строки сверки." skip
                return-value skip
                error-status :get-message(1) skip
                view-as alert-box error .
              undo block_tr, return error .
            end.
            if return-value = "cancel":U
              and p-action <> {&lookup}
            then do:
              undo block_tr, return error .
            end.
          end.
        end case.
         
         
        if not p-action = {&lookup}
        then do : 
          find first buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = p-pl-code
            .
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp(ii).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> buf_place.loc1 then next .
            
            if p-rvs-type = {&rvs-before-doc}
            then do:
              infoSectionsTotal:InfoSectionCurr:DateStart = v-prt-start-real-date .
              infoSectionsTotal:InfoSectionCurr:TimeStart = v-prt-start-real-time . 
            end .
            else do :
              infoSectionsTotal:InfoSectionCurr:DateEnd   = v-prt-end-real-date .
              infoSectionsTotal:InfoSectionCurr:TimeEnd   = v-prt-end-real-time .
            end .
            infoSectionsTotal:InfoSectionCurr:TankWeightRvs = ? .
            infoSectionsTotal:InfoSectionCurr:TankVolPomiRvs = ? .
            infoSectionsTotal:InfoSectionCurr:AvgTempRvs = ? .
          end.
        infoSectionsTotal:SaveDB().
        end .
        
        run placelib_get-attr(input {&place-virtual}
                             ,input t-doc.obj-code
                             ,input t-doc.obj-type
                             ,input p-pl-code
                             ,output v-value
                             ,output v-ok) no-error.
        
        is-vir = if (v-ok and logical(v-value)) then true else false.
        
        if not is-gas(buf_goods.gds-code)
        and not is-vir then do:
            if not available buf_rvs-line
            then do :
              find first buf_rvs-line exclusive-lock
              where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                and buf_rvs-line.obj-type = t-doc.obj-type
                and buf_rvs-line.obj-code = t-doc.obj-code
                and buf_rvs-line.pl-code  = p-pl-code
                and buf_rvs-line.gds-code = buf_goods.gds-code
              .
            end .
            
            if p-action = {&update} then do:
              if p-action-type = "meas":U then do:
                { str/rvsclcln.i
                  recid(buf_rvs-line)
                  no-error
                }
                if error-status :error then do:
                  message
                    "Ошибка при пересчете строки документа сверки." skip
                    return-value skip
                    error-status :get-message(1) skip
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
              end.
    
              { str/rvsclchd.i
                recid(buf_rvs-doc)
                false
                no-error
              }
              if error-status :error then do:
                message
                  "Ошибка при пересчете документа сверки." skip
                  return-value skip
                  error-status :get-message(1) skip
                  view-as alert-box error .
                undo block_tr, return error .
              end.
    
              run return-rvs-qnty in this-procedure
                ( input t-doc.doc-code
                 ,input buf_goods.gds-code
                 ,input p-pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                 ,output v-delta-mass-qnty
                 ,output v-trk-err
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error return-value .
              end.
              
              run placelib_get-attr  (
                 input {&place-com-tanks}
                ,input t-doc.obj-code
                ,input t-doc.obj-type
                ,input p-pl-code
                ,output v-value
                ,output v-ok      )
              no-error.
              if v-ok
              and v-value > ""
              then do :
                do ii = 1 to num-entries(v-value) :
                  find first buf_place no-lock where buf_place.obj-type = t-doc.obj-type
                                                 and buf_place.obj-code = t-doc.obj-code
                                                 and buf_place.loc1     = entry(ii, v-value)
                                                 and buf_place.status_  = ""
                                                 no-error .
                  if available buf_place
                  then do :
                    run return-rvs-qnty in this-procedure
                      ( input t-doc.doc-code
                       ,input buf_goods.gds-code
                       ,input buf_place.pl-code
                       ,output v-com-tank-rvs-qnty-before
                       ,output v-com-tank-rvs-qnty-after
                       ,output v-com-tank-rvs-cli-qnty-before
                       ,output v-com-tank-rvs-cli-qnty-after
                       ,output v-com-tank-delta-mass-qnty
                       ,output v-trk-err
                      ) no-error .
                    if error-status :error then do:
                      undo block_tr, return error return-value .
                    end.
                    if v-com-tank-rvs-qnty-after = ?
                    then do :
                      assign
                        v-com-tank-rvs-qnty-after = 0
                        v-com-tank-rvs-cli-qnty-after = 0
                        v-com-tanks-not-filled = yes
                      .
                    end .
                    assign
                      v-rvs-qnty-before     = v-rvs-qnty-before     + v-com-tank-rvs-qnty-before
                      v-rvs-qnty-after      = v-rvs-qnty-after      + v-com-tank-rvs-qnty-after
                      v-rvs-cli-qnty-before = v-rvs-cli-qnty-before + v-com-tank-rvs-cli-qnty-before
                      v-rvs-cli-qnty-after  = v-rvs-cli-qnty-after  + v-com-tank-rvs-cli-qnty-after
                    .
                  end.
                end .
              end .
              
              if p-rvs-type = {&rvs-after-doc} then do:
                if v-rvs-qnty-after = ?
                  or v-rvs-qnty-after = 0
                then do:
                  message
                    "Не задано количество по сверке <<после_док>>"
                    "по резервуару" p-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after = ?
                  or v-rvs-cli-qnty-after = 0
                then do:
                  if is-sug(buf_goods.gds-code)
                  then do :
                    message
                      "Не задана масса в сверке <<после_док>>"
                      "по резервуару" p-pl-code "."
                      view-as alert-box error .
                  end.
                  else do :
                    /* ругаемся на плотность потому что в строке редактирования сверки у нас открыто поле плотность */
                    message
                      "Масса не рассчитана. Не задана плотность в сверке <<после_док>>"
                      "по резервуару" p-pl-code "."
                      view-as alert-box error .
                  end.
                  undo block_tr, return error .
                end.
              end.
    
              if v-rvs-qnty-after <> ?
              and v-rvs-qnty-after <> 0
              and not v-com-tanks-not-filled
              then do:
                if v-rvs-qnty-after - v-rvs-qnty-before <= 0
                  or v-rvs-qnty-after - v-rvs-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", p-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-qnty-after - v-rvs-qnty-before, buf_goods.unit-base ) skip
                    substitute( "Объем в сверке до: &1 ", v-rvs-qnty-before ) skip
                    substitute( "Объем в сверке после: &1 ", v-rvs-qnty-after ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after - v-rvs-cli-qnty-before <= 0
                  or v-rvs-cli-qnty-after - v-rvs-cli-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", p-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-cli-qnty-after - v-rvs-cli-qnty-before, buf_goods.unit-cli ) skip
                    substitute( "Масса в сверке до: &1 ", v-rvs-cli-qnty-before ) skip
                    substitute( "Масса в сверке после: &1 ", v-rvs-cli-qnty-after ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
    
                if not is-sug(buf_goods.gds-code)
                then do :
                  assign
                    v-rvs-density = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before) / (v-rvs-qnty-after - v-rvs-qnty-before)
                  .
                  if Valid-Density( v-rvs-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
                    message
                      substitute( "Ошибка по результатам сверки." ) skip
                      substitute( "Место хранения: &1 .", p-pl-code ) skip
                      substitute( "Плотность залитого топлива: &1.", v-rvs-density ) skip
                      view-as alert-box .
                    undo block_tr, return error .
                  end.
                end.
                
                if is-sug(buf_goods.gds-code) then 
                do:
                  def var dmdop as decimal no-undo.
                  def var dM    as decimal no-undo.
                  
                  define variable v-value-character as character no-undo .
                  define variable v-value-date as date no-undo .
                  define variable v-value-integer as integer no-undo .
                  define variable v-value-logical as logical no-undo .
                  define variable v-param-type as character no-undo .
                  define variable v-tth as handle no-undo .
                  
                  def var v-cardifLgas as decimal no-undo.
                  def var infoSectionObj as class infosection no-undo.
                  
                  find first buf_doc-line no-lock where buf_doc-line.doc-code = t-doc.doc-code
                      and buf_goods.artic = buf_doc-line.artic
                      and buf_goods.prod-type = buf_doc-line.prod-type
                      and buf_goods.prod-code = buf_doc-line.prod-code no-error.
                  
                  run adm/shattri.p (
                      input "get":U
                      ,input  buf_doc-line.obj-type
                      ,input  buf_doc-line.obj-code
                      ,input  {&attr-petrol}
                      ,input  {&attr-petrol_CriticalDifInLgas} /*p-param-code*/
                      ,output v-value-character
                      ,output v-value-date
                      ,output v-cardifLgas
                      ,output v-value-integer
                      ,output v-value-logical
                      ,output v-param-type
                      ,INPUT-OUTPUT table-handle v-tth
                  ) no-error .
                  if v-cardifLgas = ?
                    then v-cardifLgas = 0.
                  
                  dM = buf_doc-line.cli-qnty - (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before).
                  dmdop = SQRT ((v-rvs-cli-qnty-after *  v-cardifLgas) * (v-rvs-cli-qnty-after *  v-cardifLgas) + (v-rvs-cli-qnty-before *  v-cardifLgas) * (v-rvs-cli-qnty-before *  v-cardifLgas)) / 100.
/*                  message "dM - " dM "dmdop - " dmdop "v-rvs-cli-qnty-before - " v-rvs-cli-qnty-before "v-rvs-cli-qnty-after - " v-rvs-cli-qnty-after view-as alert-box.*/
                  if absolute (dM) <= dmdop  
                  then do:
                    infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
                    infoSectionObj:AccPOMI = dmdop.
                    infoSectionObj:FactKgQnty = buf_doc-line.doc-qnty * buf_doc-line.doc-density.
                    infoSectionObj:FactQnty = (v-rvs-qnty-after - v-rvs-qnty-before).
                    infoSectionObj:FactDensity = infoSectionObj:FactKgQnty / infoSectionObj:FactQnty.
                    infoSectionsTotal:SaveDB().
                    run correct-fact-qnty in this-procedure
                      ( input buf_doc-line.doc-qnty
                       ,input buf_doc-line.doc-density
                      ) no-error .
                  end.
                  else do:
                    infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
                    infoSectionObj:FactKgQnty = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before).
                    infoSectionObj:FactQnty = (v-rvs-qnty-after - v-rvs-qnty-before).
                    infoSectionObj:FactDensity = infoSectionObj:FactKgQnty / infoSectionObj:FactQnty.
                    infoSectionsTotal:SaveDB().
                    run correct-fact-qnty in this-procedure
                      ( input infoSectionObj:FactQnty
                       ,input infoSectionObj:FactDensity
                      ) no-error.
                    message
                      substitute( "По результатам слива Газовоза фактическое кол-во товара изменяется на &1 (&2),", infoSectionObj:FactQnty, buf_goods.unit-base ) skip
                      substitute( "фактическая плотность на &1.", infoSectionObj:FactDensity ) skip
                      view-as alert-box information
                    .
                    run save-action in this-procedure
                      ( input "hard":U
                      ) no-error .
                    if error-status :error then do:
                      message return-value view-as alert-box error .
                      undo block_tr, return error .
                    end.
                  end.
                end.
                
              end. /* v-rvs-qnty-after <> ? */
            end.
        end.
      end. /* on error */
    end procedure. /* action-rvs-line */

    procedure proc-b-addinfo :

      define input        parameter parParentProc          as   handle                   no-undo .
      define input        parameter p-mode                 as   character                no-undo .
      define input        parameter p-doc-code             like ub.doc-line.doc-code     no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-stfactplvalue        as   character                no-undo .
      define input        parameter p-auto-tank            as   logical                  no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input        parameter p-doc-qnty             like ub.doc-line.doc-qnty     no-undo .
      define input        parameter p-doc-density          like ub.doc-line.doc-density  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-infoSectionsTotal    as class InfoSectionsTotal    no-undo .
      define input-output parameter p-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
      do
      on error  undo, return error substitute( "&1 (proc-b-addinfo). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (proc-b-addinfo). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (proc-b-addinfo). endkey", vss-workfile )
      :
        define buffer buf_rvs-doc  for ub.rvs-doc   .
        define buffer buf_rvs-line for ub.rvs-line  .
        define buffer buf_goods    for ub.goods .

        define variable v-new-fact-qnty     like ub.doc-line.fact-qnty    no-undo .
        define variable v-new-density       like ub.doc-line.fact-density no-undo .
        define variable v-new-cli-fact-qnty like ub.doc-line.fact-qnty    no-undo .
        define variable v-chg               as   logical                  no-undo .
        define variable v-log               as   logical                  no-undo .
        define variable v-st-doc            as   logical                  no-undo .
        define variable v-setting           as   logical                  no-undo .
        define variable v-need-message      as   logical                  no-undo init yes .

        block_tr:
        do transaction
        on error  undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo block_tr, return error substitute( "&1. stop", vss-workfile )
        on endkey undo block_tr, return error substitute( "&1. endkey", vss-workfile )
        :


          find first buf_goods no-lock
            where buf_goods.gds-code = p-gds-code
            .
          p-infoSectionsTotal:CalculateTotal().
          if p-prt-start-real-date = ?
            or p-prt-start-real-time = ?
          then do:
            find first buf_rvs-doc
              where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                and buf_rvs-doc.out-code = p-doc-code
              no-error .
            if available buf_rvs-doc then do:
              for each buf_rvs-line
                where buf_rvs-line.gds-code = p-gds-code
                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-type
                  and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              on error undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
                if buf_rvs-line.real-date <> ?
                  and buf_rvs-line.real-time <> ?
                  and ( p-prt-start-real-date > buf_rvs-line.real-date
                        or ( p-prt-start-real-date = buf_rvs-line.real-date
                            and p-prt-start-real-time > buf_rvs-line.real-time
                          )
                      )
                then do:
                  assign
                    p-prt-start-real-date = buf_rvs-line.real-date
                    p-prt-start-real-time = buf_rvs-line.real-time
                  .
                end.
              end.
            end.
          end.
          if p-prt-end-real-date = ?
            or p-prt-end-real-time = ?
          then do:
            find first buf_rvs-doc
              where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                and buf_rvs-doc.out-code = p-doc-code
              no-error .
            if available buf_rvs-doc then do:
              for each buf_rvs-line
                where buf_rvs-line.gds-code = p-gds-code
                  and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                  and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              on error undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
              :
                if buf_rvs-line.real-date <> ?
                  and buf_rvs-line.real-time <> ?
                  and ( p-prt-end-real-date < buf_rvs-line.real-date
                        or ( p-prt-end-real-date = buf_rvs-line.real-date
                            and p-prt-end-real-time < buf_rvs-line.real-time
                          )
                      )
                then do:
                  assign
                    p-prt-end-real-date = buf_rvs-line.real-date
                    p-prt-end-real-time = buf_rvs-line.real-time
                  .
                end.
              end.
            end.
          end.
          tanksForm = new ibs.th.str.ptrl.forms.tanksections(infoSectionsTotal).
          wait-for tanksForm:ShowDialog().
          
          
/*          run str/in-ladd.w
            ( input        parParentProc
             ,input        p-mode
             ,input        p-doc-code
             ,input        p-gds-code
             ,input-output p-infoSectionsTotal
             ,output v-setting
            ) no-error .
          if error-status :error then do:
            undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
          end.*/
          
          def var ii as int no-undo.
          def var infoSectionObj as class InfoSection no-undo.

          if p-infoSectionsTotal:RdcDnstvalue = 'not'
          then do:

            
            do ii = 1 to p-infoSectionsTotal:SectionNum :
              infoSectionObj = p-infoSectionsTotal:GetInfoSectionProp(ii).
              if p-mode ne {&lookup}
              then do:
                 infoSectionObj:FactQnty = infoSectionObj:TankVol.
                 infoSectionObj:FactDensity = infoSectionObj:TankDensity.
                 p-infoSectionsTotal:SaveDb().
              end.
              p-infoSectionsTotal:GetDBAllAttr().
              p-infoSectionsTotal:CalculateTotal().
            end.
          end.

          if p-infoSectionsTotal:WasSetting = false then p-infoSectionsTotal:GetDBAllAttr().

            if p-infoSectionsTotal:WasSetting = true
              and p-mode <> {&lookup}
              and p-stfactplvalue <> "":U
              and (p-auto-tank = true or p-infoSectionsTotal:IsRNAlgo)
              then 
            do:
              assign
                v-new-fact-qnty = p-new-fact-qnty
                .

            do ii = 1 to p-infoSectionsTotal:SectionNum : 

              define variable v-calc-density like ub.rvs-line.state-density no-undo .
              define variable v-new-sec-fact-qnty         as decimal no-undo.
              define variable v-new-sec-fact-qnty-kg      as decimal no-undo.
              define variable v-chg-temp                  as logical no-undo.
              define variable v-st-doc-temp               as logical no-undo.
              define variable v-rvs-sec-qnty-before       as decimal no-undo.
              define variable v-rvs-sec-qnty-after        as decimal no-undo.
              define variable v-rvs-sec-cli-qnty-before   as decimal no-undo.
              define variable v-rvs-sec-cli-qnty-after    as decimal no-undo.
              
              infoSectionObj = p-infoSectionsTotal:GetInfoSectionProp(ii).
                            
              v-new-sec-fact-qnty = if infoSectionObj:FactQnty = 0 or infoSectionObj:FactQnty = ? then infoSectionObj:DocQnty else infoSectionObj:FactQnty.
              v-calc-density = ? .
              if infoSectionObj:TankWeight > 0
              and infoSectionObj:TankVol > 0 
              then
                v-calc-density = infoSectionObj:TankWeight / infoSectionObj:TankVol
              .
              if infoSectionObj:AccMeth = 1
              and infoSectionObj:TankWeightRvs > 0 
              and infoSectionObj:TankVolPomiRvs > 0 
              then
                v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs
              .
              
              
              if not p-infoSectionsTotal:IsSGDKK
              then do :
                if p-infoSectionsTotal:IsRNAlgo
                then do:
                  assign
                    v-calc-density = infoSectionObj:TankDensityPomi when not p-infoSectionsTotal:RdcDnstvalue = 'not'
                    v-calc-density = infoSectionObj:TankDensity when p-infoSectionsTotal:RdcDnstvalue = 'not'
                  .
                  if infoSectionObj:AccMeth = 1
                  then do :
                    assign v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs .
                  end .
                  if (v-calc-density = ? or v-calc-density <= 0 or v-calc-density > 1)
                  and infoSectionObj:KPnoMeas
                  then do :
                    assign v-need-message = no .
                  end .
                  p-infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).
                  if v-new-sec-fact-qnty-kg <> infoSectionObj:DocQnty * infoSectionObj:DocDensity
                  then do:
                    v-new-sec-fact-qnty = v-new-sec-fact-qnty-kg / v-calc-density.
                    v-chg-temp = true.
                    v-st-doc-temp = false.
                  end.
                  else do:
                    v-st-doc-temp = true.
                    v-chg-temp = false.
                  end.
                end.
                else do:
                  { str/stfactqt.i
                    p-stfactplvalue
                    infoSectionObj:DocQnty
                    infoSectionObj:DocDensity
                    0.00
                    0.00
                    infoSectionObj:TankVol
                    v-calc-density            
                    no
                    v-new-sec-fact-qnty
                    v-chg-temp
                    v-st-doc-temp
                    no-error
                  }
                  if error-status :error then do:
                    undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
                  end.
                end.
              end .
              else do :  /* p-infoSectionsTotal:IsSGDKK */
                if infoSectionObj:IsKP
                then do :
                  if p-infoSectionsTotal:IsRNAlgo
                  then do:
                    assign
                      v-calc-density = infoSectionObj:TankDensityPomi when not p-infoSectionsTotal:RdcDnstvalue = 'not'
                      v-calc-density = infoSectionObj:TankDensity when p-infoSectionsTotal:RdcDnstvalue = 'not'
                    .
                    if infoSectionObj:AccMeth = 1
                    then do :
                      assign v-calc-density = infoSectionObj:TankWeightRvs / infoSectionObj:TankVolPomiRvs .
                    end .
                    if (v-calc-density = ? or v-calc-density <= 0 or v-calc-density > 1)
                    and infoSectionObj:Alarm-SGDKK
                    then do :
                      assign v-need-message = no .
                    end .
                    p-infoSectionsTotal:RNAlgo (integer(infoSectionObj:SectionName), output v-new-sec-fact-qnty-kg).
                    if v-new-sec-fact-qnty-kg <> infoSectionObj:DocQnty * infoSectionObj:DocDensity
                    then do:
                      v-new-sec-fact-qnty = v-new-sec-fact-qnty-kg / v-calc-density.
                      v-chg-temp = true.
                      v-st-doc-temp = false.
                    end.
                    else do:
                      v-st-doc-temp = true.
                      v-chg-temp = false.
                    end.
                  end.
                  else do:
                    { str/stfactqt.i
                      p-stfactplvalue
                      infoSectionObj:DocQnty
                      infoSectionObj:DocDensity
                      0.00
                      0.00
                      infoSectionObj:TankVol
                      v-calc-density            
                      no
                      v-new-sec-fact-qnty
                      v-chg-temp
                      v-st-doc-temp
                      no-error
                    }
                    if error-status :error then do:
                      undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
                    end.
                  end.
                end .
                else do :
                  p-infoSectionsTotal:CalcTP() .
                  v-st-doc-temp = true.
                  v-chg-temp = false.
                end .
              end .
              
              if v-chg-temp
              then do:
                infoSectionObj:FactQnty = v-new-sec-fact-qnty.
                v-chg = v-chg-temp.
                if v-st-doc-temp 
                then do:
                  infoSectionObj:FactDensity = infoSectionObj:DocDensity.
                  v-st-doc = v-st-doc-temp.
                end.
                else do:
                  infoSectionObj:FactDensity = v-calc-density.
                end.
              end.
              else do:
                infoSectionObj:FactQnty = infoSectionObj:DocQnty.
                infoSectionObj:FactDensity = infoSectionObj:DocDensity.                
              end.
            
            end.
            if p-mode ne {&lookup}
            then
               p-infoSectionsTotal:SaveDb().
            p-infoSectionsTotal:GetDBAllAttr().
            p-infoSectionsTotal:CalculateTotal().
            
            v-calc-density = p-infoSectionsTotal:FactKgQntyTotal / p-infoSectionsTotal:FactQntyTotal.
            v-new-fact-qnty = p-infoSectionsTotal:FactQntyTotal.
            
            if p-new-fact-qnty <> v-new-fact-qnty
            and absolute(p-new-fact-qnty - v-new-fact-qnty) < 0.0011
            then do :
              p-infoSectionsTotal:FactQntyTotal = p-new-fact-qnty .
              v-new-fact-qnty = p-infoSectionsTotal:FactQntyTotal .
              v-calc-density = p-new-density .
              p-infoSectionsTotal:FactKgQntyTotal = p-infoSectionsTotal:FactQntyTotal * v-calc-density .
            end .
            
            if (absolute (v-calc-density - p-new-density ) > 0.0000000001
              or absolute (p-infoSectionsTotal:FactQntyTotal - p-new-fact-qnty ) > 0.001)
              or ((v-calc-density = ? and p-new-density <> ?) or (p-infoSectionsTotal:FactQntyTotal = ? and p-new-fact-qnty <> ?))  
            then do:
              v-chg =  yes.
            end.
            
            
            if v-calc-density = ?
            and not infoSectionsTotal:isFlagKPChg
            then do:
/*              if v-need-message                                            */
/*              then do :                                                    */
/*                message                                                    */
/*                  substitute( "Невозможно рассчитать фактическое кол-во." )*/
/*                  view-as alert-box warning.                               */
/*              end .                                                        */
              return.
            end.
            
            if (p-new-fact-qnty <> v-new-fact-qnty
              or v-chg       =  yes
              or v-st-doc    =  yes) and not infoSectionsTotal:isFlagKPChg
            then do:
              assign
                v-new-density = v-calc-density
                v-log         = yes
              .
              if v-new-fact-qnty <> p-new-fact-qnty
                or v-new-density <> p-new-density
              then do:
                if p-fact-edit = true then do:
                  if infoSectionsTotal:isKPrvs
                  then do :
                    message
                      substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
                      substitute( "Будем менять фактические" ) skip
                      substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "плотность на &1 ?", v-new-density ) skip
                    view-as alert-box question buttons yes-no update v-log .
                  end .
                  else do :
                    message
                      substitute( "По результатам измерения автоцистерны фактическое кол-во необходимо изменить." ) skip
                      substitute( "Будем менять фактические" ) skip
                      substitute( "количество на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "плотность на &1 ?", v-new-density ) skip
                    view-as alert-box question buttons yes-no update v-log .
                  end .  
                end.
                else do:
                  if infoSectionsTotal:isKPrvs
                  then do :
                    message
                      substitute( "По результатам измерения в резервуаре фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "фактическая плотность на &1.", v-new-density ) skip
                    view-as alert-box information .
                  end .
                  else do :
                    message
                      substitute( "По результатам измерения автоцистерны фактическое кол-во товара изменяется на &1 (&2),", (v-new-fact-qnty * v-new-density), "кг" ) skip
                      substitute( "фактическая плотность на &1.", v-new-density ) skip
                    view-as alert-box information .
                  end .
                end.
              end.
              if v-log = yes then do:
                assign
                  p-new-fact-qnty     = v-new-fact-qnty
                  p-new-density       = v-new-density
                  p-new-cli-fact-qnty = p-new-fact-qnty * p-new-density
                .
              end.
            end.
          end.
        end.
      end.

    end procedure. /* proc-b-addinfo */

    procedure chkdcrvs :
      define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
      define input  parameter p-gds-code like ub.goods.gds-code   no-undo .
      define output parameter p-ok       as   logical             no-undo .

      do
      on error undo, return error return-value
      :
        define variable v-found as logical no-undo .       
        
        define buffer buf-before_rvs-doc  for ub.rvs-doc  .
        define buffer buf-before_rvs-line for ub.rvs-line .
        define buffer buf-after_rvs-doc   for ub.rvs-doc  .
        define buffer buf-after_rvs-line  for ub.rvs-line .
        assign
          p-ok = false
        .
        find first tt-doc-pl no-lock
          no-error .
        if not available tt-doc-pl then do:
          return error substitute( 'Документ "&1", товар &2: нет разбивки по местам хранения.', p-doc-code, p-gds-code ) .
        end.
        find first buf-before_rvs-doc no-lock
          where buf-before_rvs-doc.rvs-type = {&rvs-before-doc}
            and buf-before_rvs-doc.out-code = p-doc-code
          no-error .
        if not available buf-before_rvs-doc then do:
          return substitute( 'По документу "&1" нет сверки <<до налива топлива>>.', p-doc-code ).
        end.
        find first buf-after_rvs-doc no-lock
          where buf-after_rvs-doc.rvs-type = {&rvs-after-doc}
            and buf-after_rvs-doc.out-code = p-doc-code
          no-error .
        if not available buf-after_rvs-doc then do:
          return substitute( 'По документу "&1" нет сверки <<после налива топлива>>.', p-doc-code ).
        end.
        for each tt-doc-pl no-lock
        on error undo, return error return-value
        :

          find first buf-before_rvs-line no-lock
            where buf-before_rvs-line.rvs-code = buf-before_rvs-doc.rvs-code
              and buf-before_rvs-line.obj-type = buf-before_rvs-doc.obj-type
              and buf-before_rvs-line.obj-code = buf-before_rvs-doc.obj-code
              and buf-before_rvs-line.pl-code  = tt-doc-pl.pl-code
              and buf-before_rvs-line.gds-code = tt-doc-pl.gds-code
            no-error .
          if not available buf-before_rvs-line then do:
            assign v-found = no .
            for each buf-before_rvs-doc no-lock
              where buf-before_rvs-doc.rvs-type = {&rvs-before-doc}
                and buf-before_rvs-doc.out-code = p-doc-code
            :
              find first buf-before_rvs-line no-lock
                where buf-before_rvs-line.rvs-code = buf-before_rvs-doc.rvs-code
                  and buf-before_rvs-line.obj-type = buf-before_rvs-doc.obj-type
                  and buf-before_rvs-line.obj-code = buf-before_rvs-doc.obj-code
                  and buf-before_rvs-line.pl-code  = tt-doc-pl.pl-code
                  and buf-before_rvs-line.gds-code = tt-doc-pl.gds-code
                no-error .
              if available buf-before_rvs-line
              then do :
                assign v-found = yes .
                leave .
              end .
            end .
            if not v-found 
            then
            return substitute( 'По документу "&1" для товара &2 на месте хранения &3 нет строки сверки <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                             ).
          end.
          find first buf-after_rvs-line no-lock
            where buf-after_rvs-line.rvs-code = buf-after_rvs-doc.rvs-code
              and buf-after_rvs-line.obj-type = buf-after_rvs-doc.obj-type
              and buf-after_rvs-line.obj-code = buf-after_rvs-doc.obj-code
              and buf-after_rvs-line.pl-code  = tt-doc-pl.pl-code
              and buf-after_rvs-line.gds-code = tt-doc-pl.gds-code
            no-error .
          if not available buf-after_rvs-line then do:
            assign v-found = no .
            for each buf-after_rvs-doc no-lock
              where buf-after_rvs-doc.rvs-type = {&rvs-after-doc}
                and buf-after_rvs-doc.out-code = p-doc-code
            :
              find first buf-after_rvs-line no-lock
                where buf-after_rvs-line.rvs-code = buf-after_rvs-doc.rvs-code
                  and buf-after_rvs-line.obj-type = buf-after_rvs-doc.obj-type
                  and buf-after_rvs-line.obj-code = buf-after_rvs-doc.obj-code
                  and buf-after_rvs-line.pl-code  = tt-doc-pl.pl-code
                  and buf-after_rvs-line.gds-code = tt-doc-pl.gds-code
                no-error .
              if available buf-after_rvs-line
              then do :
                assign v-found = yes .
                leave .
              end .
            end .
            if not v-found 
            then
            return substitute( 'По документу "&1" для товара &2 на месте хранения &3 нет строки сверки <<после налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                             ).
          end.

          if is-gas(buf-after_rvs-line.gds-code) then next.
          
          run placelib_get-attr(input {&place-virtual}
                                 ,input buf-after_rvs-line.obj-code
                                 ,input buf-after_rvs-line.obj-type
                                 ,input buf-after_rvs-line.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
        
          is-vir = if (v-ok and logical(v-value)) then true else false.
          
          if is-vir then next.
          
          if buf-before_rvs-line.state-measure-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                               ,{&new-line}
                               ,buf_goods.unit-base
                             ).
          end.
          if buf-before_rvs-line.state-measure-cli-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<до налива топлива>>.'
                               ,p-doc-code
                               ,p-gds-code
                               ,tt-doc-pl.pl-code
                               ,{&new-line}
                               ,buf_goods.unit-cli
                             ).
          end.
          if buf-before_rvs-line.state-density = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задана плотность в сверке <<до налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,{&new-line}
                                  ).
          end.
          if buf-after_rvs-line.state-measure-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,{&new-line}
                                    ,buf_goods.unit-base
                                  ).
          end.
          if buf-after_rvs-line.state-measure-cli-qnty = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задан фактический остаток (&5) в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,{&new-line}
                                    ,buf_goods.unit-cli
                                  ).
          end.
          if buf-after_rvs-line.state-density = ? then do:
            return substitute( 'Документ "&1", товар &2, резервуар &3.&4Не задана плотность в сверке <<после налива топлива>>.'
                                    ,p-doc-code
                                    ,p-gds-code
                                    ,tt-doc-pl.pl-code
                                    ,{&new-line}
                                  ).
          end.
        end. /* for each tt-doc-pl */
        assign
          p-ok = true
        .
      end. /* on error */
    end procedure. /* chkdcrvs */

    procedure local-state-fact-rvs :

      define input        parameter p-doc-code             like ub.trn-doc.doc-code      no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-stfactplvalue        as   character                no-undo .
      define input        parameter p-revision             as   logical                  no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input        parameter p-doc-qnty             like ub.doc-line.doc-qnty     no-undo .
      define input        parameter p-doc-density          like ub.doc-line.doc-density  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .

      do
      on error undo, return error return-value
      :
        define variable v-new-fact-qnty       like ub.doc-line.fact-qnty              no-undo .
        define variable v-new-density         like ub.doc-line.doc-density            no-undo .
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-log                 as   logical                            no-undo .
        define variable v-chg                 as   logical                            no-undo .
        define variable v-st-doc              as   logical                            no-undo .
        define variable v-delta-mass-qnty as decimal   no-undo .
        define variable v-trk-err         as logical   no-undo .
        
        if p-stfactplvalue <> "":U
          and p-revision = true
        then do:
          assign
            v-new-fact-qnty = p-new-fact-qnty
          .
          run return-rvs-qnty in this-procedure
            (  input p-doc-code
              ,input p-gds-code
              ,input ?
              ,output v-rvs-qnty-before
              ,output v-rvs-qnty-after
              ,output v-rvs-cli-qnty-before
              ,output v-rvs-cli-qnty-after
              ,output v-delta-mass-qnty
              ,output v-trk-err
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.

          assign
            v-new-density = ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before ) / ( v-rvs-qnty-after - v-rvs-qnty-before )
          .
          { str/stfactqt.i
            p-stfactplvalue
            p-doc-qnty
            p-doc-density
            v-rvs-qnty-before
            v-rvs-qnty-after
            0.00
            0.00
            no
            v-new-fact-qnty
            v-chg
            v-st-doc
            no-error
          }
          if error-status :error then do:
            return error return-value .
          end.

          if v-new-fact-qnty <> p-new-fact-qnty
            or v-chg = true
            or v-st-doc = true
          then do:
            if v-st-doc = true
              or v-new-density = ?
            then do:
              assign
                v-new-density = p-doc-density
              .
            end.

            if v-new-fact-qnty <> p-new-fact-qnty
              or v-new-density <> p-new-density
            then do:
              assign
                v-log = true
              .

              if p-fact-edit = true then do:
                message
                  substitute( "По результатам измерения в резервуаре фактическое кол-во необходимо изменить." ) skip
                  substitute( "Будем менять фактические" ) skip
                  substitute( "количество на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                  substitute( "плотность на &1 ?", v-new-density ) skip
                  view-as alert-box question buttons yes-no update v-log .
              end.
              else do:
                message
                  substitute( "По результатам измерения фактическое кол-во товара изменяется на &1 (&2),", v-new-fact-qnty, buf_goods.unit-base ) skip
                  substitute( "фактическая плотность на &1.", v-new-density ) skip
                  view-as alert-box information .
              end.

              if v-log = true then do:
                assign
                  p-new-fact-qnty     = v-new-fact-qnty
                  p-new-density       = v-new-density
                  p-new-cli-fact-qnty = p-new-fact-qnty * p-new-density
                .
              end.
            end.
          end. /* v-fact-qnty <> v-newfact-qnty or v-chg = yes */
        end.
      end. /* on error */
    end procedure. /* local-state-fact-rvs */

    procedure eq-qnty-rvs-pl :

      define input        parameter p-doc-code             like ub.trn-doc.doc-code      no-undo .
      define input        parameter p-gds-code             like ub.goods.gds-code        no-undo .
      define input        parameter p-fact-edit            as   logical                  no-undo .
      define input-output parameter p-new-fact-qnty        like ub.doc-line.fact-qnty    no-undo .
      define input-output parameter p-new-density          like ub.doc-line.fact-density no-undo .
      define input-output parameter p-new-cli-fact-qnty    like ub.doc-line.fact-qnty    no-undo .
      define output       parameter p-ok                   as   logical                  no-undo .

      do
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :

        define buffer buf-after_rvs-doc   for ub.rvs-doc  .
        define buffer buf_place           for ub.place .
        
        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .

        define variable v-count-pl      as integer   no-undo .
        define variable v-message       as character no-undo .
        define variable v-tot-qnty-pl   as decimal   no-undo .
        define variable v-tot-qnty-rvs  as decimal   no-undo .
        define variable v-tot-cli-qnty-rvs  as decimal   no-undo .

        define variable v-add-option-bt as character no-undo .
        define variable v-add-option-ps as character no-undo .
        define variable v-answ-num      as integer   no-undo .
        define variable v-edit-doc-pl   as integer   no-undo .
        define variable v-set-doc-pl    as integer   no-undo .
        define variable v-delta-mass-qnty as decimal no-undo.
        define variable rdc-dnstvalue   as character no-undo.
        define variable rdc-dnsttype    as character no-undo.
        define variable v-attr-type     as character no-undo .
        define variable v-attr-value    as character no-undo .
        define variable v-place-trk-err as character no-undo .
        define variable v-trk-err       as logical no-undo .
        
        define variable ii              as integer no-undo .
        
        define buffer buf_goods for ub.goods .
        run gds-attr-value in this-procedure
          (  input p-gds-code
            ,input {&attr-fuel-type}
            ,output v-attr-value
            ,output v-attr-type
           ) .
        if v-attr-value = "lgas" 
        then do:
          p-ok = true.
          return.
        end.
        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .

        assign
          p-ok           = true
          v-message      = "":U
          v-count-pl     = 0
          v-tot-qnty-rvs = 0.0
          v-tot-qnty-pl  = 0.0
          v-tot-cli-qnty-rvs = 0.0
        .
        for each tt-doc-pl no-lock
        on error undo, return error return-value
        :
          v-place-trk-err = "" .
          
          run return-rvs-qnty in this-procedure
            ( input  p-doc-code
             ,input  p-gds-code
             ,input  tt-doc-pl.pl-code
             ,output v-rvs-qnty-before
             ,output v-rvs-qnty-after
             ,output v-rvs-cli-qnty-before
             ,output v-rvs-cli-qnty-after
             ,output v-delta-mass-qnty
             ,output v-trk-err
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          
          if v-trk-err
          then do :
            assign v-place-trk-err = v-place-trk-err + string(tt-doc-pl.pl-code) + ',' .
          end .
          
          assign
            v-count-pl     = v-count-pl + 1
            v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
            v-tot-cli-qnty-rvs = v-tot-cli-qnty-rvs + ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
            v-tot-qnty-pl  = v-tot-qnty-pl  + tt-doc-pl.fact-qnty
          .
          
          run placelib_get-attr  (
             input {&place-com-tanks}
            ,input t-doc.obj-code
            ,input t-doc.obj-type
            ,input tt-doc-pl.pl-code
            ,output v-value
            ,output v-ok      )
          no-error.
          if  v-ok
          and v-value > ""
          then do :
            do ii = 1 to num-entries(v-value) :
              find first buf_place no-lock where buf_place.obj-type = tt-doc-pl.obj-type
                                             and buf_place.obj-code = tt-doc-pl.obj-code
                                             and buf_place.loc1     = entry(ii, v-value)
                                             and buf_place.status_  = ""
                                             no-error .
              if available buf_place
              then do :
                run return-rvs-qnty in this-procedure
                  ( input  p-doc-code
                   ,input  p-gds-code
                   ,input  buf_place.pl-code
                   ,output v-rvs-qnty-before
                   ,output v-rvs-qnty-after
                   ,output v-rvs-cli-qnty-before
                   ,output v-rvs-cli-qnty-after
                   ,output v-delta-mass-qnty
                   ,output v-trk-err
                  ) no-error .
                if error-status :error then do:
                  return error return-value .
                end.
                
                if v-trk-err
                then do :
                  assign v-place-trk-err = v-place-trk-err + string(buf_place.pl-code) + ',' .
                end .
                
                assign
                  v-count-pl     = v-count-pl + 1
                  v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
                  v-tot-cli-qnty-rvs = v-tot-cli-qnty-rvs + ( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
                .
              end .
            end .
          end .
          
          assign v-place-trk-err = trim(v-place-trk-err, ",") .
          if v-place-trk-err > ""
          then do :
            assign v-trk-err = yes .
          end .
          
          run gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", no, output rdc-dnstvalue, output rdc-dnsttype) no-error.
          if error-status:error
          then do:
            rdc-dnstvalue = 'not'.
          end.
          else do:
            rdc-dnstvalue = rdc-dnstvalue.
          end.
          if not (varauto-tank and rdc-dnstvalue = "pomi-rn")
          then do:
            if absolute( v-tot-qnty-rvs - tt-doc-pl.fact-qnty ) > tt-doc-pl.fact-qnty * 0.0065 then do:
              if v-message = "":U then do:
                assign
                  v-message = "Факт. кол-во по местам хранения и по сверкам:".
                .
              end.
              assign
                v-message = v-message
                            + {&new-line}
                            + substitute( "по месту хр. &1 (&4): &2, по сверкам: &3"
                                        ,tt-doc-pl.pl-code
                                        ,tt-doc-pl.fact-qnty
                                        ,v-tot-qnty-rvs
                                        ,buf_goods.unit-base
                                        )
              .
              if v-trk-err
              then do :
                v-message = substitute("Масса реализации при расчете расхождения не была учтена из-за ошибок при получении данных с ТРК по месту хр. &1", tt-doc-pl.pl-code)
                          + {&new-line}
                          + v-message
                .
              end .
            end.
          end.
          else do:
            v-delta-mass-qnty = tt-doc-pl.cli-fact-qnty * v-delta-mass-qnty / 100.
            if absolute( v-tot-cli-qnty-rvs - tt-doc-pl.cli-fact-qnty ) > v-delta-mass-qnty
            then do:
              if v-message = "":U then do:
                assign
                  v-message = substitute ("Факт. кол-во по сверкам не совпадает с факт. кол-вом по местам хранения :").
                .
              end.
              assign
                v-message = v-message
                            + {&new-line}
                            + substitute( "по месту хр. &1 (&4): &2, по сверкам: &3, погрешность измерения: &5."
                                        ,tt-doc-pl.pl-code
                                        ,tt-doc-pl.cli-fact-qnty
                                        ,v-tot-cli-qnty-rvs
                                        ,buf_goods.unit-cli
                                        ,round (v-delta-mass-qnty, 3)
                                        )
              .
              if v-trk-err
              then do :
                v-message = substitute("Масса реализации при расчете расхождения не была учтена из-за ошибок при получении данных с ТРК по месту хр. &1", tt-doc-pl.pl-code)
                          + {&new-line}
                          + v-message
                .
              end .
              message v-message view-as alert-box warning title "Внимание!".
              v-message = "".
            end.
            
          end.
        end. /* for each tt-doc-pl */
        
        if v-message <> "":U
          then return.
        
        if v-message <> "":U
          and ( v-count-pl > 1
                or ( v-count-pl = 1
                      and p-fact-edit = true
                    )
              )
        then do:
          assign
            v-edit-doc-pl = ?
            v-set-doc-pl  = ?
          .
          if p-fact-edit = true
            or ( p-fact-edit = false
                 and v-tot-qnty-pl  = p-new-fact-qnty
                 and v-tot-qnty-rvs = p-new-fact-qnty
               )
          then do:
            assign
              v-add-option-bt = v-add-option-bt + "|Редактировать"
              v-add-option-ps = v-add-option-ps + "|Редактировать товар на местах хранения"
              v-edit-doc-pl   = 3
            .
          end.
          if p-fact-edit = true
            or ( p-fact-edit = false
                 and v-tot-qnty-rvs = p-new-fact-qnty
                )
          then do:
            assign
              v-add-option-bt = v-add-option-bt + "|Установить"
              v-add-option-ps = v-add-option-ps + "|Установить по местам хранения кол-вo из сверок (плотность по документу)"
            .
            if v-edit-doc-pl = ? then do:
              assign
                v-set-doc-pl = 3
              .
            end.
            else do:
              assign
                v-set-doc-pl = 4
              .
            end.
          end.
          {gbl/ptrlprop.i
           run
           t-doc.obj-type
           t-doc.obj-code
          }
          run gbl/d-askw.w
            ( input "Расхождение значений по местам хранения с показаниями сверок"
             ,input substitute( "&1", v-message ) + {&new-line} + "Это вызовет расхождение фактических и расчетно-книжных остатков"
             ,input "|^"
             ,input "Сохранить|Отмена" + v-add-option-bt
             ,input "Сохранить, игнорируя это расхождение|Отмена сохранения" + v-add-option-ps
             ,input 1
             ,input 2
             ,output v-answ-num
            ) .
          if v-answ-num = 2 then do:
            return error .
          end.
          if v-edit-doc-pl <> ?
            and v-answ-num = v-edit-doc-pl
          then do:
            assign
              p-ok = false
            .
            run edit-doc-pl in this-procedure
              ( input {&update}
              ).
            return .
          end.
          if v-set-doc-pl <> ?
            and v-answ-num = v-set-doc-pl
          then do:
            assign
              p-ok = false
              p-new-fact-qnty     = 0.0
              p-new-cli-fact-qnty = 0.0

            .
            for each tt-doc-pl
            on error undo, return error return-value
            :
              run return-rvs-qnty in this-procedure
                ( input  p-doc-code
                 ,input  p-gds-code
                 ,input  tt-doc-pl.pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                 ,output v-delta-mass-qnty
                 ,output v-trk-err
                ) no-error .
              if error-status :error then do:
                return error return-value .
              end.
              assign
                tt-doc-pl.fact-qnty     = v-rvs-qnty-after - v-rvs-qnty-before
                tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-new-density
                p-new-fact-qnty         = p-new-fact-qnty    + tt-doc-pl.fact-qnty
                p-new-cli-fact-qnty     = p-new-cli-fact-qnty + tt-doc-pl.cli-fact-qnty
              .
            end. /* for each tt-doc-pl */
            assign
              p-new-density = p-new-cli-fact-qnty / p-new-fact-qnty
            .
            return .
          end.
        end.
      end.

    end procedure. /* eq-qnty-rvs-pl */

  &endif

  &if "{2}":U = "all-line":U &then
    define temp-table tt-place-sec
      field loc1    as character
      field secs    as character
      field own-rvs as logical
      field pl-code as integer
      index pi as primary unique
        loc1
    .
    
    { ref/gds-attr.i }
    { str/is-sug.i }
    { str/placelib.i }

    PROCEDURE cr-rvs-doc :

      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .

      tr:
      do transaction
      on error  undo, return error substitute( "&1 (cr-rvs-doc). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (cr-rvs-doc). stop", vss-include-info{&vssseq} )
      on endkey undo, return error substitute( "&1 (cr-rvs-doc). endkey", vss-include-info{&vssseq} )
      :

        { gbl/getcntxt.i def }
        { gbl/getcntxt.i get }

        define buffer buf_trn-doc    for ub.trn-doc .
        define buffer buf_doc-line   for ub.doc-line .
        define buffer buf_doc-line-attr for ub.doc-line-attr .
        define buffer buf_goods      for ub.goods .
        define buffer buf_place      for ub.place .
        define buffer buf_rvs-doc    for ub.rvs-doc .
        define buffer buf_rvs-line   for ub.rvs-line .
        define buffer cur_shift-obj  for ub.shift-obj.
        define buffer prev_shift-obj for ub.shift-obj.
        define buffer prev_rvs-doc   for ub.rvs-doc.
        define buffer prev_icnt-doc  for ub.icnt-doc.
        define buffer buf_doc-pl     for ub.doc-pl.
        define buffer sep_auto-tank-attr  for ub.auto-tank-attr.

        define variable is-petrolium       as logical   no-undo .
        define variable is-pieces          as logical   no-undo .
        define variable v-ptrl-without-rvs as character no-undo .
        define variable v-attr-type        as character no-undo .
        define variable v-ptrl-avail       as logical   no-undo .
        define variable v-doc-pl-avail     as logical   no-undo .
        define variable v-today            as date      no-undo .
        define variable v-value            as character no-undo .
        define variable v-ok               as logical   no-undo .
        define variable ii                 as integer   no-undo .
        define variable v-kpsecs           as character no-undo .
        define variable v-need-rvs-sec     as character no-undo .
        define variable v-rvs-code         as character no-undo .
        define variable v-no-need-main-rvs as logical   no-undo .
        define variable choice             as integer   no-undo .
        define variable varcar-num         as character no-undo .
        define variable vartype            as character no-undo .

        define variable varlog             as logical   no-undo .
        
        define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo .
        define variable infoSecObj        as class ibs.th.str.InfoSection no-undo .

        v-kpsecs = "" .
        v-need-rvs-sec = "" .
        
        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .
          
        { str/tdat-val.i
          buf_trn-doc.doc-code
          {&trdcattr-car-num}
          varcar-num
          vartype
          }
        
        if trn-type = {&is-fuel}
        then do :  
          find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = varcar-num
                                                  and sep_auto-tank-attr.attr-code = "auto-sep"
                                                  no-error.
          if available sep_auto-tank-attr
          and logical(sep_auto-tank-attr.attr-value)
          then do : /* АЦ с СГДКК */
            
          end .
          else do : /* Обычная АЦ без СГДКК */
            secs_ :
            for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                                 and buf_doc-line-attr.attr-code = "n",
            first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
            :
              infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
              infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
              infoSectionsTotal:GetDBAllAttr().
              do ii = 1 to infoSectionsTotal:SectionNum :
                infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
                if not infoSecObj:KPnoMeas
                and (not (infoSecObj:TankWeight > 0)
                or infoSecObj:TankWeight = ?
                or infoSecObj:TankDensity = ?)
                then do :
                  delete object infoSectionsTotal.
                  message
                    "Перед созданием документов сверки по накладной необходимо заполнить всю дополнительную информацию по приемке топлива!"
                  view-as alert-box .
                  return .
                end .
              end .
              delete object infoSectionsTotal.
            end .
          end .
            
          v-kpsecs = "" .
          v-need-rvs-sec = "" .
          v-no-need-main-rvs = no .
          empty temp-table tt-place-sec .
          
          kpsecs_ :
          for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                               and buf_doc-line-attr.attr-code = "n",
          first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
          :
            infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
            infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
            infoSectionsTotal:GetDBAllAttr().
            do ii = 1 to infoSectionsTotal:SectionNum :
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              find first tt-place-sec where tt-place-sec.loc1 = infoSecObj:ListTank no-error .
              if not available tt-place-sec
              then do :
                create tt-place-sec .
                assign
                  tt-place-sec.loc1 = infoSecObj:ListTank
                  tt-place-sec.secs = infoSecObj:SectionName
                  tt-place-sec.own-rvs = no
                .
                for first buf_place no-lock where buf_place.obj-type = buf_trn-doc.obj-type
                                              and buf_place.obj-code = buf_trn-doc.obj-code
                                              and buf_place.loc1     = tt-place-sec.loc1
                                              and buf_place.status_  = ""
                :
                  assign tt-place-sec.pl-code = buf_place.pl-code .
                end .
              end .
              else do :
                assign
                  tt-place-sec.secs = tt-place-sec.secs + "," + infoSecObj:SectionName
                .
              end .
              if infoSecObj:isKP
              then do :
                v-kpsecs = v-kpsecs + infoSecObj:SectionName + " с " + buf_goods.gds-name + ", " .
              end .
            end .
            delete object infoSectionsTotal.
          end .
          v-kpsecs = trim(v-kpsecs, ", ") .
        end .
        
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_rvs-on-doc_cr-revision':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          varlog
          no-error
        }
        if varlog <> yes then do:
          return error return-value .
        end.

        find first buf_rvs-doc no-lock
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
          no-error.
        if available buf_rvs-doc then do:
          message "Прототипы документов сверки уже созданы." skip
                  "Можно задавать кол-ва по приборам."       skip
          view-as alert-box error.
          return error.
        end.

        find first cur_shift-obj
          where cur_shift-obj.obj-type = buf_trn-doc.obj-type
            and cur_shift-obj.obj-code = buf_trn-doc.obj-code
            and cur_shift-obj.status_  = {&sht-current}
            use-index pi no-lock no-error .
        if not available cur_shift-obj then do:
          message "Нет открытой смены на объекте " buf_trn-doc.obj-type
                                                  buf_trn-doc.obj-code
          view-as alert-box error.
          return error.
        end.

        /*Ищем последнюю закрытую смену*/
        find last prev_shift-obj no-lock
          where prev_shift-obj.obj-type = cur_shift-obj.obj-type
            and prev_shift-obj.obj-code = cur_shift-obj.obj-code
            and prev_shift-obj.status_  = {&sht-closed}
            and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
                  or prev_shift-obj.shift-date = cur_shift-obj.shift-date
                    and prev_shift-obj.shift-num  < cur_shift-obj.shift-num
                )
          use-index stts
          no-error.
        /*Если это не первая смена на объекте, ищем сверку по прошлой смене*/
        if available prev_shift-obj then do:
          find first prev_rvs-doc no-lock
            where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
              and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
              and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
              and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
              and prev_rvs-doc.status_    = {&fact}
              and prev_rvs-doc.rvs-type   = {&rvs-shift}
            no-error.
          if not available prev_rvs-doc then do:
              assign varlog = no.
              message "Объект " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " ." skip
                      "Текущая смена " cur_shift-obj.shift-date " " cur_shift-obj.shift-num " ." skip
                      "Прошлая смена " prev_shift-obj.shift-date " " prev_shift-obj.shift-num " ." skip
                      "Нет сверки типа " {&rvs-shift} " за прошлую смену." skip
                      "Торговли топливом не было. Продолжить?"
              view-as alert-box question buttons yes-no update varlog .
              if varlog <> yes then return error.
          end.
        end.
        
        if v-kpsecs > ""
        then do :
          kpsecs_ :
          for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                               and buf_doc-line-attr.attr-code = "n"
          :
            infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
            infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
            infoSectionsTotal:GetDBAllAttr().
            do ii = 1 to infoSectionsTotal:SectionNum : 
              infoSecObj = infoSectionsTotal:GetInfoSectionProp(ii) .
              if infoSecObj:isKP
              then do :
                for first tt-place-sec where tt-place-sec.loc1 = infoSecObj:ListTank
                                         and not tt-place-sec.own-rvs :
                  if num-entries(tt-place-sec.secs) >= 1
                  then do :
                    tt-place-sec.own-rvs = yes .
                    v-need-rvs-sec = v-need-rvs-sec + tt-place-sec.secs + "," .
                  end .
                end .
              end .
            end .
            delete object infoSectionsTotal.
          end .
        end .
        v-need-rvs-sec = trim(v-need-rvs-sec, ",") .
        /*Ищем последнюю инвентаризацию счетчиков ТРК*/
        find last prev_icnt-doc no-lock
          where prev_icnt-doc.obj-type = buf_trn-doc.obj-type
            and prev_icnt-doc.obj-code = buf_trn-doc.obj-code
            and prev_icnt-doc.doc-type = {&icnt-doc}
            and prev_icnt-doc.status_  = {&fact}
          use-index fact-order
          no-error.

        { gbl/curobjdt.i buf_trn-doc.obj-type buf_trn-doc.obj-code v-today }
        /*создаем документ(ы) before-doc*/
        find first tt-place-sec where tt-place-sec.own-rvs = no no-error .
        
        run doc-code in this-procedure
          ( input "main":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input ?
          ,output v-rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        if v-need-rvs-sec = ""
        or available tt-place-sec
        then do :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = v-rvs-code
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = {&g___new}
            buf_rvs-doc.rvs-type  = {&rvs-before-doc}
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " {&rvs-before-doc} skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        do ii = 1 to num-entries(v-need-rvs-sec) :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = replace(v-rvs-code, "-", "-" + entry(ii, v-need-rvs-sec) + "-")
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = {&g___new}
            buf_rvs-doc.rvs-type  = {&rvs-before-doc}
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " {&rvs-before-doc} skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        /*создаем документ(ы) after-doc*/
        run doc-code in this-procedure
          ( input "main":U
            ,input buf_trn-doc.obj-type
            ,input buf_trn-doc.obj-code
            ,input ?
            ,output v-rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        if v-need-rvs-sec = ""
        or available tt-place-sec
        then do :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = v-rvs-code
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = {&g___new}
            buf_rvs-doc.rvs-type  = {&rvs-after-doc}
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
              ,input        buf_rvs-doc.obj-code
              ,input-output buf_rvs-doc.fact-date
              ,input-output buf_rvs-doc.fact-time
              ,input-output buf_rvs-doc.shift-date
              ,input-output buf_rvs-doc.shift-num
              ,input-output buf_rvs-doc.shift-name
              ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " {&rvs-after-doc} skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .
        do ii = 1 to num-entries(v-need-rvs-sec) :
          create buf_rvs-doc.
          assign
            buf_rvs-doc.rvs-code  = replace(v-rvs-code, "-", "-" + entry(ii, v-need-rvs-sec) + "-")
            buf_rvs-doc.host-code = buf_trn-doc.host-code
            buf_rvs-doc.obj-type  = buf_trn-doc.obj-type
            buf_rvs-doc.obj-code  = buf_trn-doc.obj-code
            buf_rvs-doc.status_   = {&g___new}
            buf_rvs-doc.rvs-type  = {&rvs-after-doc}
            buf_rvs-doc.out-code  = buf_trn-doc.doc-code
            buf_rvs-doc.creid     = v-cntxt-userid
            buf_rvs-doc.PS        = "@"
            buf_rvs-doc.is-full   = no
            buf_rvs-doc.doc-date  = v-today
          .
          find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error.
          if available (ub.user-account) and not (ub.user-account.psn-code = ? or ub.user-account.psn-code = 0)
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
            buf_rvs-doc.boss = ub.user-account.psn-code.
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          
          run gbl/factdate.p
            ( input        buf_rvs-doc.obj-type
            ,input        buf_rvs-doc.obj-code
            ,input-output buf_rvs-doc.fact-date
            ,input-output buf_rvs-doc.fact-time
            ,input-output buf_rvs-doc.shift-date
            ,input-output buf_rvs-doc.shift-num
            ,input-output buf_rvs-doc.shift-name
            ,input        yes
            ) no-error.
          if error-status :error then do:
            message
              "Ошибка при установке даты в документе " {&rvs-before-doc} skip
              view-as alert-box error.
            undo tr, return error.
          end.
        end .

        assign
          v-ptrl-avail = false
        .

        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        ,first buf_goods no-lock
          where buf_goods.artic     = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
        on error undo tr, return error return-value
        :
          { str/is-petrl.i
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
            is-petrolium
            is-pieces
            no-error
          }
          if error-status :error then do:
              message "Ошибка при вызове программы lib-trn_is-petrl." view-as alert-box .
              undo tr, return error .
          end.

          run gds-attr-value in this-procedure
            ( input  buf_goods.gds-code
             ,input  {&attr-ptrl-without-rvs}
             ,output v-ptrl-without-rvs
             ,output v-attr-type
            ) .

          if is-petrolium = true
            and is-pieces = false
            and lookup(v-ptrl-without-rvs, 'true,yes':u) = 0
          then do:
            assign
              v-ptrl-avail   = true
              v-doc-pl-avail = false
            .
            
            for each buf_doc-pl no-lock
              where buf_doc-pl.obj-type = buf_doc-line.obj-type
                and buf_doc-pl.obj-code = buf_doc-line.obj-code
                and buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code
            on error undo tr, return error return-value
            :
              rvs-doc_ :
              for each buf_rvs-doc
                where buf_rvs-doc.out-code = buf_trn-doc.doc-code
              on error undo tr, return error return-value
              :
                if v-need-rvs-sec > ""
                then do :
                  for each tt-place-sec where tt-place-sec.pl-code = buf_doc-pl.pl-code
                  :
                    if (tt-place-sec.own-rvs and num-entries(buf_rvs-doc.rvs-code, "-") = 3 and lookup(entry(2, buf_rvs-doc.rvs-code, "-"), tt-place-sec.secs) > 0)
                    or (not tt-place-sec.own-rvs and num-entries(buf_rvs-doc.rvs-code, "-") = 2)
                    then do :
                      assign
                        v-doc-pl-avail = true
                      .
                      { str/crrvslin.i
                        buf_rvs-doc.obj-type
                        buf_rvs-doc.obj-code
                        buf_rvs-doc.rvs-code
                        buf_rvs-doc.rvs-type
                        buf_doc-pl.pl-code
                        buf_doc-pl.gds-code
                        "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
                        buf_rvs-doc.shift-date
                        buf_rvs-doc.shift-num
                      }
                      { str/crrvslnp.i
                        buf_rvs-doc.obj-type
                        buf_rvs-doc.obj-code
                        buf_rvs-doc.rvs-code
                        buf_rvs-doc.rvs-type
                        buf_doc-pl.pl-code
                        buf_doc-pl.gds-code
                        yes
                        "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
                        buf_rvs-doc.shift-date
                        buf_rvs-doc.shift-num
                        "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
                        yes
                      }
                    end .
                  end .
                end .
                else do :
                  assign
                    v-doc-pl-avail = true
                  .
                  { str/crrvslin.i
                    buf_rvs-doc.obj-type
                    buf_rvs-doc.obj-code
                    buf_rvs-doc.rvs-code
                    buf_rvs-doc.rvs-type
                    buf_doc-pl.pl-code
                    buf_doc-pl.gds-code
                    "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
                    buf_rvs-doc.shift-date
                    buf_rvs-doc.shift-num
                  }
                  { str/crrvslnp.i
                    buf_rvs-doc.obj-type
                    buf_rvs-doc.obj-code
                    buf_rvs-doc.rvs-code
                    buf_rvs-doc.rvs-type
                    buf_doc-pl.pl-code
                    buf_doc-pl.gds-code
                    yes
                    "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
                    buf_rvs-doc.shift-date
                    buf_rvs-doc.shift-num
                    "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
                    yes
                  }
                end .
              end. /* for each buf_rvs-doc */
              
              run placelib_get-attr  (
                 input {&place-com-tanks}
                ,input buf_doc-pl.obj-code
                ,input buf_doc-pl.obj-type
                ,input buf_doc-pl.pl-code
                ,output v-value
                ,output v-ok      )
              no-error.
              if v-ok
              and v-value > ""
              then do ii = 1 to num-entries(v-value) :
                find first buf_place no-lock where buf_place.obj-type = buf_doc-pl.obj-type
                                               and buf_place.obj-code = buf_doc-pl.obj-code
                                               and buf_place.loc1     = entry(ii, v-value)
                                               and buf_place.status_  = ""
                                               no-error .
                if available buf_place
                then do :
                  for each buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code,
                     first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                                  and buf_rvs-line.gds-code = buf_doc-pl.gds-code
                                                  and buf_rvs-line.pl-code <> buf_place.pl-code
                  on error undo tr, return error return-value
                  :
                    assign
                      v-doc-pl-avail = true
                    .
                    { str/crrvslin.i
                      buf_rvs-doc.obj-type
                      buf_rvs-doc.obj-code
                      buf_rvs-doc.rvs-code
                      buf_rvs-doc.rvs-type
                      buf_place.pl-code
                      buf_doc-pl.gds-code
                      "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
                      buf_rvs-doc.shift-date
                      buf_rvs-doc.shift-num
                    }
                    { str/crrvslnp.i
                      buf_rvs-doc.obj-type
                      buf_rvs-doc.obj-code
                      buf_rvs-doc.rvs-code
                      buf_rvs-doc.rvs-type
                      buf_place.pl-code
                      buf_doc-pl.gds-code
                      yes
                      "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
                      buf_rvs-doc.shift-date
                      buf_rvs-doc.shift-num
                      "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
                      yes
                    }
                  end. /* for each buf_rvs-doc */
                end .
              end .
            end. /* for each ub.doc-pl */
            if v-doc-pl-avail = false then do:
              message
                substitute( 'В документе "&1" товар "&2" не распределен по местам хранения.', buf_doc-line.doc-code, buf_goods.gds-code ) skip
                "Сверки не созданны!"
                view-as alert-box information.
              undo tr, leave tr.
            end.
          end. /* if is-petrolium = yes */
        end. /* each buf_doc-line */
        if v-ptrl-avail <> true then do:
          message
            "В документе нет ни одного топливного товара требующего создание сверки."  skip
            "Сверки не созданны!"
            view-as alert-box information.
          undo tr, leave tr.
        end.
        for each buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-before-doc}
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "close":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', {&rvs-before-doc}, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "froze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', {&rvs-before-doc}, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
        for each buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-after-doc}
        :
          run str/rvs-stat.p
            ( input parparentproc
              ,input recid(buf_rvs-doc)
              ,input "close":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при закрытии документа сверки "&1" номер &2', {&rvs-after-doc}, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(buf_rvs-doc)
            ,input "froze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', {&rvs-after-doc}, buf_rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
      end. /* end transaction */
      return .
    END PROCEDURE.

    PROCEDURE del-rvs-doc :

      define input  parameter parparentproc as   handle              no-undo .
      define input  parameter p-doc-code    like ub.trn-doc.doc-code no-undo .

      tr:
      do transaction
      on error   undo tr, return error
      on end-key undo tr, return error
      on stop    undo tr, return error
      :
        { gbl/getcntxt.i def }
        { gbl/getcntxt.i get }

        define buffer buf_trn-doc for ub.trn-doc .
        define buffer bef-rvs-doc for ub.rvs-doc.
        define buffer aft-rvs-doc for ub.rvs-doc.
        define buffer buf_doc-line-attr for ub.doc-line-attr .
        
        define variable varlog           as logical   no-undo .
        define variable ii               as integer   no-undo .
        define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo .
        define variable infoSectionObj as class ibs.th.str.InfoSection no-undo .

        find first buf_trn-doc 
          where buf_trn-doc.doc-code = p-doc-code
          .
          
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_rvs-on-doc_deletion':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          varlog
          no-error
        }
        if varlog <> yes then do:
          return error return-value .
        end.

        assign
          varlog = no
          .
        message
          "Вы хотите удалить документы сверки по приходу?"
          view-as alert-box question buttons yes-no update varlog.
        if varlog <> yes then do:
          return .
        end.

        run waitfram-show in this-procedure (input "Удаляем документы сверки по приходной накладной").
        
        for each buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                                             and buf_doc-line-attr.attr-code = "n"
        :
          infoSectionsTotal = new ibs.th.str.InfoSectionsTotal().
          infoSectionsTotal:Initialization(buf_trn-doc.doc-code, buf_doc-line-attr.gds-code).
          infoSectionsTotal:GetDBAllAttr().
          do ii = 1 to infoSectionsTotal:SectionNum :
            infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii) .
            if infoSectionObj:AccMeth = 0
            then do :
              infoSectionObj:TankDensityPomi = ? .
              infoSectionObj:TankVolPomi = ? .
              infoSectionObj:TankWeight = ? .
              infoSectionObj:AccPomi = ? .
            end .
            if infoSectionObj:AccMeth = 1
            then do :
              infoSectionObj:TankVolPomiRvs = ? .
              infoSectionObj:TankWeightRvs = ? .
            end .
            infoSectionObj:AccMeth = ? .
            infoSectionObj:DateStart = ? .
            infoSectionObj:TimeStart = ? .
            infoSectionObj:DateEnd = ? .
            infoSectionObj:TimeEnd = ? .
            if not (infoSectionObj:KPnoMeas or infoSectionObj:alarm-SGDKK) then infoSectionObj:IsKP = no .
          end .
          infoSectionsTotal:SaveDB().
          delete object infoSectionsTotal.
        end .

        for each bef-rvs-doc
          where bef-rvs-doc.out-code = buf_trn-doc.doc-code
            and bef-rvs-doc.rvs-type = {&rvs-before-doc}
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', {&rvs-before-doc}, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(bef-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', {&rvs-before-doc}, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release bef-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', {&rvs-before-doc}, bef-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
        for each bef-rvs-doc
            where bef-rvs-doc.out-code = buf_trn-doc.doc-code
              and bef-rvs-doc.rvs-type = {&rvs-before-doc}
        :
          delete bef-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', {&rvs-before-doc} ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
        for each aft-rvs-doc
          where aft-rvs-doc.out-code = buf_trn-doc.doc-code
            and aft-rvs-doc.rvs-type = {&rvs-after-doc}
        :
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "unfroze":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при изменении статуса документа сверки "&1" номер &2', {&rvs-after-doc}, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          run str/rvs-stat.p
            ( input parparentproc
            ,input recid(aft-rvs-doc)
            ,input "open":U
            ) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', {&rvs-after-doc}, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
          release aft-rvs-doc no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure .
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при открытии документа сверки "&1" номер &2', {&rvs-after-doc}, aft-rvs-doc.rvs-code ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end.
        for each aft-rvs-doc
            where aft-rvs-doc.out-code = buf_trn-doc.doc-code
              and aft-rvs-doc.rvs-type = {&rvs-after-doc}
        :
          delete aft-rvs-doc no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              substitute( 'Ошибка при удалении документа сверки "&1"', {&rvs-after-doc} ) skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo tr, return error.
          end.
        end .
      end. /* transaction */
      run waitfram-hide in this-procedure .
      return .
    END PROCEDURE.
  &endif

    PROCEDURE block-nozzle:
      define input parameter parparentproc  as handle    no-undo.
      define input parameter obj-type       as character no-undo.
      define input parameter obj-code       as integer   no-undo.
      define input parameter list-pl        as character no-undo.
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (obj-type + {&delim-par} +
         string(obj-code) + {&delim-par} +
         string(0) + {&delim-par} +  /*p-remote */
         string(0) + {&delim-par} + /*p-shft-close*/
         {&delim-par} +
         {&delim-par} +
         {&delim-par} +
         substitute("&1,&2"
         ,"block"
         ,list-pl))
         ,input yes
         ,input ''
         ,input 'Блокировка пистолетов') .
      if not error-status:error then 
      do:
         if return-value begins "Для кассы" then 
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then run block-nozzle ( parparentproc, obj-type, obj-code, list-pl ).
            else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                  view-as alert-box.
               
         end.
         else 
         do:
            message "Блокировка пистолетов прошла успешно"
               view-as alert-box.
         end.   
    
      end.
      else 
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then run block-nozzle .
         else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
      end.
    END PROCEDURE .
    
    PROCEDURE unblock-nozzle:
      define input parameter parparentproc  as handle    no-undo.
      define input parameter obj-type       as character no-undo.
      define input parameter obj-code       as integer   no-undo.
      define input parameter list-pl        as character no-undo.
      run str/diallog.w ( input parparentproc
        ,input this-procedure
        ,input 'str/get-block-nozzle.p':U
        ,input (obj-type + {&delim-par} +
        string(obj-code) + {&delim-par} +
        string(0) + {&delim-par} +  /*p-remote */
        string(0) + {&delim-par} + /*p-shft-close*/
        {&delim-par} +
        {&delim-par} +
        {&delim-par} +
        substitute("&1,&2"
        ,"unblock"
        ,list-pl))
        ,input yes
        ,input ''
        ,input 'Разблокировка пистолетов') .
      if not error-status:error then 
      do:
         if return-value begins "Для кассы" then 
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then run unblock-nozzle( parparentproc, obj-type, obj-code, list-pl ).
            else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                  view-as alert-box.
               
         end.
         else 
         do:
            message "Разблокировка пистолетов прошла успешно"
               view-as alert-box.
         end.   
    
      end.
      else 
      do:
        message return-value
           view-as alert-box question buttons yes-no update v-ok .
        if v-ok then run unblock-nozzle .
        else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
              view-as alert-box.
         end.
    END PROCEDURE.
    
&endif

/* $Workfile$   E n d */
