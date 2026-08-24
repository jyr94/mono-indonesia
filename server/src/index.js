import { WebSocketServer } from 'ws';
import { RoomManager } from './room-manager.js';
import { handleConnection } from './handlers.js';

const PORT = process.env.PORT || 8080;
const wss = new WebSocketServer({ port: PORT });
const roomManager = new RoomManager();

wss.on('connection', (ws) => {
  console.log('Client connected');
  handleConnection(ws, roomManager);
});

console.log(`Monopoli Indonesia server running on port ${PORT}`);
