block-level on error undo, throw.
define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.dis-gds-rule.gds-code no-undo .
define input parameter p-obj-type        like ub.dis-gds-rule.obj-type no-undo .
define input parameter p-obj-code        like ub.dis-gds-rule.obj-code no-undo .
define temp-table tt0-dis-gds-rule no-undo like ub.dis-gds-rule.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-gds-rule.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disgdsr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/disgdsr1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений скидок товара на объекте".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,p-gds-code,p-obj-type,p-obj-code)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str0  as character no-undo.
  define variable tmp-num0  as character no-undo.
  define variable i0        as integer   no-undo.
  define variable sum0      as integer   no-undo.
  define variable len-code0 as integer   no-undo.
  define variable varcont0  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str0 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str0 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont0 = yes then do:
    if integer( substring( tmp-str0, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str0, length( bc-pfx ) + 1, length( tmp-str0 ) - length( bc-pfx ) )
        len-code0    = length( full-b-code )
      .
      define variable v-sum-char0 as character no-undo .
      assign
        sum0 = 0
      .
      do i0 = 1 to len-code0 by 2
      :
        assign
          v-sum-char0 = substr(full-b-code, len-code0 - i0 + 1, 1)
        .
        if v-sum-char0 < "0"
        or v-sum-char0 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum0 = sum0 + integer(v-sum-char0)
        .
      end.
      if varcont0 = yes then do:
        assign
          sum0 = sum0 * 3
        .
        do i0 = 2 to len-code0 by 2
        :
          assign
            v-sum-char0 = substr(full-b-code, len-code0 - i0 + 1, 1)
          .
          if v-sum-char0 < "0"
          or v-sum-char0 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum0 = sum0 + integer(v-sum-char0)
          .
        end.
        if varcont0 = yes then do:
           if sum0 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum0 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cr_dis-gds-rule-attr :
def input parameter v-recid-rule-gds as int no-undo .
def buffer buf_dis-gds-rule-attr for dis-gds-rule-attr .
def buffer buf_dis-gds-rule for dis-gds-rule .
def buffer buf_bar-code for ub.bar-code .
def buffer buf_prod-bc  for prod-bc .
def buffer buf_templ-dis-rule for dis-rule .
def buffer buf_templ-dis-time-rule for dis-time-rule .
def buffer buf_dis-cfg-rule   for dis-cfg-rule .
def buffer buf_dis-rule   for dis-rule .
define variable v-upd as character no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .
find buf_dis-gds-rule no-lock where recid(buf_dis-gds-rule) = v-recid-rule-gds  no-error.
if avail buf_dis-gds-rule then
do:
  find first buf_dis-rule no-lock where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num  no-error .
  find first buf_templ-dis-rule no-lock where buf_templ-dis-rule.rule-num = buf_dis-rule.templ-rl-root  no-error .
  if avail buf_templ-dis-rule and avail buf_dis-rule then
  do:
     find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.table-name = "dis-gds-rule"
            and buf_dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
            and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            and buf_dis-cfg-rule.time-templ-rl-root =  buf_dis-rule.time-templ-rl-root
            and buf_dis-cfg-rule.self-nonunique = ""
            and buf_dis-cfg-rule.nonunique = "bar-code.b-code"
            no-error.
     if avail buf_dis-cfg-rule then
     do:
       find first buf_bar-code no-lock where buf_bar-code.b-code = integer(buf_dis-gds-rule.nonunique) no-error.
       if avail buf_bar-code then
       do:
          run gen-bc(input buf_bar-code.b-code,output v-bar-code) .
          for each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code :
            if buf_prod-bc.bc-on = yes then
            do:
               v-upd = 'A' .
            end.
            else
            do:
               v-upd = "D" .
            end.
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = buf_prod-bc.b-str
                 exclusive-lock no-error .
            if (not avail buf_dis-gds-rule-attr) and (not locked buf_dis-gds-rule-attr) then
            do:
                if v-upd = "A" then
                do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                    .
                end.
            end.
            else
            do:
              if avail buf_dis-gds-rule-attr and  buf_dis-gds-rule-attr.attr-value <> v-upd then
              do:
               assign
                buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                .
              end.
            end.
          end.
          if v-bar-code <> '' then
          do:
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                 exclusive-lock no-error .
            if not avail buf_dis-gds-rule-attr  then
            do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = v-bar-code + "," + "A"
                    .
            end.
          end.
          for each  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
             find first buf_prod-bc no-lock where
                  buf_prod-bc.b-str = entry(1,buf_dis-gds-rule-attr.attr-value,",")
                     and can-find(first buf_bar-code where buf_bar-code.b-code = int(buf_dis-gds-rule.nonunique))
                     no-error.
             if not avail buf_prod-bc or (avail buf_prod-bc and buf_prod-bc.bc-on = no) then
             do:
               if entry(1,buf_dis-gds-rule-attr.attr-value,",") <> v-bar-code then
               do:
                 v-upd = "D" .
                 if buf_dis-gds-rule-attr.attr-value <> v-upd then
                 do:
                   assign
                   buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                   .
                 end.
               end.
             end.
          end.
       end.
     end.
  end.
end.
end procedure .
procedure def-number-action :
  define input  parameter p-templ-rl-root as int no-undo .
  define output parameter p-number-action as char no-undo .
  define variable v-action as integer   no-undo .
  def buffer buf_dis-rule-attr for dis-rule-attr .
  find first buf_dis-rule-attr exclusive-lock where buf_dis-rule-attr.rule-num = p-templ-rl-root
                                       and buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
                                       no-error.
  if not avail buf_dis-rule-attr then
  do:
    create buf_dis-rule-attr .
    assign
       buf_dis-rule-attr.rule-num = p-templ-rl-root
       buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
       buf_dis-rule-attr.attr-value = "3100101"
       p-number-action = buf_dis-rule-attr.attr-value
       .
  end.
  else
  do:
     v-action = integer(buf_dis-rule-attr.attr-value) no-error .
     if error-status:error = no then
     do:
       assign
          v-action = v-action + 1
          buf_dis-rule-attr.attr-value = string(v-action)
          p-number-action = buf_dis-rule-attr.attr-value
          .
     end.
  end.
end procedure.
define variable v-deleted as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-bb-list  as character no-undo .
define variable v-cnt      as integer   no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code          for ub.bar-code.
define buffer buf_prod-bc           for ub.prod-bc.
do v-cnt = 2 to num-entries(p-mode, chr(44)):
    if entry( v-cnt, p-mode, chr(44) ) begins "dk" then do:
        find first buf_prod-bc no-lock where recid(buf_prod-bc) = int( substring( entry( v-cnt, p-mode, chr(44) ), 3 ) ) no-error .
        if avail buf_prod-bc then do:
            v-bb-list = v-bb-list + ( if v-bb-list = "":U then "":U else chr(44) ) + buf_prod-bc.b-str .
        end.
    end.
    else do:
        find first buf_bar-code no-lock where recid(buf_bar-code) = int( entry( v-cnt, p-mode, chr(44) ) ) no-error .
        if avail buf_bar-code then do:
            v-bb-list = v-bb-list + ( if v-bb-list = "":U then "":U else chr(44) ) + string( buf_bar-code.b-code ) .
        end.
    end.
end.
p-mode = entry( 1, p-mode, chr(44) ) .
_main:
do
on error undo, return error return-value
:
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    undo, return error substitute("&1 &2 &3&4Не найден товар с кодом &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , chr(10)
                                 , p-gds-code).
  end.
  FOR EACH tt0-dis-gds-rule
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
    if tt0-dis-gds-rule.obj-type = 'орг':U and g#db-num <> 0 then next.
    if tt0-dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      find FIRST buf_dis-gds-rule WHERE
                buf_dis-gds-rule.gds-code = p-gds-code
            AND buf_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
            AND buf_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
            AND buf_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
            AND buf_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
            and buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
            no-error.
    end.
    IF p-mode = 'ДОБАВЛЕНИЕ':U
    or not available buf_dis-gds-rule
    or buf_dis-gds-rule.rule-num <> tt0-dis-gds-rule.rule-num THEN DO:
      if p-mode = 'ДОБАВЛЕНИЕ':U
      or not available buf_dis-gds-rule then do:
        create buf_Dis-gds-rule.
        assign
        buf_dis-gds-rule.gds-code = p-gds-code
        buf_dis-gds-rule.obj-type = tt0-dis-gds-rule.obj-type
        buf_dis-gds-rule.obj-code = tt0-dis-gds-rule.obj-code
        buf_dis-gds-rule.pos-type = tt0-dis-gds-rule.pos-type
        buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
        buf_dis-gds-rule.discnt-role = tt0-dis-gds-rule.discnt-role
        .
      end.
      assign
      buf_dis-gds-rule.rule-num = tt0-dis-gds-rule.rule-num
      buf_dis-gds-rule.rl-root = tt0-dis-gds-rule.rule-num
      buf_dis-gds-rule.time-templ-rl-root = tt0-dis-gds-rule.time-templ-rl-root
      buf_dis-gds-rule.nonunique = tt0-dis-gds-rule.nonunique
      buf_dis-gds-rule.templ-rl-root = tt0-dis-gds-rule.templ-rl-root
      buf_dis-gds-rule.time-templ-rl-root = tt0-dis-gds-rule.time-templ-rl-root
      .
      if buf_dis-gds-rule.templ-rl-root = 91 then do:
                 do v-cnt = 1 to num-entries(v-bb-list, chr(44)):
                   v-bar-code = entry( v-cnt, v-bb-list, chr(44) ) .
                   find first buf_dis-gds-rule-attr exclusive-lock
                   where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                     and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                     and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                     and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                     and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                     and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                   no-error.
                   if not avail buf_dis-gds-rule-attr then do:
                      create buf_dis-gds-rule-attr .
      end.
                   run def-number-action(buf_dis-gds-rule.templ-rl-root, output v-number-action) .
                   assign
                    buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
                    buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
                    buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
                    buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
                    buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                    buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
                    buf_dis-gds-rule-attr.attr-code   = v-number-action
                    buf_dis-gds-rule-attr.attr-value  = v-bar-code + ",A"
                   .
                 end.
      end.
      release buf_dis-gds-rule no-error.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                ,tt0-dis-gds-rule.templ-rl-root
                                ,tt0-dis-gds-rule.pos-type
                                ,p-gds-code
                                ,tt0-dis-gds-rule.obj-type
                                ,tt0-dis-gds-rule.obj-code
                                ,chr(10)
                                ,error-status:get-message(1)
                                ,return-value
                                ).
        undo _main, return error v-err-mess.
      END.
    END.
  END.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    FOR EACH buf_dis-gds-rule where
            buf_dis-gds-rule.gds-code = p-gds-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )  :
      if buf_Dis-gds-rule.obj-type = 'орг':U and g#db-num <> 0 then next.
      if buf_dis-gds-rule.obj-type = '':U and g#db-num <> 0 then next.
      if (buf_dis-gds-rule.obj-type = 'маг':U
          or
          buf_dis-gds-rule.obj-type = 'скл':U )
      and ((buf_dis-gds-rule.obj-type <> p-obj-type
           or buf_dis-gds-rule.obj-code <> p-obj-code))  then next.
      if buf_dis-gds-rule.templ-rl-root = 0 then next.
        FIND FIRST tt0-dis-gds-rule NO-LOCK WHERE
            tt0-dis-gds-rule.gds-code = p-gds-code
        AND tt0-dis-gds-rule.obj-type = buf_dis-gds-rule.obj-type
        AND tt0-dis-gds-rule.obj-code = buf_dis-gds-rule.obj-code
        AND tt0-dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type
        AND tt0-dis-gds-rule.discnt-role = buf_dis-gds-rule.discnt-role
        AND tt0-dis-gds-rule.nonunique = buf_dis-gds-rule.nonunique
        NO-ERROR.
      IF NOT AVAILABLE tt0-dis-gds-rule THEN DO:
            for each buf_dis-gds-rule-attr exclusive-lock
            where buf_dis-gds-rule-attr.gds-code    = buf_dis-gds-rule.gds-code
              and buf_dis-gds-rule-attr.obj-type    = buf_dis-gds-rule.obj-type
              and buf_dis-gds-rule-attr.obj-code    = buf_dis-gds-rule.obj-code
              and buf_dis-gds-rule-attr.pos-type    = buf_dis-gds-rule.pos-type
              and buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
              and buf_dis-gds-rule-attr.nonunique   = buf_dis-gds-rule.nonunique
            :
                delete buf_dis-gds-rule-attr no-error.
                IF error-status:error
                THEN DO:
                  assign
                  v-err-mess = substitute("Ошибка при удалении атрибутов скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                          ,buf_dis-gds-rule.templ-rl-root
                                          ,buf_dis-gds-rule.pos-type
                                          ,p-gds-code
                                          ,buf_dis-gds-rule.obj-type
                                          ,buf_dis-gds-rule.obj-code
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).
                  undo _main, return error v-err-mess.
                END.
            end.
        delete buf_dis-gds-rule no-error.
        IF error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении скидки &1 (POS &2) на товар &3 на &4&5&6&7&6&8"
                                  ,buf_dis-gds-rule.templ-rl-root
                                  ,buf_dis-gds-rule.pos-type
                                  ,p-gds-code
                                  ,buf_dis-gds-rule.obj-type
                                  ,buf_dis-gds-rule.obj-code
                                  ,chr(10)
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.
        END.
      END.
    END.
  end.
end.
