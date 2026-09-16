$ErrorActionPreference = "Stop"

# Asegurar que el directorio de trabajo sea la raíz del proyecto
if ($PSScriptRoot) {
    Set-Location $PSScriptRoot
}

# 1. Localizar ejecutable base de Python
$basePython = if (Get-Command "python" -ErrorAction SilentlyContinue) {
    "python"
} elseif (Get-Command "py" -ErrorAction SilentlyContinue) {
    "py"
} else {
    Write-Error "Error: Python no está instalado o no se encuentra en el PATH del sistema."
    exit 1
}

# 2. Gestionar entorno virtual (venv)
$venvDir = Join-Path $PWD "venv"
$venvScripts = if (Test-Path (Join-Path $venvDir "Scripts")) {
    Join-Path $venvDir "Scripts"
} elseif (Test-Path (Join-Path $venvDir "bin")) {
    Join-Path $venvDir "bin"
} else {
    $null
}

# Verificar si las dependencias ya están disponibles en el entorno actual (ej. contenedor o venv activo)
$depsAvailable = $false
try {
    & $basePython -c "import flask, streamlit" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $depsAvailable = $true
    }
} catch {
    $depsAvailable = $false
}

# Si no hay venv existente y las dependencias no están instaladas, crear venv
if (-not $venvScripts -and -not $depsAvailable) {
    Write-Host "No se encontró entorno virtual ni dependencias necesarias. Creando entorno virtual 'venv'..."
    & $basePython -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error al crear el entorno virtual 'venv'."
        exit 1
    }
    $venvScripts = if (Test-Path (Join-Path $venvDir "Scripts")) {
        Join-Path $venvDir "Scripts"
    } else {
        Join-Path $venvDir "bin"
    }
}

# Activar venv si existe agregando su ruta de ejecutables al PATH
if ($venvScripts) {
    $env:VIRTUAL_ENV = $venvDir
    $env:PATH = "$venvScripts;$($env:PATH)"
}

# Determinar el ejecutable de Python a utilizar
$pythonExe = if ($venvScripts -and (Test-Path (Join-Path $venvScripts "python.exe"))) {
    Join-Path $venvScripts "python.exe"
} elseif ($venvScripts -and (Test-Path (Join-Path $venvScripts "python"))) {
    Join-Path $venvScripts "python"
} else {
    $basePython
}

# 3. Comprobar e instalar dependencias si faltan
$hasDeps = $false
try {
    & $pythonExe -c "import flask, streamlit" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $hasDeps = $true
    }
} catch {
    $hasDeps = $false
}

if (-not $hasDeps) {
    Write-Host "Instalando dependencias desde requirements.txt..."
    & $pythonExe -m pip install --upgrade pip
    & $pythonExe -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error al instalar dependencias desde requirements.txt."
        exit 1
    }
}

Write-Host "=== Iniciando Backend API Flask ==="
$apiProcess = Start-Process -FilePath $pythonExe -ArgumentList "src/api/app.py" -PassThru

# Esperar a que la API responda
Write-Host "Esperando que el servicio API esté listo en el puerto 5000..."
$healthUrl = "http://127.0.0.1:5000/api/health"
$ready = $false

while (-not $ready) {
    if ($apiProcess.HasExited) {
        Write-Error "El proceso Flask terminó de forma inesperada con código de salida $($apiProcess.ExitCode)."
        exit 1
    }

    try {
        $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $ready = $true
        }
    }
    catch {
        Start-Sleep -Seconds 1
    }
}
Write-Host "API Flask lista."

try {
    Write-Host "=== Iniciando Frontend Streamlit ==="
    & $pythonExe -m streamlit run src/streamlit/main.py `
        --server.port=8501 `
        --server.address=0.0.0.0 `
        --server.headless=true
}
finally {
    # Al detenerse Streamlit, terminar proceso Flask
    if ($apiProcess -and -not $apiProcess.HasExited) {
        Write-Host "Deteniendo proceso Flask..."
        try {
            if ($IsWindows -or $env:OS -eq "Windows_NT") {
                Start-Process -FilePath "taskkill" -ArgumentList "/PID", $apiProcess.Id, "/T", "/F" -NoNewWindow -Wait -ErrorAction SilentlyContinue
            } else {
                Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue
        }
    }
}
