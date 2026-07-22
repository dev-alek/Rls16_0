block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendmail.p $
$Archive: gbl/sendmail.p $

отправка сообщений по email

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/01/08
Author: Dmitry Ukhanov
Creation date: 10/01/08

*/

define input parameter p-send-address as character no-undo .
define input parameter p-subject-text as character no-undo .
define input parameter p-body-text    as longchar  no-undo .
define input parameter p-files-attach as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendmail.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sendmail.p $":U .
define variable vss-description as character no-undo init "отправка сообщений по email".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/windows.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-work-dir as character no-undo .
  define variable v-result   as integer   no-undo .
  define variable v-err-msg  as character no-undo .

  assign
    v-err-msg            = "":U
    file-info :file-name = ".":U
    v-work-dir           = file-info :full-pathname
  .
  run SendMail-MAPI in this-procedure
    ( input p-send-address
     ,input p-subject-text
     ,input p-body-text
     ,input p-files-attach
    ) no-error .
  if error-status :error
    or return-value <> "":U
  then do:
    assign
      v-err-msg = substitute( "&1. Не удалось отправить сообщение. &2&3. &2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) )
    .
  end.
  run SetCurrentDirectoryA
    (input  v-work-dir
    ,output v-result
    ).

  assign
    file-info :file-name = '.':U
  .
  if v-work-dir <> file-info :full-pathname then do:
    assign
      v-err-msg = substitute( "&1. Не удалось установить в качесте рабочего каталог &2. Текущий каталог &3", vss-workfile, v-work-dir, file-info :full-pathname )
    .
  end.
  if v-err-msg <> "":U then do:
    return error v-err-msg .
  end.
end.

procedure SetCurrentDirectoryA external "kernel32.dll":
    define input  parameter chrcurdir as character.
    define return parameter intresult as long.
end procedure.

procedure MAPIReturnCode :
  define input  parameter p-err-code as integer   no-undo .
  define output parameter p-err-msg  as character no-undo .

  case p-err-code:
    when  1 then p-err-msg = "user abort".
    when  2 then p-err-msg = "failure".
    when  3 then p-err-msg = "login failure".
    when  4 then p-err-msg = "disk full".
    when  5 then p-err-msg = "insufficient memory".
    when  6 then p-err-msg = "blk too small".
    when  8 then p-err-msg = "too many sessions".
    when  9 then p-err-msg = "too many files".
    when 10 then p-err-msg = "too many recipients".
    when 11 then p-err-msg = "attachment not found".
    when 12 then p-err-msg = "attachment open failure".
    when 13 then p-err-msg = "attachment write failure".
    when 14 then p-err-msg = "unknown recipient".
    when 15 then p-err-msg = "bad recipient type".
    when 16 then p-err-msg = "no messages".
    when 17 then p-err-msg = "invalid message".
    when 18 then p-err-msg = "bodytext too large".
    when 19 then p-err-msg = "invalid session".
    when 20 then p-err-msg = "type not supported".
    when 21 then p-err-msg = "ambiguous recipient".
    when 22 then p-err-msg = "message in use".
    when 23 then p-err-msg = "network failure".
    when 24 then p-err-msg = "invalid edit fields".
    when 25 then p-err-msg = "invalid recipients".
    when 26 then p-err-msg = "feature not supported".
    otherwise p-err-msg    = "unknown error".
  end case.

  return .

end procedure.

/* ---------- internal procedures ------------------ */

procedure SendMail-MAPI :
/*  define input parameter p-orig-name     as character no-undo.                 /* originator name */*/
  define input parameter p-recip-name    as character no-undo.                 /* recipient(s) names, comma separated */
  define input parameter p-subject       as character no-undo.
  define input parameter p-body-text     as character no-undo.
  define input parameter p-file-pathname as character no-undo.                 /* attachment(s) names, comma separated */

  do
  on error  undo, return error substitute( "&1 (SendMail-MAPI). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (SendMail-MAPI). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (SendMail-MAPI). endkey", vss-workfile )
  :
    define variable v-ind           as integer             no-undo.
    define variable v-err-code      as integer             no-undo.
    define variable v-err-msg       as character           no-undo.
    define variable v-ind-recips    as integer             no-undo.                /* count recipients */
    define variable v-ind-attachs   as integer             no-undo.                /* count attachments */
    define variable v-recip-name    as character extent 20 no-undo.                /* recipient array */
    define variable v-file-name     as character extent 20 no-undo.                /* array of attachment name */
    define variable v-file-pathname as character extent 20 no-undo.                /* attachment array */

    /* memptr definitions */
    define variable v-subj-ptr          as memptr no-undo.                         /* message subject */
    define variable v-text-ptr          as memptr no-undo.                         /* message text */
    /*define variable originnameptr       as memptr.                               /* originator name */*/
    /*define variable origindescptr       as memptr.*/
    define variable v-recip-name-ptr    as memptr extent 20 no-undo.               /* array of pointers to recipient name */
    define variable v-recip-desc-ptr    as memptr extent 20 no-undo.               /* array of pointers to recipient description */
    define variable v-file-pathname-ptr as memptr extent 20 no-undo.               /* array of pointers to attachment path */
    define variable v-file-name-ptr     as memptr extent 20 no-undo.               /* array of pointers to attachment name */
    define variable v-file-desc-ptr     as memptr extent 20 no-undo.               /* array of pointers to attachment description */
    define variable v-msg-desc-ptr      as memptr no-undo.                         /* pointer to message structure */
    define variable v-file-array-ptr    as memptr no-undo.                         /* pointer to array of file decription */
    define variable v-recip-array-ptr   as memptr no-undo.                         /* pointer to array of recipient */

    assign
      v-err-msg = "":U
    .
    /* --- populate recipient & attachment arrays -------*/
    assign
      v-ind-recips = 0
    .
    do while p-recip-name <> "":U
    :
      assign
        v-ind = index( p-recip-name, ",":U )
      .
      if v-ind > 0 then do:
        assign
          v-ind-recips            = v-ind-recips + 1
          v-recip-name[v-ind-recips] = substring( p-recip-name, 1, v-ind - 1 )
          p-recip-name          = substring( p-recip-name, v-ind + 1 )
        .
      end.
      else do:
        if p-recip-name <> "":U then do:
          assign
            v-ind-recips            = v-ind-recips + 1
            v-recip-name[v-ind-recips] = p-recip-name
            p-recip-name          = "":U
          .
        end.
      end.
    end.

    /* populate filepath name */
    assign
      v-ind-attachs = 0
    .
    do while p-file-pathname <> "":U
    :
      assign
        v-ind = index(p-file-pathname, ",":U)
      .
      if v-ind > 0 then do:
        assign
          v-ind-attachs               = v-ind-attachs + 1
          v-file-pathname[v-ind-attachs] = trim( substring( p-file-pathname, 1, v-ind - 1 ) )
          p-file-pathname           = trim( substring( p-file-pathname, v-ind + 1 ) )
        .
      end.
      else do:
        if p-file-pathname <> "":U then do:
          assign
            v-ind-attachs               = v-ind-attachs + 1
            v-file-pathname[v-ind-attachs] = trim(p-file-pathname)
            p-file-pathname           = "":U
          .
        end.
      end.
    end.

    /* --- set message text and subject -----------------*/
    set-size(v-subj-ptr)     = length(p-subject) + 1.                              /* maximum = 255 */
    put-string(v-subj-ptr,1) = p-subject.

    set-size(v-text-ptr)     = 16000.
    put-string(v-text-ptr,1) = p-body-text.

    /* --- build originator details ---------------------*/
    /*set-size(originnameptr)     = length(p-orig-name) + 1.                       /* maximum = 255 */*/
    /*put-string(originnameptr,1) = p-orig-name.                                   /* originator name */*/

    /*set-size(origindescptr)    = 24.*/
    /*put-long(origindescptr,1)  = 0.                                             /* reserved */*/
    /*put-long(origindescptr,5)  = 0.                                             /* recipclass 0 = mapi_orig */*/
    /*put-long(origindescptr,9)  = get-pointer-value(originnameptr).              /* name */*/
    /*put-long(origindescptr,13) = 0.                                             /* address */*/
    /*put-long(origindescptr,17) = 0.                                             /* eid size */*/
    /*put-long(origindescptr,21) = 0.                                             /* entry id */*/

    /* ---------- build recipient details -------------- */
    do v-ind = 1 to v-ind-recips
    :
      set-size(v-recip-name-ptr[v-ind])     = length(v-recip-name[v-ind]) + 1.           /* maximum = 255 */
      put-string(v-recip-name-ptr[v-ind],1) = v-recip-name[v-ind].                       /* recipient name */

      set-size(v-recip-desc-ptr[v-ind])     = 24.
      put-long(v-recip-desc-ptr[v-ind],1)   = 0.                                      /* reserved */
      put-long(v-recip-desc-ptr[v-ind],5)   = 1.                                      /* recipclass 1 = mapi_to */
      put-long(v-recip-desc-ptr[v-ind],9)   = get-pointer-value(v-recip-name-ptr[v-ind]). /* name */
      put-long(v-recip-desc-ptr[v-ind],13)  = 0.                                      /* address */
      put-long(v-recip-desc-ptr[v-ind],17)  = 0.                                      /* eid size */
      put-long(v-recip-desc-ptr[v-ind],21)  = 0.                                      /* entry id */
    end.

    /* populate memory indicated by v-recip-array-ptr */
    set-size(v-recip-array-ptr) = 24 * v-ind-recips.
    do v-ind = 1 to v-ind-recips
    :
      put-bytes(v-recip-array-ptr, (v-ind * 24) - 23)  = get-bytes(v-recip-desc-ptr[v-ind],1,24).
    end.

    /* ---------- build file details ------------------- */
    /* build file description array */
    do v-ind = 1 to v-ind-attachs
    :

        set-size(v-file-pathname-ptr[v-ind])     = length(v-file-pathname[v-ind]) + 1.      /* maximum = 255 */
        put-string(v-file-pathname-ptr[v-ind],1) = v-file-pathname[v-ind].                  /* file pathname */

        assign
          v-file-name[v-ind] = substring(v-file-pathname[v-ind],r-index(v-file-pathname[v-ind],"\":u) + 1)
        .

        set-size(v-file-name-ptr[v-ind])     = length(v-file-name[v-ind]) + 1.                /* maximum = 255 */
        put-string(v-file-name-ptr[v-ind],1) = v-file-name[v-ind].                            /* file name */

        set-size(v-file-desc-ptr[v-ind])    = 24.
        put-long(v-file-desc-ptr[v-ind],1)  = 0.                                         /* reserved */
        put-long(v-file-desc-ptr[v-ind],5)  = 0.                                         /* flags 0 = data file */
        put-long(v-file-desc-ptr[v-ind],9)  = -1.                                        /* position */
        put-long(v-file-desc-ptr[v-ind],13) = get-pointer-value(v-file-pathname-ptr[v-ind]). /* pathname */
        put-long(v-file-desc-ptr[v-ind],17) = get-pointer-value(v-file-name-ptr[v-ind]).      /* file name */
        put-long(v-file-desc-ptr[v-ind],21) = 0.                                         /* filetype */
    end.

    /* populate memory indicated by v-file-array-ptr */
    set-size(v-file-array-ptr) = 24 * v-ind-attachs.
    do v-ind = 1 to v-ind-attachs
    :
        put-bytes(v-file-array-ptr, (v-ind * 24) - 23)  = get-bytes(v-file-desc-ptr[v-ind],1,24).
    end.

    /* ---------- build message details ---------------- */
    set-size(v-msg-desc-ptr)    = 48.
    put-long(v-msg-desc-ptr,1)  = 0.                                            /* reserved */
    put-long(v-msg-desc-ptr,5)  = get-pointer-value(v-subj-ptr).                   /* subject */
    put-long(v-msg-desc-ptr,9)  = get-pointer-value(v-text-ptr).                   /* text */
    put-long(v-msg-desc-ptr,13) = 0.                                            /* messagetype */
    put-long(v-msg-desc-ptr,17) = 0.                                            /* datereceived */
    put-long(v-msg-desc-ptr,21) = 0.                                            /* conversationid */
    put-long(v-msg-desc-ptr,25) = 1.                                            /* flags */
    /*put-long(v-msg-desc-ptr,29) = get-pointer-value(origindescptr).             /* originator */*/
    put-long(v-msg-desc-ptr,33) = v-ind-recips.                                    /* recipcount */
    put-long(v-msg-desc-ptr,37) = get-pointer-value(v-recip-array-ptr).             /* recips */
    put-long(v-msg-desc-ptr,41) = v-ind-attachs.                                   /* filecount */
    put-long(v-msg-desc-ptr,45) = get-pointer-value(v-file-array-ptr).              /* files */

    /* ---------- send message ------------------------- */
    run MAPISendMail in hpapi
      ( input 0                             /* mapi session handle */
      ,input 0                             /* parent window handle */
      ,input get-pointer-value( v-msg-desc-ptr )
      ,input 0                             /* 1 = mapi_logon_ui + 2 = mapi_new_session + 8 = mapi_dialog */
      ,input 0                             /* reserved, must be 0 */
      ,output v-err-code                   /* error status */
      ) no-error .
    if error-status :error
      and v-err-code = 0
    then do:
      assign
        v-err-msg = substitute( "&1. Сообщение не отправлено. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      .
    end.
    else do:
      if v-err-code <> 0 then do:
        run MAPIReturnCode in this-procedure
          ( input  v-err-code
           ,output v-err-msg
          ).
        assign
          v-err-msg = substitute( "Сообщение не отправлено. &1 (&2)", v-err-msg, v-err-code )
        .
      end.
    end.

    /* ---------- release resources -------------------- */
    set-size(v-subj-ptr) = 0.
    set-size(v-text-ptr) = 0.

    do v-ind = 1 to v-ind-attachs
    :
      set-size(v-file-pathname-ptr[v-ind]) = 0.
      set-size(v-file-name-ptr[v-ind])      = 0.
      set-size(v-file-pathname-ptr[v-ind]) = 0.
      set-size(v-file-desc-ptr[v-ind])     = 0.
    end.

    do v-ind = 1 to v-ind-recips
    :
      set-size(v-recip-name-ptr[v-ind])    = 0.
      set-size(v-recip-desc-ptr[v-ind])    = 0.
    end.

    set-size(v-msg-desc-ptr) = 0.
    set-size(v-file-array-ptr)   = 0.
    set-size(v-recip-array-ptr)  = 0.
    /*set-size(originnameptr)  = 0.*/

    if valid-handle(hpapi) then do:
      delete object hpapi.
    end.
  end.

  return v-err-msg .

end procedure.