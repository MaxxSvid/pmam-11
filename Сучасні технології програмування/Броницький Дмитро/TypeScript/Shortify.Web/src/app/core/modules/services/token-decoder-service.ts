import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class TokenDecoderService {
  decodeToken(token: string): any {
    if (!token) return null;
    try {
      const payload = token.split('.')[1];
      return JSON.parse(atob(payload));
    } catch (e) {
      console.error('Error decoding token', e);
      return null;
    }
  }
}