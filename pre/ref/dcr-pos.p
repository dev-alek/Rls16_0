block-level on error undo, throw.
define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-sts as integer no-undo .
define input parameter p-rule-num as integer no-undo .
define output parameter p-pos-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcr-pos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcr-pos.p $":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-cont-det-pos as logical no-undo .
define variable v-ii as integer no-undo .
define variable glog as logical no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-thbj-rule  for ub.dis-thbj-rule.
if can-find( first ub.dis-cfg-rule no-lock where
                   ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
               and ub.dis-cfg-rule.table-name = 'dis-thbj-rule':U)
or p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-sts <> integer('1':U) then do:
      if can-find( first ub.dis-cfg-rule no-lock where
                        ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
                    and ub.dis-cfg-rule.table-name = 'dis-thbj-rule':U) then do:
        find first buf_dis-thbj-rule no-lock where
                  buf_dis-thbj-rule.host-code = p-host-code
              and buf_dis-thbj-rule.obj-type = p-obj-type
              and buf_dis-thbj-rule.obj-code = p-obj-code
              and buf_dis-thbj-rule.rule-num = p-rule-num no-error.
        if not available buf_Dis-thbj-rule then do:
          p-pos-type = '':U.
          v-cont-det-pos = yes.
        end.
        else do:
          p-pos-type = buf_Dis-thbj-rule.pos-type.
        end.
      end.
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U
  or v-cont-det-pos then do:
    _v-ii:
    do v-ii = 1 to num-entries('bo':U):
      find first  buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and buf_dis-cfg-rule.pos-type = entry(v-ii, 'bo':U) no-error .
      if available buf_dis-cfg-rule then do:
        assign
        p-pos-type = buf_dis-cfg-rule.pos-type.
        leave _v-ii.
      end.
    end.
    if p-pos-type = '':U then do:
      if p-obj-code > 0 then do:
        if p-obj-type = 'скл':U then do:
          p-pos-type = '-':U.
        end.
        else do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type0 as character no-undo .
define variable v-value-date0 as date no-undo .
define variable v-value-decimal0 as decimal no-undo .
define variable v-value-integer0 as INTEGER no-undo .
define variable v-value-logical0 AS LOGICAL no-undo .
define variable v-tth0 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date0
    ,output v-value-decimal0
    ,output v-value-integer0
    ,output v-value-logical0
    ,output v-param-type0
    ,INPUT-OUTPUT table-handle v-tth0
    )  .
delete object v-tth0 no-error.
            find first  buf_dis-cfg-rule no-lock where
                      buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                  and buf_dis-cfg-rule.pos-type = p-pos-type no-error .
          if not available buf_dis-cfg-rule then do:
            find first  buf_dis-cfg-rule no-lock where
                      buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                  and buf_dis-cfg-rule.pos-type = '-':U no-error .
            if available buf_dis-cfg-rule then do:
              if p-mode <> 'ПРОСМОТР':U then do:
                if not p-silent then do:
                  message
                  substitute("Правило скидки по данному шаблону неприменимо для типа касс, работающих на &1&2&3" +
                              "использование данного правила будет возможно только при расчете скидок по накладной&3" +
                              "все равно хотите добавить/изменить правило скидки?"
                              ,p-obj-type
                              ,p-obj-code
                              ,chr(10))
                  view-as alert-box question buttons yes-no update glog.
                  if not glog then undo,  return error.
                end.
              end.
              p-pos-type = buf_dis-cfg-rule.pos-type.
            end.
            else do:
              if p-mode <> 'ПРОСМОТР':U and p-pos-type = '' then do:
                message
                substitute("Правило скидки по данному шаблону невозможно ввести:&1" +
                            "неопределено для какого типа касс возможно его использование&1"
                            ,chr(10))
                view-as alert-box error .
                undo,  return error.
              end.
            end.
          end.
        end.
      end.
      else do:
        if p-mode <> 'ПРОСМОТР':U then do:
          find   buf_dis-cfg-rule no-lock where
                    buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
                and buf_dis-cfg-rule.pos-type <> '-':U no-error .
          if not available buf_dis-cfg-rule
          and ambiguous  buf_Dis-cfg-rule then do:
            run ref/sel-cdt.w ( input p-templ-rl-root
                              ,output p-pos-type) no-error.
            if p-pos-type = '':U then do:
              return error.
            end.
          end.
          else do:
            p-pos-type = buf_dis-cfg-rule.pos-type.
          end.
        end.
      end.
    end.
  end.
  if p-pos-type = '':U
  and p-mode <> 'ПРОСМОТР':U
  then do:
    return error substitute("Не удалось определить место действия для правила скидки &1", p-rule-num).
  end.
end.
