define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование выражения справочника для фильтра".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6':u,spr,znak,lab_user,fld,lab,type)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable flt-rec as recid no-undo.
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc ( output g#report-num ).
FUNCTION Int2Char RETURNS CHARACTER ( INPUT i-num AS INTEGER ) :   DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.   RUN conv-int-to-char IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-str ) NO-ERROR.   RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ). END FUNCTION.      PROCEDURE conv-int-to-char :   DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.   DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO.   DO ON ERROR UNDO, RETURN ERROR :     ASSIGN p-str = TRIM( STRING( p-num, "->>>>>>>>>>>>":U ) ).   END.  END PROCEDURE.
define variable v_type    as character no-undo.
DEFINE BUTTON  Btn_Reference
     IMAGE-UP          FILE "btn-down-arrow"
     IMAGE-DOWN        FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     LABEL "":L
     SIZE 3 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.17
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить"
     SIZE 10 BY 1.17
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1.17
     BGCOLOR 8 .
define variable grp           as widget-handle no-undo .
define variable flw           as widget-handle no-undo .
define variable flw1          as widget-handle no-undo .
define variable fill_in       as widget-handle no-undo .
define variable txt           as widget-handle no-undo .
define variable btn           as widget-handle no-undo .
define variable frm           as character no-undo .
define variable type_         as character no-undo .
define variable lab_          as character no-undo .
define variable fld_          as character no-undo .
define variable join-tbl      as character no-undo .
define variable join_rus      as character no-undo .
define variable i             as integer   no-undo .
define variable s             as character no-undo .
define variable s_description as character no-undo .
define variable a             as character no-undo .
define variable next-fill-in  as logical   no-undo initial no .
define variable name          as character no-undo .
DEFINE FRAME DIALOG-1
     SPACE(74.02) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "":L.
ASSIGN
       FRAME DIALOG-1 :SCROLLABLE       = NO.
IF VALID-HANDLE( ACTIVE-WINDOW ) AND FRAME DIALOG-1:PARENT = ? THEN FRAME DIALOG-1 :PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
DEFINE VARIABLE max-type-length  AS INTEGER   NO-UNDO.
DEFINE VARIABLE cur-type-length  AS INTEGER   NO-UNDO.
DEFINE VARIABLE type-length-1st  AS INTEGER   NO-UNDO.
DEFINE VARIABLE max-label-length AS INTEGER   NO-UNDO.
DEFINE VARIABLE cur-label-length AS INTEGER   NO-UNDO.
DEFINE VARIABLE type_list        AS CHARACTER NO-UNDO INITIAL "CHARACTER,INTEGER,DECIMAL,DATE,LOGICAL,RECID,INT64":U.
DEFINE VARIABLE format_list      AS CHARACTER NO-UNDO INITIAL "40,14,29,10,3,12,28":U.
DEFINE VARIABLE format_character AS CHARACTER NO-UNDO INITIAL "x(40)":U.
DEFINE VARIABLE format_integer   AS CHARACTER NO-UNDO INITIAL "->>>>>>>>>9":U.
DEFINE VARIABLE format_decimal   AS CHARACTER NO-UNDO INITIAL "->>>>>>>>>>>>>>>>>9.9999":U.
DEFINE VARIABLE format_date      AS CHARACTER NO-UNDO INITIAL "99/99/9999":U.
DEFINE VARIABLE format_logical   AS CHARACTER NO-UNDO INITIAL "yes/no":U.
DEFINE VARIABLE format_recid     AS CHARACTER NO-UNDO INITIAL ">>>>>>>>>>>9":U.
DEFINE VARIABLE format_int64     AS CHARACTER NO-UNDO INITIAL "->>>>>>>>>>>>>>>>>>>9":U.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, RETURN ERROR
   ON END-KEY UNDO MAIN-BLOCK, RETURN ERROR :
   frame DIALOG-1 :height-chars = num-entries( type, '*' ) * 1.5 + 5.
   frame DIALOG-1 :width-chars  = 78.
   form
       Btn_OK     at row 1 column  1
       Btn_Cancel at row 1 column 12
     b-help  at row 1 column 24
   with frame DIALOG-1.
   do i = 1 to num-entries( lab, '*' ) :
        assign lab_             = entry( i, lab, '*' ) + ": "
               cur-label-length = LENGTH( lab_ ).
        IF cur-label-length > max-label-length THEN DO: ASSIGN max-label-length = cur-label-length. END.
        create text txt
                   assign
                     frame        = frame DIALOG-1 :handle
                     data-type    = "character"
                     format       = "x(" + Int2Char( cur-label-length )  + ")"
                     screen-value = lab_
                     row          = i * 1.5
                     column       = 1.5.
   end.
   do i = 1 to num-entries( type, '*' ) :
        assign
              type_ = entry( i, type, '*' )
              fld_  = entry( i, fld,  '*' )
              lab_  = entry( i, lab,  '*' )
        .
        ASSIGN cur-type-length = INTEGER( ENTRY( LOOKUP( type_, type_list ), format_list ) ).
        IF i = 1 THEN DO: ASSIGN type-length-1st = cur-type-length. END.
        IF cur-type-length > max-type-length THEN DO: ASSIGN max-type-length = cur-type-length. END.
        case type_ :
           when 'character':U then do: assign frm = format_character. end.
           when 'integer':U   then do: assign frm = format_integer.   end.
           when 'int64':U   then do: assign frm = format_int64.   end.
           when 'decimal':U   then do: assign frm = format_decimal.   end.
           when 'date':U      then do: assign frm = format_date.      end.
           when 'logical':U   then do: assign frm = format_logical.   end.
           when 'recid':U     then do: assign frm = format_recid.     end.
        end case.
        create fill-in fill_in
                   assign
                     frame        = frame DIALOG-1 :handle
                     data-type    = type_
                     format       = frm
                     private-data = fld_ + ',' + lab_
                     row          = i * 1.5
                     column       = max-label-length + 1
                     sensitive    = yes
                     visible      = yes.
   end.
   frame DIALOG-1 :width-chars = max-label-length + max-type-length + 6.
   assign
        Btn_OK      :row       = i * 1.5 + 1
        Btn_OK      :column    = 2
        Btn_OK      :visible   = yes
        Btn_OK      :sensitive = yes
   .
   ASSIGN
        b-help :ROW       = i * 1.5 + 1
        b-help :COLUMN    = MAX( 25, max-label-length + type-length-1st - 5 )
        b-help :VISIBLE   = YES
        b-help :SENSITIVE = YES
   .
   assign
        Btn_Cancel  :row       = i * 1.5 + 1
        Btn_Cancel  :column    = MAX( 12, b-help :COLUMN - 12 )
        Btn_Cancel  :visible   = yes
        Btn_Cancel  :sensitive = yes
   .
   if spr <> "" then do:
       form Btn_Reference with frame DIALOG-1.
       assign
            Btn_Reference :row       = 1.5
            Btn_Reference :column    = max-label-length + type-length-1st + 2
            Btn_Reference :visible   = yes
            Btn_Reference :sensitive = yes
       .
       on choose of btn_ok in frame DIALOG-1 do:
            define variable type_       as character no-undo.
            define variable code_       as integer   no-undo.
            define variable art_        as character no-undo.
            define variable jnum_       as integer   no-undo.
            define variable jsub_       as integer   no-undo.
            define variable jhost-code_ as integer   no-undo.
            define variable v-found     as integer   no-undo extent 4.
            define variable numfdelim   as integer   no-undo.
            assign grp = frame DIALOG-1 :first-child.
            do while ( grp <> ? ) :
                 assign flw = grp :first-child.
                 do while ( flw <> ? ) :
                      if flw :type = 'fill-in' then do:
                         if spr = 'cli' then do:
                            if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                            then do:
                              numfdelim = num-entries(entry( 2, entry( 1, flw :private-data ), '.' ),"-":U).
                              case entry( numfdelim, entry( 2, entry( 1, flw :private-data ), '.' ), '-' ) :
                                  when "code" then do: assign code_ = integer( flw :screen-value ). end.
                                  when "type" then do: assign type_ =          flw :screen-value.   end.
                              end case.
                            end.
                            else do:
                              numfdelim = num-entries(entry( 2, entry( 1, flw :private-data ), '.' ),"-":U).
                              case entry( numfdelim, entry( 1, flw :private-data ), '-' ) :
                                  when "code" then do: assign code_ = integer( flw :screen-value ). end.
                                  when "type" then do: assign type_ =          flw :screen-value.   end.
                              end case.
                            end.
                         end.
                         if spr = 'gop' then do:
                            if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                            then do:
                              case entry( 2, entry( 1, flw :private-data ), '.' )  :
                                when "gop-db-num" then do: assign jnum_ = integer( flw :screen-value ). end.
                                when "gop-id"  then do: assign jsub_ = integer( flw :screen-value ). end.
                              end case.
                            end.
                            else do:
                              case entry( 2, entry( 1, flw :private-data ), '.' )  :
                                when "gop-db-num" then do: assign jnum_ = integer( flw :screen-value ). end.
                                when "gop-id" then do: assign jsub_ = integer( flw :screen-value ). end.
                              end case.
                            end.
                         end.
                         if spr = 'gds' then do:
                            if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                            then do:
                              case entry( 2, entry( 1, flw :private-data ), '.' ) :
                                  when "prod-code" then do: assign code_ = integer( flw :screen-value ). end.
                                  when "prod-type" then do: assign type_ =          flw :screen-value.   end.
                                  when "artic"     then do: assign art_  =          flw :screen-value.   end.
                              end case.
                            end.
                            else do:
                              case entry( 1, flw :private-data ) :
                                  when "prod-code" then do: assign code_ = integer( flw :screen-value ). end.
                                  when "prod-type" then do: assign type_ =          flw :screen-value.   end.
                                  when "artic"     then do: assign art_  =          flw :screen-value.   end.
                              end case.
                            end.
                         end.
                         if spr = 'acc' then do:
                            case entry( 2, entry( 2, entry( 1, flw :private-data ), '.' ), '-' ) :
                                when "num" then do: assign jnum_ = integer( flw :screen-value ). end.
                                when "sub" then do: assign jsub_ = integer( flw :screen-value ). end.
                            end case.
                            case entry( 2, entry( 1, flw :private-data ), '.' ) :
                                when "host-code" then do: assign jhost-code_  = integer( flw :screen-value ). end.
                            end case.
                         end.
                      end.
                      assign flw = flw :next-sibling.
                 end.
                 assign grp = grp :next-sibling.
            end.
            case spr :
                when 'cli' then do:
                    if lookup( type_, ( "":U    + chr(44) +
                                        'орг':U  + chr(44) +
                                        'чел':U  + chr(44) +
                                        'маг':U + chr(44) +
                                        'скл':U ) ) = 0 then do:
                      message "Неверный тип клиента".
                      return no-apply.
                    end.
                    if type_ = "":U then do:
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = 'орг':U
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 1 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = 'чел':U
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 2 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = 'маг':U
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 3 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = 'скл':U
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 4 ] = 1. end.
                        if v-found[ 1 ] + v-found[ 2 ] + v-found[ 3 ] + v-found[ 4 ] > 1 then do:
                          message "Есть два или более клиента с кодом" code_ skip
                                  "Уточните тип клиента"
                          view-as alert-box .
                          return no-apply.
                        end.
                        else do:
                          if v-found[ 1 ]  = 1 then do:
                            assign
                                  type_ = 'орг':U
                            .
                          end.
                          if v-found[ 2 ]  = 1 then do:
                            assign
                                  type_ = 'чел':U
                            .
                          end.
                          if v-found[ 3 ]  = 1 then do:
                            assign
                                  type_ = 'маг':U
                            .
                          end.
                          if v-found[ 4 ]  = 1 then do:
                            assign
                                  type_ = 'скл':U
                            .
                          end.
                          if v-found [ 1 ] + v-found [ 2 ] + v-found [ 3 ] + v-found [ 4 ] > 0 then do:
                            assign grp = frame DIALOG-1 :first-child.
                            do while ( grp <> ? ) :
                                assign flw = grp :first-child.
                                do while ( flw <> ? ) :
                                      if flw :type = 'fill-in' then do:
                                          if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                                          then do:
                                            case entry( 2, entry( 2, entry( 1, flw :private-data ), '.' ), '-' ) :
                                                when "type" then do: assign flw :screen-value = type_.   end.
                                            end case.
                                          end.
                                          else do:
                                            case entry( 2, entry( 1, flw :private-data ), '-' ) :
                                                when "type" then do: assign flw :screen-value = type_.   end.
                                            end case.
                                          end.
                                      end.
                                      assign flw = flw :next-sibling.
                                end.
                                assign grp = grp :next-sibling.
                            end.
                          end.
                        end.
                    end.
                   find first ub.clients where
                              ub.clients.obj-type = type_
                          and ub.clients.obj-code = code_ no-error.
                   if not available ub.clients then do:
                      message "Клиент отсутствует".
                      return no-apply.
                   end.
                   assign name = clients.obj-name.
                end.
                when 'gds' then do:
                  find ub.goods no-lock where
                      ub.goods.prod-type = type_
                  and ub.goods.prod-code = code_
                  and ub.goods.artic     = art_  no-error.
                  if not available ub.goods then do:
                    message "Товар отсутствует".
                    return no-apply.
                  end.
                  assign name = ub.goods.gds-name.
                END.
                when 'gop' then do:
                 find ub.grp-obj-price no-lock where
                      ub.grp-obj-price.gop-db-num = jnum_
                  and ub.grp-obj-price.gop-id     = jsub_
                  no-error.
                  if not available ub.grp-obj-price then do:
                    message "Группа отсутствует".
                    return no-apply.
                  end.
                  assign name = ub.grp-obj-price.name-group.
                end.
            end case.
       end.
       on choose of Btn_Reference in frame DIALOG-1 do:
           define variable grp-rec  as recid     no-undo.
           define variable ref-rec  as recid     no-undo.
           define variable ref-list as character no-undo.
           define variable out-an   as integer   no-undo.
           define variable numfdelim as integer  no-undo.
           case spr :
                when 'cli' then do:
                      ref-list = "".
                      run ref/cli-all.w (  input parParentProc,
                                       input "b-sel",
                                       input 'орг':U,
                                       input 'все':U,
                                       input 'текущие':U,
                                       input ?,
                                       input ",,,,,,NO":U,
                                       input ?,
                                      output ref-list         ) .
                      assign ref-rec = integer( entry( 1, ref-list ) ).
                      if ref-rec <> 0 then do:
                        find ub.clients where recid( ub.clients ) = ref-rec.
                        assign name = ub.clients.obj-name.
                        assign grp = frame DIALOG-1 :first-child.
                        do while ( grp <> ? ) :
                             assign flw = grp :first-child.
                             do while ( flw <> ? ) :
                                  if flw :type = 'fill-in' then do:
                                      if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                                      then do:
                                        numfdelim = num-entries(entry( 2, entry( 1, flw :private-data ), '.' ),"-":U).
                                        case entry( numfdelim , entry( 2, entry( 1, flw :private-data ), '.' ), '-' ) :
                                            when "code" then do: assign flw :screen-value = string( ub.clients.obj-code ). end.
                                            when "type" then do: assign flw :screen-value =         ub.clients.obj-type.   end.
                                        end case.
                                      end.
                                      else do:
                                        numfdelim = num-entries(entry( 1, flw :private-data ),"-":U).
                                        case entry( numfdelim, entry( 1, flw :private-data ), '-' ) :
                                            when "code" then do: assign flw :screen-value = string( ub.clients.obj-code ). end.
                                            when "type" then do: assign flw :screen-value =         ub.clients.obj-type.   end.
                                        end case.
                                      end.
                                  end.
                                  assign flw = flw :next-sibling.
                             end.
                             assign grp = grp :next-sibling.
                        end.
                        apply "entry":u  to Btn_OK in frame DIALOG-1.
                        apply "choose":u to Btn_OK in frame DIALOG-1.
                      end.
                      else do:
                        apply "entry":u to Btn_Reference in frame DIALOG-1.
                     end.
                end.
                when 'gds' then do:
                  run ref/gds-ref.p (    INPUT ParParentProc
                                  ,  INPUT "b-sel"
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  ,  INPUT ?
                                  , OUTPUT ref-list        ).
                  assign ref-rec = integer( entry( 1, ref-list ) ).
                  if ref-list <> "" then do:
                    find ub.goods where recid( ub.goods ) = ref-rec.
                    assign name = ub.goods.gds-name.
                    assign grp  = frame DIALOG-1 :first-child.
                    do while ( grp <> ? ) :
                          assign flw = grp :first-child.
                          do while ( flw <> ? ) :
                              if flw :type = 'fill-in' then do:
                                  if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                                  then do:
                                  case entry( 2, entry( 1, flw :private-data ), '.' ) :
                                      when "prod-code" then do: assign flw :screen-value = string( ub.goods.prod-code ). end.
                                      when "prod-type" then do: assign flw :screen-value =         ub.goods.prod-type.   end.
                                      when "artic"     then do: assign flw :screen-value =         ub.goods.artic.       end.
                                  end case.
                                  end.
                                  else do:
                                  case entry( 1, flw :private-data ) :
                                      when "prod-code" then do: assign flw :screen-value = string( ub.goods.prod-code ). end.
                                      when "prod-type" then do: assign flw :screen-value =         ub.goods.prod-type.   end.
                                      when "artic"     then do: assign flw :screen-value =         ub.goods.artic.       end.
                                  end case.
                                  end.
                              end.
                              assign flw = flw :next-sibling.
                          end.
                          assign grp = grp :next-sibling.
                      end.
                      apply "entry":u  to Btn_OK in frame DIALOG-1.
                      apply "choose":u to Btn_OK in frame DIALOG-1.
                  end.              else do: apply "entry":u to Btn_Reference in frame DIALOG-1. end.
                end.
                when 'gop' then do:
                      ref-list = "".
                      run ref/gr-objpr.w (  input parParentProc,
                                           input "b-sel",
                                           input-output ref-list  ) .
                      assign ref-rec = integer( entry( 1, ref-list ) ).
                      if ref-rec <> 0 then do:
                        find ub.grp-obj-price where recid( ub.grp-obj-price ) = ref-rec.
                        assign name = ub.grp-obj-price.name-group.
                        assign grp = frame DIALOG-1 :first-child.
                        do while ( grp <> ? ) :
                             assign flw = grp :first-child.
                             do while ( flw <> ? ) :
                                  if flw :type = 'fill-in' then do:
                                      if num-entries( entry( 1, flw :private-data ), '.' ) > 1
                                      then do :
                                        case entry( 2, entry( 1, flw :private-data ), '.' ) :
                                            when "gop-db-num" then do: assign flw :screen-value = string( ub.grp-obj-price.gop-db-num ). end.
                                            when "gop-id" then do: assign flw :screen-value = string( ub.grp-obj-price.gop-id ).   end.
                                        end case.
                                      end.
                                      else do:
                                        case entry( 1, flw :private-data ) :
                                            when "gop-db-num" then do: assign flw :screen-value = string( ub.grp-obj-price.gop-db-num ). end.
                                            when "gop-id" then do: assign flw :screen-value = string ( ub.grp-obj-price.gop-id ).   end.
                                        end case.
                                      end.
                                  end.
                                  assign flw = flw :next-sibling.
                             end.
                             assign grp = grp :next-sibling.
                        end.
                        apply "entry":u  to Btn_OK in frame DIALOG-1.
                        apply "choose":u to Btn_OK in frame DIALOG-1.
                      end.
                      else do:
                        apply "entry":u to Btn_Reference in frame DIALOG-1.
                     end.
                end.
           end case.
       end.
   end.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame DIALOG-1 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
   WAIT-FOR GO OF FRAME DIALOG-1.
   if znak = "="
   then do:
     assign
       join-tbl = " AND "
       join_rus = " И "
     .
   end.
   else do:
     assign
       join-tbl = " OR "
       join_rus = " ИЛИ "
     .
   end.
   assign
     grp = frame DIALOG-1 :first-child
   .
   do while ( grp <> ? )
   :
      assign flw = grp :first-child.
      do while ( flw <> ? ) :
        if flw :type = 'fill-in'
        then do:
          if next-fill-in
          then do:
            assign
              str     = str     + join-tbl
              str_rus = str_rus + join_rus
            .
          end.
          assign
            next-fill-in = yes
          .
          assign
            s             = flw :screen-value
            s_description = flw :screen-value
            a             = ( if flw :data-type = "character" then '"' else '' )
          .
          if flw :data-type = "date"
          then do:
            define variable v-date as date      no-undo .
            assign
              v-date = date(flw :screen-value)
            .
            if v-date = ?
            then do:
              assign
                s             = chr(63)
                s_description = "НЕ_ЗАДАНА"
              .
            end.
            else do:
              assign
                s             = 'date(':u + string(month(v-date))
                              + '~~054':u + string(day(v-date))
                              + '~~054':u + string(year(v-date))
                              + ')':u
                s_description = string(v-date, "99/99/9999")
              .
            end.
          end.
          if flw :data-type = "character"
          then do:
            run replace-special-char in this-procedure
              (input  s
              ,output s
              ) .
            assign
              s_description = replace(s_description, ',', '~~054')
            .
          end.
          assign
            str     = str     + entry( 1, flw :private-data ) + " " + znak + " " + a + s             + a
            str_rus = str_rus + entry( 2, flw :private-data ) + " " + znak + " " + a + s_description + a
          .
        end.
        assign
          flw = flw :next-sibling
        .
      end.
      assign
        grp = grp :next-sibling
      .
   end.
   assign
     str     = "(" + str     + ")"
     str_rus = "(" + str_rus + ")"
   .
   if lookup( spr, "cli,gds,acc,gop" ) > 0 then do: assign str_rus = lab_user + ' ' + znak + ' "' + name + '"'. end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  VIEW FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE replace-special-char :
  define input  parameter p-in-string    as character no-undo .
  define output parameter p-out-string   as character no-undo .
  define variable v-out-string   as character no-undo .
  define variable v-enclose-char as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-out-string   = p-in-string
      v-enclose-char = '"'
    .
    if index(v-out-string, '"') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '"', v-enclose-char + ' + chr(' + string(asc('"')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '~~') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '~~', v-enclose-char + ' + chr(' + string(asc('~~')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, ',') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, ',', v-enclose-char + ' + chr(' + string(asc(',')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, "'") > 0
    then do:
      assign
        v-out-string = replace(v-out-string, "'", v-enclose-char + ' + chr(' + string(asc("'")) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '/') > 0
    then do:
      assign
        v-out-string = replace(v-out-string, '/', v-enclose-char + ' + chr(' + string(asc('/')) + ') + ' + v-enclose-char)
      .
    end.
    assign
      p-out-string = v-out-string
    .
  end.
END PROCEDURE.
