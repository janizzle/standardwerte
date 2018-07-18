#Imports
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
Add-type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Sharepoint Snapin
Add-PSSnapin Microsoft.SharePoint.PowerShell

# Connecting site
$site = Get-SPSite "http://infsaa9040:2400"
$webApp = $site.WebApplication

# Getting user inputs
$uSite = [Microsoft.VisualBasic.Interaction]::InputBox("Enter site collection below", "Site Collection")
$uField = [Microsoft.VisualBasic.Interaction]::InputBox("Enter column below", "Column")
$uTerm = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the term value below", "Term value")


# Connecting termset
$taxonomySession = Get-SPTaxonomySession -site $site
$t = $taxonomySession.TermStores["HNT Test Managed Metadata Service"].Groups["HINT Test Intranet"].termsets["Standardwerte"].Terms[$uTerm]

foreach($allSites in $webApp.Sites)
{
       #Loop through all Sub Sites
       foreach($web in $allSites.AllWebs)
       {
            if($web.Title -eq $uSite -or $web.ParentWeb.Title -eq $uSite) {
                Write-Host "-----------------------------------------------------"
                Write-Host "Site Name: '$($web.Title)' at $($web.URL)"
                Write-Host "-----------------------------------------------------"
                
                # Loop through all Lists
                for($i = 0; $i -lt $web.Lists.Count; $i++) {
                    $l = $web.Lists[$i]
                                        
                    # Loop through all fields in list
                    for($y = 0; $y -lt $l.Fields.Count; $y++) {
                        $f = $l.Fields[$y]

                        if($f.Title -eq $uField) {
                            Write-Host $f.ParentList
                            $tVAsString = "-1" + ";#" + $t.GetPath() + [Microsoft.SharePoint.Taxonomy.TaxonomyField]::TaxonomyGuidLabelDelimiter + $t.Id.ToString() 
                            $f.DefaultValue = $tVAsString
                            $f.Update()
                        }
                    }
                }
            }
       }
}