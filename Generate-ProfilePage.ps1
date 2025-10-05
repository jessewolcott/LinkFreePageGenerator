param(
    [Parameter(Mandatory=$false)]
    [string]$LinkedInURL = "",
    
    [Parameter(Mandatory=$false)]
    [string]$EmailAddress = "",
    
    [Parameter(Mandatory=$false)]
    [string]$PhoneNumber = "",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("US", "CA", "UK", "AU", "DE", "FR", "ES", "IT", "NL", "SE", "NO", "DK", "FI")]
    [string]$PhoneCountry = "US",
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubURL = "",
    
    [Parameter(Mandatory=$false)]
    [string]$City = "Anywhere, USA",
    
    [Parameter(Mandatory=$true)]
    [string]$ProfilePicturePath,
    
    [Parameter(Mandatory=$false)]
    [string]$Name = "Your Name",
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Your Description",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "index.html"
)

# Validate that the profile picture file exists
if (-not (Test-Path $ProfilePicturePath -PathType Leaf)) {
    Write-Error "Profile picture file not found: $ProfilePicturePath"
    exit 1
}

# Function to convert image to base64
function Convert-ImageToBase64 {
    param([string]$ImagePath)
    
    try {
        $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $base64String = [System.Convert]::ToBase64String($imageBytes)
        
        # Determine MIME type based on file extension
        $extension = [System.IO.Path]::GetExtension($ImagePath).ToLower()
        $mimeType = switch ($extension) {
            ".jpg"  { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".png"  { "image/png" }
            ".gif"  { "image/gif" }
            ".bmp"  { "image/bmp" }
            ".webp" { "image/webp" }
            default { "image/jpeg" }
        }
        
        return "data:$mimeType;base64,$base64String"
    }
    catch {
        Write-Error "Failed to convert image to base64: $_"
        return $null
    }
}

# Function to format phone number based on country
function Format-PhoneNumber {
    param(
        [string]$Phone,
        [string]$Country
    )
    
    $countryPrefixes = @{
        "US" = "+1"
        "CA" = "+1"
        "UK" = "+44"
        "AU" = "+61"
        "DE" = "+49"
        "FR" = "+33"
        "ES" = "+34"
        "IT" = "+39"
        "NL" = "+31"
        "SE" = "+46"
        "NO" = "+47"
        "DK" = "+45"
        "FI" = "+358"
    }
    
    $prefix = $countryPrefixes[$Country]
    
    # Remove any existing country code or formatting
    $cleanPhone = $Phone -replace '[^\d]', ''
    
    # Add country prefix if not already present
    if (-not $Phone.StartsWith("+")) {
        return "$prefix$cleanPhone"
    }
    
    return $Phone
}

# Set verbose preference to show verbose messages
$VerbosePreference = "Continue"

# Convert profile picture to base64
Write-Verbose "Converting profile picture to base64..."
$base64Image = Convert-ImageToBase64 -ImagePath $ProfilePicturePath

if (-not $base64Image) {
    Write-Error "Failed to process profile picture. Exiting."
    exit 1
}

# Format phone number if provided
$formattedPhone = ""
if ($PhoneNumber) {
    $formattedPhone = Format-PhoneNumber -Phone $PhoneNumber -Country $PhoneCountry
}

# Build the links section dynamically
$linksSection = ""

if ($LinkedInURL) {
    $linksSection += @"
        <a class="link" href="$LinkedInURL" target="_blank">
            <ion-icon name="logo-linkedin"></ion-icon>
            LinkedIn
        </a>
"@
}

if ($GitHubURL) {
    $linksSection += @"
        <a class="link" href="$GitHubURL" target="_blank">
            <ion-icon name="logo-github"></ion-icon>
            GitHub
        </a>
"@
}

if ($PhoneNumber) {
    $linksSection += @"
        <a class="link" href="tel:$formattedPhone" target="_blank">
            <ion-icon name="call-outline"></ion-icon>
            Phone
        </a>
"@
}

if ($EmailAddress) {
    $linksSection += @"
        <a class="link" href="mailto:$EmailAddress" target="_blank">
            <ion-icon name="mail"></ion-icon>
            Email
        </a>
"@
}

# Generate HTML content
$htmlContent = @"
<!DOCTYPE html>
<html>

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta charset="UTF-8">
    <title>$Name</title>
    <style>
        /* Style Settings */
@import url("https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;600&display=swap");
:root {
  --bgColor: #000;
  --fgColor: #fff;
  --accentColor: rgba(255, 255, 255, 0.3);
  --font: "Open Sans", sans-serif;
}

body {
  background-color: var(--bgColor);
  color: var(--fgColor);
  font-family: var(--font);
  font-weight: 600;
}

a {
  text-decoration: none;
}

#userPhoto {
  width: 100px;
  height: 100px;
  display: block;
  margin: 10px auto;
  border-radius: 20%;
}

#userName {
  display: block;
  width: 100%;
  text-align: center;
  color: var(--fgColor);
  font-size: 2rem;
  font-weight: 300;
  letter-spacing: 0.2rem;
  margin: 0 auto;
}

#description {
  font-weight: 300;
  width: 100%;
  text-align: center;
  margin-top: 5px;
  text-transform: none;
}

#description2 {
  font-weight: 250;
  width: 100%;
  text-align: center;
  margin-top: 5px;
  text-transform: none;
}

ion-icon {
  margin-right: 0.3rem;
}

#links {
  max-width: 500px;
  width: auto;
  display: block;
  margin: 20px auto;
}

.link {
  display: block;
  background-color: rgba(66, 110, 255, 0.2);
  color: var(--fgColor);
  text-align: center;
  margin-bottom: 20px;
  padding: 17px;
  font-size: 1.2rem;
  font-weight: 300;
  transition: all 0.25s cubic-bezier(0.08, 0.59, 0.29, 0.99);
  border-radius: 10px;
}

.link:hover {
  background-color: var(--accentColor);
  color: var(--bgColor);
  border: none;
}

ion-icon {
  vertical-align: text-bottom;
  width: 1.1875em;
  height: 1.1875em;
}

    </style>
</head>

<body>
    <img id="userPhoto" src="$base64Image" alt="User Photo">
    
    <a href="#">
        <h1 id="userName">$Name</h1>
    </a>
    <br>
    <p id="description">$Description</p>
    <p id="description2">Proudly based in $City</p>

    <div id="links">
$linksSection
    </div>
    
    <script type="module" src="https://esm.sh/ionicons@8.0.8/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://esm.sh/ionicons@8.0.8/dist/ionicons/ionicons.js"></script>
</body>

</html>
"@

# Write HTML content to file
try {
    $htmlContent | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Verbose "HTML file generated successfully: $OutputPath"
    Write-Verbose "Profile picture converted to base64 and embedded."
}
catch {
    Write-Error "Failed to write HTML file: $_"
    exit 1
}

# Display summary
Write-Verbose "`nGenerated profile page with the following details:"
Write-Verbose "Name: $Name"
Write-Verbose "Description: $Description"
Write-Verbose "City: $City"

if ($LinkedInURL) {
    Write-Verbose "LinkedIn: $LinkedInURL"
} else {
    Write-Verbose "LinkedIn: Not provided"
}

if ($GitHubURL) {
    Write-Verbose "GitHub: $GitHubURL"
} else {
    Write-Verbose "GitHub: Not provided"
}

if ($EmailAddress) {
    Write-Verbose "Email: $EmailAddress"
} else {
    Write-Verbose "Email: Not provided"
}

if ($PhoneNumber) {
    Write-Verbose "Phone: $formattedPhone ($PhoneCountry)"
} else {
    Write-Verbose "Phone: Not provided"
}

Write-Verbose "Profile Picture: $ProfilePicturePath (converted to base64)"
Write-Verbose "Output File: $OutputPath"
