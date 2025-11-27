import { Component } from '@angular/core';
import { ShortUrl } from '../../core/modules/interfaces/short-url';
import { UrlService } from '../../core/modules/services/url-service';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { map, Observable, take } from 'rxjs';
import { AddLinkRequestDTO } from '../../core/modules/interfaces/add-link-request-dto';
import { Store } from '@ngrx/store';
import { selectUser } from '../../core/modules/services/user.selectors';
import { User } from '../../core/modules/interfaces/user.model';
import { RedirectService } from '../../core/modules/services/redirect-service';

@Component({
  selector: 'app-urls-table',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule
  ],
  templateUrl: './urls-table.component.html',
  styleUrl: './urls-table.component.css'
})
export class UrlsTableComponent {
  urls: ShortUrl[] = [];

  addLink: AddLinkRequestDTO = { OriginURL: '', CreatedBy: '', Title: '', Description: '' };

  errorMessage: string = '';

  currentUser$: Observable<User | null>;

  constructor(
    private urlService: UrlService,
    private store: Store,
    private router: Router,
    private redirectService: RedirectService
  ) {
    this.currentUser$ = this.store.select(selectUser);
  }

  ngOnInit(): void {
    this.loadUrls();
  }

  loadUrls(): void {
    this.urlService.getUrls().subscribe({
      next: (data) => this.urls = data.result,
      error: () => this.errorMessage = 'Failed to load URLs'
    });
  }

  canAdd$(): Observable<boolean> {
    return this.currentUser$.pipe(map(u => !!u));
  }

  canDelete$(url: ShortUrl): Observable<boolean> {
    return this.currentUser$.pipe(
      map(u => !!u && (u!.role === 'Admin' || u!.id === url.createdBy))
    );
  }

  addUrl(): void {
    if (!this.addLink?.OriginURL || !this.addLink?.Title || !this.addLink?.Description) {
      this.errorMessage = 'Please fill in all fields';
      return;
    }

    if (this.urls.some(u => u.originalUrl === this.addLink.OriginURL)) {
      this.errorMessage = 'This URL already exists';
      return;
    }

    this.currentUser$.pipe(take(1)).subscribe(user => {
      if (!user) {
        this.errorMessage = 'User is not authorized';
        return;
      }

      const payload: AddLinkRequestDTO = {
        OriginURL: this.addLink.OriginURL,
        CreatedBy: user.id,
        Title: this.addLink.Title,
        Description: this.addLink.Description
      };

      this.urlService.addUrl(payload).subscribe({
        next: (response) => {
          if (response.success && response.result) {
            this.urls.push(response.result);
            this.addLink = { OriginURL: '', CreatedBy: '', Title: '', Description: '' };
            this.errorMessage = '';
          } else {
            this.errorMessage = response.message[0] || 'Failed to add URL';
          }
        },
        error: (err) => {
          this.errorMessage = err.error?.message || 'Failed to add URL';
        }
      });

    });
  }

  deleteUrl(url: ShortUrl): void {
    this.urlService.deleteUrl(url.id).subscribe({
      next: (response) => {
        if (response.success && response.result) {
          this.urls = this.urls.filter(u => u.id !== response.result);
        } else {
          this.errorMessage = response.message[0] || 'Failed to delete URL';
        }
      },
      error: () => this.errorMessage = 'Failed to delete URL'
    });
  }

  viewDetails(id: string): void {
    this.router.navigate(['/url-info', id]);
  }

  viewOriginal(urlId: string) {
    this.redirectService.redirectToOriginal(urlId, true);
  }
}
