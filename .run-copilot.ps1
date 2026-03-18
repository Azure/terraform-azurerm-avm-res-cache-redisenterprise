# Force UTF-8 for all I/O to avoid mojibake
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'

Set-Location 'C:\project\69ba5fc108fe2e50754aa78f'
$prompt = Get-Content 'C:\project\69ba5fc108fe2e50754aa78f\.copilot-prompt.txt' -Raw -Encoding UTF8
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Add-Content -Path 'C:\project\69ba5fc108fe2e50754aa78f\stdout.log' -Value "
=== $timestamp ==="
Add-Content -Path 'C:\project\69ba5fc108fe2e50754aa78f\stderr.log' -Value "
=== $timestamp ==="
copilot -p $prompt --no-color --allow-all --disable-mcp-server github-mcp-server --additional-mcp-config '@C:\Users\zjhe\.openclaw\workspace-trello-router\copilot-mcp-config.json' >> 'C:\project\69ba5fc108fe2e50754aa78f\stdout.log' 2>> 'C:\project\69ba5fc108fe2e50754aa78f\stderr.log'
