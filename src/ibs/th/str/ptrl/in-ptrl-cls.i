 
 /*------------------------------------------------------------------------
    File        : in-ptrl
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Thu May 18 14:40:08 AST 2023
    Notes       : 
  ----------------------------------------------------------------------*/



/*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void ActionRvsSec
    (input pAction as character,
     input pActionType as character,
     input pRvsType as character)
  :
    define buffer buf_doc-line for ub.doc-line.

    block_tr:
    do transaction
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
      define variable v-value        as character no-undo .
      define variable v-value2       as character no-undo .
      define variable v-ok           as logical   no-undo .
      define variable ii             as integer   no-undo .
      define variable v-com-vessel-rvs as logical no-undo init no .
      define variable v-com-vessel-is-meas as logical no-undo init no .
      define variable v-code         as character    no-undo.
      define variable is-com-tanks   as logical no-undo init no .
      define variable v-pump-err     as character no-undo init "" .

      define buffer buf_rvs-doc       for ub.rvs-doc .
      define buffer buf_rvs-line      for ub.rvs-line .
      define buffer buf_rvs-line-pump for ub.rvs-line-pump .
      define buffer buf_place         for ub.place .
      define buffer buf_place-attr    for ub.place-attr .
      define buffer buf2_place        for ub.place .
      define buffer buf_goods         for ub.goods .
      define buffer bf_pump-nozzle    for ub.pump-nozzle.
      define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
      define buffer bf_pl-gds         for ub.pl-gds.

      define variable v-rvs-qnty-before     like ub.rvs-line.state-measure-qnty     no-undo .
      define variable v-rvs-qnty-after      like ub.rvs-line.state-measure-qnty     no-undo .
      define variable v-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty no-undo .
      define variable v-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty no-undo .
      define variable v-rvs-density         like ub.rvs-line.state-density          no-undo .
      define variable v-attr-type           as character no-undo .
      define variable v-attr-value          as character   no-undo .
      define variable v-delta-mass-qnty as decimal   no-undo .
      define variable v-com-tank-delta-mass-qnty as decimal   no-undo .
      
      define variable v-asi-ip  as character no-undo .
      define variable v-asi-port as character no-undo .
      define variable v-asi-type as character no-undo .
      
      define variable ptoldfilvalue          as character    no-undo.
      define variable ptoldfiltype           as character    no-undo.
      
      define variable v-prt-start-real-date  like ub.rvs-line.real-date    no-undo .
      define variable v-prt-start-real-time  like ub.rvs-line.real-time    no-undo .
      define variable v-prt-end-real-date    like ub.rvs-line.real-date    no-undo .
      define variable v-prt-end-real-time    like ub.rvs-line.real-time    no-undo .
      
      define variable infoSecObj as class InfoSection .
      
      define variable v-pl-list      as character no-undo init "":U .
      define variable v-com-tanks    as character no-undo init "":U .
      
      define variable pl-rvd-dens as logical no-undo .
      define variable pl-rvd-lvl as logical no-undo .
      define variable pl-rvd-temp as logical no-undo .
      
      define variable waitForm as class ibs.th.str.ptrl.forms.waitform no-undo.

      infoSecObj = infoSecsObj:GetInfoSectionProp(idSecTabPage) .
      
      find first buf_rvs-doc exclusive-lock
        where buf_rvs-doc.rvs-type = pRvsType
          and buf_rvs-doc.out-code = infoSecsObj:TrnDocNum
          and num-entries(buf_rvs-doc.rvs-code, "-") = 3
          and entry(2, buf_rvs-doc.rvs-code, "-") = infoSecObj:SectionName
        no-error .
      if not available buf_rvs-doc then do:
        message
          "Не зафиксированы книжные кол-ва и не созданы документы сверки по складскому документу." skip
          view-as alert-box error .
        undo block_tr, return error .
      end.
      
      find first buf_goods no-lock where buf_goods.gds-code = infoSecsObj:GdsCode .
      
      { gbl/conf-rd.i "'ptoldfil'" buf_rvs-doc.host-code buf_rvs-doc.obj-type buf_rvs-doc.obj-code "''" "''" "''" no ptoldfilvalue ptoldfiltype no-error }

      assign v-pl-code = ? .
      
      if pAction = {&lookup}
      then do :
        for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                        and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                        and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                        and buf_rvs-line.gds-code = buf_goods.gds-code
        :
          assign
            v-pl-code      = buf_rvs-line.pl-code
            v-pl-list      = v-pl-list + string(buf_rvs-line.pl-code) + "," 
          .
        end .
        if v-pl-code = ?
        then do :
          message
            "Не найдена строка сверки:" skip
            substitute( "товар &1", buf_goods.gds-code ) skip
            substitute( "место хранения &1", infoSecObj:ListTank ) skip
            view-as alert-box error .
          undo block_tr, return error .
        end .
      end .
      else do :
        for first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                      and buf_place.obj-code = buf_rvs-doc.obj-code
                                      and buf_place.loc1 = infoSecObj:ListTank
                                      and buf_place.status_ = ""
        :
          assign
            v-pl-code = buf_place.pl-code
            v-pl-list = v-pl-list + string(buf_place.pl-code) + ","
            v-com-tanks = ""
          .
          for first buf_place-attr no-lock where buf_place-attr.attr-code = "place-com-tanks"
                                              and buf_place-attr.obj-code = buf_place.obj-code
                                              and buf_place-attr.obj-type = buf_place.obj-type
                                              and buf_place-attr.pl-code  = buf_place.pl-code
          :
            assign v-com-tanks = buf_place-attr.attr-value .
          end .
          if pActionType = "edit"
          then
          do ii = 1 to num-entries(v-com-tanks) :
            for each buf2_place no-lock where buf2_place.obj-type = buf_place.obj-type
                                          and buf2_place.obj-code = buf_place.obj-code
                                          and buf2_place.loc1     = entry(ii, v-com-tanks)
  /*                                          and buf2_place.status_  = ""*/
            :
              for first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                               and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                               and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                               and buf_rvs-line.pl-code  = buf2_place.pl-code
                                               and buf_rvs-line.gds-code = buf_goods.gds-code
              :
                assign v-pl-list = v-pl-list + string(buf2_place.pl-code) + "," .
              end .
              release buf_rvs-line no-error .
            end .
          end .
        end .
      end .
      
      assign v-pl-list = trim(v-pl-list, ",") .
      
      if num-entries(v-pl-list) > 1
      or v-pl-code = ?
      then do:
        run ref/pl-gds-list.w
          ( input v-pl-list
          , output v-pl-code
          ) no-error .
        if v-pl-code = ? 
        or v-pl-code = 0
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

      case pAction :
        when {&update}
        then do:
          if infoSecObj:IsKP
          then do :
            assign
              v-act-name = 'actn_income_petrol-сommission':U /* Право на комиссионный приём */
            .
          end .
          else do :
            find first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                           and buf_place.obj-code = buf_rvs-doc.obj-code
                                           and buf_place.pl-code  = v-pl-code
                                           no-error .
            if not available buf_place
            then do :
              undo block_tr, return error return-value .
            end .
            if pActionType = "meas" or not buf_place.is-meas
            then do :
              assign
                v-act-name = 'actn_rvs-on-doc_cr-revision':U /* Право на создание сверки */
              .
            end .
            else do :
              for first buf_place-attr no-lock where buf_place-attr.attr-code = "place-rvd-dnsty"
                                                 and buf_place-attr.obj-code = buf_place.obj-code
                                                 and buf_place-attr.obj-type = buf_place.obj-type
                                                 and buf_place-attr.pl-code  = buf_place.pl-code
              :
                assign pl-rvd-dens = logical(buf_place-attr.attr-value) no-error .
              end .
              for first buf_place-attr no-lock where buf_place-attr.attr-code = "place-rvd-lvl"
                                                 and buf_place-attr.obj-code = buf_place.obj-code
                                                 and buf_place-attr.obj-type = buf_place.obj-type
                                                 and buf_place-attr.pl-code  = buf_place.pl-code
              :
                assign pl-rvd-lvl = logical(buf_place-attr.attr-value) no-error .
              end .
              for first buf_place-attr no-lock where buf_place-attr.attr-code = "place-rvd-tmp"
                                                 and buf_place-attr.obj-code = buf_place.obj-code
                                                 and buf_place-attr.obj-type = buf_place.obj-type
                                                 and buf_place-attr.pl-code  = buf_place.pl-code
              :
                assign pl-rvd-temp = logical(buf_place-attr.attr-value) no-error .
              end .
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
            end .
          end .
          case pRvsType :
            when {&rvs-before-doc} then do:
              check-before
                ( input infoSecsObj:TrnDocNum
                 ,input buf_goods.gds-code
                 ,input v-pl-code
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error .
              end.
            end.
            when {&rvs-after-doc} then do:
              check-after
                ( input infoSecsObj:TrnDocNum
                 ,input buf_goods.gds-code
                 ,input v-pl-code
                ) no-error .
              if error-status :error then do:
                undo block_tr, return error .
              end.
            end.
          end case .
        end.
        when {&lookup}
        then do:
          assign
            v-act-name = 'actn_rvs-on-doc_lookup':U
          .
        end.
      end case.

      if v-act-name <> "":U
      then do:
        { gbl/chk-actg.i
          gbl-var:g#db-num
          gbl-var:g#userid
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
          if pAction = {&update}
          then do :
            message "Не достаточно прав! Работа со сверками запрещена!" view-as alert-box .
          end .
          undo block_tr, return error .
        end.
      end.

      find first buf_rvs-line exclusive-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
          and buf_rvs-line.pl-code  = v-pl-code
          and buf_rvs-line.gds-code = buf_goods.gds-code
        .

      case pActionType :
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
            where buf_place.obj-type = buf_rvs-doc.obj-type
              and buf_place.obj-code = buf_rvs-doc.obj-code
              and buf_place.pl-code  = v-pl-code
            .
            
          if v-com-tanks > ""
          then do :
            v-com-vessel-rvs = yes .
            v-com-vessel-is-meas = no .
            v-com-tanks = buf_place.loc1 + "," + v-com-tanks .
            do ii = 1 to num-entries(v-com-tanks) :
              find first buf_place no-lock where buf_place.obj-type = buf_rvs-doc.obj-type
                                             and buf_place.obj-code = buf_rvs-doc.obj-code
                                             and buf_place.loc1     = entry(ii, v-com-tanks)
                                             and buf_place.status_  = ""
                                             no-error .
              if available buf_place
              then do :
                
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
              tt-meas.obj-type = buf_rvs-doc.obj-type
              tt-meas.obj-code = buf_rvs-doc.obj-code
              tt-meas.pl-code  = v-pl-code
            .
            
            for each bf_pl-pump-nozzle no-lock where bf_pl-pump-nozzle.obj-type = buf_place.obj-type 
                                                 and bf_pl-pump-nozzle.obj-code = buf_place.obj-code
                                                 and bf_pl-pump-nozzle.pl-code  = buf_place.pl-code,
            first bf_pump-nozzle no-lock where bf_pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type 
                                           and bf_pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code 
                                           and bf_pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
                                           and bf_pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
  /*                                         and bf_pump-nozzle.is-meas     = yes*/
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
          v-asi-ip = db-attr-value(sys-ctrl.db,"AsiIp").
          v-asi-port = db-attr-value(sys-ctrl.db,"AsiPort").
          v-asi-type = db-attr-value(sys-ctrl.db,"AsiType").
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

          waitForm = new ibs.th.str.ptrl.forms.waitform("~r~nОпрос АСИ...") .
          waitForm:Show() .
          { str/rvsplace.i
            buf_rvs-doc.obj-type
            buf_rvs-doc.obj-code
            yes
            varcur-rvs
            yes
            yes
            tt-meas-file
            tt-meas
            no-error
          }
          if error-status :error then do:
            waitForm:Close() .
            delete object waitForm no-error .
            message
              "Ошибка при получении данных с приборов на резервуарах." skip( 0 )
              return-value skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
          waitForm:Close() .
          delete object waitForm no-error .
          
          if v-com-vessel-rvs
          then do :
            for each buf_rvs-line exclusive-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                                   and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                                   and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                                   and buf_rvs-line.gds-code = buf_goods.gds-code,
            first tt-meas where tt-meas.pl-code = buf_rvs-line.pl-code
            :
              { str/fill1plc.i
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
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
  
              cur-time
                ( output v-today
                , output v-time
                ) .
              { gbl/curobjdt.i
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
                v-today
              }
  
              assign
                buf_rvs-line.real-date = v-today
                buf_rvs-line.real-time = v-time
              .
              
              if pRvsType = {&rvs-before-doc}
              then do:
                v-prt-start-real-date = buf_rvs-line.real-date .
                v-prt-start-real-time = buf_rvs-line.real-time .
              end.
              else do:
                v-prt-end-real-date = buf_rvs-line.real-date .
                v-prt-end-real-time = buf_rvs-line.real-time .
              end.
              
              waitForm = new ibs.th.str.ptrl.forms.waitform("~r~nОпрос ТРК...") .
              waitForm:Show() .
              if varcur-rvs = 1
              or ptoldfilvalue <> "yes":u
              then do :
                { str/anls-pmp.i
                  infoSecsObj:Parentproc
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  yes
                  tt-pump-nozzle-file
                  tt-pump-nozzle
                  yes
                  ?
                  yes
                  no-error
                }
              end.
              else do :
                { str/anls-pmp.i
                  infoSecsObj:Parentproc
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  yes
                  tt-pump-nozzle-file
                  tt-pump-nozzle
                  no
                  ?
                  yes
                  no-error
                }
              end.
              waitForm:Close() .
              delete object waitForm no-error .
              
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
              buf_rvs-doc.obj-type
              buf_rvs-doc.obj-code
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
  
            cur-time
              ( output v-today
              , output v-time
              ) .
            { gbl/curobjdt.i
              buf_rvs-doc.obj-type
              buf_rvs-doc.obj-code
              v-today
            }
  
            assign
              buf_rvs-line.real-date = v-today
              buf_rvs-line.real-time = v-time
            .
            
            infoSecsObj:CalculateTotal().
            if pRvsType = {&rvs-before-doc}  then do:
              v-prt-start-real-date = buf_rvs-line.real-date .
              v-prt-start-real-time = buf_rvs-line.real-time .
            end.
            else do:
              v-prt-end-real-date = buf_rvs-line.real-date .
              v-prt-end-real-time = buf_rvs-line.real-time .
            end.
            
            waitForm = new ibs.th.str.ptrl.forms.waitform("~r~nОпрос ТРК...") .
            waitForm:Show() .
            if varcur-rvs = 1
            or ptoldfilvalue <> "yes":u
            then do :
              { str/anls-pmp.i
                infoSecsObj:Parentproc
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
                yes
                tt-pump-nozzle-file
                tt-pump-nozzle
                yes
                ?
                yes
                no-error
              }
            end.
            else do :
              { str/anls-pmp.i
                infoSecsObj:Parentproc
                buf_rvs-doc.obj-type
                buf_rvs-doc.obj-code
                yes
                tt-pump-nozzle-file
                tt-pump-nozzle
                no
                ?
                yes
                no-error
              }
            end.
            waitForm:Close() .
            delete object waitForm no-error .
              
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
  /*          for each tt-pump-nozzle where not (tt-pump-nozzle.meas-el-cnt > 0) :                                                                      */
  /*            v-pump-err = v-pump-err + "ТРК " + string(tt-pump-nozzle.pump-code) + " Пистолету " + string(tt-pump-nozzle.nozzle-code) + {&new-line} .*/
  /*          end. /* for each tt-pump-nozzle */                                                                                                        */
  /*          if v-pump-err > ""                                                                                                                        */
  /*          then do :                                                                                                                                 */
  /*            message "Данные по:" + {&new-line} + v-pump-err + "Не получены." view-as alert-box .                                                    */
  /*          end .                                                                                                                                     */
            
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
        end.
        when "edit":U then do:
          if not available buf_rvs-line
          then do :
            find first buf_rvs-line exclusive-lock
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
              and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
              and buf_rvs-line.pl-code  = v-pl-code
              and buf_rvs-line.gds-code = buf_goods.gds-code
            .
          end .
          run str/rvs-lin.w
            (input  infoSecsObj:Parentproc
            ,input  recid( buf_rvs-line )
            ,input  pAction
            ,input  substitute(" # &1 товар &2 &3 &4  складское место &5"
                              ,buf_rvs-doc.rvs-code
                              ,buf_goods.artic
                              ,buf_goods.prod-type
                              ,buf_goods.prod-code
                              ,v-pl-code)) no-error.
          if error-status :error then do:
            message
              "Ошибка при редактировании строки сверки." skip
              return-value skip
              error-status :get-message(1) skip
              view-as alert-box error .
            undo block_tr, return error .
          end.
          if return-value = "cancel":U
            and pAction <> {&lookup}
          then do:
            undo block_tr, return error .
          end.
          
          if pAction <> {&lookup}
          then do :
            cur-time
              ( output v-today
              , output v-time
              ) .
  
            assign
              buf_rvs-line.real-date = v-today
              buf_rvs-line.real-time = v-time
            .
            infoSecsObj:CalculateTotal().
            if pRvsType = {&rvs-before-doc}
            then do:
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
            
            if varcur-rvs <> 3
            then do :
              waitForm = new ibs.th.str.ptrl.forms.waitform("~r~nОпрос ТРК...") .
              waitForm:Show() .
              if varcur-rvs = 1
              or ptoldfilvalue <> "yes":u
              then do :
                { str/anls-pmp.i
                  infoSecsObj:Parentproc
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  yes
                  tt-pump-nozzle-file
                  tt-pump-nozzle
                  yes
                  ?
                  yes
                  no-error
                }
              end.
              else do :
                { str/anls-pmp.i
                  infoSecsObj:Parentproc
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  yes
                  tt-pump-nozzle-file
                  tt-pump-nozzle
                  no
                  ?
                  yes
                  no-error
                }
              end.
              waitForm:Close() .
              delete object waitForm no-error .
              
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
  /*            for each tt-pump-nozzle where not (tt-pump-nozzle.meas-el-cnt > 0) :                                                                      */
  /*              v-pump-err = v-pump-err + "ТРК " + string(tt-pump-nozzle.pump-code) + " Пистолету " + string(tt-pump-nozzle.nozzle-code) + {&new-line} .*/
  /*            end. /* for each tt-pump-nozzle */                                                                                                        */
  /*            if v-pump-err > ""                                                                                                                        */
  /*            then do :                                                                                                                                 */
  /*              message "Данные по:" + {&new-line} + v-pump-err + "Не получены." view-as alert-box .                                                    */
  /*            end .                                                                                                                                     */
              
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
      end case.
      
       
      if not pAction = {&lookup}
      then do :
        infoSecsObj:GetInfoSectionProp(idSecTabPage) .
        if pRvsType = {&rvs-before-doc}
        then do:
          infoSecsObj:InfoSectionCurr:DateStart = v-prt-start-real-date . 
          infoSecsObj:InfoSectionCurr:TimeStart = v-prt-start-real-time . 
        end .
        else do :
          infoSecsObj:InfoSectionCurr:DateEnd   = v-prt-end-real-date . 
          infoSecsObj:InfoSectionCurr:TimeEnd   = v-prt-end-real-time .
        end .
        infoSecsObj:InfoSectionCurr:TankWeightRvs = ? .
        infoSecsObj:InfoSectionCurr:TankVolPomiRvs = ? .
        infoSecsObj:InfoSectionCurr:AvgTempRvs = ? .
      end.
      infoSecsObj:SaveDB().
      
      if not available buf_rvs-line
      then do :
        find first buf_rvs-line exclusive-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
          and buf_rvs-line.pl-code  = v-pl-code
          and buf_rvs-line.gds-code = buf_goods.gds-code
        .
      end .
      
      if pAction = {&update} then do:
        if pActionType = "meas":U then do:
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

        return-rvs-qnty 
          ( input infoSecsObj:TrnDocNum
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
        
        if pRvsType = {&rvs-after-doc} then do:
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
                "Масса не рассчитана. Не задана плотность в сверке <<после_док>>"
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
              substitute( "Место хранения: &1 .", v-pl-code ) skip
              substitute( "Количество залитого топлива: &1 (&2).", v-rvs-cli-qnty-after - v-rvs-cli-qnty-before, buf_goods.unit-cli ) skip
              substitute( "Масса в сверке до: &1 ", v-rvs-cli-qnty-before ) skip
              substitute( "Масса в сверке после: &1 ", v-rvs-cli-qnty-after ) skip
              view-as alert-box .
            undo block_tr, return error .
          end.

          assign
            v-rvs-density = (v-rvs-cli-qnty-after - v-rvs-cli-qnty-before) / (v-rvs-qnty-after - v-rvs-qnty-before)
          .
          if Valid-Density( v-rvs-density ) <> true then do:
            message
              substitute( "Ошибка по результатам сверки." ) skip
              substitute( "Место хранения: &1 .", v-pl-code ) skip
              substitute( "Плотность залитого топлива: &1.", v-rvs-density ) skip
              view-as alert-box .
            undo block_tr, return error .
          end.
              
              
        end. /* v-rvs-qnty-after <> ? */
      end.
    end. /* on error */
  end method .
  
  method private void check-before
    (input pDocCode as character,
     input pGdsCode as integer,
     input pPlCode  as integer)
  :
    define buffer buf_goods         for ub.goods .
    define buffer bf_after_rvs-doc  for ub.rvs-doc  .
    define buffer bf_after_rvs-line for ub.rvs-line .
    define buffer bf_before_rvs-doc  for ub.rvs-doc  .
    define buffer bf_before_rvs-line for ub.rvs-line .
    
    define variable ii as integer no-undo .
    define variable v-sec as character no-undo .
    
    define variable infoSecObj as class InfoSection no-undo .

    find first buf_goods no-lock
      where buf_goods.gds-code = pGdsCode
      .
      
    infoSecObj = infoSecsObj:GetInfoSectionProp(idSecTabPage) .
      
    v-sec = infoSecObj:SectionName .
    
    for each bf_before_rvs-doc no-lock where bf_before_rvs-doc.rvs-type = {&rvs-before-doc}
                                         and bf_before_rvs-doc.out-code = pDocCode
                                         and num-entries(bf_before_rvs-doc.rvs-code, "-") = 3
                                         and entry(2, bf_before_rvs-doc.rvs-code, "-") <> v-sec
    :
      for each bf_before_rvs-line no-lock where bf_before_rvs-line.rvs-code = bf_before_rvs-doc.rvs-code
                                            and bf_before_rvs-line.obj-type = bf_before_rvs-doc.obj-type
                                            and bf_before_rvs-line.obj-code = bf_before_rvs-doc.obj-code
                                            and bf_before_rvs-line.pl-code  = pPlCode
                                            and bf_before_rvs-line.gds-code = buf_goods.gds-code
                                            and bf_before_rvs-line.state-measure-cli-qnty <> ?
      :
        find first bf_after_rvs-doc no-lock where bf_after_rvs-doc.rvs-type = {&rvs-after-doc}
                                              and bf_after_rvs-doc.out-code = pDocCode
                                              and num-entries(bf_after_rvs-doc.rvs-code, "-") = 3
                                              and entry(2, bf_after_rvs-doc.rvs-code, "-") = entry(2, bf_before_rvs-doc.rvs-code, "-")
                                              no-error .
        if not available bf_after_rvs-doc
        then do :
          message
            "Не найдена сверка <<после налива топлива>> "
            "по секции" v-sec ". "
            "Следует удалить сверки и создать их снова. "
          view-as alert-box error .
          return error .
        end .
        find first bf_after_rvs-line no-lock where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
                                               and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
                                               and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
                                               and bf_after_rvs-line.pl-code  = pPlCode
                                               and bf_after_rvs-line.gds-code = buf_goods.gds-code
                                               and bf_after_rvs-line.state-measure-cli-qnty <> ?
                                               no-error .
        if not available bf_after_rvs-line
        then do :
          message
            "Не заполнена сверка «После» по секции " entry(2, bf_after_rvs-doc.rvs-code, "-")
          view-as alert-box .
          return error .
        end .
      end .
    end .
    
    find first bf_after_rvs-doc no-lock
      where bf_after_rvs-doc.rvs-type = {&rvs-after-doc}
        and bf_after_rvs-doc.out-code = pDocCode
        and num-entries(bf_after_rvs-doc.rvs-code, "-") = 3
        and entry(2, bf_after_rvs-doc.rvs-code, "-") = v-sec
      no-error .
    if available bf_after_rvs-doc then do:
      find first bf_after_rvs-line no-lock
        where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
          and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
          and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
          and bf_after_rvs-line.pl-code  = pPlCode
          and bf_after_rvs-line.gds-code = buf_goods.gds-code
        no-error .
      if not available bf_after_rvs-line then do:
        message
          "По данному товару нет заготовки для сверки <<после налива топлива>>"
          "по резервуару" pPlCode "."
          view-as alert-box error .
        return error .
      end.
      if bf_after_rvs-line.state-measure-cli-qnty <> ? then do:
        message
          "Уже задан фактический остаток в сверке <<после налива топлива>>"
          "по резервуару" pPlCode "."
          "Следует удалить сверки и создать их снова."
          view-as alert-box error .
        return error .
      end.
    end. /* if available bf_after_rvs-doc */
    else do:
      message "Не создана сверка <<после налива топлива>>." view-as alert-box error .
      return error .
    end.
  end method .
  
  method private void check-after
    (input pDocCode as character,
     input pGdsCode as integer,
     input pPlCode  as integer)
  :
    define buffer buf_goods         for ub.goods .
    define buffer bf_after_rvs-doc  for ub.rvs-doc  .
    define buffer bf_after_rvs-line for ub.rvs-line .
    define buffer bf_before_rvs-doc  for ub.rvs-doc  .
    define buffer bf_before_rvs-line for ub.rvs-line .
    define buffer bf2_before_rvs-doc  for ub.rvs-doc  .
    define buffer bf2_before_rvs-line for ub.rvs-line .
    
    define variable ii as integer no-undo .
    define variable v-sec as character no-undo .
    
    define variable infoSecObj as class InfoSection no-undo .
    
    find first buf_goods no-lock
      where buf_goods.gds-code = pGdsCode
      .
      
    infoSecObj = infoSecsObj:GetInfoSectionProp(idSecTabPage) .
      
    v-sec = infoSecObj:SectionName .
      
    find first bf_before_rvs-doc no-lock
      where bf_before_rvs-doc.rvs-type = {&rvs-before-doc}
        and bf_before_rvs-doc.out-code = pDocCode
        and num-entries(bf_before_rvs-doc.rvs-code, "-") = 3
        and entry(2, bf_before_rvs-doc.rvs-code, "-") = v-sec
      no-error .
    if available bf_before_rvs-doc then do:
      find first bf_before_rvs-line no-lock
        where bf_before_rvs-line.rvs-code = bf_before_rvs-doc.rvs-code
          and bf_before_rvs-line.obj-type = bf_before_rvs-doc.obj-type
          and bf_before_rvs-line.obj-code = bf_before_rvs-doc.obj-code
          and bf_before_rvs-line.pl-code  = pPlCode
          and bf_before_rvs-line.gds-code = pGdsCode
        no-error .
      if not available bf_before_rvs-line then do:
        message
          "По данному товару нет заготовки для сверки <<до налива топлива>>"
          "по резервуару" pPlCode "."
          view-as alert-box error .
        return error .
      end.
      if bf_before_rvs-line.state-measure-cli-qnty = ?
      then do:
        message
          "Не задан фактический остаток в сверке <<до налива топлива>>"
          "по резервуару" pPlCode "." skip
          "Следует удалить сверки и создать их снова."
          view-as alert-box error .
        return error .
      end.
      if bf_before_rvs-line.state-density = ?
      then do:
        message
          "Не задана фактическая плотность в сверке <<до налива топлива>>"
          "по резервуару" pPlCode "." skip
          "Следует удалить сверки и создать их снова."
          view-as alert-box error .
        return error .
      end.
    end. /* if available bf_before_rvs-doc */
    else do:
      message "Не создана сверка <<до налива топлива>>." view-as alert-box error .
      return error .
    end.
    
    for each bf_before_rvs-doc no-lock where bf_before_rvs-doc.rvs-type = {&rvs-before-doc}
                                         and bf_before_rvs-doc.out-code = pDocCode
                                         and num-entries(bf_before_rvs-doc.rvs-code, "-") = 3
                                         and entry(2, bf_before_rvs-doc.rvs-code, "-") <> v-sec
    :
      for each bf_before_rvs-line no-lock where bf_before_rvs-line.rvs-code = bf_before_rvs-doc.rvs-code
                                            and bf_before_rvs-line.obj-type = bf_before_rvs-doc.obj-type
                                            and bf_before_rvs-line.obj-code = bf_before_rvs-doc.obj-code
                                            and bf_before_rvs-line.pl-code  = pPlCode
                                            and bf_before_rvs-line.gds-code = buf_goods.gds-code
                                            and bf_before_rvs-line.state-measure-cli-qnty <> ?
      :
        find first bf_after_rvs-doc no-lock where bf_after_rvs-doc.rvs-type = {&rvs-after-doc}
                                              and bf_after_rvs-doc.out-code = pDocCode
                                              and num-entries(bf_after_rvs-doc.rvs-code, "-") = 3
                                              and entry(2, bf_after_rvs-doc.rvs-code, "-") = entry(2, bf_before_rvs-doc.rvs-code, "-")
                                              no-error .
        if not available bf_after_rvs-doc
        then do :
          message
            "Не найдена сверка <<после налива топлива>> "
            "по секции" v-sec ". "
            "Следует удалить сверки и создать их снова. "
          view-as alert-box error .
          return error .
        end .
        find first bf_after_rvs-line no-lock where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
                                               and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
                                               and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
                                               and bf_after_rvs-line.pl-code  = pPlCode
                                               and bf_after_rvs-line.gds-code = buf_goods.gds-code
                                               and bf_after_rvs-line.state-measure-cli-qnty <> ?
                                               no-error .
        if not available bf_after_rvs-line
        then do :
          message
            "Не заполнена сверка «После» по секции " entry(2, bf_after_rvs-doc.rvs-code, "-")
          view-as alert-box .
          return error .
        end .
      end .
    end .
    
    find first bf_after_rvs-doc no-lock
      where bf_after_rvs-doc.rvs-type = {&rvs-after-doc}
        and bf_after_rvs-doc.out-code = pDocCode
        and num-entries(bf_after_rvs-doc.rvs-code, "-") = 3
        and entry(2, bf_after_rvs-doc.rvs-code, "-") = v-sec
      no-error .
    if available bf_after_rvs-doc
    then do:
      find first bf_after_rvs-line no-lock
        where bf_after_rvs-line.rvs-code = bf_after_rvs-doc.rvs-code
          and bf_after_rvs-line.obj-type = bf_after_rvs-doc.obj-type
          and bf_after_rvs-line.obj-code = bf_after_rvs-doc.obj-code
          and bf_after_rvs-line.pl-code  = pPlCode
          and bf_after_rvs-line.gds-code = buf_goods.gds-code
        no-error .
      if available bf_after_rvs-line
      then do :
        for each bf2_before_rvs-doc no-lock where bf2_before_rvs-doc.rvs-type = {&rvs-before-doc}
                                              and bf2_before_rvs-doc.out-code = pDocCode
                                              and num-entries(bf2_before_rvs-doc.rvs-code, "-") = 3
                                              and entry(2, bf2_before_rvs-doc.rvs-code, "-") <> v-sec
        :
          find first bf2_before_rvs-line no-lock where bf2_before_rvs-line.rvs-code = bf2_before_rvs-doc.rvs-code
                                                   and bf2_before_rvs-line.obj-type = bf2_before_rvs-doc.obj-type
                                                   and bf2_before_rvs-line.obj-code = bf2_before_rvs-doc.obj-code
                                                   and bf2_before_rvs-line.pl-code  = pPlCode
                                                   and bf2_before_rvs-line.gds-code = buf_goods.gds-code
                                                   and bf2_before_rvs-line.state-measure-cli-qnty <> ?
                                                   and ((bf2_before_rvs-line.real-date > bf_after_rvs-line.real-date)
                                                     or (bf2_before_rvs-line.real-date = bf_after_rvs-line.real-date
                                                     and bf2_before_rvs-line.real-time > bf_after_rvs-line.real-time))
                                                   no-error .
          if available bf2_before_rvs-line
          then do :
            message
              "Уже заполнена сверка «До» по секции " entry(2, bf2_before_rvs-doc.rvs-code, "-")
              " Следует удалить сверки и создать их снова. "
            view-as alert-box .
            return error .
          end .
        end .
      end .
    end .
    
  end method . 
  
  method void return-rvs-qnty
    (input pDocCode as character,
     input pGdsCode as integer,
     input pPlCode  as integer,
     output p-rvs-qnty-before     like ub.rvs-line.state-measure-qnty,
     output p-rvs-qnty-after      like ub.rvs-line.state-measure-qnty,
     output p-rvs-cli-qnty-before like ub.rvs-line.state-measure-cli-qnty,
     output p-rvs-cli-qnty-after  like ub.rvs-line.state-measure-cli-qnty)
  :
    define buffer bf_bef_rvs-doc  for ub.rvs-doc  .
    define buffer bf_aft_rvs-doc  for ub.rvs-doc  .
    define buffer bf_bef_rvs-line for ub.rvs-line .
    define buffer bf_aft_rvs-line for ub.rvs-line .
    
    define variable v-sec as character no-undo .
    define variable infoSecObj as class InfoSection no-undo .
    
    infoSecObj = infoSecsObj:GetInfoSectionProp(idSecTabPage) .
      
    v-sec = infoSecObj:SectionName .
    
    assign
      p-rvs-qnty-before     = 0.0
      p-rvs-qnty-after      = 0.0
      p-rvs-cli-qnty-before = 0.0
      p-rvs-cli-qnty-after  = 0.0
    .
    find first bf_bef_rvs-doc no-lock
      where bf_bef_rvs-doc.rvs-type = {&rvs-before-doc}
        and bf_bef_rvs-doc.out-code = pDocCode
        and num-entries(bf_bef_rvs-doc.rvs-code, "-") = 3
        and entry(2, bf_bef_rvs-doc.rvs-code, "-") = v-sec
      no-error .
    if available bf_bef_rvs-doc then do:
      for each bf_bef_rvs-line no-lock
        where bf_bef_rvs-line.rvs-code = bf_bef_rvs-doc.rvs-code
          and bf_bef_rvs-line.obj-type = bf_bef_rvs-doc.obj-type
          and bf_bef_rvs-line.obj-code = bf_bef_rvs-doc.obj-code
          and bf_bef_rvs-line.gds-code = pGdsCode
          and bf_bef_rvs-line.pl-code  = pPlCode
      :
        assign
          p-rvs-qnty-before     = p-rvs-qnty-before     + bf_bef_rvs-line.state-measure-qnty
          p-rvs-cli-qnty-before = p-rvs-cli-qnty-before + bf_bef_rvs-line.state-measure-cli-qnty
        .
      end. /* for each bf_bef_rvs-line */
    end. /* if available bf_bef_rvs-doc */
    find first bf_aft_rvs-doc no-lock
      where bf_aft_rvs-doc.rvs-type = {&rvs-after-doc}
        and bf_aft_rvs-doc.out-code = pDocCode
        and num-entries(bf_aft_rvs-doc.rvs-code, "-") = 3
        and entry(2, bf_aft_rvs-doc.rvs-code, "-") = v-sec
      no-error .
    if available bf_aft_rvs-doc then do:
      for each bf_aft_rvs-line no-lock
        where bf_aft_rvs-line.rvs-code = bf_aft_rvs-doc.rvs-code
          and bf_aft_rvs-line.obj-type = bf_aft_rvs-doc.obj-type
          and bf_aft_rvs-line.obj-code = bf_aft_rvs-doc.obj-code
          and bf_aft_rvs-line.gds-code = pGdsCode
          and bf_aft_rvs-line.pl-code  = pPlCode
      :
        assign
          p-rvs-qnty-after     = p-rvs-qnty-after     + bf_aft_rvs-line.state-measure-qnty
          p-rvs-cli-qnty-after = p-rvs-cli-qnty-after + bf_aft_rvs-line.state-measure-cli-qnty
        .
      end. /* for each bf_aft_rvs-line */
    end. /* if available bf_aft_rvs-doc */
    
  end method .
  
  method logical chk-asi-polling
    (input is-bef as log )
  :
    
    define buffer bf_rsv for ub.rvs-doc .
    define variable v-sec as character no-undo .
      
    v-sec = infoSecsObj:GetInfoSectionProp(idSecTabPage):SectionName .
    
    find first bf_rsv 
      no-lock where bf_rsv.rvs-type = (if is-bef then {&rvs-before-doc} else {&rvs-after-doc}) 
      and bf_rsv.out-code = infoSecsObj:TrnDocNum
      and num-entries(bf_rsv.rvs-code, "-") = 3
      and entry(2, bf_rsv.rvs-code, "-") = v-sec
      and bf_rsv.state-measure-qnty <> ?
      no-error .
              
    if available (bf_rsv) and not infoSecsObj:lRepeatAsi
      then 
    do:
      message
        infoSecsObj:mRepeatAsi
        view-as alert-box information title "".              
      return no .
    end.
    else return yes.
    
  end method .
  
  method character db-attr-value
    (input pDbNum as integer,
     input pAttrCode as character)
  :
    define buffer buf_db-attr for ub.db-attr .
    
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = pDbNum
        and buf_db-attr.attr-code = pAttrCode
      no-error .
    if avail buf_db-attr then do:
      return buf_db-attr.attr-value .
    end.
    
    return "" .
  end method .
