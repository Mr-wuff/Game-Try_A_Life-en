#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Infinite Life Simulator — Installer        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Check Python
echo "[1/4] Checking Python..."
if ! command -v python3 &> /dev/null; then
    echo "  [ERROR] Python 3 not found!"
    echo "  Install via: sudo apt install python3 python3-pip  (Ubuntu/Debian)"
    echo "           or: brew install python3                  (macOS)"
    exit 1
fi
echo "       $(python3 --version) — OK"

# Step 2: Install deps
echo ""
echo "[2/4] Installing Python dependencies..."
cd backend
python3 -m pip install -r requirements.txt --quiet 2>/dev/null || pip3 install -r requirements.txt --quiet
cd ..
echo "       Dependencies installed — OK"

# Step 3: Check Ollama
echo ""
echo "[3/4] Checking Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "  [INFO] Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
    if [ $? -ne 0 ]; then
        echo "  [ERROR] Ollama installation failed."
        echo "  Please install manually: https://ollama.com/download"
        exit 1
    fi
fi
echo "       Ollama found — OK"

# Step 4: Pull model
echo ""
echo "[4/4] Downloading AI model..."
MODEL=${ILS_MODEL:-llama3.1:8b}

if ollama list 2>/dev/null | grep -q "$MODEL"; then
    echo "       Model $MODEL already downloaded — OK"
else
    echo "  Downloading $MODEL (~4.7 GB). This may take a while..."
    ollama pull "$MODEL"
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Installation complete!                     ║"
echo "║   To play: ./launcher.sh                     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
