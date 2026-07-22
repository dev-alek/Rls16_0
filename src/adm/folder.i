
/*------------------------------------------------------------------------
    File        : folder.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : asmorozov
    Created     : Tue Sep 29 15:51:19 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initialize-folder Dialog-Frame 
PROCEDURE initialize-folder :
  /* -----------------------------------------------------------
        Purpose:     Creates the dynamic images for a tab or notebook
                     folder.
        Parameters:  <none>
        Notes:       Run automatically as part of folder startup.
      -------------------------------------------------------------*/   
  
  define input parameter folder-labels as character no-undo.
  

  define variable i             as integer   no-undo.
  define variable temp-hdl      as handle    no-undo.             
  define variable del-hdl       as handle    no-undo.             
  define variable rebuild       as logical   no-undo init no.
  define variable sts           as logical   no-undo.
    
  /*    RUN get-attribute IN THIS-PROCEDURE ('FOLDER-LABELS':U).*/
  /*    ASSIGN folder-labels = IF RETURN-VALUE = ? THEN "":U    */
  /*                           ELSE RETURN-VALUE.               */

  /*    RUN get-attribute IN THIS-PROCEDURE ('FOLDER-TAB-TYPE':U).*/
  assign 
    tab-type = 1 .

  assign 
    number-of-pages = num-entries(folder-labels,'|':U).
  /*    RUN set-size (FRAME {&FRAME-NAME}:HEIGHT, FRAME {&FRAME-NAME}:WIDTH).*/
    
  /* Get the folder's CONTAINER for triggers.
     Note that in design mode the CONTAINER may not be specified;
     the code takes this into account. Also the broker will not
     be available in design mode. */
  /*    IF valid-handle(adm-broker-hdl) THEN DO:                                   */
  /*        RUN get-link-handle IN adm-broker-hdl                                  */
  /*           (INPUT THIS-PROCEDURE, INPUT 'CONTAINER-SOURCE':U, OUTPUT char-hdl).*/
  /*        ASSIGN container-hdl = WIDGET-HANDLE(char-hdl).                        */
  /*    END.                                                                       */
      
  if valid-handle(up-image) then 
  do:  /* Rebuilding an existing folder */
    temp-hdl = frame {&FRAME-NAME}:HANDLE.
    temp-hdl = temp-hdl:first-child.    /* Field group */
    temp-hdl = temp-hdl:first-child.   /* First dynamic widget */
    do while valid-handle(temp-hdl):  
      del-hdl = temp-hdl.
      temp-hdl = temp-hdl:next-sibling.
      if del-hdl:private-data = "Tab-Folder":U then delete widget del-hdl.  
    end.
  end.

  create image up-image
    assign 
    frame             = frame {&FRAME-NAME}:HANDLE
    x                 = 0 + pos-x
    y                 = 0 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = {&tab-height} + 4
    private-data      = "Tab-Folder":U
    hidden            = no.  /* Do this explicitly or it's sometimes hidden. */
  assign
    sts = up-image:load-image("adeicon/ts-up":U +
         STRING(width-tab-values[tab-type])).
    
    

      
  do i = 1 to number-of-pages:       
    if entry(i,folder-labels,'|':U) ne "":U then /*Allow skipping of pos'ns*/
      run create-folder-label (i, entry(i, folder-labels,'|':U)).
  end. 
    
  view frame {&FRAME-NAME}.  
  /*    sts = FRAME {&FRAME-NAME}:MOVE-TO-BOTTOM().*/
  run change-folder-page.
     
  return.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-folder-page Dialog-Frame 
PROCEDURE change-folder-page :
  /* -----------------------------------------------------------
        Purpose:    Changes the folder visualization when a new page is
                    selected (from the folder or elsewhere). 
        Parameters:  <none>
        Notes: 
      -------------------------------------------------------------*/   

  define variable sts   as logical no-undo.
  define variable page# as integer no-undo.
   
  /*    IF VALID-HANDLE (container-hdl) THEN DO:                  */
  /*        RUN get-attribute IN container-hdl ('CURRENT-PAGE':U).*/
  /*        ASSIGN page# = INT(RETURN-VALUE).                     */
  /*    END.                                                      */
  /*    ELSE ASSIGN page# = 1.    /* For design mode. */*/
    
  if page# > 0 and page# <= {&max-labels} and
    VALID-HANDLE (page-label[page#]) then
  do: 
    assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4 
      up-image:hidden = no
      sts             = up-image:move-to-top().
  end.
 
  return. 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-folder-label Dialog-Frame 
PROCEDURE create-folder-label :
  /* -----------------------------------------------------------
        Purpose:     Defines an image for a single tab and sets its label.
        Parameters:  INPUT page number, label
        Notes:       
      -------------------------------------------------------------*/   
     
  define input parameter p-page#        as integer   no-undo.
  define input parameter p-page-label   as character no-undo.

  define variable sts as log no-undo.
  
  create image image-hdl[p-page#]
    assign 
    frame             = frame {&FRAME-NAME}:HANDLE
    x                 = (p-page# - 1) * width-tab-values[tab-type] + pos-x 
    y                 = 2 + pos-y
    width-pixel       = width-tab-values[tab-type]
    height-pixel      = {&tab-height}
    private-data      = "Tab-Folder":U
    sensitive         = yes
    triggers:      
      on mouse-select-click 
        persistent run label-trigger in THIS-PROCEDURE (p-page#).        
    end triggers.         

                        
  create text page-label[p-page#]
    assign 
    frame             = frame {&FRAME-NAME}:HANDLE
    y                 = image-hdl[p-page#]:y + 2
    x                 = image-hdl[p-page#]:x + 9
    width-pixel       = image-hdl[p-page#]:WIDTH-PIXEL - 18
    height-pixel      = image-hdl[p-page#]:HEIGHT-PIXEL - 4
    format            = "X(13)":U
    sensitive         = yes 
    font              = if tab-type = 1 then ? else 4 /* smaller for narrow */
    bgcolor           = 8                 /* Light gray to match the image */
    screen-value      = p-page-label
    private-data      = "Tab-Folder":U
    triggers:      
      on mouse-select-click 
        persistent run label-trigger in THIS-PROCEDURE (p-page#).        
    end triggers.
      
  assign      
    sts = image-hdl[p-page#]:load-image("adeicon/ts-dn":U + 
                STRING(width-tab-values[tab-type])).
  sts = image-hdl[p-page#]:move-to-top().
  sts = page-label[p-page#]:move-to-top().

  assign 
    page-enabled[p-page#]      = yes
    image-hdl[p-page#]:hidden  = no     /* Set HIDDEN off explicitly */
    page-label[p-page#]:hidden = no.   /*  or it may come up hidden. */
  
  return.  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-folder-page Dialog-Frame 
PROCEDURE create-folder-page :
  /* -----------------------------------------------------------
        Purpose:     Create a new tab label after initialization.
        Parameters:  INPUT new page number, new tab label
        Notes:       Usage: RUN get-link-handle IN adm-broker-hdl
                        (THIS-PROCEDURE, 'PAGE-SOURCE',OUTPUT page-hdl).
                            RUN create-folder-page 
                               IN WIDGET-HANDLE(page-hdl) (<page,label>)
      -------------------------------------------------------------*/   

  define input parameter p-page#      as integer   no-undo.
  define input parameter p-new-label  as character no-undo.

  define variable i          as integer   no-undo.
  define variable num-labels as integer   no-undo. 
  define variable labels     as character no-undo.
  define variable new-labels as character no-undo init "".
   
  run get-attribute ('FOLDER-LABELS':U).
  assign 
    labels = return-value.   
  if labels = ? then labels = "". 
    
  num-labels = num-entries(labels,'|':U).
  /* If the new label is on a page that already exists, replace it. */
  if p-page# <= num-labels then
  do i = 1 to num-labels:
    new-labels = new-labels + 
      if i = p-page# then p-new-label
      else entry(i, labels, '|':U).
    if i < num-labels then new-labels = new-labels + '|':U.
  end.
  else 
  do:
    /* If this is higher than the current labels, insert the
       right number of elimiters to make room for it. */
    new-labels = labels.
    do i = 1 to p-page# - num-labels - if num-labels = 0 then 1 else 0:
      new-labels = new-labels + '|':U. 
    end.
    new-labels = new-labels + p-new-label.   
  end.                      
    
  run set-attribute-list in THIS-PROCEDURE 
    ('FOLDER-LABELS = ':U + new-labels).
  run initialize-folder.
        
  return.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-folder-page Dialog-Frame 
PROCEDURE delete-folder-page :
  /* -----------------------------------------------------------
        Purpose:     Remove the tab for a page
        Parameters:  INPUT page number to delete
        Notes:       Usage: RUN get-link-handle IN adm-broker-hdl
                        (THIS-PROCEDURE, 'PAGE-SOURCE',OUTPUT page-hdl).
                            RUN delete-folder-page 
                               IN WIDGET-HANDLE(page-hdl) (<page-number>)
      -------------------------------------------------------------*/   

  define input parameter p-page#  as integer no-undo.

  define variable i      as integer   no-undo.
  define variable pos1   as integer   no-undo init 0.
  define variable pos2   as integer   no-undo. 
  define variable labels as character no-undo.
   
  run get-attribute ('FOLDER-LABELS':U).
  assign 
    labels = return-value.

  if valid-handle (page-label[p-page#]) then /* Make sure this page exists */
    delete widget page-label[p-page#].
  if valid-handle (image-hdl[p-page#]) then  
    delete widget image-hdl[p-page#].  
                          
  /* Remove the label from the FOLDER-LABELS attribute list */
  do i = 1 to p-page# - 1:                                      
    pos1 = index(labels,'|':U, pos1 + 1).
  end.
  pos2 = index(labels,'|':U, pos1 + 1).
  labels = if pos2 ne 0 then SUBSTR(labels, 1, pos1, "CHARACTER":U) +
    SUBSTR(labels, pos2, -1, "CHARACTER":U)       
    else SUBSTR(labels, 1, pos1 - 1, "CHARACTER":U).
  run set-attribute-list in THIS-PROCEDURE 
    ('FOLDER-LABELS = ':U + labels).

  return. 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-folder-page Dialog-Frame 
PROCEDURE disable-folder-page :
  /* -----------------------------------------------------------
        Purpose:     Disable and gray out the tab for a page
        Parameters:  INPUT page number to disable
        Notes:       Usage: RUN get-link-handle IN adm-broker-hdl
                        (THIS-PROCEDURE, 'PAGE-SOURCE',OUTPUT page-hdl).
                            RUN disable-folder-page 
                               IN WIDGET-HANDLE(page-hdl) (<page-number>)
      -------------------------------------------------------------*/   

  define input parameter p-page#  as integer no-undo.

  assign 
    page-enabled[p-page#]       = no
    page-label[p-page#]:fgcolor = 7.  /* Gray out the text */
  return. 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-folder-page Dialog-Frame 
PROCEDURE enable-folder-page :
  /* -----------------------------------------------------------
        Purpose:     Enable the tab for a page
        Parameters:  INPUT page number to enable
        Notes:       Usage: RUN get-link-handle IN adm-broker-hdl
                        (THIS-PROCEDURE, 'PAGE-SOURCE',OUTPUT page-hdl).
                            RUN enable-folder-page 
                               IN WIDGET-HANDLE(page-hdl) (<page-number>)
      -------------------------------------------------------------*/   

  define input parameter p-page#  as integer no-undo.

  assign 
    page-enabled[p-page#]       = yes
    page-label[p-page#]:fgcolor = ?.  /* Restore the text */
  return. 
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE label-trigger Dialog-Frame 
PROCEDURE label-trigger :
  /*------------------------------------------------------------------------------
    Purpose:     This procedure serves as the trigger code for each tab label.
    Parameters:  INPUT page number
    Notes:       Used internally only in the definition of tab labels.
  ------------------------------------------------------------------------------*/
  define input parameter p-page# as integer no-undo.
  
  {2} = p-page#.
  run {1} in this-procedure no-error.
  if error-status:error 
    then return.
  run show-current-page(input p-page#).

  return.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize Dialog-Frame 
PROCEDURE local-initialize :
/* -----------------------------------------------------------
      Purpose:     Local version of the initialize method which starts up
                   the folder object. This runs initialize-folder with
                   the folder attributes.
      Parameters:  <none>
      Notes:       The folder initialization is suppressed in character mode.
    -------------------------------------------------------------*/   
&IF "{&WINDOW-SYSTEM}":U <> "TTY":U &THEN
  run initialize-folder.
  run dispatch in THIS-PROCEDURE ('initialize':U).
&ENDIF
  return.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-size Dialog-Frame 
PROCEDURE set-size :
  /*------------------------------------------------------------------------------
    Purpose:     Sets the size of the rectangles which make up the folder
                 "image" whenever it is resized.
    Parameters:  INPUT height and width.
    Notes:       Run automatically when the folder is initialized or resized.
  ------------------------------------------------------------------------------*/
  define input parameter p-height as decimal no-undo.
  define input parameter p-width  as decimal no-undo.
  
&IF "{&WINDOW-SYSTEM}":U <> "TTY":U &THEN  
  define variable sts as logical.
 
  /* This is the minimum height needed for all the tabs and rectangles to exist: */
  if p-height < 1.35 then p-height = 1.35.
  
  do with frame {&FRAME-NAME}:
     
    /*      ASSIGN Rect-Main:HIDDEN = yes                */
    /*             Rect-Top:HIDDEN = yes                 */
    /*             Rect-Bottom:HIDDEN = yes              */
    /*             Rect-Left:HIDDEN = yes                */
    /*             Rect-Right:HIDDEN = yes               */
    /*             Rect-Main:HEIGHT = 1                  */
    /*             Rect-Main:WIDTH  = 1                  */
    /*             Rect-Top:WIDTH  = 1                   */
    /*             Rect-Bottom:height-pixels   = p-height*/
    /*             Rect-Bottom:WIDTH  = 1                */
    /*             Rect-Left:HEIGHT = 1                  */
    /*             Rect-Right:width-pixels    = p-width  */
    /*             Rect-Right:HEIGHT = 1 no-error.       */
   
    /* Adjust the virtual height to match the new height, to avoid
             scrollbars - note that the frame can't be made non-scrollable
             because that may cause errors *during* a resize. 
             Also adjust the virtual width to match the new width or the
             required width of the tab images, whichever is greater;
             in the latter case scrollbars will appear. */
    /*         FRAME {&FRAME-NAME}:HEIGHT = p-height                    */
    /*         FRAME {&FRAME-NAME}:WIDTH  = p-width                     */
    /*         FRAME {&FRAME-NAME}:VIRTUAL-HEIGHT-PIXELS =              */
    /*             FRAME {&FRAME-NAME}:HEIGHT-PIXELS                    */
    /*         FRAME {&FRAME-NAME}:VIRTUAL-WIDTH-PIXELS  =              */
    /*             IF (tab-type = 0)    /* May not have been set yet. */*/
    /*             OR (number-of-pages <=                               */
    /*                 (FRAME {&FRAME-NAME}:WIDTH-PIXELS                */
    /*                   / width-tab-values[tab-type] ))                */
    /*            THEN FRAME {&FRAME-NAME}:WIDTH-PIXELS                 */
    /*            ELSE number-of-pages * width-tab-values[tab-type] + 2.*/
            
    assign 
      Rect-Main:X               = 0 + pos-x
      Rect-Main:Y               = {&tab-height} + pos-y
      Rect-Main:WIDTH-PIXELS    = p-width
      Rect-Main:HEIGHT-PIXELS   = p-height
                                     - {&tab-height} 
      Rect-Top:X                = 1 + pos-x
      Rect-Top:Y                = {&tab-height} + 1 + pos-y
      Rect-Top:WIDTH-PIXELS     = p-width
                                     - 3
      Rect-Top:HEIGHT-PIXELS    = 3
      Rect-Bottom:X             = 1 + pos-x
      Rect-Bottom:Y             = p-height - 4 + pos-y
      Rect-Bottom:HEIGHT-PIXELS = 3
      Rect-Bottom:WIDTH-PIXELS  = p-width
                                     - 2
      Rect-Left:X               = 1 + pos-x
      Rect-Left:Y               = {&tab-height} + 1 + pos-y
      Rect-Left:WIDTH-PIXELS    = 3
      Rect-Left:HEIGHT-PIXELS   = p-height
                                     - {&tab-height} - 2
      Rect-Right:X              = p-width + pos-x
                                     - 4
      Rect-Right:Y              = {&tab-height} + 4 + pos-y
      Rect-Right:WIDTH-PIXELS   = 3         
      Rect-Right:HEIGHT-PIXELS  = p-height
                                     - {&tab-height} - 5
      Rect-Main:HIDDEN          = no
      Rect-Top:HIDDEN           = no
      Rect-Bottom:HIDDEN        = no
      Rect-Left:HIDDEN          = no
      Rect-Right:HIDDEN         = no. 
  end.
          
  return.
&ENDIF
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-current-page Dialog-Frame 
PROCEDURE show-current-page :
  /*------------------------------------------------------------------------------
    Purpose:     Shows the tab for "current" folder page
    Parameters:  page# - (INTEGER) The current page.
    Notes:       
  ------------------------------------------------------------------------------*/
  define input parameter page# as integer no-undo.

  define variable sts as logical no-undo.

  if page# > 0 and page# <= {&max-labels} and
    VALID-HANDLE (page-label[page#]) 
    then assign
      up-image:x      = page-label[page#]:x -  9
      up-image:y      = page-label[page#]:y -  4 
      up-image:hidden = no
      sts             = up-image:move-to-top().
  /* If there are no tabs at all leave the up-image viewed for appearance.
     Otherwise if the user has selected page 0, hide the up-image in order
     to visually deselect all pages. */
  else if number-of-pages > 0 then
      assign up-image:hidden = yes.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed Dialog-Frame 
PROCEDURE state-changed :
  /* -----------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  -------------------------------------------------------------*/

  define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME