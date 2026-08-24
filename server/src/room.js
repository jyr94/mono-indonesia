import { v4 as uuidv4 } from 'uuid';

export class Room {
  constructor(hostId) {
    this.id = this.generateCode();
    this.hostId = hostId;
    this.players = [];
    this.state = 'waiting'; // waiting | inProgress | finished
    this.currentPlayerIndex = 0;
    this.turnTimer = null;
    this.createdAt = Date.now();
  }

  generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  addPlayer(player) {
    if (this.players.length >= 4) return false;
    if (this.state !== 'waiting') return false;
    this.players.push(player);
    return true;
  }

  removePlayer(playerId) {
    this.players = this.players.filter(p => p.id !== playerId);
    return this.players.length === 0;
  }

  getPlayer(playerId) {
    return this.players.find(p => p.id === playerId);
  }

  toJSON() {
    return {
      id: this.id,
      hostId: this.hostId,
      players: this.players,
      state: this.state,
      currentPlayerIndex: this.currentPlayerIndex,
    };
  }
}
