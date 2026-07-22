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
    
    define variable v-prt-car-num          as character    no-undo .
    define variable v-prt-car-vol          as character    no-undo .
    define variable v-prt-tests            as character    no-undo .
    define variable v-prt-autoent-obj-type as character    no-undo .
    define variable v-prt-autoent-obj-code as character    no-undo .
    define variable v-prt-item-pour        as character    no-undo .
    define variable v-prt-time-pour        as character    no-undo .
    define variable v-prt-tank-vol         as character    no-undo .
    define variable v-prt-tank-temp        as character    no-undo .
    define variable v-prt-tank-water       as character    no-undo .
    define variable v-prt-tank-density     as character    no-undo .
    define variable v-prt-tank-weight      as character    no-undo .
    define variable v-prt-time-income      as character    no-undo .
    define variable v-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
    define variable v-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
    define variable v-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
    define variable v-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
    define variable v-prt-mouth            as character    no-undo .
    define variable v-prt-fio              as character    no-undo .
    define variable v-prt-ptbotype         as character    no-undo .
    define variable v-prt-ptbocode         as character    no-undo .
    define variable v-prt-a-b-tarir        as character    no-undo .
    define variable v-diameter             as character    no-undo .
    define variable v-place-si             as character    no-undo .
    define variable v-tank-density-pomi    as character    no-undo .
    define variable v-prt-certif-fuel      as character    no-undo .
    define variable v-prt-norm-doc         as character    no-undo .
    define variable v-prt-num-passport     as character    no-undo .
    define variable v-prt-validity-certif  as character    no-undo .
    define variable v-prt-passport-plotn   as character    no-undo .
    define variable v-prt-num-plotn        as character    no-undo .     
    define variable v-prt-date-pov-plotn   as date    no-undo . 
    define variable was_setting            as logical      no-undo initial no .

    define variable ptoldfilvalue          as character    no-undo.
    define variable ptoldfiltype           as character    no-undo.
    define variable stfactplvalue          as character    no-undo initial ? .
    define variable stfactpltype           as character    no-undo initial ? .
    define variable olddensvalue           as character    no-undo initial ? .
    define variable olddenstype            as character    no-undo initial ? .

    define variable varupd-fact-qnty       as logical      no-undo initial yes .
    define variable varrevision            as logical      no-undo initial no  .
    define variable varpercrev             as decimal      no-undo initial ?   .
    define variable varauto-tank           as logical      no-undo initial no  .
    define variable varpercauto            as decimal      no-undo initial ?   .
    define variable varinv                 as logical      no-undo initial no  .
    define variable varpercinv             as decimal      no-undo initial ?   .
    define variable varinv-set             as logical      no-undo initial no  .
    
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    
    procedure return-rvs-qnty :
      define  input parameter p-doc-code            like ub.trn-doc.doc-code            no-undo .
      define  input parameter p-gds-code            like ub.goods.gds-code              no-undo .
      define  input parameter p-pl-code             like ub.rvs-line.pl-code            no-undo .
      define output parameter p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty no-undo .
      define output parameter p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define output parameter p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .

      define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
      define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
      define buffer bf_bef_rvs-line for ub.rvs-line .
      define buffer bf_aft_rvs-line for ub.rvs-line .

      assign
        p-rvs-qnty-before     = 0.0
        p-rvs-qnty-after      = 0.0
        p-rvs-cli-qnty-before = 0.0
        p-rvs-cli-qnty-after  = 0.0
      .
      find first bf_bef_rvs-doc no-lock
        where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
          and bf_bef_rvs-doc.out-code = p-doc-code
        no-error .
      if available bf_bef_rvs-doc then do:
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
        end. /* for each bf_bef_rvs-line */
      end. /* if available bf_bef_rvs-doc */
      find first bf_aft_rvs-doc no-lock
        where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
          and bf_aft_rvs-doc.out-code = p-doc-code
        no-error .
      if available bf_aft_rvs-doc then do:
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
          assign
            p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
            p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
          .
        end. /* for each bf_aft_rvs-line */
      end. /* if available bf_aft_rvs-doc */
    end procedure. /* return-rvs-qnty */

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
            
            if is-gas(buf_before_rvs-line.gds-code) then next.
            
            run placelib_get-attr(input {&place-virtual}
                                 ,input tt-doc-pl.obj-code
                                 ,input tt-doc-pl.obj-type
                                 ,input tt-doc-pl.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
        
            is-vir = if (v-ok and logical(v-value)) then true else false.
            
            if is-vir then next.
            
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

      block_tr:
      do transaction
      on error  undo block_tr, return error substitute( "&1 (action-rvs-line). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo block_tr, return error substitute( "&1 (action-rvs-line). stop", vss-workfile )
      on endkey undo block_tr, return error substitute( "&1 (action-rvs-line). endkey", vss-workfile )
      :
        define variable v-pl-code      like ub.place.pl-code    no-undo .
        define variable v-rvs-code     like ub.rvs-doc.rvs-code no-undo .
        define variable v-act-name     as   character           no-undo .
        define variable v-log          as   logical             no-undo .
        define variable v-count-doc-pl as   integer             no-undo .
        define variable is-rvs-place   as   logical             no-undo .

        define variable varnum         as   integer             no-undo.
        define variable varcur-rvs     as   integer             no-undo.
        define variable v-today        as   date                no-undo.
        define variable v-time         as   integer             no-undo.

        define buffer buf_rvs-doc     for ub.rvs-doc .
        define buffer buf_rvs-line    for ub.rvs-line .
        define buffer buf_place       for ub.place .

        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-density         like ub.rvs-line.state-density          no-undo .
        
        define variable v-asi-ip  as character no-undo .
        define variable v-asi-port as character no-undo .
        define variable v-asi-type as character no-undo .
        define variable v-attr-type as character no-undo .

        assign
          v-pl-code = ?
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
          v-count-doc-pl = 0
          v-pl-code      = ?
        .
        for each tt-doc-pl no-lock
        on error undo block_tr, return error return-value
        :
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
            v-count-doc-pl = v-count-doc-pl + 1
            v-pl-code      = buf_rvs-line.pl-code
          .
        end. /* for each tt-doc-pl */

        if v-count-doc-pl > 1
          or v-pl-code = ?
        then do:
          run plgdsfnd in this-procedure
            ( input yes
            ,input buf_rvs-doc.obj-type
            ,input buf_rvs-doc.obj-code
            ,input buf_goods.gds-code
            ,output is-rvs-place
            ,output v-pl-code
            ) no-error .
          if error-status :error then do:
            message
              substitute( "Ошибка при выборе места хранения по товару &1.", buf_goods.gds-code ) skip
              return-value skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
        end. /* v-count-doc-pl > 1 */

        find first buf_rvs-line
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
            and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
            and buf_rvs-line.pl-code  = v-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          no-error.
        if not available buf_rvs-line then do:
          message
            substitute( "Не найдена строка сверки по резервуару &1", v-pl-code ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end.

        case p-action :
          when {&update} then do:
              find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = v-pl-code
              .
                    
            if p-action-type = "meas" or buf_place.is-meas <> yes then /* ТН-3370 Арн 12.01.2015. (Строка Накл в режиме "Изменить") и меню pop-up (по кнопкам "Св.до" и "Св.после") = "Сверка резервуара" [он же парам="meas"] */
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_cr-revision':U /* Право на создание сверки */
              .
            end.
            else
            do:
              assign
                v-act-name = 'actn_rvs-on-doc_upd-revision':U /* Право на изменение сверки */
              .
            end.

            case p-rvs-type :
              when {&rvs-before-doc} then do:
                run check-before in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input v-pl-code
                  ) no-error .
                if error-status :error then do:
                  undo block_tr, return error .
                end.
              end.
              when {&rvs-after-doc} then do:
                run check-after in this-procedure
                  ( input t-doc.doc-code
                   ,input buf_goods.gds-code
                   ,input v-pl-code
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
            undo block_tr, return error .
          end.
        end.

        find first buf_rvs-line exclusive-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.obj-type = t-doc.obj-type
            and buf_rvs-line.obj-code = t-doc.obj-code
            and buf_rvs-line.pl-code  = v-pl-code
            and buf_rvs-line.gds-code = buf_goods.gds-code
          .

        case p-action-type :
          when "meas":U then do:
            find buf_place no-lock
              where buf_place.obj-type = t-doc.obj-type
                and buf_place.obj-code = t-doc.obj-code
                and buf_place.pl-code  = v-pl-code
              .
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
            for each tt-meas
            :
              delete tt-meas .
            end.
            create tt-meas .
            assign
              tt-meas.obj-type = t-doc.obj-type
              tt-meas.obj-code = t-doc.obj-code
              tt-meas.pl-code  = v-pl-code
            .
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

            { str/fill1plc.i
              t-doc.obj-type
              t-doc.obj-code
              v-pl-code
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
            if p-rvs-type = {&rvs-before-doc}  then do:
              if v-prt-start-real-date > buf_rvs-line.real-date
                or ( v-prt-start-real-date = buf_rvs-line.real-date
                    and v-prt-start-real-time > buf_rvs-line.real-time
                  )
              then do:
                assign
                  v-prt-start-real-date = buf_rvs-line.real-date
                  v-prt-start-real-time = buf_rvs-line.real-time
                .
              end.
            end.
            else do:
              if v-prt-end-real-date < buf_rvs-line.real-date
                or ( v-prt-end-real-date = buf_rvs-line.real-date
                    and v-prt-end-real-time < buf_rvs-line.real-time
                  )
              then do:
                assign
                  v-prt-end-real-date  = buf_rvs-line.real-date
                  v-prt-end-real-time  = buf_rvs-line.real-time
                .
              end.
            end.
          end.
          when "edit":U then do:

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
                                    ,v-pl-code)) no-error.
            end.
            else
            if not error-status :error 
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
                                    ,v-pl-code)) no-error.
            end.
            
            else do:
            
                run str/rvs-lin.w
                  (input  parparentproc
                  ,input  recid( buf_rvs-line )
                  ,input  p-action
                  ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                                    ,buf_rvs-doc.rvs-code
                                    ,buf_goods.artic
                                    ,buf_goods.prod-type
                                    ,buf_goods.prod-code
                                    ,v-pl-code)) no-error.
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
        
        run placelib_get-attr(input {&place-virtual}
                                 ,input buf_rvs-line.obj-code
                                 ,input buf_rvs-line.obj-type
                                 ,input buf_rvs-line.pl-code
                                 ,output v-value
                                 ,output v-ok) no-error.
        
        is-vir = if (v-ok and logical(v-value)) then true else false.
        
        if not is-gas(buf_goods.gds-code) and not is-vir then do:
        
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
                 ,input v-pl-code
                 ,output v-rvs-qnty-before
                 ,output v-rvs-qnty-after
                 ,output v-rvs-cli-qnty-before
                 ,output v-rvs-cli-qnty-after
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error return-value .
              end.
              
              if p-rvs-type = {&rvs-after-doc} then do:
                if v-rvs-qnty-after = ?
                  or v-rvs-qnty-after = 0
                then do:
                  message
                    "Не задано количество по сверке <<после_док>>"
                    "по резервуару" v-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after = ?
                  or v-rvs-cli-qnty-after = 0
                then do:
                  /* ругаемся на плотность потому что в строке редактирования сверки у нас открыто поле плотность */
                  message
                    "Не задана плотность в сверке <<после_док>>"
                    "по резервуару" v-pl-code "."
                    view-as alert-box error .
                  undo block_tr, return error .
                end.
              end.
    
              if v-rvs-qnty-after <> ?
                and v-rvs-qnty-after <> 0
              then do:
                if v-rvs-qnty-after - v-rvs-qnty-before <= 0
                  or v-rvs-qnty-after - v-rvs-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-qnty-after - v-rvs-qnty-before, buf_goods.unit-base ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
                if v-rvs-cli-qnty-after - v-rvs-cli-qnty-before <= 0
                  or v-rvs-cli-qnty-after - v-rvs-cli-qnty-before = ?
                then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Количество залитого топлива: &1 (&2).", v-rvs-cli-qnty-after - v-rvs-cli-qnty-before, buf_goods.unit-cli ) skip
                    view-as alert-box .
                  undo block_tr, return error .
                end.
    
                assign
                  v-rvs-density = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before) / (v-rvs-qnty-after - v-rvs-qnty-before)
                .
                if Valid-Density( v-rvs-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
                  message
                    substitute( "Ошибка по результатам сверки." ) skip
                    substitute( "Место хранения: &1 .", v-pl-code ) skip
                    substitute( "Плотность залитого топлива: &1.", v-rvs-density ) skip
                    view-as alert-box .
                  undo block_tr, return error .
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
      define input-output parameter p-prt-car-num          as   character                no-undo .
      define input-output parameter p-prt-car-vol          as   character                no-undo .
      define input-output parameter p-prt-tests            as   character                no-undo .
      define input-output parameter p-prt-autoent-obj-type as   character                no-undo .
      define input-output parameter p-prt-autoent-obj-code as   character                no-undo .
      define input-output parameter p-prt-item-pour        as   character                no-undo .
      define input-output parameter p-prt-time-pour        as   character                no-undo .
      define input-output parameter p-prt-tank-vol         as   character                no-undo .
      define input-output parameter p-prt-tank-temp        as   character                no-undo .
      define input-output parameter p-prt-tank-water       as   character                no-undo .
      define input-output parameter p-prt-tank-density     as   character                no-undo .
      define input-output parameter p-prt-tank-weight      as   character                no-undo .
      define input-output parameter p-prt-time-income      as   character                no-undo .
      define input-output parameter p-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
      define input-output parameter p-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
      define input-output parameter p-prt-mouth            as   character                no-undo .
      define input-output parameter p-prt-fio              as   character                no-undo .
      define input-output parameter p-prt-ptbotype         as   character                no-undo .
      define input-output parameter p-prt-ptbocode         as   character                no-undo .
      define input-output parameter p-prt-a-b-tarir        as   character                no-undo .
      define input-output parameter p-diameter             as   character                no-undo .
      define input-output parameter p-place-si             as   character                no-undo .
      define input-output parameter p-tank-density-pomi    as   character                no-undo .
      define input-output parameter p-prt-certif-fuel      as character    no-undo .
      define input-output parameter p-prt-norm-doc         as character    no-undo .
      define input-output parameter p-prt-num-passport     as character    no-undo .
      define input-output parameter p-prt-validity-certif  as character    no-undo .
      define input-output parameter p-prt-passport-plotn   as   character             no-undo .
      define input-output parameter p-prt-num-plotn        as   character             no-undo .
      define input-output parameter p-prt-date-pov-plotn   like ub.rvs-line.real-date no-undo .
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

        block_tr:
        do transaction
        on error  undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo block_tr, return error substitute( "&1. stop", vss-workfile )
        on endkey undo block_tr, return error substitute( "&1. endkey", vss-workfile )
        :


          find first buf_goods no-lock
            where buf_goods.gds-code = p-gds-code
            .
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

          run str/in-laddout.w
            ( input        parParentProc
             ,input        p-mode
             ,input        p-doc-code
             ,input        p-gds-code
             ,input-output p-prt-car-num
             ,input-output p-prt-car-vol
             ,input-output p-prt-tests
             ,input-output p-prt-autoent-obj-type
             ,input-output p-prt-autoent-obj-code
             ,input-output p-prt-item-pour
             ,input-output p-prt-time-pour
             ,input-output p-prt-tank-vol
             ,input-output p-prt-tank-temp
             ,input-output p-prt-tank-water
             ,input-output p-prt-tank-density
             ,input-output p-prt-tank-weight
             ,input-output p-prt-time-income
             ,input-output p-prt-start-real-date
             ,input-output p-prt-start-real-time
             ,input-output p-prt-end-real-date
             ,input-output p-prt-end-real-time
             ,input-output p-prt-mouth
             ,input-output p-prt-fio
             ,input-output p-prt-ptbotype
             ,input-output p-prt-ptbocode
             ,input-output p-prt-a-b-tarir
             ,input-output p-diameter
             ,input-output p-place-si
             ,input-output p-tank-density-pomi
             ,input-output p-prt-certif-fuel 
             ,input-output p-prt-norm-doc 
             ,input-output p-prt-num-passport 
             ,input-output p-prt-validity-certif
             ,input-output p-prt-passport-plotn
             ,input-output p-prt-num-plotn             
             ,input-output p-prt-date-pov-plotn     
             ,      output v-setting
            ) no-error .
          if error-status :error then do:
            undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
          end.

          if v-setting = true
            and p-mode <> {&lookup}
            and p-stfactplvalue <> "":U
            and p-auto-tank = true
          then do:
            assign
              v-new-fact-qnty = p-new-fact-qnty
            .
            { str/stfactqt.i
              p-stfactplvalue
              p-doc-qnty
              p-doc-density
              0.00
              0.00
              p-prt-tank-vol
              decimal(p-prt-tank-density)
              no
              v-new-fact-qnty
              v-chg
              v-st-doc
              no-error
            }
            if error-status :error then do:
              undo block_tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) .
            end.

            if p-new-fact-qnty <> v-new-fact-qnty
              or v-chg       =  yes
              or v-st-doc    =  yes
            then do:
              assign
                v-new-density = ( if v-st-doc = yes then p-doc-density else decimal( p-prt-tank-density ) )
                v-log         = yes
              .
              if decimal( p-prt-tank-vol ) <> p-new-fact-qnty
                or v-new-density <> p-new-density
              then do:
                if p-fact-edit = true then do:
                  message
                    substitute( "По результатам измерения автоцистерны фактическое кол-во необходимо изменить." ) skip
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
                  substitute( "По результатам измерения резервуаров фактическое кол-во необходимо изменить." ) skip
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

        define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
        define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
        define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .

        define variable v-count-pl      as integer   no-undo .
        define variable v-message       as character no-undo .
        define variable v-tot-qnty-pl   as decimal   no-undo .
        define variable v-tot-qnty-rvs  as decimal   no-undo .

        define variable v-add-option-bt as character no-undo .
        define variable v-add-option-ps as character no-undo .
        define variable v-answ-num      as integer   no-undo .
        define variable v-edit-doc-pl   as integer   no-undo .
        define variable v-set-doc-pl    as integer   no-undo .


        define buffer buf_goods for ub.goods .

        find first buf_goods no-lock
          where buf_goods.gds-code = p-gds-code
          .

        assign
          p-ok           = true
          v-message      = "":U
          v-count-pl     = 0
          v-tot-qnty-rvs = 0.0
          v-tot-qnty-pl  = 0.0
        .
        for each tt-doc-pl no-lock
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
            ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
          assign
            v-count-pl     = v-count-pl + 1
            v-tot-qnty-rvs = v-tot-qnty-rvs + ( v-rvs-qnty-after - v-rvs-qnty-before )
            v-tot-qnty-pl  = v-tot-qnty-pl  + tt-doc-pl.fact-qnty
          .
          if absolute( ( v-rvs-qnty-after - v-rvs-qnty-before ) - tt-doc-pl.fact-qnty ) > tt-doc-pl.fact-qnty * 0.0065 then do:
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
                                      ,tt-doc-pl.cli-fact-qnty
                                      ,( v-rvs-cli-qnty-after - v-rvs-cli-qnty-before )
                                      ,buf_goods.unit-cli
                                      ) .
            .
          end.
        end. /* for each tt-doc-pl */

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
    { ref/gds-attr.i }

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
        define buffer buf_goods      for ub.goods .
        define buffer buf_rvs-doc    for ub.rvs-doc .
        define buffer cur_shift-obj  for ub.shift-obj.
        define buffer prev_shift-obj for ub.shift-obj.
        define buffer prev_rvs-doc   for ub.rvs-doc.
        define buffer prev_icnt-doc  for ub.icnt-doc.
        define buffer buf_doc-pl     for ub.doc-pl.

        define variable is-petrolium       as logical   no-undo.
        define variable is-pieces          as logical   no-undo.
        define variable v-ptrl-without-rvs as character no-undo .
        define variable v-attr-type        as character no-undo .
        define variable v-ptrl-avail       as logical   no-undo .
        define variable v-doc-pl-avail     as logical   no-undo .
        define variable v-today            as date      no-undo.

        define variable varlog             as logical   no-undo .

        find first buf_trn-doc
          where buf_trn-doc.doc-code = p-doc-code
          .

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
        /*Ищем последнюю инвентаризацию счетчиков ТРК*/
        find last prev_icnt-doc no-lock
          where prev_icnt-doc.obj-type = buf_trn-doc.obj-type
            and prev_icnt-doc.obj-code = buf_trn-doc.obj-code
            and prev_icnt-doc.doc-type = {&icnt-doc}
            and prev_icnt-doc.status_  = {&fact}
          use-index fact-order
          no-error.

        { gbl/curobjdt.i buf_trn-doc.obj-type buf_trn-doc.obj-code v-today }
        /*создаем документ before-doc*/
        create buf_rvs-doc.
        run doc-code in this-procedure
          ( input "main":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input ?
          ,output buf_rvs-doc.rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        assign
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
        /*создаем документ after-doc*/
        create buf_rvs-doc.
        run doc-code in this-procedure
          ( input "main":U
            ,input buf_trn-doc.obj-type
            ,input buf_trn-doc.obj-code
            ,input ?
            ,output buf_rvs-doc.rvs-code
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при генерации номера документа."
            view-as alert-box error.
          return error.
        end.
        assign
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
              for each buf_rvs-doc
                where buf_rvs-doc.out-code = buf_trn-doc.doc-code
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
                  buf_doc-pl.pl-code
                  buf_doc-pl.gds-code
                  "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
                  buf_rvs-doc.shift-date
                  buf_rvs-doc.shift-num
                }
              end. /* for each buf_rvs-doc */
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
        find first buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-before-doc}
        .
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
        find first buf_rvs-doc
          where buf_rvs-doc.out-code = buf_trn-doc.doc-code
            and buf_rvs-doc.rvs-type = {&rvs-after-doc}
        .
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

        define variable varlog           as logical   no-undo .

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

        find first bef-rvs-doc
          where bef-rvs-doc.out-code = buf_trn-doc.doc-code
            and bef-rvs-doc.rvs-type = {&rvs-before-doc}
          no-error.
        if available bef-rvs-doc then do:
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
          find first bef-rvs-doc
            where bef-rvs-doc.out-code = buf_trn-doc.doc-code
              and bef-rvs-doc.rvs-type = {&rvs-before-doc}
            no-error.
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
        end.
        find first aft-rvs-doc
          where aft-rvs-doc.out-code = buf_trn-doc.doc-code
            and aft-rvs-doc.rvs-type = {&rvs-after-doc}
          no-error.
        if available aft-rvs-doc then do:
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
          find first aft-rvs-doc
            where aft-rvs-doc.out-code = buf_trn-doc.doc-code
              and aft-rvs-doc.rvs-type = {&rvs-after-doc}
            no-error.
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
        end.
      end. /* transaction */
      run waitfram-hide in this-procedure .
      return .
    END PROCEDURE.
  &endif

&endif

/* $Workfile$   E n d */