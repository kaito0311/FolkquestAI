# AGENTS.md

## Project

This repo is a Flutter app for the FQA/FolkQuest mobile experience. The current implementation targets Android and web debug, using Figma-exported raster assets from the `FQA cv v2` design.

## Key Paths

- `lib/main.dart` contains the current app shell, story engine models, controller, UI screens, and reusable widgets.
- `assets/images/figma/` is the canonical Flutter asset tree.
- `web/assets/assets/images/figma/` mirrors the Figma assets for Chrome/web debug asset resolution.
- `test/widget_test.dart` contains the current widget coverage for navigation, story choices, unlocks, restart behavior, and collection filters.
- `screenshots/` is used for local Chrome/Figma comparison captures.

## Figma Access

- Design file: `FQA cv v2`
- URL: `https://www.figma.com/design/0a34l3a5JyYT1L4Z0wtthB/FQA-cv-v2?node-id=0-1`
- File key: `0a34l3a5JyYT1L4Z0wtthB`
- Useful frame node ids:
  - Home: `4:2`
  - Discussion: `7:2`
  - Options: `8:2`
  - Karma reflection: `11:2`
  - Final ending: `22:2`
  - Unlock collectible: `26:68`
  - Collection: `31:2`
  - Pause overlay: `34:2`

Use the installed Figma plugin tools when available. The CLI MCP entry was intentionally removed; do not assume `codex mcp login figma` is needed. In this Codex Desktop session, Figma plugin access was previously authenticated for `minhdt.design@gmail.com`.

## Asset Organization

Keep Figma assets organized by usage:

- `backgrounds/` for full-screen backgrounds and large scene images.
- `buttons/` for image-backed button frames.
- `icons/` for small actionable icons.
- `panels/` for plaques, dialogue panels, cards, badges, and modal panels.
- `collectibles/` for collection item art.
- `navigation/` for collection tab bar assets.
- `decor/` for dividers and small decorative assets.

When adding, moving, or renaming an asset, update both:

- `assets/images/figma/...`
- `web/assets/assets/images/figma/...`

The web mirror exists because Flutter web debug requests assets under `/assets/assets/images/figma/...`.

## Development Rules

- Prefer the existing lightweight Flutter architecture before adding packages.
- Keep story data replaceable; placeholder script content should stay isolated in the story repository section.
- Preserve Vietnamese UI text and check for wrapping/overflow on a 426x899 reference layout.
- Use Figma assets where available instead of recreating visual elements with plain Flutter shapes.
- Do not remove fallback rendering in `FqaAssetImage`; it helps reveal missing assets during debug.

## Verification

Run these before handing off changes:

```powershell
dart format lib test
flutter analyze
flutter test
```

For visual checks, capture the Chrome debug tab and compare against the relevant Figma frame screenshots in `screenshots/`.

## Chrome Screen Capture

When Flutter web is already running in Chrome debug, find the active Chrome DevTools port:

```powershell
Get-NetTCPConnection -State Listen | Where-Object { $_.OwningProcess -in (Get-Process chrome -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id) } | Select-Object LocalAddress,LocalPort,OwningProcess
```

Then capture the `FolkQuest` tab. Replace `$port` if Chrome is not using `61208`:

```powershell
$port = 61208
$outDir = Join-Path (Get-Location) 'screenshots'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$outFile = Join-Path $outDir 'folkquest-chrome-latest.png'
$target = @(curl.exe -s "http://127.0.0.1:$port/json/list" | ConvertFrom-Json | Where-Object { $_.title -eq 'FolkQuest' -and $_.type -eq 'page' } | Select-Object -First 1)[0]
$ws = [System.Net.WebSockets.ClientWebSocket]::new()
$ct = [Threading.CancellationToken]::None
$ws.ConnectAsync([Uri]([string]$target.webSocketDebuggerUrl), $ct).GetAwaiter().GetResult()
$id = 0
function Send-Cdp($method, $params) {
  $script:id++
  $payload = @{ id = $script:id; method = $method; params = $params } | ConvertTo-Json -Depth 8 -Compress
  $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
  $script:ws.SendAsync([ArraySegment[byte]]::new($bytes), [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $script:ct).GetAwaiter().GetResult()
  while ($true) {
    $buffer = New-Object byte[] 1048576
    $ms = [System.IO.MemoryStream]::new()
    do {
      $result = $script:ws.ReceiveAsync([ArraySegment[byte]]::new($buffer), $script:ct).GetAwaiter().GetResult()
      if ($result.Count -gt 0) { $ms.Write($buffer, 0, $result.Count) }
    } while (-not $result.EndOfMessage)
    $msg = ([Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json)
    if ($msg.id -eq $script:id) {
      if ($msg.error) { throw "$method failed: $($msg.error.message)" }
      return $msg.result
    }
  }
}
Send-Cdp 'Page.enable' @{} | Out-Null
Send-Cdp 'Runtime.enable' @{} | Out-Null
Send-Cdp 'Page.bringToFront' @{} | Out-Null
Send-Cdp 'Runtime.evaluate' @{ expression = "Promise.all([document.fonts ? document.fonts.ready : Promise.resolve(), new Promise(r => setTimeout(r, 1000))]).then(() => true)"; awaitPromise = $true } | Out-Null
$screenshot = Send-Cdp 'Page.captureScreenshot' @{ format = 'png'; fromSurface = $true; captureBeyondViewport = $false }
[IO.File]::WriteAllBytes($outFile, [Convert]::FromBase64String($screenshot.data))
$ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, 'done', $ct).GetAwaiter().GetResult()
Get-Item $outFile | Select-Object FullName,Length
```

To capture a Figma reference frame, use the Figma screenshot tool with the file key and node id above, then download the returned `image_url` into `screenshots/`, for example `screenshots/figma-options.png`.
