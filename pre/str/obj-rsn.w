define input parameter parparentproc as widget-handle no-undo.
define input parameter p-obj-type    as character     no-undo.
define input parameter p-obj-code    as integer       no-undo.
define input parameter p-mode        as character     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Коды оснований (причин) создания документа по умолчанию на объекте":U.
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable ref-rec     as recid   no-undo.
define variable j_rsn-code  as integer no-undo.
define variable j_host-code as integer no-undo.
define variable p-host-code as integer no-undo.
define button   b-Exit    label "От&мена"  size-chars 10.00 by 1.00 default auto-end-key.
define button   b-OK      label "&Ввод "   size-chars 10.00 by 1.00 default auto-go.
define button   b-help   label "Помощ&ь"  size-chars 10.00 by 1.00 default.
define button   b-History label "Истори&я" size-chars 10.00 by 1.00 default.
define button b-ie
  image-up          file "btn-down-arrow"
  image-down        file "btn-down-arrow"
  image-insensitive file "btn-down-arrow" size-chars  3.00 by 1.00.
define button b-ee  like b-ie.
define button b-ep  like b-ie.
define button b-es  like b-ie.
define button b-re  like b-ie.
define button b-rs  like b-ie.
define button b-we  like b-ie.
define button b-vt  like b-ie.
define button b-vp  like b-ie.
define button b-iv  like b-ie.
define button b-ev  like b-ie.
define button b-rv  like b-ie.
define button b-em  like b-ie.
define button b-wm  like b-ie.
define button b-im  like b-ie.
define button b-ap  like b-ie.
define button b-mp  like b-ie.
define button b-pc  like b-ie.
define button b-ieh like b-ie.
define button b-eeh like b-ie.
define button b-eph like b-ie.
define button b-reh like b-ie.
define variable rsn-ie  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-ee  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-ep  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-es  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-re  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-rs  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-we  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-vt  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-vp  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-iv  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-ev  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-rv  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-em  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-wm  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-im  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-ap  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-mp  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-pc  as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-ieh as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-eeh as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-eph as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable rsn-reh as integer   no-undo format ">>9":U   view-as fill-in size-chars  4.00 by 1.00.
define variable holdLbl as character no-undo format "x(98)":U view-as fill-in size-chars 98.00 by 1.00 bgcolor 3 fgcolor 15.
define frame fr-D-obj-rsn
  rsn-ie      at row  2.25 col 36.00 colon-aligned    label "&Приход внешний"
  rsn-ee      at row  2.25 col 75.00 colon-aligned    label "&Расход внешний"
  rsn-ep      at row  3.50 col 36.00 colon-aligned    label "Во&зврат поставщику"
  rsn-es      at row  3.50 col 75.00 colon-aligned    label "Касса прода&жа"
  rsn-re      at row  4.75 col 36.00 colon-aligned    label "Возвр&ат внешний"
  rsn-rs      at row  4.75 col 75.00 colon-aligned    label "&Касса возврат"
  rsn-we      at row  6.00 col 36.00 colon-aligned    label "&Списание"
  rsn-vt      at row  6.00 col 75.00 colon-aligned    label "&Инвентаризация"
  rsn-vp      at row  7.25 col 36.00 colon-aligned    label "Пересор&тица"
  rsn-iv      at row  7.25 col 75.00 colon-aligned    label "Прихо&д внутренний"
  rsn-ev      at row  8.50 col 36.00 colon-aligned    label "Расход вн&утренний"
  rsn-rv      at row  8.50 col 75.00 colon-aligned    label "Возврат в&нутренний"
  rsn-em      at row  9.75 col 36.00 colon-aligned    label "Расход произв&одство"
  rsn-wm      at row  9.75 col 75.00 colon-aligned    label "Списани&е производство"
  rsn-im      at row 11.00 col 36.00 colon-aligned    label "При&ход производство"
  rsn-ap      at row 12.25 col 36.00 colon-aligned    label "Коррекция у&четных цен"
  rsn-pc      at row 12.25 col 75.00 colon-aligned    label "Смена типа прио&бретения"
  rsn-mp      at row 13.50 col 36.00 colon-aligned    label "Корректировка отрицате&льных партий"
  holdLbl     at row 15.00 col  1.63          no-label
  rsn-ieh     at row 16.25 col 36.00 colon-aligned    label "Приход вне&шний"
  rsn-eeh     at row 16.25 col 75.00 colon-aligned    label "Расход внешни&й"
  rsn-eph     at row 17.50 col 36.00 colon-aligned    label "Возврат постав&щику"
  rsn-reh     at row 17.50 col 75.00 colon-aligned    label "&Возврат внешний"
.
define frame fr-D-obj-rsn
    b-OK      at row 1 col 1
    b-Exit    at row 1 col 11
    b-History at row 1 col 67.5
    b-help   at row 1 col 77.75
    b-ie      at row  2.25 col 42.00
    b-ee      at row  2.25 col 81.00
    b-ep      at row  3.50 col 42.00
    b-es      at row  3.50 col 81.00
    b-re      at row  4.75 col 42.00
    b-rs      at row  4.75 col 81.00
    b-we      at row  6.00 col 42.00
    b-vt      at row  6.00 col 81.00
    b-vp      at row  7.25 col 42.00
    b-iv      at row  7.25 col 81.00
    b-ev      at row  8.50 col 42.00
    b-rv      at row  8.50 col 81.00
    b-em      at row  9.75 col 42.00
    b-wm      at row  9.75 col 81.00
    b-im      at row 11.00 col 42.00
    b-ap      at row 12.25 col 42.00
    b-pc      at row 12.25 col 81.00
    b-mp      at row 13.50 col 42.00
    b-ieh     at row 16.25 col 42.00
    b-eeh     at row 16.25 col 81.00
    b-eph     at row 17.50 col 42.00
    b-reh     at row 17.50 col 81.00
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button b-Exit cancel-button b-Exit.
assign frame fr-D-obj-rsn :scrollable = no.
on choose of b-OK in frame fr-D-obj-rsn do:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run Save-Vars in this-procedure.
  apply "GO":U to frame fr-D-obj-rsn.
end.
on choose of b-Exit in frame fr-D-obj-rsn do:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  apply "END-ERROR":U to frame fr-D-obj-rsn.
end.
on choose of b-History in frame fr-D-obj-rsn do:
  define variable v-list as character no-undo.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run str/objcrsns.w ( input        parparentproc,
                   input        "":U,
                   input        "obj":U,
                   input        p-obj-type,
                   input        p-obj-code,
                   input        ?,
                   input        ?,
                   input-output v-list         ).
end.
  on choose of b-ie in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ie ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ie = j_rsn-code.
      display rsn-ie with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ie in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ie ) no-error.
    if available ub.trn-reason then do: assign rsn-ie. end.
    run Apply-Next in this-procedure ( input "ie" ).
    return no-apply.
  end.
  on choose of b-ee in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ee ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ee = j_rsn-code.
      display rsn-ee with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ee in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ee ) no-error.
    if available ub.trn-reason then do: assign rsn-ee. end.
    run Apply-Next in this-procedure ( input "ee" ).
    return no-apply.
  end.
  on choose of b-ep in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ep ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ep = j_rsn-code.
      display rsn-ep with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ep in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ep ) no-error.
    if available ub.trn-reason then do: assign rsn-ep. end.
    run Apply-Next in this-procedure ( input "ep" ).
    return no-apply.
  end.
  on choose of b-es in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-es ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-es = j_rsn-code.
      display rsn-es with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-es in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-es ) no-error.
    if available ub.trn-reason then do: assign rsn-es. end.
    run Apply-Next in this-procedure ( input "es" ).
    return no-apply.
  end.
  on choose of b-re in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-re ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-re = j_rsn-code.
      display rsn-re with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-re in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-re ) no-error.
    if available ub.trn-reason then do: assign rsn-re. end.
    run Apply-Next in this-procedure ( input "re" ).
    return no-apply.
  end.
  on choose of b-rs in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-rs ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-rs = j_rsn-code.
      display rsn-rs with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-rs in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-rs ) no-error.
    if available ub.trn-reason then do: assign rsn-rs. end.
    run Apply-Next in this-procedure ( input "rs" ).
    return no-apply.
  end.
  on choose of b-we in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-we ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-we = j_rsn-code.
      display rsn-we with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-we in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-we ) no-error.
    if available ub.trn-reason then do: assign rsn-we. end.
    run Apply-Next in this-procedure ( input "we" ).
    return no-apply.
  end.
  on choose of b-vt in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-vt ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-vt = j_rsn-code.
      display rsn-vt with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-vt in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-vt ) no-error.
    if available ub.trn-reason then do: assign rsn-vt. end.
    run Apply-Next in this-procedure ( input "vt" ).
    return no-apply.
  end.
  on choose of b-vp in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-vp ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-vp = j_rsn-code.
      display rsn-vp with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-vp in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-vp ) no-error.
    if available ub.trn-reason then do: assign rsn-vp. end.
    run Apply-Next in this-procedure ( input "vp" ).
    return no-apply.
  end.
  on choose of b-iv in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-iv ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-iv = j_rsn-code.
      display rsn-iv with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-iv in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-iv ) no-error.
    if available ub.trn-reason then do: assign rsn-iv. end.
    run Apply-Next in this-procedure ( input "iv" ).
    return no-apply.
  end.
  on choose of b-ev in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ev ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ev = j_rsn-code.
      display rsn-ev with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ev in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ev ) no-error.
    if available ub.trn-reason then do: assign rsn-ev. end.
    run Apply-Next in this-procedure ( input "ev" ).
    return no-apply.
  end.
  on choose of b-rv in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-rv ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-rv = j_rsn-code.
      display rsn-rv with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-rv in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-rv ) no-error.
    if available ub.trn-reason then do: assign rsn-rv. end.
    run Apply-Next in this-procedure ( input "rv" ).
    return no-apply.
  end.
  on choose of b-em in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-em ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-em = j_rsn-code.
      display rsn-em with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-em in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-em ) no-error.
    if available ub.trn-reason then do: assign rsn-em. end.
    run Apply-Next in this-procedure ( input "em" ).
    return no-apply.
  end.
  on choose of b-wm in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-wm ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-wm = j_rsn-code.
      display rsn-wm with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-wm in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-wm ) no-error.
    if available ub.trn-reason then do: assign rsn-wm. end.
    run Apply-Next in this-procedure ( input "wm" ).
    return no-apply.
  end.
  on choose of b-im in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-im ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-im = j_rsn-code.
      display rsn-im with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-im in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-im ) no-error.
    if available ub.trn-reason then do: assign rsn-im. end.
    run Apply-Next in this-procedure ( input "im" ).
    return no-apply.
  end.
  on choose of b-ap in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ap ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ap = j_rsn-code.
      display rsn-ap with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ap in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ap ) no-error.
    if available ub.trn-reason then do: assign rsn-ap. end.
    run Apply-Next in this-procedure ( input "ap" ).
    return no-apply.
  end.
  on choose of b-mp in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-mp ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-mp = j_rsn-code.
      display rsn-mp with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-mp in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-mp ) no-error.
    if available ub.trn-reason then do: assign rsn-mp. end.
    run Apply-Next in this-procedure ( input "mp" ).
    return no-apply.
  end.
  on choose of b-pc in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-pc ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-pc = j_rsn-code.
      display rsn-pc with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-pc in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-pc ) no-error.
    if available ub.trn-reason then do: assign rsn-pc. end.
    run Apply-Next in this-procedure ( input "pc" ).
    return no-apply.
  end.
  on choose of b-ieh in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-ieh ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-ieh = j_rsn-code.
      display rsn-ieh with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-ieh in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-ieh ) no-error.
    if available ub.trn-reason then do: assign rsn-ieh. end.
    run Apply-Next in this-procedure ( input "ieh" ).
    return no-apply.
  end.
  on choose of b-eeh in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-eeh ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-eeh = j_rsn-code.
      display rsn-eeh with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-eeh in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-eeh ) no-error.
    if available ub.trn-reason then do: assign rsn-eeh. end.
    run Apply-Next in this-procedure ( input "eeh" ).
    return no-apply.
  end.
  on choose of b-eph in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-eph ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-eph = j_rsn-code.
      display rsn-eph with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-eph in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-eph ) no-error.
    if available ub.trn-reason then do: assign rsn-eph. end.
    run Apply-Next in this-procedure ( input "eph" ).
    return no-apply.
  end.
  on choose of b-reh in frame fr-D-obj-rsn do:
    assign j_rsn-code = ( input frame fr-D-obj-rsn rsn-reh ).
    run str/trn-reas.w ( input parparentproc
                       , input 'выбор':U
                       , input-output j_rsn-code
                       ) .
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = j_rsn-code no-error.
    if available ub.trn-reason then do:
      assign  rsn-reh = j_rsn-code.
      display rsn-reh with frame fr-D-obj-rsn.
    end.
  end.
  on return of rsn-reh in frame fr-D-obj-rsn do:
    find first ub.trn-reason no-lock where
               ub.trn-reason.reason-code = ( input frame fr-D-obj-rsn rsn-reh ) no-error.
    if available ub.trn-reason then do: assign rsn-reh. end.
    run Apply-Next in this-procedure ( input "reh" ).
    return no-apply.
  end.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-obj-rsn anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-obj-rsn. END.
  return no-apply.
end.
if valid-handle( active-window ) and frame fr-D-obj-rsn :parent = ? then frame fr-D-obj-rsn :parent = active-window.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
on window-close of frame fr-D-obj-rsn do: apply "END-ERROR":U to self. end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-obj-rsn
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame fr-D-obj-rsn
do:
  apply "help":u to frame fr-D-obj-rsn .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame fr-D-obj-rsn:width - 0.3
                fh            = frame fr-D-obj-rsn:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  j_host-code = v-cntxt-host-code-obj .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-host-code
  )  .
  if j_host-code <> p-host-code then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "У вас нет прав для изменения настроек на объекте, принадлежащем другой фирме." skip( 0 )
            "Текущий объект:" p-obj-type p-obj-code skip( 0 )
            "Фирма объекта:"  p-host-code skip( 0 )
            "Текущая фирма:"  j_host-code "."
    view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  run Init-Vars in this-procedure.
  run UI-On     in this-procedure.
  wait-for go of frame fr-D-obj-rsn.
end.
hide frame fr-D-obj-rsn no-pause.
procedure UI-On :
  display rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
          rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im rsn-ap rsn-pc rsn-mp
          rsn-ieh rsn-eeh rsn-eph rsn-reh
          holdLbl
  with frame fr-D-obj-rsn.
  if p-mode <> 'ПРОСМОТР':U then do:
    enable rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
           rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im  rsn-ap rsn-pc rsn-mp
           rsn-ieh rsn-eeh rsn-eph rsn-reh
           b-ie  b-ee  b-ep  b-es  b-re  b-rs b-we b-vt b-vp
           b-iv  b-ev  b-rv  b-em  b-wm  b-im b-ap b-pc b-mp
           b-ieh b-eeh b-eph b-reh
           b-OK
    with frame fr-D-obj-rsn.
  end.
  enable b-Exit b-help b-History with frame fr-D-obj-rsn.
end procedure.
procedure Init-Vars :
  assign holdLbl = "Межфирменные перемещения":C98.
  assign frame fr-D-obj-rsn :title =
    substitute( "Коды оснований (причин) создания документа по умолчанию на объекте &1 &2", p-obj-type, p-obj-code ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ie':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-ie = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ee':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-ee = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ep':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-ep = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'es':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-es = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 're':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-re = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'rs':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-rs = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'we':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-we = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'vt':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-vt = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'vp':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-vp = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'iv':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-iv = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ev':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-ev = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'rv':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-rv = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'em':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-em = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'wm':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-wm = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'im':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-im = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ap':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-ap = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'mp':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-mp = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'pc':U      and
           ( ub.trn-reason-obj.hold-doc     = no          or
             ub.trn-reason-obj.hold-doc     = ? )
             no-error.
  assign rsn-pc = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ie':U      and
             ub.trn-reason-obj.hold-doc     = yes
             no-error.
  assign rsn-ieh = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ee':U      and
             ub.trn-reason-obj.hold-doc     = yes
             no-error.
  assign rsn-eeh = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 'ep':U      and
             ub.trn-reason-obj.hold-doc     = yes
             no-error.
  assign rsn-eph = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
  find first ub.trn-reason-obj no-lock where
             ub.trn-reason-obj.obj-type     = p-obj-type  and
             ub.trn-reason-obj.obj-code     = p-obj-code  and
             ub.trn-reason-obj.ext-doc-type = 're':U      and
             ub.trn-reason-obj.hold-doc     = yes
             no-error.
  assign rsn-reh = ( if available ub.trn-reason-obj then ub.trn-reason-obj.reason-code else ? ).
end procedure.
procedure Save-Vars :
  assign frame fr-D-obj-rsn rsn-ie  rsn-ee  rsn-ep  rsn-es  rsn-re  rsn-rs rsn-we rsn-vt rsn-vp
                             rsn-iv  rsn-ev  rsn-rv  rsn-em  rsn-wm  rsn-im rsn-ap rsn-mp
                             rsn-pc  rsn-ieh rsn-eeh rsn-eph rsn-reh .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ie no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ie':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ie':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ie.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ie = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ee no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ee':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ee':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ee.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ee = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ep no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ep':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ep':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ep.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ep = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-es no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'es':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'es':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-es.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-es = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-re no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 're':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 're':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-re.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-re = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-rs no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'rs':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'rs':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-rs.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-rs = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-we no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'we':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'we':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-we.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-we = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-vt no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'vt':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'vt':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-vt.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-vt = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-vp no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'vp':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'vp':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-vp.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-vp = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-iv no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'iv':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'iv':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-iv.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-iv = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ev no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ev':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ev':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ev.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ev = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-rv no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'rv':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'rv':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-rv.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-rv = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-em no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'em':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'em':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-em.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-em = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-wm no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'wm':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'wm':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-wm.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-wm = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-im no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'im':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'im':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-im.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-im = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ap no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ap':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ap':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ap.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ap = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-mp no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'mp':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'mp':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-mp.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-mp = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-pc no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'pc':U      and
             ( ub.trn-reason-obj.hold-doc     = no          or
               ub.trn-reason-obj.hold-doc     = ? )
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'pc':U
             ub.trn-reason-obj.hold-doc     = no
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-pc.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-pc = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-ieh no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ie':U      and
               ub.trn-reason-obj.hold-doc     = yes
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ie':U
             ub.trn-reason-obj.hold-doc     = yes
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-ieh.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-ieh = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-eeh no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ee':U      and
               ub.trn-reason-obj.hold-doc     = yes
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ee':U
             ub.trn-reason-obj.hold-doc     = yes
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-eeh.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-eeh = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-eph no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 'ep':U      and
               ub.trn-reason-obj.hold-doc     = yes
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 'ep':U
             ub.trn-reason-obj.hold-doc     = yes
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-eph.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-eph = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = rsn-reh no-error.
    find first ub.trn-reason-obj exclusive-lock where
               ub.trn-reason-obj.obj-type     = p-obj-type  and
               ub.trn-reason-obj.obj-code     = p-obj-code  and
               ub.trn-reason-obj.ext-doc-type = 're':U      and
               ub.trn-reason-obj.hold-doc     = yes
               no-error.
  if available ub.trn-reason then do:
    if available ub.trn-reason-obj then do:
      assign ref-rec = recid( ub.trn-reason-obj ).
      find first ub.trn-reason-obj exclusive-lock where
          recid( ub.trn-reason-obj ) = ref-rec.
    end.
    else do:
      create ub.trn-reason-obj.
      assign
             ub.trn-reason-obj.obj-type     = p-obj-type
             ub.trn-reason-obj.obj-code     = p-obj-code
             ub.trn-reason-obj.ext-doc-type = 're':U
             ub.trn-reason-obj.hold-doc     = yes
      .
    end.
    assign ub.trn-reason-obj.reason-code = rsn-reh.
  end.
  else do:
    if available ub.trn-reason-obj
     and rsn-reh = ? then do:
       delete ub.trn-reason-obj .
     end.
  end.
end procedure.
  procedure Apply-Next :
    define input parameter p-name as character no-undo.
    case p-name :
      when      'ie':U          then do: apply "ENTRY":U  to rsn-ee          in frame fr-D-obj-rsn. end.
      when      'ee':U          then do: apply "ENTRY":U  to rsn-ep       in frame fr-D-obj-rsn. end.
      when      'ep':U       then do: apply "ENTRY":U  to rsn-es     in frame fr-D-obj-rsn. end.
      when      'es':U     then do: apply "ENTRY":U  to rsn-re      in frame fr-D-obj-rsn. end.
      when      're':U      then do: apply "ENTRY":U  to rsn-rs in frame fr-D-obj-rsn. end.
      when      'rs':U then do: apply "ENTRY":U  to rsn-we          in frame fr-D-obj-rsn. end.
      when      'we':U          then do: apply "ENTRY":U  to rsn-vt                in frame fr-D-obj-rsn. end.
      when      'vt':U                then do: apply "ENTRY":U  to rsn-vp           in frame fr-D-obj-rsn. end.
      when      'vp':U           then do: apply "ENTRY":U  to rsn-iv          in frame fr-D-obj-rsn. end.
      when      'iv':U          then do: apply "ENTRY":U  to rsn-ev          in frame fr-D-obj-rsn. end.
      when      'ev':U          then do: apply "ENTRY":U  to rsn-rv      in frame fr-D-obj-rsn. end.
      when      'rv':U      then do: apply "ENTRY":U  to rsn-em           in frame fr-D-obj-rsn. end.
      when      'em':U           then do: apply "ENTRY":U  to rsn-wm           in frame fr-D-obj-rsn. end.
      when      'wm':U           then do: apply "ENTRY":U  to rsn-im           in frame fr-D-obj-rsn. end.
      when      'im':U           then do: apply "ENTRY":U  to rsn-ap           in frame fr-D-obj-rsn. end.
      when      'ap':U     then do: apply "ENTRY":U  to rsn-pc     in frame fr-D-obj-rsn. end.
      when      'pc':U     then do: apply "ENTRY":U  to rsn-mp   in frame fr-D-obj-rsn. end.
      when      'mp':U   then do: apply "ENTRY":U  to rsn-ieh         in frame fr-D-obj-rsn. end.
      when 'ieh':U      then do: apply "ENTRY":U  to rsn-eeh         in frame fr-D-obj-rsn. end.
      when 'eeh':U      then do: apply "ENTRY":U  to rsn-eph      in frame fr-D-obj-rsn. end.
      when 'eph':U   then do: apply "ENTRY":U  to rsn-reh     in frame fr-D-obj-rsn. end.
      when 'reh':U  then do: apply "CHOOSE":U to b-OK                              in frame fr-D-obj-rsn. end.
    end case.
  end procedure.
