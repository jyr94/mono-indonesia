import { Room } from './room.js';

export class RoomManager {
  constructor() {
    this.rooms = new Map();
  }

  createRoom(hostId) {
    const room = new Room(hostId);
    this.rooms.set(room.id, room);
    return room;
  }

  joinRoom(roomCode, player) {
    const room = this.rooms.get(roomCode);
    if (!room) return null;
    if (!room.addPlayer(player)) return null;
    return room;
  }

  leaveRoom(roomCode, playerId) {
    const room = this.rooms.get(roomCode);
    if (!room) return false;
    const isEmpty = room.removePlayer(playerId);
    if (isEmpty) this.rooms.delete(roomCode);
    return true;
  }

  getRoom(roomCode) {
    return this.rooms.get(roomCode);
  }

  findPlayerRoom(playerId) {
    for (const room of this.rooms.values()) {
      if (room.getPlayer(playerId)) return room;
    }
    return null;
  }
}
