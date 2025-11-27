import { Injectable } from '@angular/core';
import { environment } from '../../../../envirenments/environment.development';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class RedirectService {
  private apiUrl = environment.apiUrl;
  private apiUrlRazor = environment.apiUrlRazor;

  constructor( private http: HttpClient) {}

  redirectToOriginal(id: string, newTab: boolean = false): void {
    const url = `${this.apiUrl}Redirect/${id}`;
    if (newTab) {
      window.open(url, '_blank');
    } else {
      window.location.href = url;
    }
  }
  redirectToAbout(newTab: boolean = false): void {
    const url = `${this.apiUrlRazor}/About`;
    if (newTab) {
      window.open(url, '_blank');
    } else {
      window.location.href = url;
    }
}

}