&glob param_1 iGdsCode
define input  parameter {&Param_1} like ub.goods.gds-code no-undo.

{ gbl/objsrv.i }

&glob buf_obj-hist c-gds-hist
&Glob VisibleKeyField yes
{ref/brwhist.i &Paramonly = yes}

run ref/cgdshist.w (
      input parParentProc
    , input p-curr-host-code
    , input p-curr-obj-type
    , input p-curr-obj-code
    , input bttns
    , input p-mode
    , input iGdsCode
    , input ?
    , input ?
    , input ?
    , input p-corr-user-db-num
    , input p-corr-user-name
    , input p-subject
    , input p-db-num
    , input-output p-rid-list  ) no-error .