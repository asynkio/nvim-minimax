-- Windows: use PowerShell 7
if vim.fn.has('win32') ~= 1 then return end

-- Used by :terminal and shell commands such as :!, :read !, and :make.
-- GUI launches may inherit a PATH without the Microsoft Store alias directory.
local shell = vim.fn.exepath('pwsh')
if shell == '' then
  local candidates = {
    (vim.env.LOCALAPPDATA or '') .. '/Microsoft/WindowsApps/Microsoft.PowerShell_8wekyb3d8bbwe/pwsh.exe',
    (vim.env.LOCALAPPDATA or '') .. '/Microsoft/WindowsApps/pwsh.exe',
    (vim.env.ProgramFiles or 'C:/Program Files') .. '/PowerShell/7/pwsh.exe',
  }
  -- Neovim may reject Store execution aliases; use the actual package binary.
  local store_packages = vim.fn.glob(
    (vim.env.ProgramFiles or 'C:/Program Files') .. '/WindowsApps/Microsoft.PowerShell_*__8wekyb3d8bbwe/pwsh.exe',
    false,
    true
  )
  vim.list_extend(candidates, store_packages)
  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      shell = path
      break
    end
  end
  -- WindowsApps does not always allow directory enumeration, so glob() can
  -- miss an installed Store package. Query its registered location instead.
  if shell == '' then
    local powershell = (vim.env.SystemRoot or 'C:/Windows')
      .. '/System32/WindowsPowerShell/v1.0/powershell.exe'
    local result = vim.system({
      powershell,
      '-NoLogo',
      '-NoProfile',
      '-Command',
      '(Get-AppxPackage -Name Microsoft.PowerShell | Select-Object -First 1).InstallLocation',
    }, { text = true }):wait()
    if result.code == 0 then
      local location = vim.trim(result.stdout or '')
      local path = location .. '/pwsh.exe'
      if location ~= '' and vim.fn.executable(path) == 1 then shell = path end
    end
  end
end

-- Keep paths containing spaces as one executable in shell commands.
vim.o.shell = shell:find(' ', 1, true) and ('"' .. shell .. '"') or (shell ~= '' and shell or 'pwsh')
vim.o.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
  .. '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();'
  .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
  .. "$PSStyle.OutputRendering='PlainText';"
vim.o.shellquote = ''
vim.o.shellxquote = ''
vim.o.shellpipe = '> %s 2>&1'
vim.o.shellredir = '> %s 2>&1'
vim.o.shelltemp = false
vim.env.__SuppressAnsiEscapeSequences = '1'
