&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r10 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME    DIALOG-1
&Scoped-define FRAME-NAME     DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование выражения справочника для фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.

&SCOP f-l Int2Char

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование выражения справочника для фильтра".

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u,spr,znak,lab_user,fld,lab,type)" }
{ cmp/trg-def.i         }
{ cmp/showinf.i         }
{ gbl/flt-shar.i        }
{ gbl/std-func.i {&f-l} }

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

DEFINE BUTTON {&Btn_Help} DEFAULT
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  DIALOG-1

/* Custom List Definitions                                              */
&Scoped-define LIST-1
&Scoped-define LIST-2
&Scoped-define LIST-3

/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define FIELDS-IN-QUERY-DIALOG-1

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     SPACE(74.02) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "":L.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
  VISIBLE,L                                                             */
ASSIGN
       FRAME DIALOG-1 :SCROLLABLE       = NO.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE( ACTIVE-WINDOW ) AND FRAME {&FRAME-NAME}:PARENT = ? THEN FRAME {&FRAME-NAME} :PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

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

   frame {&frame-name} :height-chars = num-entries( type, '{&delim-flt}' ) * 1.5 + 5.
   frame {&frame-name} :width-chars  = 78.

   form
       Btn_OK     at row 1 column  1
       Btn_Cancel at row 1 column 12
     {&Btn_Help}  at row 1 column 24
   with frame {&frame-name}.

   do i = 1 to num-entries( lab, '{&delim-flt}' ) :
        assign lab_             = entry( i, lab, '{&delim-flt}' ) + ": "
               cur-label-length = LENGTH( lab_ ).
        IF cur-label-length > max-label-length THEN DO: ASSIGN max-label-length = cur-label-length. END.
        create text txt
                   assign
                     frame        = frame {&frame-name} :handle
                     data-type    = "character"
                     format       = "x(" + Int2Char( cur-label-length )  + ")"
                     screen-value = lab_
                     row          = i * 1.5
                     column       = 1.5.
   end.
   do i = 1 to num-entries( type, '{&delim-flt}' ) :
        assign
              type_ = entry( i, type, '{&delim-flt}' )
              fld_  = entry( i, fld,  '{&delim-flt}' )
              lab_  = entry( i, lab,  '{&delim-flt}' )
        .
        ASSIGN cur-type-length = INTEGER( ENTRY( LOOKUP( type_, type_list ), format_list ) ).
        IF i = 1 THEN DO: ASSIGN type-length-1st = cur-type-length. END.
        IF cur-type-length > max-type-length THEN DO: ASSIGN max-type-length = cur-type-length. END.
        case type_ :
           when {&abl-datatype-character} then do: assign frm = format_character. end.
           when {&abl-datatype-integer}   then do: assign frm = format_integer.   end.
           when {&abl-datatype-int64}   then do: assign frm = format_int64.   end.
           when {&abl-datatype-decimal}   then do: assign frm = format_decimal.   end.
           when {&abl-datatype-date}      then do: assign frm = format_date.      end.
           when {&abl-datatype-logical}   then do: assign frm = format_logical.   end.
           when {&abl-datatype-recid}     then do: assign frm = format_recid.     end.
        end case. /* type_ */
        create fill-in fill_in
                   assign
                     frame        = frame {&frame-name} :handle
                     data-type    = type_
                     format       = frm
                     private-data = fld_ + ',' + lab_
                     row          = i * 1.5
                     column       = max-label-length + 1
                     sensitive    = yes
                     visible      = yes.
   end.

   frame {&frame-name} :width-chars = max-label-length + max-type-length + 6.

   assign
        Btn_OK      :row       = i * 1.5 + 1
        Btn_OK      :column    = 2
        Btn_OK      :visible   = yes
        Btn_OK      :sensitive = yes
   .

   ASSIGN
        {&Btn_Help} :ROW       = i * 1.5 + 1
        {&Btn_Help} :COLUMN    = MAX( 25, max-label-length + type-length-1st - 5 )
        {&Btn_Help} :VISIBLE   = YES
        {&Btn_Help} :SENSITIVE = YES
   .

   assign
        Btn_Cancel  :row       = i * 1.5 + 1
        Btn_Cancel  :column    = MAX( 12, {&Btn_Help} :COLUMN - 12 )
        Btn_Cancel  :visible   = yes
        Btn_Cancel  :sensitive = yes
   .

   if spr <> "" then do:
       form Btn_Reference with frame {&frame-name}.

       assign
            Btn_Reference :row       = 1.5
            Btn_Reference :column    = max-label-length + type-length-1st + 2
            Btn_Reference :visible   = yes
            Btn_Reference :sensitive = yes
       .

       on choose of btn_ok in frame {&frame-name} do:
            define variable type_       as character no-undo.
            define variable code_       as integer   no-undo.
            define variable art_        as character no-undo.
            define variable jnum_       as integer   no-undo.
            define variable jsub_       as integer   no-undo.
            define variable jhost-code_ as integer   no-undo.
            define variable v-found     as integer   no-undo extent 4.
            define variable numfdelim   as integer   no-undo.

            assign grp = frame {&frame-name} :first-child.
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
                    if lookup( type_, ( "":U    + {&comma-char} +
                                        {&cmp}  + {&comma-char} +
                                        {&prs}  + {&comma-char} +
                                        {&shop} + {&comma-char} +
                                        {&stock} ) ) = 0 then do:
                      message "Неверный тип клиента".
                      return no-apply.
                    end.
                    if type_ = "":U then do:
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = {&cmp}
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 1 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = {&prs}
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 2 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = {&shop}
                         AND ub.clients.obj-code = code_ NO-ERROR.
                        if available ub.clients then do: assign v-found[ 3 ] = 1. end.
                        FIND ub.clients WHERE
                             ub.clients.obj-type  = {&stock}
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
                                  type_ = {&cmp}
                            .
                          end.
                          if v-found[ 2 ]  = 1 then do:
                            assign
                                  type_ = {&prs}
                            .
                          end.
                          if v-found[ 3 ]  = 1 then do:
                            assign
                                  type_ = {&shop}
                            .
                          end.
                          if v-found[ 4 ]  = 1 then do:
                            assign
                                  type_ = {&stock}
                            .
                          end.
                          if v-found [ 1 ] + v-found [ 2 ] + v-found [ 3 ] + v-found [ 4 ] > 0 then do:
                            assign grp = frame {&frame-name} :first-child.
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
                        end. /* else found[ .. ] */
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

       on choose of Btn_Reference in frame {&frame-name} do:
           define variable grp-rec  as recid     no-undo.
           define variable ref-rec  as recid     no-undo.
           define variable ref-list as character no-undo.
           define variable out-an   as integer   no-undo.
           define variable numfdelim as integer  no-undo.
           case spr :
                when 'cli' then do:
                      ref-list = "".
                      run ref/cli-all.w (  input parParentProc,
                                       input "{&Btn_Select}",
                                       input {&cmp},
                                       input {&all},
                                       input {&current},
                                       input ?,
                                       input ",,,,,,NO":U,
                                       input ?,
                                      output ref-list         ) .
                      assign ref-rec = integer( entry( 1, ref-list ) ).
                      if ref-rec <> 0 then do:
                        find ub.clients where recid( ub.clients ) = ref-rec.
                        assign name = ub.clients.obj-name.
                        assign grp = frame {&frame-name} :first-child.
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
                        apply "entry":u  to Btn_OK in frame {&frame-name}.
                        apply "choose":u to Btn_OK in frame {&frame-name}.
                      end.
                      else do:
                        apply "entry":u to Btn_Reference in frame {&frame-name}.
                     end.
                end.
                when 'gds' then do:
                  run ref/gds-ref.p (    INPUT ParParentProc
                                  ,  INPUT "{&Btn_Select}"    /* buttons    */
                                  ,  INPUT ?                  /* p-stat     */
                                  ,  INPUT ?                  /* p-list     */
                                  ,  INPUT ?                  /* p-cond     */
                                  ,  INPUT ?                  /* p-rec      */
                                  ,  INPUT ?                  /* p-grp      */
                                  ,  INPUT ?                  /* p-cli-type */
                                  ,  INPUT ?                  /* p-cli-code */
                                  ,  INPUT ?                  /* p-obj-type */
                                  ,  INPUT ?                  /* p-obj-code */
                                  ,  INPUT ?                  /* p-other    */
                                  , OUTPUT ref-list        ).
                  assign ref-rec = integer( entry( 1, ref-list ) ).
                  if ref-list <> "" then do:
                    find ub.goods where recid( ub.goods ) = ref-rec.
                    assign name = ub.goods.gds-name.
                    assign grp  = frame {&frame-name} :first-child.
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
                      apply "entry":u  to Btn_OK in frame {&frame-name}.
                      apply "choose":u to Btn_OK in frame {&frame-name}.
                  end.              else do: apply "entry":u to Btn_Reference in frame {&frame-name}. end.
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
                        assign grp = frame {&frame-name} :first-child.
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
                        apply "entry":u  to Btn_OK in frame {&frame-name}.
                        apply "choose":u to Btn_OK in frame {&frame-name}.
                      end.
                      else do:
                        apply "entry":u to Btn_Reference in frame {&frame-name}.
                     end.
                end.

           end case. /* spr */
       end. /* on choose of Btn_Reference */
   end. /* if spr <> "" */

   { gbl/hot-key.i  {&Btn_Help} }
   { gbl/app_help.i             }

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.

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
     grp = frame {&frame-name} :first-child
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
                s             = {&question-mark}
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
  VIEW FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE replace-special-char W-Win
PROCEDURE replace-special-char :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
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
      /* если в строке была двойная кавычка, */
      /* то она меняется на своё представление через код */
      /* двойная кавычка должна меняться первой */
      assign
        v-out-string = replace(v-out-string, '"', v-enclose-char + ' + chr(' + string(asc('"')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '~~') > 0
    then do:
      /* если в строке была тильда, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, '~~', v-enclose-char + ' + chr(' + string(asc('~~')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, ',') > 0
    then do:
      /* если в строке была запятая, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, ',', v-enclose-char + ' + chr(' + string(asc(',')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, "'") > 0
    then do:
      /* если в строке была одинарная кавычка, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, "'", v-enclose-char + ' + chr(' + string(asc("'")) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '/') > 0
    then do:
      /* если в строке был символ наклонной черты, */
      /* то он меняется на своё представление через код */
      /* это делается для того, чтобы в строке случайно не возникло символа */
      /* начала комментария */
      assign
        v-out-string = replace(v-out-string, '/', v-enclose-char + ' + chr(' + string(asc('/')) + ') + ' + v-enclose-char)
      .
    end.

    assign
      p-out-string = v-out-string
    .
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME