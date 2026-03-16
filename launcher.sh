#!/bin/bash
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║      Infinite Life Simulator — Launcher      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

MODEL=${ILS_MODEL:-llama3.1:8b}
echo "[INFO] AI Model: $MODEL"

# Ensure Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "[INFO] Starting Ollama service..."
    ollama serve &>/dev/null &
    sleep 2
fi

# Auto-pull model if missing
if ! ollama list 2>/dev/null | grep -q "$MODEL"; then
    echo "[INFO] Model $MODEL not found. Downloading..."
    ollama pull "$MODEL"
fi

# Start backend
echo "[INFO] Starting backend server on port 8000..."
cd backend
ILS_MODEL="$MODEL" python3 main.py &
BACKEND_PID=$!
cd ..

# Wait for server
echo "[INFO] Waiting for server..."
for i in $(seq 1 15); do
    if curl -s http://127.0.0.1:8000/ > /dev/null 2>&1; then
        echo "[INFO] Server is ready!"
        break
    fi
    sleep 1
done

# Launch game
echo "[INFO] Launching game..."
if [ -f "./InfiniteLifeSimulator.x86_64" ]; then
    chmod +x ./InfiniteLifeSimulator.x86_64
    ./InfiniteLifeSimulator.x86_64 &
elif [ -d "./InfiniteLifeSimulator.app" ]; then
    open ./InfiniteLifeSimulator.app &
else
    echo "[WARNING] Game executable not found."
    echo "  The backend is running at http://127.0.0.1:8000"
    echo "  You can run the game from the Godot editor."
fi

echo ""
echo "──────────────────────────────────────────────"
echo " Game is running! Press Ctrl+C to stop."
echo "──────────────────────────────────────────────"

# Trap Ctrl+C to cleanup
trap "echo ''; echo '[INFO] Shutting down...'; kill $BACKEND_PID 2>/dev/null; exit 0" INT
wait $BACKEND_PID
