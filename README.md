Syntax
------

**Creating a control**  
`<System.Windows.Forms.Control> = Form-Control [-Control <String>] [-Member <HashTable>]`
   
**Modifying a control**  
`<Void> = Form-Control [-Control <System.Windows.Forms.Control>] [-Member <HashTable>]`
   
**Adding a (new) control to a container**  
`<System.Windows.Forms.Control> = Form-Control [-Control <String>|<System.Windows.Forms.Control>] [-Member <HashTable>] [-Add <System.Windows.Forms.Control[]>]`
   
**Piping a container to a (new) control**  
`<System.Windows.Forms.Control> = <System.Windows.Forms.Control> | Form-Control [-Control <String>|<System.Windows.Forms.Control>] [-Member <HashTable>] [-Set <HashTable>] [-PassParent]`

Parameters
----------

**`-Control <String>|<System.Windows.Forms.Control>`** <sub>(position 0, default: `Form`)</sub>  
The `-Control` parameter accepts either a Windows form control type name (`[String]`) or an existing form control (`[System.Windows.Forms.Control]`  ). Windows form control type names are like [`Form`, `Label`, `TextBox`, `Button`, `Panel`, `...`](https://docs.microsoft.com/dotnet/framework/winforms/controls/windows-forms-controls-by-function), etc.
If a Windows form control type name (`[String]`) is supplied, the wrapper will create and return a new Windows form control with properties and settings as defined by the rest of the parameters.  
If an existing Windows form control (`[System.Windows.Forms.Control]`  ) is supplied, the wrapper will update the existing Windows form control using the properties and settings as defined by the rest of the parameters.

**`-Member <HashTable>`** <sub>(position 1)</sub>  
Sets property values, invokes methods and add events on a new or existing object.  

 - If the hash name represents [`property`](https://msdn.microsoft.com/library/system.windows.forms.control_properties%28v=vs.110%29.aspx) on the control, e.g.  `Size = "50, 50"`, the value will be assigned to the control property value.

 - If the hash name represents [`method`](https://msdn.microsoft.com/library/system.windows.forms.control_methods(v=vs.110).aspx) on the control, e.g. `Scale = {1.5, 1.5}`, the control method will be invoked using the value for arguments .

 - If the hash name represents [`event`](https://msdn.microsoft.com/en-us/library/system.windows.forms.control_events(v=vs.110).aspx) on the control, take e.g. `Click = {$Form.Close()}`, the value ( `[ScriptBlock]`) will be added to the control events.

Two collection properties, `ColumnStyles` and `RowStyles`, are simplified especially for the [TableLayoutPanel](https://msdn.microsoft.com/library/system.windows.forms.tablelayoutpanel%28v=vs.110%29.aspx) control which is considered a general substitute for the WPF [Grid](https://msdn.microsoft.com//library/system.windows.controls.grid(v=vs.110).aspx) control:
 - The  [`ColumnStyles`](https://msdn.microsoft.com/library/system.windows.forms.tablelayoutsettings.columnstyles%28v=vs.110%29.aspx) property, clears all column widths and reset them with the [`ColumnStyle`](https://msdn.microsoft.com/library/system.windows.forms.columnstyle%28v=vs.110%29.aspx) array supplied by the hash value.
 - The [`RowStyles`](https://technet.microsoft.com/library/system.windows.forms.tablelayoutsettings.rowstyles%28v=vs.90%29.aspx) property, clears all row Heigths and reset them with the [`RowStyle`](https://msdn.microsoft.com/library/system.windows.forms.rowstyle(v=vs.110).aspx) array supplied by the hash value.  
<sub>*Note:* If want to add or insert a single specific ColumnStyle or RowStyle item, you need to fallback on the native statement, as e.g.: `[Void]$Control.Control.ColumnStyles.Add((New-Object Windows.Forms.ColumnStyle("Percent", 100))`</sub>.

**`-Add <Array>`**  
The `-Add`parameter adds one or more child controls to the current control.  
<sub>*Note:* the `-add` parameter **cannot** be used if container is piped to the control.</sub>

**`-Container <System.Windows.Forms.Control>`** <sub>(from pipeline)</sub>  
The parent container is usually provided from the pipeline:  `$ParentContainer | Form $ChildControl` and attached a (new) child control to the concerned container. 

**`-Set <HashTable>`**  
The `-Set`parameter sets (`SetCellPosition`, `SetColumn`, `SetColumnSpan`, `SetRow`, `SetRowSpan` and `SetStyle`) the specific child control properties related its parent panel container, e.g. .`Set RowSpan = 2`  
<sub>*Note:* the `-set` column - and row parameters can only be used if a container is piped to the control.</sub>

**`-GetParent`**  
By default the (child) control will be returned by the `form-control` function unless the `-GetParent` switch is supplied which will return the parent container instead.
<sub>*Note:* the `-set` column - and row parameters can only be used if a container is piped to the control.</sub>

Examples
--------
There are two way to setup the Windows Forms hierarchy: 

1. Adding a (new) control to a container
2. Piping a container to a (new) control

**Adding a (new) control to a container**   
For this example I have reworked the [Creating a Custom Input Box](https://docs.microsoft.com/powershell/scripting/getting-started/cookbooks/creating-a-custom-input-box?view=powershell-5.1) at docs.microsoft.com using the PowerShell Form-Control wrapper:

    $TextBox      = Form TextBox @{Location = "10, 40";   Size = "260, 20"}
    $OKButton     = Form Button  @{Location = "75, 120";  Size = "75, 23"; Text = "OK";     DialogResult = "OK"}
    $CancelButton = Form Button  @{Location = "150, 120"; Size = "75, 23"; Text = "Cancel"; DialogResult = "Cancel"}
    $Result = (Form-Control Form @{
    		Size = "300, 200"
    		Text = "Data Entry Form"
    		StartPosition = "CenterScreen"
    		KeyPreview = $True
    		Topmost = $True
    		AcceptButton = $OKButton
    		CancelButton = $CancelButton
    	} -Add (
    		(Form Label    @{Text = "Please enter the information below:"; Location = "10, 20"; Size = "280, 20"}),
    		$TextBox, $OKButton, $CancelButton
    	)
    ).ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
    	$x = $TextBox.Text
    	$x
    }

<sub>*Note 1:* Although the adding controls appears more structured especially for small forms, the drawback is that can't invoke methods that relate to both the parent container and child control (like `-Set RowSpan`).</sub>  
<sub>*Note 2:* You might easily get lost in open and close parenthesis if try build child (or even grandchild) controls directly in a parent container (like the above `Label` control). Besides it more difficult to reference such a child (e.g. `$OKButton` vs. `$Form.Controls["OKButton"]`, presuming you have set the button property `Name = "OKButton`)</sub>

**Piping a container to a (new) control**  
For this example, I have created a user interface to test the `dock`property behavior. The form looks like this:

[![enter image description here][1]][1]

The PowerShell Form-Control code required for this:

    $Form   = Form-Control Form @{Text = "Dock test"; StartPosition = "CenterScreen"; Padding = 4; Activated = {$Dock[0].Select()}}
    $Table  = $Form  | Form TableLayoutPanel @{RowCount = 2; ColumnCount = 2; ColumnStyles = ("Percent", 50), "AutoSize"; Dock = "Fill"}
    $Panel  = $Table | Form Panel @{Dock = "Fill"; BorderStyle = "FixedSingle"; BackColor = "Teal"} -Set @{RowSpan = 2}
    $Button = $Panel | Form Button @{Location = "50, 50"; Size = "50, 50"; BackColor = "Silver"; Enabled = $False}
    $Group  = $Table | Form GroupBox @{Text = "Dock"; AutoSize = $True}
    $Flow   = $Group | Form FlowLayoutPanel @{AutoSize = $True; FlowDirection = "TopDown"; Dock = "Fill"; Padding = 4}
    $Dock   = "None", "Top", "Left", "Bottom", "Right", "Fill" | ForEach {
    	$Flow | Form RadioButton @{Text = $_; AutoSize = $True; Click = {$Button.Dock = $This.Text}}
    }
    $Close  = $Table | Form Button @{Text = "Close"; Dock = "Bottom"; Click = {$Form.Close()}}
    $Form.ShowDialog()

For more background, see: [PowerShell Windows Forms Wrapper on StackOverFlow](https://stackoverflow.com/questions/46994238/powershell-windows-forms-wrapper)

  [1]: https://i.stack.imgur.com/u8gP8.png
