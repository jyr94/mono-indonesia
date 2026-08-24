import { v4 as uuidv4 } from 'uuid';

export function handleConnection(ws, roomManager) {
  const playerId = uuidv4();
  let currentRoom = null;

  ws.playerId = playerId;

  ws.on('message', (data) => {
    try {
      const msg = JSON.parse(data.toString());
      handleMessage(ws, msg, roomManager, playerId, (room) => {
        currentRoom = room;
      });
    } catch (err) {
      ws.send(JSON.stringify({ type: 'error', message: 'Invalid message format' }));
    }
  });

  ws.on('close', () => {
    console.log(`Player ${playerId} disconnected`);
    if (currentRoom) {
      roomManager.leaveRoom(currentRoom.id, playerId);
      broadcast(currentRoom, {
        type: 'player_left',
        playerId,
      });
    }
  });

  ws.send(JSON.stringify({ type: 'connected', playerId }));
}

function handleMessage(ws, msg, roomManager, playerId, setRoom) {
  switch (msg.type) {
    case 'create_room': {
      const room = roomManager.createRoom(playerId);
      const player = { id: playerId, name: msg.name || 'Host', isHost: true };
      room.addPlayer(player);
      setRoom(room);
      ws.send(JSON.stringify({
        type: 'room_created',
        room: room.toJSON(),
      }));
      break;
    }

    case 'join_room': {
      const player = { id: playerId, name: msg.name || 'Player' };
      const room = roomManager.joinRoom(msg.roomCode, player);
      if (!room) {
        ws.send(JSON.stringify({ type: 'error', message: 'Room not found or full' }));
        return;
      }
      setRoom(room);
      ws.send(JSON.stringify({
        type: 'room_joined',
        room: room.toJSON(),
      }));
      broadcast(room, {
        type: 'player_joined',
        player,
        room: room.toJSON(),
      }, playerId);
      break;
    }

    case 'roll_dice': {
      const room = roomManager.findPlayerRoom(playerId);
      if (!room || room.state !== 'inProgress') return;
      const die1 = Math.floor(Math.random() * 6) + 1;
      const die2 = Math.floor(Math.random() * 6) + 1;
      broadcast(room, {
        type: 'dice_rolled',
        playerId,
        dice: { die1, die2, total: die1 + die2, isDoubles: die1 === die2 },
      });
      break;
    }

    case 'start_game': {
      const room = roomManager.findPlayerRoom(playerId);
      if (!room || room.hostId !== playerId) return;
      if (room.players.length < 2) {
        ws.send(JSON.stringify({ type: 'error', message: 'Need at least 2 players' }));
        return;
      }
      room.state = 'inProgress';
      broadcast(room, {
        type: 'game_started',
        room: room.toJSON(),
      });
      break;
    }

    case 'end_turn': {
      const room = roomManager.findPlayerRoom(playerId);
      if (!room || room.state !== 'inProgress') return;
      room.currentPlayerIndex = (room.currentPlayerIndex + 1) % room.players.length;
      broadcast(room, {
        type: 'turn_ended',
        nextPlayerIndex: room.currentPlayerIndex,
        nextPlayerId: room.players[room.currentPlayerIndex].id,
      });
      break;
    }

    case 'chat': {
      const room = roomManager.findPlayerRoom(playerId);
      if (!room) return;
      broadcast(room, {
        type: 'chat_message',
        playerId,
        message: msg.message,
      });
      break;
    }

    default:
      ws.send(JSON.stringify({ type: 'error', message: `Unknown type: ${msg.type}` }));
  }
}

function broadcast(room, message, excludeId = null) {
  // In a real implementation, we'd track ws connections per player
  // For now this is a placeholder for the broadcast pattern
  const data = JSON.stringify(message);
  console.log(`Broadcast to room ${room.id}:`, data);
}
