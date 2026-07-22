using Progress.Lang.*.
using Progress.Windows.Form.
using ibs.th.str.*.
using ibs.th.str.ptrl.forms.* from propath.
using System.Windows.Forms.* from assembly.
block-level on error undo, throw.
class ibs.th.str.ptrl.forms.tanksections inherits Form:
  define property infoSecsObj as class ibs.th.str.InfoSectionsTotal no-undo
    get.
    private set.
  define property tankSectionControl as class tanksection extent 10 no-undo
    get.
    private set.
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable imageList as System.Windows.Forms.ImageList no-undo.
  define private variable tableLayoutPanel1 as System.Windows.Forms.TableLayoutPanel no-undo.
  define private variable tabPage as System.Windows.Forms.TabPage no-undo.
  define private variable tabPageAdd as System.Windows.Forms.TabPage no-undo.
  define private variable tabPageSum as System.Windows.Forms.TabPage no-undo.
  define private variable tabPageArr as System.Windows.Forms.TabPage extent 10 no-undo.
  define private variable tabControl as System.Windows.Forms.TabControl no-undo.
  define private variable tankSectionSumControl as class tanksum no-undo.
  define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
  define private variable toolSBtn_View as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Status as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Star as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Print as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Ok as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Main as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_History as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Exit as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Edit as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Delete as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Copy as System.Windows.Forms.ToolStripButton no-undo.
  define private variable toolSBtn_Add as System.Windows.Forms.ToolStripButton no-undo.
  define private variable vClickSave as logical no-undo initial no .
  define private variable maxSec as integer no-undo.
  define private variable prevTabIndex as integer no-undo.
  define private variable screenHeight as integer no-undo .
  define public variable formHeight as integer no-undo .
  constructor public tanksections (infoSecs as class InfoSectionsTotal):
    super().
    assign
      screenHeight = Screen:PrimaryScreen:WorkingArea:Height
      formHeight = 882
    .
    infoSecsObj = infoSecs.
    if infoSecs:SectionNum = 0
      then undo, throw new Progress.Lang.AppError ("Ошибка при создании формы, отсутсвуют секции по доп. инфо.").
    InitializeComponent().
    if infoSecsObj:FlagTrn and screenHeight < (formHeight + 30) then this-object:ClientSize = new System.Drawing.Size(713, screenHeight - 40).
    if (infoSecsObj:Mode = "ИЗМЕНЕНИЕ" or infoSecsObj:Mode = "ДОБАВЛЕНИЕ")
    then do:
      this-object:tabControl:Deselecting:Subscribe(tabControlCancelEvntHndl).
    end.
    SetDataControls ().
    maxSec = extent (tabPageArr).
    this-object:ComponentsCollection:Add(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public tanksections ():
    super().
    assign
      screenHeight = Screen:PrimaryScreen:WorkingArea:Height
      formHeight = 882
    .
    infoSecsObj = new InfoSectionsTotal ().
    infoSecsObj:GetDBAllAttr().
    if infoSecsObj:SectionNum = 0
      then undo, throw new Progress.Lang.AppError ("Ошибка при создании формы, отсутсвуют секции по доп. инфо.").
    InitializeComponent().
    if infoSecsObj:FlagTrn and screenHeight < (formHeight + 30) then this-object:ClientSize = new System.Drawing.Size(713, screenHeight - 40).
    if (infoSecsObj:Mode = "ИЗМЕНЕНИЕ" or infoSecsObj:Mode = "ДОБАВЛЕНИЕ")
    then do:
      this-object:tabControl:Deselecting:Subscribe(tabControlCancelEvntHndl).
    end.
    SetDataControls ().
    maxSec = extent (tabPageArr).
    this-object:ComponentsCollection:Add(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  method private void SetDataControls():
    def var ii as int no-undo.
    define variable v-tth             as handle    no-undo .
    define variable par-type          as character no-undo .
    define variable v-value-char      as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-rvd-own-nb      as logical   no-undo .
    define buffer buf_trn-doc for ub.trn-doc .
    if not valid-object (infoSecsObj)
    then do:
      undo, throw new Progress.Lang.AppError ("Ошибка при создании формы, передан неверный параметр, не иницализирован объект типа InfoSectionsTotal").
    end.
    run adm/shattri.p (
               input "get":U
              ,input  infoSecsObj:ObjType
              ,input  infoSecsObj:ObjCode
              ,input  'petrol':U
              ,input  'rvd-own-nb':U
              ,output v-value-char
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-rvd-own-nb
              ,output par-type
              ,input-output table-handle v-tth
              ) no-error .
    if error-status:error then do:
        if valid-object(v-tth) then delete object v-tth.
        v-rvd-own-nb = false .
    end.
    do ii = 1 to infoSecsObj:SectionNum:
      infoSecsObj:GetInfoSectionProp(ii).
      InitializeComponentCust().
      if infoSecsObj:SectionNum = 0
        then return.
      this-object:tabPageArr[infoSecsObj:idSecCurr]:Text = string (infoSecsObj:InfoSectionCurr:SectionName).
      tankSectionControl[infoSecsObj:idSecCurr] = new tanksection(infoSecsObj, infoSecsObj:idSecCurr, this-object).
      this-object:tabPageArr[infoSecsObj:idSecCurr]:Controls:Add(tankSectionControl[infoSecsObj:idSecCurr]).
    end.
    SetDataSum ().
    if (infoSecsObj:Mode = "ИЗМЕНЕНИЕ" or infoSecsObj:Mode = "ДОБАВЛЕНИЕ") and not infoSecsObj:FlagTrn
      then do:
        toolSBtn_Delete:Visible = true.
        this-object:tabControl:Controls:Add(this-object:tabPageAdd).
      end.
    if infoSecsObj:FlagTrn
      then this-object:tabControl:Controls:Add(this-object:tabPageSum).
    if (infoSecsObj:Mode = "ПРОСМОТР")
    then do:
      toolSBtn_Delete:Visible = false.
      toolSBtn_Ok:Visible = false.
    end.
    if v-rvd-own-nb = false
    then do :
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = infoSecsObj:TrnDocNum no-error .
      if available buf_trn-doc
      then do :
        find first ub.clients-attr no-lock where ub.clients-attr.obj-type = buf_trn-doc.cli-type
                                             and ub.clients-attr.obj-code = buf_trn-doc.cli-code
                                             and ub.clients-attr.attr-code = 'owner-code':U
                                             no-error .
        if available ub.clients-attr
        and ub.clients-attr.attr-value > ""
        then do :
          if ub.clients-attr.attr-value = "орг" + string(buf_trn-doc.host-code)
          then do :
            toolSBtn_Delete:Visible = false.
            this-object:tabControl:Controls:Remove(this-object:tabPageAdd).
          end .
        end .
      end .
    end .
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end.
  method private void SetDataSum ():
    tankSectionSumControl:SetData(infoSecsObj).
  end.
  method private void InitializeComponent(  ):
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable resources as Progress.Util.ResourceManager no-undo.
    resources = new Progress.Util.ResourceManager("ibs.th.str.ptrl.forms.tanksections").
    this-object:tabControl = new System.Windows.Forms.TabControl().
    this-object:imageList = new System.Windows.Forms.ImageList(this-object:components).
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
    this-object:toolSBtn_Exit = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Ok = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Delete = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Add = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Star = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Main = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_View = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Edit = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Copy = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Status = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_Print = new System.Windows.Forms.ToolStripButton().
    this-object:toolSBtn_History = new System.Windows.Forms.ToolStripButton().
    this-object:tabPageSum = new System.Windows.Forms.TabPage().
    this-object:tankSectionSumControl = new ibs.th.str.ptrl.forms.tanksum().
    this-object:tabPageAdd = new System.Windows.Forms.TabPage().
    this-object:tableLayoutPanel1:SuspendLayout().
    this-object:toolStrip1:SuspendLayout().
    this-object:tabPageSum:SuspendLayout().
    this-object:SuspendLayout().
    define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    this-object:tabControl:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:tabControl:ImageList = this-object:imageList.
    this-object:tabControl:Location = new System.Drawing.Point(3, 45).
    this-object:tabControl:Name = "tabControl".
    this-object:tabControl:SelectedIndex = 0.
    this-object:tabControl:Size = new System.Drawing.Size(716, 832).
    this-object:tabControl:TabIndex = 1.
    this-object:imageList:ColorDepth = System.Windows.Forms.ColorDepth:Depth8Bit.
    this-object:imageList:ImageSize = new System.Drawing.Size(16, 16).
    this-object:imageList:TransparentColor = System.Drawing.Color:Transparent.
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:toolStrip1, 0, 0).
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(3, 3).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 1.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(710, 40).
    this-object:tableLayoutPanel1:TabIndex = 0.
    this-object:toolStrip1:AutoSize = false.
    this-object:toolStrip1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:toolStrip1:ImageScalingSize = new System.Drawing.Size(32, 32).
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.ToolStripItem extent 3 no-undo.
    arrayvar0[1] = this-object:toolSBtn_Exit.
    arrayvar0[2] = this-object:toolSBtn_Ok.
    arrayvar0[3] = this-object:toolSBtn_Delete.
    this-object:toolStrip1:Items:AddRange(arrayvar0).
    this-object:toolStrip1:Location = new System.Drawing.Point(0, 0).
    this-object:toolStrip1:Name = "toolStrip1".
    this-object:toolStrip1:Size = new System.Drawing.Size(710, 40).
    this-object:toolStrip1:TabIndex = 0.
    this-object:toolStrip1:Text = "toolStrip1".
    this-object:toolSBtn_Exit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
    this-object:toolSBtn_Exit:Image = cast(resources:GetObject("toolSBtn_Exit.Image"), System.Drawing.Image).
    this-object:toolSBtn_Exit:ImageTransparentColor = System.Drawing.Color:Magenta.
    this-object:toolSBtn_Exit:Name = "toolSBtn_Exit".
    this-object:toolSBtn_Exit:Size = new System.Drawing.Size(36, 37).
    this-object:toolSBtn_Exit:Text = "Выход без сохранения".
    this-object:toolSBtn_Exit:Click:Subscribe(this-object:toolSBtn_Exit_Click).
    this-object:toolSBtn_Ok:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
    this-object:toolSBtn_Ok:Image = cast(resources:GetObject("toolSBtn_Ok.Image"), System.Drawing.Image).
    this-object:toolSBtn_Ok:ImageTransparentColor = System.Drawing.Color:Magenta.
    this-object:toolSBtn_Ok:Name = "toolSBtn_Ok".
    this-object:toolSBtn_Ok:Size = new System.Drawing.Size(36, 37).
    this-object:toolSBtn_Ok:Text = "Сохранить".
    this-object:toolSBtn_Ok:Click:Subscribe(this-object:toolSBtn_Ok_Click).
    this-object:toolSBtn_Delete:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
    this-object:toolSBtn_Delete:Image = cast(resources:GetObject("toolSBtn_Delete.Image"), System.Drawing.Image).
    this-object:toolSBtn_Delete:ImageTransparentColor = System.Drawing.Color:Magenta.
    this-object:toolSBtn_Delete:Name = "toolSBtn_Delete".
    this-object:toolSBtn_Delete:Size = new System.Drawing.Size(36, 37).
    this-object:toolSBtn_Delete:Text = "Удалить секцию".
    this-object:toolSBtn_Delete:Visible = false.
    this-object:toolSBtn_Delete:Click:Subscribe(this-object:toolSBtn_Delete_Click).
    this-object:toolSBtn_Add:Name = "toolSBtn_Add".
    this-object:toolSBtn_Add:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Star:Name = "toolSBtn_Star".
    this-object:toolSBtn_Star:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Main:Name = "toolSBtn_Main".
    this-object:toolSBtn_Main:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_View:Name = "toolSBtn_View".
    this-object:toolSBtn_View:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Edit:Name = "toolSBtn_Edit".
    this-object:toolSBtn_Edit:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Copy:Name = "toolSBtn_Copy".
    this-object:toolSBtn_Copy:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Status:Name = "toolSBtn_Status".
    this-object:toolSBtn_Status:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_Print:Name = "toolSBtn_Print".
    this-object:toolSBtn_Print:Size = new System.Drawing.Size(23, 23).
    this-object:toolSBtn_History:Name = "toolSBtn_History".
    this-object:toolSBtn_History:Size = new System.Drawing.Size(23, 23).
    this-object:tabPageSum:Controls:Add(this-object:tankSectionSumControl).
    this-object:tabPageSum:Location = new System.Drawing.Point(4, 23).
    this-object:tabPageSum:Name = "tabPageSum".
    this-object:tabPageSum:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPageSum:Size = new System.Drawing.Size(702, 765).
    this-object:tabPageSum:TabIndex = 0.
    this-object:tabPageSum:Text = "Итого".
    this-object:tabPageSum:UseVisualStyleBackColor = true.
    this-object:tabPageSum:Enter:Subscribe(this-object:tabPageSum_Enter).
    this-object:tankSectionSumControl:BackgroundImage = cast(resources:GetObject("tankSectionSumControl.BackgroundImage"), System.Drawing.Image).
    this-object:tankSectionSumControl:Location = new System.Drawing.Point(0, 0).
    this-object:tankSectionSumControl:Name = "tankSectionSumControl".
    this-object:tankSectionSumControl:Size = new System.Drawing.Size(700, 765).
    this-object:tankSectionSumControl:TabIndex = 0.
    this-object:tabPageAdd:Location = new System.Drawing.Point(4, 23).
    this-object:tabPageAdd:Name = "tabPageAdd".
    this-object:tabPageAdd:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPageAdd:Size = new System.Drawing.Size(702, 765).
    this-object:tabPageAdd:TabIndex = 0.
    this-object:tabPageAdd:Text = "+".
    this-object:tabPageAdd:UseVisualStyleBackColor = true.
    this-object:tabPageAdd:Enter:Subscribe(this-object:tabPageAdd_Enter).
    this-object:AutoScroll = true.
    this-object:AutoScrollMargin = new System.Drawing.Size(0, 835).
    this-object:AutoScrollMinSize = new System.Drawing.Size(0, 5).
    this-object:ClientSize = new System.Drawing.Size(713, 882).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Controls:Add(this-object:tabControl).
    this-object:Icon = cast(resources:GetObject("$this.Icon"), System.Drawing.Icon).
    this-object:Name = "tanksections".
    this-object:Text = "Дополнительная информация по сливу нефтепродукта из АЦ".
    this-object:FormClosing:Subscribe(this-object:tool_FormClosing).
    this-object:tableLayoutPanel1:ResumeLayout(false).
    this-object:toolStrip1:ResumeLayout(false).
    this-object:toolStrip1:PerformLayout().
    this-object:tabPageSum:ResumeLayout(false).
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  method private void InitializeComponentCust(  ):
    this-object:tabPage = new System.Windows.Forms.TabPage().
    this-object:tabPage:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPage:Size = new System.Drawing.Size(771, 491).
    this-object:tabPage:Text = infoSecsObj:InfoSectionCurr:SectionName.
    this-object:tabPage:Name = string (infoSecsObj:InfoSectionCurr:idSec).
    this-object:tabPage:UseVisualStyleBackColor = true.
    this-object:tabPage:ImageIndex = 0.
    this-object:tabControl:Controls:Add(this-object:tabPage).
    tabPageArr[infoSecsObj:idSecCurr] = this-object:tabPage.
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end.
  @VisualDesigner.
  method private void tabControlCancelEvntHndl( input sender as System.Object, input e as System.Windows.Forms.TabControlCancelEventArgs ):
    def var ii as int no-undo.
    def var tabThis as TabPage no-undo.
    def var tbcontrol as TabControl no-undo.
    tbcontrol = cast(sender, tabControl).
    if tabControl:SelectedIndex < 0
      then return.
    if tabControl:TabPages[tabControl:SelectedIndex] = tabPageSum or tabControl:TabPages[tabControl:SelectedIndex] = tabPageAdd
      then return.
    tabThis = tabControl:TabPages[tabControl:SelectedIndex].
    int (tabThis:Name) no-error.
    if not error-status:error and not tankSectionControl[integer (tabThis:Name)]:CheckSec(yes, yes, no)
    then do:
      tankSectionControl[integer (tabThis:Name)]:SetForcus ().
      tbcontrol = cast(sender, tabControl).
      e:Cancel = true.
      return.
    end.
    return.
  end method.
        @VisualDesigner.
        method private void tool_FormClosing( input sender as System.Object, input e as System.Windows.Forms.FormClosingEventArgs ):
                define variable vlog as logical no-undo .
                define variable ii as integer no-undo .
                define variable numsecs as character no-undo .
                define variable v-sec as character no-undo .
                define buffer buf_rvs-doc for ub.rvs-doc .
                if infoSecsObj:Mode = "ИЗМЕНЕНИЕ" or infoSecsObj:Mode = "ДОБАВЛЕНИЕ"
                then do :
                  if vClickSave
                  then do :
                    if not infoSecsObj:FlagTrn
                    then do :
                      numsecs = "" .
                      do ii = 1 to infoSecsObj:SectionNum:
            if infoSecsObj:GetInfoSectionProp(ii):alarm-SGDKK
            then do :
              numsecs = numsecs + infoSecsObj:GetInfoSectionProp(ii):SectionName + chr(10) .
            end .
          end.
          if numsecs > ""
          then do :
            message "Для секций " skip
                    numsecs
                    "установлены флаги «Тревожное событие СЭП». По обозначенным  секциям будет активирован  комиссионный прием. Продолжить?"
            view-as alert-box question buttons yes-no update vlog .
            if not vlog
            then do :
              e:Cancel = yes .
              vClickSave = no .
              infoSecsObj:WasSetting = no .
            end .
            else do :
              do ii = 1 to infoSecsObj:SectionNum:
                if infoSecsObj:GetInfoSectionProp(ii):alarm-SGDKK
                then do :
                  infoSecsObj:GetInfoSectionProp(ii):IsKP = yes .
                end .
              end.
            end .
          end .
          numsecs = "" .
          do ii = 1 to infoSecsObj:SectionNum:
            if infoSecsObj:GetInfoSectionProp(ii):KPnoMeas
            then do :
              numsecs = numsecs + infoSecsObj:GetInfoSectionProp(ii):SectionName + chr(10) .
            end .
          end.
          if numsecs > ""
          then do :
            message "Для секций " skip
                    numsecs
                    "установлены флаги «Переход к комиссионному приему НП без замеров секции АЦ». По обозначенным  секциям будет активирован  комиссионный прием. Продолжить?"
            view-as alert-box question buttons yes-no update vlog .
            if not vlog
            then do :
              e:Cancel = yes .
              vClickSave = no .
              infoSecsObj:WasSetting = no .
            end .
            else do :
              do ii = 1 to infoSecsObj:SectionNum:
                if infoSecsObj:GetInfoSectionProp(ii):KPnoMeas
                then do :
                  infoSecsObj:GetInfoSectionProp(ii):IsKP = yes .
                end .
              end.
            end .
          end .
          if infoSecsObj:Mode = "ИЗМЕНЕНИЕ" then infoSecsObj:SaveDB() .
                    end .
                  end .
                  else do :
        message "Несохранённые данные будут утеряны! Выйти без сохранения?"
        view-as alert-box question buttons yes-no update vlog .
        if not vlog
        then do :
          e:Cancel = yes .
        end .
      end .
    end .
                return.
        end method.
  @VisualDesigner.
  method private void toolSBtn_Exit_Click( input sender as System.Object, input e as System.EventArgs ):
    vClickSave = no .
    this-object:Close().
    return.
  end method.
  @VisualDesigner.
  method private void toolSBtn_Ok_Click( input sender as System.Object, input e as System.EventArgs ):
    define variable ii as integer no-undo .
    define variable v-idSel as int no-undo.
    define variable tabsel as TabPage no-undo.
    tabsel = tabControl:SelectedTab.
    if tabsel:Name = "tabPageSum"
    then do :
      v-idSel = infoSecsObj:SectionNum .
    end .
    else do :
      v-idSel = integer (tabsel:Name).
    end .
    if infoSecsObj:FlagTrn
    then do :
      do ii = 1 to infoSecsObj:SectionNum:
        tabControl:SelectTab(ii - 1) .
      end .
      tabControl:SelectTab(v-idSel - 1) .
    end .
    do ii = 1 to infoSecsObj:SectionNum:
      if not tankSectionControl[ii]:CheckSec(yes, if infoSecsObj:FlagTrn then no else yes, yes)
      then do :
        tabControl:SelectTab(ii - 1) .
        return.
      end .
    end.
    do ii = 1 to infoSecsObj:SectionNum:
      tankSectionControl[ii]:SetInfoSec().
    end.
    infoSecsObj:WasSetting = true.
    vClickSave = yes .
    this-object:Close().
    return.
  end method.
  @VisualDesigner.
  method private void toolSBtn_Delete_Click( input sender as System.Object, input e as System.EventArgs ):
    define variable ii as integer no-undo .
    define variable v-idSel as int no-undo.
    define variable tabsel as TabPage no-undo.
    if infoSecsObj:SectionNum = 1
    then do:
      message "Нельзя удалять одну единственную секцию." view-as alert-box information title "Сообщение".
      return.
    end.
    tabsel = tabControl:SelectedTab.
    if tabsel:Name = "tabPageSum"
    then do :
      v-idSel = infoSecsObj:SectionNum .
    end .
    else do :
      v-idSel = integer (tabsel:Name).
    end .
    this-object:tabControl:Controls:Remove(tabPageAdd).
    do ii = 1 to infoSecsObj:SectionNum:
      if ii <> v-idSel
        then tankSectionControl[ii]:SetInfoSec().
      this-object:tabControl:Controls:Remove (this-object:tabPageArr[ii]).
      delete object this-object:tabPageArr[ii].
    end.
    infoSecsObj:GetInfoSectionProp(v-idSel).
    infoSecsObj:DeleteSection(infoSecsObj:InfoSectionCurr:idSec).
    SetDataControls().
    return.
  end.
  @VisualDesigner.
  method private void tabPageSum_Enter( input sender as System.Object, input e as System.EventArgs ):
    infoSecsObj:CalculateTotal().
    SetDataSum ().
  end.
  @VisualDesigner.
  method private void tabPageAdd_Enter( input sender as System.Object, input e as System.EventArgs ):
    if infoSecsObj:SectionNum >= maxSec
    then do:
      message "Максимальное количество секций - " maxSec ". Невозможно добавить секцию." view-as alert-box information title "Сообщение".
      tabControl:SelectedIndex = prevTabIndex.
      return.
    end.
    infoSecsObj:NewSection ().
    infoSecsObj:InfoSectionCurr:UserMode = true.
    this-object:tabPageArr[infoSecsObj:idSecCurr] = this-object:tabPageAdd.
    this-object:tabPageArr[infoSecsObj:idSecCurr]:Name = string (infoSecsObj:idSecCurr).
    this-object:tabPageArr[infoSecsObj:idSecCurr]:Enter:Unsubscribe(this-object:tabPageAdd_Enter).
    this-object:tabPageAdd = new System.Windows.Forms.TabPage().
    this-object:tabPageAdd:Location = new System.Drawing.Point(4, 23).
    this-object:tabPageAdd:Name = "tabPageAdd".
    this-object:tabPageAdd:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPageAdd:Size = new System.Drawing.Size(702, 765).
    this-object:tabPageAdd:TabIndex = 1.
    this-object:tabPageAdd:Text = "+".
    this-object:tabPageAdd:Enter:Subscribe(this-object:tabPageAdd_Enter).
    this-object:tabPageAdd:UseVisualStyleBackColor = true.
    this-object:tabPageArr[infoSecsObj:idSecCurr]:Text = string (infoSecsObj:InfoSectionCurr:SectionName).
    this-object:tankSectionControl[infoSecsObj:idSecCurr] = new tanksection(infoSecsObj, infoSecsObj:idSecCurr, this-object).
    this-object:tabPageArr[infoSecsObj:idSecCurr]:Controls:Add(tankSectionControl[infoSecsObj:idSecCurr]).
    this-object:tabControl:Controls:Add(tabPageAdd).
    return.
  end method.
  method public void SetSecName (arg as char):
    tabControl:SelectedTab:Text = arg.
  end.
  destructor public tanksections ( ):
    tankSectionSumControl:Dispose() .
    delete object tankSectionSumControl no-error .
  end destructor.
end class.
