Function Form-Control {
    [CmdletBinding(DefaultParametersetName='Self')]param(
        [Parameter(Position = 0)]$Control = "Form",
        [Parameter(Position = 1)][HashTable]$Member = @{},
        [Parameter(ParameterSetName = 'AttachChild',  Mandatory = $false)][Windows.Forms.Control[]]$Add = @(),
        [Parameter(ParameterSetName = 'AttachParent', Mandatory = $false)][HashTable]$Set = @{},
        [Parameter(ParameterSetName = 'AttachParent', Mandatory = $false)][Alias("Parent")][Switch]$GetParent,
        [Parameter(ParameterSetName = 'AttachParent', Mandatory = $true, ValueFromPipeline = $true)][Windows.Forms.Control]$Container
    )
    If ($Control -isnot [Windows.Forms.Control]) {Try {$Control = New-Object Windows.Forms.$Control} Catch {$PSCmdlet.WriteError($_)}}
    $Styles = @{RowStyles = "RowStyle"; ColumnStyles = "ColumnStyle"}
    ForEach ($Key in $Member.Keys) {
        If ($Style = $Styles.$Key) {[Void]$Control.$Key.Clear()
            For ($i = 0; $i -lt $Member.$Key.Length; $i++) {[Void]$Control.$Key.Add((New-Object Windows.Forms.$Style($Member.$Key[$i])))}
        } Else {
            Switch (($Control | Get-Member $Key).MemberType) {
                "Property"  {$Control.$Key = $Member.$Key}
                "Method"    {Invoke-Expression "[Void](`$Control.$Key($($Member.$Key)))"}
                "Event"     {Invoke-Expression "`$Control.Add_$Key(`$Member.`$Key)"}
                Default     {Write-Error("The $($Control.GetType().Name) control doesn't have a '$Key' member.")}
            }
        }
    }
    $Add | ForEach {$Control.Controls.Add($_)}
    If ($Container) {$Container.Controls.Add($Control)}
    If ($Set) {$Set.Keys | ForEach {Invoke-Expression "`$Container.Set$_(`$Control, `$Set.`$_)"}}
    If ($GetParent) {$Container} Else {$Control}
}; Set-Alias Form Form-Control
