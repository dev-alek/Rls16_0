block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usrs-prn.p $
$Archive: rep/usrs-prn.p $

Автор: Белоусов Илья Александрович
Дата создания: 05/10/07
Author: Ilia Belousov
Creation date: 05/10/07

Печать списков пользователей системы и их прав

*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: usrs-prn.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/usrs-prn.p $":U .
def var vss-description as character no-undo init "Список пользователей системы".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menu-doc.i def }
{ gbl/getcntxt.i def }

{ gbl/cur-time.i }

/*
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ rep/f-fdec.i     }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ rep/lkp-font.i   }


{ rep/fmtcli.i     }
{ trg/factord.i    }
{ gbl/clntattr.i   }
{ str/clcprtsl.i   }
{ str/trdcalib.i   }
*/
/*
{ cmp/library.i    }
{ rep/f-fdec.i     }
{ gbl/waitfram.i   }

{ rep/fmtcli.i     }
{ str/clcprtsl.i   }
{ gbl/clntattr.i   }
{ gbl/paramls.i    }
{ str/trdcalib.i   }
*/

define input  parameter parparentproc as widget-handle no-undo .
define input parameter p-user-id like user-account.user-id no-undo.
define input parameter p-db-num  AS INTEGER no-undo.

DEFINE STREAM out-stream .

DEFINE VARIABLE LineCounter AS INTEGER INITIAL 0   NO-UNDO .
define variable v-user-action   as character no-undo .
define variable v-printed       as logical   no-undo .
define variable Line            as character no-undo.
define variable g#report-num              as integer              no-undo .

def var sym1 as char init ":!:"   no-undo.
def var sym2 as char init ":!:"   no-undo.
def var sym3 as char init ":!:"   no-undo.
MESSAGE 123
view-as alert-box.
run get-report-num in parparentproc (output g#report-num).
{ cmp/open-out.i stream out-stream " " {&CS_PS} }


DEFINE FRAME main
    sym1 column-label ":!:" format "x(1)"
    clients.obj-name     column-label "Макс. скидка / Объекты / Армы! " format "x(100)"
    sym2 column-label ":!:" format "x(1)"
    action-role.action-role-name  column-label "Группа прав! "
    sym3 column-label ":!:" format "x(1)"

    HEADER
        cur-time-print() AT 5 format "x(35)"
            string( "Страница " + string (PAGE-NUMBER( out-stream ) , ">>9") )
                    AT 45 format "X(15)" SKIP
        Line format "X(127)" AT 1
with width {&A4_CW} down stream-io .


FORM HEADER
      Line format "X(127)" SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
      VIEW stream out-stream FRAME BottomFrame .


if session:set-wait-state("compiler") then.
Line = fill("-", 140).

FORM with FRAME main .

if p-user-id = ? then
    PUT STREAM out-stream SPACE(30) "С П И С О К    П О Л Ь З О В А Т Е Л Е Й  С И С Т Е М Ы" FORMAT "X(127)" SKIP.

account_:
FOR EACH  user-account
    WHERE user-account.user-id = p-user-id
    OR    p-user-id = ?
    NO-LOCK
    :
       FIND FIRST user-login
            WHERE user-login.user-id = p-user-id
              AND (user-login.db-num  = p-db-num
                          /*OR  p-db-num = ?*/ )
            NO-LOCK
            NO-ERROR
            .
       IF NOT AVAILABLE user-login THEN DO:
          NEXT account_.
       END.

       FIND FIRST _user WHERE _user._userid = user-login.user-login NO-LOCK NO-ERROR.
       if NOT available _user then
           do:
               message string('Пользователь "' + user-account.user-id + '" не найден в таблице _user!') view-as alert-box ERROR.
               NEXT.
           end.
       LineCounter = LineCounter + 1 .

       DISPLAY stream  out-stream
           sym1
           string( string( LineCounter, ">>9" )
                 + ") Пользователь: "
                 + trim( _user._user-name )
                 ) @ clients.obj-name
           sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .

       DISPLAY stream  out-stream
           sym1
           string( "     Макс. скидка: " + trim( string( user-login.max-discnt ) ) + " %" ) @ clients.obj-name
           sym2 sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .

       DISPLAY stream  out-stream
           sym1 "     Объекты:" @ clients.obj-name
           sym2 sym3
       with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .

       FOR EACH  user-login-action-role
           WHERE user-login-action-role.user-id             = user-account.user-id
             and user-login-action-role.db-num              = p-db-num
             and user-login-action-role.action-role-context = {&cntxt-object}
           NO-LOCK,
           FIRST action-role
           WHERE action-role.db-num           = p-db-num
             AND action-role.action-head-code = {&action-head-code-main}
             AND action-role.action-role-code = user-login-action-role.action-role-code
           NO-LOCK
           :
            FIND FIRST clients
                 WHERE clients.obj-type = user-login-action-role.obj-type
                 AND   clients.obj-code = user-login-action-role.obj-code
                 NO-LOCK
                 NO-ERROR.
            IF NOT AVAILABLE clients THEN
                DO:
                    MESSAGE STRING('В ДБ нет объекта "' + user-login-action-role.obj-type + ' ' + string(user-login-action-role.obj-code) + '" принадлежащего пользователю ' + trim( _user._user-name ) ) view-as alert-box ERROR.
                    NEXT.
                END.
            DISPLAY stream  out-stream
                sym1 clients.obj-name
                sym2 action-role.action-role-name
                sym3
            WITH FRAME main .
            DOWN STREAM  out-stream 1 with FRAME main .
       END.

       DISPLAY stream  out-stream
           sym1 "     Армы:" @ clients.obj-name
           sym2 sym3
           with FRAME main .
       DOWN stream  out-stream 1 with FRAME main .

       FOR EACH  user-login-action-role
           WHERE user-login-action-role.user-id             = user-account.user-id
             and user-login-action-role.db-num              = p-db-num
             and user-login-action-role.action-role-context = {&cntxt-firm}
           NO-LOCK,
           FIRST action-role
           WHERE action-role.db-num           = p-db-num
             AND action-role.action-head-code = {&action-head-code-main}
             AND action-role.action-role-code = user-login-action-role.action-role-code
           NO-LOCK
           :
           DISPLAY stream out-stream
               sym1
               string( "фирма " + string(user-login-action-role.host-code) + ")" ) @ clients.obj-name
               sym2 action-role.action-role-name @ action-role.action-role-name
               sym3
               with FRAME main .
           DOWN stream  out-stream 1 with FRAME main .
       END.
END.

IF ( LINE-COUNTER( out-stream ) + 1 ) > PAGE-SIZE( out-stream )
THEN PAGE STREAM out-stream .

PUT STREAM out-stream Line FORMAT "X(127)" SKIP.
HIDE STREAM out-stream FRAME BottomFrame .
OUTPUT STREAM out-stream CLOSE.

run gbl/prnfilen.w
                   ( input  "":U
                   , input  0
                   , input  string(session :temp-directory)
                          + {&DF_Name}
                          + string( g#report-num )
                   , input  7
                   , output v-user-action
                   , output v-printed
                   ) .